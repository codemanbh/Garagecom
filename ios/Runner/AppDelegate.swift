import UIKit
import Flutter
import Firebase
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 1️⃣ Init Firebase
    FirebaseApp.configure()

    // 2️⃣ Request permission & register for APNs
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let opts: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current()
        .requestAuthorization(options: opts) { granted, error in
          // you can inspect granted / error here
        }
    } else {
      let settings = UIUserNotificationSettings(
        types: [.alert, .badge, .sound],
        categories: nil
      )
      application.registerUserNotificationSettings(settings)
    }
    application.registerForRemoteNotifications()

    // 3️⃣ Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // 4️⃣ Hand APNs token off to FCM
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}
