#import "VENTouchLock.h"

#import <SSKeychain/SSKeychain.h>
#import <LocalAuthentication/LocalAuthentication.h>

@interface VENTouchLock ()

@property (copy, nonatomic) NSString *keychainService;
@property (copy, nonatomic) NSString *keychainAccount;

@property (copy, nonatomic) NSString *touchIDReason;

@end

@implementation VENTouchLock

- (void)setKeychainService:(NSString *)service
           keychainAccount:(NSString *)account
             touchIDReason:(NSString *)reason
{
    self.keychainService = service;
    self.keychainAccount = account;
    self.touchIDReason = reason;
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

- (void)requestTouchID
{
    if ([self canUseTouchID]) {
        NSString *localizedReason = self.touchIDReason;
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
}

@end
