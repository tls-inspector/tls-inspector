/*
TLSKit
Copyright (C) 2024 Ian Spence

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
	"encoding/pem"
	"fmt"
	"net"
	"net/http"
	"sync"
)

type tserverHTTP struct{}

func (s *tserverHTTP) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
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

	fmt.Printf("HTTP ready on %d\n", port)
	wg.Wait()
	return httpError
}

func (s *tserverHTTP) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		rw.WriteHeader(405)
		return
	}

	switch r.URL.Path {
	case "/":
		rw.Header().Add("Content-Type", "text/html")
		rw.WriteHeader(200)
		rw.Write([]byte("<html><body><h1>CertificateKit Test Server</h1><p>Download <a href=\"/root.crt\" download>root CA certificate</a></p></body></html>"))
	case "/root.crt":
		data := pem.EncodeToMemory(&pem.Block{
			Type:  "CERTIFICATE",
			Bytes: rootCertificate.Raw,
		})
		rw.Header().Add("Content-Type", "application/x-pem-file")
		rw.Header().Add("Content-Length", fmt.Sprintf("%d", len(data)))
		rw.WriteHeader(200)
		rw.Write(data)
	default:
		rw.WriteHeader(404)
		return
	}
}
