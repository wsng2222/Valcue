import UIKit
import Flutter
import AVFoundation
import ObjectiveC

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var liveActivityBridge: LiveActivityBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Workaround for GULUserDefaults synchronize unrecognized selector crash in GoogleUtilities 8.x
    if let gulUserDefaultsClass = NSClassFromString("GULUserDefaults") {
      let block: @convention(block) (AnyObject) -> Bool = { _ in
        return true
      }
      let imp = imp_implementationWithBlock(block)
      class_addMethod(gulUserDefaultsClass, NSSelectorFromString("synchronize"), imp, "B@:")
    }

    // Configure audio session to play sounds even in silent mode
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Failed to set audio session category: \(error)")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    if let flutterViewController = window?.rootViewController as? FlutterViewController {
      liveActivityBridge = LiveActivityBridge(
        messenger: flutterViewController.binaryMessenger
      )
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// Workaround for legacy GoogleUtilitiesComponents linking errors with GoogleUtilities 8.x
@_cdecl("GULLogBasic")
public func GULLogBasic() {
  // Empty stub to satisfy Undefined symbol: _GULLogBasic
}

@_cdecl("GULLogError")
public func GULLogError() {
  // Empty stub to satisfy Undefined symbol: _GULLogError
}
