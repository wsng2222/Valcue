import ActivityKit
import Foundation

/// Data shared by the Runner target and the Live Activity widget extension.
///
/// Keep strings display-ready. Flutter owns localization and unit conversion,
/// while the extension remains a small, deterministic SwiftUI renderer.
@available(iOS 16.1, *)
struct WorkoutActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var status: String
        var statusText: String
        var intervalText: String
        var primaryMetric: String
        var secondaryMetric: String
        var durationText: String
        var timerStartAt: Date
        var timerEndAt: Date
        var workoutEndAt: Date
        var pausedRemainingSeconds: Int
        var progress: Double

        init(
            status: String,
            statusText: String,
            intervalText: String,
            primaryMetric: String,
            secondaryMetric: String,
            durationText: String,
            timerStartAt: Date,
            timerEndAt: Date,
            workoutEndAt: Date,
            pausedRemainingSeconds: Int,
            progress: Double
        ) {
            self.status = status
            self.statusText = statusText
            self.intervalText = intervalText
            self.primaryMetric = primaryMetric
            self.secondaryMetric = secondaryMetric
            self.durationText = durationText
            self.timerStartAt = timerStartAt
            self.timerEndAt = timerEndAt
            self.workoutEndAt = workoutEndAt
            self.pausedRemainingSeconds = pausedRemainingSeconds
            self.progress = progress
        }

        /// ActivityKit decodes APNs `content-state` using standard Codable.
        /// Expose Unix milliseconds explicitly so remote payloads use the same
        /// unambiguous time representation as the Flutter method channel.
        private enum CodingKeys: String, CodingKey {
            case status
            case statusText
            case intervalText
            case primaryMetric
            case secondaryMetric
            case durationText
            case timerStartAt = "timerStartAtMs"
            case timerEndAt = "timerEndAtMs"
            case workoutEndAt = "workoutEndAtMs"
            case pausedRemainingSeconds
            case progress
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            status = try container.decode(String.self, forKey: .status)
            statusText = try container.decode(String.self, forKey: .statusText)
            intervalText = try container.decode(String.self, forKey: .intervalText)
            primaryMetric = try container.decode(String.self, forKey: .primaryMetric)
            secondaryMetric = try container.decode(String.self, forKey: .secondaryMetric)
            durationText = try container.decode(String.self, forKey: .durationText)
            timerStartAt = Self.date(
                milliseconds: try container.decode(Int64.self, forKey: .timerStartAt)
            )
            timerEndAt = Self.date(
                milliseconds: try container.decode(Int64.self, forKey: .timerEndAt)
            )
            workoutEndAt = Self.date(
                milliseconds: try container.decode(Int64.self, forKey: .workoutEndAt)
            )
            pausedRemainingSeconds = try container.decode(
                Int.self,
                forKey: .pausedRemainingSeconds
            )
            progress = try container.decode(Double.self, forKey: .progress)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(status, forKey: .status)
            try container.encode(statusText, forKey: .statusText)
            try container.encode(intervalText, forKey: .intervalText)
            try container.encode(primaryMetric, forKey: .primaryMetric)
            try container.encode(secondaryMetric, forKey: .secondaryMetric)
            try container.encode(durationText, forKey: .durationText)
            try container.encode(
                Self.milliseconds(date: timerStartAt),
                forKey: .timerStartAt
            )
            try container.encode(
                Self.milliseconds(date: timerEndAt),
                forKey: .timerEndAt
            )
            try container.encode(
                Self.milliseconds(date: workoutEndAt),
                forKey: .workoutEndAt
            )
            try container.encode(
                pausedRemainingSeconds,
                forKey: .pausedRemainingSeconds
            )
            try container.encode(progress, forKey: .progress)
        }

        private static func date(milliseconds: Int64) -> Date {
            Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
        }

        private static func milliseconds(date: Date) -> Int64 {
            Int64((date.timeIntervalSince1970 * 1000).rounded())
        }
    }

    var routineId: String
    var workoutSessionId: String
    var routineName: String
    var machineType: String
    var machineName: String
    var machineSymbol: String
}
