import 'package:firebase_messaging/firebase_messaging.dart';

import '../../main.dart';
import 'local_notification_services.dart';

class FirebaseNotificationServices{
  // for foreground messages and handle notifications
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize push notifications for background and terminated states
  Future<void> initPushNotification() async {
    // Handle messages when the app is launched from a terminated state
    _firebaseMessaging.getInitialMessage().then(handleMessage);
    // Handle messages when the app is reopened from the background
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  Future<void> initNotification() async {
    // Request notification permissions
    await _firebaseMessaging.requestPermission();

    // Get and print the FCM token for debugging purposes
    final String? fcmToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fcmToken");

    //calling when init() invoke
    handleForegroundMessage();
  }
  void handleForegroundMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title}");
      if (message.notification != null) {
        NotificationService().showNotification(
          id: message.hashCode,
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
        );
      }
    },);
  }

  /// Navigate to a specific screen based on the message payload
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    navigatorKey.currentState?.pushNamed(
      '/local_notification',
      arguments: message,
    );
  }

}
