public enum AnimationMode: String, CaseIterable, Identifiable, Sendable {
    case implicit = "Implicit"
    case disabledActions = "Actions Disabled"
    case explicit = "Explicit"

    public var id: String { rawValue }
}

