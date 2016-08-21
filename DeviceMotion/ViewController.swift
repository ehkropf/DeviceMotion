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
        
        motionInfo.delegate = self
        motionInfo.updateInterval = 4.0
        quaternionLabelsToNil()
        accelLabelsToNil()
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
            quaternionLabelsToNil()
            accelLabelsToNil()
            startStopButton?.setTitle("Start", forState: UIControlState.Normal)
        } else { // not running
            isRunning = true
            motionInfo.startDataCapture()
            startStopButton?.setTitle("Stop", forState: UIControlState.Normal)
        }
    }

    func quaternionLabelsToNil() {
        quaternionX?.text = nilNumberString
        quaternionY?.text = nilNumberString
        quaternionZ?.text = nilNumberString
        quaternionW?.text = nilNumberString
    }
    
    func accelLabelsToNil() {
        accelX?.text = nilNumberString
        accelY?.text = nilNumberString
        accelZ?.text = nilNumberString
    }
    
    func updateQuaternionLabels() {
        guard let ra = motionInfo.referenceAttitude else {
            quaternionLabelsToNil()
            return
        }
        quaternionX?.text = ra.quaternion.x.motionString
        quaternionY?.text = ra.quaternion.y.motionString
        quaternionZ?.text = ra.quaternion.z.motionString
        quaternionW?.text = ra.quaternion.w.motionString
    }
    
    func updateAccelLabels() {
        guard let acc = motionInfo.acceleration else {
            return
        }
        accelX?.text = acc.x.motionString
        accelY?.text = acc.y.motionString
        accelZ?.text = acc.z.motionString
    }
    
    //MARK: MotionInfo delegate
    func referenceAttitudeUpdated() {
        guard isRunning else {
            return
        }
        updateQuaternionLabels()
    }
    
    func accelerationUpdated() {
        guard isRunning else {
            return
        }
        updateAccelLabels()
    }
}


























