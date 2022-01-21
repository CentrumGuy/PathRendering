//
//  RenderContext.swift
//  PathRendering
//
//  Created by Shahar Ben-Dor on 1/16/22.
//

import Foundation
import Metal

public class RenderContext {
    
    private var renderArguments: RenderArguments?
    private var renderEncoder: MTLRenderCommandEncoder?
    private let pathRenderer = PathRenderer()
    
    func begin(renderArguments: RenderArguments) {
        self.renderArguments = renderArguments
        renderEncoder = renderArguments.commandBuffer.makeRenderCommandEncoder(descriptor: renderArguments.outputDescriptor)
    }
    
    public func finalize() {
        renderEncoder?.endEncoding()
        renderEncoder = nil
        renderArguments = nil
    }
    
    public func fillPath(path: Path, color: MetalColor, triangleCount: Int = 20) {
        guard let renderArguments = renderArguments,
              var renderEncoder = renderEncoder else { return }
        pathRenderer.render(
            withArguments: renderArguments,
            renderEncoder: &renderEncoder,
            path: path,
            fillColor: color,
            triangleCount: triangleCount
        )
        
        self.renderEncoder = renderEncoder
    }
    
}
