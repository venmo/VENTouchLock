#import "VENTouchLockEnterPasscodeViewController.h"
#import "VENTouchLock.h"

@interface VENTouchLockEnterPasscodeViewController ()

@end

@implementation VENTouchLockEnterPasscodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Enter Passcode", nil);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VENTouchLock sharedInstance] requestTouchID];
}

- (void)enteredPasscode:(NSString *)passcode
{
    if ([[VENTouchLock sharedInstance] isPasscodeValid:passcode]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.passcodeView shakeAndVibrateCompletion:^{
            
        }];
    }
}

@end
