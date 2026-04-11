/*
TLSKit
Copyright (C) Ian Spence and other TLSKit Contributors

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
	"fmt"
	"os"
	"strconv"
)

func main() {
	args := os.Args[1:]

	startPort := uint16(8400)
	bindIP4 := "127.0.0.1"
	bindIP6 := "::1"
	rootCertPath := ""
	rootKeyPath := ""
	servername := "localhost"

	for i := 0; i < len(args); i++ {
		arg := args[i]

		if arg == "-g" {
			if err := generateRoot(); err != nil {
				panic(err)
			}
			os.Exit(0)
		} else if arg == "-c" || arg == "--cert" {
			if i == len(args)-1 {
				fmt.Fprintf(os.Stderr, "Argument %s requires a value\n", arg)
				os.Exit(1)
			}
			rootCertPath = args[i+1]
			i++
		} else if arg == "-k" || arg == "--key" {
			if i == len(args)-1 {
				fmt.Fprintf(os.Stderr, "Argument %s requires a value\n", arg)
				os.Exit(1)
			}
			rootKeyPath = args[i+1]
			i++
		} else if arg == "-p" || arg == "--start-port" {
			if i == len(args)-1 {
				fmt.Fprintf(os.Stderr, "Argument %s requires a value\n", arg)
				os.Exit(1)
			}
			v, err := strconv.ParseUint(args[i+1], 10, 16)
			if err != nil {
				fmt.Fprintf(os.Stderr, "Invalid value %s for parameter %s\n", args[i+1], arg)
				os.Exit(1)
			}
			startPort = uint16(v)
			i++
		} else if arg == "--bind-ipv4" {
			if i == len(args)-1 {
				fmt.Fprintf(os.Stderr, "Argument %s requires a value\n", arg)
				os.Exit(1)
			}
			bindIP4 = args[i+1]
			i++
		} else if arg == "--bind-ipv6" {
			if i == len(args)-1 {
				fmt.Fprintf(os.Stderr, "Argument %s requires a value\n", arg)
				os.Exit(1)
			}
			bindIP6 = args[i+1]
			i++
		} else if arg == "--servername" {
			if i == len(args)-1 {
				fmt.Fprintf(os.Stderr, "Argument %s requires a value\n", arg)
				os.Exit(1)
			}
			servername = args[i+1]
			i++
		} else {
			fmt.Printf(`Usage: %s <Options>
Required options:
-g                                Generate a new root certificate and private key and exit.
-c <value> --cert <value>         Specify the path to the root certificate PEM file.
-k <value> --key <value>          Specify the path to the root certificate PEM file.

Optional options:
-p <value> --start-port <value>   Specify the starting port number to use. Defaults to 8400.
--bind-ipv4 <value>               Specify the IPv4 address to bind to. Defaults to 127.0.0.1.
--bind-ipv6 <value>               Specify the IPv6 address to bind to. Defaults to ::1.
--servername <value>              Specify the servername for TLS servers & certificates. Defaults to localhost.
`, os.Args[0])
			os.Exit(1)
		}
	}

	if rootCertPath == "" {
		fmt.Fprintf(os.Stderr, "Must specify root certificate path with -c\n")
		os.Exit(1)
	}
	if rootKeyPath == "" {
		fmt.Fprintf(os.Stderr, "Must specify root key path with -c\n")
		os.Exit(1)
	}

	if err := loadRoot(rootCertPath, rootKeyPath); err != nil {
		panic(err)
	}

	start(startPort, bindIP4, bindIP6, servername)
}

func start(startPort uint16, ipv4 string, ipv6 string, servername string) {
	servers := []IServer{
		// Avoid changing the order of the tests as the order here maps directly to what port the test will be assigned
		// and those ports are hard-coded in TLSKit's tests
		&tserverHTTP{},
		&tserverBasicHTTPS{},
		&tserverBareTLS{},
		&tserverTooManyCerts{},
		&tserverNaughtyHTTP{},
		&tserverFuzzHTTP{},
		&tserverFuzzTLS{},
		&tserverBigHTTPHeader{},
		&tserverStatusRevokedCert{}, &tserverRevokedCRLOCSPProvider{},
		&tserverExpiredLeaf{},
		&tserverExpiredInt{},
		&tserverTooManyHTTPHeaders{},
		&tserverTimeout{},
		&tserverRootCA{},
		&tserverCTPrecertificate{},
		&tserverStatusNotRevokedCert{}, &tserverNotRevokedCRLOCSPProvider{},
	}

	port := startPort
	for _, server := range servers {
		go func(p uint16, s IServer) {
			if err := s.Start(p, ipv4, ipv6, servername); err != nil {
				panic(err)
			}
		}(port, server)
		port++
	}

	select {}
}
