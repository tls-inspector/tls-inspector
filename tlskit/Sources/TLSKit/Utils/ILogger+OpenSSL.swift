import Foundation
import OpenSSL

internal func logOpenSSLError(inFile: String, atLine: Int) {
    var opensslFile: UnsafePointer<CChar>?
    var opensslLine: Int32 = -1
    let errorCode = ERR_get_error()
    ERR_peek_last_error_line(&opensslFile, &opensslLine)
    if opensslFile == nil {
        printError("[\(inFile):\(atLine)] (\(errorCode)) Unsuccessful OpenSSL operation but no value returned from ERR_peek_last_error_line")
    } else {
        let fileName = String(cString: opensslFile!)
        printError("[\(inFile):\(atLine)] (\(errorCode)) OpenSSL error in \(fileName):\(opensslLine)")
    }
}
