#import "VENTouchLock.h"

#import <SSKeychain/SSKeychain.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "UIViewController+VENTouchLock.h"
#import "VENTouchLockBlurView.h"

static NSString *const VENTouchLockDefaultUniqueIdentifier = @"VENTouchLockDefaultUniqueIdentifier";
static NSString *const VENTouchLockTouchIDOn = @"On";
static NSString *const VENTouchLockTouchIDOff = @"Off";

@interface VENTouchLock ()

@property (copy, nonatomic) NSString *keychainService;
@property (copy, nonatomic) NSString *keychainPasscodeAccount;
@property (copy, nonatomic) NSString *keychainTouchIDAccount;
@property (copy, nonatomic) NSString *touchIDReason;
@property (assign, nonatomic) NSUInteger passcodeAttemptLimit;
@property (strong, nonatomic) VENTouchLockOptions *options;
@property (assign, nonatomic) BOOL locked;

@property (strong, nonatomic) UIView *snapshotView;
@property (strong, nonatomic) UIView *obscureView;

@end

@implementation VENTouchLock

+ (instancetype)sharedInstance
{
    static VENTouchLock *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
        sharedInstance.options = [[VENTouchLockOptions alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:[self keypathOfAutolockOptions]];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(locked))];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:[self keypathOfAutolockOptions] options:NSKeyValueObservingOptionInitial context:nil];
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(locked)) options:NSKeyValueObservingOptionInitial context:nil];
    }
    return self;
}

- (void)setKeychainService:(NSString *)service
   keychainPasscodeAccount:(NSString *)passcodeAccount
    keychainTouchIDAccount:(NSString *)touchIDAccount
             touchIDReason:(NSString *)reason
      passcodeAttemptLimit:(NSUInteger)attemptLimit
{
    self.keychainService = service;
    self.keychainPasscodeAccount = passcodeAccount;
    self.keychainTouchIDAccount = touchIDAccount;
    self.touchIDReason = reason;
    self.passcodeAttemptLimit = attemptLimit;
}


#pragma mark - Keychain Methods

- (BOOL)isPasscodeSet
{
    return !![self currentPasscode];
}

- (NSString *)currentPasscode
{
    NSString *service = self.keychainService;
    NSString *account = self.keychainPasscodeAccount;
    return [SSKeychain passwordForService:service account:account];
}

- (BOOL)isPasscodeValid:(NSString *)passcode
{
    return [passcode isEqualToString:[self currentPasscode]];
}

- (void)setPasscode:(NSString *)passcode
{
    NSString *service = self.keychainService;
    NSString *account = self.keychainPasscodeAccount;
    [SSKeychain setPassword:passcode forService:service account:account];
    [self resetIncorrectPasscodeAttemptCount];
}

- (void)deletePasscode
{
    NSString *service = self.keychainService;
    NSString *passcodeAccount = self.keychainPasscodeAccount;
    NSString *touchIDAccount = self.keychainPasscodeAccount;
    NSString *passcodeAttemptCountAccount = [self keychainPasscodeAttemptAccountName];
    [SSKeychain deletePasswordForService:service account:passcodeAccount];
    [SSKeychain deletePasswordForService:service account:touchIDAccount];
    [SSKeychain deletePasswordForService:service account:passcodeAttemptCountAccount];
}


#pragma mark - TouchID Methods

+ (BOOL)canUseTouchID
{
    return [[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                                 error:nil];
}

- (BOOL)shouldUseTouchID
{
    if (![[self class] canUseTouchID]) {
        return NO;
    }

    NSString *service = self.keychainService;
    NSString *account = self.keychainTouchIDAccount;
    return [[SSKeychain passwordForService:service account:account] isEqualToString:VENTouchLockTouchIDOn];
}

- (void)setShouldUseTouchID:(BOOL)shouldUseTouchID
{
    NSString *password = shouldUseTouchID ? VENTouchLockTouchIDOn : VENTouchLockTouchIDOff;
    NSString *service = self.keychainService;
    NSString *account = self.keychainTouchIDAccount;
    [SSKeychain setPassword:password forService:service account:account];
}

- (void)requestTouchIDWithCompletion:(void (^)(VENTouchLockTouchIDResponse))completionBlock
{
    [self requestTouchIDWithCompletion:completionBlock reason:self.touchIDReason];
}

- (void)requestTouchIDWithCompletion:(void (^)(VENTouchLockTouchIDResponse))completionBlock reason:(NSString *)reason
{
    static BOOL isTouchIDPresented = NO;
    if ([[self class] canUseTouchID]) {
        if (!isTouchIDPresented) {
            isTouchIDPresented = YES;
            LAContext *context = [[LAContext alloc] init];
            context.localizedFallbackTitle = NSLocalizedString(@"Enter Passcode", nil);
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                    localizedReason:reason
                              reply:^(BOOL success, NSError *error) {
                                  isTouchIDPresented = NO;
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if (success) {
                                          if (completionBlock) {
                                              completionBlock(VENTouchLockTouchIDResponseSuccess);
                                          }
                                      }
                                      else {
                                          VENTouchLockTouchIDResponse response;
                                          switch (error.code) {
                                              case LAErrorUserFallback:
                                                  response = VENTouchLockTouchIDResponseUsePasscode;
                                                  break;
                                              case LAErrorAuthenticationFailed: // when TouchID max retry is reached, fallbacks to passcode
                                              case LAErrorUserCancel:
                                                  response = (self.options.touchIDCancelPresentsPasscodeViewController) ? VENTouchLockTouchIDResponseUsePasscode : VENTouchLockTouchIDResponseCanceled;
                                                  break;
                                              default:
                                                  response = VENTouchLockTouchIDResponseUndefined;
                                                  break;
                                          }
                                          if (completionBlock) {
                                              completionBlock(response);
                                          }
                                      }
                                  });
                              }];
        }
        else {
            if (completionBlock) {
                completionBlock(VENTouchLockTouchIDResponsePromptAlreadyPresent);
            }
        }
    }
}

- (void)lock
{
    if (![self isPasscodeSet]) {
        return;
    }

    BOOL fromBackground = [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
    BOOL shouldUseSplash = ((self.splashViewControllerClass != NULL)
                            && ([self.splashViewControllerClass isSubclassOfClass:[VENTouchLockSplashViewController class]]));

    self.locked = YES;

    if (shouldUseSplash) {
        VENTouchLockSplashViewController *splashViewController = [self splashViewController];

        BOOL shouldEmbedInNavigationController = self.options.splashShouldEmbedInNavigationController;
        UIViewController *displayViewController;
        displayViewController = [self transformViewController:splashViewController byEmbedding:shouldEmbedInNavigationController];

        if (fromBackground) {
            VENTouchLockSplashViewController *snapshotSplashViewController = [[self.splashViewControllerClass alloc] init];
            UIViewController *snapshotDisplayController = [self transformViewController:snapshotSplashViewController byEmbedding:shouldEmbedInNavigationController];
            [snapshotDisplayController loadView];
            [snapshotDisplayController viewDidLoad];
            [self showSnapshotView:snapshotSplashViewController.view];
        }

        [self presentViewControllerOnTop:displayViewController completion:^{
            [splashViewController showUnlockAnimated:NO];
        }];

    } else {
        if (self.shouldUseTouchID) {
            if (!fromBackground) {
                [self showTouchID];
            }
        }
        else {
            VENTouchLockEnterPasscodeViewController *enterPasscodeViewController = [self enterPasscodeViewController];

            BOOL shouldEmbedInNavigationController = self.options.passcodeViewControllerShouldEmbedInNavigationController;

            UIViewController *displayViewController = [self transformViewController:enterPasscodeViewController
                                                                        byEmbedding:shouldEmbedInNavigationController];

            if (fromBackground && self.appSwitchViewClass != NULL) {
                UIView *snapshotView = [[self.appSwitchViewClass alloc] init];
                [self showSnapshotView:snapshotView];
            }
            [self presentViewControllerOnTop:displayViewController completion:nil];
        }
    }
}


#pragma mark - Incorrect Passcode Attempts

- (NSUInteger)numberOfIncorrectPasscodeAttempts
{
    NSString *service = self.keychainService;
    NSString *account = [self keychainPasscodeAttemptAccountName];
    NSString *countString = [SSKeychain passwordForService:service account:account];
    return [countString integerValue];
}

- (void)incrementIncorrectPasscodeAttemptCount
{
    NSUInteger count = [self numberOfIncorrectPasscodeAttempts];
    count++;

    NSString *service = self.keychainService;
    NSString *account = [self keychainPasscodeAttemptAccountName];
    [SSKeychain setPassword:[@(count) stringValue] forService:service account:account];
}

- (void)resetIncorrectPasscodeAttemptCount
{
    NSString *service = self.keychainService;
    NSString *account = [self keychainPasscodeAttemptAccountName];
    [SSKeychain setPassword:[@(0) stringValue] forService:service account:account];
}


#pragma mark - NSNotifications

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    if (!self.locked) {
        [self lock];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if (!self.locked) {
        [self lock];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
        if (self.locked && self.splashViewControllerClass == NULL && [self shouldUseTouchID]) {
            [self showTouchID];
        }
    });
}


#pragma mark - NSObject

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:[self keypathOfAutolockOptions]]) {
        BOOL shouldAutolock = ((VENTouchLock *)object).options.shouldAutoLockOnAppLifeCycleNotifications;
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        if (shouldAutolock) {
            [notificationCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
            [notificationCenter addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
            [notificationCenter addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        } else {
            [notificationCenter removeObserver:self];
        }
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(locked))]) {
        BOOL locked = ((VENTouchLock *)object).locked;
        if (locked && self.options.shouldBlurWhenLocked && !self.obscureView) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            UIView *topMostView = [UIViewController ventouchlock_topMostController].view;
            VENTouchLockBlurView *obscureView = [[VENTouchLockBlurView alloc] initWithFrame:topMostView.bounds blurEffectStyle:self.options.blurEffectStyle];
            [topMostView addSubview:obscureView];
            self.obscureView = obscureView;
        } else {
            if (self.obscureView) {
                [UIView animateWithDuration:self.options.blurDissolveAnimationDuration animations:^{
                    self.obscureView.alpha = 0;
                } completion:^(BOOL finished) {
                    [self.obscureView removeFromSuperview];
                    self.obscureView = nil;
                }];
            }
        }
    }
}


#pragma mark - Internal Helper Methods

- (void)showTouchID
{
    [self requestTouchIDWithCompletion:^(VENTouchLockTouchIDResponse response) {
        switch (response) {
            case VENTouchLockTouchIDResponseSuccess: {
                self.locked = NO;
                if (self.lockCompletion) {
                    self.lockCompletion(VENTouchLockCompletionTypePasscodeUnlock);
                }
                break;
            }
            case VENTouchLockTouchIDResponseCanceled: {
                self.locked = NO;
                if (self.lockCompletion) {
                    self.lockCompletion(VENTouchLockCompletionTypeCancel);
                }
                break;
            }
            case VENTouchLockTouchIDResponseUsePasscode: {
                VENTouchLockEnterPasscodeViewController *enterPasscodeViewController = [self enterPasscodeViewController];
                BOOL shouldEmbedInNavigationController = self.options.passcodeViewControllerShouldEmbedInNavigationController;

                UIViewController *displayViewController = [self transformViewController:enterPasscodeViewController
                                                                            byEmbedding:shouldEmbedInNavigationController];
                [self presentViewControllerOnTop:displayViewController completion:nil];
                break;
            }

            default:
                break;
        }
    }];
}

- (void)showSnapshotView:(UIView *)snapshotView
{
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    UIWindow *mainWindow = [[UIApplication sharedApplication].windows firstObject];
    snapshotView.frame = mainWindow.bounds;
    [mainWindow addSubview:snapshotView];
    self.snapshotView = snapshotView;
}

- (void)presentViewControllerOnTop:(UIViewController *)viewController completion:(void (^)())completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootViewController = [UIViewController ventouchlock_topMostController];
        [rootViewController presentViewController:viewController animated:NO completion:completion];
    });
}

- (NSString *)keychainPasscodeAttemptAccountName
{
    return [self.keychainPasscodeAccount stringByAppendingString:@"_AttemptName"];
}

- (NSString *)keypathOfAutolockOptions
{
    return [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(options)), NSStringFromSelector(@selector(shouldAutoLockOnAppLifeCycleNotifications))];
}

- (VENTouchLockSplashViewController *)splashViewController
{
    VENTouchLockSplashViewController *splashViewController = [[self.splashViewControllerClass alloc] init];

    void (^didFinishWithResult)(BOOL success, VENTouchLockSplashViewControllerUnlockType unlockType) = splashViewController.didFinishWithResult;

    __weak typeof(self) weakSelf = self;
    splashViewController.didFinishWithResult = ^(BOOL success, VENTouchLockSplashViewControllerUnlockType unlockType) {
        __strong typeof(self) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.locked = NO;
            if (didFinishWithResult) {
                didFinishWithResult(success, unlockType);
            }

            VENTouchLockCompletionType lockCompletion;
            if (success) {
                switch (unlockType) {
                    case VENTouchLockSplashViewControllerUnlockTypeTouchID: {
                        lockCompletion = VENTouchLockCompletionTypeTouchIDUnlock;
                        break;
                    }
                    case VENTouchLockSplashViewControllerUnlockTypePasscode: {
                        lockCompletion = VENTouchLockCompletionTypePasscodeUnlock;
                        break;
                    }
                    default: {
                        lockCompletion = VENTouchLockCompletionTypeUndefined;
                        break;
                    }
                }
            } else {
                lockCompletion = VENTouchLockCompletionTypePasscodeLimitReached;
            }
            if (strongSelf.lockCompletion) {
                self.lockCompletion(lockCompletion);
            }
        });
    };

    return splashViewController;
}

- (VENTouchLockEnterPasscodeViewController *)enterPasscodeViewController
{
    VENTouchLockEnterPasscodeViewController *enterPasscodeViewController = [[VENTouchLockEnterPasscodeViewController alloc] initWithTouchLock:self];

    __weak typeof(self) weakSelf = self;
    enterPasscodeViewController.didFinishWithResult = ^(BOOL success) {
        __strong typeof(self) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.locked = NO;
            VENTouchLockCompletionType lockCompletion = success ? VENTouchLockCompletionTypePasscodeUnlock : VENTouchLockCompletionTypeCancel;
            if (strongSelf.lockCompletion) {
                self.lockCompletion(lockCompletion);
            }
        });
    };
    return enterPasscodeViewController;
}

- (UIViewController *)transformViewController:(UIViewController *)vc byEmbedding:(BOOL)shouldEmbed
{
    UIViewController *viewController;
    if (shouldEmbed) {
        viewController = [vc ventouchlock_embeddedInNavigationControllerWithNavigationBarClass:self.options.navigationBarClass];
    }
    else {
        viewController = vc;
    }
    return viewController;
}

@end
