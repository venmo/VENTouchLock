#import "UIViewController+VENTouchLock.h"

SpecBegin(UIViewControllerSpec)

describe(@"ven_embeddedInNavigationController", ^{

    it(@"should return a navigation controller with the reciever as the first view controller", ^{
        UIViewController *testViewController = [UIViewController new];
        UINavigationController *navigationController = [testViewController ventouchlock_embeddedInNavigationController];
        expect([navigationController.viewControllers firstObject]).to.equal(testViewController);
    });
    
});

SpecEnd