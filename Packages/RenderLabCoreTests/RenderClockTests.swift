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

@Test
func renderClockExcludesPausedDuration() {
    var clock = RenderClock()

    #expect(clock.elapsedTime(at: 10) == 0)
    #expect(clock.elapsedTime(at: 12) == 2)
    clock.setPaused(true, at: 12)
    #expect(clock.elapsedTime(at: 18) == 2)
    clock.setPaused(false, at: 20)
    #expect(clock.elapsedTime(at: 22) == 4)
}

@Test
func renderClockIgnoresRepeatedPauseState() {
    var clock = RenderClock()

    _ = clock.elapsedTime(at: 4)
    clock.setPaused(true, at: 5)
    clock.setPaused(true, at: 7)
    clock.setPaused(false, at: 9)
    clock.setPaused(false, at: 11)

    #expect(clock.elapsedTime(at: 12) == 4)
}
