import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static Future<void> init() async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      "high_importance_channel",
      "High Importance Notifications",
      description: "this channel is used for important notifications",
      importance: Importance.high,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.initialize(
      settings: InitializationSettings(android: initializationSettingsAndroid),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    String? abc = await FirebaseMessaging.instance.getToken();
    print("token :$abc");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      // print(notification != null);
      if (notification != null) {
        await flutterLocalNotificationsPlugin.show(
          id: DateTime.now().millisecond,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel', // MUST match your channel id
              'High Importance Notifications',
              channelDescription:
                  'this channel is used for important notifications',
              importance: Importance.max,
              priority: Priority.high,
              fullScreenIntent: true,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }
}
