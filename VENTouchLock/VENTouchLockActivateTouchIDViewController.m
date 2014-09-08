#import "VENTouchLockActivateTouchIDViewController.h"
#import "VENTouchLock.h"

@implementation VENTouchLockActivateTouchIDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Touch ID", nil);
    [self.navigationItem setHidesBackButton:YES animated:NO];
}
- (IBAction)userTappedUseTouchID:(id)sender
{
    [VENTouchLock setShouldUseTouchID:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)userTappedSkip:(id)sender
{
    [VENTouchLock setShouldUseTouchID:NO];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
