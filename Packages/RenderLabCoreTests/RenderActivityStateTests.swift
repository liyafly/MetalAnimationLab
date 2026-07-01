@testable import RenderLabCore
import Testing

@Test
func renderActivityStateRunsOnlyWhenActiveWithMotionEnabled() {
    #expect(RenderActivityState(isApplicationActive: true, reduceMotion: false).isPaused == false)
    #expect(RenderActivityState(isApplicationActive: false, reduceMotion: false).isPaused)
    #expect(RenderActivityState(isApplicationActive: true, reduceMotion: true).isPaused)
}

@Test
func renderActivityStateDisablesMotionForAccessibility() {
    #expect(RenderActivityState(isApplicationActive: true, reduceMotion: false).motionScale == 1)
    #expect(RenderActivityState(isApplicationActive: true, reduceMotion: true).motionScale == 0)
}
