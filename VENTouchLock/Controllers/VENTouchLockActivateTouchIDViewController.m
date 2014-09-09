#import "VENTouchLockActivateTouchIDViewController.h"
#import "VENTouchLock.h"
#import "VENTouchLockSetPasscodeViewController.h"

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
    [self.sourceViewController finishWithResult:YES];
}

- (IBAction)userTappedSkip:(id)sender
{
    [VENTouchLock setShouldUseTouchID:NO];
    [self.sourceViewController finishWithResult:YES];
}
@end
