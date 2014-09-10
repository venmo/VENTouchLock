#import <Foundation/Foundation.h>
#import "VENTouchLockSetPasscodeViewController.h"
#import "VENTouchLockEnterPasscodeViewController.h"
#import "VENTouchLockSplashViewController.h"

typedef NS_ENUM(NSUInteger, VENTouchLockTouchIDResponse) {
    VENTouchLockTouchIDResponseUndefined,
    VENTouchLockTouchIDResponseSuccess,
    VENTouchLockTouchIDResponseUsePasscode,
    VENTouchLockTouchIDResponseCanceled,
};

@interface VENTouchLock : NSObject

+ (instancetype)sharedInstance;

/**
 Set the defaults. This method should be called at launch.
 @param service The keychain service for which to set and return a passcode
 @param account The keychain account for which to set and return a passcode
 @param reason The default message displayed on the TouchID prompt
 @param splashViewControllerClass The class of the custom splash view controller. This class must be a subclass of VENTouchLockSplashViewController with any custom initialization in its init function
 */
- (void)setKeychainService:(NSString *)service
           keychainAccount:(NSString *)account
             touchIDReason:(NSString *)reason
 splashViewControllerClass:(Class)splashViewControllerClass;

/**
 Returns YES if a passcode exists, and NO otherwise.
 */
- (BOOL)isPasscodeSet;

/**
 Returns a string containing the passcode for a given account and service, or `nil` if the keychain doesn't have a password for the given parameters.
 */
- (NSString *)currentPasscode;

/**
 Returns NO if a passcode is not set, or if the current passcode is not equal to the given parameter.
 */
- (BOOL)isPasscodeValid:(NSString *)passcode;

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
 Returns YES if the user activated touchID in app passcode settings, and NO otherwise.
 */
+ (BOOL)shouldUseTouchID;

/**
 Sets and persists the user's preference for using TouchID.
 */
+ (void)setShouldUseTouchID:(BOOL)shouldUseTouchID;

/**
 Requests a TouchID if possible. If canUseTouchID returns NO, this method does nothing. The displayed string on the touch id prompt will be the default touchIDReason.
 */
- (void)requestTouchIDWithCompletion:(void(^)(VENTouchLockTouchIDResponse response))completionBlock;

/**
 Requests a TouchID if possible. If canUseTouchID returns NO, this method does nothing.
 */
- (void)requestTouchIDWithCompletion:(void(^)(VENTouchLockTouchIDResponse response))completionBlock reason:(NSString *)reason;

/**
 Requests YES if the app was locked automatically after having entered the background, and NO otherwise.
 */
- (BOOL)backgroundLockIsVisible;

@end
