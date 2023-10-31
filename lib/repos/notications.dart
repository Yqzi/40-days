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

  Future<void> cancelNotification(int id) async {
    notifPlugin.cancel(id);
  }

  notifDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId',
        'channelName',
        // channelDescription: 'channelDescription',
        importance: Importance.max,
      ),
    );
  }

  Future dailyNotif(
      {int id = 0,
      required String title,
      required String body,
      required DateTime time}) async {
    return notifPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      await notifDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
