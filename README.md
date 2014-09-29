VENTouchLock
=============
<!--  [![Build Status](https://travis-ci.org/venmo/VENTouchLock.svg?branch=master)](https://travis-ci.org/venmo/VENTouchLock) -->

VENTouchLock secures your app by requiring a Touch ID fingerprint scan or Passcode to gain access on launch and on background and is used in the Venmo app.

<!-- ![alt text](http://i.imgur.com/a1FfEBi.gif "VENTouchLock demo") -->

Installation
------------
The easiest way to get started is to use [CocoaPods](http://cocoapods.org/). Just add the following line to your Podfile:

```ruby
pod 'VENTouchLock', '~> 1.0'
```

Usage
-----

### 1. Create a Splash view controller
VENTouchLock requires a custom Splash view controller in order to hide the contents of your app during app-switch and present the Touch ID prompt and Passcode view controller. In order to create one, subclass ```VENTouchLockSplashViewController``` and override its ```init``` function with any customization. The Splash view controller is usually a good place to give your users the option to logout in case another user is attempting to sign in.

### 2. Start the framework
Add the VENTouchLock header file to your app delegate. Import this header in any of your implementation files to use the framework.
```obj-c
#import <VENTouchLock/VENTouchLock.h>
```
Add the following code to initialize VENTouchLock in your app delegate's ```application:didFinishLaunchingWithOptions:``` method.
```obj-c
[[VENTouchLock sharedInstance] setKeychainService:@"KEYCHAIN_SERVICE_NAME"
								  keychainAccount:@"KEYCHAIN_ACCOUNT_NAME"
                                    touchIDReason:@"TOUCHID_REASON"
                             passcodeAttemptLimit:ATTEMPT_LIMIT
                        splashViewControllerClass:[CUSTOM_SPLASH_VIEW_CONTROLLER class]];
```

* `KEYCHAIN_SERVICE_NAME`: A service name used to set and return a passcode from Apple's Keychain Services interface.
* `KEYCHAIN_ACCOUNT_NAME`: An account name used to set and return a passcode from Apple's Keychain Services interface.
* `TOUCHID_REASON`: A message displayed on the Touch ID prompt.
* `ATTEMPT_LIMIT`: The maximum number of passcode attempts before the splash view controller fails to authenticate (Your app should logout when the user reaches this limit)
* `CUSTOM_SPLASH_VIEW_CONTROLLER`: The name of the ```VENTouchLockSplashViewController``` subclass.

### 3. Set a Passcode
In order for your users to enable Touch ID and / or Passcode, they must set a passcode. In the Venmo app, this option is in the settings page. To let your users create a passcode, use a ```VENTouchLockSetPasscodeViewController```.

### 4. Enable Touch ID
If the user's device supports Touch ID (ie. ```[VENTouchLock canUseTouchID]``` returns ```YES```), after setting a passcode prompt, the user with the option to unlock with Touch ID. Set their preference with the VENTouchLock class method ```setShouldUseTouchID:(BOOL)preference``` 

Sample Project
--------------
Check out the [sample project](https://github.com/venmo/VENTouchLock/tree/master/VENTouchLockSample) in this repo for sample usage.

Contributing
------------

We'd love to see your ideas for improving this library! The best way to contribute is by submitting a pull request. We'll do our best to respond to your patch as soon as possible. You can also submit a [new Github issue](https://github.com/venmo/VENTouchLock/issues/new) if you find bugs or have questions. :octocat:

Please make sure to follow our general coding style and add test coverage for new features!
