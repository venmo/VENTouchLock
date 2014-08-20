#import "VENTouchLockSetPasscodeViewController.h"

@interface VENTouchLockSetPasscodeViewController ()

@property (strong, nonatomic) NSString *firstPasscode;

@end

@implementation VENTouchLockSetPasscodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Set Passcode", nil);
}

- (void)enteredPasscode:(NSString *)passcode;
{
    if (self.firstPasscode) {
        if ([passcode isEqualToString:self.firstPasscode]) {
            // Go to next step
        }
        else {
            // Go back to Set Pass code
            [self showFirstPasscodeView];
        }
    }
    else {
        self.firstPasscode = passcode;
        [self showConfirmPasscodeView];
    }
}

- (void)showConfirmPasscodeView
{
    VENTouchLockPasscodeView *firstPasscodeView = self.passcodeView;
    CGFloat passcodeViewWidth = CGRectGetWidth(firstPasscodeView.frame);
    CGRect confirmInitialFrame = CGRectMake(passcodeViewWidth,
                                     CGRectGetMinY(firstPasscodeView.frame),
                                     passcodeViewWidth,
                                     CGRectGetHeight(firstPasscodeView.frame));
    CGRect confirmEndFrame = firstPasscodeView.frame;
    CGRect firstEndFrame = CGRectMake(-passcodeViewWidth,
                                        CGRectGetMinY(firstPasscodeView.frame),
                                        passcodeViewWidth,
                                        CGRectGetHeight(firstPasscodeView.frame));
    VENTouchLockPasscodeView *confirmPasscodeView = [[VENTouchLockPasscodeView alloc] initWithFrame:confirmInitialFrame];
    [self.view addSubview:confirmPasscodeView];
    [UIView animateWithDuration: 0.2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         firstPasscodeView.frame = firstEndFrame;
                         confirmPasscodeView.frame = confirmEndFrame;
                     }
                     completion:^(BOOL finished) {
                         [firstPasscodeView removeFromSuperview];
                         self.passcodeView = confirmPasscodeView;
                     }];

}

- (void)showFirstPasscodeView
{
    VENTouchLockPasscodeView *confirmPasscodeView = self.passcodeView;
    CGFloat passcodeViewWidth = CGRectGetWidth(confirmPasscodeView.frame);
    CGRect firstInitialFrame = CGRectMake(-passcodeViewWidth,
                                     CGRectGetMinY(confirmPasscodeView.frame),
                                     passcodeViewWidth,
                                     CGRectGetHeight(confirmPasscodeView.frame));
    CGRect firstEndFrame = confirmPasscodeView.frame;
    CGRect confirmEndFrame = CGRectMake(passcodeViewWidth,
                                        CGRectGetMinY(confirmPasscodeView.frame),
                                        passcodeViewWidth,
                                        CGRectGetHeight(confirmPasscodeView.frame));
    VENTouchLockPasscodeView *firstPasscodeView = [[VENTouchLockPasscodeView alloc] initWithFrame:firstInitialFrame];
    [self.view addSubview:firstPasscodeView];
    [UIView animateWithDuration: 0.2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         confirmPasscodeView.frame = confirmEndFrame;
                         firstPasscodeView.frame = firstEndFrame;
                     }
                     completion:^(BOOL finished) {
                         [confirmPasscodeView removeFromSuperview];
                         self.passcodeView = firstPasscodeView;
                     }];
}

@end
