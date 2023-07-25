const NativeModules = {
  OtpCodeGenerator: {
    generateOtp: jest.fn(),
    generateOtpWithTime: jest.fn(),
  },
  Platform: {
    OS: 'ios', // You can set this to 'android' if you want to test the Android case
  },
};

export default NativeModules;
