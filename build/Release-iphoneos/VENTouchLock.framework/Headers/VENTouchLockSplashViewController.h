#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VENTouchLockSplashViewControllerUnlockType) {
    VENTouchLockSplashViewControllerUnlockTypeNone,
    VENTouchLockSplashViewControllerUnlockTypeTouchID,
    VENTouchLockSplashViewControllerUnlockTypePasscode
};

@class VENTouchLock;

@interface VENTouchLockSplashViewController : UIViewController

/**
 Called when the VENTouchLockSplashViewController instance is dismissed.
 @param success YES if the splash view controller was unlocked successfully. NO if the user reached passcodeAttemptLimit.
 @param unlockType The type of unlock method used when unlock is successful.
 @note A secure use-case of this block is to log out of your app when success is NO.
 */
@property (nonatomic, copy) void (^didFinishWithSuccess)(BOOL success, VENTouchLockSplashViewControllerUnlockType unlockType);

/**
 The VENTouchLock framework this class interacts with. This property should not be set outside of VENTouchLock framework's automated tests.  By default, it is set to the [VENTouchLock sharedInstance] singleton on initialization.
 */
@property (nonatomic, strong) VENTouchLock *touchLock;

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
/**
 Signals the splash view controller to behave like a snapshot view for app-switch. This method should not be called outside of the VENTouchLock framework.
 @param isSnapshotViewController YES if the splash view controller is for the app-switch snapshot. NO othwerise.
 */
- (void)setIsSnapshotViewController:(BOOL)isSnapshotViewController;

@end
