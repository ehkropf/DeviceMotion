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

    let motionControl = MotionControl()
    
    var timer: NSTimer?
    var updateFrequency: Double = 30 // Hertz
    var isRunning = false
    
    //MARK: View outlets
    
    @IBOutlet weak var labelX: UILabel?
    @IBOutlet weak var labelY: UILabel?
    @IBOutlet weak var labelZ: UILabel?
    
    @IBOutlet weak var startStopButton: UIButton?
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        methodPicker?.delegate = self
        methodPicker?.dataSource = self
        
        labelX?.textColor = UIColor(CGColor: GVHelpers.graphXColor)
        labelY?.textColor = UIColor(CGColor: GVHelpers.graphYColor)
        labelZ?.textColor = UIColor(CGColor: GVHelpers.graphZColor)
        
//        let dt = 1.0/updateFrequency
        
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
    
    @IBAction func startStopTap() {
        if isRunning {
            
            isRunning = false
            timer?.invalidate()
            motionControl.stopDeviceMotion()
            startStopButton?.setTitle("Start", forState: UIControlState.Normal)
            
        } else { // not running
            
            isRunning = true
            motionControl.startDeviceMotion()
            timer = NSTimer(timeInterval: NSTimeInterval(1.0/updateFrequency), target: self, selector: #selector(timerHandler(_:)), userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
            startStopButton?.setTitle("Stop", forState: UIControlState.Normal)
            
        }
    }
    
    @objc func timerHandler(timer: NSTimer?) {
//        guard let dm = motionControl.deviceMotion else {
//            return
//        }
//        let acc = dm.userAcceleration
//        let aref = dm.userAccelerationInReferenceFrame
        
    }
    
    
    //MARK: Method picker management
    
    enum MeasurementMethod: String {
        case PhoneMovingFrame = "Phone moving frame"
        case Time0Frame = "t0 frame"
    }
    
    let methodList: [MeasurementMethod] = [.PhoneMovingFrame, .Time0Frame]
    
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




























