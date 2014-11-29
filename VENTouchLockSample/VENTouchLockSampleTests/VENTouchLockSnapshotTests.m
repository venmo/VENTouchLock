#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import "VENTouchLockPasscodeView.h"

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
    VENTouchLockPasscodeView *passcodeView = [[VENTouchLockPasscodeView alloc] initWithTitle:@"Test Title" frame:CGRectMake(0, 0, 300, 300)];
    FBSnapshotVerifyView(passcodeView, nil);
}

@end
