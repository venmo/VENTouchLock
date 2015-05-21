#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <KIF/KIF.h>
#import "VENTouchLock.h"

@interface VENTouchLock (Internal)

@property (assign, nonatomic) NSUInteger passcodeAttemptLimit;
@property (strong, nonatomic) VENTouchLockAppearance *appearance;

@end

@interface VENTouchLockAutoLockTests : XCTestCase

@end

@implementation VENTouchLockAutoLockTests

- (void)testBasicCreatePasswordFlow
{
    [self dismissAndResetLock];
    VENTouchLockAppearance *currentAppearance = [VENTouchLock sharedInstance].appearance;
    [tester tapViewWithAccessibilityLabel:@"Set Passcode"];
    [tester waitForSoftwareKeyboard];
    [tester waitForTimeInterval:0.5];
    [tester enterTextIntoCurrentFirstResponder:@"1"];
    [tester enterTextIntoCurrentFirstResponder:@"2"];
    [tester enterTextIntoCurrentFirstResponder:@"3"];
    [tester enterTextIntoCurrentFirstResponder:@"4"];
    [tester waitForViewWithAccessibilityLabel:currentAppearance.createPasscodeConfirmLabelText];
    [tester waitForTimeInterval:0.5];
    [tester enterTextIntoCurrentFirstResponder:@"1"];
    [tester enterTextIntoCurrentFirstResponder:@"2"];
    [tester enterTextIntoCurrentFirstResponder:@"3"];
    [tester enterTextIntoCurrentFirstResponder:@"4"];
    [tester waitForAbsenceOfSoftwareKeyboard];
}

- (void)testBasicEnterPasscodeFlow
{
    [self dismissAndResetLock];
    [[VENTouchLock sharedInstance] setPasscode:@"7890"];
    [tester tapViewWithAccessibilityLabel:@"Show Passcode"];
    [tester waitForSoftwareKeyboard];
    [tester waitForTimeInterval:0.5];
    [tester enterTextIntoCurrentFirstResponder:@"7"];
    [tester enterTextIntoCurrentFirstResponder:@"8"];
    [tester enterTextIntoCurrentFirstResponder:@"9"];
    [tester enterTextIntoCurrentFirstResponder:@"0"];
    [tester waitForAbsenceOfSoftwareKeyboard];
}

- (void)testAdvancedCreatePasscodeFlow
{
    [self dismissAndResetLock];
    VENTouchLockAppearance *currentAppearance = [VENTouchLock sharedInstance].appearance;
    [tester tapViewWithAccessibilityLabel:@"Set Passcode"];
    [tester waitForSoftwareKeyboard];
    [tester waitForTimeInterval:0.5];
    [tester enterTextIntoCurrentFirstResponder:@"1"];
    [tester enterTextIntoCurrentFirstResponder:@"2"];
    [tester enterTextIntoCurrentFirstResponder:@"3"];
    [tester enterTextIntoCurrentFirstResponder:@"4"];
    [tester waitForViewWithAccessibilityLabel:currentAppearance.createPasscodeConfirmLabelText];
    [tester waitForTimeInterval:0.5];
    [tester enterTextIntoCurrentFirstResponder:@"1"];
    [tester enterTextIntoCurrentFirstResponder:@"2"];
    [tester enterTextIntoCurrentFirstResponder:@"3"];
    [tester enterTextIntoCurrentFirstResponder:@"1"];
    [tester waitForViewWithAccessibilityLabel:currentAppearance.createPasscodeMismatchedLabelText];
    [tester waitForTimeInterval:0.5];
    [tester enterTextIntoCurrentFirstResponder:@"1"];
    [tester enterTextIntoCurrentFirstResponder:@"2"];
    [tester enterTextIntoCurrentFirstResponder:@"3"];
    [tester enterTextIntoCurrentFirstResponder:@"4"];
    [tester waitForViewWithAccessibilityLabel:currentAppearance.createPasscodeConfirmLabelText];
    [tester waitForTimeInterval:0.5];
    [tester enterTextIntoCurrentFirstResponder:@"1"];
    [tester enterTextIntoCurrentFirstResponder:@"2"];
    [tester enterTextIntoCurrentFirstResponder:@"3"];
    [tester enterTextIntoCurrentFirstResponder:@"4"];
    [tester waitForAbsenceOfSoftwareKeyboard];
}

- (void)testAdvancedEnterPasscodeFlow
{
    [self dismissAndResetLock];
    VENTouchLockAppearance *currentAppearance = [VENTouchLock sharedInstance].appearance;
    [[VENTouchLock sharedInstance] setPasscode:@"7890"];
    [tester tapViewWithAccessibilityLabel:@"Show Passcode"];
    [tester waitForSoftwareKeyboard];
    [tester waitForTimeInterval:0.5];
    [tester enterTextIntoCurrentFirstResponder:@"7"];
    [tester enterTextIntoCurrentFirstResponder:@"8"];
    [tester enterTextIntoCurrentFirstResponder:@"9"];
    [tester enterTextIntoCurrentFirstResponder:@"9"];
    [tester waitForViewWithAccessibilityLabel:currentAppearance.enterPasscodeIncorrectLabelText];
    [tester waitForTimeInterval:0.5];
    [tester enterTextIntoCurrentFirstResponder:@"7"];
    [tester enterTextIntoCurrentFirstResponder:@"8"];
    [tester enterTextIntoCurrentFirstResponder:@"9"];
    [tester enterTextIntoCurrentFirstResponder:@"0"];
    [tester waitForAbsenceOfSoftwareKeyboard];
}

- (void)testEnterPasscodeAttemptLimitExceeded
{
    [self performPasscodeAttemptLimitTestWithSplashInNavVC:NO];
    [self performPasscodeAttemptLimitTestWithSplashInNavVC:YES];
}

- (void)performPasscodeAttemptLimitTestWithSplashInNavVC:(BOOL)splashEmbeddedInNavigationController
{
    [self dismissAndResetLock];
    VENTouchLockAppearance *currentAppearance = [VENTouchLock sharedInstance].appearance;
    [[VENTouchLock sharedInstance] setPasscode:@"4567"];
    [self simulateAppBackgroundThenForeground];
    [tester waitForSoftwareKeyboard];
    for (NSUInteger i = 0 ; i < [VENTouchLock sharedInstance].passcodeAttemptLimit; i++) {
        if (i == 0) {
            [tester waitForViewWithAccessibilityLabel:currentAppearance.enterPasscodeInitialLabelText];
        }
        else {
            [tester waitForViewWithAccessibilityLabel:currentAppearance.enterPasscodeIncorrectLabelText];
        }
        [tester waitForTimeInterval:0.5];
        [tester enterTextIntoCurrentFirstResponder:@"5"];
        [tester enterTextIntoCurrentFirstResponder:@"5"];
        [tester enterTextIntoCurrentFirstResponder:@"5"];
        [tester enterTextIntoCurrentFirstResponder:@"5"];
        [tester waitForTimeInterval:1.0];
    }
    [tester waitForAbsenceOfSoftwareKeyboard];
    [tester waitForViewWithAccessibilityLabel:@"Limit Exceeded"];
    [tester tapViewWithAccessibilityLabel:@"OK"];
}


#pragma mark - Helper Methods

- (void)dismissAndResetLock
{
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (viewController.presentedViewController) {
        viewController = viewController.presentedViewController;
        if ([viewController isKindOfClass:[VENTouchLockSplashViewController class]]) {
            VENTouchLockSplashViewController *splashViewController = (VENTouchLockSplashViewController *)viewController;
            [splashViewController dismissWithUnlockSuccess:YES unlockType:VENTouchLockSplashViewControllerUnlockTypePasscode animated:NO];
        }
    }
    [VENTouchLock sharedInstance].backgroundLockVisible = NO;
    [[VENTouchLock sharedInstance] deletePasscode];
}

- (void)simulateAppBackgroundThenForeground
{
    [tester waitForTimeInterval:0.5];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillResignActiveNotification object:nil];
    [tester waitForTimeInterval:0.5];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    [tester waitForTimeInterval:0.5];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
    [tester waitForTimeInterval:0.5];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
}

@end