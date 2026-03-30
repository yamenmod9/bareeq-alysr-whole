import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local notifications for payment reminders
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap - could navigate to repayments page
  }

  /// Request notification permissions (mainly for iOS)
  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iOS = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    
    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'payment_reminders',
      'Payment Reminders',
      channelDescription: 'Notifications for upcoming payment reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Show a payment reminder notification
  Future<void> showPaymentReminder({
    required String title,
    required String body,
    int? planId,
  }) async {
    await showNotification(
      id: planId ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: planId != null ? 'plan_$planId' : null,
    );
  }

  /// Store pending payment reminders in shared preferences
  /// This is a simple approach - for production use WorkManager or similar
  Future<void> savePendingReminders(List<Map<String, dynamic>> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final reminderStrings = reminders.map((r) => 
      '${r['planId']}|${r['amount']}|${r['dueDate']}|${r['title']}|${r['body']}'
    ).toList();
    await prefs.setStringList('pending_reminders', reminderStrings);
  }

  /// Check and show due reminders
  Future<void> checkAndShowDueReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderStrings = prefs.getStringList('pending_reminders') ?? [];
    final now = DateTime.now();
    final remainingReminders = <String>[];

    for (final reminderStr in reminderStrings) {
      final parts = reminderStr.split('|');
      if (parts.length >= 5) {
        final dueDate = DateTime.tryParse(parts[2]);
        if (dueDate != null) {
          // Show reminder if due date is within 3 days
          final daysUntilDue = dueDate.difference(now).inDays;
          if (daysUntilDue <= 3 && daysUntilDue >= 0) {
            await showNotification(
              id: int.tryParse(parts[0]) ?? now.millisecondsSinceEpoch ~/ 1000,
              title: parts[3],
              body: parts[4],
              payload: 'plan_${parts[0]}',
            );
          }
          // Keep reminder if due date hasn't passed
          if (dueDate.isAfter(now)) {
            remainingReminders.add(reminderStr);
          }
        }
      }
    }

    // Update stored reminders
    await prefs.setStringList('pending_reminders', remainingReminders);
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel a specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}

