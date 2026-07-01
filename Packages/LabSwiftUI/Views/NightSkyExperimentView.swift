import SwiftUI

@MainActor
struct NightSkyExperimentView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var activityMonitor = PlatformActivityMonitor()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MetalViewRepresentable(
                kind: .nightSky,
                isActive: activityMonitor.isActive,
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
