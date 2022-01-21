//
//  PathRenderer.swift
//  PathRendering
//
//  Created by Shahar Ben-Dor on 1/16/22.
//

import Foundation
import Metal

class PathRenderer {
    
    private var fillPipelineState: MTLRenderPipelineState?
    
    func render(withArguments renderArguments: RenderArguments, renderEncoder: inout MTLRenderCommandEncoder, path: Path, fillColor: MetalColor, triangleCount: Int) {
        makePipelineStatesIfNeeded(renderArguments: renderArguments)
        
        let segmentBuffer = renderArguments.device.makeBuffer(bytes: path.segments, length: MemoryLayout<MetalFloat4x2>.stride * path.segments.count, options: [])
        let subpathIndexBuffer = renderArguments.device.makeBuffer(bytes: path.subpathIndices, length: MemoryLayout<UInt32>.stride * path.subpathIndices.count, options: [])
        
        renderEncoder.setRenderPipelineState(fillPipelineState!)
        renderEncoder.setVertexBuffer(segmentBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(subpathIndexBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBytes([UInt32(triangleCount)], length: MemoryLayout<UInt32>.stride, index: 2)
        renderEncoder.setVertexBytes([fillColor], length: MemoryLayout<MetalColor>.stride, index: 3)
        
        renderEncoder.setFragmentTexture(renderArguments.outputDescriptor.colorAttachments[0].texture!, index: 0)
        renderEncoder.setFragmentTexture(renderArguments.outputDescriptor.colorAttachments[1].texture!, index: 1)
        renderEncoder.setFragmentTexture(renderArguments.outputDescriptor.colorAttachments[2].texture!, index: 2)
//        renderEncoder.setTriangleFillMode(.lines)
        
        renderEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: triangleCount*3,
            indexType: .uint16,
            indexBuffer: VertexIndexBuffer.rotaryDistributedBuffer(withTriangleCount: triangleCount, device: renderArguments.device),
            indexBufferOffset: 0,
            instanceCount: path.segments.count
        )
    }
    
    private func makePipelineStatesIfNeeded(renderArguments: RenderArguments) {
        if fillPipelineState == nil {
            let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
            let vertexFunction = renderArguments.library.makeFunction(name: "bezier_fill_vertex")
            let fragmentFunction = renderArguments.library.makeFunction(name: "bezier_fill_fragment")
            
            pipelineStateDescriptor.sampleCount = renderArguments.outputDescriptor.colorAttachments[0].texture!.sampleCount
            pipelineStateDescriptor.vertexFunction = vertexFunction
            pipelineStateDescriptor.fragmentFunction = fragmentFunction
            pipelineStateDescriptor.colorAttachments[0].pixelFormat = renderArguments.outputDescriptor.colorAttachments[0].texture!.pixelFormat
            pipelineStateDescriptor.colorAttachments[1].pixelFormat = renderArguments.outputDescriptor.colorAttachments[1].texture!.pixelFormat
            pipelineStateDescriptor.colorAttachments[2].pixelFormat = renderArguments.outputDescriptor.colorAttachments[2].texture!.pixelFormat
            
            fillPipelineState = try! renderArguments.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        }
    }
    
}
