#import "VENTouchLockEnterPasscodeViewController.h"
#import "VENTouchLock.h"

@implementation VENTouchLockEnterPasscodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Enter Passcode", nil);
    self.passcodeView.title = NSLocalizedString(@"Enter your Passcode", nil);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)enteredPasscode:(NSString *)passcode
{
    [super enteredPasscode:passcode];
    if ([[VENTouchLock sharedInstance] isPasscodeValid:passcode]) {
        [self finishWithResult:YES];
    }
    else {
        [self.passcodeView shakeAndVibrateCompletion:^{
            self.passcodeView.title = NSLocalizedString(@"Incorrect Passcode. Try again.", nil);
            [self clearPasscode];
        }];
    }
}

@end
