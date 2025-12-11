import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // 🔹 Initialize Firebase Messaging + Local Notifications + SAVE FCM TOKEN
  static Future initializeFCM() async {
    await Firebase.initializeApp();

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 🔸 Local Notification setup
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(initializationSettings, onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      final payload = notificationResponse.payload;
      if (payload != null) {
        print('🟢 Notification tapped with payload: $payload');
      }
    });

    // 🔸 Request permission for notifications
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 🔥 NEW: Get & SAVE FCM Token to SharedPreferences
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveFCMToken(token);
      print('🔥 FCM Token SAVED: $token');
    }

    // 🔸 Foreground Message Handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground Message Received: ${message.notification?.title}');
      _showNotification(message);
    });

    // 🔸 When user taps on notification while app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🚀 Notification clicked (app in background)');
      _handleNotificationTap(message);
    });
  }

  // 🔥 NEW: Save FCM Token to SharedPreferences
  static Future _saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcmToken', token);
      print('💾 FCM Token saved to SharedPreferences: $token');
    } catch (e) {
      print('❌ Error saving FCM Token: $e');
    }
  }

  // 🔥 NEW: Get FCM Token from SharedPreferences
  static Future<String?> getFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcmToken');
      print('📖 Retrieved FCM Token: $token');
      return token;
    } catch (e) {
      print('❌ Error retrieving FCM Token: $e');
      return null;
    }
  }

  // Background handler
  static Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('💤 Background message received: ${message.notification?.title}');
  }

  // Show Local Notification (Foreground)
  static Future _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      notificationDetails,
      payload: message.data['route'] ?? '',
    );
  }

  // Handle Notification Tap
  static void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'];
    print('➡️ Notification tap detected. Type: $type');
  }
}