#import <Foundation/Foundation.h>

@interface VENTouchLock : NSObject

- (void)setKeychainService:(NSString *)service
           keychainAccount:(NSString *)account
      touchIDDefaultReason:(NSString *)reason;

/**
 Returns YES if a passcode exists, and NO otherwise.
 */
- (BOOL)isPasscodeSet;

/**
 Returns a string containing the passcode for a given account and service, or `nil` if the keychain doesn't have a password for the given parameters.
 */
- (NSString *)currentPasscode;

/**
 Sets the given string to be the current passcode.
 */
- (void)setPasscode:(NSString *)passcode;

/**
 Deletes the current passcode if one exists.
 */
- (void)deletePasscode;

/**
 Returns YES if the device has TouchID enabled and is running a minimum of iOS 8.0, and NO otherwise.
 */
- (BOOL)canUseTouchID;

- (void)showTouchID;

@end
