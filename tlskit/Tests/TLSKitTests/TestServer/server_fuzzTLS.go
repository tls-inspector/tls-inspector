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
	"crypto/rand"
	"crypto/tls"
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

	vers := uint16(tls.VersionTLS12)
	msgBytes := make([]byte, 6)
	msgBytes[0] = byte(uint8(22))
	msgBytes[1] = byte(vers >> 8)
	msgBytes[2] = byte(vers)
	msgBytes[3] = byte(80 >> 8)
	msgBytes[4] = byte(80)
	msgBytes[5] = byte(2)

	go func() {
		for {
			conn, err := t4l.Accept()
			if err != nil {
				acceptErr = err
				wg.Done()
				return
			}
			buf := make([]byte, 8192)
			conn.Read(buf)
			randBytes := make([]byte, 100)
			rand.Read(randBytes)
			tlsHello := append(msgBytes, randBytes...)
			conn.Write(tlsHello)
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
			buf := make([]byte, 8192)
			conn.Read(buf)
			randBytes := make([]byte, 100)
			rand.Read(randBytes)
			tlsHello := append(msgBytes, randBytes...)
			conn.Write(tlsHello)
			conn.Close()
		}
	}()

	fmt.Printf("FuzzTLS ready on %d\n", port)
	wg.Wait()
	return acceptErr
}
