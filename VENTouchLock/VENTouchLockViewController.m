#import "VENTouchLockViewController.h"

@interface VENTouchLockViewController ()

@end

@implementation VENTouchLockViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (UINavigationController *)embedInNavigationController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    return navigationController;
}

@end
