#import <UIKit/UIKit.h>

@class VENTouchLock, VENTouchLockPasscodeView;

@interface VENTouchLockPasscodeViewController : UIViewController

/**
 The initial passcode view attached to this view controller.
 */
@property (strong, nonatomic) VENTouchLockPasscodeView *passcodeView;

/**
 If this block is defined, it is called within the completion block of the passcode view controller when it is dismissed. If the operation was completed successfully, the returned BOOL will return YES, and NO otherwise.
 */
@property (nonatomic, copy) void (^willFinishWithResult)(BOOL success);
// ^ SYMPLE: usage customized and comment updated to reflect Symple usage

/**
 The VENTouchLock framework this class interacts with. This property should not be set outside of VENTouchLock framework's automated tests.  By default, it is set to the [VENTouchLock sharedInstance] singleton on initialization.
 */
@property (nonatomic, strong) VENTouchLock *touchLock;

@property (nonatomic, getter=isSnapshotViewController) BOOL snapshotViewController;
/**
 Encapsulates the view controller in a navigation controller.
 */
- (UINavigationController *)embeddedInNavigationController;

/**
 Clears passcode in view if one exist.
 */
- (void)clearPasscode;

/**
 Called when a user enters a complete passcode. This should be overriden in subclasses. When overriding this method, calling the super classes method should be the first call.
 */
- (void)enteredPasscode:(NSString *)passcode;

/**
 Called by superclasses in order to dismiss this view controller.
 @param success YES if the intended operation was successful. NO otherwise.
 @param animated YES to animated the view controller's dismissal. NO otherwise.
 */
- (void)finishWithResult:(BOOL)success animated:(BOOL)animated;

@end