//
//  ViewController.swift
//  DeviceMotion
//
//  Created by Everett Kropf on 18/08/2016.
//  Copyright © 2016 Everett Kropf. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    let motionControl = MotionControl()
    var timer: NSTimer?
    var updateInterval: Double = 30 // Hertz
    var isRunning = false
    
    //MARK: View outlets
    
    @IBOutlet weak var graphPhone: GraphView?
    @IBOutlet weak var graphFrozen: GraphView?
    
    @IBOutlet weak var labelX: UILabel?
    @IBOutlet weak var labelY: UILabel?
    @IBOutlet weak var labelZ: UILabel?
    
    @IBOutlet weak var labelPhoneVelocity: UILabel?
    @IBOutlet weak var labelFrozenVelocity: UILabel?
    
    @IBOutlet weak var startStopButton: UIButton?
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelX?.textColor = UIColor(CGColor: GVHelpers.graphXColor)
        labelY?.textColor = UIColor(CGColor: GVHelpers.graphYColor)
        labelZ?.textColor = UIColor(CGColor: GVHelpers.graphZColor)
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
            timer?.invalidate()
            motionControl.stopDeviceMotion()
            startStopButton?.setTitle("Start", forState: UIControlState.Normal)
        } else { // not running
            isRunning = true
            motionControl.startDeviceMotion()
            timer = NSTimer(timeInterval: NSTimeInterval(1.0/updateInterval), target: self, selector: #selector(timerHandler(_:)), userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
            startStopButton?.setTitle("Stop", forState: UIControlState.Normal)
        }
    }
    
    @objc func timerHandler(timer: NSTimer?) {
        guard let dm = motionControl.deviceMotion else {
            return
        }
        let acc = dm.userAcceleration
        let aref = dm.userAccelerationInReferenceFrame
        
        graphFrozen?.add(acc.x, acc.y, acc.z)
        graphPhone?.add(aref.x, aref.y, aref.z)
    }

}

extension CMAcceleration {
    var modulus: Double {
        return sqrt(self.x*self.x + self.y*self.y + self.z*self.z)
    }
}

class VelocityIntegral {
    
    var value: Double = 0
    var dt: Double
    
    init(dt: Double) {
        self.dt = dt
    }
    
    func add(acceleration acc: CMAcceleration) {
        value += acc.modulus*dt
    }
    
}
























