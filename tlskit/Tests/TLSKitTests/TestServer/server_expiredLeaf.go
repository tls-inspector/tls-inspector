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
	"fmt"
	"net/http"
	"sync"
	"time"
)

type tserverExpiredLeaf struct{}

func (s *tserverExpiredLeaf) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
	chain, _, err := generateCertificateChain("ExpiredLeaf", 1, port, ipv4, ipv6, servername, &extraCertificateParameters{
		LeafDateRange: &pkiDateRange{
			NotBefore: time.Now().AddDate(0, -2, 0),
			NotAfter:  time.Now().AddDate(0, 0, -1),
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

	fmt.Printf("ExpiredLeaf ready on %d\n", port)
	wg.Wait()
	return httpError
}

func (s *tserverExpiredLeaf) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	rw.Header().Add("Content-Type", "text/html")
	rw.Header().Add("X-CertificateKit-Test-Name", "ExpiredLeaf")
	rw.WriteHeader(200)
	rw.Write([]byte("<html><body><h1>It worked!</h1></body></html>"))
}
