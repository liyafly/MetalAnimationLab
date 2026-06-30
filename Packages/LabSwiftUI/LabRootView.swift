import AnimationPlayground
import SwiftUI

@MainActor
public struct LabRootView: View {
    @State private var selectedID: ExperimentDescriptor.ID? = DemoRegistry.standard.first?.id

    public init() {}

    public var body: some View {
        NavigationSplitView {
            List(DemoRegistry.standard, selection: $selectedID) { experiment in
                ExperimentRow(experiment: experiment)
                    .tag(experiment.id)
            }
            .navigationTitle("Metal Animation Lab")
        } detail: {
            if let selectedID,
               let experiment = DemoRegistry.standard.first(where: { $0.id == selectedID })
            {
                ExperimentDetailView(experiment: experiment)
            } else {
                ContentUnavailableView(
                    "Choose an Experiment",
                    systemImage: "sparkles.rectangle.stack"
                )
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

private struct ExperimentRow: View {
    let experiment: ExperimentDescriptor

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(experiment.id)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                if experiment.isRequired {
                    Text("CORE")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.15), in: Capsule())
                }
            }
            Text(experiment.title)
                .font(.headline)
            Text(experiment.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 5)
    }
}
