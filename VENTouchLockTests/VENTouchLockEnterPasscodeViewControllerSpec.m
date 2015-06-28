#import "VENTouchLockEnterPasscodeViewController.h"
#import "VENTouchLock.h"

@interface VENTouchLockEnterPasscodeViewController (UnitTests)

extern NSString *const VENTouchLockEnterPasscodeUserDefaultsKeyNumberOfConsecutivePasscodeAttempts;

- (void)recordIncorrectPasscodeAttempt;

- (void)callExceededLimitActionBlock;

@end

SpecBegin(VENTouchLockEnterPasscode)


describe(@"recordIncorrectPasscodeAttempt", ^{

    __block id mockEnterPasscodeVC;
    __block VENTouchLock *touchLock;

    beforeEach(^{
        touchLock = [[VENTouchLock alloc] init];
        [touchLock setKeychainService:@"testService"
              keychainPasscodeAccount:@"testPasscodeAccount"
               keychainTouchIDAccount:@"testTouchIDAccount"
                        touchIDReason:@"testReason"
                 passcodeAttemptLimit:3
            splashViewControllerClass:[VENTouchLockSplashViewController class]];

        VENTouchLockEnterPasscodeViewController *enterPasscodeVC = [[VENTouchLockEnterPasscodeViewController alloc] init];
        enterPasscodeVC.touchLock = touchLock;
        mockEnterPasscodeVC = [OCMockObject partialMockForObject:enterPasscodeVC];
        [touchLock resetIncorrectPasscodeAttemptCount];
    });

    afterEach(^{
        touchLock = nil;
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

SpecEnd