//
//  MetalUtils.swift
//  PathRendering
//
//  Created by Shahar Ben-Dor on 1/16/22.
//

import Foundation
import Metal

extension MTLTexture {
    func makeDescriptor() -> MTLTextureDescriptor {
        let descriptor = MTLTextureDescriptor()
        descriptor.textureType = textureType
        descriptor.pixelFormat = pixelFormat
        descriptor.usage = usage
        descriptor.width = width
        descriptor.height = height
        descriptor.depth = depth
        descriptor.mipmapLevelCount = mipmapLevelCount
        descriptor.sampleCount = sampleCount
        descriptor.arrayLength = arrayLength
        descriptor.cpuCacheMode = cpuCacheMode
        descriptor.storageMode = storageMode
        
        if #available(iOS 12.0, macOS 10.14, *) {
            descriptor.allowGPUOptimizedContents = allowGPUOptimizedContents
        }
        if #available(iOS 13.0, macOS 10.15, *) {
            descriptor.resourceOptions = resourceOptions
            descriptor.hazardTrackingMode = hazardTrackingMode
            descriptor.swizzle = swizzle
        }
        return descriptor
    }
}
