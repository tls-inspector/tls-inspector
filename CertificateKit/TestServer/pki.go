package main

import (
	"bytes"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/sha1"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/asn1"
	"encoding/pem"
	"fmt"
	"math/big"
	"net"
	"net/url"
	"os"
	"time"
)

type Certificate struct {
	Certificate *x509.Certificate
	PrivateKey  *ecdsa.PrivateKey
}

var rootCAPool *x509.CertPool
var rootCertificate *x509.Certificate
var rootKey *ecdsa.PrivateKey

const signatureAlgorithm = x509.ECDSAWithSHA256

func loadRoot(certPath, keyPath string) error {
	certData, err := os.ReadFile(certPath)
	if err != nil {
		return err
	}
	certPem, _ := pem.Decode(certData)
	if certPem == nil {
		return fmt.Errorf("invalid PEM data from file %s", certPath)
	}
	cert, err := x509.ParseCertificate(certPem.Bytes)
	if err != nil {
		return err
	}
	rootCertificate = cert
	rootCAPool = x509.NewCertPool()
	rootCAPool.AddCert(rootCertificate)

	keyData, err := os.ReadFile(keyPath)
	if err != nil {
		return err
	}
	keyPem, _ := pem.Decode(keyData)
	if keyPem == nil {
		return fmt.Errorf("invalid PEM data from file %s", certPath)
	}
	pkey, err := x509.ParseECPrivateKey(keyPem.Bytes)
	if err != nil {
		return err
	}
	rootKey = pkey
	return nil
}

type pkiDateRange struct {
	NotBefore time.Time
	NotAfter  time.Time
}

type extraCertificateParameters struct {
	CRL               *string
	OCSP              *string
	LastIntPrivateKey *ecdsa.PrivateKey
	LeafDateRange     *pkiDateRange
	IntDateRange      *pkiDateRange
	IncludeExtensions bool
}

func generateCertificateChain(serverId string, nInts int, port uint16, ipv4, ipv6, servername string, extraParams *extraCertificateParameters) (*tls.Certificate, []Certificate, error) {
	certificates := make([][]byte, nInts+1)

	var lastIssuer = rootCertificate
	var lastSigner = rootKey

	var certObjects = make([]Certificate, nInts+1)

	for i := 0; i < nInts; i++ {
		intPrivKey := generateEcKey()
		intPubKey := intPrivKey.Public()
		intPublicKeyBytes, err := x509.MarshalPKIXPublicKey(intPubKey)
		if err != nil {
			return nil, nil, err
		}

		intSubjectKeyId := sha1.Sum(intPublicKeyBytes)

		intTpl := &x509.Certificate{
			SerialNumber: genSerial(),
			Subject: pkix.Name{
				CommonName: fmt.Sprintf("CertificateKit Intermediate #%d (%s)", (i + 1), serverId),
			},
			Issuer:                lastIssuer.Subject,
			NotBefore:             time.Now().UTC().AddDate(-1, 0, 0),
			NotAfter:              time.Now().UTC().AddDate(1, 0, 0),
			KeyUsage:              x509.KeyUsageDigitalSignature | x509.KeyUsageCertSign | x509.KeyUsageCRLSign,
			ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth, x509.ExtKeyUsageServerAuth, x509.ExtKeyUsageOCSPSigning},
			BasicConstraintsValid: true,
			SubjectKeyId:          intSubjectKeyId[:],
			AuthorityKeyId:        lastIssuer.SubjectKeyId,
			SignatureAlgorithm:    signatureAlgorithm,
			MaxPathLenZero:        true,
			IsCA:                  true,
		}
		if extraParams != nil && extraParams.IntDateRange != nil {
			intTpl.NotBefore = extraParams.IntDateRange.NotBefore
			intTpl.NotAfter = extraParams.IntDateRange.NotAfter
		}

		intCertBytes, err := x509.CreateCertificate(rand.Reader, intTpl, lastIssuer, intPubKey, lastSigner)
		if err != nil {
			return nil, nil, err
		}
		intCert, _ := x509.ParseCertificate(intCertBytes)

		certificates[i] = intCertBytes

		lastIssuer = intTpl
		lastSigner = intPrivKey
		certObjects[i] = Certificate{
			Certificate: intCert,
			PrivateKey:  intPrivKey,
		}
	}

	serverPrivKey := generateEcKey()
	serverPubKey := serverPrivKey.Public()
	serverPublicKeyBytes, err := x509.MarshalPKIXPublicKey(serverPubKey)
	if err != nil {
		return nil, nil, err
	}

	serverSubjectKeyId := sha1.Sum(serverPublicKeyBytes)

	serverTpl := &x509.Certificate{
		SerialNumber: genSerial(),
		Subject: pkix.Name{
			CommonName: fmt.Sprintf("CertificateKit Leaf (%s)", serverId),
		},
		Issuer:                lastIssuer.Subject,
		NotBefore:             time.Now().UTC().AddDate(0, 0, -20),
		NotAfter:              time.Now().UTC().AddDate(0, 0, 20),
		KeyUsage:              x509.KeyUsageDigitalSignature | x509.KeyUsageKeyEncipherment,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth, x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid: true,
		SubjectKeyId:          serverSubjectKeyId[:],
		AuthorityKeyId:        lastIssuer.SubjectKeyId,
		SignatureAlgorithm:    signatureAlgorithm,
		IsCA:                  false,
		DNSNames: []string{
			servername,
		},
		IPAddresses: []net.IP{
			net.ParseIP(ipv4), net.ParseIP(ipv6),
		},
		URIs: []*url.URL{
			mustParseURI(fmt.Sprintf("https://%s:%d/", ipv4, port)),
			mustParseURI(fmt.Sprintf("https://[%s]:%d/", ipv6, port)),
			mustParseURI(fmt.Sprintf("https://%s:%d/", servername, port)),
		},
	}

	if extraParams != nil {
		if extraParams.CRL != nil {
			serverTpl.CRLDistributionPoints = []string{*extraParams.CRL}
		}
		if extraParams.OCSP != nil {
			serverTpl.OCSPServer = []string{*extraParams.OCSP}
		}
		if extraParams.LeafDateRange != nil {
			serverTpl.NotBefore = extraParams.LeafDateRange.NotBefore
			serverTpl.NotAfter = extraParams.LeafDateRange.NotAfter
		}
		if extraParams.IncludeExtensions {
			stringVal, err := asn1.MarshalWithParams("hello, world!", "tag:12,utf8")
			if err != nil {
				panic(err)
			}

			loc, err := time.LoadLocation("America/New_York")
			if err != nil {
				panic(err)
			}

			// 29 Nov, 2023, 20:34 ET
			timeVal, err := asn1.MarshalWithParams(time.Date(2023, 11, 29, 20, 34, 00, 00, loc), "tag:24,generalized") // rip, bozo
			if err != nil {
				panic(err)
			}
			intVal, err := asn1.MarshalWithParams(int64(150000), "tag:2")
			if err != nil {
				panic(err)
			}
			boolVal, err := asn1.MarshalWithParams(true, "tag:1")
			if err != nil {
				panic(err)
			}

			serverTpl.ExtraExtensions = []pkix.Extension{
				{
					Id:    asn1.ObjectIdentifier{2, 16, 124, 2, 1},
					Value: stringVal,
				},
				{
					Id:    asn1.ObjectIdentifier{2, 16, 124, 2, 2},
					Value: timeVal,
				},
				{
					Id:    asn1.ObjectIdentifier{2, 16, 124, 2, 3},
					Value: intVal,
				},
				{
					Id:    asn1.ObjectIdentifier{2, 16, 124, 2, 4},
					Value: boolVal,
				},
			}
		}
	}

	certBytes, err := x509.CreateCertificate(rand.Reader, serverTpl, lastIssuer, serverPubKey, lastSigner)
	if err != nil {
		return nil, nil, err
	}
	serverCert, _ := x509.ParseCertificate(certBytes)
	certificates[nInts] = certBytes

	certsAsPem := [][]byte{}
	for i := len(certificates) - 1; i >= 0; i-- {
		certsAsPem = append(certsAsPem, pem.EncodeToMemory(&pem.Block{
			Type:  "CERTIFICATE",
			Bytes: certificates[i],
		}))
	}

	certsPem := bytes.Join(certsAsPem, []byte("\n"))
	keyPem := pem.EncodeToMemory(&pem.Block{
		Type:  "EC PRIVATE KEY",
		Bytes: mustMarshalPrivateKey(serverPrivKey),
	})

	ts, err := tls.X509KeyPair(certsPem, keyPem)
	if err != nil {
		return nil, nil, err
	}
	certObjects[nInts] = Certificate{
		Certificate: serverCert,
		PrivateKey:  serverPrivKey,
	}
	return &ts, certObjects, nil
}

func generateRoot() error {
	privKey := generateEcKey()
	pubKey := privKey.Public()
	privKeyBytes := mustMarshalPrivateKey(privKey)
	publicKeyBytes, err := x509.MarshalPKIXPublicKey(pubKey)
	if err != nil {
		return err
	}

	subjectKeyId := sha1.Sum(publicKeyBytes)

	tpl := &x509.Certificate{
		SerialNumber: genSerial(),
		Subject: pkix.Name{
			CommonName: "CertificateKit Root",
		},
		NotBefore:             time.Now().UTC().AddDate(-10, 0, 0),
		NotAfter:              time.Now().UTC().AddDate(10, 0, 0),
		KeyUsage:              x509.KeyUsageDigitalSignature | x509.KeyUsageCertSign | x509.KeyUsageCRLSign,
		BasicConstraintsValid: true,
		SubjectKeyId:          subjectKeyId[:],
		AuthorityKeyId:        subjectKeyId[:],
		SignatureAlgorithm:    signatureAlgorithm,
		IsCA:                  true,
	}

	certBytes, err := x509.CreateCertificate(rand.Reader, tpl, tpl, pubKey, privKey)
	if err != nil {
		return err
	}

	certPem := pem.EncodeToMemory(&pem.Block{
		Type:  "CERTIFICATE",
		Bytes: certBytes,
	})
	keyPem := pem.EncodeToMemory(&pem.Block{
		Type:  "EC PRIVATE KEY",
		Bytes: privKeyBytes,
	})

	if err := os.WriteFile("root.crt", certPem, 0644); err != nil {
		return err
	}
	if err := os.WriteFile("root.key", keyPem, 0644); err != nil {
		return err
	}
	return nil
}

func generateEcKey() *ecdsa.PrivateKey {
	key, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		panic(err)
	}
	return key
}

func genSerial() *big.Int {
	s, err := rand.Int(rand.Reader, new(big.Int).Lsh(big.NewInt(1), 128))
	if err != nil {
		panic(err)
	}
	return s
}

func mustMarshalPrivateKey(key *ecdsa.PrivateKey) []byte {
	d, err := x509.MarshalECPrivateKey(key)
	if err != nil {
		panic(err)
	}
	return d
}

func mustParseURI(v string) *url.URL {
	u, err := url.Parse(v)
	if err != nil {
		panic(err)
	}
	return u
}
