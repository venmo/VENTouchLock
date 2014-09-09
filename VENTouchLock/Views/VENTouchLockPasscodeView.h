#import <UIKit/UIKit.h>

@interface VENTouchLockPasscodeView : UIView

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSArray *characters;

/**
 Creates a passcode view controller with the given title and frame.
 @param completionBlock called after shake and vibrate complete
 */
- (instancetype)initWithTitle:(NSString *)title frame:(CGRect)frame;

/**
 Shakes the reciever and vibrates the device.
 @param completionBlock called after shake and vibrate complete
 */
- (void)shakeAndVibrateCompletion:(void (^)())completionBlock;

@end
