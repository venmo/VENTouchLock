#import "VENTouchLock.h"

#import <SSKeychain/SSKeychain.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "UIViewController+VENTouchLock.h"

@interface VENTouchLock ()

@property (copy, nonatomic) NSString *keychainService;
@property (copy, nonatomic) NSString *keychainAccount;

@property (copy, nonatomic) NSString *touchIDReason;

@property (strong, nonatomic) UIView *snapshotView;
@property (assign, nonatomic) BOOL isLocked;
@property (assign, nonatomic) Class splashViewControllerClass;

@end

@implementation VENTouchLock

+ (instancetype)sharedInstance
{
    static VENTouchLock *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}


#pragma mark - Instance Methods

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(applicationDidEnterBackground:) name: UIApplicationDidEnterBackgroundNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(applicationWillEnterForeground:) name: UIApplicationWillEnterForegroundNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(applicationDidFinishLaunching:) name: UIApplicationDidFinishLaunchingNotification object: nil];

    }
    return self;
}

- (void)setKeychainService:(NSString *)service
           keychainAccount:(NSString *)account
             touchIDReason:(NSString *)reason
 splashViewControllerClass:(Class)splashViewControllerClass
{
    self.keychainService = service;
    self.keychainAccount = account;
    self.touchIDReason = reason;
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
    NSString *service = self.keychainService;
    NSString *account = self.keychainAccount;
    [SSKeychain deletePasswordForService:service account:account];
}

#pragma mark - TouchID Methods

+ (BOOL)canUseTouchID
{
    LAContext *context = [[LAContext alloc] init];
    return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                error:nil];
}

- (void)requestTouchIDWithCompletion:(void (^)(VENTouchLockTouchIDResponse))completionBlock
{
    if ([[self class] canUseTouchID]) {
        NSString *localizedReason = self.touchIDReason;
        LAContext *context = [[LAContext alloc] init];
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:localizedReason
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
            __weak VENTouchLock *weakSelf = self;
            splashViewController.didUnlockSuccesfullyBlock = ^{
                weakSelf.isLocked = NO;
            };
            UIWindow *mainWindow = [[UIApplication sharedApplication].windows firstObject];
            UIViewController *rootViewController = mainWindow.rootViewController;
            UINavigationController *navigationController = [splashViewController embeddedInNavigationController];
            if (fromBackground) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
                VENTouchLockSplashViewController *snapshotSplashViewController = [[self.splashViewControllerClass alloc] init];
                self.snapshotView = [snapshotSplashViewController embeddedInNavigationController].view;
                [mainWindow addSubview:self.snapshotView];
            }
            self.isLocked = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.001 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [rootViewController presentViewController:navigationController animated:NO completion:^{
                    if (!fromBackground) {
                        [splashViewController showUnlock];
                    }
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
    if ([self isPasscodeSet] && !self.isLocked) {
        [self lockFromBackground:YES];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self.snapshotView removeFromSuperview];
    self.snapshotView = nil;
}

@end
