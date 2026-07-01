import SwiftUI

@MainActor
struct NightSkyExperimentView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MetalViewRepresentable(
                kind: .nightSky,
                isActive: scenePhase == .active,
                reduceMotion: reduceMotion
            )
            .frame(minHeight: 420)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .accessibilityLabel("Procedural stars and slowly drifting partial clouds")

            Text("One fragment pass combines deterministic stars with layered-noise clouds.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}
