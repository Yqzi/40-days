import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotifService {
  final FlutterLocalNotificationsPlugin notifPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotif() async {
    AndroidInitializationSettings initSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initSettings = InitializationSettings(android: initSettingsAndroid);

    await notifPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notifResponse) async {},
    );
  }

  notifDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
      'channelId 1',
      'channelName 1',
      importance: Importance.max,
    ));
  }

  DateTime now = DateTime.now();

  Future dailyNotif(
      {int id = 0, required String title, required String body}) async {
    return notifPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(DateTime(now.year, now.month, now.day, 19), tz.local),
      await notifDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
