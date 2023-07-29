package main

import (
	"crypto/tls"
	"fmt"
	"sync"
)

type tserverBareTLS struct{}

func (s *tserverBareTLS) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
	chain, err := generateCertificateChain("BareTLS", 1, port, ipv4, ipv6, servername)
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

			conn.Write([]byte{uint8('1')})
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
			conn.Write([]byte{uint8('1')})
			conn.Close()
		}
	}()

	fmt.Printf("BareTLS ready on %d\n", port)
	wg.Wait()
	return acceptErr
}
