#import "VENTouchLockSetPasscodeViewController.h"

@interface VENTouchLockSetPasscodeViewController ()

@property (strong, nonatomic) NSString *firstPasscode;

@end

@implementation VENTouchLockSetPasscodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Set Passcode", nil);
}

- (void)enteredPasscode:(NSString *)passcode;
{
    if (self.firstPasscode) {
    }
    else {
        self.firstPasscode;
    }

}

@end
