#import "VENTouchLockBlurView.h"

@implementation VENTouchLockBlurView

- (instancetype)initWithFrame:(CGRect)frame blurEffectStyle:(UIBlurEffectStyle)blurEffectStyle
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
            UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:frame];
            [self addSubview:toolbar];
        }
    }
    return self;
}


@end
