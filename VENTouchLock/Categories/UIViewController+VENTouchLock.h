#import <UIKit/UIKit.h>

@interface UIViewController (VENTouchLock)

- (UINavigationController *)ventouchlock_embeddedInNavigationController;

+ (UIViewController*)ventouchlock_topMostController;

@end