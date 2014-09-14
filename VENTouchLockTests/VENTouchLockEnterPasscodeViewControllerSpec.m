#import "VENTouchLockEnterPasscodeViewController.h"

@interface VENTouchLockEnterPasscodeViewController (Internal)

extern NSString *const VENTouchLockEnterPasscodeUserDefaultsKeyNumberOfConsecutivePasscodeAttempts;

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

SpecEnd
