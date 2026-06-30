import Metal

public struct RenderConfiguration: Equatable, Sendable {
    public let pixelFormat: MTLPixelFormat
    public let sampleCount: Int

    public init(pixelFormat: MTLPixelFormat, sampleCount: Int = 1) throws {
        guard sampleCount > 0 else {
            throw MetalRenderError.invalidSampleCount(sampleCount)
        }
        self.pixelFormat = pixelFormat
        self.sampleCount = sampleCount
    }
}

