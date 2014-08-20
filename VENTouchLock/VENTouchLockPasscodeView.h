#import <UIKit/UIKit.h>

@interface VENTouchLockPasscodeView : UIView

- (void)shakeAndVibrateCompletion:(void (^)())completionBlock;

@end
