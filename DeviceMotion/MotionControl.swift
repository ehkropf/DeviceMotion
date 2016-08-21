//
//  MotionInfo.swift
//  DeviceMotion
//
//  Created by Everett Kropf on 19/08/2016.
//  Copyright © 2016 Everett Kropf. All rights reserved.
//

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
        accRef.x = acc.x*rot.m11 + acc.y*rot.m21 + acc.z*rot.m31
        accRef.y = acc.x*rot.m12 + acc.y*rot.m22 + acc.z*rot.m23
        accRef.z = acc.x*rot.m13 + acc.y*rot.m23 + acc.z*rot.m33
        
        return accRef
    }
}

/**
 Encapsulate CMDeviceMotion data gathering for reference frame based acceleration data.
 */
class MotionControl {
    
    var deviceMotion: CMDeviceMotion? {
        return MotionManager.instance.deviceMotion
    }
    
    func startDeviceMotion() {
        let mm = MotionManager.instance
        guard mm.deviceMotionAvailable else {
            return
        }
        mm.startDeviceMotionUpdates()
    }
    
    func stopDeviceMotion() {
        let mm = MotionManager.instance
        guard mm.deviceMotionAvailable else {
            return
        }
        mm.stopDeviceMotionUpdates()
    }
}






























