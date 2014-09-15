#import "VENTouchLockEnterPasscodeViewController.h"
#import "VENTouchLock.h"

static id mockTouchLock = nil;

@implementation VENTouchLock (UnitTests)

#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
+ (instancetype)sharedInstance
{
    return mockTouchLock;
}

@end

@interface VENTouchLockEnterPasscodeViewController (UnitTests)

extern NSString *const VENTouchLockEnterPasscodeUserDefaultsKeyNumberOfConsecutivePasscodeAttempts;

- (void)recordIncorrectPasscodeAttempt;

- (void)callExceededLimitActionBlock;

@end

SpecBegin(VENTouchLockEnterPasscode)

describe(@"resetPasscodeAttemptHistory:", ^{

    afterEach(^{
        NSDictionary *defaultsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
        for (NSString *key in [defaultsDictionary allKeys]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    });

    it(@"should set passcode attempt history to 0", ^{
        [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:VENTouchLockEnterPasscodeUserDefaultsKeyNumberOfConsecutivePasscodeAttempts];
        [VENTouchLockEnterPasscodeViewController resetPasscodeAttemptHistory];
        NSUInteger afterAttemptHistory = [[NSUserDefaults standardUserDefaults] integerForKey:VENTouchLockEnterPasscodeUserDefaultsKeyNumberOfConsecutivePasscodeAttempts];
        expect(afterAttemptHistory).to.equal(0);
    });

});

describe(@"recordIncorrectPasscodeAttempt", ^{

    __block id mockEnterPasscodeVC;

    beforeEach(^{
        mockTouchLock = [OCMockObject mockForClass:[VENTouchLock class]];
        [[[mockTouchLock stub] andReturnValue:OCMOCK_VALUE((NSUInteger){3})] passcodeAttemptLimit];
        VENTouchLockEnterPasscodeViewController *enterPasscodeVC = [[VENTouchLockEnterPasscodeViewController alloc] init];
        mockEnterPasscodeVC = [OCMockObject partialMockForObject:enterPasscodeVC];
    });

    afterEach(^{
        mockTouchLock = nil;
    });

    it(@"should not call callExceededLimitActionBlock when incorrectPasscodeAttempt < passcodeAttemptLimit", ^{
               [[mockEnterPasscodeVC reject] callExceededLimitActionBlock];
        [mockEnterPasscodeVC recordIncorrectPasscodeAttempt];
        [mockEnterPasscodeVC recordIncorrectPasscodeAttempt];
        [mockEnterPasscodeVC verify];
    });

    it(@"should call callExceededLimitActionBlock when incorrectPasscodeAttempt = passcodeAttemptLimit", ^{
        VENTouchLockEnterPasscodeViewController *enterPasscodeVC = [[VENTouchLockEnterPasscodeViewController alloc] init];
        id mockEnterPasscodeVC = [OCMockObject partialMockForObject:enterPasscodeVC];
        [mockEnterPasscodeVC recordIncorrectPasscodeAttempt];
        [mockEnterPasscodeVC recordIncorrectPasscodeAttempt];

        [[mockEnterPasscodeVC expect] callExceededLimitActionBlock];
        [mockEnterPasscodeVC recordIncorrectPasscodeAttempt];
        [mockEnterPasscodeVC verify];
    });

    it(@"should call callExceededLimitActionBlock when incorrectPasscodeAttempt > passcodeAttemptLimit", ^{
        VENTouchLockEnterPasscodeViewController *enterPasscodeVC = [[VENTouchLockEnterPasscodeViewController alloc] init];
        id mockEnterPasscodeVC = [OCMockObject partialMockForObject:enterPasscodeVC];
        [mockEnterPasscodeVC recordIncorrectPasscodeAttempt];
        [mockEnterPasscodeVC recordIncorrectPasscodeAttempt];

        [[mockEnterPasscodeVC expect] callExceededLimitActionBlock];
        [mockEnterPasscodeVC recordIncorrectPasscodeAttempt];
        [mockEnterPasscodeVC verify];

        [[mockEnterPasscodeVC expect] callExceededLimitActionBlock];
        [mockEnterPasscodeVC recordIncorrectPasscodeAttempt];
        [mockEnterPasscodeVC verify];
    });

});

afterAll(^{
    mockTouchLock = [[VENTouchLock alloc] init]; // Restore [VENTouchLock sharedInstance] natural behavior
});

SpecEnd