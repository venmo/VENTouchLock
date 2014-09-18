#import "VENTouchLockSplashViewController.h"
#import "VENTouchLockEnterPasscodeViewController.h"
#import "VENTouchLock.h"

@interface VENTouchLockSplashViewController ()
@property (nonatomic, assign) BOOL isSnapshotViewController;
@end

@implementation VENTouchLockSplashViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (!self.isSnapshotViewController) {
        [VENTouchLock sharedInstance].backgroundLockVisible = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.isSnapshotViewController) {
        [VENTouchLock sharedInstance].backgroundLockVisible = YES;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

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
    __weak VENTouchLockSplashViewController *weakSelf = self;
    [[VENTouchLock sharedInstance] requestTouchIDWithCompletion:^(VENTouchLockTouchIDResponse response) {
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
    [self.navigationController presentViewController:[[self enterPasscodeVC] embeddedInNavigationController]
                                            animated:animated
                                          completion:nil];
}

- (VENTouchLockEnterPasscodeViewController *)enterPasscodeVC
{
    VENTouchLockEnterPasscodeViewController *enterPasscodeVC = [[VENTouchLockEnterPasscodeViewController alloc] init];
    __weak VENTouchLockSplashViewController *weakSelf = self;
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

- (void)appWillEnterForeground
{
    if (!self.presentedViewController) {
        if ([VENTouchLock shouldUseTouchID]) {
            [self showTouchID];
        }
        else {
            [self showPasscodeAnimated:NO];
        }
    }
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
    [self.presentingViewController dismissViewControllerAnimated:animated completion:^{
        if (self.didFinishWithSuccess) {
            self.didFinishWithSuccess(success, unlockType);
        }
    }];
}

@end