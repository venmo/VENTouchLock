#import <Foundation/Foundation.h>
#import "VENTouchLockCreatePasscodeViewController.h"
#import "VENTouchLockEnterPasscodeViewController.h"
#import "VENTouchLockSplashViewController.h"
#import "VENTouchLockAppearance.h"

typedef NS_ENUM(NSUInteger, VENTouchLockTouchIDResponse) {
    VENTouchLockTouchIDResponseUndefined,
    VENTouchLockTouchIDResponseSuccess,
    VENTouchLockTouchIDResponseUsePasscode,
    VENTouchLockTouchIDResponseCanceled,
    VENTouchLockTouchIDResponsePromptAlreadyPresent,
};

@interface VENTouchLock : NSObject

/**
 YES if the app is locked after having entered the background, and NO otherwise.
 */
@property (assign, nonatomic) BOOL backgroundLockVisible;

/**
 @return A singleton VENTouchLock instance.
 */
+ (instancetype)sharedInstance;

/**
 Set the defaults. This method should be called at launch.
 @param service The keychain service for which to set and return a passcode
 @param account The keychain account for which to set and return a passcode
 @param splashViewControllerClass The class of the custom splash view controller. This class should be a subclass of VENTouchLockSplashViewController and any of its custom initialization must be in its init function
 @param reason The default message displayed on the TouchID prompt
 */
- (void)setKeychainService:(NSString *)service
           keychainAccount:(NSString *)account
             touchIDReason:(NSString *)reason
      passcodeAttemptLimit:(NSUInteger)attemptLimit
 splashViewControllerClass:(Class)splashViewControllerClass;

/**
 Set the defaults. This method should be called at launch.
 @param service The keychain service for which to set and return a passcode
 @param account The keychain account for which to set and return a passcode
 @param splashViewControllerClass The class of the custom splash view controller. This class should be a subclass of VENTouchLockSplashViewController and any of its custom initialization must be in its init function
 @param reason The default message displayed on the TouchID prompt
 @param secondsToLock The number of seconds from lastRefreshDate that the app will wait for lock
 */
- (void)setKeychainService:(NSString *)service
           keychainAccount:(NSString *)account
             touchIDReason:(NSString *)reason
             secondsToLock:(NSUInteger)secondsToLock
      passcodeAttemptLimit:(NSUInteger)attemptLimit
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
- (void)requestTouchIDWithCompletion:(void(^)(VENTouchLockTouchIDResponse response))completionBlock
                              reason:(NSString *)reason;

/**
 The maximum number of incorrect passcode attempts before the exceededLimitAction is called.
 */
- (NSUInteger)passcodeAttemptLimit;

/**
 Updates de refreshDate value with current date
 */
- (void) updateRefreshDate;

/**
 Sets the number of seconds that the app has to wait since lastRefreshDate to lock
 */
- (void) setSecondsToLock:(NSUInteger) secondsToLock;

/**
 If a passcode is set, calling this method will lock the app. Otherwise, calling it will not do anything.
 @note The app is automatically locked if needed (see method below) when on launch and on entering background. Use this method only if necessary in other circumstances.
 */
- (void)lock;

/**
  Locks the app if has passed 'secondsToLock' from 'lastRefreshDate'. Otherwile, calling it will not do anything.
 */
- (void) lockIfNeeded;

/**
 @return The proxy for the receiver's user interface. Custom appearance preferences may optionally be set by editing the returned instance's properties.
 */
- (VENTouchLockAppearance *)appearance;



@end
