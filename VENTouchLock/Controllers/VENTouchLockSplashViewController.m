#import "VENTouchLockSplashViewController.h"
#import "VENTouchLockEnterPasscodeViewController.h"
#import "VENTouchLock.h"

@interface VENTouchLockSplashViewController ()

@property (nonatomic, assign) BOOL isSnapshotViewController;
@property (nonatomic, strong) VENTouchLock *touchLock;

@end

@implementation VENTouchLockSplashViewController

#pragma mark - Creation and Lifecycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (!self.isSnapshotViewController) {
        self.touchLock.backgroundLockVisible = NO;
    }
}

- (instancetype)initWithTouchLock:(VENTouchLock *)touchLock
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _touchLock = touchLock ?: [VENTouchLock sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (!self.isSnapshotViewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showUnlockAnimated:NO];
        });
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}


#pragma mark - Present unlock methods

- (void)showUnlockAnimated:(BOOL)animated
{
    if ([[VENTouchLock sharedInstance] shouldUseTouchID]) {
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

- (void)appWillEnterForeground
{
    if (!self.presentedViewController) {
        [self showUnlockAnimated:NO];
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