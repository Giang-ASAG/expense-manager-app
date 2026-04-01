import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Xử lý khi người dùng nhấn vào thông báo
      },
    );

    // ✅ Fix: thêm dấu < bị thiếu
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleDailyReminder() async {
    // ✅ Fix: zonedSchedule v18+ dùng named parameters
    await _notificationsPlugin.zonedSchedule(
      id: 100,
      title: 'Nhắc nhở chi tiêu 📝',
      body: 'Đã 20:00 rồi, hãy dành 1 phút ghi lại các khoản chi hôm nay nhé!',
      scheduledDate: _nextInstanceOfEightPM(),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'expense_reminder_channel',
          'Nhắc nhở hàng ngày',
          channelDescription:
              'Thông báo nhắc nhở ghi chi tiêu lúc 20:00 mỗi ngày',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Đổi tên hàm cho đúng nghĩa (tùy chọn)
  static tz.TZDateTime _nextInstanceOfHalfThreePM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      15,
      40,
    ); // ✅ 20,0 → 15,30

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static tz.TZDateTime _nextInstanceOfEightPM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
