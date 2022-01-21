//
//  Path.swift
//  PathRendering
//
//  Created by Shahar Ben-Dor on 1/16/22.
//

import Foundation
import simd

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

open class Path {
    
    private var _currentPoint: SIMD2<MetalFloat>
    open var currentPoint: SIMD2<MetalFloat> { _currentPoint }
    
    private var _segments: [MetalFloat4x2]
    open var segments: [MetalFloat4x2] { _segments }
    
    private var _joinIndices: [UInt32]
    internal var joinIndices: [UInt32] { _joinIndices }
    private var _capIndices: [SIMD2<UInt32>]
    internal var capIndices: [SIMD2<UInt32>] { _capIndices }
    private var _subpathIndices: [UInt32]
    internal var subpathIndices: [UInt32] { _subpathIndices }
    
    public convenience init (segments: [MetalFloat4x2]) {
        self.init()
        self._segments.reserveCapacity(segments.count + 4)
        if let firstPoint = segments.first?[0] {
            _currentPoint = firstPoint
            segments.forEach(addSegment(_:))
        }
    }
    
    public init () {
        self._currentPoint = .zero
        self._segments = []
        self._joinIndices = []
        self._capIndices = []
        self._subpathIndices = []
    }
    
    
    
    open func addSegment(_ segment: MetalFloat4x2) {
        if let lastSegment = segments.last {
            if lastSegment[3] == segment[0] {
                _joinIndices.append(UInt32(segments.count - 1))
                _subpathIndices.append(UInt32(_subpathIndices.last!))
            } else {
                _capIndices.append(SIMD2<UInt32>(UInt32(segments.count - 1), 1))
                _capIndices.append(SIMD2<UInt32>(UInt32(segments.count), 0))
                _subpathIndices.append(UInt32(_segments.count))
            }
        } else {
            _subpathIndices.append(0)
        }
        _segments.append(segment)
        _currentPoint = segment[3]
    }
    
    internal func prepareForRender(render: () -> ()) {
        guard let firstSegment = segments.first, let lastSegment = segments.last else {
            render()
            return
        }
        
        if firstSegment[0] == lastSegment[3] {
            _joinIndices.append(UInt32(segments.count - 1))
            render()
            _joinIndices.removeLast()
        } else {
            _capIndices.append(SIMD2<UInt32>(0, 0))
            _capIndices.append(SIMD2<UInt32>(UInt32(segments.count - 1), 1))
            render()
            _capIndices.removeLast(2)
        }
    }
    
    open func move(to point: SIMD2<MetalFloat>) {
        self._currentPoint = point
    }
    
    open func addLine(to point: SIMD2<MetalFloat>) {
        guard point != _currentPoint else { return }
        let segment = MetalFloat4x2(
            _currentPoint,
            _currentPoint*SIMD2<MetalFloat>(repeating: 2/3)+point*SIMD2<MetalFloat>(repeating: 1/3),
            _currentPoint*SIMD2<MetalFloat>(repeating: 1/3)+point*SIMD2<MetalFloat>(repeating: 2/3),
            point
        )
        addSegment(segment)
    }
    
    open func addBezierCurve(cp0: SIMD2<MetalFloat>, to point: SIMD2<MetalFloat>) {
        let segment = MetalFloat4x2(
            _currentPoint,
            _currentPoint*SIMD2<MetalFloat>(repeating: 1/3)+cp0*SIMD2<MetalFloat>(repeating: 2/3),
            cp0*SIMD2<MetalFloat>(repeating: 2/3)+point*SIMD2<MetalFloat>(repeating: 1/3),
            point
        )
        addSegment(segment)
    }
    
    open func addBezierCurve(cp0: SIMD2<MetalFloat>, cp1: SIMD2<MetalFloat>, to point: SIMD2<MetalFloat>) {
        let segment = MetalFloat4x2(
            _currentPoint,
            cp0,
            cp1,
            point
        )
        addSegment(segment)
    }
    
    open func close() {
        guard let lastSubpathIndex = _subpathIndices.last else { return }
        let startPoint = _segments[Int(lastSubpathIndex)][0]
        guard startPoint != _currentPoint else { return }
        addLine(to: startPoint)
    }
    
    #if os(iOS)
    open func makeBezierPath() -> UIBezierPath {
        guard let startPoint = _segments.first?[0] else { return UIBezierPath() }
        let path = UIBezierPath()
        var currentPoint = startPoint
        path.move(to: CGPoint(startPoint))
        for segment in _segments {
            if currentPoint != segment[0] { path.move(to: CGPoint(segment[0])) }
            path.addCurve(to: CGPoint(segment[3]), controlPoint1: CGPoint(segment[1]), controlPoint2: CGPoint(segment[2]))
            currentPoint = segment[3]
        }
        path.move(to: CGPoint(_currentPoint))
        return path
    }
    #elseif os(macOS)
    open func makeBezierPath() -> NSBezierPath {
        guard let startPoint = _segments.first?[0] else { return NSBezierPath() }
        let path = NSBezierPath()
        var currentPoint = startPoint
        path.move(to: CGPoint(startPoint))
        for segment in _segments {
            if currentPoint != segment[0] { path.move(to: CGPoint(segment[0])) }
            path.curve(to: CGPoint(segment[3]), controlPoint1: CGPoint(segment[1]), controlPoint2: CGPoint(segment[2]))
            currentPoint = segment[3]
        }
        path.move(to: CGPoint(self.currentPoint))
        return path
    }
    #endif
    
}

private extension CGPoint {
    init(_ points: SIMD2<MetalFloat>) {
        self.init(x: CGFloat(points.x), y: CGFloat(points.y))
    }
}

