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
@property (strong, nonatomic) VENTouchLockAppearance *appearance;

@property (strong, nonatomic) UIViewController *displayController;

@property (weak, nonatomic) UIWindow *mainWindow;
@property (strong, nonatomic) UIWindow *lockWindow;

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

        [notificationCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

        self.mainWindow = [[UIApplication sharedApplication].windows firstObject];
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
                                                  response = (self.appearance.touchIDCancelPresentsPasscodeViewController) ? VENTouchLockTouchIDResponseUsePasscode : VENTouchLockTouchIDResponseCanceled;
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
    if (![self isPasscodeSet] || self.lockWindow.isKeyWindow) {
        return;
    }

    if (self.splashViewControllerClass != NULL) {
        VENTouchLockSplashViewController *splashViewController = [[self.splashViewControllerClass alloc] init];
        if ([splashViewController isKindOfClass:[VENTouchLockSplashViewController class]]) {
            self.lockWindow = [[UIWindow alloc] initWithFrame:self.mainWindow.frame];
            self.lockWindow.windowLevel = UIWindowLevelAlert + 1;

            if (self.appearance.splashShouldEmbedInNavigationController) {
                self.displayController = [splashViewController ventouchlock_embeddedInNavigationControllerWithNavigationBarClass:self.appearance.navigationBarClass];
            }
            else {
                self.displayController = splashViewController;
            }

            self.lockWindow.rootViewController = self.displayController;

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.lockWindow makeKeyAndVisible];
            });
        }
    }
}

- (void)unlockAnimated:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^{
                self.lockWindow.alpha = 0;
            } completion:^(BOOL finished) {
                [self.mainWindow makeKeyAndVisible];
            }];
        } else {
            [self.mainWindow makeKeyAndVisible];
        }
    });
}


#pragma mark - NSNotifications

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self lock];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self lock];
}

@end
