#import "VENTouchLockViewController.h"
#import "VENTouchLockPasscodeView.h"

@interface VENTouchLockViewController () <UITextFieldDelegate>

@property (strong, nonatomic) VENTouchLockPasscodeView *passcodeView;
@property (strong, nonatomic) UITextField *invisiblePasscodeField;

@end

@implementation VENTouchLockViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

    self.view.backgroundColor = [UIColor whiteColor];
    [self configureInvisiblePasscodeField];
}

- (void)configureInvisiblePasscodeField
{
    self.invisiblePasscodeField = [[UITextField alloc] init];
    self.invisiblePasscodeField.keyboardType = UIKeyboardTypeNumberPad;
    self.invisiblePasscodeField.delegate = self;
    [self.view addSubview:self.invisiblePasscodeField];
    [self.invisiblePasscodeField becomeFirstResponder];
}

- (UINavigationController *)embedInNavigationController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    navigationController.navigationBar.translucent = NO;
    return navigationController;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect newKeyboardFrame = [(NSValue *)[notification.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    if (!self.passcodeView) {
        CGFloat passcodeLockViewHeight = CGRectGetHeight(self.view.frame) - CGRectGetHeight(newKeyboardFrame);
        CGFloat passcodeLockViewWidth = CGRectGetWidth(self.view.frame);
        VENTouchLockPasscodeView *passcodeView = [[VENTouchLockPasscodeView alloc] initWithFrame:CGRectMake(0, 0, passcodeLockViewWidth, passcodeLockViewHeight)];
        passcodeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;

        [self.view addSubview:passcodeView];
        self.passcodeView = passcodeView;
    }
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSUInteger newLength = [newString length];
    NSUInteger passcodeLength = 4;
    if (newLength == passcodeLength) {
        return YES;
    } else if (newLength < passcodeLength) {
        return YES;
    } else {
        [self.passcodeView shakeAndVibrate];
        textField.text = @"";
        return NO;
    }
}

@end
