//
//  VertexIndexBuffer.swift
//  PathRendering
//
//  Created by Shahar Ben-Dor on 1/16/22.
//

import Foundation
import Metal

class VertexIndexBuffer {
    
    private static var linearDistributionIndices = [UInt16]()
    private static var rotaryDistributionIndices = [UInt16]()
    private static var _linearDistriburionBuffer: MTLBuffer!
    private static var _rotaryDistributionBuffer: MTLBuffer!
    
    static var linearDistriburion: MTLBuffer { _linearDistriburionBuffer }
    static var rotaryDistribution: MTLBuffer { _rotaryDistributionBuffer }
    
    private static func addLinearlyDistributedTrianglesIfNeeded(triangleCount: Int, device: MTLDevice) {
        guard linearDistributionIndices.count/3 < triangleCount || device !== _linearDistriburionBuffer?.device else { return }
        while linearDistributionIndices.count/3 < triangleCount {
            let currentIndex = UInt16(linearDistributionIndices.count/3)
            if currentIndex % 2 == 0 {
                linearDistributionIndices.append(currentIndex + 1)
                linearDistributionIndices.append(currentIndex)
                linearDistributionIndices.append(currentIndex + 2)
            } else {
                linearDistributionIndices.append(currentIndex)
                linearDistributionIndices.append(currentIndex + 1)
                linearDistributionIndices.append(currentIndex + 2)
            }
        }
        
        _linearDistriburionBuffer = device.makeBuffer(
            bytes: linearDistributionIndices,
            length: MemoryLayout<UInt16>.stride * linearDistributionIndices.count,
            options: []
        )
    }
    
    private static func addRotaryDistributedTrianglesIfNeeded(triangleCount: Int, device: MTLDevice) {
        guard rotaryDistributionIndices.count/3 < triangleCount || device !== _rotaryDistributionBuffer?.device else { return }
        while rotaryDistributionIndices.count/3 < triangleCount {
            let currentIndex = UInt16(rotaryDistributionIndices.count/3)
            rotaryDistributionIndices.append(currentIndex + 1)
            rotaryDistributionIndices.append(currentIndex + 2)
            rotaryDistributionIndices.append(0)
        }
        
        _rotaryDistributionBuffer = device.makeBuffer(
            bytes: rotaryDistributionIndices,
            length: MemoryLayout<UInt16>.stride * rotaryDistributionIndices.count,
            options: []
        )
    }
    
    static func linearlyDistributedBuffer(withTriangleCount triangleCount: Int, device: MTLDevice) -> MTLBuffer {
        addLinearlyDistributedTrianglesIfNeeded(triangleCount: triangleCount, device: device)
        return linearDistriburion
    }
    
    static func rotaryDistributedBuffer(withTriangleCount triangleCount: Int, device: MTLDevice) -> MTLBuffer {
        addRotaryDistributedTrianglesIfNeeded(triangleCount: triangleCount, device: device)
        return rotaryDistribution
    }
    
}
