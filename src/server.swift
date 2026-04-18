import Cocoa
import InputMethodKit
import TaigiTelexLib

class NSManualApplication: NSApplication {
  private let appDelegate = AppDelegate()

  override init() {
    super.init()
    delegate = appDelegate
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("Unreachable path")
  }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  static var server = IMKServer()
  func applicationDidFinishLaunching(_: Notification) {
    AppDelegate.server = IMKServer(
      name: Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String,
      bundleIdentifier: Bundle.main.bundleIdentifier)
  }

  func applicationWillTerminate(_: Notification) {}
}
