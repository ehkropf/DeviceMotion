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

extension String {
    init(integral vi: VelocityIntegral) {
        self = VelocityFormatter().toString(vi)!
    }
}




























