import Flutter
import Foundation
import HealthKit

/// Writes finished workouts straight into HealthKit.
///
/// The `health` plugin is still used for the permission prompt and for
/// Android, but it always saves a workout with `metadata: nil`. HealthKit has
/// no treadmill or stationary-bike activity - indoor is a metadata flag - so
/// every treadmill session ended up filed as an *outdoor* run, and the plugin
/// offers no way to say otherwise. Writing the sample here also lets us
/// attach active energy so the workout counts towards the activity rings.
final class HealthWorkoutBridge: NSObject {
    static let channelName = "valcue/health_workout"

    private let channel: FlutterMethodChannel
    private let healthStore = HKHealthStore()

    init(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: Self.channelName,
            binaryMessenger: messenger
        )
        super.init()
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }

    private func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "isAvailable":
            result(HKHealthStore.isHealthDataAvailable())
        case "writeWorkout":
            writeWorkout(call.arguments, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func writeWorkout(_ arguments: Any?, result: @escaping FlutterResult) {
        guard HKHealthStore.isHealthDataAvailable() else {
            result(false)
            return
        }
        guard let args = arguments as? [String: Any],
              let activityName = args["activityType"] as? String,
              let startMs = args["startMs"] as? NSNumber,
              let endMs = args["endMs"] as? NSNumber
        else {
            result(false)
            return
        }

        let activityType = Self.activityType(for: activityName)
        let start = Date(timeIntervalSince1970: startMs.doubleValue / 1000)
        let end = Date(timeIntervalSince1970: endMs.doubleValue / 1000)
        guard end > start else {
            result(false)
            return
        }

        // The whole reason this bridge exists: every machine in this app is
        // indoors, and without this flag Health files a treadmill run as an
        // outdoor run.
        var metadata: [String: Any] = [
            HKMetadataKeyIndoorWorkout: NSNumber(value: true)
        ]
        if let title = args["title"] as? String, !title.isEmpty {
            metadata[HKMetadataKeyWorkoutBrandName] = title
        }

        var distance: HKQuantity?
        if let meters = args["distanceMeters"] as? NSNumber, meters.doubleValue > 0 {
            distance = HKQuantity(unit: .meter(), doubleValue: meters.doubleValue)
        }

        var energy: HKQuantity?
        if let kcal = args["activeEnergyKcal"] as? NSNumber, kcal.doubleValue > 0 {
            energy = HKQuantity(unit: .kilocalorie(), doubleValue: kcal.doubleValue)
        }

        if #available(iOS 17.0, *) {
            writeWithBuilder(
                activityType: activityType,
                start: start,
                end: end,
                metadata: metadata,
                distance: distance,
                energy: energy,
                result: result
            )
        } else {
            let workout = HKWorkout(
                activityType: activityType,
                start: start,
                end: end,
                workoutEvents: nil,
                totalEnergyBurned: energy,
                totalDistance: distance,
                metadata: metadata
            )
            healthStore.save(workout) { success, _ in
                DispatchQueue.main.async { result(success) }
            }
        }
    }

    /// iOS 17 deprecated the HKWorkout initialiser in favour of the builder,
    /// which is also the only way to attach energy and distance samples that
    /// the Fitness app will total up.
    @available(iOS 17.0, *)
    private func writeWithBuilder(
        activityType: HKWorkoutActivityType,
        start: Date,
        end: Date,
        metadata: [String: Any],
        distance: HKQuantity?,
        energy: HKQuantity?,
        result: @escaping FlutterResult
    ) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        configuration.locationType = .indoor

        let builder = HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: configuration,
            device: .local()
        )

        var samples: [HKSample] = []
        if let energy, let type = HKQuantityType.quantityType(
            forIdentifier: .activeEnergyBurned
        ) {
            samples.append(
                HKQuantitySample(
                    type: type,
                    quantity: energy,
                    start: start,
                    end: end
                )
            )
        }
        if let distance, let identifier = Self.distanceIdentifier(for: activityType),
           let type = HKQuantityType.quantityType(forIdentifier: identifier) {
            samples.append(
                HKQuantitySample(
                    type: type,
                    quantity: distance,
                    start: start,
                    end: end
                )
            )
        }

        func fail() {
            builder.discardWorkout()
            DispatchQueue.main.async { result(false) }
        }

        builder.beginCollection(withStart: start) { began, _ in
            guard began else {
                fail()
                return
            }
            builder.addMetadata(metadata) { _, _ in
                let finish = {
                    builder.endCollection(withEnd: end) { ended, _ in
                        guard ended else {
                            fail()
                            return
                        }
                        builder.finishWorkout { workout, _ in
                            DispatchQueue.main.async { result(workout != nil) }
                        }
                    }
                }
                if samples.isEmpty {
                    finish()
                } else {
                    // A workout without its energy is still worth keeping, so
                    // this finishes either way - but it must say so, because a
                    // silent failure here looks exactly like "rings not
                    // moving" with nothing to go on.
                    builder.add(samples) { added, error in
                        if !added {
                            NSLog(
                                "HealthWorkoutBridge: energy/distance rejected: %@",
                                error?.localizedDescription ?? "unknown"
                            )
                        }
                        finish()
                    }
                }
            }
        }
    }

    private static func activityType(for name: String) -> HKWorkoutActivityType {
        switch name {
        case "cycling":
            return .cycling
        case "stairClimbing":
            return .stairClimbing
        default:
            return .running
        }
    }

    private static func distanceIdentifier(
        for activityType: HKWorkoutActivityType
    ) -> HKQuantityTypeIdentifier? {
        switch activityType {
        case .running:
            return .distanceWalkingRunning
        case .cycling:
            return .distanceCycling
        default:
            return nil
        }
    }
}
