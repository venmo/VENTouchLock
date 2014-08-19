#import "VENTouchLock.h"

#import <SSKeychain/SSKeychain.h>
#import <LocalAuthentication/LocalAuthentication.h>

@interface VENTouchLock ()

@property (copy, nonatomic) NSString *keychainService;
@property (copy, nonatomic) NSString *keychainAccount;

@property (copy, nonatomic) NSString *touchIDDefaultReason;

@end

@implementation VENTouchLock

- (void)setKeychainService:(NSString *)service
           keychainAccount:(NSString *)account
      touchIDDefaultReason:(NSString *)reason
{
    self.keychainService = service;
    self.keychainAccount = account;
    self.touchIDDefaultReason = reason;
}

#pragma mark - Keychain Methods

- (BOOL)isPasscodeSet
{
    return !![self currentPasscode];
}

- (NSString *)currentPasscode
{
    NSString *service = self.keychainService;
    NSString *account = self.keychainAccount;
    return [SSKeychain passwordForService:service account:account];
}

- (void)setPasscode:(NSString *)passcode
{
    NSString *service = self.keychainService;
    NSString *account = self.keychainAccount;
    [SSKeychain setPassword:passcode forService:service account:account];
}

- (void)deletePasscode
{
    NSString *service = self.keychainService;
    NSString *account = self.keychainAccount;
    [SSKeychain deletePasswordForService:service account:account];
}

#pragma mark - TouchID Methods

- (BOOL)canUseTouchID
{
    LAContext *context = [[LAContext alloc] init];
    return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                error:nil];
}

- (void)showTouchID
{
    NSString *localizedReason = self.touchIDDefaultReason;
    LAContext *context = [[LAContext alloc] init];
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
            localizedReason:localizedReason
                      reply:^(BOOL success, NSError *error) {
                          if (success) {
                              // Unlock
                          }
                          else {
                              // Show Passcode
                          }
                      }];
}

@end
