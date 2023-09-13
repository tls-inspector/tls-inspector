package main

import (
	"crypto/rand"
	"crypto/tls"
	"encoding/base64"
	"fmt"
	"log"
	"net/http"
	"strings"
	"sync"
)

type tserverDOH struct{}

func (s *tserverDOH) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
	chain, _, err := generateCertificateChain("DOH", 1, port, ipv4, ipv6, servername, nil)
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

	fmt.Printf("DOH ready on %d\n", port)
	wg.Wait()
	return httpError
}

func (s *tserverDOH) processDNSoverHTTPSRequest(rw http.ResponseWriter, r *http.Request) {
	queryBase64 := r.URL.Query().Get("dns")
	if queryBase64 == "" {
		rw.WriteHeader(400)
		return
	}

	if paddingNeeded := 4 - len(queryBase64)%4; paddingNeeded > 0 && paddingNeeded < 4 {
		// DNS over HTTPS requires that the padding characters be omitted, re-add them
		queryBase64 += strings.Repeat("=", paddingNeeded)
	}

	query, err := base64.URLEncoding.DecodeString(queryBase64)
	if err != nil {
		log.Printf("[DOH] Invalid base64 data %s: %s", queryBase64, err.Error())
		rw.WriteHeader(400)
		return
	}

	reply, err := dnsServer.processDNSRequest(query)
	if err != nil {
		rw.WriteHeader(400)
		return
	}

	rw.Header().Add("Content-Type", "application/dns-message")
	rw.Header().Add("Content-Length", fmt.Sprintf("%d", len(reply)))
	rw.WriteHeader(200)
	rw.Write(reply)
}

func (s *tserverDOH) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		rw.WriteHeader(404)
		return
	}

	if r.URL.Path == "/dns-query" {
		s.processDNSoverHTTPSRequest(rw, r)
		return
	} else if r.URL.Path == "/bad-content-type" {
		reply := make([]byte, 255)
		rand.Read(reply)
		rw.Header().Add("Content-Type", "application/dna-message")
		rw.Header().Add("Content-Length", fmt.Sprintf("%d", len(reply)))
		rw.WriteHeader(200)
		rw.Write(reply)
		return
	} else if r.URL.Path == "/oversize-reply" {
		reply := make([]byte, 520)
		rand.Read(reply)
		rw.Header().Add("Content-Type", "application/dns-message")
		rw.Header().Add("Content-Length", fmt.Sprintf("%d", len(reply)))
		rw.WriteHeader(200)
		rw.Write(reply)
		return
	}

	rw.WriteHeader(404)
}
