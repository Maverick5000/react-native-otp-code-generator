package com.otpcodegenerator;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactMethod;

import java.nio.ByteBuffer;

import java.time.Instant;

import androidx.annotation.NonNull;

@ReactModule(name = OtpCodeGeneratorModule.NAME)
public class OtpCodeGeneratorModule extends ReactContextBaseJavaModule {
    public static final String NAME = "OtpCodeGenerator";
    private static final int DEFAULT_PASSCODE_LENGTH = 6;
    private static final int MAX_PASSCODE_LENGTH = 9;
    private final int passcodeLength;

    public OtpCodeGeneratorModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.passcodeLength = DEFAULT_PASSCODE_LENGTH;
    }

    public OtpCodeGeneratorModule(ReactApplicationContext reactContext, int passcodeLength) {
        super(reactContext);
        if (passcodeLength < 1 || passcodeLength > MAX_PASSCODE_LENGTH) {
            throw new IllegalArgumentException("Passcode length must be between 1 and " + MAX_PASSCODE_LENGTH);
        }
        this.passcodeLength = passcodeLength;
    }

    private String generateOTP(String base32SecretKey, long counter) {
        try {
            byte[] key = OtpCodeGeneratorUtils.base32Decode(base32SecretKey);
            byte[] counterBytes = ByteBuffer.allocate(8).putLong(counter).array();
            byte[] hash = OtpCodeGeneratorUtils.hmacSha(key, counterBytes);
            int otpValue = OtpCodeGeneratorUtils.truncateHash(hash, passcodeLength);

            // Pad the OTP value with leading zeros if necessary
            String otp = String.format("%0" + passcodeLength + "d", otpValue);
            return otp;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @ReactMethod
    public void generateOtp(String base32SecretKey, Callback successCallback, Callback errorCallback) {
        try {
            if (base32SecretKey == null || base32SecretKey.isEmpty()) {
                errorCallback.invoke("INVALID_BASE32", "The provided base32 string is empty or null.");
                return;
            }

            String otp = generateOTP(base32SecretKey, Instant.now().getEpochSecond() / 30);
            successCallback.invoke(otp);
        } catch (Exception e) {
            e.printStackTrace();
            errorCallback.invoke("ERROR", e.getMessage());
        }
    }

    @ReactMethod
    public void generateOtpWithTime(String base32SecretKey, Callback successCallback, Callback errorCallback) {
        try {
            if (base32SecretKey == null || base32SecretKey.isEmpty()) {
                errorCallback.invoke("INVALID_BASE32", "The provided base32 string is empty or null.");
                return;
            }

            byte[] key = OtpCodeGeneratorUtils.base32Decode(base32SecretKey);
            long currentTime = Instant.now().getEpochSecond();
            long counter = currentTime / 30;
            long nextInterval = (counter + 1) * 30;
            int remainingSeconds = (int) (nextInterval - currentTime);
            double timeRemainingPercentage = (double) remainingSeconds / 30.0;

            String otp = generateOTP(base32SecretKey, counter);

            WritableMap otpWithTime = Arguments.createMap();
            otpWithTime.putString("otp", otp);
            otpWithTime.putString("timeRemaining", String.valueOf(timeRemainingPercentage));

            successCallback.invoke(otpWithTime);
        } catch (Exception e) {
            e.printStackTrace();
            errorCallback.invoke("ERROR", e.getMessage());
        }
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }
}
