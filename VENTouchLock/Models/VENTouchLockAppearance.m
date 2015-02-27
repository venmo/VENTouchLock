#import "VENTouchLockAppearance.h"

@implementation VENTouchLockAppearance

- (instancetype)init
{
    self = [super init];
    if (self) { // Set default values
        _passcodeViewControllerTitleColor = [UIColor blackColor];
        _passcodeViewControllerCharacterColor = [UIColor blackColor];
        _passcodeViewControllerBackgroundColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f];
        _passcodeViewControllerShouldEmbedInNavigationController = NO;
        _cancelBarButtonItemTitle = NSLocalizedString(@"Cancel", nil);
        _createPasscodeInitialLabelText = NSLocalizedString(@"Enter a new passcode", nil);
        _createPasscodeConfirmLabelText = NSLocalizedString(@"Please re-enter your passcode", nil);
        _createPasscodeMismatchedLabelText = NSLocalizedString(@"Passwords did not match. Try again", nil);
        _createPasscodeViewControllerTitle = NSLocalizedString(@"Set Passcode", nil);
        _enterPasscodeInitialLabelText = NSLocalizedString(@"Enter your passcode", nil);
        _enterPasscodeIncorrectLabelText = NSLocalizedString(@"Incorrect passcode. Try again.", nil);
        _enterPasscodeViewControllerTitle = NSLocalizedString(@"Enter Passcode", nil);
        _splashShouldEmbedInNavigationController = NO;
        _touchIDCancelPresentsPasscodeViewController = NO;
    }
    return self;
}

@end
