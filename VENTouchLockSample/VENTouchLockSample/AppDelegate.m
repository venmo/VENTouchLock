#import "AppDelegate.h"
#import "VENTouchLock.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[VENTouchLock sharedInstance] setKeychainService:@"testService" keychainAccount:@"testAccount" touchIDReason:@"Scan your fingerprint to use the app."];
    return YES;
}

@end
