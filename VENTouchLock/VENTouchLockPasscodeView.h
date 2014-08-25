#import <UIKit/UIKit.h>

@interface VENTouchLockPasscodeView : UIView

@property (strong, nonatomic) NSArray *characters;

- (void)shakeAndVibrateCompletion:(void (^)())completionBlock;

@end
