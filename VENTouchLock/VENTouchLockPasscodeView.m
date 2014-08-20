#import "VENTouchLockPasscodeView.h"
@import AudioToolbox;

@implementation VENTouchLockPasscodeView

- (instancetype)initWithFrame:(CGRect)frame
{
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                      owner:self options:nil];
    self = [nibArray firstObject];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (void)shakeAndVibrate
{
    NSString *keyPath = @"position";
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:keyPath];
    [animation setDuration:0.04];
    [animation setRepeatCount:4];
    [animation setAutoreverses:YES];
    CGFloat delta = 10.0;
    CGPoint center = self.center;
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake(center.x - delta, center.y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake(center.x + delta, center.y)]];
    [[self layer] addAnimation:animation forKey:keyPath];
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

@end