#import "VENTouchLockPasscodeViewController.h"

static const NSInteger VENTouchLockViewControllerPasscodeLength = 4;

@interface VENTouchLockPasscodeViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *invisiblePasscodeField;

@end

@implementation VENTouchLockPasscodeViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

    self.view.backgroundColor = [UIColor whiteColor];
    [self configureInvisiblePasscodeField];
    [self configureNavigationItems];
}

- (void)configureInvisiblePasscodeField
{
    self.invisiblePasscodeField = [[UITextField alloc] init];
    self.invisiblePasscodeField.keyboardType = UIKeyboardTypeNumberPad;
    self.invisiblePasscodeField.delegate = self;
    [self.invisiblePasscodeField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.invisiblePasscodeField];
    [self.invisiblePasscodeField becomeFirstResponder];
}

- (void)configureNavigationItems
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController)];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
        [self.view addSubview:passcodeView];
        self.passcodeView = passcodeView;
    }
}

- (void)enteredPasscode:(NSString *)passcode
{

}

#pragma mark - UITextField Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSUInteger newLength = [newString length];
    if (newLength > VENTouchLockViewControllerPasscodeLength) {
        [self.passcodeView shakeAndVibrateCompletion:nil];
        textField.text = @"";
        return NO;
    }
    else {
        return YES;
    }
}

- (void)textFieldDidChange:(UITextField *)textField
{
    NSString *newString = textField.text;
    NSUInteger newLength = [newString length];
    if (newLength == VENTouchLockViewControllerPasscodeLength) {
        textField.text = @"";
        [self enteredPasscode:newString];
    }
}

@end
