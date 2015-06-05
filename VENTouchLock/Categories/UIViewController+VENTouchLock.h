#import <UIKit/UIKit.h>

@interface UIViewController (VENTouchLock)

/**
 * @return The highest modally presented view controller of the app's root view controller.
 */
+ (UIViewController*)ventouchlock_topMostController;

/**
 * @param navigationBarClass The navigation bar class that should be used to initialize the navigation controller. Defaults to UINavigationBar.
 * @return A navigation controller that contains the reciever as its root view controller.
 */
- (UINavigationController *)ventouchlock_embeddedInNavigationControllerWithNavigationBarClass:(Class)navigationBarClass;

@end