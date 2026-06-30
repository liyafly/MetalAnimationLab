import Metal
import Testing

@testable import MetalRenderKit

@Test
func renderConfigurationRejectsInvalidSampleCount() {
    #expect(throws: MetalRenderError.invalidSampleCount(0)) {
        _ = try RenderConfiguration(pixelFormat: .bgra8Unorm, sampleCount: 0)
    }
}

@Test
func renderConfigurationAcceptsValidValues() throws {
    let configuration = try RenderConfiguration(
        pixelFormat: .bgra8Unorm,
        sampleCount: 1
    )

    #expect(configuration.pixelFormat == .bgra8Unorm)
    #expect(configuration.sampleCount == 1)
}
