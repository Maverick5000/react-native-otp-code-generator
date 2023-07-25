import Foundation
import CommonCrypto

@objc(OtpCodeGenerator)
class OtpCodeGenerator: NSObject {
    static let NAME = "OtpCodeGenerator"
    private static let DEFAULT_PASSCODE_LENGTH = 6
    private static let MAX_PASSCODE_LENGTH = 9
    private let passcodeLength: Int

    override init() {
        self.passcodeLength = OtpCodeGenerator.DEFAULT_PASSCODE_LENGTH
    }

    init(passcodeLength: Int) {
        if passcodeLength < 1 || passcodeLength > OtpCodeGenerator.MAX_PASSCODE_LENGTH {
            fatalError("Passcode length must be between 1 and \(OtpCodeGenerator.MAX_PASSCODE_LENGTH)")
        }
        self.passcodeLength = passcodeLength
    }

    private func generateOTP(base32SecretKey: String, counter: Int64) -> String? {
        guard let key = OtpCodeGeneratorUtils.base32Decode(base32SecretKey) else {
            return nil
        }

        var counterBytes = counter.bigEndian
        let counterData = Data(bytes: &counterBytes, count: MemoryLayout<Int64>.size)
        guard let hash = OtpCodeGeneratorUtils.hmacSha(key: key, data: counterData) else {
            return nil
        }

        let otpValue = OtpCodeGeneratorUtils.truncateHash(hashValue: hash, passcodeLength: passcodeLength)

        // Pad the OTP value with leading zeros if necessary
        let otp = String(format: "%0\(passcodeLength)d", otpValue)
        return otp
    }

    @objc(generateOtp:successCallback:failureCallback:)
    func generateOtp(base32SecretKey: String, successCallback: @escaping RCTResponseSenderBlock, errorCallback: @escaping RCTResponseSenderBlock) {
        guard !base32SecretKey.isEmpty else {
            errorCallback(["INVALID_BASE32", "The provided base32 string is empty or null."])
            return
        }

        if let otp = generateOTP(base32SecretKey: base32SecretKey, counter: Int64(Date().timeIntervalSince1970 / 30)) {
            successCallback([otp])
        } else {
            errorCallback(["ERROR", "Failed to generate OTP."])
        }
    }

    @objc(generateOtpWithTime:successCallback:failureCallback:)
    func generateOtpWithTime(base32SecretKey: String, successCallback: @escaping RCTResponseSenderBlock, errorCallback: @escaping RCTResponseSenderBlock) {
        guard !base32SecretKey.isEmpty else {
            errorCallback(["INVALID_BASE32", "The provided base32 string is empty or null."])
            return
        }

        guard let key = OtpCodeGeneratorUtils.base32Decode(base32SecretKey) else {
            errorCallback(["ERROR", "Failed to generate OTP."])
            return
        }

        let currentTime = Int64(Date().timeIntervalSince1970)
        let counter = currentTime / 30
        let nextInterval = (counter + 1) * 30
        let remainingSeconds = Int(nextInterval - currentTime)
        let timeRemainingPercentage = Double(remainingSeconds) / 30.0

        if let otp = generateOTP(base32SecretKey: base32SecretKey, counter: counter) {
            let otpWithTime = [
                "otp": otp,
                "timeRemaining": String(format: "%.2f", timeRemainingPercentage),
            ]
            successCallback([otpWithTime])
        } else {
            errorCallback(["ERROR", "Failed to generate OTP."])
        }
    }

    @objc
    static func moduleName() -> String {
        return NAME
    }
}
