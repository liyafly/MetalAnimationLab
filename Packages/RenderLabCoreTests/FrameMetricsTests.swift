@testable import RenderLabCore
import Testing

@Test
func frameMetricsRecordsSamples() {
    var metrics = FrameMetrics(hitchThreshold: 0.05)

    metrics.record(frameDuration: 1.0 / 60.0)
    metrics.record(frameDuration: 0.08)

    #expect(metrics.sampleCount == 2)
    #expect(metrics.hitchCount == 1)
    #expect(metrics.averageFPS > 20)
}

@Test
func frameMetricsIgnoresInvalidDurations() {
    var metrics = FrameMetrics(hitchThreshold: 0.05)

    metrics.record(frameDuration: 0)
    metrics.record(frameDuration: -.infinity)

    #expect(metrics.sampleCount == 0)
    #expect(metrics.averageFPS == 0)
}
