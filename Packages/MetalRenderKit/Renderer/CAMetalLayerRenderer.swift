import Metal
import QuartzCore

@MainActor
public final class CAMetalLayerRenderer {
    private let context: MetalContext
    private let pipeline: any MTLRenderPipelineState

    public init(
        pixelFormat: MTLPixelFormat = .bgra8Unorm,
        context: MetalContext? = nil
    ) throws {
        let context = try context ?? MetalContext()
        self.context = context
        pipeline = try context.makeRenderPipeline(
            vertexFunction: "lab_fullscreen_vertex",
            fragmentFunction: "lab_manual_layer_fragment",
            configuration: RenderConfiguration(pixelFormat: pixelFormat)
        )
    }

    public func configure(layer: CAMetalLayer) {
        layer.device = context.device
        layer.pixelFormat = .bgra8Unorm
        layer.framebufferOnly = true
    }

    @discardableResult
    public func draw(layer: CAMetalLayer, time: Float) -> Bool {
        guard
            layer.drawableSize.width > 0,
            layer.drawableSize.height > 0,
            let drawable = layer.nextDrawable(),
            let commandBuffer = context.commandQueue.makeCommandBuffer()
        else { return false }

        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].storeAction = .store
        descriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: 0.02,
            green: 0.03,
            blue: 0.08,
            alpha: 1
        )

        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return false
        }
        var time = time
        encoder.setRenderPipelineState(pipeline)
        encoder.setFragmentBytes(&time, length: MemoryLayout<Float>.size, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        return true
    }
}
