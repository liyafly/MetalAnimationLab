import AnimationPlayground
import SwiftUI

@MainActor
struct ExperimentDetailView: View {
    let experiment: ExperimentDescriptor

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(experiment.id)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                    Text(experiment.title)
                        .font(.largeTitle.bold())
                    Text(experiment.summary)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Divider()
                destinationView
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding(24)
        }
        .navigationTitle(experiment.title)
    }

    @ViewBuilder
    private var destinationView: some View {
        switch ExperimentDestination(experimentID: experiment.id) {
        case .layerTree:
            LayerTreeExperimentView()
        case .implicitAnimation:
            ImplicitAnimationExperimentView()
        case .triangle:
            TriangleExperimentView()
        case .offscreenRendering:
            OffscreenExperimentView()
        case .manualMetalLayer:
            CAMetalLayerExperimentView()
        case .particles:
            ParticleExperimentView()
        case .symbolLightSweep:
            SymbolLightSweepExperimentView()
        case nil:
            ContentUnavailableView("Experiment unavailable", systemImage: "exclamationmark.triangle")
        }
    }
}
