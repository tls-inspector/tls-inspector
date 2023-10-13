# TestServer

TestServer provides a variety of HTTPS and TLS servers for use with unit tests.

## Usage

### Generate a root certificate & key

TestServer requires a root certificate and key to operate. First, generate them using:

```
./TestServer -g
```

This will save `root.crt` and `root.key` in the current directory

### Run the server

To run the server you must provide the paths to the root certificate and key.

```
./TestServer -c root.crt -k root.key
```

Other options are available to customize the default behaviour:

```
Usage: ./TestServer <Options>
Required options:
-g                                Generate a new root certificate and private key and exit.
-c <value> --cert <value>         Specify the path to the root certificate PEM file.
-k <value> --key <value>          Specify the path to the root certificate PEM file.

Optional options:
-p <value> --start-port <value>   Specify the starting port number to use. Defaults to 8400.
--bind-ipv4 <value>               Specify the IPv4 address to bind to. Defaults to 127.0.0.1.
--bind-ipv6 <value>               Specify the IPv6 address to bind to. Defaults to ::1.
--servername <value>              Specify the servername for TLS servers & certificates. Defaults to localhost.
```

## Servers

The order of the server list matches to the order of the port numbers (by default starting at 8400)

**0. HTTP**

This is a control server that provides a basic HTTP server without TLS. A basic HTML index page is provided, and the root certificate can be downloaded in PEM form at `/root.crt`.

**1. Basic HTTPS**

This server provides a basic HTTPS server. Any valid HTTP request is accepted, and the response is always the same, a basic HTML document.

**2. Bare TLS**

This server provides a base TLS server that responds with ASCII `1` and then closes the connection.

**3. Too Many Certs**

This server is another HTTPS server, however it uses a certificate chain of 52 certificates (1 root, 50 intermediates, 1 server).

**4. Naughty HTTP**

This server accepts any HTTP request, invalid or otherwise, and returns a HTTP response that is structurally valid but semantically incorrect.

**5. Fuzz HTTP**

This server accepts any HTTP request, invalid or otherwise, but always returns 255 random binary bytes.

**6. Fuzz TLS**

This server accepts any TLS client hello and returns a TLS handshake record with 100 random binary bytes. The handshake record intentionally incorrectly reports the length as 80 bytes.

**7. Big HTTP Header**

This server accepts any HTTP request, invalid or otherwise, and responds with a valid HTTP response of a HTML document. However, this response includes a HTTP header `A-Large-Header` which has a value of 200KiB of ASCII `1`'s.

**8 & 9. Revoked Certificate**

This is the same as the Basic HTTPS server, however the leaf certificate contains a CRL distribution point and a OCSP responder, both of which will report that the certificate is revoked.

Server #9 is reserved for the CRL & OCSP providers for this certificate.

**10 & 11. Expired Leaf / Intermediate**

These servers provide a basic HTTPS server, expect that the leaf or intermediate certificates are expired.

**12. Too many HTTP Headers**

This server provides a basic HTTPS server where the HTTP response includes 500,000 headers.

**13. HTTPS Redirect**

This server provides a basic HTTPS server where the HTTP response includes a `Location` header. The server will alternate between an absolute path and a relative path`

**14. Naughty HTTPS Redirect**

This server provides a basic HTTPS server where the HTTP response includes a `Location` header with an absolute URL. The host name in that URL is over 255 characters long, and therefor invalid.

**15. DNS over HTTPS**

This server provides a DNS over HTTPS service, for testing purposes only (it won't actually resolve real queries).

It supports UDP Wireformat requests to `/dns-query`. All DoH tests go to this server, but the test changes depending on the query or URL.

|URL|Query|Test Description|
|-|-|-|
|`/dns-query`|A `dns.google.`|_Control_ - Resolves to 8.8.8.8 and 8.8.4.4, used to pass validation within TLS Inspector itself.|
|`/dns-query`|A `single.address.a.example.com.`|_Control_ - Resolves to 192.0.2.1.|
|`/dns-query`|A `multiple.address.a.example.com.`|_Control_ - Resolves to 192.0.2.1, 192.0.2.2, and 192.0.2.3.|
|`/dns-query`|A `cname.a.example.com.`|_Control_ - Resolves to a CNAME of `cname.target.a.example.com.`, which itself resolves to 192.0.2.1.|
|`/dns-query`|AAAA `single.address.aaaa.example.com.`|_Control_ - Resolves to 2001:db8::1.|
|`/dns-query`|AAAA `multiple.address.aaaa.example.com.`|_Control_ -  Resolves to 2001:db8::1,  Resolves to 2001:db8::2,  Resolves to 2001:db8::3.|
|`/dns-query`|AAAA `cname.aaaa.example.com.`|_Control_ - Resolves to a CNAME of `cname.target.aaaa.example.com.`, which itself resolves to 2001:db8::1.|
|`/dns-query`|A `recursive.cname.example.com.`|Returns a recursive CNAME loop where two CNAMEs point to eachother.|
|`/dns-query`|A `infinite.loop.compression.example.com.`|Returns a malformed label that abuses DNS compression to point to itself.|
|`/dns-query`|A `incorrect.id.example.com.`|Returns an otherwise valid DNS response but the ID will be different.|
|`/dns-query`|A `wrong.type.example.com.`|Returns an otherwise valid DNS response, but the resource record type will be unknown.|
|`/dns-query`|A `bad.length.example.com.`|Returns a malformed DNS response with a false data length.|
|`/bad-content-type`|_Any_|Returns a HTTP response with the incorrect `application/dna-message` content type.|
|`/oversize-reply`|_Any_|Returns a HTTP response with random data that exceeds the 512 byte limit of DNS messages.|
