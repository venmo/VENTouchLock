#import "VENTouchLockEnterPasscodeViewController.h"
#import "VENTouchLockPasscodeView.h"
#import "VENTouchLock.h"

@implementation VENTouchLockEnterPasscodeViewController

#pragma mark - Instance Methods

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = [self.touchLock options].enterPasscodeViewControllerTitle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.passcodeView.title = [self.touchLock options].enterPasscodeInitialLabelText;
}

- (void)enteredPasscode:(NSString *)passcode
{
    [super enteredPasscode:passcode];
    if ([self.touchLock isPasscodeValid:passcode]) {
        [self.touchLock resetIncorrectPasscodeAttemptCount];
        [self finishWithResult:YES animated:YES];
    }
    else {
        [self.passcodeView shakeAndVibrateCompletion:^{
            self.passcodeView.title = [self.touchLock options].enterPasscodeIncorrectLabelText;
            [self clearPasscode];
            if ([self parentSplashViewController]) {
                [self recordIncorrectPasscodeAttempt];
            }
        }];

    }
}

- (void)recordIncorrectPasscodeAttempt
{
    [self.touchLock incrementIncorrectPasscodeAttemptCount];

    if ([self.touchLock numberOfIncorrectPasscodeAttempts] >= [self.touchLock passcodeAttemptLimit]) {
        [self callExceededLimitActionBlock];
    }
}

- (void)callExceededLimitActionBlock
{
    [[self parentSplashViewController] dismissWithUnlockSuccess:NO
                                                     unlockType:VENTouchLockSplashViewControllerUnlockTypeNone
                                                       animated:NO];
}

- (VENTouchLockSplashViewController *)parentSplashViewController
{
    VENTouchLockSplashViewController *splashViewController = nil;
    UIViewController *presentingViewController = self.presentingViewController;
    if (self.touchLock.options.splashShouldEmbedInNavigationController) {
        UIViewController *rootViewController = ([presentingViewController isKindOfClass:[UINavigationController class]]) ? [((UINavigationController *)presentingViewController).viewControllers firstObject] : nil;
        if ([rootViewController isKindOfClass:[VENTouchLockSplashViewController class]]) {
            splashViewController = (VENTouchLockSplashViewController *)rootViewController;
        }
    }
    else if ([presentingViewController isKindOfClass:[VENTouchLockSplashViewController class]]) {
        splashViewController = (VENTouchLockSplashViewController *)presentingViewController;
    }
    return splashViewController;
}

@end
