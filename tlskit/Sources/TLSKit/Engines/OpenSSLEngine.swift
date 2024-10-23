// TLSKit
// Copyright (C) 2024 Ian Spence
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

import Foundation
import OpenSSL

// Due to the use of C-callback methods we need to have this be a global variable
nonisolated(unsafe) fileprivate var rawCertificates: [Data] = []

internal final class OpenSSLEngine: Engine {
    let engineOptions: EngineOptions

    init(engineOptions: EngineOptions) {
        self.engineOptions = engineOptions
    }

    func execute(_ request: InspectionRequest, _ target: InspectionTarget, _ dispatchQueue: DispatchQueue, _ complete: @Sendable @escaping  (Result<InspectionResponse, Error>) -> Void) {
        printDebug("[\(#fileID):\(#line)] Starting inspection of target: \(target) with options: \(request)")

        let semaphore = DispatchSemaphore(value: 0)
        let didComplete = AtomicBool(initialValue: false)

        dispatchQueue.async {
            do {
                let response = try self.getResponse(request, target)
                didComplete.If(false) {
                    complete(.success(response))
                    return true
                }
                semaphore.signal()
            } catch {
                didComplete.If(false) {
                    complete(.failure(error))
                    return true
                }
                semaphore.signal()
            }
        }

        _ = semaphore.wait(timeout: request.timeoutDispatchTime)
        didComplete.If(false) {
            printError("[\(#fileID):\(#line)] Connection timed out")
            complete(.failure(MakeError("Connection timed out")))
            return true
        }
    }

    fileprivate func getResponse(_ request: InspectionRequest, _ target: InspectionTarget) throws -> InspectionResponse {
        let timer = Timer.start()

        guard let context = SSL_CTX_new(TLS_client_method()) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] SSL_CTX_new returned nil")
            throw MakeError("Internal error")
        }

        let verifyCallback: SSL_verify_cb = { (_ preverify: Int32, _ storeContext: OpaquePointer?) -> Int32 in
            guard let certs = X509_STORE_CTX_get1_chain(storeContext) else {
                return 0
            }

            let count = OPENSSL_sk_num(certs)
            if count > CertificateChainMaximumLength {
                printError("[\(#fileID):\(#line)] Certificate chain exceeds maximum number of supported certificates: Count: \(count), Max: \(CertificateChainMaximumLength)")
                return 0
            }

            for i in 0..<count {
                guard let x509 = OPENSSL_sk_value(certs, i) else {
                    return 0
                }

                guard let certDer = I2D.X509(X509(x509)) else {
                    return 0
                }

                rawCertificates.append(certDer)
            }

            return preverify
        }

        let keylogCallback: SSL_CTX_keylog_cb_func = { (_ ctx: OpaquePointer?, _ buf: UnsafePointer<Int8>?) in

        }

        SSL_CTX_set_verify(context, SSL_VERIFY_NONE, verifyCallback)
        SSL_CTX_set_verify_depth(context, Int32(CertificateChainMaximumLength))
        SSL_CTX_set_options(context, UInt64(SSL_OP_NO_SSLv2))
        SSL_CTX_set_keylog_callback(context, keylogCallback)

        nonisolated(unsafe) let conn: OpaquePointer! = BIO_new_ssl_connect(context)
        if conn == nil {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] BIO_new_ssl_connect returned nil")
            throw MakeError("Internal error")
        }

        var host = target.socketAddress()
        if _BIO_set_conn_hostname(conn, host) <= 0 {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] BIO_set_conn_hostname returned nil")
            throw MakeError("Internal error")
        }

        switch request.ipVersion {
        case .ipv4:
            BIO_int_ctrl(conn, BIO_C_SET_CONNECT, 3, BIO_FAMILY_IPV4)
        case .ipv6:
            BIO_int_ctrl(conn, BIO_C_SET_CONNECT, 3, BIO_FAMILY_IPV6)
        case nil:
            BIO_int_ctrl(conn, BIO_C_SET_CONNECT, 3, BIO_FAMILY_IPANY)
        }

        var ssl: OpaquePointer?
        BIO_ctrl(conn, BIO_C_GET_SSL, 0, &ssl)
        if ssl == nil {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] BIO_get_ssl returned nil")
            throw MakeError("Internal error")
        }

        if SSL_set_cipher_list(ssl, "HIGH:!aNULL:!MD5:!RC4") <= 0 {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] SSL_set_cipher_list returned nil")
            throw MakeError("Internal error")
        }

        let domain: String
        if let serverName = request.serverName {
            if withUnsafeMutablePointer(to: &host, { SSL_ctrl(ssl, SSL_CTRL_SET_TLSEXT_HOSTNAME, Int(TLSEXT_NAMETYPE_host_name), $0) }) <= 0 {
                logOpenSSLError(inFile: #fileID, atLine: #line)
                printError("[\(#fileID):\(#line)] SSL_set_tlsext_host_name returned nil")
                throw MakeError("Internal error")
            }

            domain = serverName
        } else {
            domain = target.ipAddress.string
        }

        printDebug("[\(#fileID):\(#line)] Dialing \(target.socketAddress())...")

        if _BIO_do_connect(conn) != 1 {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] BIO_do_connect returned nil")
            throw MakeError("Connection failed")
        }

        printDebug("[\(#fileID):\(#line)] Connected")

        var fd: Int32 = 0
        if withUnsafeMutablePointer(to: &fd, { BIO_ctrl(conn, BIO_C_GET_FD, 0, $0) }) <= 0 {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] BIO_get_fd returned nil")
            throw MakeError("Connection failed")
        }

        guard let remoteAddress = IPAddress.from(socket: fd) else {
            printError("[\(#fileID):\(#line)] Unable to get remote address from socket")
            throw MakeError("Connection failed")
        }

        printDebug("[\(#fileID):\(#line)] Establashing TLS connection...")

        if _BIO_do_handshake(conn) != 1 {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] BIO_do_handshake returned nil")
            throw MakeError("Connection failed")
        }

        printDebug("[\(#fileID):\(#line)] Established with server providing \(rawCertificates.count) certificates")

        if rawCertificates.count == 0 {
            printError("[\(#fileID):\(#line)] No certificates returned")
            throw MakeError("Connection failed")
        }

        guard let cipherRaw = SSL_get_current_cipher(ssl) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] SSL_get_current_cipher returned nil")
            throw MakeError("Connection failed")
        }
        guard let ciphersuite = Ciphersuite.from(SSL_CIPHER: cipherRaw) else {
            printError("[\(#fileID):\(#line)] Unknown SSL ciphersuite")
            throw MakeError("Connection failed")
        }
        guard let version = TLSVersion.from(openssl: SSL_version(ssl)) else {
            printError("[\(#fileID):\(#line)] Unknown TLS version")
            throw MakeError("Connection failed")
        }

        // For security purposes, regular iOS applications are not allowed to access the root CA store
        // for the device. This means that OpenSSL will not be able to determine if a certificate is
        // trusted or get the root CA certificate (as most websites do not present it)
        // The work-around for this is to export and import the certificate into Apple's security
        // library, determine the trust status (which gets the root CA for us).
        // If the security library gave us one more certificate than what the server presented,
        // that's the system-installed root CA
        var secCertificates: [SecCertificate] = []
        for certDer in rawCertificates {
            guard let secCertificate = SecCertificateCreateWithData(nil, certDer as CFData) else {
                printError("[\(#fileID):\(#line)] Unable to decode DER bytes as certificate")
                throw MakeError("Internal error")
            }

            secCertificates.append(secCertificate)
        }

        if secCertificates.count == 0 {
            printError("[\(#fileID):\(#line)] No sec certificates? This shouldn't happen...")
            throw MakeError("Internal error")
        }

        let policy = SecPolicyCreateSSL(true, request.address as CFString)
        var trust: SecTrust!
        SecTrustCreateWithCertificates(secCertificates as CFTypeRef, policy, &trust)
        if trust == nil {
            printError("[\(#fileID):\(#line)] Unable to create trust object with certificates")
            throw MakeError("Internal error")
        }

        var trustResult: SecTrustResultType = .invalid
        if let error = SecTry(SecTrustGetTrustResult(trust, &trustResult)) {
            printError("[\(#fileID):\(#line)] error getting trust result: \(error)")
            throw error
        }

        var rTrustStatus: TrustStatus?
        if trustResult == .unspecified {
            // trusted
            rTrustStatus = .trusted
        } else if trustResult == .proceed {
            // locally trusted
            rTrustStatus = .locallyTrusted
        }

        // The trust object should now have the root certificate
        let certificateCount = SecTrustGetCertificateCount(trust)
        if certificateCount > CertificateChainMaximumLength {
            printError("[\(#fileID):\(#line)] Trust evalulation somehow produced too many certificates. Count \(certificateCount), Max \(CertificateChainMaximumLength)")
            throw MakeError("Internal error")
        } else if certificateCount == 0 {
            printError("[\(#fileID):\(#line)] Trust evaluation somehow produced no certificates.")
            throw MakeError("Internal error")
        }

        var certificates: [Certificate] = []
        if #available(iOS 15.0, *) {
            guard let secCertificates = SecTrustCopyCertificateChain(trust) as? [SecCertificate] else {
                printError("[\(#fileID):\(#line)] SecTrustCopyCertificateChain returned nil")
                throw MakeError("Internal error")
            }
            for secCertificate in secCertificates {
                do {
                    let certificate = try Certificate(secCertificate: secCertificate)
                    certificates.append(certificate)
                } catch {
                    printError("[\(#fileID):\(#line)] Error decoding certificate: \(error.localizedDescription)")
                    throw error
                }
            }
        } else {
            for i in 0 ..< certificateCount {
                guard let secCertificate = SecTrustGetCertificateAtIndex(trust, i) else {
                    printError("[\(#fileID):\(#line)] SecTrustGetCertificateAtIndex returned nil at index \(i)")
                    throw MakeError("Internal error")
                }
                do {
                    let certificate = try Certificate(secCertificate: secCertificate)
                    certificates.append(certificate)
                } catch {
                    printError("[\(#fileID):\(#line)] Error decoding certificate: \(error.localizedDescription)")
                    throw error
                }
            }
        }

        StatusProviderHelper.checkCertificates(&certificates, checkCRL: request.checkCRL, checkOCSP: request.checkOCSP)
        if let trustFailureReason = TrustStatus.fromChain(certificates: certificates, peername: domain, peeraddress: remoteAddress) {
            rTrustStatus = trustFailureReason
        }
        if rTrustStatus == nil {
            rTrustStatus = .untrusted
        }

        var handshakeScts: [SignedCertificateTimestamp]?
        if let rawScts = SSL_get0_peer_scts(ssl), OPENSSL_sk_num(rawScts) > 0 {
            var scts: [SignedCertificateTimestamp] = []
            for i in 0..<OPENSSL_sk_num(rawScts) {
                guard let rawSct = OPENSSL_sk_value(rawScts, i) else {
                    continue
                }
                guard let sct = try? SignedCertificateTimestamp.fromSct(OpaquePointer(rawSct)) else {
                    continue
                }
                scts.append(sct)
            }
            if scts.count > 0 {
                handshakeScts = scts
            }
        }

        let tlsConnection = TLSConnection(domain: domain, remoteAddress: remoteAddress, certificates: certificates, version: version, ciphersuite: ciphersuite, trust: rTrustStatus!, signedTimestamps: handshakeScts)

        if !request.checkHTTP {
            return InspectionResponse(tlsConnection: tlsConnection, httpServerInfo: nil, elapsedNs: timer.stop())
        }

        let client = HTTPClient()
        _ = client.requestFor(host: domain).withUnsafeBytes {
            printDebug("[\(#fileID):\(#line)] Writing \($0.count)B to connection")
            return BIO_write(conn, $0.baseAddress, Int32($0.count))
        }
        let result = client.response(from: conn)
        switch result {
        case .success(let r):
            return InspectionResponse(tlsConnection: tlsConnection, httpServerInfo: r, elapsedNs: timer.stop())
        case .failure:
            return InspectionResponse(tlsConnection: tlsConnection, httpServerInfo: nil, elapsedNs: timer.stop())
        }
    }
}
