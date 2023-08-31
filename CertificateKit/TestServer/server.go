package main

type IServer interface {
	Start(port uint16, ipv4 string, ipv6 string, servername string) error
}
