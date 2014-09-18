#import "UIViewController+VENTouchLock.h"

@implementation UIViewController (VENTouchLock)

- (UINavigationController *)ventouchlock_embeddedInNavigationController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    navigationController.navigationBar.translucent = NO;
    return navigationController;
}

+ (UIViewController*)ventouchlock_topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    return topController;
}

@end