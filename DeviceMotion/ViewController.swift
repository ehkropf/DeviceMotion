//
//  ViewController.swift
//  DeviceMotion
//
//  Created by Everett Kropf on 18/08/2016.
//  Copyright © 2016 Everett Kropf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var timer: NSTimer!
    var updateInterval: Double = 20 // Hertz
    var isRunning = false
    
    //MARK: View outlets
    
    @IBOutlet weak var graphNoReference: GraphView?
    @IBOutlet weak var graphReference: GraphView?
    
    @IBOutlet weak var labelX: UILabel?
    @IBOutlet weak var labelY: UILabel?
    @IBOutlet weak var labelZ: UILabel?
    
    @IBOutlet weak var startStopButton: UIButton?
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelX?.textColor = UIColor(CGColor: GVHelpers.graphXColor)
        labelY?.textColor = UIColor(CGColor: GVHelpers.graphYColor)
        labelZ?.textColor = UIColor(CGColor: GVHelpers.graphZColor)
        
        timer = NSTimer(timeInterval: NSTimeInterval(1.0/updateInterval), target: self, selector: #selector(timerHandler(_:)), userInfo: nil, repeats: true)
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
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
            startStopButton?.setTitle("Start", forState: UIControlState.Normal)
        } else { // not running
            isRunning = true
            timer.invalidate()
            startStopButton?.setTitle("Stop", forState: UIControlState.Normal)
        }
    }
    
    @objc func timerHandler(timer: NSTimer?) {
        // Read motion state and add values to graphs.
    }

}


























