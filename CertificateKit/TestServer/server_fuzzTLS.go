package main

import (
	"crypto/rand"
	"fmt"
	"net"
	"sync"
)

type tserverFuzzTLS struct{}

func (s *tserverFuzzTLS) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
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

	fmt.Printf("FuzzTLS ready on %d\n", port)
	wg.Wait()
	return acceptErr
}
