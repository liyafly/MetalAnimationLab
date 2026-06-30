import SwiftUI

@MainActor
struct CAMetalLayerExperimentView: View {
    var body: some View {
        TimelineView(.animation) { context in
            ManualMetalLayerRepresentable(time: context.date.timeIntervalSinceReferenceDate)
                .frame(minHeight: 360)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .overlay(alignment: .bottomLeading) {
            Text("Manual drawable → command buffer → present")
                .font(.caption.monospaced())
                .padding(10)
                .background(.black.opacity(0.5), in: Capsule())
                .foregroundStyle(.white)
                .padding()
        }
    }
}
