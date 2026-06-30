import CoreAnimationLab
import SwiftUI

@MainActor
struct ImplicitAnimationExperimentView: View {
    @State private var mode: AnimationMode = .implicit
    @State private var runToken = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("Animation mode", selection: $mode) {
                ForEach(AnimationMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            ImplicitAnimationRepresentable(mode: mode, runToken: runToken)
                .frame(minHeight: 260)
                .background(.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 18))

            Button("Run \(mode.rawValue)") { runToken += 1 }
                .buttonStyle(.borderedProminent)
        }
    }
}
