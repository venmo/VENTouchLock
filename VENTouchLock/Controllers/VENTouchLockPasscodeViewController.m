#import "VENTouchLockPasscodeViewController.h"
#import "VENTouchLockPasscodeView.h"
#import "VENTouchLockPasscodeCharacterView.h"
#import "UIViewController+VENTouchLock.h"
#import "VENTouchLock.h"

static const NSInteger VENTouchLockViewControllerPasscodeLength = 4;

@interface VENTouchLockPasscodeViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *invisiblePasscodeField;
@property (assign, nonatomic) BOOL shouldIgnoreTextFieldDelegateCalls;

@end

@implementation VENTouchLockPasscodeViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _touchLock = [VENTouchLock sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.view.backgroundColor = [self.touchLock appearance].passcodeViewControllerBackgroundColor;
    
    if (!self.isSnapshotViewController) {
        [self configureInvisiblePasscodeField];
    }
    
    [self configureNavigationItems];
    [self configurePasscodeView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.isSnapshotViewController && ![self.invisiblePasscodeField isFirstResponder]) {
        [self.invisiblePasscodeField becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!self.isSnapshotViewController && [self.invisiblePasscodeField isFirstResponder]) {
        [self.invisiblePasscodeField resignFirstResponder];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (self.isSnapshotViewController) {
        // FIXME: keyboard height should not be hardcoded
        [self setPasscodeViewFrameForKeyboardHeight:216];
    }
}

- (void)configureInvisiblePasscodeField
{
    self.invisiblePasscodeField = [[UITextField alloc] init];
    self.invisiblePasscodeField.keyboardType = UIKeyboardTypeNumberPad;
    self.invisiblePasscodeField.secureTextEntry = YES;
    self.invisiblePasscodeField.delegate = self;
    [self.invisiblePasscodeField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.invisiblePasscodeField];
}

- (void)configureNavigationItems
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self.touchLock appearance].cancelBarButtonItemTitle style:UIBarButtonItemStylePlain target:self action:@selector(userTappedCancel)];
}

- (void)configurePasscodeView
{
    VENTouchLockPasscodeView *passcodeView = [[VENTouchLockPasscodeView alloc] init];
    passcodeView.titleColor = self.touchLock.appearance.passcodeViewControllerTitleColor;
    passcodeView.characterColor = self.touchLock.appearance.passcodeViewControllerCharacterColor;
    [self.view addSubview:passcodeView];
    self.passcodeView = passcodeView;
}

- (void)userTappedCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)finishWithResult:(BOOL)success animated:(BOOL)animated
{
    [self.invisiblePasscodeField resignFirstResponder];
    
    [self dismissViewControllerAnimated:animated completion:^{
        if (self.didFinishWithResult) {
            self.didFinishWithResult(success);
        }
    }];
}
// ^ SYMPLE: Customized

- (UINavigationController *)embeddedInNavigationController
{
    return [super ventouchlock_embeddedInNavigationController];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect newKeyboardFrame = [(NSValue *)[notification.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    [self setPasscodeViewFrameForKeyboardHeight:CGRectGetHeight(newKeyboardFrame)];
}

- (void)setPasscodeViewFrameForKeyboardHeight:(CGFloat)keyboardHeight
{
    CGFloat passcodeLockViewHeight = CGRectGetHeight(self.view.frame) - keyboardHeight;
    CGFloat passcodeLockViewWidth = CGRectGetWidth(self.view.frame);
    self.passcodeView.frame = CGRectMake(0, 0, passcodeLockViewWidth, passcodeLockViewHeight);
}

- (void)enteredPasscode:(NSString *)passcode
{
    self.shouldIgnoreTextFieldDelegateCalls = NO;
}

- (void)clearPasscode
{
    UITextField *textField = self.invisiblePasscodeField;
    textField.text = @"";
    for (VENTouchLockPasscodeCharacterView *characterView in self.passcodeView.characters) {
        characterView.isEmpty = YES;
    }
}


#pragma mark - UITextField Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.shouldIgnoreTextFieldDelegateCalls) {
        return NO;
    }
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSUInteger newLength = [newString length];
    if (newLength > VENTouchLockViewControllerPasscodeLength) {
        [self.passcodeView shakeAndVibrateCompletion:nil];
        textField.text = @"";
        return NO;
    }
    else {
        for (VENTouchLockPasscodeCharacterView *characterView in self.passcodeView.characters) {
            NSUInteger index = [self.passcodeView.characters indexOfObject:characterView];
            characterView.isEmpty = (index >= newLength);
        }
        return YES;
    }
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (self.shouldIgnoreTextFieldDelegateCalls) {
        return;
    }
    NSString *newString = textField.text;
    NSUInteger newLength = [newString length];
    
    if (newLength == VENTouchLockViewControllerPasscodeLength) {
        self.shouldIgnoreTextFieldDelegateCalls = YES;
        textField.text = @"";
        [self performSelector:@selector(enteredPasscode:) withObject:newString afterDelay:0.3];
    }
}

# pragma mark Symple rotation behavior

-(BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - notification action

- (void)didBecomeActiveNotification
{
    if (!self.isSnapshotViewController && ![self.invisiblePasscodeField isFirstResponder]) {
        [self.invisiblePasscodeField becomeFirstResponder];
    }
}

@end
