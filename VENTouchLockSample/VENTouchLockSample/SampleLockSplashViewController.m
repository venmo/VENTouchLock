#import "SampleLockSplashViewController.h"
#import "VENTouchLock.h"

@interface SampleLockSplashViewController ()

@property (weak, nonatomic) IBOutlet UIButton *touchIDButton;

@end

@implementation SampleLockSplashViewController

- (instancetype)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.didUnlockSuccesfullyBlock = ^{
            NSLog(@"Sample App Unlocked");
        };
    }
    return self;
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
