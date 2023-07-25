import Foundation

class OtpCodeGeneratorUtils {
    private static let ALGORITHM = CCHmacAlgorithm(kCCHmacAlgSHA1)
    private static let BASE32_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    private static let DEFAULT_PASSCODE_LENGTH = 6
    private static let MAX_PASSCODE_LENGTH = 9

    static func hmacSha(key: Data, data: Data) -> Data? {
        var result = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        key.withUnsafeBytes { keyPtr in
            data.withUnsafeBytes { dataPtr in
                CCHmac(OtpCodeGeneratorUtils.ALGORITHM, keyPtr.baseAddress, key.count, dataPtr.baseAddress, data.count, &result)
            }
        }
        return Data(result)
    }

    static func base32Decode(_ base32SecretKey: String) -> Data? {
        let base32Chars = OtpCodeGeneratorUtils.BASE32_CHARS
        var base32SecretKey = base32SecretKey.uppercased().replacingOccurrences(of: " ", with: "") // Remove any spaces

        // Remove any padding characters '=' from the end of the secret key
        while base32SecretKey.hasSuffix("=") {
            base32SecretKey.removeLast()
        }

        var numBytes = Int(ceil(Double(base32SecretKey.count) * 5 / 8.0))
        var bytes = [UInt8](repeating: 0, count: numBytes)

        var currentByte = 0
        var bitsRemaining = 8
        var mask = 0
        for c in base32SecretKey {
            guard let value = base32Chars.firstIndex(of: c)?.encodedOffset else {
                return nil
            }

            if bitsRemaining > 5 {
                mask = value << (bitsRemaining - 5)
                bytes[currentByte] |= UInt8(mask)
                bitsRemaining -= 5
            } else {
                mask = value >> (5 - bitsRemaining)
                bytes[currentByte] |= UInt8(mask)
                currentByte += 1
                bytes[currentByte] |= UInt8((value << (3 + bitsRemaining)) & 0xFF)
                bitsRemaining += 3
            }
        }

        return Data(bytes)
    }

    static func truncateHash(hashValue: Data, passcodeLength: Int) -> Int {
        let hashArray = [UInt8](hashValue)
        let offset = Int(hashArray[hashArray.count - 1] & 0xF)

        var truncatedHash = Int(hashArray[offset] & 0x7F) << 24
        truncatedHash |= Int(hashArray[offset + 1] & 0xFF) << 16
        truncatedHash |= Int(hashArray[offset + 2] & 0xFF) << 8
        truncatedHash |= Int(hashArray[offset + 3] & 0xFF)

        return truncatedHash % Int(pow(10, Double(passcodeLength)))
    }
}
