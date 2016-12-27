//
//  AppDelegate.swift
//  VENTouchLockSample-Swift
//
//  Created by Pouria Almassi on 11/12/16.
//  Copyright © 2016 Pouria Almassi. All rights reserved.
//

import UIKit
import VENTouchLock

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Override point for customization after application launch.

        VENTouchLock.sharedInstance().setKeychainService("com.ventouchlock.ventouchlock-sample-swift",
                                                         keychainAccount: "com.ventouchlock.ventouchlock-sample-swift",
                                                         touchIDReason: "Scan your fingerprint to use the app.",
                                                         passcodeAttemptLimit: 5,
                                                         splashViewControllerClass: LockSplashViewController.self)


        return true
    }

}
