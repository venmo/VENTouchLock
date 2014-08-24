//
//  VENTouchLockPasscodeCharacterView.m
//  VENTouchLockSample
//
//  Created by Dasmer Singh on 8/24/14.
//  Copyright (c) 2014 Venmo. All rights reserved.
//

#import "VENTouchLockPasscodeCharacterView.h"

@implementation VENTouchLockPasscodeCharacterView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _isEmpty = YES;
        [self drawCircle];
    }
    return self;
}

- (void)draw
{

}

- (void)drawCircle
{
    CGFloat borderWidth = 2;
    CGFloat radius = (CGRectGetWidth(self.frame) - borderWidth) / 2;
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)

                                             cornerRadius:radius].CGPath;
    UIColor *circleColor = self.color ?: [UIColor blackColor];
    circle.fillColor = circleColor.CGColor;
    circle.strokeColor =  circleColor.CGColor;
    circle.borderWidth = borderWidth;
    [self.layer addSublayer:circle];
    [self setNeedsDisplay];
}

@end
