package main

import (
	"TestServer/rootca"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"path/filepath"
	"sync"
)

type tserverRootCA struct{}

func (s *tserverRootCA) Prepare() error {
	return nil
}

func (s *tserverRootCA) Start(port uint16, ipv4 string, ipv6 string, servername string) error {
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

	fmt.Printf("RootCA ready on %d\n", port)
	wg.Wait()
	return httpError
}

func (s *tserverRootCA) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		rw.WriteHeader(405)
		return
	}

	if r.URL.Path == "/rootca/latest" {
		rw.Header().Set("Content-Type", "application/json")
		rw.Write([]byte("{\"version\":\"bundle_20250101\"}"))
		return
	} else if r.URL.Path == "/rootca/metadata/bundle_20250101" {
		rw.Header().Set("Content-Type", "application/json")
		metadata, err := rootca.Files.ReadFile("bundle_metadata.json")
		if err != nil {
			panic(err)
		}
		rw.Write(metadata)
		return
	}

	filename := filepath.Base(r.URL.Path)
	f, err := rootca.Files.Open(filename)
	if err != nil {
		log.Printf("[rootca] %s", err.Error())
		rw.WriteHeader(404)
		return
	}
	defer f.Close()
	info, err := f.Stat()
	if err != nil {
		rw.WriteHeader(500)
		return
	}

	rw.Header().Set("Content-Length", fmt.Sprintf("%d", info.Size()))
	rw.Header().Set("Content-Type", "application/octet-stream")
	rw.WriteHeader(200)
	io.Copy(rw, f)
}
