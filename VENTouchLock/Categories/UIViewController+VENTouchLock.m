#import "UIViewController+VENTouchLock.h"

@implementation UIViewController (VENTouchLock)

- (UINavigationController *)ventouchlock_embeddedInNavigationControllerWithNavigationBarClass:(Class)navigationBarClass
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:navigationBarClass toolbarClass:nil];
    [navigationController pushViewController:self animated:NO];
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