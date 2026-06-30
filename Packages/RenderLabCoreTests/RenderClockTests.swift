@testable import RenderLabCore
import Testing

@Test
func renderClockPreservesFrameIntervalsForLargeAbsoluteTimestamps() {
    var clock = RenderClock()

    #expect(clock.elapsedTime(at: 800_000_000) == 0)
    #expect(clock.elapsedTime(at: 800_000_000 + 1.0 / 60.0) > 0.016)
    #expect(clock.elapsedTime(at: 800_000_001) == 1)
}

@Test
func renderClockDoesNotMoveBackward() {
    var clock = RenderClock()

    #expect(clock.elapsedTime(at: 10) == 0)
    #expect(clock.elapsedTime(at: 9) == 0)
}
