import MetalRenderKit
import RenderLabCore
import SwiftUI

@MainActor
struct SymbolLightSweepExperimentView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var activityMonitor = PlatformActivityMonitor()
    @State private var clock = SymbolLightSweepClock()

    private let parameters = SymbolLightSweepParameters.standard

    var body: some View {
        let activity = RenderActivityState(
            isApplicationActive: activityMonitor.isActive,
            reduceMotion: reduceMotion
        )

        VStack(alignment: .leading, spacing: 12) {
            TimelineView(
                .animation(
                    minimumInterval: 1.0 / 30.0,
                    paused: activity.isPaused
                )
            ) { context in
                GeometryReader { proxy in
                    let size = proxy.size
                    let time = clock.elapsedTime(at: context.date, paused: activity.isPaused)

                    ZStack {
                        RadialGradient(
                            colors: [Color.white.opacity(0.08), Color.black.opacity(0.34)],
                            center: .top,
                            startRadius: 0,
                            endRadius: max(size.width, size.height) * 0.7
                        )
                        Color(red: 0.055, green: 0.065, blue: 0.09)
                            .blendMode(.destinationOver)

                        Image(systemName: "heart.fill")
                            .font(.system(size: min(size.width, size.height) * 0.36, weight: .medium))
                            .foregroundStyle(Color(red: 0.42, green: 0.45, blue: 0.52))
                            .padding(24)
                            .layerEffect(
                                LabShaderLibrary.symbolLightSweep(
                                    size: size,
                                    time: time,
                                    parameters: parameters
                                ),
                                maxSampleOffset: CGSize(width: 6, height: 6),
                                isEnabled: !reduceMotion
                            )
                            .accessibilityLabel("Heart symbol with a soft moving light")
                    }
                }
                .frame(minHeight: 360)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            Text("A native SF Symbol is sampled by a Metal layer-effect shader.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

@MainActor
private final class SymbolLightSweepClock {
    private var renderClock = RenderClock()

    func elapsedTime(at date: Date, paused: Bool) -> Float {
        let timestamp = date.timeIntervalSinceReferenceDate
        renderClock.setPaused(paused, at: timestamp)
        return renderClock.elapsedTime(at: timestamp)
    }
}
