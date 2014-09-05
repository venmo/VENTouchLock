#import <UIKit/UIKit.h>

@interface VENTouchLockPasscodeView : UIView

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSArray *characters;

- (instancetype)initWithTitle:(NSString *)title frame:(CGRect)frame;

- (void)shakeAndVibrateCompletion:(void (^)())completionBlock;

@end
