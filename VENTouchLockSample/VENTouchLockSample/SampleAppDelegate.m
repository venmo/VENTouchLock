#import "SampleAppDelegate.h"
#import "VENTouchLock.h"
#import "SampleLockSplashViewController.h"

@interface SampleAppDelegate ()

@end

@implementation SampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[VENTouchLock sharedInstance] setKeychainService:@"testService"
                              keychainPasscodeAccount:@"testPasscodeAccount"
                              keychainTouchIDAccount:@"testTouchIDAccount"
                                        touchIDReason:@"Scan your fingerprint to use the app."
                                 passcodeAttemptLimit:5];
    [VENTouchLock sharedInstance].splashViewControllerClass = [SampleLockSplashViewController class];
    [VENTouchLock sharedInstance].options.shouldAutoLockOnAppLifeCycleNotifications = YES;
    return YES;
}

@end
