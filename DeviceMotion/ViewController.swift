//
//  ViewController.swift
//  DeviceMotion
//
//  Created by Everett Kropf on 18/08/2016.
//  Copyright © 2016 Everett Kropf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let motionInfo = MotionInfo()
    let nilNumberString = "-.----"
    var isRunning = false
    
    //MARK: View outlets
    
    @IBOutlet weak var quaternionX: UILabel?
    @IBOutlet weak var quaternionY: UILabel?
    @IBOutlet weak var quaternionZ: UILabel?
    @IBOutlet weak var quaternionW: UILabel?
    
    @IBOutlet weak var accelX: UILabel?
    @IBOutlet weak var accelY: UILabel?
    @IBOutlet weak var accelZ: UILabel?
    
    @IBOutlet weak var startStopButton: UIButton?
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberLabelsToNil()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // If running, resume data collection.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause data collection.
    }

    //MARK: Doing things
    
    @IBAction func startStopTap() {
        if isRunning {
            // Stop collecting data.
            
            numberLabelsToNil()
            startStopButton?.setTitle("Start", forState: UIControlState.Normal)
            isRunning = false
        } else { // not running
            // Start collecting data.
            
            startStopButton?.setTitle("Stop", forState: UIControlState.Normal)
            isRunning = true
        }
    }

    func numberLabelsToNil() {
        quaternionX?.text = nilNumberString
        quaternionY?.text = nilNumberString
        quaternionZ?.text = nilNumberString
        quaternionW?.text = nilNumberString
        accelX?.text = nilNumberString
        accelY?.text = nilNumberString
        accelZ?.text = nilNumberString
    }
    
    func updateQuaternionLabels() {
        // Get label strings from MotionInfo object.
//        quaternionX?.text = motionInfo.referenceFrameX.string
//        quaternionY?.text = ?
//        quaternionZ?.text = ?
//        quaternionW?.text = ?
    }
    
    func updateAccelLabels() {
        // Get label strings from MotionInfo object.
//        accelX?.text = MotionInfo.accelX.string
//        accelY?.text = MotionInfo.accelX.string
//        accelZ?.text = MotionInfo.accelX.string
    }
}


























