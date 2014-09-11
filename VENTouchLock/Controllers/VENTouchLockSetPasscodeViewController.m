#import "VENTouchLockSetPasscodeViewController.h"
#import "VENTouchLockActivateTouchIDViewController.h"
#import "VENTouchLock.h"

@interface VENTouchLockSetPasscodeViewController ()

@property (strong, nonatomic) NSString *firstPasscode;

@end

@implementation VENTouchLockSetPasscodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Set Passcode", nil);
    self.passcodeView.title = (@"Enter a new Passcode");
}

- (void)enteredPasscode:(NSString *)passcode;
{
    [super enteredPasscode:passcode];
    if (self.firstPasscode) {
        if ([passcode isEqualToString:self.firstPasscode]) {
            [[VENTouchLock sharedInstance] setPasscode:passcode];
            if ([VENTouchLock canUseTouchID]) {
                VENTouchLockActivateTouchIDViewController *touchIDViewController = [[VENTouchLockActivateTouchIDViewController alloc] initWithNibName:NSStringFromClass([VENTouchLockActivateTouchIDViewController class]) bundle:nil];
                touchIDViewController.sourceViewController = self;
                [self.navigationController pushViewController:touchIDViewController animated:YES];
            }
            else {
                [self finishWithResult:YES animated:YES];
            }
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
    VENTouchLockPasscodeView *confirmPasscodeView = [[VENTouchLockPasscodeView alloc]
                                                     initWithTitle:@"Please re-enter your passcode"
                                                                                              frame:confirmInitialFrame];
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
    VENTouchLockPasscodeView *firstPasscodeView = [[VENTouchLockPasscodeView alloc] initWithTitle:@"Passwords did not match. Try again." frame:firstInitialFrame];
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
