#import <UIKit/UIKit.h>

@interface VENTouchLockPasscodeCharacterView : UIView

/**
 * YES if the view represents no character (to display a hyphen character). NO otherwise (to display a bullet character).
 */
@property (assign, nonatomic) BOOL isEmpty;

/**
 * The fill color of the passcode character.
 */
@property (strong, nonatomic) UIColor *fillColor;

@end