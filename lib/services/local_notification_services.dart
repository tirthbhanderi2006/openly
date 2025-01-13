import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService{
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: backgroundNotificationResponseHandler,
    );
  }
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  })async{
    print("Notification : $id $title $body $payload");
    await _flutterLocalNotificationsPlugin.show(id, title, body,
      await notificationDetails(),);
  }

  Future<NotificationDetails> notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId', // Must match the channel ID
        'channelName',
        channelDescription: 'Channel for heads-up notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        ticker: 'ticker',
      ),
    );
  }
}



void backgroundNotificationResponseHandler(NotificationResponse notification) {
  print('Received background notification response: $notification');
}