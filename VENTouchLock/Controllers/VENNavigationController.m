//
//  VENNavigationController.m
//  VENTouchLock
//
//  Created by Sean M Kirkpatrick on 2/28/15.
//  Copyright (c) 2015 Venmo. All rights reserved.
//

#import "VENNavigationController.h"

@implementation VENNavigationController

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

@end
