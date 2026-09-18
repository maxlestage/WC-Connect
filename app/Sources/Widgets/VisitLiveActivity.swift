import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

/// Live Activity de la visite en cours.
///
/// Le chronomètre utilise `Text(timerInterval:)` : iOS l'anime lui-même, sans
/// réveiller l'app ni consommer de batterie.
struct VisitLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WCActivityAttributes.self) { context in
            LockScreenLiveActivityView(state: context.state)
                .activityBackgroundTint(Color.black.opacity(0.55))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            let color = WCTheme.color(for: context.state.kind)

            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(context.state.kind.title)
                    } icon: {
                        Image(systemName: context.state.kind.symbol)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(color)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.state.timerRange, countsDown: false)
                        .font(.title3.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(color)
                        .frame(maxWidth: 76)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        ProgressView(
                            timerInterval: context.state.timerRange,
                            countsDown: false,
                            label: { EmptyView() },
                            currentValueLabel: { EmptyView() }
                        )
                        .tint(color)

                        HStack {
                            Label(context.state.place.title, systemImage: context.state.place.symbol)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button(intent: StopVisitIntent()) {
                                Label("Terminer", systemImage: "checkmark")
                                    .font(.caption.weight(.semibold))
                            }
                            .buttonStyle(.bordered)
                            .tint(color)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "toilet.fill")
                    .foregroundStyle(color)
            } compactTrailing: {
                Text(timerInterval: context.state.timerRange, countsDown: false, showsHours: false)
                    .monospacedDigit()
                    .frame(maxWidth: 44)
                    .foregroundStyle(color)
            } minimal: {
                Image(systemName: "toilet.fill")
                    .foregroundStyle(color)
            }
            .keylineTint(color)
        }
    }
}

/// Vue affichée sur l'écran verrouillé et dans la pile intelligente de la Watch.
struct LockScreenLiveActivityView: View {
    let state: WCActivityAttributes.ContentState

    private var color: Color { WCTheme.color(for: state.kind) }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "toilet.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("Visite en cours")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(timerInterval: state.timerRange, countsDown: false)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                HStack(spacing: 6) {
                    Label(state.kind.title, systemImage: state.kind.symbol)
                    Text("·")
                    Label(state.place.title, systemImage: state.place.symbol)
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Button(intent: StopVisitIntent()) {
                Image(systemName: "checkmark")
                    .font(.headline)
                    .padding(6)
            }
            .buttonStyle(.bordered)
            .tint(color)
            .accessibilityLabel("Terminer la visite")
        }
        .padding(16)
    }
}
