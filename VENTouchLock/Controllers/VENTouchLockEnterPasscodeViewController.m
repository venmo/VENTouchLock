#import "VENTouchLockEnterPasscodeViewController.h"
#import "VENTouchLock.h"

static NSString *const VENTouchLockEnterPasscodeUserDefaultsKeyNumberOfConsecutivePasscodeAttempts = @"VENTouchLockEnterPasscodeUserDefaultsKeyNumberOfConsecutivePasscodeAttempts";

@implementation VENTouchLockEnterPasscodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Enter Passcode", nil);
    self.passcodeView.title = NSLocalizedString(@"Enter your Passcode", nil);
}

- (void)enteredPasscode:(NSString *)passcode
{
    [super enteredPasscode:passcode];
    if ([[VENTouchLock sharedInstance] isPasscodeValid:passcode]) {
        [[self class] resetPasscodeAttemptHistory];
        [self finishWithResult:YES animated:YES];
    }
    else {
        [self.passcodeView shakeAndVibrateCompletion:^{
            self.passcodeView.title = NSLocalizedString(@"Incorrect Passcode. Try again.", nil);
            [self clearPasscode];
            if ([self parentSplashViewController]) {
                [self recordIncorrectPasscodeAttempt];
            }
        }];

    }
}

- (void)recordIncorrectPasscodeAttempt
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSUInteger numberOfAttemptsSoFar = [standardDefaults integerForKey:VENTouchLockEnterPasscodeUserDefaultsKeyNumberOfConsecutivePasscodeAttempts];
    numberOfAttemptsSoFar ++;
    [standardDefaults setInteger:numberOfAttemptsSoFar forKey:VENTouchLockEnterPasscodeUserDefaultsKeyNumberOfConsecutivePasscodeAttempts];
    [standardDefaults synchronize];
    if (numberOfAttemptsSoFar >= [[VENTouchLock sharedInstance] passcodeAttemptLimit]) {
        [self callExceededLimitActionBlock];
    }
}

- (void)callExceededLimitActionBlock
{
    [[self parentSplashViewController] dismissWithUnlockSuccess:NO animated:NO];
}

+ (void)resetPasscodeAttemptHistory
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults removeObjectForKey:VENTouchLockEnterPasscodeUserDefaultsKeyNumberOfConsecutivePasscodeAttempts];
    [standardDefaults synchronize];
}

- (VENTouchLockSplashViewController *)parentSplashViewController
{
    VENTouchLockSplashViewController *splashViewController = nil;
    UIViewController *navcontroller = self.presentingViewController;
    UIViewController *rootViewController = ([navcontroller isKindOfClass:[UINavigationController class]]) ? [((UINavigationController *)navcontroller).viewControllers firstObject] : nil;
    if ([rootViewController isKindOfClass:[VENTouchLockSplashViewController class]]) {
        splashViewController = (VENTouchLockSplashViewController *)rootViewController;
    }
    return splashViewController;
}

@end
