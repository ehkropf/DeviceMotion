//
//  GraphView.swift
//  Motionater
//
//  Created by Everett Kropf on 02/01/2016.
//  Copyright © 2016 Everett Kropf. All rights reserved.
//

import UIKit

//------------------------------------------------------------------
// MARK: Drawing helpers

struct GVHelpers {
    
    static var graphBackgroundColor: CGColorRef {
        return UIColor.whiteColor().CGColor
    }
    
    static var graphLineColor: CGColorRef {
        return UIColor(white: 0.7, alpha: 1.0).CGColor
    }
    
    static var graphXColor: CGColorRef {
        return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
    }
    
    static var graphYColor: CGColorRef {
        return UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0).CGColor
    }
    
    static var graphZColor: CGColorRef {
        return UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).CGColor
    }
    
    static func drawGridLines(context: CGContextRef?, _ x: CGFloat, _ rect: CGRect) {
        // Want horizontal lines staring at -ylim spaced by dy.
        let dy = dyGrid(rect.height)
        
        for n in -3...3 {
            let y = CGFloat(n)*dy
            CGContextMoveToPoint(context, x, y)
            CGContextAddLineToPoint(context, x + rect.width, y)
        }
        //    for var y: CGFloat = -ylim; y <= ylim + dy; y += dy {
        //    }
        CGContextSetStrokeColorWithColor(context, GVHelpers.graphLineColor)
        CGContextStrokePath(context)
    }
    
    static func dyGrid(height: CGFloat) -> CGFloat {
        // Leave "7.5" pixels space on top and bottom. Need 7 lines,
        // or 6 spaces in between.
        
        let dy = (height - 15.0)/6.0
        
        return dy
    }

}

//------------------------------------------------------------------
//MARK: Data structure.

struct DataHistory {
    
    let color: CGColor
    let count: Int
    var data = [Double]()
    
    init(numPoints: Int, withColor color: CGColor) {
        count = numPoints
        self.color = color
        reset()
    }
    
    subscript(index: Int) -> Double {
        get {
            return data[index]
        }
        
        set {
            data[index] = newValue
        }
    }
    
    mutating func reset() {
        data = [Double].init(count: count, repeatedValue: 0.0)
    }
    
}

//------------------------------------------------------------------
// MARK: A graph view segment
    
func maxAbsData(data: [Double]) -> Double {
    var amax = 0.0
    for x in data {
        amax = max(amax, x)
    }
    return amax
}

let kLineCount = 64

class GraphViewSegment : NSObject {
    
    // MARK: Properties
    
    // Need one more index than the number of line segments. Each line segment is 1 point long.
    let lineCount = kLineCount
    var indexSize: Int {
        return lineCount + 1
    }
    var history = [DataHistory]()
    var index: Int
    var cgLine: [CGPoint]
    
    var layer = CALayer()
    
    var isFull: Bool {
        return index == 0
    }
    
    var maxAbsValue = 1.0
    var currentScale = 1.0
    
    // MARK: Initializers
    
    init(height: CGFloat) {
        index = lineCount + 1
        
        cgLine = [CGPoint]()
        cgLine.reserveCapacity(2*lineCount)
        for i in 0..<lineCount {
            cgLine.append(CGPointMake(CGFloat(i), 0.0))
            cgLine.append(CGPointMake(CGFloat(i + 1), 0.0))
        }
        
        super.init()
        
        layer.delegate = self
        layer.bounds = CGRectMake(0.0, -height/2.0, CGFloat(lineCount), height)
    }
    
    convenience init(height: CGFloat, withColors colors: CGColor ...) {
        self.init(height: height)
        
        for color in colors {
            history.append(DataHistory(numPoints: indexSize, withColor: color))
        }
    }
    
    static func ThreeLines(height: CGFloat) -> GraphViewSegment {
        return GraphViewSegment(height: height, withColors: GVHelpers.graphXColor, GVHelpers.graphYColor, GVHelpers.graphZColor)
    }
    
    static func OneLine(height: CGFloat) -> GraphViewSegment {
        return GraphViewSegment(height: height, withColors: GVHelpers.graphXColor)
    }
    
    // MARK: Methods
    
    func reset() {
        // Clear out our components and reset the index to 33 to start filling values again.
        for i in 0..<history.count {
            history[i].reset()
        }
        index = indexSize
        
        // Inform Core Animation that this layer needs to be redrawn.
        layer.setNeedsDisplay()
    }
    
    func isVisibleInRect(rect: CGRect) -> Bool {
        // Check if there is an intersection between the layer's frame and the given rect.
        return CGRectIntersectsRect(rect, layer.frame)
    }
    
    func add(data: Double ...) -> Bool {
        // Syntactic sugar.
        return add(data)
    }
    
    func add(data: [Double]) -> Bool {
        // If this segment is not full, add a new value to the history.
        if index > 0 {
            index -= 1
            for i in 0..<min(data.count, history.count) {
                history[i][index] = data[i]
            }
            // Dirty, redraw!
            layer.setNeedsDisplay()
        }
        
        let amax = maxAbsData(data)
        if amax > maxAbsValue {
            maxAbsValue = amax
        }
        
        return isFull
    }
    
    //MARK: Layer
    
    override func drawLayer(_: CALayer, inContext context: CGContextRef) {
        // Draw the graph lines.
        let dy = GVHelpers.dyGrid(layer.bounds.height)
        for data in history {
            for i in 0..<lineCount {
                cgLine[i*2].y = CGFloat(data[i])*dy
                cgLine[i*2+1].y = CGFloat(data[i+1])*dy
            }
            CGContextSetStrokeColorWithColor(context, data.color)
            CGContextSetLineWidth(context, 1.5)
            CGContextSetLineCap(context, .Square)
            CGContextStrokeLineSegments(context, cgLine, cgLine.count)
        }
    }
    
    override func actionForLayer(layer: CALayer, forKey event: String) -> CAAction? {
        // We disable all actions for the layer, so no content cross fades, no implicit animation on moves, etc.
        return NSNull()
    }
    
}

//------------------------------------------------------------------
// MARK: The graph text view

class GraphTextView: UIView {
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let context: CGContextRef? = UIGraphicsGetCurrentContext()
        
        // Fill in background.
        CGContextSetGrayFillColor(context, 1.0, 1.0)
        CGContextFillRect(context, bounds)
        
        CGContextTranslateCTM(context, 0.0, bounds.size.height/2.0)
        
        var tmpBds = bounds
        tmpBds.size.width = 6.0
        GVHelpers.drawGridLines(context, 26.0, tmpBds)
        
        // Draw the text.
        let labels = ["+3.0", "+2.0", "+1.0", "0.0", "-1.0", "-2.0", "-3.0"]
        
        let systemFont = UIFont.systemFontOfSize(12.0)
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = NSTextAlignment.Right
        let attribDict = ["withFont": systemFont , NSParagraphStyleAttributeName: paraStyle]
        
        let dy = GVHelpers.dyGrid(bounds.height)
        let ylim = bounds.size.height/2.0
        let twidth = CGFloat(24.0)
        let theight = CGFloat(16.0)
        
        UIColor.blackColor().set()
        for (i, txt) in labels.enumerate() {
            txt.drawInRect(CGRectMake(2.0, -ylim + CGFloat(i)*dy, twidth, theight), withAttributes: attribDict)
        }
    }
    
}

//------------------------------------------------------------------
// MARK: The graph view

class GraphView: UIView {

    /**
    kSegmentInitialPosition defines the initial position of a segment that is meant to be displayed on the left side of the graph.
    This positioning is meant so that a few entries must be added to the segment's history before it becomes visible to the user. This value could be tweaked a little bit with varying results, but the X coordinate should never be larger than 16 (the center of the text view) or the zero values in the segment's history will be exposed to the user.
    */
    var kSegmentInitialPosition: CGPoint {
        let half = Double(kLineCount)/2.0
        return CGPointMake(CGFloat(30.0 - half), bounds.height/2.0)
    }
    
    var segments = [GraphViewSegment]()
    weak var current: GraphViewSegment?
    weak var upnext: GraphViewSegment?
    weak var textView: GraphTextView?
    
    
    // MARK: Construction
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        // Add graph text as subview; store a weak reference.
        let text = GraphTextView(frame: CGRectMake(0.0, 0.0, 32.0, bounds.height))
        addSubview(text)
        textView = text
        
        // Create a new current segment, which is required by -addX:y:z and other methods.
        // This is also a weak reference (we assume that the 'segments' array will keep the strong reference).
        current = addSegment()
    }
    
    // MARK: Segment management
    
    func add(x: Double, _ y: Double, _ z: Double) {
        guard let current = current else {
            return
        }
        
        current.add(x, y, z)
        
        if current.isFull {
            // Ready the next segment, add same data for overlap.
            let next = recycleSegment()
            next.add(x, y, z)
            
            self.current = next
        }
        
        // After adding a new data point, advance the x-position of all the segment layers by 1 to create the illusion that the graph is advancing.
        for segment in segments {
            var position = segment.layer.position
            position.x += 1.0
            segment.layer.position = position
        }
    }

    /**
      Creates a new segment, adds it to 'segments', and returns a weak reference to that segment. Typically a graph will have around a dozen segments, but this depends on the width of the graph view and segments.
     */
    func addSegment() -> GraphViewSegment {
        let segment = GraphViewSegment.ThreeLines(bounds.height)
        
        // Add the new segment at the front of the array because recycleSegment expects the oldest segment to be at the end of the array. As long as we always insert the youngest segment at the front this will be true.
        segments.insert(segment, atIndex: 0)

        // Ensure that newly added segment layers are placed after the text view's layer so that the text view always renders above the segment layer.
        layer.insertSublayer(segment.layer, below: textView?.layer)
        
        // Position the segment properly (see the comment for kSegmentInitialPosition).
        segment.layer.position = kSegmentInitialPosition
        
        return segment
    }
    
    /// Recycles a segment from 'segments' into 'current'.
    func recycleSegment() -> GraphViewSegment {
        // Start with the last object in the segments array, because it should either be visible onscreen (which indicates that we need more segments) or pushed offscreen (which makes it eligible for recycling).
        let last = segments.last!
        
        if last.isVisibleInRect(layer.bounds) {
            // The last segment is still visible, so create a new segment, which is now the current segment.
            return addSegment()
        }
        else {
            // The last segment is no longer visible, so reset it in preperation for being recycled.
            last.reset()
            
            // Position the segment properly (see the comment for kSegmentInitialPosition).
            last.layer.position = kSegmentInitialPosition
            
            // Move the segment from the last position in the array to the first position in the array because it is now the youngest segment,
            segments.insert(last, atIndex: 0)
            segments.removeLast()
            
            // and make it the current segment.
            return last
        }
    }
    
    //MARK: UIView
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        // Draw the grid lines.
        CGContextTranslateCTM(context, 0.0, bounds.size.height/2.0);
        GVHelpers.drawGridLines(context, 0.0, bounds)
    }
}
