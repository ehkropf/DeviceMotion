//
//  ViewController.swift
//  DeviceMotion
//
//  Created by Everett Kropf on 18/08/2016.
//  Copyright © 2016 Everett Kropf. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    //MARK: Lifecycle
    
    @IBOutlet weak var labelX: UILabel?
    @IBOutlet weak var labelY: UILabel?
    @IBOutlet weak var labelZ: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        methodPicker?.delegate = self
        methodPicker?.dataSource = self
        
        labelX?.textColor = UIColor(CGColor: GVHelpers.graphXColor)
        labelY?.textColor = UIColor(CGColor: GVHelpers.graphYColor)
        labelZ?.textColor = UIColor(CGColor: GVHelpers.graphZColor)
        
        velocityLabel?.setFromVelocity(nil, measure: "m/s")
        
        if !motionControl.available {
            startStopButton?.enabled = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        pickerViewSetHidden(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isRunning {
            startStopTap()
        }
    }

    //MARK: Doing things
    
    let motionControl = MotionControl()
    var timer: NSTimer?
    var updateFrequency: Double = 60 // Hertz
    var isRunning = false
    
    var velocityIntegral: VelocityIntegral?
    var tic: Double = 0.0
    
    @IBOutlet weak var graphView: GraphView?
    @IBOutlet weak var startStopButton: UIButton?
    @IBOutlet weak var velocityLabel: UILabel?
    
    @IBAction func startStopTap() {
        if isRunning {
            stopMeasuring()
            isRunning = false
            startStopButton?.setTitle("Start", forState: UIControlState.Normal)
        } else { // not running
            startMeasuring()
            isRunning = true
            startStopButton?.setTitle("Stop", forState: UIControlState.Normal)
        }
    }
    
    func startMeasuring() {
        motionControl.startDeviceMotion()
        velocityIntegral = VelocityIntegral(v0: Vector3(getAcceleration()))
        timer = NSTimer(timeInterval: NSTimeInterval(1.0/updateFrequency), target: self, selector: #selector(ViewController.timerHandler(_:)), userInfo: nil, repeats: true)
        tic = CACurrentMediaTime()
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
    }
    
    func stopMeasuring() {
        timer?.invalidate()
        velocityIntegral = nil
        motionControl.stopDeviceMotion()
    }
    
    func getAcceleration() -> CMAcceleration {
        var acc = CMAcceleration()
        guard let dm = motionControl.deviceMotion, index = methodPicker?.selectedRowInComponent(0) else {
            return acc
        }
        switch methodList[index] {
        case .PhoneMovingFrame:
            acc = dm.userAcceleration
        case .Time0Frame:
            acc = dm.userAccelerationInReferenceFrame
        }
        return acc
    }
    
    @objc func timerHandler(timer: NSTimer?) {
        let acc = getAcceleration()
        let toc = CACurrentMediaTime()
        velocityIntegral?.add(acceleration: acc, dt: toc - tic)
        tic = toc
        graphView?.add(acc.x, acc.y, acc.z)
        velocityLabel?.setFromVelocity(velocityIntegral?.value.magnitude, measure: "m/s")
    }
    
    
    //MARK: Method picker management
    
    enum MeasurementMethod: String {
        case PhoneMovingFrame = "Phone moving frame"
        case Time0Frame = "t0 frame"
    }
    
    let methodList: [MeasurementMethod] = [.Time0Frame, .PhoneMovingFrame]
    
    @IBOutlet weak var methodPickerView: UIView?
    @IBOutlet weak var methodPicker: UIPickerView?
    @IBOutlet weak var methodButton: UIButton?
    
    @IBAction func methodButtonTap() {
        if let hidden = methodPickerView?.hidden {
            pickerViewSetHidden(!hidden)
        }
    }
    
    @IBAction func pickerDoneTap() {
        pickerViewSetHidden(true)
    }
    
    func updateMethodButtonLabel() {
        if let index = methodPicker?.selectedRowInComponent(0) {
            methodButton?.setTitle(methodList[index].rawValue, forState: .Normal)
        }
    }
    
    func pickerViewSetHidden(hidden: Bool, animated: Bool = true) {
        layoutIfNeeded(animated) {
            if hidden {
                self.updateMethodButtonLabel()
            }
            if let subviews = self.methodPickerView?.subviews {
                for view in subviews {
                    view.hidden = hidden
                }
            }
            self.methodPickerView?.hidden = hidden
        }
    }

    func layoutIfNeeded(animated: Bool, block: () -> Void) {
        if animated {
            UIView.animateWithDuration(0.25) {
                block()
            }
        } else {
            block()
        }
    }
    
    //MARK: Picker delegate stuff
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component > 0 {
            return nil
        }
        return methodList[row].rawValue
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component > 0 {
            return 0
        }
        return methodList.count
    }
}

//MARK: Number formatting

extension UILabel {
    func setFromVelocity(value: Double?, measure: String) {
        var str: String?
        if let v = value {
            str = VelocityFormatter().toString(v)
        } else {
            str = VelocityFormatter.nilValue
        }
        self.text = str! + " " + measure
    }
}

class VelocityFormatter {
    
    static let nilValue = "-.-"
    
    var _formatter = NSNumberFormatter()
    
    init() {
        _formatter.numberStyle = .DecimalStyle
        _formatter.minimumIntegerDigits = 1
        _formatter.minimumFractionDigits = 1
        _formatter.maximumFractionDigits = 1
    }
    
    func toString(value: Double) -> String {
        return _formatter.stringFromNumber(NSNumber(double: value)) ?? VelocityFormatter.nilValue
    }
    
}
