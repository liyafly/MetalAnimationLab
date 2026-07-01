@testable import MetalRenderKit
import Testing

@Test
func symbolLightSweepDefaultsUseLowFrequencyCycle() {
    let value = SymbolLightSweepParameters.standard

    #expect(value.cycleDuration == 10)
    #expect(value.sweepDuration == 1.5)
    #expect(value.softness == 0.09)
    #expect(value.intensity == 0.9)
}

@Test
func symbolLightSweepParametersClampInvalidValues() {
    let value = SymbolLightSweepParameters(
        cycleDuration: 0,
        sweepDuration: 8,
        angle: 0.4,
        softness: 0,
        intensity: 9
    )

    #expect(value.cycleDuration == 1)
    #expect(value.sweepDuration == 1)
    #expect(value.softness == 0.001)
    #expect(value.intensity == 2)
}

@Test
func proceduralSceneParametersClampRuntimeValues() {
    let value = ProceduralSceneParameters(
        seed: 7,
        preferredFramesPerSecond: 0,
        motionScale: -2
    )

    #expect(value.seed == 7)
    #expect(value.preferredFramesPerSecond == 1)
    #expect(value.motionScale == 0)
}

@Test
func proceduralSceneDefaultsAreDeterministic() {
    #expect(ProceduralSceneParameters.nightSky.seed == 0x5A17_2026)
    #expect(ProceduralSceneParameters.ambientShadow.seed == 0x1EA7_2026)
    #expect(ProceduralSceneParameters.nightSky.preferredFramesPerSecond == 30)
    #expect(ProceduralSceneParameters.ambientShadow.preferredFramesPerSecond == 30)
}
