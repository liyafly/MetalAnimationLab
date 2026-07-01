@testable import AnimationPlayground
import Testing

@Test
func registryKeepsStableExperimentOrder() {
    #expect(DemoRegistry.standard.map(\.id) == [
        "EXP-001",
        "EXP-002",
        "EXP-003",
        "EXP-004",
        "EXP-005",
        "EXP-006",
        "EXP-007",
        "EXP-008",
    ])
}

@Test
func registryMarksRequiredExperiments() {
    let required = DemoRegistry.standard.filter(\.isRequired)

    #expect(required.map(\.id) == ["EXP-001", "EXP-002", "EXP-003"])
}
