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
    /// Default formmated string via `MotionInfoDecimalFormatter`.
    public var motionString: String? {
        return MotionInfoDecimalFormatter.defaultFormatter.stringFromDouble(self)
    }
    
    public func motionString(withFormatter f: MotionInfoDecimalFormatter) -> String? {
        return f.stringFromDouble(self)
    }
}


/**
 MotionInfo delegate for observing. So more of a single observer pattern, really.
 */
protocol MotionInfoDelegate {
    func referenceAttitudeDidChange()
}


/**
 Encapsulate CMDeviceMotion data gathering for reference frame based acceleration data.
 */
class MotionInfo {
    
    var delegate: MotionInfoDelegate?
    var referenceAttitude: CMAttitude? {
        didSet {
            delegate?.referenceAttitudeDidChange()
        }
    }
    
    func startDataCapture() {
        let mm = MotionManager.instance
        referenceAttitude = mm.deviceMotion?.attitude
    }
    
    func stopDataCapture() {
        referenceAttitude = nil
    }
    
}






























