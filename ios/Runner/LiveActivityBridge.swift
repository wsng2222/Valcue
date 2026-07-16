import ActivityKit
import Flutter
import Foundation
import UIKit

private struct PersistedLiveActivityRegistration: Codable {
    var activityId: String
    var routineId: String
    var workoutSessionId: String
    var tokenHex: String?
    var tokenVersion: Int
    var environment: String
    var updatedAtMs: Int64
}

/// Bridges Flutter workout state into ActivityKit without exposing native
/// Activity objects to Dart. All method arguments are JSON-compatible maps.
final class LiveActivityBridge: NSObject, FlutterStreamHandler {
    static let channelName = "valcue/live_activity"
    static let eventChannelName = "valcue/live_activity/events"
    private static let registrationStorageKey =
        "valcue.liveActivity.pushRegistrations.v1"
    private static let eventSchemaVersion = 1
    private static let apnsEnvironment = resolveAPNsEnvironment()

    private let channel: FlutterMethodChannel
    private let eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?
    private var activityUpdatesTask: Task<Void, Never>?
    private var pushTokenObservationTasks: [String: Task<Void, Never>] = [:]
    private var activityStateObservationTasks: [String: Task<Void, Never>] = [:]
    private var pushTokensByActivityId: [String: String] = [:]
    private var tokenVersionsByActivityId: [String: Int] = [:]
    private var persistedRegistrationsByActivityId:
        [String: PersistedLiveActivityRegistration] = [:]
    private var invalidatedActivityIds: Set<String> = []
    private var pendingTerminalEvents: [[String: Any]] = []

    init(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: Self.channelName,
            binaryMessenger: messenger
        )
        eventChannel = FlutterEventChannel(
            name: Self.eventChannelName,
            binaryMessenger: messenger
        )
        super.init()
        restorePersistedRegistrations()
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
        eventChannel.setStreamHandler(self)

        if #available(iOS 16.2, *) {
            Task { @MainActor [weak self] in
                self?.beginObservingActivities()
            }
        }
    }

    deinit {
        activityUpdatesTask?.cancel()
        pushTokenObservationTasks.values.forEach { $0.cancel() }
        activityStateObservationTasks.values.forEach { $0.cancel() }
        channel.setMethodCallHandler(nil)
        eventChannel.setStreamHandler(nil)
    }

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        Task { @MainActor [weak self] in
            guard let self else { return }
            if #available(iOS 16.2, *) {
                self.attachEventSink(events)
            } else {
                self.eventSink = events
            }
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        Task { @MainActor [weak self] in
            self?.eventSink = nil
        }
        return nil
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isSupported":
            // iOS 16.2 added stale-date rendering. Earlier versions can't
            // safely hide an interval snapshot after its deadline, so use the
            // local-notification fallback there instead.
            if #available(iOS 16.2, *) {
                result(true)
            } else {
                result(false)
            }

        case "areActivitiesEnabled":
            if #available(iOS 16.2, *) {
                result(ActivityAuthorizationInfo().areActivitiesEnabled)
            } else {
                result(false)
            }

        case "getPushRegistrations":
            guard #available(iOS 16.2, *) else {
                result([])
                return
            }
            Task { @MainActor [weak self] in
                result(self?.pushRegistrations() ?? [])
            }

        case "start":
            guard #available(iOS 16.2, *) else {
                result(false)
                return
            }
            let payload = Self.payload(from: call.arguments)
            Task { @MainActor [weak self] in
                guard let self else {
                    result(false)
                    return
                }
                let response = await self.startSession(payload: payload)
                result(response["started"] as? Bool ?? false)
            }

        case "startSession":
            guard #available(iOS 16.2, *) else {
                result([
                    "started": false,
                    "activityId": "",
                    "workoutSessionId": "",
                    "remotePushEnabled": false,
                    "environment": Self.apnsEnvironment,
                ])
                return
            }
            let payload = Self.payload(from: call.arguments)
            Task { @MainActor [weak self] in
                guard let self else {
                    result([
                        "started": false,
                        "activityId": "",
                        "workoutSessionId": "",
                        "remotePushEnabled": false,
                        "environment": Self.apnsEnvironment,
                    ])
                    return
                }
                result(await self.startSession(payload: payload))
            }

        case "update":
            guard #available(iOS 16.1, *) else {
                result(nil)
                return
            }
            let payload = Self.payload(from: call.arguments)
            Task { @MainActor [weak self] in
                await self?.update(payload: payload)
                result(nil)
            }

        case "end":
            guard #available(iOS 16.1, *) else {
                result(nil)
                return
            }
            let payload = Self.payload(from: call.arguments)
            Task { @MainActor [weak self] in
                await self?.end(payload: payload)
                result(nil)
            }

        case "cleanup":
            guard #available(iOS 16.1, *) else {
                result(nil)
                return
            }
            Task { @MainActor [weak self] in
                await self?.cleanup()
                result(nil)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

private extension LiveActivityBridge {
    func restorePersistedRegistrations() {
        guard let data = UserDefaults.standard.data(
            forKey: Self.registrationStorageKey
        ),
        let registrations = try? JSONDecoder().decode(
            [PersistedLiveActivityRegistration].self,
            from: data
        ) else {
            return
        }

        for registration in registrations where !registration.activityId.isEmpty {
            persistedRegistrationsByActivityId[registration.activityId] = registration
            tokenVersionsByActivityId[registration.activityId] = max(
                0,
                registration.tokenVersion
            )
            if let token = registration.tokenHex, !token.isEmpty {
                pushTokensByActivityId[registration.activityId] = token
            }
        }
    }

    func savePersistedRegistrations() {
        guard !persistedRegistrationsByActivityId.isEmpty else {
            UserDefaults.standard.removeObject(
                forKey: Self.registrationStorageKey
            )
            return
        }

        let registrations = persistedRegistrationsByActivityId.values.sorted {
            $0.activityId < $1.activityId
        }
        guard let data = try? JSONEncoder().encode(registrations) else { return }
        UserDefaults.standard.set(data, forKey: Self.registrationStorageKey)
    }

    static func resolveAPNsEnvironment() -> String {
        // iOS has no public API for reading the signed aps-environment
        // entitlement. Runner/Info.plist mirrors the exact APS_ENVIRONMENT
        // build setting used by Runner.entitlements.
        if let value = Bundle.main.object(
            forInfoDictionaryKey: "ValcueAPNsEnvironment"
        ) as? String {
            if value == "production" { return "production" }
            if value == "development" { return "sandbox" }
        }

        #if DEBUG
        return "sandbox"
        #else
        return "production"
        #endif
    }

    static func nowMilliseconds() -> Int64 {
        Int64((Date().timeIntervalSince1970 * 1000).rounded())
    }
}

@available(iOS 16.1, *)
private extension LiveActivityBridge {
    typealias WorkoutActivity = Activity<WorkoutActivityAttributes>
    typealias WorkoutState = WorkoutActivityAttributes.ContentState

    @available(iOS 16.2, *)
    @MainActor
    func startSession(payload: [String: Any]) async -> [String: Any] {
        let attributes = makeAttributes(from: payload)
        guard ActivityAuthorizationInfo().areActivitiesEnabled,
              UIApplication.shared.applicationState == .active else {
            return startResponse(
                started: false,
                activityId: nil,
                attributes: attributes
            )
        }

        // A Flutter method-channel response can be lost even after
        // ActivityKit successfully created the activity. Reuse the activity
        // for the same workout session so a bounded Dart retry cannot rotate
        // activity IDs underneath an already registered server schedule.
        if let existingActivity = WorkoutActivity.activities.first(where: {
            $0.attributes.workoutSessionId == attributes.workoutSessionId
        }) {
            observe(existingActivity)
            return startResponse(
                started: true,
                activityId: existingActivity.id,
                attributes: existingActivity.attributes
            )
        }

        // PacePilot has one active workout at a time. Ending stale activities
        // from another session prevents more than one workout from occupying
        // the Dynamic Island.
        await cleanup()

        let state = makeState(from: payload, fallback: nil)

        do {
            let activity = try WorkoutActivity.request(
                attributes: attributes,
                content: ActivityContent(
                    state: state,
                    staleDate: staleDate(for: state),
                    relevanceScore: 100
                ),
                pushType: .token
            )
            observe(activity)
            return startResponse(
                started: true,
                activityId: activity.id,
                attributes: attributes
            )
        } catch {
            NSLog("[LiveActivityBridge] Unable to start Live Activity: %@", String(describing: error))
            return startResponse(
                started: false,
                activityId: nil,
                attributes: attributes
            )
        }
    }

    @available(iOS 16.2, *)
    func startResponse(
        started: Bool,
        activityId: String?,
        attributes: WorkoutActivityAttributes
    ) -> [String: Any] {
        [
            "started": started,
            "activityId": activityId ?? "",
            "workoutSessionId": attributes.workoutSessionId,
            "remotePushEnabled": started,
            "environment": Self.apnsEnvironment,
        ]
    }

    @MainActor
    func update(payload: [String: Any]) async {
        let activities = matchingActivities(for: payload)
        guard !activities.isEmpty else { return }

        for activity in activities {
            let state = makeState(
                from: payload,
                fallback: currentState(of: activity)
            )
            if #available(iOS 16.2, *) {
                await activity.update(
                    ActivityContent(
                        state: state,
                        staleDate: staleDate(for: state),
                        relevanceScore: 100
                    )
                )
            } else {
                await activity.update(using: state)
            }
        }
    }

    @MainActor
    func end(payload: [String: Any]) async {
        let activities = matchingActivities(for: payload)
        guard !activities.isEmpty else { return }

        let hasFinalPayload = !payload.isEmpty
        let dismissImmediately = Self.bool(payload["dismissImmediately"]) ?? false
        let dismissalDelaySeconds = max(
            0,
            Self.int(payload["dismissalDelaySeconds"]) ?? 0
        )

        for activity in activities {
            if #available(iOS 16.2, *) {
                invalidatePushToken(for: activity, reason: "localEnd")
            }
            let finalState = hasFinalPayload
                ? makeState(from: payload, fallback: currentState(of: activity))
                : currentState(of: activity)
            let dismissalPolicy: ActivityUIDismissalPolicy
            if dismissImmediately {
                dismissalPolicy = .immediate
            } else if dismissalDelaySeconds > 0 {
                dismissalPolicy = .after(
                    Date().addingTimeInterval(TimeInterval(dismissalDelaySeconds))
                )
            } else {
                dismissalPolicy = .default
            }

            if #available(iOS 16.2, *) {
                await activity.end(
                    ActivityContent(
                        state: finalState,
                        staleDate: nil,
                        relevanceScore: 100
                    ),
                    dismissalPolicy: dismissalPolicy
                )
            } else {
                await activity.end(
                    using: finalState,
                    dismissalPolicy: dismissalPolicy
                )
            }
        }
    }

    @MainActor
    func cleanup() async {
        for activity in WorkoutActivity.activities {
            if #available(iOS 16.2, *) {
                invalidatePushToken(for: activity, reason: "cleanup")
            }
            if #available(iOS 16.2, *) {
                await activity.end(nil, dismissalPolicy: .immediate)
            } else {
                await activity.end(using: nil, dismissalPolicy: .immediate)
            }
        }
    }

    @available(iOS 16.2, *)
    @MainActor
    func beginObservingActivities() {
        let activities = WorkoutActivity.activities
        reconcilePersistedRegistrations(with: activities)
        for activity in activities {
            observe(activity, emitsLifecycleEvent: false)
        }

        activityUpdatesTask?.cancel()
        activityUpdatesTask = Task { @MainActor [weak self] in
            for await activity in WorkoutActivity.activityUpdates {
                guard !Task.isCancelled, let self else { return }
                self.observe(activity)
            }
        }
    }

    @available(iOS 16.2, *)
    @MainActor
    func observe(
        _ activity: WorkoutActivity,
        emitsLifecycleEvent: Bool = true
    ) {
        let activityId = activity.id
        let isNewObservation = pushTokenObservationTasks[activityId] == nil &&
            activityStateObservationTasks[activityId] == nil
        invalidatedActivityIds.remove(activityId)
        persistRegistration(for: activity)

        if isNewObservation && emitsLifecycleEvent {
            emitEvent(baseEvent(type: "activityStarted", activity: activity))
            emitActivityState(activity.activityState, for: activity)
        }

        if pushTokenObservationTasks[activityId] == nil {
            pushTokenObservationTasks[activityId] = Task {
                @MainActor [weak self, weak activity] in
                guard let activity else { return }
                for await tokenData in activity.pushTokenUpdates {
                    guard !Task.isCancelled, let self else { return }
                    self.recordPushToken(tokenData, for: activity)
                }
            }
        }

        if activityStateObservationTasks[activityId] == nil {
            activityStateObservationTasks[activityId] = Task {
                @MainActor [weak self, weak activity] in
                guard let activity else { return }
                for await state in activity.activityStateUpdates {
                    guard !Task.isCancelled, let self else { return }
                    self.handleActivityStateUpdate(state, for: activity)
                    if self.isTerminalActivityState(state) { return }
                }
            }
        }

        if let tokenData = activity.pushToken {
            recordPushToken(
                tokenData,
                for: activity,
                emitsEvent: emitsLifecycleEvent
            )
        }
    }

    @available(iOS 16.2, *)
    @MainActor
    func attachEventSink(_ sink: @escaping FlutterEventSink) {
        eventSink = sink

        let terminalEvents = pendingTerminalEvents
        pendingTerminalEvents.removeAll(keepingCapacity: true)
        terminalEvents.forEach { sink($0) }

        let activities = WorkoutActivity.activities
        reconcilePersistedRegistrations(with: activities)
        for activity in activities {
            observe(activity, emitsLifecycleEvent: false)
            sink(registrationSnapshot(for: activity, eventType: "activitySnapshot"))
        }
    }

    @available(iOS 16.2, *)
    @MainActor
    func pushRegistrations() -> [[String: Any]] {
        let activities = WorkoutActivity.activities
        reconcilePersistedRegistrations(with: activities)
        return activities.map { activity in
            observe(activity, emitsLifecycleEvent: false)
            return registrationSnapshot(
                for: activity,
                eventType: "activitySnapshot"
            )
        }
    }

    @available(iOS 16.2, *)
    @MainActor
    func persistRegistration(for activity: WorkoutActivity) {
        let activityId = activity.id
        let existing = persistedRegistrationsByActivityId[activityId]
        let token = pushTokensByActivityId[activityId] ?? existing?.tokenHex
        let tokenVersion = tokenVersionsByActivityId[activityId]
            ?? existing?.tokenVersion
            ?? 0

        if existing?.routineId == activity.attributes.routineId,
           existing?.workoutSessionId == activity.attributes.workoutSessionId,
           existing?.tokenHex == token,
           existing?.tokenVersion == tokenVersion,
           existing?.environment == Self.apnsEnvironment {
            return
        }

        persistedRegistrationsByActivityId[activityId] =
            PersistedLiveActivityRegistration(
                activityId: activityId,
                routineId: activity.attributes.routineId,
                workoutSessionId: activity.attributes.workoutSessionId,
                tokenHex: token,
                tokenVersion: tokenVersion,
                environment: Self.apnsEnvironment,
                updatedAtMs: Self.nowMilliseconds()
            )
        savePersistedRegistrations()
    }

    @available(iOS 16.2, *)
    @MainActor
    func reconcilePersistedRegistrations(
        with activities: [WorkoutActivity]
    ) {
        let activeActivityIds = Set(activities.map(\.id))
        let obsoleteRegistrations = persistedRegistrationsByActivityId.values
            .filter {
                !activeActivityIds.contains($0.activityId) ||
                    $0.environment != Self.apnsEnvironment
            }
        guard !obsoleteRegistrations.isEmpty else { return }

        for registration in obsoleteRegistrations {
            var event: [String: Any] = [
                "type": "pushTokenInvalidated",
                "schemaVersion": Self.eventSchemaVersion,
                "activityId": registration.activityId,
                "routineId": registration.routineId,
                "workoutSessionId": registration.workoutSessionId,
                "environment": registration.environment,
                "version": registration.tokenVersion,
                "timestampMs": Self.nowMilliseconds(),
                "reason": registration.environment == Self.apnsEnvironment
                    ? "activityMissingOnRestore"
                    : "environmentChanged",
            ]
            if let token = registration.tokenHex, !token.isEmpty {
                event["tokenHex"] = token
            }
            emitEvent(event, queueWhenDisconnected: true)

            invalidatedActivityIds.insert(registration.activityId)
            pushTokensByActivityId.removeValue(forKey: registration.activityId)
            tokenVersionsByActivityId.removeValue(
                forKey: registration.activityId
            )
            persistedRegistrationsByActivityId.removeValue(
                forKey: registration.activityId
            )
        }
        savePersistedRegistrations()
    }

    @available(iOS 16.2, *)
    @MainActor
    func removePersistedRegistration(activityId: String) {
        guard persistedRegistrationsByActivityId.removeValue(
            forKey: activityId
        ) != nil else {
            return
        }
        savePersistedRegistrations()
    }

    @available(iOS 16.2, *)
    @MainActor
    func recordPushToken(
        _ tokenData: Data,
        for activity: WorkoutActivity,
        emitsEvent: Bool = true
    ) {
        let token = Self.hexString(tokenData)
        guard !token.isEmpty else { return }

        let previousToken = pushTokensByActivityId[activity.id]
        if token == previousToken {
            persistRegistration(for: activity)
            return
        }

        let tokenVersion = max(
            0,
            tokenVersionsByActivityId[activity.id] ?? 0
        ) + 1
        pushTokensByActivityId[activity.id] = token
        tokenVersionsByActivityId[activity.id] = tokenVersion
        persistRegistration(for: activity)

        guard emitsEvent else { return }
        var event = baseEvent(type: "pushToken", activity: activity)
        event["tokenHex"] = token
        event["version"] = tokenVersion
        if let previousToken {
            event["previousTokenHex"] = previousToken
        }
        emitEvent(event)
    }

    @available(iOS 16.2, *)
    @MainActor
    func invalidatePushToken(
        for activity: WorkoutActivity,
        reason: String
    ) {
        guard invalidatedActivityIds.insert(activity.id).inserted else { return }

        let token = pushTokensByActivityId.removeValue(forKey: activity.id)
            ?? activity.pushToken.map(Self.hexString)
        let tokenVersion = tokenVersionsByActivityId.removeValue(
            forKey: activity.id
        ) ?? 0
        removePersistedRegistration(activityId: activity.id)
        pushTokenObservationTasks.removeValue(forKey: activity.id)?.cancel()

        var event = baseEvent(type: "pushTokenInvalidated", activity: activity)
        event["reason"] = reason
        if let token, !token.isEmpty {
            event["tokenHex"] = token
        }
        event["version"] = tokenVersion
        emitEvent(event, queueWhenDisconnected: true)
    }

    @available(iOS 16.2, *)
    @MainActor
    func handleActivityStateUpdate(
        _ state: ActivityState,
        for activity: WorkoutActivity
    ) {
        emitActivityState(state, for: activity)
        guard isTerminalActivityState(state) else { return }

        invalidatePushToken(
            for: activity,
            reason: "activityState.\(activityStateName(state))"
        )
        activityStateObservationTasks.removeValue(forKey: activity.id)
    }

    @available(iOS 16.2, *)
    @MainActor
    func emitActivityState(
        _ state: ActivityState,
        for activity: WorkoutActivity
    ) {
        var event = baseEvent(type: "activityState", activity: activity)
        event["state"] = activityStateName(state)
        emitEvent(
            event,
            queueWhenDisconnected: isTerminalActivityState(state)
        )
    }

    @available(iOS 16.2, *)
    func registrationSnapshot(
        for activity: WorkoutActivity,
        eventType: String
    ) -> [String: Any] {
        var snapshot = baseEvent(type: eventType, activity: activity)
        snapshot["state"] = activityStateName(activity.activityState)
        let token = pushTokensByActivityId[activity.id]
            ?? activity.pushToken.map(Self.hexString)
        if let token, !token.isEmpty {
            snapshot["tokenHex"] = token
        }
        snapshot["version"] = tokenVersionsByActivityId[activity.id] ?? 0
        return snapshot
    }

    @available(iOS 16.2, *)
    func baseEvent(
        type: String,
        activity: WorkoutActivity
    ) -> [String: Any] {
        [
            "type": type,
            "schemaVersion": Self.eventSchemaVersion,
            "activityId": activity.id,
            "routineId": activity.attributes.routineId,
            "workoutSessionId": activity.attributes.workoutSessionId,
            "environment": Self.apnsEnvironment,
            "timestampMs": Self.nowMilliseconds(),
        ]
    }

    @available(iOS 16.2, *)
    @MainActor
    func emitEvent(
        _ event: [String: Any],
        queueWhenDisconnected: Bool = false
    ) {
        guard let eventSink else {
            if queueWhenDisconnected {
                if pendingTerminalEvents.count >= 32 {
                    pendingTerminalEvents.removeFirst()
                }
                pendingTerminalEvents.append(event)
            }
            return
        }
        eventSink(event)
    }

    @available(iOS 16.2, *)
    func activityStateName(_ state: ActivityState) -> String {
        if state == .active { return "active" }
        if state == .stale { return "stale" }
        if state == .ended { return "ended" }
        if state == .dismissed { return "dismissed" }
        if #available(iOS 26.0, *), state == .pending { return "pending" }
        return "unknown"
    }

    @available(iOS 16.2, *)
    func isTerminalActivityState(_ state: ActivityState) -> Bool {
        state == .ended || state == .dismissed
    }

    static func hexString(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    func matchingActivities(for payload: [String: Any]) -> [WorkoutActivity] {
        if let workoutSessionId = Self.string(payload["workoutSessionId"]),
           !workoutSessionId.isEmpty {
            return WorkoutActivity.activities.filter {
                $0.attributes.workoutSessionId == workoutSessionId
            }
        }
        guard let routineId = Self.string(payload["routineId"]),
              !routineId.isEmpty else {
            return WorkoutActivity.activities
        }
        return WorkoutActivity.activities.filter {
            $0.attributes.routineId == routineId
        }
    }

    func currentState(of activity: WorkoutActivity) -> WorkoutState {
        if #available(iOS 16.2, *) {
            return activity.content.state
        }
        return activity.contentState
    }

    func makeAttributes(from payload: [String: Any]) -> WorkoutActivityAttributes {
        let machineType = Self.string(payload["machineType"]) ?? "treadmill"
        return WorkoutActivityAttributes(
            routineId: Self.string(payload["routineId"]) ?? UUID().uuidString,
            workoutSessionId: Self.string(payload["workoutSessionId"])
                ?? UUID().uuidString,
            routineName: Self.string(payload["routineName"]) ?? "Workout",
            machineType: machineType,
            machineName: Self.string(payload["machineName"])
                ?? Self.defaultMachineName(for: machineType),
            machineSymbol: Self.string(payload["machineSymbol"])
                ?? Self.defaultMachineSymbol(for: machineType)
        )
    }

    func makeState(
        from payload: [String: Any],
        fallback: WorkoutState?
    ) -> WorkoutState {
        let now = Date()
        let status = Self.string(payload["status"])
            ?? fallback?.status
            ?? "preparing"
        let timerStartAt = Self.date(milliseconds: payload["timerStartAtMs"])
            ?? fallback?.timerStartAt
            ?? now
        let rawTimerEndAt = Self.date(milliseconds: payload["timerEndAtMs"])
            ?? fallback?.timerEndAt
            ?? timerStartAt
        let timerEndAt = max(rawTimerEndAt, timerStartAt)
        let workoutEndAt = Self.date(milliseconds: payload["workoutEndAtMs"])
            ?? fallback?.workoutEndAt
            ?? timerEndAt
        let pausedRemainingSeconds = max(
            0,
            Self.int(payload["pausedRemainingSeconds"])
                ?? fallback?.pausedRemainingSeconds
                ?? 0
        )
        let progress = min(
            1,
            max(
                0,
                Self.double(payload["progress"])
                    ?? fallback?.progress
                    ?? 0
            )
        )

        return WorkoutState(
            status: status,
            statusText: Self.string(payload["statusText"])
                ?? fallback?.statusText
                ?? Self.defaultStatusText(for: status),
            intervalText: Self.string(payload["intervalText"])
                ?? fallback?.intervalText
                ?? "--/--",
            primaryMetric: Self.string(payload["primaryMetric"])
                ?? fallback?.primaryMetric
                ?? "",
            secondaryMetric: Self.string(payload["secondaryMetric"])
                ?? fallback?.secondaryMetric
                ?? "",
            durationText: Self.string(payload["durationText"])
                ?? fallback?.durationText
                ?? "",
            timerStartAt: timerStartAt,
            timerEndAt: timerEndAt,
            workoutEndAt: max(workoutEndAt, timerEndAt),
            pausedRemainingSeconds: pausedRemainingSeconds,
            progress: progress
        )
    }

    func staleDate(for state: WorkoutState) -> Date? {
        switch state.status.lowercased() {
        case "preparing", "running":
            // A Live Activity cannot advance arbitrary interval data on its
            // own. Mark this snapshot stale at the next interval/countdown
            // boundary so the extension can stop presenting old metrics.
            return state.timerEndAt
        default:
            return nil
        }
    }

    static func payload(from arguments: Any?) -> [String: Any] {
        guard let dictionary = arguments as? [String: Any] else { return [:] }
        // Accept both the documented flat map and `{ "payload": { ... } }`
        // to keep the native bridge tolerant while Flutter integration lands.
        return dictionary["payload"] as? [String: Any] ?? dictionary
    }

    static func string(_ value: Any?) -> String? {
        switch value {
        case let value as String:
            return value
        case let value as NSNumber:
            return value.stringValue
        default:
            return nil
        }
    }

    static func int(_ value: Any?) -> Int? {
        switch value {
        case let value as Int:
            return value
        case let value as NSNumber:
            return value.intValue
        case let value as String:
            return Int(value)
        default:
            return nil
        }
    }

    static func double(_ value: Any?) -> Double? {
        switch value {
        case let value as Double:
            return value
        case let value as NSNumber:
            return value.doubleValue
        case let value as String:
            return Double(value)
        default:
            return nil
        }
    }

    static func bool(_ value: Any?) -> Bool? {
        switch value {
        case let value as Bool:
            return value
        case let value as NSNumber:
            return value.boolValue
        case let value as String:
            return ["true", "1", "yes"].contains(value.lowercased())
        default:
            return nil
        }
    }

    static func date(milliseconds value: Any?) -> Date? {
        guard let milliseconds = double(value), milliseconds > 0 else {
            return nil
        }
        return Date(timeIntervalSince1970: milliseconds / 1000)
    }

    static func defaultMachineName(for machineType: String) -> String {
        switch machineType.lowercased() {
        case "cycle", "bike", "bicycle":
            return "Cycle"
        case "stairmaster", "stairs", "stair":
            return "Stairmaster"
        default:
            return "Treadmill"
        }
    }

    static func defaultMachineSymbol(for machineType: String) -> String {
        switch machineType.lowercased() {
        case "cycle", "bike", "bicycle":
            return "bicycle"
        case "stairmaster", "stairs", "stair":
            return "figure.stairs"
        default:
            return "figure.run"
        }
    }

    static func defaultStatusText(for status: String) -> String {
        switch status.lowercased() {
        case "running":
            return "In progress"
        case "paused":
            return "Paused"
        case "finished":
            return "Workout complete"
        default:
            return "Get ready"
        }
    }
}
