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
                [weakSelf unlock];
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
    [self.navigationController presentViewController:[[self enterPasscodeVC] embedInNavigationController] animated:animated completion:nil];
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
        if ([VENTouchLock shouldUseTouchID]) {
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
