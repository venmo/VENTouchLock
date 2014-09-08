#import <UIKit/UIKit.h>

@interface VENTouchLockSplashViewController : UIViewController

- (void)showUnlockAnimated:(BOOL)animated;

- (void)showTouchID;

- (void)showPasscodeAnimated:(BOOL)animated;

@property (nonatomic, copy) void (^didUnlockSuccesfullyBlock)();

@end
