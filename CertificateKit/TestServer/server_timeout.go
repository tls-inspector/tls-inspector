package main

import (
	"fmt"
	"net"
	"sync"
)

type tserverTimeout struct{}

func (s *tserverTimeout) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
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
			_, err := t4l.Accept()
			if err != nil {
				acceptErr = err
				wg.Done()
				return
			}
		}
	}()
	go func() {
		for {
			_, err := t6l.Accept()
			if err != nil {
				acceptErr = err
				wg.Done()
				return
			}
		}
	}()

	fmt.Printf("Timeout ready on %d\n", port)
	wg.Wait()
	return acceptErr
}
