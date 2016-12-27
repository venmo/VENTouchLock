//
//  LockSplashViewController.swift
//  VENTouchLockSample-Swift
//
//  Created by Pouria Almassi on 11/12/16.
//  Copyright © 2016 Pouria Almassi. All rights reserved.
//

import UIKit
import VENTouchLock

class LockSplashViewController: VENTouchLockSplashViewController {

    @IBOutlet weak var touchIDButton: UIButton!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        // treat this view controller as a 'splash screen' presenting it upon resuming the app
        self.setIsSnapshot(true)

        // embed this view controller within a navigation controller
        self.touchLock.appearance().passcodeViewControllerShouldEmbedInNavigationController = true

        self.didFinishWithSuccess = { (success: Bool, unlockType: VENTouchLockSplashViewControllerUnlockType) -> () in
            if success {

                self.touchLock.backgroundLockVisible = false

                switch unlockType {
                case .touchID:
                    print("Unlocked with touch id")

                case .passcode:
                    print("Unlocked with passcode")

                default: ()
                }
            } else {
                let alert = UIAlertController(title: "Limit Exceeded",
                                              message: "You have exceeded the maximum number of passcode attempts",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        touchIDButton.isHidden = !VENTouchLock.canUseTouchID()
    }

    @IBAction func userTappedShowTouchID(_ id: UIButton) {
        showTouchID()
    }

    @IBAction func userTappedEnterPasscode(_ id: UIButton) {
        showPasscode(animated: true)
    }
    
}
