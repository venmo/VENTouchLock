//
//  LockViewController.m
//  VENTouchLockSample
//
//  Created by Dasmer Singh on 9/7/14.
//  Copyright (c) 2014 Venmo. All rights reserved.
//

#import "LockSplashViewController.h"
#import "VENTouchLock.h"

@interface LockSplashViewController ()
@property (weak, nonatomic) IBOutlet UIButton *touchIDButton;

@end

@implementation LockSplashViewController

- (instancetype)init
{
    return [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.touchIDButton.hidden = ![VENTouchLock canUseTouchID];
}

- (IBAction)userTappedShowTouchID:(id)sender
{
    [self showTouchID];
}

- (IBAction)userTappedEnterPasscode:(id)sender
{
    [self showPasscode];
}


@end
