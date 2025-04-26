import './apiHelper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class notificationHelper {
  static Future<String> getNotiToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1) Request permissions on iOS
    NotificationSettings settings = await messaging.requestPermission();
    print('User granted permission: ${settings.authorizationStatus}');

    // 2) Get the token
    String token = await messaging.getToken() ?? '';

    return token;
  }
}
