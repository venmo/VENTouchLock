#import "VENTouchLockActivateTouchIDViewController.h"

@interface VENTouchLockActivateTouchIDViewController ()

@end

@implementation VENTouchLockActivateTouchIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Touch ID", nil);
    [self.navigationItem setHidesBackButton:YES animated:NO];
    // Do any additional setup after loading the view.
}
- (IBAction)userTappedUseTouchID:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)userTappedSkip:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
