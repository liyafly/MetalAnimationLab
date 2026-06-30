public enum ExperimentDestination: String, CaseIterable, Sendable {
    case layerTree = "EXP-001"
    case implicitAnimation = "EXP-002"
    case triangle = "EXP-003"
    case offscreenRendering = "EXP-004"
    case manualMetalLayer = "EXP-005"
    case particles = "EXP-006"

    public init?(experimentID: String) {
        self.init(rawValue: experimentID)
    }
}
