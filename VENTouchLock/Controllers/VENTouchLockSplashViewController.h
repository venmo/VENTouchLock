#import <UIKit/UIKit.h>

@interface VENTouchLockSplashViewController : UIViewController

- (void)showUnlockAnimated:(BOOL)animated;

- (void)showTouchID;

- (void)showPasscodeAnimated:(BOOL)animated;

- (void)dismissWithUnlockSuccess:(BOOL)success animated:(BOOL)animated;

@property (nonatomic, copy) void (^didFinishWithSuccess)(BOOL success);

@end
