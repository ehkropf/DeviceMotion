//
//  ViewController.swift
//  DeviceMotion
//
//  Created by Everett Kropf on 18/08/2016.
//  Copyright © 2016 Everett Kropf. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MotionInfoDelegate {

    let motionInfo = MotionInfo()
    var isRunning = false
    
    //MARK: View outlets
    
    @IBOutlet weak var startStopButton: UIButton?
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        motionInfo.delegate = self
        motionInfo.updateInterval = 4.0
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isRunning {
            startStopTap()
        }
    }

    //MARK: Doing things
    
    @IBAction func startStopTap() {
        if isRunning {
            isRunning = false
            motionInfo.stopDataCapture()
            startStopButton?.setTitle("Start", forState: UIControlState.Normal)
        } else { // not running
            isRunning = true
            motionInfo.startDataCapture()
            startStopButton?.setTitle("Stop", forState: UIControlState.Normal)
        }
    }

    //MARK: MotionInfo delegate
    func referenceAttitudeUpdated() {
        guard isRunning else {
            return
        }
    }
    
    func accelerationUpdated() {
        guard isRunning else {
            return
        }
    }
}


























