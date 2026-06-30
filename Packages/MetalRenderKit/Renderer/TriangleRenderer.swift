import MetalKit

@MainActor
public final class TriangleRenderer: NSObject, MTKViewDelegate {
    private let context: MetalContext
    private let pipeline: any MTLRenderPipelineState

    public init(view: MTKView, context: MetalContext? = nil) throws {
        let context = try context ?? MetalContext()
        self.context = context
        view.device = context.device
        view.colorPixelFormat = .bgra8Unorm
        view.clearColor = MTLClearColor(red: 0.035, green: 0.045, blue: 0.08, alpha: 1)
        pipeline = try context.makeRenderPipeline(
            vertexFunction: "lab_triangle_vertex",
            fragmentFunction: "lab_vertex_color_fragment",
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

        encoder.setRenderPipelineState(pipeline)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
