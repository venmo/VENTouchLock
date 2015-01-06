#import "VENTouchLockEnterPasscodeViewController.h"
#import "VENTouchLockPasscodeView.h"
#import "VENTouchLock.h"

NSString *const VENTouchLockEnterPasscodeUserDefaultsKeyNumberOfConsecutivePasscodeAttempts = @"VENTouchLockEnterPasscodeUserDefaultsKeyNumberOfConsecutivePasscodeAttempts";

@implementation VENTouchLockEnterPasscodeViewController

#pragma mark - Class Methods

+ (void)resetPasscodeAttemptHistory
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults removeObjectForKey:VENTouchLockEnterPasscodeUserDefaultsKeyNumberOfConsecutivePasscodeAttempts];
    [standardDefaults synchronize];
}


#pragma mark - Instance Methods

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = [self.touchLock appearance].enterPasscodeViewControllerTitle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.passcodeView.title = [self.touchLock appearance].enterPasscodeInitialLabelText;
    
    if ([VENTouchLock shouldUseTouchID]) {
        self.passcodeView.hideTouchIDButton = NO;
        __weak VENTouchLockEnterPasscodeViewController *weakSelf = self;
        [self.passcodeView setTouchIDButtonPressed:^(UIButton *button) {
            [weakSelf.touchLock showTouchID];
        }];
    }
}

- (void)configureNavigationItems
{
    // no navigation items
}

- (void)enteredPasscode:(NSString *)passcode
{
    [super enteredPasscode:passcode];
    if ([self.touchLock isPasscodeValid:passcode]) {
        [[self class] resetPasscodeAttemptHistory];
        [self finishWithResult:YES animated:YES];
    }
    else {
        [self.passcodeView shakeAndVibrateCompletion:^{
            self.passcodeView.title = [self.touchLock appearance].enterPasscodeIncorrectLabelText;
            [self clearPasscode];
            [self recordIncorrectPasscodeAttempt];
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
    if (numberOfAttemptsSoFar >= [self.touchLock passcodeAttemptLimit]) {
        [self callExceededLimitActionBlock];
    }
}

- (void)callExceededLimitActionBlock
{
   // TODO: come up with solution for this
}

@end
