import { NativeModules, Platform } from 'react-native';

interface OtpResponse {
  otp: string;
  timeRemaining: string;
}

const LINKING_ERROR =
  `The package 'react-native-otp-code-generator' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const OtpCodeGenerator = NativeModules.OtpCodeGenerator
  ? NativeModules.OtpCodeGenerator
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function generateOtp(base32: string, successCallback: (otp: string) => void, errorCallback: (errorCode: string, errorMessage: string) => void) {
    OtpCodeGenerator.generateOtp(
        base32,
        successCallback,
        (errorCode: string, errorMessage: string) => {
            errorCallback(errorCode, errorMessage);
        }
    );
}

export function generateOtpWithTime(base32: string, successCallback: (otpWithTime: OtpResponse) => void, errorCallback: (errorCode: string, errorMessage: string) => void) {
    OtpCodeGenerator.generateOtpWithTime(
        base32,
        successCallback,
        (errorCode: string, errorMessage: string) => {
            errorCallback(errorCode, errorMessage);
        }
    );
}

