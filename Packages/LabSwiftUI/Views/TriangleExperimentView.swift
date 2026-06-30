import SwiftUI

@MainActor
struct TriangleExperimentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MetalViewRepresentable(kind: .triangle)
                .frame(minHeight: 360)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            Text("The vertex shader creates three vertices from vertex_id; no CPU vertex buffer is required.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}
