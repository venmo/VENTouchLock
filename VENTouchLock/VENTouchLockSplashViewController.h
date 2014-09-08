#import <UIKit/UIKit.h>

@interface VENTouchLockSplashViewController : UIViewController

- (void)showUnlock;

- (void)showTouchID;

- (void)showPasscode;

@property (nonatomic, copy) void (^didUnlockSuccesfullyBlock)();

@end
