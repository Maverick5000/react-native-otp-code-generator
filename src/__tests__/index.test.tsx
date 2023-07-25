// Import the functions to be tested
import { generateOtp, generateOtpWithTime } from '../index';
import { NativeModules } from 'react-native';

jest.mock('react-native', () => {
  return {
    NativeModules: {
      OtpCodeGenerator: {
        generateOtp: jest.fn(),
        generateOtpWithTime: jest.fn(),
      },
    },
    Platform: {
      select: jest.fn((options) => options.ios), // You can set this to 'android' if you want to test the Android case
    },
  };
});

// Tests for generateOtp function
describe('generateOtp', () => {
  it('should call the successCallback with the generated OTP', () => {
    const successCallback = jest.fn();
    const errorCallback = jest.fn();
    const base32 = 'my-base-32-string';

    // Simulate a successful OTP generation
    NativeModules.OtpCodeGenerator.generateOtp.mockImplementation(
      (_base32: any, success: (arg0: string) => void, _error: any) => {
        success('123456'); // Mock generated OTP
      }
    );

    generateOtp(base32, successCallback, errorCallback);

    expect(successCallback).toHaveBeenCalledWith('123456');
    expect(errorCallback).not.toHaveBeenCalled();
  });

  it('should call the errorCallback when there is an error', () => {
    const successCallback = jest.fn();
    const errorCallback = jest.fn();
    const base32 = 'my-base-32-string';

    // Simulate an error during OTP generation
    NativeModules.OtpCodeGenerator.generateOtp.mockImplementation(
      (
        _base32: any,
        _success: any,
        error: (arg0: string, arg1: string) => void
      ) => {
        error('error_code', 'Error message');
      }
    );

    generateOtp(base32, successCallback, errorCallback);

    expect(successCallback).not.toHaveBeenCalled();
    expect(errorCallback).toHaveBeenCalledWith('error_code', 'Error message');
  });

  // Add more test cases for different scenarios
});

// Tests for generateOtpWithTime function
describe('generateOtpWithTime', () => {
  it('should call the successCallback with the generated OTP and timeRemaining', () => {
    const successCallback = jest.fn();
    const errorCallback = jest.fn();
    const base32 = 'my-base-32-string';

    // Simulate a successful OTP generation with time
    NativeModules.OtpCodeGenerator.generateOtpWithTime.mockImplementation(
      (
        _base32: any,
        success: (arg0: {
          otp: string; // Mock generated OTP
          timeRemaining: string;
        }) => void,
        _error: any
      ) => {
        const otpResponse = {
          otp: '123456', // Mock generated OTP
          timeRemaining: '30', // Mock time remaining
        };
        success(otpResponse);
      }
    );

    generateOtpWithTime(base32, successCallback, errorCallback);

    expect(successCallback).toHaveBeenCalledWith({
      otp: '123456',
      timeRemaining: '30',
    });
    expect(errorCallback).not.toHaveBeenCalled();
  });

  it('should call the errorCallback when there is an error', () => {
    const successCallback = jest.fn();
    const errorCallback = jest.fn();
    const base32 = 'my-base-32-string';

    // Simulate an error during OTP generation with time
    NativeModules.OtpCodeGenerator.generateOtpWithTime.mockImplementation(
      (
        _base32: any,
        _success: any,
        error: (arg0: string, arg1: string) => void
      ) => {
        error('error_code', 'Error message');
      }
    );

    generateOtpWithTime(base32, successCallback, errorCallback);

    expect(successCallback).not.toHaveBeenCalled();
    expect(errorCallback).toHaveBeenCalledWith('error_code', 'Error message');
  });
});
