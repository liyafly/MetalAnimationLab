import MetalKit
import QuartzCore

@MainActor
public final class ParticleRenderer: NSObject, MTKViewDelegate {
    private let context: MetalContext
    private let pipeline: any MTLRenderPipelineState
    private let startTime = CACurrentMediaTime()
    private let particleCount: Int

    public init(view: MTKView, particleCount: Int = 768, context: MetalContext? = nil) throws {
        let context = try context ?? MetalContext()
        self.context = context
        self.particleCount = max(1, particleCount)
        view.device = context.device
        view.colorPixelFormat = .bgra8Unorm
        view.clearColor = MTLClearColor(red: 0.015, green: 0.02, blue: 0.05, alpha: 1)
        view.preferredFramesPerSecond = 60
        pipeline = try context.makeRenderPipeline(
            vertexFunction: "lab_particle_vertex",
            fragmentFunction: "lab_particle_fragment",
            configuration: RenderConfiguration(pixelFormat: view.colorPixelFormat)
        )
        super.init()
    }

    public func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}

    public func draw(in view: MTKView) {
        guard
            let descriptor = view.currentRenderPassDescriptor,
            let drawable = view.currentDrawable,
            let commandBuffer = context.commandQueue.makeCommandBuffer(),
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }

        var time = Float(CACurrentMediaTime() - startTime)
        encoder.setRenderPipelineState(pipeline)
        encoder.setVertexBytes(&time, length: MemoryLayout<Float>.size, index: 0)
        encoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: particleCount)
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

