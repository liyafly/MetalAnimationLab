import Foundation
import Metal

public final class MetalContext: @unchecked Sendable {
    public let device: any MTLDevice
    public let commandQueue: any MTLCommandQueue

    public convenience init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw MetalRenderError.deviceUnavailable
        }
        try self.init(device: device)
    }

    public init(device: any MTLDevice) throws {
        guard let commandQueue = device.makeCommandQueue() else {
            throw MetalRenderError.commandQueueUnavailable
        }
        self.device = device
        self.commandQueue = commandQueue
    }

    func makeShaderLibrary() throws -> any MTLLibrary {
        do {
            return try device.makeDefaultLibrary(bundle: .module)
        } catch {
            throw MetalRenderError.shaderLibraryUnavailable(error.localizedDescription)
        }
    }

    func makeFunction(named name: String, in library: any MTLLibrary) throws -> any MTLFunction {
        guard let function = library.makeFunction(name: name) else {
            throw MetalRenderError.shaderFunctionUnavailable(name)
        }
        return function
    }

    func makeRenderPipeline(
        vertexFunction: String,
        fragmentFunction: String,
        configuration: RenderConfiguration
    ) throws -> any MTLRenderPipelineState {
        let library = try makeShaderLibrary()
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = try makeFunction(named: vertexFunction, in: library)
        descriptor.fragmentFunction = try makeFunction(named: fragmentFunction, in: library)
        descriptor.colorAttachments[0].pixelFormat = configuration.pixelFormat
        descriptor.rasterSampleCount = configuration.sampleCount

        do {
            return try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            throw MetalRenderError.pipelineCreationFailed(error.localizedDescription)
        }
    }
}
