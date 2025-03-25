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
import Network

internal final class NetworkFrameworkEngine: Engine {
    let engineOptions: EngineOptions

    init(engineOptions: EngineOptions) {
        self.engineOptions = engineOptions
    }

    func execute(_ request: InspectionRequest, _ target: InspectionTarget, _ dispatchQueue: DispatchQueue, _ complete: @Sendable @escaping (Result<InspectionResponse, TLSKitError>) -> Void) {
        printDebug("[\(#fileID):\(#line)] Starting inspection of target: \(target) with options: \(request)")

        let timer = Timer.start()

        let endpoint = target.endpoint()

        let domain: String

        let tlsOptions = NWProtocolTLS.Options()
        // Don't do OCSP because we do it ourselves
        sec_protocol_options_set_tls_ocsp_enabled(tlsOptions.securityProtocolOptions, false)
        // Enable SNI if serverName provided
        if let serverName = target.serverName {
            sec_protocol_options_set_tls_server_name(tlsOptions.securityProtocolOptions, serverName)
            domain = serverName
        } else {
            domain = target.ipAddress.string
        }

        // These are all nonisolated as we only set them once
        nonisolated(unsafe) var rRemoteAddress: IPAddress?
        nonisolated(unsafe) var rCertificates: [Certificate] = []
        nonisolated(unsafe) var rVersion: TLSVersion?
        nonisolated(unsafe) var rCiphersuite: Ciphersuite?
        nonisolated(unsafe) var rTrustStatus: TrustStatus?

        let semaphore = DispatchSemaphore(value: 0)
        let didComplete = AtomicBool(initialValue: false)

        // Don't reuse sessions otherwise the verify block is not called
        sec_protocol_options_set_tls_resumption_enabled(tlsOptions.securityProtocolOptions, false)

        sec_protocol_options_set_verify_block(tlsOptions.securityProtocolOptions, { metadata, trustRef, verifyComplete in

            let trust = sec_trust_copy_ref(trustRef).takeRetainedValue()
            var trustResult = SecTrustResultType.invalid

            let numberOfCertificates1 = SecTrustGetCertificateCount(trust)

            var oEvalulateError: CFError?
            _ = SecTrustEvaluateWithError(trust, &oEvalulateError)

            let numberOfCertificates2 = SecTrustGetCertificateCount(trust)

            if let error = SecTry(SecTrustGetTrustResult(trust, &trustResult)) {
                didComplete.If(false) {
                    printError("[\(#fileID):\(#line)] error getting trust result: \(error)")
                    complete(.failure(error))
                    verifyComplete(false)
                    return true
                }
                semaphore.signal()
                return
            }

            if log?.getLevel() == .Debug {
                printDebug("[\(#fileID):\(#line)] Trust result details: \(SecTrustCopyResult(trust).debugDescription)")
                if let evalulateError = oEvalulateError {
                    let code = CFErrorGetCode(evalulateError)
                    printDebug("[\(#fileID):\(#line)] Trust error \(code): \(evalulateError.localizedDescription)")
                }
            }

            let numberOfCertificates = SecTrustGetCertificateCount(trust)
            if numberOfCertificates > CertificateChainMaximumLength {
                didComplete.If(false) {
                    printError("[\(#fileID):\(#line)] server returned too many certificates \(numberOfCertificates)")
                    complete(.failure(.responseError("Server returned too many certificates")))
                    verifyComplete(false)
                    return true
                }
                semaphore.signal()
                return
            }
            if numberOfCertificates == 0 {
                didComplete.If(false) {
                    printError("[\(#fileID):\(#line)] server returned no certificates")
                    complete(.failure(.responseError("Server returned no certificates")))
                    verifyComplete(false)
                    return true
                }
                semaphore.signal()
                return
            }
            printDebug("[\(#fileID):\(#line)] server returned \(numberOfCertificates) certificates")

            if trustResult == .unspecified {
                // trusted
                rTrustStatus = .trusted
            } else if trustResult == .proceed {
                // locally trusted
                rTrustStatus = .locallyTrusted
            }

            for i in 0..<numberOfCertificates {
                guard let secCert = SecTrustGetCertificateAtIndex(trust, i) else {
                    didComplete.If(false) {
                        printError("[\(#fileID):\(#line)] Unable to get certificate from trustref at index \(i)")
                        complete(.failure(.responseError("Server returned no certificates")))
                        verifyComplete(false)
                        return true
                    }
                    semaphore.signal()
                    return
                }
                let certificate: Certificate
                do {
                    certificate = try Certificate(secCertificate: secCert)
                } catch {
                    didComplete.If(false) {
                        printError("[\(#fileID):\(#line)] Unable to deseralize seccert from chain at index \(i): \(error)")
                        complete(.failure(.invalidData(error.localizedDescription)))
                        verifyComplete(false)
                        return true
                    }
                    semaphore.signal()
                    return
                }
                rCertificates.append(certificate)
            }

            if #available(iOS 13, *) {
                guard let version = TLSVersion.from(tls_protocol_version_t: sec_protocol_metadata_get_negotiated_tls_protocol_version(metadata)) else {
                    didComplete.If(false) {
                        printError("[\(#fileID):\(#line)] sec_protocol_metadata_get_negotiated_tls_protocol_version bad return")
                        complete(.failure(.invalidData("Unknown or unsupported protocol version")))
                        verifyComplete(false)
                        return true
                    }
                    semaphore.signal()
                    return
                }
                rVersion = version

                guard let suite = Ciphersuite.from(tls_ciphersuite_t: sec_protocol_metadata_get_negotiated_tls_ciphersuite(metadata)) else {
                    didComplete.If(false) {
                        printError("[\(#fileID):\(#line)] sec_protocol_metadata_get_negotiated_tls_ciphersuite bad return")
                        complete(.failure(.invalidData("Unknown or unsupported ciphersuite")))
                        verifyComplete(false)
                        return true
                    }
                    semaphore.signal()
                    return
                }
                rCiphersuite = suite
            } else {
                guard let version = TLSVersion.from(SSLProtocol: sec_protocol_metadata_get_negotiated_protocol_version(metadata)) else {
                    didComplete.If(false) {
                        printError("[\(#fileID):\(#line)] sec_protocol_metadata_get_negotiated_protocol_version bad return")
                        complete(.failure(.invalidData("Unknown or unsupported protocol version")))
                        verifyComplete(false)
                        return true
                    }
                    semaphore.signal()
                    return
                }
                rVersion = version

                guard let suite = Ciphersuite.from(SSLCipherSuite: sec_protocol_metadata_get_negotiated_ciphersuite(metadata)) else {
                    didComplete.If(false) {
                        printError("[\(#fileID):\(#line)] sec_protocol_metadata_get_negotiated_ciphersuite bad return")
                        complete(.failure(.invalidData("Unknown or unsupported ciphersuite")))
                        verifyComplete(false)
                        return true
                    }
                    semaphore.signal()
                    return
                }
                rCiphersuite = suite
            }

            verifyComplete(true)
        }, dispatchQueue)

        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.connectionTimeout = Int(request.timeoutSeconds)
        let parameters = NWParameters.init(tls: tlsOptions, tcp: tcpOptions)
        guard let ipOptions = parameters.defaultProtocolStack.internetProtocol as? NWProtocolIP.Options else {
            // Sometimes NetworkFramework is too generic for its own good... what, is it going to support
            // non-IP based networks?
            printError("[\(#fileID):\(#line)] default protocol stack does not contain an instance of NWProtocolIP")
            fatalError()
        }

        switch request.ipVersion {
        case .ipv4:
            ipOptions.version = .v4
        case .ipv6:
            ipOptions.version = .v6
        case nil:
            ipOptions.version = .any
        }

        let connection = NWConnection(to: endpoint, using: parameters)
        connection.stateUpdateHandler = { state in
            printDebug("[\(#fileID):\(#line)] NWConnection stateUpdateHandler: \(String(describing: state))")
            switch state {
            case .ready:
                guard let innerEndpoint = connection.currentPath?.remoteEndpoint, case .hostPort(let host, _) = innerEndpoint else {
                    didComplete.If(false) {
                        printError("[\(#fileID):\(#line)] No remote endpoint from nwconnection")
                        complete(.failure(.internalError("Internal error")))
                        return true
                    }
                    semaphore.signal()
                    return
                }
                guard let remoteAddress = try? IPAddress.init("\(host)") else {
                    didComplete.If(false) {
                        printError("[\(#fileID):\(#line)] Unable to decode IP address '\(host)'")
                        complete(.failure(.internalError("Internal error")))
                        return true
                    }
                    semaphore.signal()
                    return
                }
                rRemoteAddress = remoteAddress

                StatusProviderHelper.checkCertificates(&rCertificates, checkCRL: request.checkCRL, checkOCSP: request.checkOCSP)
                if let trustFailureReason = TrustStatus.fromChain(certificates: rCertificates, peername: domain, peeraddress: remoteAddress) {
                    rTrustStatus = trustFailureReason
                }

                guard let remoteaddress = rRemoteAddress, let version = rVersion, let ciphersuite = rCiphersuite, let truststatus = rTrustStatus else {
                    if rRemoteAddress == nil {
                        printError("[\(#fileID):\(#line)] Unable to determine remote address")
                    }
                    if rVersion == nil {
                        printError("[\(#fileID):\(#line)] Unable to determine TLS versions")
                    }
                    if rCiphersuite == nil {
                        printError("[\(#fileID):\(#line)] Unable to determine TLS ciphersuite")
                    }
                    if rTrustStatus == nil {
                        printError("[\(#fileID):\(#line)] Unable to determine TLS trust status")
                    }

                    didComplete.If(false) {
                        printError("[\(#fileID):\(#line)] Unable to collect required information from TLS handshake")
                        complete(.failure(.internalError("Internal error")))
                        return true
                    }
                    semaphore.signal()
                    return
                }

                let tlsConnectionInfo = TLSConnection(domain: domain, remoteAddress: remoteaddress, certificates: rCertificates, version: version, ciphersuite: ciphersuite, trust: truststatus, signedTimestamps: nil)

                if !request.checkHTTP {
                    didComplete.If(false) {
                        complete(.success(InspectionResponse(tlsConnection: tlsConnectionInfo, httpServerInfo: nil, elapsedNs: timer.stop())))
                        return true
                    }
                    semaphore.signal()
                    return
                }

                let httpClient = HTTPClient()
                let httpRequest = httpClient.requestFor(host: domain)
                connection.send(content: httpRequest, completion: NWConnection.SendCompletion.contentProcessed({ _ in
                    httpClient.response(from: connection) { result in
                        let httpServerInfo: HTTPServerInfo?
                        switch result {
                        case .success(let r):
                            httpServerInfo = r
                        case .failure:
                            httpServerInfo = nil
                        }

                        didComplete.If(false) {
                            complete(.success(InspectionResponse(tlsConnection: tlsConnectionInfo, httpServerInfo: httpServerInfo, elapsedNs: timer.stop())))
                            return true
                        }
                        semaphore.signal()
                    }
                }))
            default:
                break
            }
        }
        connection.start(queue: dispatchQueue)

        _ = semaphore.wait(timeout: request.timeoutDispatchTime)
        didComplete.If(false) {
            connection.cancel()
            printError("[\(#fileID):\(#line)] Connection timed out")
            complete(.failure(.timedOut))
            return true
        }
    }
}
