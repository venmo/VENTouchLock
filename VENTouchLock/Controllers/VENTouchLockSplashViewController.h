#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VENTouchLockSplashViewControllerUnlockType) {
    VENTouchLockSplashViewControllerUnlockTypeNone,
    VENTouchLockSplashViewControllerUnlockTypeTouchID,
    VENTouchLockSplashViewControllerUnlockTypePasscode
};

@interface VENTouchLockSplashViewController : UIViewController

/**
 Called when the VENTouchLockSplashViewController instance is dismissed.
 @param success YES if the splash view controller was unlocked successfully. NO if the user reached passcodeAttemptLimit.
 @param unlockType The type of unlock method used when unlock is successful.
 @note A secure use-case of this block is to log out of your app when success is NO.
 */
@property (nonatomic, copy) void (^didFinishWithSuccess)(BOOL success, VENTouchLockSplashViewControllerUnlockType unlockType);

/**
 Displays a Touch ID prompt if the device can support it.
 */
- (void)showUnlockAnimated:(BOOL)animated;

/**
 Displays a Touch ID prompt if the device can support it.
 */
- (void)showTouchID;

/**
 Presents a VENTouchLockEnterPasscodeViewController instance.
 */
- (void)showPasscodeAnimated:(BOOL)animated;

/**
 Dismisses the VENTouchLockSplashViewController instance. This method should not be called outside of the VENTouchLock framework.
 @param success YES if the splash view controller was unlocked successfully. NO if the user reached passcodeAttemptLimit.
 @param unlockType The type of unlock method used when unlock is successful.
 @param animated YES to animated the view controller's dismissal. NO otherwise.
 */
- (void)dismissWithUnlockSuccess:(BOOL)success
                      unlockType:(VENTouchLockSplashViewControllerUnlockType)unlockType
                        animated:(BOOL)animated;

@end
