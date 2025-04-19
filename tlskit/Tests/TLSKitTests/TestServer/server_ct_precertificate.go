/*
TLSKit
Copyright (C) Ian Spence and other TLSKit Contributors

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
package main

import (
	"crypto/tls"
	"crypto/x509/pkix"
	"encoding/asn1"
	"fmt"
	"net/http"
	"sync"
)

type tserverCTPrecertificate struct{}

func (s *tserverCTPrecertificate) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
	chain, _, err := generateCertificateChain("CTPrecertificate", 1, port, ipv4, ipv6, servername, &extraCertificateParameters{
		CustomExtensions: []pkix.Extension{
			{
				Id:       asn1.ObjectIdentifier{1, 3, 6, 1, 4, 1, 11129, 2, 4, 3},
				Value:    []byte{0x05, 0x00},
				Critical: true,
			},
		},
	})
	if err != nil {
		return err
	}

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

	fmt.Printf("CTPrecertificate ready on %d\n", port)
	wg.Wait()
	return httpError
}

func (s *tserverCTPrecertificate) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	rw.Header().Add("Content-Type", "text/html")
	rw.Header().Add("X-CertificateKit-Test-Name", "CTPrecertificate")
	rw.Header().Add("Content-Security-Policy", "default-src * localhost:8401")
	rw.Header().Add("Permissions-Policy", "geolocation ()")
	rw.Header().Add("Referrer-Policy", "no-referrer")
	rw.Header().Add("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
	rw.Header().Add("X-Content-Type-Options", "nosniff")
	rw.Header().Add("X-Frame-Options", "DENY")
	rw.WriteHeader(200)
	rw.Write([]byte("<html><body><h1>It worked!</h1></body></html>"))
}
