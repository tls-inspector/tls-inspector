package main

import (
	"crypto/rand"
	"crypto/tls"
	"fmt"
	"sync"
)

type tserverFuzzHTTP struct{}

func (s *tserverFuzzHTTP) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
	chain, _, err := generateCertificateChain("FuzzHTTP", 1, port, ipv4, ipv6, servername, nil)
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
	var acceptErr error

	go func() {
		for {
			conn, err := t4l.Accept()
			if err != nil {
				acceptErr = err
				wg.Done()
				return
			}
			buf := make([]byte, 1024)
			conn.Read(buf)
			resp := make([]byte, 255)
			rand.Read(resp)
			conn.Write(resp)
			conn.Close()
		}
	}()
	go func() {
		for {
			conn, err := t6l.Accept()
			if err != nil {
				acceptErr = err
				wg.Done()
				return
			}
			buf := make([]byte, 1024)
			conn.Read(buf)
			resp := make([]byte, 255)
			rand.Read(resp)
			conn.Write(resp)
			conn.Close()
		}
	}()

	fmt.Printf("FuzzHTTP ready on %d\n", port)
	wg.Wait()
	return acceptErr
}
