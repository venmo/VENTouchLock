#import "VENTouchLock.h"

//static id mockTouchLock = nil;


//#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
//+ (instancetype)sharedInstance
//{
//    return mockTouchLock;
//}


SpecBegin(VENTouchLock)

beforeAll(^{
    [[VENTouchLock sharedInstance] setKeychainService:@"keychainService"
                                      keychainAccount:@"keychainAccount"
                                        touchIDReason:@"touchIDReason"
                            splashViewControllerClass:NULL
                                 passcodeAttemptLimit:0];
});

describe(@"setPasscode:", ^{


    beforeEach(^{
        [[VENTouchLock sharedInstance] deletePasscode];
    });

    it(@"should register a passcode with VENTouchLock", ^{
        VENTouchLock *touchLock = [VENTouchLock sharedInstance];
        expect([touchLock isPasscodeSet]).to.equal(NO);
        expect([touchLock currentPasscode]).to.beNil();

        [[VENTouchLock sharedInstance] setPasscode:@"testPasscode"];

        expect([touchLock isPasscodeSet]).to.equal(YES);
        expect([touchLock currentPasscode]).to.equal(@"testPasscode");
    });

});

SpecEnd




