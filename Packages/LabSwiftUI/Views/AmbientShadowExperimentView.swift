import SwiftUI

@MainActor
struct AmbientShadowExperimentView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MetalViewRepresentable(
                kind: .ambientShadow,
                isActive: scenePhase == .active,
                reduceMotion: reduceMotion
            )
            .frame(minHeight: 420)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .accessibilityLabel("Stationary branch shadows with gently moving leaf shadows")

            Text("Fixed branch distance fields anchor independently wind-driven leaf groups.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}
