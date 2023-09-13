package main

import (
	"bytes"
	"crypto"
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"io"
	"log"
	"math/big"
	"net"
	"net/http"
	"sync"
	"time"

	"golang.org/x/crypto/ocsp"
)

var revokedCertificate *Certificate
var crlocspSigningCertificate *Certificate

type tserverRevokedCert struct{}
type tserverCRLOCSPProvider struct{}

func (s *tserverRevokedCert) Prepare() error {
	return nil
}

func (s *tserverRevokedCert) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
	crlURL := fmt.Sprintf("http://%s:%d/crl", servername, port+1)
	ocspURL := fmt.Sprintf("http://%s:%d/ocsp", servername, port+1)

	chain, certs, err := generateCertificateChain("RevokedCert", 1, port, ipv4, ipv6, servername, &extraCertificateParameters{
		CRL:  &crlURL,
		OCSP: &ocspURL,
	})
	if err != nil {
		return err
	}
	crlocspSigningCertificate = &certs[0]
	revokedCertificate = &certs[1]

	tlsConfig := &tls.Config{
		Certificates: []tls.Certificate{*chain},
		RootCAs:      rootCAPool,
		ServerName:   servername,
	}
	t4l, err := tls.Listen("tcp4", fmt.Sprintf("%s:%d", ipv4, port), tlsConfig)
	if err != nil {
		return err
	}
	t6l, err := tls.Listen("tcp6", fmt.Sprintf("[%s]:%d", ipv6, port), tlsConfig)
	if err != nil {
		return err
	}

	wg := &sync.WaitGroup{}
	wg.Add(1)
	var httpError error

	go func() {
		if err := http.Serve(t4l, s); err != nil {
			httpError = err
		}
		wg.Done()
	}()
	go func() {
		if err := http.Serve(t6l, s); err != nil {
			httpError = err
		}
		wg.Done()
	}()

	fmt.Printf("RevokedCert ready on %d\n", port)
	wg.Wait()
	return httpError
}

func (s *tserverRevokedCert) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	rw.Header().Add("Content-Type", "text/html")
	rw.Header().Add("X-CertificateKit-Test-Name", "RevokedCert")
	rw.WriteHeader(200)
	rw.Write([]byte("<html><body><h1>It worked!</h1></body></html>"))
}

func (s *tserverCRLOCSPProvider) Prepare() error {
	return nil
}

func (s *tserverCRLOCSPProvider) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
	t4l, err := net.Listen("tcp4", fmt.Sprintf("%s:%d", ipv4, port))
	if err != nil {
		return err
	}
	t6l, err := net.Listen("tcp6", fmt.Sprintf("[%s]:%d", ipv6, port))
	if err != nil {
		return err
	}

	wg := &sync.WaitGroup{}
	wg.Add(1)
	var httpError error

	go func() {
		if err := http.Serve(t4l, s); err != nil {
			httpError = err
		}
		wg.Done()
	}()
	go func() {
		if err := http.Serve(t6l, s); err != nil {
			httpError = err
		}
		wg.Done()
	}()

	fmt.Printf("CRLOCSPProvider ready on %d\n", port)
	wg.Wait()
	return httpError
}

func (s *tserverCRLOCSPProvider) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	switch r.URL.Path {
	case "/cert":
		data := pem.EncodeToMemory(&pem.Block{
			Type:  "CERTIFICATE",
			Bytes: revokedCertificate.Certificate.Raw,
		})
		rw.Header().Add("Content-Type", "application/x-pem-file")
		rw.Header().Add("Content-Length", fmt.Sprintf("%d", len(data)))
		rw.WriteHeader(200)
		rw.Write(data)
	case "/ca":
		data := pem.EncodeToMemory(&pem.Block{
			Type:  "CERTIFICATE",
			Bytes: crlocspSigningCertificate.Certificate.Raw,
		})
		rw.Header().Add("Content-Type", "application/x-pem-file")
		rw.Header().Add("Content-Length", fmt.Sprintf("%d", len(data)))
		rw.WriteHeader(200)
		rw.Write(data)
	case "/crl":
		if r.Method != "GET" {
			rw.WriteHeader(405)
			return
		}

		if revokedCertificate == nil {
			log.Print("CRL request before revoked certificate generated")
			rw.WriteHeader(500)
			return
		}

		crl := &x509.RevocationList{
			Number: big.NewInt(1),
			RevokedCertificateEntries: []x509.RevocationListEntry{
				{
					SerialNumber:   revokedCertificate.Certificate.SerialNumber,
					RevocationTime: time.Now(),
					ReasonCode:     1,
				},
			},
		}

		data, err := x509.CreateRevocationList(rand.Reader, crl, crlocspSigningCertificate.Certificate, crlocspSigningCertificate.PrivateKey)
		if err != nil {
			log.Printf("[RevokedCert] Error generating CRL: %s", err.Error())
			rw.WriteHeader(500)
			return
		}

		rw.Header().Set("Content-Type", "application/pkix-crl")
		rw.Header().Set("Content-Length", fmt.Sprintf("%d", len(data)))
		rw.WriteHeader(200)
		io.Copy(rw, bytes.NewReader(data))
	case "/ocsp":
		if r.Method != "POST" {
			rw.WriteHeader(405)
			return
		}

		if r.Header.Get("Content-Type") != "application/ocsp-request" {
			log.Printf("[RevokedCert] Unknown content type '%s'", r.Header.Get("Content-Type"))
			rw.WriteHeader(400)
			return
		}

		if r.ContentLength > 8192 {
			log.Printf("[RevokedCert] Excessive OCSP request size")
			rw.WriteHeader(400)
			return
		}

		requestBytes, err := io.ReadAll(r.Body)
		if err != nil {
			log.Printf("[RevokedCert] Error reading HTTP request: %s", err.Error())
			rw.WriteHeader(400)
			return
		}

		request, err := ocsp.ParseRequest(requestBytes)
		if err != nil {
			log.Printf("[RevokedCert] Error parsing OCSP request: %s", err.Error())
			rw.WriteHeader(400)
			return
		}

		if request.HashAlgorithm != crypto.SHA1 {
			log.Printf("[RevokedCert] Unsupported OCSP hash algorithm")
			rw.WriteHeader(400)
			return
		}

		response := ocsp.Response{
			Status:     ocsp.Unknown,
			ProducedAt: time.Now(),
			ThisUpdate: time.Now(),
			NextUpdate: time.Now(),
		}

		if request.SerialNumber.Cmp(revokedCertificate.Certificate.SerialNumber) == 0 {
			response.Status = ocsp.Revoked
			response.RevocationReason = 1
			response.RevokedAt = time.Now()
			response.SerialNumber = revokedCertificate.Certificate.SerialNumber
		}

		data, err := ocsp.CreateResponse(crlocspSigningCertificate.Certificate, crlocspSigningCertificate.Certificate, response, crlocspSigningCertificate.PrivateKey)
		if err != nil {
			log.Printf("[RevokedCert] Error generating OCSP response: %s", err.Error())
			rw.WriteHeader(500)
			return
		}

		rw.Header().Set("Content-Type", "application/ocsp-response")
		rw.Header().Set("Content-Length", fmt.Sprintf("%d", len(data)))
		rw.WriteHeader(200)
		io.Copy(rw, bytes.NewReader(data))
	default:
		rw.WriteHeader(404)
		return
	}
}
