//
//  Renderer.swift
//  PathRendering
//
//  Created by Shahar Ben-Dor on 1/16/22.
//

import Foundation
import Metal

public class Renderer {
    
    private let context: RenderContext
    private var library: MTLLibrary?
    
    public init() {
        self.context = RenderContext()
    }
    
    public func render(passDescriptor: MTLRenderPassDescriptor, commandBuffer: MTLCommandBuffer) -> RenderContext {
        if library == nil || library!.device !== commandBuffer.device { library = commandBuffer.device.makeDefaultLibrary()! }
        
        let renderArguments = RenderArguments(
            device: commandBuffer.device,
            library: library!,
            commandBuffer: commandBuffer,
            outputDescriptor: passDescriptor
        )
        
        context.begin(renderArguments: renderArguments)
        return context
    }
    
}
