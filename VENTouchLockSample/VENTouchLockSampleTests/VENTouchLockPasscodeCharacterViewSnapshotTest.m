#import <FBSnapshotTestCase/FBSnapshotTestCase.h>
#import "VENTouchLockPasscodeCharacterView.h"

@interface VENTouchLockPasscodeCharacterViewSnapshotTest : FBSnapshotTestCase

@end

@implementation VENTouchLockPasscodeCharacterViewSnapshotTest

- (void)setUp
{
    [super setUp];
    self.recordMode = NO;
}

- (void)testHyphenCharacterView
{
    VENTouchLockPasscodeCharacterView *characterView = [[VENTouchLockPasscodeCharacterView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    characterView.isEmpty = YES;
    FBSnapshotVerifyView(characterView, nil);
}


- (void)testBulletCharacterView
{
    VENTouchLockPasscodeCharacterView *characterView = [[VENTouchLockPasscodeCharacterView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    characterView.isEmpty = NO;
    FBSnapshotVerifyView(characterView, nil);
}

@end
