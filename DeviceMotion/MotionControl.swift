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

//MARK: Motion facade

/**
 Encapsulate CMDeviceMotion data gathering for reference frame based acceleration data.
 */
class MotionControl {
    
    var available: Bool {
        return MotionManager.instance.deviceMotionAvailable
    }
    
    var deviceMotion: CMDeviceMotion? {
        return MotionManager.instance.deviceMotion
    }
    
    func startDeviceMotion() {
        guard self.available else {
            return
        }
        MotionManager.instance.startDeviceMotionUpdates()
    }
    
    func stopDeviceMotion() {
        guard self.available else {
            return
        }
        MotionManager.instance.stopDeviceMotionUpdates()
    }
}

//MARK: 3D vector

/**
 Define a 3D vector.
 */
struct Vector3 {
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
}

prefix func -(v: Vector3) -> Vector3 {
    return Vector3(x: -v.x, y: -v.y, z: -v.z)
}

func +(v1: Vector3, v2: Vector3) -> Vector3 {
    return Vector3(x: v1.x + v2.x, y: v1.y + v2.y, z: v1.z + v2.z)
}

func -(v1: Vector3, v2: Vector3) -> Vector3 {
    return v1 + -v2
}

func *(s: Double, v: Vector3) -> Vector3 {
    return Vector3(x: s*v.x, y: s*v.y, z: s*v.z)
}

func *(v: Vector3, s: Double) -> Vector3 {
    return s*v
}

func /(v: Vector3, s: Double) -> Vector3 {
    return (1/s)*v
}

extension Vector3 {
    init(_ acc: CMAcceleration) {
        x = acc.x
        y = acc.y
        z = acc.z
    }
    
    var magnitude: Double {
        return sqrt(x*x + y*y + z*z)
    }
}

//MARK: Integral

/**
 Compute the 3D velocity integral bit by bit.
 */
class VelocityIntegral {
    
    var value = Vector3()
    private var _lastAdded: Vector3
    
    init(v0: Vector3) {
        _lastAdded = v0
    }
    
    func reset() {
        value = Vector3()
    }
    
    func add(acceleration acc: CMAcceleration, dt: Double) {
        let va = Vector3(acc)
        let mid = (va + _lastAdded)/2.0
        _lastAdded = va
        value.x += mid.x*dt
        value.y += mid.y*dt
        value.z += mid.z*dt
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
        return _formatter.stringFromNumber(NSNumber(double: integral.value.magnitude))
    }
    
}

extension String {
    init(integral vi: VelocityIntegral) {
        self = VelocityFormatter().toString(vi)!
    }
}




























