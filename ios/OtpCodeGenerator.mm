#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(OtpCodeGenerator, NSObject)

RCT_EXTERN_METHOD(generateOtp:(NSString *)base32SecretKey
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failureCallback:(RCTResponseSenderBlock)failureCallback)

RCT_EXTERN_METHOD(generateOtpWithTime:(NSString *)base32SecretKey
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failureCallback:(RCTResponseSenderBlock)failureCallback)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end

