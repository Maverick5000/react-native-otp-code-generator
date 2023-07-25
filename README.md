# React Native OTP Code Generator

A React Native module for generating One-Time Password (OTP) codes using the Time-Based One-Time Password (TOTP) algorithm.

## Installation

### Step 1: Install the module

Install the package from npm:

```bash
npm install react-native-otp-code-generator
```

### Step 2: Link the module (for React Native versions below 0.60)

Link the native module using React Native's CLI:

```bash
react-native link react-native-otp-code-generator
```

## Usage

Import the methods in your JavaScript file:

```javascript
import { generateOtp, generateOtpWithTime, } from 'react-native-otp-code-generator';
```
### Generating an OTP code

To generate a 6-digit OTP code, you can use the `generateOtp` function with callbacks:

```javascript
generateOtp(
  'base32SecretKey',
  (otpcode) => {
    // Use the generated OTP code
    console.log('Generated OTP:', otpcode);
  },
  (errorcode, errorMessage) => {
    console.error(`Error (${errorCode}): ${errorMessage}`);
  }
);
```

### Generating an OTP code with remaining time

To generate a 6-digit OTP code along with the remaining time percentage until the next code is generated, use the `generateOtpWithTime` function with callbacks:

```javascript
generateOtpWithTime(
  'base32SecretKey',
  (otpData) => {
    const { otpcode, timeRemaining } = otpData;
    // Use the generated OTP code and time remaining
    console.log('Generated OTP:', otpcode);
    console.log('Time remaining:', timeRemaining);
  },
  (errorcode, errorMessage) => {
    console.error(`Error (${errorCode}): ${errorMessage}`);
  }
);
```

### Handling Errors

If the provided base32 secret key is invalid or any other error occurs during the OTP code generation process, the error callback will be invoked with an error message. Handle errors using the error callback as shown in the examples above.

---

Please note that this README assumes you have already set up a React Native project and are familiar with the basic concepts of React Native development. If you encounter any issues during installation or usage, refer to the official React Native documentation or open an issue on the library's GitHub repository.

Happy OTP Code Generation! 🚀
