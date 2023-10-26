// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class NotifService {
//   final FlutterLocalNotificationsPlugin notifPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initNotif() async {
//     AndroidInitializationSettings initSettingsAndroid =
//         const AndroidInitializationSettings('@mipmap/ic_launcher');

//     var initSettings = InitializationSettings(android: initSettingsAndroid);

//     await notifPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse:
//           (NotificationResponse notifResponse) async {},
//     );
//   }

//   notifDetails() {
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'channelId',
//         'channelName',
//         // channelDescription: 'channelDescription',
//         importance: Importance.max,
//       ),
//     );
//   }

//   DateTime now = DateTime.now();

//   Future dailyNotif(
//       {int id = 0, required String title, required String body}) async {
//     // DateTime x = DateTime.utc(now.year, now.month, now.day, 19);
//     // print(x);

//     return notifPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.from(DateTime(now.year, now.month, now.day, 19), tz.local),
//       // tz.TZDateTime.parse(tz.local, x.toString()),
//       await notifDetails(),
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.wallClockTime,
//     );
//   }
// }

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

class Notif {
  final _flnp _notifPlugin = _flnp();

  // initializes the capabilities for notifications.
  Future<bool> initializeNotification() async {
    initializeTimeZones();
    final _ais _androidS = _ais('mipmap/ic_launcher');
    InitializationSettings initSet = InitializationSettings(android: _androidS);
    await _notifPlugin.initialize(initSet,
        onDidReceiveNotificationResponse: (NotificationResponse notifResponse) {
      print(notifResponse);
    });
    return true;
  }

  bool? _isInitialized;

  Future<void> cancelNotification(int id) async {
    _notifPlugin.cancel(id);
  }

  Future<void> scheduleNotification(
    String title,
    String body,
    DateTime time, {
    required int id,
  }) async {
    // initialize notification if not already initialized.
    _isInitialized = _isInitialized ?? await initializeNotification();
    _and ands = const _and(
      'channelID: ',
      'channelName: ',
      importance: Importance.max,
      priority: Priority.high,
      autoCancel: false,
    );

    NotificationDetails nd = NotificationDetails(android: ands);

    return await _notifPlugin.zonedSchedule(
      id,
      title,
      body,
      TZDateTime.from(time, local),
      nd,
      uiLocalNotificationDateInterpretation: _uilnf.absoluteTime,
    );
  }
}

typedef _flnp = FlutterLocalNotificationsPlugin;
typedef _uilnf = UILocalNotificationDateInterpretation;
typedef _ais = AndroidInitializationSettings;
typedef _and = AndroidNotificationDetails;
