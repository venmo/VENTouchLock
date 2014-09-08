#import "VENTouchLockSplashViewController.h"
#import "VENTouchLockEnterPasscodeViewController.h"
#import "VENTouchLock.h"

@interface VENTouchLockSplashViewController ()

@end

@implementation VENTouchLockSplashViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)showUnlock
{
    if ([VENTouchLock canUseTouchID]) {
        [self showTouchID];
    }
    else {
        [self showPasscode];
    }
}

- (void)showTouchID
{
    __weak VENTouchLockSplashViewController *weakSelf = self;
    [[VENTouchLock sharedInstance] requestTouchIDWithCompletion:^(VENTouchLockTouchIDResponse response) {
        switch (response) {
            case VENTouchLockTouchIDResponseSuccess:
                [weakSelf unlock];
                break;
            case VENTouchLockTouchIDResponseUsePasscode:
                [weakSelf showPasscode];
                break;
            default:
                break;
        }
    }];
}

- (void)showPasscode
{
    [self.navigationController presentViewController:[[self enterPasscodeVC] embedInNavigationController] animated:YES completion:nil];
}

- (VENTouchLockEnterPasscodeViewController *)enterPasscodeVC
{
    VENTouchLockEnterPasscodeViewController *enterPasscodeVC = [[VENTouchLockEnterPasscodeViewController alloc] init];
    __weak VENTouchLockSplashViewController *weakSelf = self;
    enterPasscodeVC.willFinishWithResult = ^(BOOL success) {
        if (success) {
            [weakSelf unlock];
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
        if ([VENTouchLock canUseTouchID]) {
            [self showTouchID];
        }
    }
    else {
        [self presentViewController:[[self enterPasscodeVC] embedInNavigationController] animated:NO completion:nil];
    }
}

- (void)unlock
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if (self.didUnlockSuccesfullyBlock) {
            self.didUnlockSuccesfullyBlock();
        }
    }];

}


@end
