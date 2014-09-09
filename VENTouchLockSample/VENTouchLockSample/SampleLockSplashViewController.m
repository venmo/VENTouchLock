//
//  LockViewController.m
//  VENTouchLockSample
//
//  Created by Dasmer Singh on 9/7/14.
//  Copyright (c) 2014 Venmo. All rights reserved.
//

#import "SampleLockSplashViewController.h"
#import "VENTouchLock.h"

@interface SampleLockSplashViewController ()
@property (weak, nonatomic) IBOutlet UIButton *touchIDButton;

@end

@implementation SampleLockSplashViewController

- (instancetype)init
{
    return [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.touchIDButton.hidden = ![VENTouchLock shouldUseTouchID];
}

- (IBAction)userTappedShowTouchID:(id)sender
{
    [self showTouchID];
}

- (IBAction)userTappedEnterPasscode:(id)sender
{
    [self showPasscodeAnimated:YES];
}


@end
