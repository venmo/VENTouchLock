#import "SampleViewController.h"
#import "VENTouchLock.h"

@interface SampleViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *touchIDSwitch;
@end

@implementation SampleViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureTouchIDToggle];
}

- (void)configureTouchIDToggle
{
    self.touchIDSwitch.enabled = [[VENTouchLock sharedInstance] isPasscodeSet] && [VENTouchLock canUseTouchID];
    self.touchIDSwitch.on = [VENTouchLock shouldUseTouchID];
}
            
- (IBAction)userTappedSetPasscode:(id)sender
{
    if ([[VENTouchLock sharedInstance] isPasscodeSet]) {
        [[[UIAlertView alloc] initWithTitle:@"Passcode already exists" message:@"To set a new one, first delete the existing one" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else {
        VENTouchLockCreatePasscodeViewController *createPasscodeVC = [[VENTouchLockCreatePasscodeViewController alloc] init];
        [self presentViewController:[createPasscodeVC embeddedInNavigationController] animated:YES completion:nil];
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
        [self configureTouchIDToggle];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"No passcode" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (IBAction)userTappedSwitch:(UISwitch *)toggle
{
    [VENTouchLock setShouldUseTouchID:toggle.on];
}

@end