import SwiftUI

@MainActor
struct ParticleExperimentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MetalViewRepresentable(kind: .particles)
                .frame(minHeight: 420)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            Text("Particle positions are generated on the GPU from vertex_id and time.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}
