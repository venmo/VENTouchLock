//
//  ViewController.swift
//  VENTouchLockSample-Swift
//
//  Created by Pouria Almassi on 11/12/16.
//  Copyright © 2016 Pouria Almassi. All rights reserved.
//

import UIKit
import VENTouchLock

class ViewController: UIViewController {

    @IBOutlet weak var touchIDSwitch: UISwitch!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureTouchIDToggle()
    }

    func configureTouchIDToggle() {
        touchIDSwitch.isEnabled = VENTouchLock.sharedInstance().isPasscodeSet() && VENTouchLock.canUseTouchID()
        touchIDSwitch.isOn = VENTouchLock.shouldUseTouchID()
    }

    @IBAction func userTappedSetPasscode(_ sender: UIButton) {
        if VENTouchLock.sharedInstance().isPasscodeSet() {
            let alert = UIAlertController(title: "Passcode already exists",
                                          message: "To set a new one, first delete the existing one",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            let createPasscodeVC = VENTouchLockCreatePasscodeViewController()
            present(createPasscodeVC, animated: true, completion: nil)
        }
    }

    @IBAction func userTappedShowPasscode(_ sender: UIButton) {
        if VENTouchLock.sharedInstance().isPasscodeSet() {
            let showPasscodeVC = VENTouchLockEnterPasscodeViewController()
            present(showPasscodeVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "No passcode",
                                          message: "Please set a passcode first",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func userTappedDeletePasscode(_ sender: UIButton) {
        if VENTouchLock.sharedInstance().isPasscodeSet() {
            VENTouchLock.sharedInstance().deletePasscode()
        } else {
            let alert = UIAlertController(title: "No passcode",
                                          message: nil,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)

        }
    }

    @IBAction func userTappedSwitch(_ sender: UISwitch) {
        VENTouchLock.setShouldUseTouchID(sender.isOn)
    }

}
