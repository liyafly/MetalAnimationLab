import AnimationPlayground
import Testing

@testable import LabSwiftUI

@Test
func everyRegisteredExperimentHasADestination() {
    let destinations = DemoRegistry.standard.compactMap {
        ExperimentDestination(experimentID: $0.id)
    }

    #expect(destinations.count == DemoRegistry.standard.count)
    #expect(destinations.map(\.rawValue) == DemoRegistry.standard.map(\.id))
}

@Test
func unknownExperimentDoesNotCreateADestination() {
    #expect(ExperimentDestination(experimentID: "EXP-999") == nil)
}
