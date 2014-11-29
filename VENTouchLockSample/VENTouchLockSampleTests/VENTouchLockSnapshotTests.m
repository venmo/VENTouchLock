#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import "VENTouchLockPasscodeView.h"
#import "VENTouchLockPasscodeCharacterView.h"

@interface VENTouchLockSnapshotTests : FBSnapshotTestCase

@end

@implementation VENTouchLockSnapshotTests

- (void)setUp
{
    [super setUp];
    self.recordMode = NO;
}

- (void)testPasscodeViewSnapshotWithZeroDigits
{
    VENTouchLockPasscodeView *passcodeView = [self passcodeViewWithNumberOfDigits:0];
    FBSnapshotVerifyView(passcodeView, nil);
}

- (void)testPasscodeViewSnapshotWithOneDigit
{
    VENTouchLockPasscodeView *passcodeView = [self passcodeViewWithNumberOfDigits:1];
    FBSnapshotVerifyView(passcodeView, nil);
}

- (void)testPasscodeViewSnapshotWithTwoDigits
{
    VENTouchLockPasscodeView *passcodeView = [self passcodeViewWithNumberOfDigits:2];
    FBSnapshotVerifyView(passcodeView, nil);
}

- (void)testPasscodeViewSnapshotWithThreeDigits
{
    VENTouchLockPasscodeView *passcodeView = [self passcodeViewWithNumberOfDigits:3];
    FBSnapshotVerifyView(passcodeView, nil);
}

- (void)testPasscodeViewSnapshotWithFourDigits
{
    VENTouchLockPasscodeView *passcodeView = [self passcodeViewWithNumberOfDigits:4];
    FBSnapshotVerifyView(passcodeView, nil);
}

- (VENTouchLockPasscodeView *)passcodeViewWithNumberOfDigits:(NSUInteger)numberOfDigits
{
    VENTouchLockPasscodeView *passcodeView = [[VENTouchLockPasscodeView alloc] initWithTitle:@"Test Title" frame:CGRectMake(0, 0, 300, 300)];
    for (NSUInteger j = 0; j < numberOfDigits; j++) {
        VENTouchLockPasscodeCharacterView *characterView = (VENTouchLockPasscodeCharacterView *)passcodeView.characters[j];
        characterView.isEmpty = NO;
    }
    return passcodeView;
}

@end