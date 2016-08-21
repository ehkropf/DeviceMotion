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

/**
 For converting motion data doubles to strings.
 Note this basically replicates the "%W.Pf" printf format where W is width and P is precision. Nomenclature is likely wrong.
 
 - parameters:
   - width: total width; number of digits to the left of the decimal point is `width - precision - 1`
   - precision: number of digits to the right of the decimal point
 */
public class MotionInfoDecimalFormatter {
    public static let defaultFormatter = MotionInfoDecimalFormatter()
    
    private let _formatter = NSNumberFormatter()
    
    /// Width in "characters".
    public var width = 6 {
        didSet {
            setIntegerLimits()
        }
    }
    /// Digits to the right of the decimal point.
    public var precision = 4 {
        didSet {
            setIntegerLimits()
            setFractionLimits()
        }
    }
    
    public init() {
        _formatter.numberStyle = .DecimalStyle
        setIntegerLimits()
        setFractionLimits()
    }
    
    /// Formatted string version of decimal value.
    public func stringFromDouble(value: Double) -> String? {
        return _formatter.stringFromNumber(NSNumber(double: value))
    }
    
    //MARK: Internal
    
    func setIntegerLimits() {
        let integerDigits = width - precision - 1
        _formatter.minimumIntegerDigits = integerDigits
        _formatter.maximumIntegerDigits = integerDigits
    }
    
    func setFractionLimits() {
        _formatter.minimumFractionDigits = precision
        _formatter.maximumFractionDigits = precision
    }
}

extension Double {
    /// Default formated string via `MotionInfoDecimalFormatter`.
    public var motionString: String? {
        return MotionInfoDecimalFormatter.defaultFormatter.stringFromDouble(self)
    }
    
    // Supply formatter to convert to string.
    public func motionString(withFormatter f: MotionInfoDecimalFormatter) -> String? {
        return f.stringFromDouble(self)
    }
}


extension CMDeviceMotion {
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






























