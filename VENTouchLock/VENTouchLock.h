#import <Foundation/Foundation.h>
#import "VENTouchLockCreatePasscodeViewController.h"
#import "VENTouchLockEnterPasscodeViewController.h"
#import "VENTouchLockSplashViewController.h"
#import "VENTouchLockOptions.h"

typedef NS_ENUM(NSUInteger, VENTouchLockCompletionType) {
    VENTouchLockCompletionTypeUndefined,
    VENTouchLockCompletionTypeTouchIDUnlock,
    VENTouchLockCompletionTypePasscodeUnlock,
    VENTouchLockCompletionTypePasscodeLimitReached,
    VENTouchLockCompletionTypeCancel
};

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
@property (assign, nonatomic, readonly) BOOL locked;

/**
 This block is called each time the TouchLock is unlocked or dismissed.
 */
@property (nonatomic, copy) void (^lockCompletion)(VENTouchLockCompletionType);

/**
 The class of a UIView subclass.
 When the app is in the background and the TouchLock is locked, an instance of this view, that is
 the same size of the device's screen will be added to the top of the view hieararchy and
 will be displayed when a user is on the a multi-tasking app switch screen.
 By default, this is NULL and there is no app switch view covering the app when the TouchLock is locked.
 */
@property (assign, nonatomic) Class appSwitchViewClass;

/**
 The class of the VENTouchLockSplashViewController subclass.
 This view controller will be underneath the Touch ID prompt or passcode view controller.
 By default, this is NULL and there is no splash view controller when the TouchLock is locked.
 */
@property (assign, nonatomic) Class splashViewControllerClass;

/**
 Preferences may optionally be set by editing the returned instance's properties.
 */
@property (strong, nonatomic, readonly) VENTouchLockOptions *options;


/**
 @return A singleton TouchLock instance.
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
   keychainPasscodeAccount:(NSString *)passcodeAccount
    keychainTouchIDAccount:(NSString *)touchIDAccount
             touchIDReason:(NSString *)reason
      passcodeAttemptLimit:(NSUInteger)attemptLimit;

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
- (BOOL)shouldUseTouchID;

/**
 Sets and persists the user's preference for using TouchID.
 */
- (void)setShouldUseTouchID:(BOOL)shouldUseTouchID;

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
 If a passcode is set, calling this method will lock the app. Otherwise, calling it will not do anything.
 @note The app is automatically locked when on launch and on entering background. Use this method only if necessary in other circumstances.
 */
- (void)lock;

/**
 Increments the incorrect passcode attempt count;
 */
- (NSUInteger)numberOfIncorrectPasscodeAttempts;

/**
 Increments the incorrect password attempt count;
 */
- (void)incrementIncorrectPasscodeAttemptCount;

/**
 Resets the incorrect password attempt count;
 */
- (void)resetIncorrectPasscodeAttemptCount;

@end