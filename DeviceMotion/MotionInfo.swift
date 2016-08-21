//
//  MotionInfo.swift
//  DeviceMotion
//
//  Created by Everett Kropf on 19/08/2016.
//  Copyright © 2016 Everett Kropf. All rights reserved.
//

import Foundation
import CoreMotion

/// Singleton encapsulation of CMMotionManager object.
public struct MotionManager {
    /// Singleton instance of motion manager.
    public static var instance = CMMotionManager()
}

extension CMDeviceMotion {
    /// Applies rotation matrix to user acceleration.
    var userAccelerationInReferenceFrame: CMAcceleration {
        let acc = self.userAcceleration
        let rot = self.attitude.rotationMatrix
        
        var accRef = CMAcceleration()
        accRef.x = acc.x*rot.m11 + acc.y*rot.m12 + acc.z*rot.m13
        accRef.y = acc.x*rot.m21 + acc.y*rot.m22 + acc.z*rot.m23
        accRef.z = acc.x*rot.m31 + acc.y*rot.m32 + acc.z*rot.m33
        
        return accRef
    }
}

/**
 MotionInfo delegate for observing. So more of a single observer pattern, really.
 */
protocol MotionInfoDelegate {
    func referenceAttitudeUpdated()
    func accelerationUpdated()
}


/**
 Encapsulate CMDeviceMotion data gathering for reference frame based acceleration data.
 */
class MotionInfo {
    
    /// Update interval in Hertz.
    var updateInterval: Double = 30
    
    /// Attitude at start of updates.
    var referenceAttitude: CMAttitude? {
        didSet {
            delegate?.referenceAttitudeUpdated()
        }
    }
    
    /// Current acceleration measurement.
    var acceleration: CMAcceleration? {
        didSet {
            delegate?.accelerationUpdated()
        }
    }
    
    /// Delegate to recieve updates.
    var delegate: MotionInfoDelegate?
    
    /// Begin updating acceleration data (with resepect to reference frame) with `updateInterval` frequency.
    func startDataCapture() {
        let mm = MotionManager.instance
        guard mm.deviceMotionAvailable else {
            return
        }
        referenceAttitude = mm.deviceMotion?.attitude
        mm.deviceMotionUpdateInterval = NSTimeInterval(1.0/updateInterval)
        mm.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) { deviceMotion, _ in
            guard let dm = deviceMotion else {
                return
            }
            self.acceleration = dm.userAccelerationInReferenceFrame
        }
    }
    
    /// Stop updating acceleration data.
    func stopDataCapture() {
        let mm = MotionManager.instance
        guard mm.deviceMotionAvailable else {
            return
        }
        referenceAttitude = nil
        mm.stopDeviceMotionUpdates()
    }
    
}






























