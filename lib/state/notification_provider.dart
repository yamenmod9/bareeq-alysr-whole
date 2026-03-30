import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Model for in-app notifications
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? type; // 'payment_reminder', 'transaction', etc.
  final String? payload;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.type,
    this.payload,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
    'type': type,
    'payload': payload,
    'isRead': isRead,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    type: json['type'] as String?,
    payload: json['payload'] as String?,
    isRead: json['isRead'] as bool? ?? false,
  );
}

/// Provider for managing in-app notifications
class InAppNotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _loaded = false;

  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;

  /// Load notifications from storage
  Future<void> load() async {
    if (_loaded) return;
    
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('app_notifications');
    
    if (jsonStr != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonStr);
        _notifications = jsonList
            .map((j) => AppNotification.fromJson(j as Map<String, dynamic>))
            .toList();
        // Sort by date, newest first
        _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (e) {
        debugPrint('Error loading notifications: $e');
        _notifications = [];
      }
    }
    
    _loaded = true;
    notifyListeners();
  }

  /// Save notifications to storage
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _notifications.map((n) => n.toJson()).toList();
    await prefs.setString('app_notifications', json.encode(jsonList));
  }

  /// Add a new notification
  Future<void> addNotification({
    required String title,
    required String body,
    String? type,
    String? payload,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      createdAt: DateTime.now(),
      type: type,
      payload: payload,
    );
    
    _notifications.insert(0, notification);
    await _save();
    notifyListeners();
  }

  /// Add a payment reminder notification
  Future<void> addPaymentReminder({
    required String title,
    required String body,
    int? planId,
    DateTime? dueDate,
  }) async {
    await addNotification(
      title: title,
      body: body,
      type: 'payment_reminder',
      payload: planId != null ? 'plan_$planId' : null,
    );
  }

  /// Mark a notification as read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      await _save();
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (final notification in _notifications) {
      notification.isRead = true;
    }
    await _save();
    notifyListeners();
  }

  /// Delete a notification
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    await _save();
    notifyListeners();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    _notifications.clear();
    await _save();
    notifyListeners();
  }

  /// Check for upcoming payment reminders and create notifications
  Future<void> checkUpcomingPayments(List<dynamic> repaymentPlans) async {
    final now = DateTime.now();
    
    for (final plan in repaymentPlans) {
      final status = plan['status']?.toString().toLowerCase();
      if (status != 'active' && status != 'pending') continue;
      
      final totalMonths = plan['plan_months'] ?? plan['installment_months'] ?? 0;
      final totalAmount = double.tryParse(plan['total_amount']?.toString() ?? '0') ?? 0;
      final remainingAmount = double.tryParse(plan['remaining_amount']?.toString() ?? '0') ?? 0;
      final paidAmount = totalAmount - remainingAmount;
      final monthlyPayment = totalMonths > 0 ? totalAmount / totalMonths : totalAmount;
      final paidMonths = monthlyPayment > 0 ? (paidAmount / monthlyPayment).floor() : 0;
      
      final createdAt = plan['created_at'] ?? plan['transaction_date'];
      if (createdAt == null) continue;
      
      final startDate = DateTime.tryParse(createdAt.toString());
      if (startDate == null) continue;
      
      // Calculate next payment date
      if (paidMonths < totalMonths) {
        final nextPaymentDate = DateTime(
          startDate.year,
          startDate.month + paidMonths + 1,
          startDate.day,
        );
        
        final daysUntilDue = nextPaymentDate.difference(now).inDays;
        
        // Create reminder if payment is due within 3 days
        if (daysUntilDue <= 3 && daysUntilDue >= 0) {
          // Check if we already have a notification for this
          final existingNotification = _notifications.any(
            (n) => n.type == 'payment_reminder' && 
                   n.payload == 'plan_${plan['id']}' &&
                   now.difference(n.createdAt).inHours < 24
          );
          
          if (!existingNotification) {
            await addPaymentReminder(
              title: 'Payment Reminder',
              body: 'Your installment payment is due ${daysUntilDue == 0 ? 'today' : 'in $daysUntilDue days'}',
              planId: plan['id'] as int?,
              dueDate: nextPaymentDate,
            );
          }
        }
      }
    }
  }
}
