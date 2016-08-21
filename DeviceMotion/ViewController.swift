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
    
    var phoneIntegral: VelocityIntegral!
    var frozenIntegral: VelocityIntegral!
    
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
        
        let dt = 1.0/updateInterval
        phoneIntegral = VelocityIntegral(dt: dt)
        frozenIntegral = VelocityIntegral(dt: dt)
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
            phoneIntegral.reset()
            frozenIntegral.reset()
            updateVelocityLabels()
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
        
        graphPhone?.add(acc.x, acc.y, acc.z)
        phoneIntegral.add(acceleration: acc)
        graphFrozen?.add(aref.x, aref.y, aref.z)
        frozenIntegral.add(acceleration: aref)
        updateVelocityLabels()
    }

    func updateVelocityLabels() {
        labelPhoneVelocity?.text = phoneIntegral.string
        labelFrozenVelocity?.text = frozenIntegral.string
    }
}

extension CMAcceleration {
    var modulus: Double {
        return sqrt(self.x*self.x + self.y*self.y + self.z*self.z)
    }
}

class VelocityIntegral {
    
    var integralValue: [Double] = [0, 0, 0]
    var value: Double {
        let v = integralValue
        return sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2])
    }
    var dt: Double
    
    init(dt: Double) {
        self.dt = dt
    }
    
    func reset() {
        integralValue = [0, 0, 0]
    }
    
    func add(acceleration acc: CMAcceleration) {
        integralValue[0] += acc.x*dt
        integralValue[1] += acc.y*dt
        integralValue[2] += acc.z*dt
    }
    
}

class VelocityFormatter {
    
    var _formatter = NSNumberFormatter()
    
    init() {
        _formatter.numberStyle = .DecimalStyle
        _formatter.minimumIntegerDigits = 1
        _formatter.minimumFractionDigits = 2
        _formatter.maximumFractionDigits = 2
    }
    
    func toString(integral: VelocityIntegral) -> String? {
        return _formatter.stringFromNumber(NSNumber(double: integral.value))
    }
    
}

extension VelocityIntegral {
    var string: String? {
        return VelocityFormatter().toString(self)
    }
}




























