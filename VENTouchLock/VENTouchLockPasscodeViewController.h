#import <UIKit/UIKit.h>
#import "VENTouchLockPasscodeView.h"

@interface VENTouchLockPasscodeViewController : UIViewController

/**
 Encapsulates the view controller in a navigation controller.
 */
- (UINavigationController *)embedInNavigationController;

/**
 Called when a user enters a complete passcode. By default, this method has no action, but should be overriden in subclasses.
 */
- (void)enteredPasscode:(NSString *)passcode;

@property (strong, nonatomic) VENTouchLockPasscodeView *passcodeView;

@end
