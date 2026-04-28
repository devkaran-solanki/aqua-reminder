import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    _initialized = true;
  }

  Future<void> requestPermissions() async {
    // Android
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // iOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> scheduleSmartReminders({
    required List<DateTime> drinkReminders,
    required DateTime? morningCheerTime,
    required DateTime? streakMaintainTime,
  }) async {
    if (!_initialized) return;
    
    // Request permissions before scheduling
    await requestPermissions();

    // First, cancel all previously scheduled notifications
    await cancelAllNotifications();
    
    int id = 0;
    
    // 1. Drink Reminders
    for (final nextTime in drinkReminders) {
      if (nextTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: id++,
          title: _getRandomDrinkTitle(),
          body: _getRandomDrinkBody(),
          scheduledTime: nextTime,
        );
      }
    }

    // 2. Morning Cheer
    if (morningCheerTime != null && morningCheerTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: id++,
        title: 'Good Morning! ☀️',
        body: 'You crushed your hydration goal yesterday! Let\'s keep that energy up today. 💪',
        scheduledTime: morningCheerTime,
      );
    }
    
    // 3. Streak maintenance
    if (streakMaintainTime != null && streakMaintainTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: id++,
        title: 'Don\'t break the streak! 🔥',
        body: 'You are close to reaching your goal for today! Have a drink to keep your streak alive.',
        scheduledTime: streakMaintainTime,
      );
    }
  }

  String _getRandomDrinkTitle() {
    final titles = [
      'Time to hydrate! 💧',
      'Drink Water! 🚰',
      'Hydration Check! 💙',
      'Stay Refreshed! 🌊',
      'Time for a sip! 🧊',
      'Quench your thirst! 🌿',
    ];
    return titles[Random().nextInt(titles.length)];
  }

  String _getRandomDrinkBody() {
    final bodies = [
      'Have a glass of water to stay on track with your goal.',
      'A little water goes a long way. Drink up!',
      'Your body needs water. Hydrate now for more energy!',
      'Keep up the good work and drink some water.',
      'Stay hydrated to keep your mind sharp and focused!',
      'You are doing great! Time for another sip of water.',
    ];
    return bodies[Random().nextInt(bodies.length)];
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminder_channel',
          'Water Reminders',
          channelDescription: 'Notifications to remind you to drink water',
          importance: Importance.max,
          priority: Priority.high,
          // Updated to use the native drawable filename without extension
          icon: 'notification_white', 
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
