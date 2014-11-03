#import "SampleLockSplashViewController.h"
#import "VENTouchLock.h"

@interface SampleLockSplashViewController ()

@property (weak, nonatomic) IBOutlet UIButton *touchIDButton;

@end

@implementation SampleLockSplashViewController

- (instancetype)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.didFinishWithSuccess = ^(BOOL success, VENTouchLockSplashViewControllerUnlockType unlockType) {
            if (success) {
                NSString *logString = @"Sample App Unlocked";
                switch (unlockType) {
                    case VENTouchLockSplashViewControllerUnlockTypeTouchID: {
                        logString = [logString stringByAppendingString:@" with Touch ID."];
                        break;
                    }
                    case VENTouchLockSplashViewControllerUnlockTypePasscode: {
                        logString = [logString stringByAppendingString:@" with Passcode."];
                        break;
                    }
                    default:
                        break;
                }
                NSLog(@"%@", logString);
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"Limit Exceeded"
                                            message:@"You have exceeded the maximum number of passcode attempts"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.touchIDButton.hidden = ![VENTouchLock shouldUseTouchID];
}

- (IBAction)userTappedShowTouchID:(id)sender
{
    [self showTouchID];
}

- (IBAction)userTappedEnterPasscode:(id)sender
{
    [self showPasscodeAnimated:YES];
}

@end
