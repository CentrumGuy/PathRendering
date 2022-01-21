//
//  RenderArguments.swift
//  PathRendering
//
//  Created by Shahar Ben-Dor on 1/16/22.
//

import Foundation
import Metal

struct RenderArguments {
    
    let device: MTLDevice
    let library: MTLLibrary
    let commandBuffer: MTLCommandBuffer
    let outputDescriptor: MTLRenderPassDescriptor
    let renderTarget: MTLTexture
    
    public init(device: MTLDevice, library: MTLLibrary, commandBuffer: MTLCommandBuffer, outputDescriptor: MTLRenderPassDescriptor) {
        self.device = device
        self.library = library
        self.commandBuffer = commandBuffer
        self.outputDescriptor = outputDescriptor
        self.renderTarget = (outputDescriptor.colorAttachments[0].resolveTexture ?? outputDescriptor.colorAttachments[0].texture)!
        
        let outputTextureDescriptor = outputDescriptor.colorAttachments[0].texture!.makeDescriptor()        
        let aux0 = device.makeTexture(descriptor: outputTextureDescriptor)
        let aux1 = device.makeTexture(descriptor: outputTextureDescriptor)
        
        outputDescriptor.colorAttachments[0].loadAction = .clear
        outputDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        outputDescriptor.colorAttachments[1].texture = aux0
        outputDescriptor.colorAttachments[1].loadAction = .clear
        outputDescriptor.colorAttachments[1].storeAction = .dontCare
        outputDescriptor.colorAttachments[1].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        outputDescriptor.colorAttachments[2].texture = aux1
        outputDescriptor.colorAttachments[2].loadAction = .clear
        outputDescriptor.colorAttachments[2].storeAction = .dontCare
        outputDescriptor.colorAttachments[2].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
}
