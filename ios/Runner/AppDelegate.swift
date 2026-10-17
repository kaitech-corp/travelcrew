import Flutter
import UIKit
import EventKit
import EventKitUI

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, EKEventEditViewDelegate {
  private var calendarResult: FlutterResult?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(name: "travelcrew/calendar", binaryMessenger: engineBridge.applicationRegistrar.messenger())
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "addTrip" || call.method == "addActivity" else { result(FlutterMethodNotImplemented); return }
      self?.addEvent(call.arguments, timed: call.method == "addActivity", result: result)
    }
  }

  private func addEvent(_ arguments: Any?, timed: Bool, result: @escaping FlutterResult) {
    guard calendarResult == nil else {
      result(FlutterError(code: "busy", message: "A calendar event is already open", details: nil)); return
    }
    guard let data = arguments as? [String: Any] else {
      result(FlutterError(code: "invalid", message: "Invalid calendar event", details: nil)); return
    }
    let start: Date
    let end: Date
    if timed {
      guard let begin = data["startMilliseconds"] as? NSNumber,
            let finish = data["endMilliseconds"] as? NSNumber else {
        result(FlutterError(code: "invalid", message: "Invalid activity times", details: nil)); return
      }
      start = Date(timeIntervalSince1970: begin.doubleValue / 1000)
      end = Date(timeIntervalSince1970: finish.doubleValue / 1000)
    } else {
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.calendar = Calendar(identifier: .gregorian)
      formatter.timeZone = .current
      formatter.dateFormat = "yyyy-MM-dd"
      guard let begin = formatter.date(from: data["startDate"] as? String ?? ""),
            let finish = formatter.date(from: data["endDate"] as? String ?? "") else {
        result(FlutterError(code: "invalid", message: "Invalid trip dates", details: nil)); return
      }
      start = begin
      end = finish
    }
    guard end > start else {
      result(FlutterError(code: "invalid", message: "End must be after start", details: nil)); return
    }
    calendarResult = result
    let store = EKEventStore()
    let presentEditor = { [weak self] in
      guard let self = self else { return }
      let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
      guard var presenter = scenes.filter({ $0.activationState == .foregroundActive })
        .flatMap({ $0.windows }).first(where: { $0.isKeyWindow })?.rootViewController else {
        self.finishCalendar(FlutterError(code: "unavailable", message: "Unable to present Calendar", details: nil)); return
      }
      while let top = presenter.presentedViewController { presenter = top }
      let event = EKEvent(eventStore: store)
      event.title = data["title"] as? String
      event.location = data["location"] as? String
      event.notes = data["notes"] as? String
      event.isAllDay = !timed
      event.startDate = start
      event.endDate = end
      let editor = EKEventEditViewController()
      editor.eventStore = store
      editor.event = event
      editor.editViewDelegate = self
      editor.isModalInPresentation = true
      presenter.present(editor, animated: true)
    }
    if #available(iOS 17.0, *) {
      // EventKitUI handles the save without access to the user's calendar data.
      presentEditor()
    } else {
      store.requestAccess(to: .event) { [weak self] allowed, _ in
        DispatchQueue.main.async {
          if allowed { presentEditor() }
          else { self?.finishCalendar(FlutterError(code: "permission", message: "Calendar access is disabled", details: nil)) }
        }
      }
    }
  }

  private func finishCalendar(_ value: Any?) {
    let result = calendarResult
    calendarResult = nil
    result?(value)
  }

  func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
    controller.dismiss(animated: true) { self.finishCalendar(nil) }
  }
}
