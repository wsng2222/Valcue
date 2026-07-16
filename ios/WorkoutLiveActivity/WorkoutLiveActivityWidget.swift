import ActivityKit
import SwiftUI
import WidgetKit

private let valcueAccent = Color(red: 0.95, green: 0.22, blue: 0.20)

struct WorkoutLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            WorkoutLockScreenView(context: context)
                .activityBackgroundTint(Color(.systemBackground))
                .activitySystemActionForegroundColor(valcueAccent)
        } dynamicIsland: { context in
            let isStale = activityIsStale(context)
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: context.attributes.machineSymbol)
                            .font(.title2)
                            .foregroundStyle(valcueAccent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.routineName)
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                            if !isStale {
                                Text(context.state.statusText)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                    }
                    .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        WorkoutTimerView(
                            state: context.state,
                            compact: false,
                            isStale: isStale
                        )
                        if !isStale {
                            Text(context.state.intervalText)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.trailing, 8)
                }
                DynamicIslandExpandedRegion(.center) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        if !isStale {
                            HStack {
                                if !context.state.primaryMetric.isEmpty {
                                    Text(context.state.primaryMetric)
                                        .font(.subheadline.weight(.bold))
                                }
                                Spacer()
                                if !context.state.secondaryMetric.isEmpty {
                                    Text(context.state.secondaryMetric)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        if let interval = workoutProgressTimerInterval(for: context.state) {
                            ProgressView(timerInterval: interval, countsDown: false) {
                                EmptyView()
                            } currentValueLabel: {
                                EmptyView()
                            }
                            .tint(valcueAccent)
                        } else if !isStale {
                            ProgressView(value: normalizedProgress(context.state.progress))
                                .tint(valcueAccent)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 4)
                }
            } compactLeading: {
                Image(systemName: context.attributes.machineSymbol)
                    .foregroundStyle(valcueAccent)
            } compactTrailing: {
                WorkoutTimerView(
                    state: context.state,
                    compact: true,
                    isStale: isStale,
                    usesWorkoutEndAt: true
                )
                .foregroundStyle(valcueAccent)
            } minimal: {
                Image(systemName: context.attributes.machineSymbol)
                    .foregroundStyle(valcueAccent)
            }
            .keylineTint(valcueAccent)
        }
    }
}

private struct WorkoutLockScreenView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>

    private var isStale: Bool {
        activityIsStale(context)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                MachineBadge(
                    symbol: context.attributes.machineSymbol,
                    name: context.attributes.machineName
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.routineName)
                        .font(.headline)
                        .lineLimit(1)
                    if !isStale {
                        Text(context.state.statusText)
                            .font(.caption)
                            .foregroundStyle(statusColor(context.state.status))
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 2) {
                    WorkoutTimerView(
                        state: context.state,
                        compact: false,
                        isStale: isStale
                    )
                    if !isStale {
                        Text(context.state.intervalText)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            WorkoutExpandedMetrics(
                state: context.state,
                showsSnapshotDetails: !isStale
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
        )
        .accessibilityElement(children: .combine)
    }
}

private struct WorkoutExpandedMetrics: View {
    let state: WorkoutActivityAttributes.ContentState
    let showsSnapshotDetails: Bool

    var body: some View {
        VStack(spacing: 8) {
            if showsSnapshotDetails {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    if !state.primaryMetric.isEmpty {
                        Text(state.primaryMetric)
                            .font(.title3.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }

                    if !state.secondaryMetric.isEmpty {
                        Text(state.secondaryMetric)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }

                    Spacer(minLength: 4)

                    if !state.durationText.isEmpty {
                        Text(state.durationText)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            if let interval = workoutProgressTimerInterval(for: state) {
                ProgressView(timerInterval: interval, countsDown: false) {
                    EmptyView()
                } currentValueLabel: {
                    EmptyView()
                }
                .tint(valcueAccent)
                .scaleEffect(x: 1, y: 0.9, anchor: .center)
            } else if showsSnapshotDetails {
                ProgressView(value: normalizedProgress(state.progress))
                    .tint(valcueAccent)
                    .scaleEffect(x: 1, y: 0.9, anchor: .center)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemFill))
        )
    }
}

private struct MachineBadge: View {
    let symbol: String
    let name: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.headline)
                .foregroundStyle(valcueAccent)
            Text(name)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(Color(.secondarySystemFill))
        )
        .accessibilityElement(children: .combine)
    }
}

private struct WorkoutTimerView: View {
    let state: WorkoutActivityAttributes.ContentState
    let compact: Bool
    let isStale: Bool
    var usesWorkoutEndAt = false

    var body: some View {
        Group {
            switch state.status.lowercased() {
            case "paused":
                Text(formatDuration(state.pausedRemainingSeconds))
            case "finished":
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            default:
                let timerEndAt = isStale ||
                    (usesWorkoutEndAt && state.status.lowercased() == "running")
                    ? state.workoutEndAt
                    : state.timerEndAt
                Text(
                    timerInterval: state.timerStartAt...timerEndAt,
                    pauseTime: nil,
                    countsDown: true,
                    showsHours: !compact
                )
            }
        }
        .font(compact ? .caption2.weight(.bold) : .title3.weight(.bold))
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.72)
        .accessibilityLabel(state.statusText)
    }
}

private func workoutProgressTimerInterval(
    for state: WorkoutActivityAttributes.ContentState
) -> ClosedRange<Date>? {
    guard state.status.lowercased() == "running",
          state.progress.isFinite,
          state.progress >= 0,
          state.progress < 1 else {
        return nil
    }

    // The payload snapshot supplies `timerStartAt` as now, the completed
    // fraction as progress, and workoutEndAt as now + remaining. Reconstruct
    // the original workout span so SwiftUI can advance progress system-side.
    let remaining = state.workoutEndAt.timeIntervalSince(state.timerStartAt)
    let remainingFraction = 1 - state.progress
    guard remaining.isFinite,
          remaining > 0,
          remainingFraction > 0 else {
        return nil
    }

    let total = remaining / remainingFraction
    guard total.isFinite, total >= remaining else { return nil }

    let start = state.workoutEndAt.addingTimeInterval(-total)
    guard start.timeIntervalSinceReferenceDate.isFinite,
          start <= state.workoutEndAt else {
        return nil
    }
    return start...state.workoutEndAt
}

private func activityIsStale(
    _ context: ActivityViewContext<WorkoutActivityAttributes>
) -> Bool {
    // staleDate/isStale were added to ActivityKit in iOS 16.2. Keep the
    // extension loadable on its declared iOS 16.1 deployment target.
    if #available(iOS 16.2, *) {
        return context.isStale
    }
    return false
}

private func statusColor(_ status: String) -> Color {
    switch status.lowercased() {
    case "paused":
        return .orange
    case "finished":
        return .green
    default:
        return valcueAccent
    }
}

private func normalizedProgress(_ value: Double) -> Double {
    min(1, max(0, value))
}

private func formatDuration(_ totalSeconds: Int) -> String {
    let seconds = max(0, totalSeconds)
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let remainder = seconds % 60
    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, remainder)
    }
    return String(format: "%02d:%02d", minutes, remainder)
}
