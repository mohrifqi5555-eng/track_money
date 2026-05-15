import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  static const String _storageKey = 'notifications_history';

  Future<void> init() async {
    tz_data.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification click
      },
    );

    // Request permission for Android 13+
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    // Load saved notifications
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_storageKey);
      
      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        _notifications = decoded.map((item) => AppNotification.fromMap(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_notifications.map((n) => n.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    required String type,
    double? amount,
    String? status,
    String? payload,
  }) async {
    // Add to history
    final newNotification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      amount: amount,
      status: status ?? 'success',
    );
    
    _notifications.insert(0, newNotification);
    notifyListeners();
    await _saveNotifications();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'money_track_channel',
      'MoneyTrack Notifications',
      channelDescription: 'Notifications for MoneyTrack app',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    _saveNotifications();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
      _saveNotifications();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
    _saveNotifications();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
    _saveNotifications();
  }
}
