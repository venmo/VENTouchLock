#import <XCTest/XCTest.h>
#import <KIF/KIF.h>
#import "VENTouchLock.h"

@interface VENTouchLockSampleTests : XCTestCase

@end

@implementation VENTouchLockSampleTests

- (void)testBasicCreatePasswordFlow
{
    [self dismissAutoLockAndDeletePasscode];
    VENTouchLockAppearance *currentAppearance = [VENTouchLock sharedInstance].appearance;
    [tester tapViewWithAccessibilityLabel:@"Set Passcode"];
    [tester waitForKeyboard];
    [tester enterTextIntoCurrentFirstResponder:@"1"];
    [tester enterTextIntoCurrentFirstResponder:@"2"];
    [tester enterTextIntoCurrentFirstResponder:@"3"];
    [tester enterTextIntoCurrentFirstResponder:@"4"];
    [tester waitForViewWithAccessibilityLabel:currentAppearance.createPasscodeConfirmLabelText];
    [tester enterTextIntoCurrentFirstResponder:@"1"];
    [tester enterTextIntoCurrentFirstResponder:@"2"];
    [tester enterTextIntoCurrentFirstResponder:@"3"];
    [tester enterTextIntoCurrentFirstResponder:@"4"];
    [tester waitForAbsenceOfKeyboard];
}

- (void)testBasicEnterPasscodeFlow
{
    [self dismissAutoLockAndDeletePasscode];
    [[VENTouchLock sharedInstance] setPasscode:@"7890"];
    [tester tapViewWithAccessibilityLabel:@"Show Passcode"];
    [tester waitForKeyboard];
    [tester enterTextIntoCurrentFirstResponder:@"7"];
    [tester enterTextIntoCurrentFirstResponder:@"8"];
    [tester enterTextIntoCurrentFirstResponder:@"9"];
    [tester enterTextIntoCurrentFirstResponder:@"0"];
    [tester waitForAbsenceOfKeyboard];
}

- (void)testAdvancedCreatePasscodeFlow
{
    [self dismissAutoLockAndDeletePasscode];
    VENTouchLockAppearance *currentAppearance = [VENTouchLock sharedInstance].appearance;
    [tester tapViewWithAccessibilityLabel:@"Set Passcode"];
    [tester waitForKeyboard];
    [tester enterTextIntoCurrentFirstResponder:@"1"];
    [tester enterTextIntoCurrentFirstResponder:@"2"];
    [tester enterTextIntoCurrentFirstResponder:@"3"];
    [tester enterTextIntoCurrentFirstResponder:@"4"];
    [tester waitForViewWithAccessibilityLabel:currentAppearance.createPasscodeConfirmLabelText];
    [tester enterTextIntoCurrentFirstResponder:@"1"];
    [tester enterTextIntoCurrentFirstResponder:@"2"];
    [tester enterTextIntoCurrentFirstResponder:@"3"];
    [tester enterTextIntoCurrentFirstResponder:@"1"];
    [tester waitForViewWithAccessibilityLabel:currentAppearance.createPasscodeMismatchedLabelText];
    [tester enterTextIntoCurrentFirstResponder:@"1"];
    [tester enterTextIntoCurrentFirstResponder:@"2"];
    [tester enterTextIntoCurrentFirstResponder:@"3"];
    [tester enterTextIntoCurrentFirstResponder:@"4"];
    [tester waitForViewWithAccessibilityLabel:currentAppearance.createPasscodeConfirmLabelText];
    [tester enterTextIntoCurrentFirstResponder:@"1"];
    [tester enterTextIntoCurrentFirstResponder:@"2"];
    [tester enterTextIntoCurrentFirstResponder:@"3"];
    [tester enterTextIntoCurrentFirstResponder:@"4"];
    [tester waitForAbsenceOfKeyboard];
}

- (void)testAdvancedEnterPasscodeFlow
{
    [self dismissAutoLockAndDeletePasscode];
    VENTouchLockAppearance *currentAppearance = [VENTouchLock sharedInstance].appearance;
    [[VENTouchLock sharedInstance] setPasscode:@"7890"];
    [tester tapViewWithAccessibilityLabel:@"Show Passcode"];
    [tester waitForKeyboard];
    [tester enterTextIntoCurrentFirstResponder:@"7"];
    [tester enterTextIntoCurrentFirstResponder:@"8"];
    [tester enterTextIntoCurrentFirstResponder:@"9"];
    [tester enterTextIntoCurrentFirstResponder:@"9"];
    [tester waitForViewWithAccessibilityLabel:currentAppearance.enterPasscodeIncorrectLabelText];
    [tester enterTextIntoCurrentFirstResponder:@"7"];
    [tester enterTextIntoCurrentFirstResponder:@"8"];
    [tester enterTextIntoCurrentFirstResponder:@"9"];
    [tester enterTextIntoCurrentFirstResponder:@"0"];
    [tester waitForAbsenceOfKeyboard];
}


#pragma mark - Helper Methods

- (void)dismissAutoLockAndDeletePasscode
{
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (viewController.presentedViewController) {
        viewController = viewController.presentedViewController;
        if ([viewController isKindOfClass:[VENTouchLockSplashViewController class]]) {
            VENTouchLockSplashViewController *splashViewController = (VENTouchLockSplashViewController *)viewController;
            [splashViewController dismissWithUnlockSuccess:YES unlockType:VENTouchLockSplashViewControllerUnlockTypePasscode animated:NO];
        }
    }
    [[VENTouchLock sharedInstance] deletePasscode];
}

@end