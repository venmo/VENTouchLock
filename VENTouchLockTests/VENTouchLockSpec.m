#import "VENTouchLock.h"

SpecBegin(VENTouchLock)

__block VENTouchLock *touchLock;

beforeAll(^{
    touchLock = [[VENTouchLock alloc] init];

    [touchLock setKeychainService:@"keychainService"
          keychainPasscodeAccount:@"keychainAccount"
           keychainTouchIDAccount:@"keychainAccount"
                    touchIDReason:@"touchIDReason"
             passcodeAttemptLimit:0];
});

beforeEach(^{
    [touchLock deletePasscode];
});

describe(@"setPasscode:", ^{

    it(@"should register a passcode with VENTouchLock", ^{
        expect([touchLock isPasscodeSet]).to.equal(NO);
        expect([touchLock currentPasscode]).to.beNil();

        [touchLock setPasscode:@"testPasscode"];

        expect([touchLock isPasscodeSet]).to.equal(YES);
        expect([touchLock currentPasscode]).to.equal(@"testPasscode");
    });

    it(@"setting a passcode should reset all prior passcode attempt history", ^{
        [touchLock incrementIncorrectPasscodeAttemptCount];
        [touchLock setPasscode:@"testPasscode"];

        expect([touchLock passcodeAttemptLimit]).to.equal(0);
    });

});

describe(@"isPasscodeValid", ^{

    it(@"should return YES if the parameter sent is equal to the set passcode and NO otherwise", ^{
        [touchLock setPasscode:@"testPasscode"];
        expect([touchLock isPasscodeValid:@"testPasscode"]).to.equal(YES);
        expect([touchLock isPasscodeValid:@"wrongPasscode"]).to.equal(NO);
    });

});

describe(@"deletePasscode", ^{

    it(@"should register a passcode with VENTouchLock", ^{
        [touchLock setPasscode:@"testPasscode"];
        expect([touchLock isPasscodeSet]).to.equal(YES);
        expect([touchLock currentPasscode]).to.equal(@"testPasscode");

        [touchLock deletePasscode];

        expect([touchLock isPasscodeSet]).to.equal(NO);
        expect([touchLock currentPasscode]).to.beNil();
    });

});

describe(@"shouldUseTouchID", ^{

    it(@"should return YES if the device supports touch ID and the user has setShouldUseTouchID to YES", ^{
        [touchLock setShouldUseTouchID:YES];
        OCMockObject *mockClass = [OCMockObject niceMockForClass:[VENTouchLock class]];
        [[[mockClass stub] andReturnValue:@YES] canUseTouchID];
        [[[mockClass expect] andForwardToRealObject] shouldUseTouchID];
        BOOL shouldUseTouchID =  [touchLock shouldUseTouchID];
        expect(shouldUseTouchID).to.equal(YES);
    });

    it(@"should return NO if the device does not support touch ID and the user has setShouldUseTouchID to YES", ^{
        [touchLock setShouldUseTouchID:YES];
        OCMockObject *mockClass = [OCMockObject niceMockForClass:[VENTouchLock class]];
        [[[mockClass stub] andReturnValue:@NO] canUseTouchID];
        [[[mockClass expect] andForwardToRealObject] shouldUseTouchID];
        BOOL shouldUseTouchID =  [touchLock shouldUseTouchID];
        expect(shouldUseTouchID).to.equal(NO);
    });

    it(@"should return NO if the device supports touch ID and the user has setShouldUseTouchID to NO", ^{
        [touchLock setShouldUseTouchID:NO];
        OCMockObject *mockClass = [OCMockObject niceMockForClass:[VENTouchLock class]];
        [[[mockClass stub] andReturnValue:@YES] canUseTouchID];
        [[[mockClass expect] andForwardToRealObject] shouldUseTouchID];
        BOOL shouldUseTouchID =  [touchLock shouldUseTouchID];
        expect(shouldUseTouchID).to.equal(NO);
    });

    it(@"should return NO if the device does not support touch ID and the user has setShouldUseTouchID to NO", ^{
        [touchLock setShouldUseTouchID:NO];
        OCMockObject *mockClass = [OCMockObject niceMockForClass:[VENTouchLock class]];
        [[[mockClass stub] andReturnValue:@NO] canUseTouchID];
        [[[mockClass expect] andForwardToRealObject] shouldUseTouchID];
        BOOL shouldUseTouchID =  [touchLock shouldUseTouchID];
        expect(shouldUseTouchID).to.equal(NO);
    });

});

describe(@"passcodeAttemptCount methods", ^{
    it(@"should increment, reset and read methods correctly", ^{
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