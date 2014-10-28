#import <UIKit/UIKit.h>

@interface UIViewController (VENTouchLock)

/**
 * @return The highest modally presented view controller of the app's root view controller.
 */
+ (UIViewController*)ventouchlock_topMostController;

/**
 * @return A navigation controller that contains the reciever as its root view controller.
 */
- (UINavigationController *)ventouchlock_embeddedInNavigationController;

@end