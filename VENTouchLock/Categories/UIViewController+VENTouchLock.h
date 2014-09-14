#import <UIKit/UIKit.h>

@interface UIViewController (VENTouchLock)

- (UINavigationController *)ven_embeddedInNavigationController;

+ (UIViewController*)ven_topMostController;

@end
