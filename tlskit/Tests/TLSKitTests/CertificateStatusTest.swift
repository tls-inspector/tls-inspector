// TLSKit
// Copyright (C) Ian Spence and other TLSKit Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Testing
@testable import TLSKit

@Suite("Certificate Status Checks")
struct CertificateStatusTest {
    @Test func testCRL() async throws {
        let certificate = try Certificate(pemString: """
-----BEGIN CERTIFICATE-----
MIIDmjCCAyGgAwIBAgISBTabVvzuMUzMkRhxH6kWulHOMAoGCCqGSM49BAMDMDIx
CzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MQswCQYDVQQDEwJF
ODAeFw0yNTA5MjQxNjQ2NThaFw0yNTEyMjMxNjQ2NTdaMBoxGDAWBgNVBAMMDyou
aWFuc3BlbmNlLmNvbTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABNg9FbiTiKim
IaDnqOV7L+zPNjuatGWC5mjc5ao6vAUiU7OyoZr/PwZORr2lGw/Pijj8Ibw3C56F
O+SOo5RaHFKjggItMIICKTAOBgNVHQ8BAf8EBAMCB4AwHQYDVR0lBBYwFAYIKwYB
BQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFIdk7btMhQXT
kqCofC2h6sCi/DSxMB8GA1UdIwQYMBaAFI8NE6L2Ln7RUGwzGDhdWY4jcpHKMDIG
CCsGAQUFBwEBBCYwJDAiBggrBgEFBQcwAoYWaHR0cDovL2U4LmkubGVuY3Iub3Jn
LzApBgNVHREEIjAggg8qLmlhbnNwZW5jZS5jb22CDWlhbnNwZW5jZS5jb20wEwYD
VR0gBAwwCjAIBgZngQwBAgEwLQYDVR0fBCYwJDAioCCgHoYcaHR0cDovL2U4LmMu
bGVuY3Iub3JnLzc5LmNybDCCAQUGCisGAQQB1nkCBAIEgfYEgfMA8QB3AO08S9bo
BsKkogBX28sk4jgB31Ev7cSGxXAPIN23Pj/gAAABmXzUj1YAAAQDAEgwRgIhANWF
34pwGNNYCwjphcNTFzm5iKKz7l9xxm2O8WmR4775AiEAgJCB/S0SmvHZu5HA5yVC
r3qZp298GayBJyYCA7kDMeIAdgDM+w9qhXEJZf6Vm1PO6bJ8IumFXA2XjbapflTA
/kwNsAAAAZl81I93AAAEAwBHMEUCIGuThwGdORRZXUcLmLSJ96DGbnRFDzj1OVWK
68dGE8wJAiEAjdGvNO2rKmUjqDs/C/r4V+zHIY0ohlZHGzwgdpSif6EwCgYIKoZI
zj0EAwMDZwAwZAIwXmefM0CabRNcfBkSjaL7zHDl66qNdoGEp+y1N8dTMYGTiK2z
mVYW//mubDI5xiiJAjAgKa69td4VSQ3Np+nC8tF69Me5NzDmvmsKIsw1rNPG4QWq
By/YNS+DT5dzngS6b1c=
-----END CERTIFICATE-----
""")
        let issuedBy = try Certificate(pemString: """
-----BEGIN CERTIFICATE-----
MIIEVjCCAj6gAwIBAgIQY5WTY8JOcIJxWRi/w9ftVjANBgkqhkiG9w0BAQsFADBP
MQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJuZXQgU2VjdXJpdHkgUmVzZWFy
Y2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBYMTAeFw0yNDAzMTMwMDAwMDBa
Fw0yNzAzMTIyMzU5NTlaMDIxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBF
bmNyeXB0MQswCQYDVQQDEwJFODB2MBAGByqGSM49AgEGBSuBBAAiA2IABNFl8l7c
S7QMApzSsvru6WyrOq44ofTUOTIzxULUzDMMNMchIJBwXOhiLxxxs0LXeb5GDcHb
R6EToMffgSZjO9SNHfY9gjMy9vQr5/WWOrQTZxh7az6NSNnq3u2ubT6HTKOB+DCB
9TAOBgNVHQ8BAf8EBAMCAYYwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMB
MBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFI8NE6L2Ln7RUGwzGDhdWY4j
cpHKMB8GA1UdIwQYMBaAFHm0WeZ7tuXkAXOACIjIGlj26ZtuMDIGCCsGAQUFBwEB
BCYwJDAiBggrBgEFBQcwAoYWaHR0cDovL3gxLmkubGVuY3Iub3JnLzATBgNVHSAE
DDAKMAgGBmeBDAECATAnBgNVHR8EIDAeMBygGqAYhhZodHRwOi8veDEuYy5sZW5j
ci5vcmcvMA0GCSqGSIb3DQEBCwUAA4ICAQBnE0hGINKsCYWi0Xx1ygxD5qihEjZ0
RI3tTZz1wuATH3ZwYPIp97kWEayanD1j0cDhIYzy4CkDo2jB8D5t0a6zZWzlr98d
AQFNh8uKJkIHdLShy+nUyeZxc5bNeMp1Lu0gSzE4McqfmNMvIpeiwWSYO9w82Ob8
otvXcO2JUYi3svHIWRm3+707DUbL51XMcY2iZdlCq4Wa9nbuk3WTU4gr6LY8MzVA
aDQG2+4U3eJ6qUF10bBnR1uuVyDYs9RhrwucRVnfuDj29CMLTsplM5f5wSV5hUpm
Uwp/vV7M4w4aGunt74koX71n4EdagCsL/Yk5+mAQU0+tue0JOfAV/R6t1k+Xk9s2
HMQFeoxppfzAVC04FdG9M+AC2JWxmFSt6BCuh3CEey3fE52Qrj9YM75rtvIjsm/1
Hl+u//Wqxnu1ZQ4jpa+VpuZiGOlWrqSP9eogdOhCGisnyewWJwRQOqK16wiGyZeR
xs/Bekw65vwSIaVkBruPiTfMOo0Zh4gVa8/qJgMbJbyrwwG97z/PRgmLKCDl8z3d
tA0Z7qq7fta0Gl24uyuB05dqI5J1LvAzKuWdIjT1tP8qCoxSE/xpix8hX2dt3h+/
jujUgFPFZ0EVZ0xSyBNRF3MboGZnYXFUxpNjTWPKpagDHJQmqrAcDmWJnMsFY3jS
u1igv3OefnWjSQ==
-----END CERTIFICATE-----
""")
        let crlResult = CRLManager.checkCertificate(certificate, issuedBy: issuedBy)

        switch crlResult {
        case .success(let success):
            #expect(success != nil)
        case .failure(let failure):
            Issue.record(failure, "CRL status check failed")
        }
    }
}
