#import "SampleViewController.h"
#import "VENTouchLock.h"

@implementation SampleViewController
            
- (IBAction)userTappedSetPasscode:(id)sender
{
    if ([[VENTouchLock sharedInstance] isPasscodeSet]) {
        [[[UIAlertView alloc] initWithTitle:@"Passcode already exists" message:@"To set a new one, first delete the existing one" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else {
        VENTouchLockSetPasscodeViewController *setPasscodeVC = [[VENTouchLockSetPasscodeViewController alloc] init];
        [self presentViewController:[setPasscodeVC embeddedInNavigationController] animated:YES completion:nil];
    }
}

- (IBAction)userTappedShowPasscode:(id)sender
{
    if ([[VENTouchLock sharedInstance] isPasscodeSet]) {
    VENTouchLockEnterPasscodeViewController *showPasscodeVC = [[VENTouchLockEnterPasscodeViewController alloc] init];
    [self presentViewController:[showPasscodeVC embeddedInNavigationController] animated:YES completion:nil];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"No passcode" message:@"Please set a passcode first" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}
- (IBAction)userTappedDeletePasscode:(id)sender
{
    if ([[VENTouchLock sharedInstance] isPasscodeSet]) {
        [[VENTouchLock sharedInstance] deletePasscode];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"No passcode" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

@end
