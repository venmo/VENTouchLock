#import "VENTouchLockPasscodeCharacterView.h"

@interface VENTouchLockPasscodeCharacterView ()

@property (strong, nonatomic) CAShapeLayer *circle;
@property (strong, nonatomic) CAShapeLayer *hyphen;

@end

@implementation VENTouchLockPasscodeCharacterView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _isEmpty = YES;
    self.backgroundColor = [UIColor clearColor];
    [self drawCircle];
    [self drawHyphen];
    [self redraw];
}

- (void)redraw
{
    self.circle.hidden = self.isEmpty;
    self.hyphen.hidden = !self.isEmpty;
}

- (void)drawCircle
{
    CGFloat borderWidth = 2;
    CGFloat radius = CGRectGetWidth(self.bounds) / 2 - borderWidth;
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(borderWidth, borderWidth, 2.0*radius, 2.0*radius)

                                             cornerRadius:radius].CGPath;
    UIColor *circleColor = [UIColor blackColor];
    circle.fillColor = circleColor.CGColor;
    circle.strokeColor =  circleColor.CGColor;
    circle.borderWidth = borderWidth;
    [self.layer addSublayer:circle];
    _circle = circle;
}

- (void)drawHyphen
{
    CGFloat horizontalMargin = 1;
    CGFloat hyphenHeight = CGRectGetHeight(self.bounds) / 7;
    CAShapeLayer *hyphen = [CAShapeLayer layer];
    UIBezierPath *hyphenPath = [UIBezierPath bezierPath];

    CGPoint leftTopCorner = CGPointMake(horizontalMargin, 3 * hyphenHeight);
    CGPoint rightTopCorner = CGPointMake((CGRectGetWidth(self.bounds) - horizontalMargin), 3 * hyphenHeight);
    CGPoint rightBottomCorner = CGPointMake((CGRectGetWidth(self.bounds) - horizontalMargin), 4 * hyphenHeight);
    CGPoint leftBottomCorner = CGPointMake(horizontalMargin, 4 * hyphenHeight);

    [hyphenPath moveToPoint:leftTopCorner];
    [hyphenPath addLineToPoint:rightTopCorner];
    [hyphenPath addLineToPoint:rightBottomCorner];
    [hyphenPath addLineToPoint:leftBottomCorner];

    hyphen.path = hyphenPath.CGPath;
    UIColor *hyphenColor = [UIColor blackColor];
    hyphen.fillColor = hyphenColor.CGColor;
    hyphen.strokeColor = hyphenColor.CGColor;
    [self.layer addSublayer:hyphen];
    _hyphen = hyphen;
}

- (void)setIsEmpty:(BOOL)isEmpty {
    if (_isEmpty != isEmpty) {
        _isEmpty = isEmpty;
        [self redraw];
    }
}
- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    CGColorRef cgColor = fillColor.CGColor;
    self.hyphen.fillColor = cgColor;
    self.hyphen.strokeColor = cgColor;
    self.circle.fillColor = cgColor;
    self.circle.strokeColor = cgColor;
}

@end