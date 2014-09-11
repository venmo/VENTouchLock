#import <UIKit/UIKit.h>
#import "VENTouchLockPasscodeView.h"

@interface VENTouchLockPasscodeViewController : UIViewController

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

- (void)finishWithResult:(BOOL)success animated:(BOOL)animated;

/**
 This block is called directly before the passcode view controller has completed its intended operation. If the operation was completed successfully, the returned BOOL will return YES, and NO otherwise.
 If this block is defined, it is responsible for dismissing the passcode view controller.
 If this block is nil, the payment view controller will dismiss itself.
 */
@property (nonatomic, copy) void (^willFinishWithResult)(BOOL success);

@property (strong, nonatomic) VENTouchLockPasscodeView *passcodeView;

@end
