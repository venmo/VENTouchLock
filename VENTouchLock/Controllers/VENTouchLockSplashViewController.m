#import "VENTouchLockSplashViewController.h"
#import "VENTouchLockEnterPasscodeViewController.h"
#import "VENTouchLock.h"

@implementation VENTouchLockSplashViewController

#pragma mark - Creation and Lifecycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self showUnlock];
    }
}


#pragma mark - Present unlock methods

- (void)showUnlockAnimated:(BOOL)animated
{
    if ([VENTouchLock shouldUseTouchID]) {
        [self showTouchID];
    }
    else {
        [self showPasscodeAnimated:animated];
    }
}

- (void)showTouchID
{
    __weak __typeof__(self) weakSelf = self;
    [self.touchLock requestTouchIDWithCompletion:^(VENTouchLockTouchIDResponse response) {
        switch (response) {
            case VENTouchLockTouchIDResponseSuccess:
                [weakSelf unlockWithType:VENTouchLockSplashViewControllerUnlockTypeTouchID];
                break;
            case VENTouchLockTouchIDResponseUsePasscode:
                [weakSelf showPasscodeAnimated:YES];
                break;
            default:
                break;
        }
    }];
}

- (void)showPasscodeAnimated:(BOOL)animated
{
    UIViewController *enterPassCodeViewController;
    if (self.touchLock.appearance.passcodeViewControllerShouldEmbedInNavigationController) {
        enterPassCodeViewController = [[self enterPasscodeVC] embeddedInNavigationController];
    } else {
        enterPassCodeViewController = [self enterPasscodeVC];
    }

    [self presentViewController:enterPassCodeViewController animated:animated completion:nil];
}

- (VENTouchLockEnterPasscodeViewController *)enterPasscodeVC
{
    VENTouchLockEnterPasscodeViewController *enterPasscodeVC = [[VENTouchLockEnterPasscodeViewController alloc] init];
    __weak __typeof__(self) weakSelf = self;
    enterPasscodeVC.willFinishWithResult = ^(BOOL success) {
        if (success) {
            [weakSelf unlockWithType:VENTouchLockSplashViewControllerUnlockTypePasscode];
        }
        else {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    };
    return enterPasscodeVC;
}

- (void)unlockWithType:(VENTouchLockSplashViewControllerUnlockType)unlockType
{
    [self dismissWithUnlockSuccess:YES
                        unlockType:unlockType
                          animated:YES];
}

- (void)dismissWithUnlockSuccess:(BOOL)success
                      unlockType:(VENTouchLockSplashViewControllerUnlockType)unlockType
                        animated:(BOOL)animated
{
    [self.touchLock unlockAnimated:animated];
    if (self.didFinishWithSuccess) {
        self.didFinishWithSuccess(success, unlockType);
    }
}

- (void)initialize
{
    _touchLock = [VENTouchLock sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUnlock) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)showUnlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showUnlockAnimated:NO];
    });
}

@end