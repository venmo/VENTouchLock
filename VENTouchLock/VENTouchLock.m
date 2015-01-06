#import "VENTouchLock.h"

#import <SSKeychain/SSKeychain.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "UIViewController+VENTouchLock.h"


static NSString *const VENTouchLockUserDefaultsKeyTouchIDActivated = @"VENTouchLockUserDefaultsKeyTouchIDActivated";

@interface VENTouchLock ()

@property (copy, nonatomic) NSString *keychainService;
@property (copy, nonatomic) NSString *keychainAccount;
@property (copy, nonatomic) NSString *touchIDReason;
@property (assign, nonatomic) NSUInteger passcodeAttemptLimit;
@property (strong, nonatomic) UIView *snapshotView;
@property (strong, nonatomic) VENTouchLockAppearance *appearance;

@end

@implementation VENTouchLock

+ (instancetype)sharedInstance
{
    static VENTouchLock *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
        sharedInstance.appearance = [[VENTouchLockAppearance alloc] init];
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
           keychainAccount:(NSString *)account
             touchIDReason:(NSString *)reason
      passcodeAttemptLimit:(NSUInteger)attemptLimit
{
    self.keychainService = service;
    self.keychainAccount = account;
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
    NSString *account = self.keychainAccount;
    return [SSKeychain passwordForService:service account:account];
}

- (BOOL)isPasscodeValid:(NSString *)passcode
{
    return [passcode isEqualToString:[self currentPasscode]];
}

- (void)setPasscode:(NSString *)passcode
{
    NSString *service = self.keychainService;
    NSString *account = self.keychainAccount;
    [SSKeychain setPassword:passcode forService:service account:account];
}

- (void)deletePasscode
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:VENTouchLockUserDefaultsKeyTouchIDActivated];
    [VENTouchLockEnterPasscodeViewController resetPasscodeAttemptHistory];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSString *service = self.keychainService;
    NSString *account = self.keychainAccount;
    [SSKeychain deletePasswordForService:service account:account];
}


#pragma mark - TouchID Methods

+ (BOOL)canUseTouchID
{
    return [[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                                 error:nil];
}

+ (BOOL)shouldUseTouchID
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:VENTouchLockUserDefaultsKeyTouchIDActivated] && [self canUseTouchID];
}

+ (void)setShouldUseTouchID:(BOOL)shouldUseTouchID
{
    [[NSUserDefaults standardUserDefaults] setBool:shouldUseTouchID forKey:VENTouchLockUserDefaultsKeyTouchIDActivated];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showTouchID
{
    UIViewController *rootViewController = [UIViewController ventouchlock_topMostController];
    
    [self requestTouchIDWithCompletion:^(VENTouchLockTouchIDResponse response) {
        switch (response) {
            case VENTouchLockTouchIDResponseSuccess:
                [rootViewController dismissViewControllerAnimated:YES completion:nil];
                self.backgroundLockVisible = NO;
                break;
            case VENTouchLockTouchIDResponseUsePasscode:
                break;
            default:
                break;
        }
    }];
}

- (void)requestTouchIDWithCompletion:(void (^)(VENTouchLockTouchIDResponse))completionBlock
{
    [self requestTouchIDWithCompletion:completionBlock reason:self.touchIDReason];
}

- (void)requestTouchIDWithCompletion:(void (^)(VENTouchLockTouchIDResponse))completionBlock reason:(NSString *)reason
{
    if ([[self class] canUseTouchID]) {
        LAContext *context = [[LAContext alloc] init];
        context.localizedFallbackTitle = @"Enter Passcode";
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:reason
                          reply:^(BOOL success, NSError *error) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  if (success) {
                                      if (completionBlock) {
                                          completionBlock(VENTouchLockTouchIDResponseSuccess);
                                      }
                                  }
                                  else {
                                      if (completionBlock) {
                                          VENTouchLockTouchIDResponse response;
                                          switch (error.code) {
                                              case LAErrorUserFallback:
                                                  response = VENTouchLockTouchIDResponseUsePasscode;
                                                  break;
                                              case LAErrorUserCancel:
                                                  response = VENTouchLockTouchIDResponseCanceled;
                                                  break;
                                              default:
                                                  response = VENTouchLockTouchIDResponseUndefined;
                                                  break;
                                          }
                                          completionBlock(response);
                                      }
                                  }
                              });
                          }];
    }
}

- (void)lockFromBackground:(BOOL)fromBackground
{
    VENTouchLockEnterPasscodeViewController *splashViewController = [self enterPasscodeVC];
    UIWindow *mainWindow = [[UIApplication sharedApplication].windows firstObject];
    UIViewController *rootViewController = [UIViewController ventouchlock_topMostController];
    UIViewController *displayController;
    if (self.appearance.splashShouldEmbedInNavigationController) {
        displayController = [splashViewController ventouchlock_embeddedInNavigationController];
    }
    else {
        displayController = splashViewController;
    }
    
    if (fromBackground) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        VENTouchLockEnterPasscodeViewController *snapshotSplashViewController = [[VENTouchLockEnterPasscodeViewController alloc] init];
        snapshotSplashViewController.snapshotViewController = YES;
        UIViewController *snapshotDisplayController;
        if (self.appearance.splashShouldEmbedInNavigationController) {
            snapshotDisplayController = [snapshotSplashViewController ventouchlock_embeddedInNavigationController];
        }
        else {
            snapshotDisplayController = snapshotSplashViewController;
        }
        [snapshotDisplayController loadView];
        [snapshotDisplayController viewDidLoad];
        snapshotDisplayController.view.frame = mainWindow.bounds;
        self.snapshotView = snapshotDisplayController.view;
        [mainWindow addSubview:self.snapshotView];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [rootViewController presentViewController:displayController animated:NO completion:^{
            self.backgroundLockVisible = YES;
            if ([[self class] shouldUseTouchID]) {
                [self showTouchID];
            }
        }];
    });
}

- (VENTouchLockEnterPasscodeViewController *)enterPasscodeVC
{
    VENTouchLockEnterPasscodeViewController *enterPasscodeVC = [[VENTouchLockEnterPasscodeViewController alloc] init];
    __weak VENTouchLockEnterPasscodeViewController *weakVC = enterPasscodeVC;
    enterPasscodeVC.willFinishWithResult = ^(BOOL success) {
        [weakVC dismissViewControllerAnimated:YES completion:nil];
        self.backgroundLockVisible = NO;
    };
    return enterPasscodeVC;
}

#pragma mark - NSNotifications

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    if ([self isPasscodeSet]) {
        [self lockFromBackground:NO];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if ([self isPasscodeSet] && !self.backgroundLockVisible) {
        [[UIApplication sharedApplication] ignoreSnapshotOnNextApplicationLaunch];
        [self lockFromBackground:YES];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
    });

}

@end
