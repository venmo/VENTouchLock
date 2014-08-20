#import <Foundation/Foundation.h>
#import "VENTouchLockSetPasscodeViewController.h"

@interface VENTouchLock : NSObject


/**
 Set the keychain service and account names in order to specify where in the keychain the passcode persists. The touch ID reason will be displayed when touch ID is requested.
 */
- (void)setKeychainService:(NSString *)service
           keychainAccount:(NSString *)account
             touchIDReason:(NSString *)reason;

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
+ (BOOL)canUseTouchID;

/**
 Requests a TouchID if possible. If canUseTouchID returns NO, this method does nothing.
 */
- (void)requestTouchID;

@end
