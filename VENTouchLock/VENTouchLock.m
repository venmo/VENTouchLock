#import "VENTouchLock.h"

#import <SSKeychain/SSKeychain.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "UIViewController+VENTouchLock.h"

static NSString *const VENTouchLockDefaultUniqueIdentifier = @"VENTouchLockDefaultUniqueIdentifier";
static NSString *const VENTouchLockTouchIDOn = @"On";
static NSString *const VENTouchLockTouchIDOff = @"Off";

@interface VENTouchLock ()

@property (copy, nonatomic) NSString *keychainService;
@property (copy, nonatomic) NSString *keychainPasscodeAccount;
@property (copy, nonatomic) NSString *keychainTouchIDAccount;
@property (copy, nonatomic) NSString *touchIDReason;
@property (assign, nonatomic) NSUInteger passcodeAttemptLimit;
@property (strong, nonatomic) UIView *snapshotView;
@property (strong, nonatomic) VENTouchLockOptions *options;
@property (assign, nonatomic) BOOL locked;

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
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
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

    __weak typeof(self) weakSelf = self;
    BOOL fromBackground = [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
    UIViewController *displayViewController;
    UIView *snapshotView;

    if (self.splashViewControllerClass != NULL) {
        VENTouchLockSplashViewController *splashViewController = [[self.splashViewControllerClass alloc] init];

        void (^didFinishWithResult)(BOOL success, VENTouchLockSplashViewControllerUnlockType unlockType) = splashViewController.didFinishWithResult;

        splashViewController.didFinishWithResult = ^(BOOL success, VENTouchLockSplashViewControllerUnlockType unlockType) {
            __strong typeof(self) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.locked = NO;
                if (didFinishWithResult) {
                    didFinishWithResult(success, unlockType);
                }
            });
        };

        if ([splashViewController isKindOfClass:[VENTouchLockSplashViewController class]]) {
            if (self.options.splashShouldEmbedInNavigationController) {
                displayViewController = [splashViewController ventouchlock_embeddedInNavigationControllerWithNavigationBarClass:self.options.navigationBarClass];
            }
            else {
                displayViewController = splashViewController;
            }

            if (fromBackground) {
                VENTouchLockSplashViewController *snapshotSplashViewController = [[self.splashViewControllerClass alloc] init];
                UIViewController *snapshotDisplayController;
                if (self.options.splashShouldEmbedInNavigationController) {
                snapshotDisplayController = [snapshotSplashViewController ventouchlock_embeddedInNavigationControllerWithNavigationBarClass:self.options.navigationBarClass];
                }
                else {
                    snapshotDisplayController = snapshotSplashViewController;
                }
                [snapshotDisplayController loadView];
                [snapshotDisplayController viewDidLoad];
                snapshotView = snapshotDisplayController.view;
            }
        }
    } else {
        VENTouchLockEnterPasscodeViewController *enterPasscodeViewController = [[VENTouchLockEnterPasscodeViewController alloc] initWithTouchLock:self];
        enterPasscodeViewController.didFinishWithResult = ^(BOOL success) {
            __strong typeof(self) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.locked = NO;
            });
        };
        if (self.options.passcodeViewControllerShouldEmbedInNavigationController) {
            displayViewController = [enterPasscodeViewController ventouchlock_embeddedInNavigationControllerWithNavigationBarClass:self.options.navigationBarClass];
        } else {
            displayViewController = enterPasscodeViewController;
        }

        if (fromBackground && self.appSwitchViewClass != NULL) {
             snapshotView = [[self.appSwitchViewClass alloc] initWithFrame:CGRectZero];
        }
    }

    if (fromBackground && snapshotView) {
        UIWindow *mainWindow = [[UIApplication sharedApplication].windows firstObject];
        snapshotView.frame = mainWindow.bounds;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        [mainWindow addSubview:snapshotView];
        self.snapshotView = snapshotView;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.locked = YES;
        UIViewController *rootViewController = [UIViewController ventouchlock_topMostController];
        [rootViewController presentViewController:displayViewController animated:NO completion:nil];
    });
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
    });

}


#pragma mark - Internal

- (NSString *)keychainPasscodeAttemptAccountName
{
    return [self.keychainPasscodeAccount stringByAppendingString:@"_AttemptName"];
}

@end
