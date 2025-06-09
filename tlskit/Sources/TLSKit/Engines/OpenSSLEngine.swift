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

import Foundation
import OpenSSL

internal final class OpenSSLEngine: Engine {
    let engineOptions: EngineOptions

    init(engineOptions: EngineOptions) {
        self.engineOptions = engineOptions
    }

    func execute(_ request: InspectionRequest, _ target: InspectionTarget, _ dispatchQueue: DispatchQueue, _ complete: @Sendable @escaping  (Result<InspectionResponse, TLSKitError>) -> Void) {
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
                    if let error = error as? TLSKitError {
                        complete(.failure(error))
                    } else {
                        complete(.failure(.internalError(error.localizedDescription)))
                    }
                    return true
                }
                semaphore.signal()
            }
        }

        _ = semaphore.wait(timeout: request.timeoutDispatchTime)
        didComplete.If(false) {
            printError("[\(#fileID):\(#line)] Connection timed out")
            complete(.failure(.timedOut))
            return true
        }
    }

    private func getResponse(_ request: InspectionRequest, _ target: InspectionTarget) throws -> InspectionResponse {
        let timer = Timer.start()

        guard let context = SSL_CTX_new(TLS_client_method()) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] SSL_CTX_new returned nil")
            throw TLSKitError.internalError("libssl error")
        }
        defer {
            SSL_CTX_free(context)
        }

        let keylogCallback: SSL_CTX_keylog_cb_func = { (_ ctx: OpaquePointer?, _ buf: UnsafePointer<Int8>?) in
            // TODO
        }

        SSL_CTX_set_verify(context, SSL_VERIFY_NONE, nil)
        SSL_CTX_set_verify_depth(context, Int32(CertificateChainMaximumLength))
        SSL_CTX_set_options(context, UInt64(SSL_OP_NO_SSLv2))
        SSL_CTX_set_keylog_callback(context, keylogCallback)

        guard let conn = BIO_new_ssl_connect(context) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] BIO_new_ssl_connect returned nil")
            throw TLSKitError.internalError("libssl error")
        }
        defer {
            BIO_free(conn)
        }

        let host = target.socketAddress()
        try BIO.setConnHostname(bio: conn, hostname: host)

        switch request.ipVersion {
        case .ipv4:
            BIO_int_ctrl(conn, BIO_C_SET_CONNECT, 3, BIO_FAMILY_IPV4)
        case .ipv6:
            BIO_int_ctrl(conn, BIO_C_SET_CONNECT, 3, BIO_FAMILY_IPV6)
        case nil:
            BIO_int_ctrl(conn, BIO_C_SET_CONNECT, 3, BIO_FAMILY_IPANY)
        }

        guard let ssl = BIO.getSSL(bio: conn) else {
            throw TLSKitError.internalError("libssl error")
        }

        if SSL_set_cipher_list(ssl, "HIGH:!aNULL:!MD5:!RC4") <= 0 {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] SSL_set_cipher_list returned nil")
            throw TLSKitError.internalError("libssl error")
        }

        let domain: String
        if var serverName = target.serverName?.cString(using: .ascii) {
            if SSL_ctrl(ssl, SSL_CTRL_SET_TLSEXT_HOSTNAME, Int(TLSEXT_NAMETYPE_host_name), &serverName) <= 0 {
                logOpenSSLError(inFile: #fileID, atLine: #line)
                printError("[\(#fileID):\(#line)] SSL_set_tlsext_host_name returned nil")
                throw TLSKitError.internalError("libssl error")
            }

            domain = target.serverName!
        } else {
            domain = target.ipAddress.string
        }

        printDebug("[\(#fileID):\(#line)] Dialing \(target.socketAddress())...")

        try BIO.doConnect(bio: conn)
        printDebug("[\(#fileID):\(#line)] Connected")

        var fd: Int32 = 0
        if withUnsafeMutablePointer(to: &fd, { BIO_ctrl(conn, BIO_C_GET_FD, 0, $0) }) <= 0 {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] BIO_get_fd returned nil")
            throw TLSKitError.connectionError(TLSKitError.internalError("libssl error"))
        }

        let remoteAddress: IPAddress
        do {
            remoteAddress = try IPAddress.from(socket: fd)
        } catch {
            printError("[\(#fileID):\(#line)] Unable to get remote address from socket \(error)")
            throw TLSKitError.connectionError(error)
        }

        printDebug("[\(#fileID):\(#line)] Establashing TLS connection...")

        try BIO.doHandshake(bio: conn)

        guard let cipherRaw = SSL_get_current_cipher(ssl) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] SSL_get_current_cipher returned nil")
            throw TLSKitError.invalidData("Unknown or unsupported ciphersuite")
        }
        guard let ciphersuite = Ciphersuite.from(SSL_CIPHER: cipherRaw) else {
            printError("[\(#fileID):\(#line)] Unknown SSL ciphersuite")
            throw TLSKitError.invalidData("Unknown or unsupported ciphersuite")
        }
        guard let version = TLSVersion.from(openssl: SSL_version(ssl)) else {
            printError("[\(#fileID):\(#line)] Unknown TLS version")
            throw TLSKitError.invalidData("Unknown or unsupported protocol version")
        }

        var certificatesSentByServer: [Data] = []
        guard let certs = SSL_get_peer_cert_chain(ssl) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] SSL_get_peer_cert_chain returned nil")
            throw TLSKitError.internalError("libssl error")
        }
        let certCount = OPENSSL_sk_num(certs)
        printDebug("[\(#fileID):\(#line)] Established with server providing \(certCount) certificates")

        if certCount == 0 {
            printError("[\(#fileID):\(#line)] No certificates returned")
            throw TLSKitError.responseError("Server returned no certificates")
        }

        // For security purposes, regular iOS applications are not allowed to access the root CA store
        // for the device. This means that OpenSSL will not be able to determine if a certificate is
        // trusted or get the root CA certificate (as most websites do not present it)
        // The work-around for this is to export and import the certificate into Apple's security
        // library, determine the trust status (which gets the root CA for us).
        // If the security library gave us one more certificate than what the server presented,
        // that's the system-installed root CA
        var secCertificates: [SecCertificate] = []
        for i in 0..<certCount {
            guard let raw = OPENSSL_sk_value(certs, i), let x509 = OpaquePointer(to: raw) else {
                printError("[\(#fileID):\(#line)] No certificates returned")
                throw TLSKitError.responseError("Server returned no certificates")
            }

            guard let data = I2D.X509(x509), let secCertificate = SecCertificateCreateWithData(nil, data as CFData) else {
                printError("[\(#fileID):\(#line)] Unable to decode DER bytes as certificate")
                throw TLSKitError.invalidData("Server returned no certificates")
            }

            secCertificates.append(secCertificate)
            certificatesSentByServer.add(data)
        }

        if secCertificates.count == 0 {
            printError("[\(#fileID):\(#line)] No sec certificates? This shouldn't happen...")
            throw TLSKitError.internalError("Server returned no certificates")
        }

        // At this stage secCertificates contains only the certificates from the server, so we need to reconstruct the chain
        let policy = SecPolicyCreateSSL(true, (request.serverName ?? request.address) as CFString)
        var trust: SecTrust!
        SecTrustCreateWithCertificates(secCertificates as CFTypeRef, policy, &trust)
        if trust == nil {
            printError("[\(#fileID):\(#line)] Unable to create trust object with certificates")
            throw TLSKitError.invalidData("Server returned no certificates")
        }

        var trustResult: SecTrustResultType = .invalid
        if let error = SecTry(SecTrustGetTrustResult(trust, &trustResult)) {
            printError("[\(#fileID):\(#line)] error getting trust result: \(error)")
            throw error
        }

        if let details = SecTrustCopyResult(trust) {
            printDebug("[\(#fileID):\(#line)] Trust details \(details as NSDictionary)")
        }

        printDebug("[\(#fileID):\(#line)] Trust result \(String(describing: trustResult))")

        var rTrustStatus: TrustStatus?
        if trustResult == .unspecified {
            // trusted
            rTrustStatus = .trusted
        } else if trustResult == .proceed {
            // locally trusted
            rTrustStatus = .locallyTrusted
        }

        // The trust object should now have the full chain
        let certificateCount = SecTrustGetCertificateCount(trust)
        if certificateCount > CertificateChainMaximumLength {
            printError("[\(#fileID):\(#line)] Trust evalulation somehow produced too many certificates. Count \(certificateCount), Max \(CertificateChainMaximumLength)")
            throw TLSKitError.responseError("Server returned too many certificates")
        } else if certificateCount == 0 {
            printError("[\(#fileID):\(#line)] Trust evaluation somehow produced no certificates.")
            throw TLSKitError.invalidData("Server returned no certificates")
        }

        printDebug("[\(#fileID):\(#line)] Certificates from server \(certificatesSentByServer.count), certificates in reassembled chain \(certificateCount)")

        var certificates: [Certificate] = []
        let addCertificate = { (secCertificate: SecCertificate) throws in
            do {
                var source: CertificateSource?
                let data = SecCertificateCopyData(secCertificate) as Data
                if certificatesSentByServer.firstIndex(of: data) == nil {
                    source = .localStore
                } else {
                    source = .server
                }

                let certificate = try Certificate(secCertificate: secCertificate, certificateSource: source)
                certificates.append(certificate)
            } catch {
                printError("[\(#fileID):\(#line)] Error decoding certificate: \(error.localizedDescription)")
                throw error
            }
        }

        if #available(iOS 15.0, *) {
            guard let secCertificates = SecTrustCopyCertificateChain(trust) as? [SecCertificate] else {
                printError("[\(#fileID):\(#line)] SecTrustCopyCertificateChain returned nil")
                throw TLSKitError.internalError("Server returned no certificates")
            }
            for secCertificate in secCertificates {
                try addCertificate(secCertificate)
            }
        } else {
            for i in 0 ..< certificateCount {
                guard let secCertificate = SecTrustGetCertificateAtIndex(trust, i) else {
                    printError("[\(#fileID):\(#line)] SecTrustGetCertificateAtIndex returned nil at index \(i)")
                    throw TLSKitError.internalError("Server returned no certificates")
                }
                try addCertificate(secCertificate)
            }
        }

        StatusProviderHelper.checkCertificates(&certificates, checkCRL: request.checkCRL, checkOCSP: request.checkOCSP)
        if let trustFailureReason = TrustStatus.fromChain(certificates: certificates, peername: domain, peeraddress: remoteAddress) {
            rTrustStatus = trustFailureReason
        }
        if rTrustStatus == nil {
            printWarning("[\(#fileID):\(#line)] Trust status was not trusted but unable to determine cause")
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
