#import "UIViewController+VENTouchLock.h"

@implementation UIViewController (VENTouchLock)

- (UINavigationController *)embeddedInNavigationController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    navigationController.navigationBar.translucent = NO;
    return navigationController;
}

@end
