package main

import (
	"bytes"
	"crypto/tls"
	"encoding/hex"
	"fmt"
	"sync"
)

type tserverBigHTTPHeader struct{}

func (s *tserverBigHTTPHeader) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
	// Although there is no defined limit for a header value curl has a maximum header size of 100KiB, so this will far exceed that
	headerData := hex.EncodeToString(bytes.Repeat([]byte{uint8('1')}, 204800))
	body := []byte("<html><body><h1>It worked!</h1></body></html>")

	chain, err := generateCertificateChain("BigHTTPHeader", 1, port, ipv4, ipv6, servername)
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
			conn.Write([]byte("A-Large-Header: "))
			conn.Write([]byte(headerData))
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
			conn.Write([]byte("A-Large-Header: "))
			conn.Write([]byte(headerData))
			conn.Write([]byte("\r\n\r\n"))
			conn.Write(body)
			conn.Close()
		}
	}()

	fmt.Printf("BigHTTPHeader ready on %d\n", port)
	wg.Wait()
	return acceptErr
}
