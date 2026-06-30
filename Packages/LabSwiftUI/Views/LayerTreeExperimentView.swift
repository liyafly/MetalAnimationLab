import SwiftUI

@MainActor
struct LayerTreeExperimentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            LayerTreeRepresentable()
                .frame(minHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            Text("The blue subject layer keeps a fixed bounds and anchor point while its position is derived from the host view's current bounds.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

