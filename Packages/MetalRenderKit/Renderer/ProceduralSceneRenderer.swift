import MetalKit
import QuartzCore
import RenderLabCore

public enum ProceduralSceneKind: Sendable {
    case nightSky
    case ambientShadow

    var fragmentFunction: String {
        switch self {
        case .nightSky:
            "lab_night_sky_fragment"
        case .ambientShadow:
            "lab_ambient_shadow_fragment"
        }
    }

    var clearColor: MTLClearColor {
        switch self {
        case .nightSky:
            MTLClearColor(red: 0.025, green: 0.035, blue: 0.11, alpha: 1)
        case .ambientShadow:
            MTLClearColor(red: 0.91, green: 0.91, blue: 0.89, alpha: 1)
        }
    }
}

private struct ProceduralSceneUniforms {
    var resolution: SIMD2<Float>
    var time: Float
    var motionScale: Float
    var seed: UInt32
    var padding: UInt32 = 0
}

@MainActor
public final class ProceduralSceneRenderer: NSObject, MTKViewDelegate {
    private let context: MetalContext
    private let parameters: ProceduralSceneParameters
    private let pipeline: any MTLRenderPipelineState
    private var clock = RenderClock()
    private var reduceMotion = false
    private var isActive = true

    public init(
        view: MTKView,
        kind: ProceduralSceneKind,
        parameters: ProceduralSceneParameters,
        context: MetalContext? = nil
    ) throws {
        let context = try context ?? MetalContext()
        self.context = context
        self.parameters = parameters
        view.device = context.device
        view.colorPixelFormat = .bgra8Unorm
        view.clearColor = kind.clearColor
        view.preferredFramesPerSecond = parameters.preferredFramesPerSecond
        view.framebufferOnly = true
        pipeline = try context.makeRenderPipeline(
            vertexFunction: "lab_fullscreen_vertex",
            fragmentFunction: kind.fragmentFunction,
            configuration: RenderConfiguration(pixelFormat: view.colorPixelFormat)
        )
        super.init()
    }

    public func setMotionState(
        isActive: Bool,
        reduceMotion: Bool,
        at timestamp: TimeInterval = CACurrentMediaTime(),
        in view: MTKView
    ) {
        let wasPaused = view.isPaused
        self.isActive = isActive
        self.reduceMotion = reduceMotion
        let shouldPause = !isActive || reduceMotion
        clock.setPaused(shouldPause, at: timestamp)
        view.isPaused = shouldPause
        if isActive, shouldPause, !wasPaused {
            view.draw()
        }
    }

    public func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}

    public func draw(in view: MTKView) {
        guard
            isActive,
            let descriptor = view.currentRenderPassDescriptor,
            let drawable = view.currentDrawable,
            let commandBuffer = context.commandQueue.makeCommandBuffer(),
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }

        let timestamp = CACurrentMediaTime()
        var uniforms = ProceduralSceneUniforms(
            resolution: SIMD2(
                Float(max(1, view.drawableSize.width)),
                Float(max(1, view.drawableSize.height))
            ),
            time: reduceMotion ? 0 : clock.elapsedTime(at: timestamp),
            motionScale: reduceMotion ? 0 : parameters.motionScale,
            seed: parameters.seed
        )

        encoder.setRenderPipelineState(pipeline)
        encoder.setFragmentBytes(
            &uniforms,
            length: MemoryLayout<ProceduralSceneUniforms>.stride,
            index: 0
        )
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
