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

- (void)testPasscodeViewSnapshot
{
    VENTouchLockPasscodeView *passcodeView;
    for (NSUInteger i = 0; i <= 4; i++) {
        passcodeView = [[VENTouchLockPasscodeView alloc] initWithTitle:@"Test Title" frame:CGRectMake(0, 0, 300, 300)];
        for (NSUInteger j = 0; j < i; j++) {
            VENTouchLockPasscodeCharacterView *characterView = (VENTouchLockPasscodeCharacterView *)passcodeView.characters[j];
            characterView.isEmpty = NO;
        }
        NSString *identifier = [NSString stringWithFormat:@"%@Digits", [@(i) stringValue]];
        FBSnapshotVerifyView(passcodeView, identifier);
    }
}

@end