#import <UIKit/UIKit.h>

@interface UIViewController (VENTouchLock)

- (UINavigationController *)embeddedInNavigationController;

+ (UIViewController*) topMostController;

@end
