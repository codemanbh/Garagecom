import './apiHelper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

class notificationHelper {
  static Future<String> getNotiToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String token = '';
    if(Platform.isAndroid) {
      NotificationSettings settings = await messaging.requestPermission();
      print('User granted permission: ${settings.authorizationStatus}');

    // 2) Get the token
      token = await messaging.getToken() ?? '';
    }
    // 1) Request permissions on iOS
    

    return token;
  }
}
