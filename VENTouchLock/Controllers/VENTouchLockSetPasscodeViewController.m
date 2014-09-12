#import "VENTouchLockSetPasscodeViewController.h"
#import "VENTouchLock.h"

static CGFloat const VENTouchLockSetPasscodeViewControllerAnimationDuration = 0.2;

@interface VENTouchLockSetPasscodeViewController ()
@property (strong, nonatomic) NSString *firstPasscode;
@end

@implementation VENTouchLockSetPasscodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Set Passcode", nil);
    self.passcodeView.title = NSLocalizedString(@"Enter a new Passcode",nil);
}

- (void)enteredPasscode:(NSString *)passcode;
{
    [super enteredPasscode:passcode];
    if (self.firstPasscode) {
        if ([passcode isEqualToString:self.firstPasscode]) {
            [[VENTouchLock sharedInstance] setPasscode:passcode];
            [self finishWithResult:YES animated:YES];
        }
        else {
            [self.passcodeView shakeAndVibrateCompletion:^{
                self.firstPasscode = nil;
                [self showFirstPasscodeView];
            }];
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
    NSString *confirmPasscodeTitle = NSLocalizedString(@"Please re-enter your passcode", nil);
    VENTouchLockPasscodeView *confirmPasscodeView = [[VENTouchLockPasscodeView alloc]
                                                     initWithTitle:confirmPasscodeTitle
                                                     frame:confirmInitialFrame];
    [self.view addSubview:confirmPasscodeView];
    [UIView animateWithDuration: VENTouchLockSetPasscodeViewControllerAnimationDuration
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
    NSString *firstPasscodeTitle = NSLocalizedString(@"Passwords did not match. Try again.", nil);
    VENTouchLockPasscodeView *firstPasscodeView = [[VENTouchLockPasscodeView alloc] initWithTitle:firstPasscodeTitle
                                                                                            frame:firstInitialFrame];
    [self.view addSubview:firstPasscodeView];
    [UIView animateWithDuration: VENTouchLockSetPasscodeViewControllerAnimationDuration
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
