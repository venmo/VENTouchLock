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
@property (assign, nonatomic) Class splashViewControllerClass;
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
        NSDictionary *selectorsToNotifications = [[NSDictionary alloc] initWithObjectsAndKeys:
            @selector(applicationDidEnterBackground:), UIApplicationDidEnterBackgroundNotification,
            @selector(applicationWillEnterForeground:), UIApplicationWillEnterForegroundNotification,
            @selector(applicationDidFinishLaunching:), UIApplicationDidFinishLaunchingNotification];
        [selectorsToNotifications enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:(SEL)key name:(NSString *)value object:nil];
        }];
    }
    return self;
}

- (void)setKeychainService:(NSString *)service
           keychainAccount:(NSString *)account
             touchIDReason:(NSString *)reason
      passcodeAttemptLimit:(NSUInteger)attemptLimit
 splashViewControllerClass:(Class)splashViewControllerClass

{
    self.keychainService = service;
    self.keychainAccount = account;
    self.touchIDReason = reason;
    self.passcodeAttemptLimit = attemptLimit;
    self.splashViewControllerClass = splashViewControllerClass;
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

- (void)requestTouchIDWithCompletion:(void (^)(VENTouchLockTouchIDResponse))completionBlock
{
    [self requestTouchIDWithCompletion:completionBlock reason:self.touchIDReason];
}

- (void)requestTouchIDWithCompletion:(void (^)(VENTouchLockTouchIDResponse))completionBlock reason:(NSString *)reason
{
    if ([[self class] canUseTouchID]) {
        LAContext *context = [[LAContext alloc] init];
        context.localizedFallbackTitle = NSLocalizedString(@"Enter Passcode", nil);
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
    if (self.splashViewControllerClass != NULL) {
        VENTouchLockSplashViewController *splashViewController = [[self.splashViewControllerClass alloc] init];
        if ([splashViewController isKindOfClass:[VENTouchLockSplashViewController class]]) {
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
                VENTouchLockSplashViewController *snapshotSplashViewController = [[self.splashViewControllerClass alloc] init];
                [snapshotSplashViewController setIsSnapshotViewController:YES];
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
                    [splashViewController showUnlockAnimated:NO];
                }];
            });
        }
    }
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
