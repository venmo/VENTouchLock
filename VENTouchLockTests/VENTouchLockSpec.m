#import "VENTouchLock.h"

SpecBegin(VENTouchLock)

beforeAll(^{
    [[VENTouchLock sharedInstance] setKeychainService:@"keychainService"
                              keychainPasscodeAccount:@"keychainAccount"
                               keychainTouchIDAccount:@"keychainAccount"
                                        touchIDReason:@"touchIDReason"
                                 passcodeAttemptLimit:0
                            splashViewControllerClass:NULL];
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

    it(@"setting a passcode should reset all prior passcode attempt history", ^{
        VENTouchLock *touchLock = [VENTouchLock sharedInstance];

        [touchLock incrementIncorrectPasscodeAttemptCount];
        [touchLock setPasscode:@"testPasscode"];

        expect([touchLock passcodeAttemptLimit]).to.equal(0);
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
        [[VENTouchLock sharedInstance] setShouldUseTouchID:YES];
        OCMockObject *mockClass = [OCMockObject niceMockForClass:[VENTouchLock class]];
        [[[mockClass stub] andReturnValue:@YES] canUseTouchID];
        [[[mockClass expect] andForwardToRealObject] shouldUseTouchID];
        BOOL shouldUseTouchID =  [[VENTouchLock sharedInstance] shouldUseTouchID];
        expect(shouldUseTouchID).to.equal(YES);
    });

    it(@"should return NO if the device does not support touch ID and the user has setShouldUseTouchID to YES", ^{
        [[VENTouchLock sharedInstance] setShouldUseTouchID:YES];
        OCMockObject *mockClass = [OCMockObject niceMockForClass:[VENTouchLock class]];
        [[[mockClass stub] andReturnValue:@NO] canUseTouchID];
        [[[mockClass expect] andForwardToRealObject] shouldUseTouchID];
        BOOL shouldUseTouchID =  [[VENTouchLock sharedInstance] shouldUseTouchID];
        expect(shouldUseTouchID).to.equal(NO);
    });

    it(@"should return NO if the device supports touch ID and the user has setShouldUseTouchID to NO", ^{
        [[VENTouchLock sharedInstance] setShouldUseTouchID:NO];
        OCMockObject *mockClass = [OCMockObject niceMockForClass:[VENTouchLock class]];
        [[[mockClass stub] andReturnValue:@YES] canUseTouchID];
        [[[mockClass expect] andForwardToRealObject] shouldUseTouchID];
        BOOL shouldUseTouchID =  [[VENTouchLock sharedInstance] shouldUseTouchID];
        expect(shouldUseTouchID).to.equal(NO);
    });

    it(@"should return NO if the device does not support touch ID and the user has setShouldUseTouchID to NO", ^{
        [[VENTouchLock sharedInstance] setShouldUseTouchID:NO];
        OCMockObject *mockClass = [OCMockObject niceMockForClass:[VENTouchLock class]];
        [[[mockClass stub] andReturnValue:@NO] canUseTouchID];
        [[[mockClass expect] andForwardToRealObject] shouldUseTouchID];
        BOOL shouldUseTouchID =  [[VENTouchLock sharedInstance] shouldUseTouchID];
        expect(shouldUseTouchID).to.equal(NO);
    });

});

describe(@"passcodeAttemptCount methods", ^{
    it(@"should increment, reset and read methods correctly", ^{
        VENTouchLock *touchLock = [VENTouchLock sharedInstance];

        [touchLock resetIncorrectPasscodeAttemptCount];
        expect([touchLock numberOfIncorrectPasscodeAttempts]).to.equal(0);
        [touchLock incrementIncorrectPasscodeAttemptCount];
        expect([touchLock numberOfIncorrectPasscodeAttempts]).to.equal(1);
        [touchLock incrementIncorrectPasscodeAttemptCount];
        expect([touchLock numberOfIncorrectPasscodeAttempts]).to.equal(2);
        [touchLock resetIncorrectPasscodeAttemptCount];
        expect([touchLock numberOfIncorrectPasscodeAttempts]).to.equal(0);
    });
});

SpecEnd