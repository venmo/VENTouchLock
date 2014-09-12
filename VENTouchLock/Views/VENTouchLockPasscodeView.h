#import <UIKit/UIKit.h>

@interface VENTouchLockPasscodeView : UIView

/**
 The title string directly on top of the passcode characters.
 */
@property (strong, nonatomic) NSString *title;

/**
 An array of the passcode character subviews.
 */
@property (strong, nonatomic) NSArray *characters;

/**
 Creates a passcode view controller with the given title and frame.
 */
- (instancetype)initWithTitle:(NSString *)title frame:(CGRect)frame;

/**
 Shakes the reciever and vibrates the device.
 @param completionBlock called after shake and vibrate complete
 */
- (void)shakeAndVibrateCompletion:(void (^)())completionBlock;

@end
