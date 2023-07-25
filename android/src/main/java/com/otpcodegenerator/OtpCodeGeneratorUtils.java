package com.otpcodegenerator;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

public class OtpCodeGeneratorUtils {
    private static final String ALGORITHM = "HmacSHA1";
    private static final String BASE32_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
    private static final int DEFAULT_PASSCODE_LENGTH = 6;
    private static final int MAX_PASSCODE_LENGTH = 9;

    public static byte[] hmacSha(byte[] keyBytes, byte[] text) throws NoSuchAlgorithmException, InvalidKeyException {
        SecretKeySpec key = new SecretKeySpec(keyBytes, ALGORITHM);
        Mac mac = Mac.getInstance(ALGORITHM);
        mac.init(key);
        return mac.doFinal(text);
    }

    public static byte[] base32Decode(String base32SecretKey) {
        base32SecretKey = base32SecretKey.toUpperCase().replaceAll(" ", ""); // Remove any spaces

        // Remove any padding characters '=' from the end of the secret key
        while (base32SecretKey.endsWith("=")) {
            base32SecretKey = base32SecretKey.substring(0, base32SecretKey.length() - 1);
        }

        int numBytes = (int) Math.ceil(base32SecretKey.length() * 5 / 8.0);
        byte[] bytes = new byte[numBytes];

        int currentByte = 0;
        int bitsRemaining = 8;
        int mask = 0;
        for (char c : base32SecretKey.toCharArray()) {
            int value = BASE32_CHARS.indexOf(c);
            if (value < 0) {
                throw new IllegalArgumentException("Invalid Base32 character: " + c);
            }
            if (bitsRemaining > 5) {
                mask = value << (bitsRemaining - 5);
                bytes[currentByte] |= mask;
                bitsRemaining -= 5;
            } else {
                mask = value >> (5 - bitsRemaining);
                bytes[currentByte] |= mask;
                currentByte++;
                bytes[currentByte] |= (value << (3 + bitsRemaining)) & 0xFF;
                bitsRemaining += 3;
            }
        }

        return bytes;
    }

    public static int truncateHash(byte[] hashValue, int passcodeLength) {
        int offset = hashValue[hashValue.length - 1] & 0xF;
        int truncatedHash = ((hashValue[offset] & 0x7F) << 24) |
                ((hashValue[offset + 1] & 0xFF) << 16) |
                ((hashValue[offset + 2] & 0xFF) << 8) |
                (hashValue[offset + 3] & 0xFF);
        return truncatedHash % (int) Math.pow(10, passcodeLength);
    }
}
