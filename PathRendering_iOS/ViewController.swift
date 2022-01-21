//
//  ViewController.swift
//  PathRendering_iOS
//
//  Created by Shahar Ben-Dor on 1/20/22.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
    private let mtkView = MTKView()
    private let renderer = Renderer()
    private let path = Path()
    
    private var commandQueue: MTLCommandQueue?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(mtkView)
        setupConstraints()
        
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.delegate = self
        mtkView.multisampleColorAttachmentTextureUsage = [.renderTarget, .shaderRead, .shaderWrite]
        mtkView.framebufferOnly = false
        mtkView.sampleCount = 4
        
        path.move(to: SIMD2<MetalFloat>(-0.9,-0.4))
        path.addBezierCurve(
            cp0: SIMD2<MetalFloat>(-0.25,1),
            cp1: SIMD2<MetalFloat>(0.25,-1),
            to: SIMD2<MetalFloat>(0.9,0.9)
        )
        path.move(to: SIMD2<MetalFloat>(-0.9,-0.4))
        path.close()
    }
    
    private func setupConstraints() {
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mtkView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        mtkView.widthAnchor.constraint(equalTo: mtkView.heightAnchor).isActive = true
        mtkView.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor).isActive = true
        let topAnchorConstraint = mtkView.topAnchor.constraint(equalTo: view.topAnchor)
        topAnchorConstraint.priority = .defaultLow
        topAnchorConstraint.isActive = true
    }
    
    private func renderScene(context: RenderContext) {
        context.fillPath(
            path: path,
            color: MetalColor(1, 0.5, 0.8, 1),
            triangleCount: 20
        )
    }


}



extension ViewController: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    
    func draw(in view: MTKView) {
        if commandQueue == nil { commandQueue = view.device?.makeCommandQueue() }
        guard let commandQueue = commandQueue,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let passDescriptor = view.currentRenderPassDescriptor else { return }
        
        let context = renderer.render(
            passDescriptor: passDescriptor,
            commandBuffer: commandBuffer
        )
        
        renderScene(context: context)
        context.finalize()
        
        if let drawable = view.currentDrawable { commandBuffer.present(drawable) }
        commandBuffer.commit()
    }
    
    
}
