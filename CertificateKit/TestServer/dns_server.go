package main

import (
	"encoding/binary"
	"log"
	"math/rand"

	"golang.org/x/net/dns/dnsmessage"
)

type tdnsserver struct{}

var dnsServer tdnsserver

func (s *tdnsserver) processDNSRequest(request []byte) ([]byte, error) {
	var p dnsmessage.Parser
	header, err := p.Start(request)
	if err != nil {
		log.Printf("[DOH] Invalid dns request: %s", err.Error())
		return nil, err
	}

	builder := dnsmessage.NewBuilder(nil, header)
	builder.EnableCompression()

	question, err := p.Question()
	if err != nil {
		log.Printf("[DOH] Invalid dns request: %s", err.Error())
		return nil, err
	}

	builder.StartQuestions()
	builder.Question(question)
	builder.StartAnswers()

	switch question.Name.String() {
	case "dns.google.":
		builder.AResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeA,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.AResource{A: [4]byte{8, 8, 8, 8}})
		builder.AResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeA,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.AResource{A: [4]byte{8, 8, 4, 4}})
	case "single.address.a.example.com.":
		builder.AResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeA,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.AResource{A: [4]byte{192, 0, 2, 1}})
	case "multiple.address.a.example.com.":
		builder.AResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeA,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.AResource{A: [4]byte{192, 0, 2, 1}})
		builder.AResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeA,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.AResource{A: [4]byte{192, 0, 2, 2}})
		builder.AResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeA,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.AResource{A: [4]byte{192, 0, 2, 3}})
	case "cname.a.example.com.":
		builder.CNAMEResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeCNAME,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.CNAMEResource{CNAME: dnsmessage.MustNewName("cname.target.a.example.com.")})
		builder.AResource(dnsmessage.ResourceHeader{
			Name:  dnsmessage.MustNewName("cname.target.a.example.com."),
			Type:  dnsmessage.TypeA,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.AResource{A: [4]byte{192, 0, 2, 1}})
	case "single.address.aaaa.example.com.":
		builder.AAAAResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeAAAA,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.AAAAResource{AAAA: [16]byte{0x20, 0x01, 0x0d, 0xb8, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x1}})
	case "multiple.address.aaaa.example.com.":
		builder.AAAAResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeAAAA,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.AAAAResource{AAAA: [16]byte{0x20, 0x01, 0x0d, 0xb8, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x1}})
		builder.AAAAResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeAAAA,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.AAAAResource{AAAA: [16]byte{0x20, 0x01, 0x0d, 0xb8, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x2}})
		builder.AAAAResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeAAAA,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.AAAAResource{AAAA: [16]byte{0x20, 0x01, 0x0d, 0xb8, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x3}})
	case "cname.aaaa.example.com.":
		builder.CNAMEResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeCNAME,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.CNAMEResource{CNAME: dnsmessage.MustNewName("cname.target.aaaa.example.com.")})
		builder.AAAAResource(dnsmessage.ResourceHeader{
			Name:  dnsmessage.MustNewName("cname.target.aaaa.example.com."),
			Type:  dnsmessage.TypeAAAA,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.AAAAResource{AAAA: [16]byte{0x20, 0x01, 0x0d, 0xb8, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x1}})
	case "recursive.cname.example.com.":
		builder.CNAMEResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeCNAME,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.CNAMEResource{CNAME: dnsmessage.MustNewName("recursive2.cname.example.com.")})
		builder.CNAMEResource(dnsmessage.ResourceHeader{
			Name:  dnsmessage.MustNewName("recursive2.cname.example.com."),
			Type:  dnsmessage.TypeCNAME,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.CNAMEResource{CNAME: dnsmessage.MustNewName("recursive3.cname.example.com.")})
		builder.CNAMEResource(dnsmessage.ResourceHeader{
			Name:  dnsmessage.MustNewName("recursive3.cname.example.com."),
			Type:  dnsmessage.TypeCNAME,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.CNAMEResource{CNAME: dnsmessage.MustNewName("recursive2.cname.example.com.")})
	case "infinite.loop.compression.example.com.":
		reply := request
		reply[7] = 0x01
		reply = append(reply, []byte{0xC0, 0x37}...) // 0xC0 pointer flag, 0x2f offset 47 (itself)
		return reply, nil
	case "incorrect.id.example.com.":
		reply := request
		id := uint16(rand.Intn(65535))
		for id == header.ID {
			id = uint16(rand.Intn(65535))
		}
		binary.BigEndian.PutUint16(reply, id)
		reply[7] = 0x01
		return reply, nil
	case "wrong.type.example.com.":
		builder.AResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeA,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.AResource{A: [4]byte{192, 0, 2, 1}})
		reply, _ := builder.Finish()
		reply[43] = 0xff // unknown rtype
		return reply, nil
	case "bad.length.example.com.":
		builder.CNAMEResource(dnsmessage.ResourceHeader{
			Name:  question.Name,
			Type:  dnsmessage.TypeCNAME,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.CNAMEResource{CNAME: dnsmessage.MustNewName("bad.length.target.example.com.")})
		builder.AResource(dnsmessage.ResourceHeader{
			Name:  dnsmessage.MustNewName("bad.length.target.example.com."),
			Type:  dnsmessage.TypeA,
			Class: dnsmessage.ClassINET,
		}, dnsmessage.AResource{A: [4]byte{192, 0, 2, 1}})
		reply, _ := builder.Finish()
		reply[56] = 0xef // bad length
		return reply, nil
	default:
		header.RCode = dnsmessage.RCodeNameError
		builder = dnsmessage.NewBuilder(nil, header)
		builder.EnableCompression()
		builder.StartQuestions()
		builder.Question(question)
		builder.StartAnswers()
		log.Printf("[DOH] Unknown domain %s", question.Name.String())
	}

	replyBytes, err := builder.Finish()
	if err != nil {
		log.Printf("[DOH] Error forming DNS response for %s: %s", question.Name.String(), err.Error())
		return nil, err
	}

	return replyBytes, nil
}
