#import "AppDelegate.h"
#import "VENTouchLock.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    VENTouchLock *touchLock = [[VENTouchLock alloc] init];
    [touchLock setKeychainService:@"testService" keychainAccount:@"testAccount" touchIDReason:@"Scan your fingerprint to use the app."];
    if ([touchLock canUseTouchID]) {
        [touchLock requestTouchID];
    }
    self.window.rootViewController = [[[VENTouchLockSetPasscodeViewController alloc] init] embedInNavigationController];
    return YES;
}

@end
