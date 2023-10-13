package main

import (
	"crypto/tls"
	"fmt"
	"net/http"
	"sync"
)

type tserverHTTPSRedirect struct {
	a bool
}

func (s *tserverHTTPSRedirect) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
	chain, _, err := generateCertificateChain("HTTPSRedirect", 1, port, ipv4, ipv6, servername, nil)
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

	fmt.Printf("HTTPSRedirect ready on %d\n", port)
	wg.Wait()
	return httpError
}

func (s *tserverHTTPSRedirect) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	rw.Header().Add("Content-Type", "text/html")
	rw.Header().Add("X-CertificateKit-Test-Name", "HTTPSRedirect")
	rw.Header().Add("Content-Security-Policy", "default-src * localhost:8413")
	rw.Header().Add("Permissions-Policy", "geolocation ()")
	rw.Header().Add("Referrer-Policy", "no-referrer")
	rw.Header().Add("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
	rw.Header().Add("X-Content-Type-Options", "nosniff")
	rw.Header().Add("X-Frame-Options", "DENY")
	if s.a {
		rw.Header().Add("Location", "https://localhost:8413/other")
		s.a = false
	} else {
		rw.Header().Add("Location", "other")
		s.a = true
	}
	rw.WriteHeader(301)
	rw.Write([]byte("<html><body><h1>It worked!</h1></body></html>"))
}
