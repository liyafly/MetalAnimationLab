public enum ExperimentCategory: String, CaseIterable, Sendable {
    case coreAnimation = "Core Animation"
    case metal = "Metal"
    case performance = "Performance"
}

public struct ExperimentDescriptor: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let summary: String
    public let category: ExperimentCategory
    public let isRequired: Bool

    public init(
        id: String,
        title: String,
        summary: String,
        category: ExperimentCategory,
        isRequired: Bool
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.category = category
        self.isRequired = isRequired
    }
}

