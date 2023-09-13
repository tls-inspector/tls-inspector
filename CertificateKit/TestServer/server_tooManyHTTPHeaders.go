package main

import (
	"crypto/tls"
	"fmt"
	"sync"
)

type tserverTooManyHTTPHeaders struct{}

func (s *tserverTooManyHTTPHeaders) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
	body := []byte("<html><body><h1>It worked!</h1></body></html>")

	chain, _, err := generateCertificateChain("TooManyHTTPHeaders", 1, port, ipv4, ipv6, servername, nil)
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
			conn.Write([]byte("HTTP/1.1 200 OK\r\n"))
			conn.Write([]byte("Content-Type: text/html\r\n"))
			conn.Write([]byte(fmt.Sprintf("Content-Length: %d\r\n", len(body))))
			for i := 0; i < 500000; i++ {
				conn.Write([]byte(fmt.Sprintf("A%d:1\r\n", i)))
			}
			conn.Write([]byte("\r\n\r\n"))
			conn.Write(body)
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
			conn.Write([]byte("HTTP/1.1 200 OK\r\n"))
			conn.Write([]byte("Content-Type: text/html\r\n"))
			conn.Write([]byte(fmt.Sprintf("Content-Length: %d\r\n", len(body))))
			for i := 0; i < 500000; i++ {
				conn.Write([]byte(fmt.Sprintf("A%d:1\r\n", i)))
			}
			conn.Write([]byte("\r\n\r\n"))
			conn.Write(body)
			conn.Close()
		}
	}()

	fmt.Printf("TooManyHTTPHeaders ready on %d\n", port)
	wg.Wait()
	return acceptErr
}
