import SwiftUI

@MainActor
struct OffscreenExperimentView: View {
    @State private var usesShadowPath = true

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle("Provide a fixed shadowPath", isOn: $usesShadowPath)
            OffscreenRenderingRepresentable(usesShadowPath: usesShadowPath)
                .frame(minHeight: 300)
                .background(.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
            Text(usesShadowPath
                ? "The compositor receives explicit shadow geometry."
                : "The compositor derives the shadow from the layer's alpha mask.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

