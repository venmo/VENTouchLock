#import "VENTouchLockBlurView.h"

@implementation VENTouchLockBlurView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            visualEffectView.frame = frame;
            [self addSubview:visualEffectView];
        } else {
            UIToolbar* bgToolbar = [[UIToolbar alloc] initWithFrame:frame];
            [self addSubview:bgToolbar];
        }
    }
    return self;
}


@end
