#import "VENTouchLock.h"

SpecBegin(VENTouchLock)

beforeAll(^{
    [[VENTouchLock sharedInstance] setKeychainService:@"keychainService"
                                      keychainAccount:@"keychainAccount"
                                        touchIDReason:@"touchIDReason"
                            splashViewControllerClass:NULL
                                 passcodeAttemptLimit:0];
});

beforeEach(^{
    [[VENTouchLock sharedInstance] deletePasscode];
});

describe(@"setPasscode:", ^{

    it(@"should register a passcode with VENTouchLock", ^{
        VENTouchLock *touchLock = [VENTouchLock sharedInstance];
        expect([touchLock isPasscodeSet]).to.equal(NO);
        expect([touchLock currentPasscode]).to.beNil();

        [[VENTouchLock sharedInstance] setPasscode:@"testPasscode"];

        expect([touchLock isPasscodeSet]).to.equal(YES);
        expect([touchLock currentPasscode]).to.equal(@"testPasscode");
    });

});

describe(@"isPasscodeValid", ^{

    it(@"should return YES if the parameter sent is equal to the set passcode and NO otherwise", ^{
        VENTouchLock *touchLock = [VENTouchLock sharedInstance];
        [touchLock setPasscode:@"testPasscode"];
        expect([touchLock isPasscodeValid:@"testPasscode"]).to.equal(YES);
        expect([touchLock isPasscodeValid:@"wrongPasscode"]).to.equal(NO);
    });

});

describe(@"deletePasscode", ^{

    it(@"should register a passcode with VENTouchLock", ^{
        VENTouchLock *touchLock = [VENTouchLock sharedInstance];

        [[VENTouchLock sharedInstance] setPasscode:@"testPasscode"];
        expect([touchLock isPasscodeSet]).to.equal(YES);
        expect([touchLock currentPasscode]).to.equal(@"testPasscode");

        [touchLock deletePasscode];

        expect([touchLock isPasscodeSet]).to.equal(NO);
        expect([touchLock currentPasscode]).to.beNil();
    });

});

describe(@"shouldUseTouchID", ^{

    it(@"should return YES if the device supports touch ID and the user has setShouldUseTouchID to YES", ^{
        [VENTouchLock setShouldUseTouchID:YES];
        OCMockObject *mockClass = [OCMockObject niceMockForClass:[VENTouchLock class]];
        [[[mockClass stub] andReturnValue:@YES] canUseTouchID];
        [[[mockClass expect] andForwardToRealObject] shouldUseTouchID];
        BOOL shouldUseTouchID =  [VENTouchLock shouldUseTouchID];
        expect(shouldUseTouchID).to.equal(YES);
    });

    it(@"should return NO if the device does not support touch ID and the user has setShouldUseTouchID to YES", ^{
        [VENTouchLock setShouldUseTouchID:YES];
        OCMockObject *mockClass = [OCMockObject niceMockForClass:[VENTouchLock class]];
        [[[mockClass stub] andReturnValue:@NO] canUseTouchID];
        [[[mockClass expect] andForwardToRealObject] shouldUseTouchID];
        BOOL shouldUseTouchID =  [VENTouchLock shouldUseTouchID];
        expect(shouldUseTouchID).to.equal(NO);
    });

    it(@"should return NO if the device supports touch ID and the user has setShouldUseTouchID to NO", ^{
        [VENTouchLock setShouldUseTouchID:NO];
        OCMockObject *mockClass = [OCMockObject niceMockForClass:[VENTouchLock class]];
        [[[mockClass stub] andReturnValue:@YES] canUseTouchID];
        [[[mockClass expect] andForwardToRealObject] shouldUseTouchID];
        BOOL shouldUseTouchID =  [VENTouchLock shouldUseTouchID];
        expect(shouldUseTouchID).to.equal(NO);
    });

    it(@"should return NO if the device does not support touch ID and the user has setShouldUseTouchID to NO", ^{
        [VENTouchLock setShouldUseTouchID:NO];
        OCMockObject *mockClass = [OCMockObject niceMockForClass:[VENTouchLock class]];
        [[[mockClass stub] andReturnValue:@NO] canUseTouchID];
        [[[mockClass expect] andForwardToRealObject] shouldUseTouchID];
        BOOL shouldUseTouchID =  [VENTouchLock shouldUseTouchID];
        expect(shouldUseTouchID).to.equal(NO);
    });

});

SpecEnd