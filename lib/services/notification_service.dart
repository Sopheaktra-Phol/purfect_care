import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    
    final bool? initialized = await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) {
        print('Notification tapped: ${payload.payload}');
      },
    );
    
    print('Notification service initialized: $initialized');
    
    if (initialized == true) {
      // Create notification channel for Android
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        // Create the notification channel
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'pawfect_channel',
            'Reminders',
            description: 'Pet care reminders',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );
        print('Android notification channel created');
        
        // Check and request permissions for Android 13+
        final areEnabled = await androidImplementation.areNotificationsEnabled();
        print('Android notifications enabled: $areEnabled');
        
        if (areEnabled != true) {
          print('Requesting Android notification permission...');
          final granted = await androidImplementation.requestNotificationsPermission();
          print('Android notification permission granted: $granted');
        } else {
          print('Android notification permission already granted');
        }
      }
      
      // Request permissions for iOS
      final iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        // Always request permissions on iOS (it's safe to call multiple times)
        // The system will only show the dialog if permissions haven't been granted
        print('Requesting iOS notification permissions...');
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        print('iOS notification permissions granted: $granted');
        
        // Check permission status after request
        final permissionStatus = await iosImplementation.checkPermissions();
        print('iOS notification permission status after request: $permissionStatus');
      }
    }
  }

  Future<int> scheduleNotification({
    required String petName,
    required String title,
    required DateTime scheduledDate,
    String repeat = 'none',
  }) async {
    try {
      // Ensure notification channel exists for Android
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'pawfect_channel',
            'Reminders',
            description: 'Pet care reminders',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );
      }
      
      final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
      
      // Choose emoji based on task type
      String emoji = '🐶'; // Default
      String action = title.toLowerCase();
      
      if (title.toLowerCase().contains('feed') || title.toLowerCase().contains('food')) {
        emoji = '🐶';
        action = 'feed';
      } else if (title.toLowerCase().contains('walk')) {
        emoji = '🚶';
        action = 'walk';
      } else if (title.toLowerCase().contains('vet')) {
        emoji = '🏥';
        action = 'take to the vet';
      } else if (title.toLowerCase().contains('groom')) {
        emoji = '✂️';
        action = 'groom';
      } else {
        // For custom tasks, use the title as-is
        action = title.toLowerCase();
      }
      
      final body = "It's time to $action $petName $emoji!";
      const androidDetails = AndroidNotificationDetails(
        'pawfect_channel',
        'Reminders',
        channelDescription: 'Pet care reminders',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        showWhen: true,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      // Convert to timezone-aware datetime
      final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
      
      // Ensure the scheduled time is in the future
      final now = tz.TZDateTime.now(tz.local);
      if (scheduledTZ.isBefore(now)) {
        print('Warning: Scheduled time is in the past. Adjusting to 1 minute from now.');
        // For testing, schedule 1 minute from now if past time
        final adjustedTime = now.add(const Duration(minutes: 1));
        if (repeat == 'none') {
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            adjustedTime,
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
          print('Notification scheduled (adjusted): ID=$id, Time=${adjustedTime.toString()}');
        } else {
          // For repeating notifications, still use the original scheduled time
          await _scheduleRepeating(id, title, body, scheduledTZ, details, repeat);
        }
      } else {
        if (repeat == 'none') {
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            scheduledTZ,
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
          print('Notification scheduled: ID=$id, Time=${scheduledTZ.toString()}, Body=$body');
        } else {
          await _scheduleRepeating(id, title, body, scheduledTZ, details, repeat);
          print('Repeating notification scheduled: ID=$id, Time=${scheduledTZ.toString()}, Repeat=$repeat');
        }
      }

      // Verify notification was scheduled
      final pending = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      print('Total pending notifications: ${pending.length}');
      final thisNotification = pending.where((n) => n.id == id).toList();
      if (thisNotification.isNotEmpty) {
        print('✓ Notification confirmed in pending list: ${thisNotification.first.title}');
      } else {
        print('⚠ Warning: Notification not found in pending list!');
      }

      return id;
    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }

  Future<void> _scheduleRepeating(
    int id,
    String title,
    String body,
    tz.TZDateTime scheduledTZ,
    NotificationDetails details,
    String repeat,
  ) async {
    if (repeat == 'daily') {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else if (repeat == 'weekly') {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } else if (repeat == 'monthly') {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<bool> requestPermissions() async {
    print('=== Requesting notification permissions ===');
    
    // Request Android permissions (Android 13+)
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final areEnabled = await androidImplementation.areNotificationsEnabled();
      print('Android notifications currently enabled: $areEnabled');
      
      if (areEnabled != true) {
        print('Requesting Android notification permission...');
        final granted = await androidImplementation.requestNotificationsPermission();
        print('Android notification permission result: $granted');
        if (granted == true) {
          print('✓ Android notification permission granted');
          return true;
        } else {
          print('✗ Android notification permission denied');
        }
      } else {
        print('✓ Android notification permission already granted');
        return true;
      }
    }

    // Request iOS permissions
    final iosImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      // Check current permission status first
      final permissionStatus = await iosImplementation.checkPermissions();
      print('iOS notification permission status: $permissionStatus');
      
      // Always request permissions on iOS (it's safe to call multiple times)
      // The system will only show the dialog if permissions haven't been granted/denied
      print('Requesting iOS notification permissions...');
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      print('iOS notification permission result: $granted');
      
      // Check status again after request
      final statusAfterRequest = await iosImplementation.checkPermissions();
      print('iOS notification permission status after request: $statusAfterRequest');
      
      if (granted == true || statusAfterRequest?.isEnabled == true) {
        print('✓ iOS notification permission granted');
        return true;
      } else {
        print('✗ iOS notification permission denied or not granted');
        print('Note: If permission was previously denied, user must enable it in Settings > Purfect Care > Notifications');
        return false;
      }
    }

    return false;
  }

  Future<bool> areNotificationsEnabled() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    return true; // iOS permissions are handled by the system
  }

  // Test notification - shows immediately for debugging
  Future<void> showTestNotification({
    required String petName,
    required String title,
  }) async {
    try {
      // Choose emoji based on task type
      String emoji = '🐶';
      String action = title.toLowerCase();
      
      if (title.toLowerCase().contains('feed') || title.toLowerCase().contains('food')) {
        emoji = '🐶';
        action = 'feed';
      } else if (title.toLowerCase().contains('walk')) {
        emoji = '🚶';
        action = 'walk';
      } else if (title.toLowerCase().contains('vet')) {
        emoji = '🏥';
        action = 'take to the vet';
      } else if (title.toLowerCase().contains('groom')) {
        emoji = '✂️';
        action = 'groom';
      } else {
        action = title.toLowerCase();
      }
      
      final body = "It's time to $action $petName $emoji!";
      const androidDetails = AndroidNotificationDetails(
        'pawfect_channel',
        'Reminders',
        channelDescription: 'Pet care reminders',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _flutterLocalNotificationsPlugin.show(
        999999, // Test notification ID
        title,
        body,
        details,
      );
      
      print('Test notification shown: $title - $body');
    } catch (e) {
      print('Error showing test notification: $e');
    }
  }

  // Get all pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String petName,
    required String title,
  }) async {
    try {
      // Choose emoji based on task type
      String emoji = '🐶';
      String action = title.toLowerCase();
      
      if (title.toLowerCase().contains('feed') || title.toLowerCase().contains('food')) {
        emoji = '🐶';
        action = 'feed';
      } else if (title.toLowerCase().contains('walk')) {
        emoji = '🚶';
        action = 'walk';
      } else if (title.toLowerCase().contains('vet')) {
        emoji = '🏥';
        action = 'take to the vet';
      } else if (title.toLowerCase().contains('groom')) {
        emoji = '✂️';
        action = 'groom';
      } else {
        action = title.toLowerCase();
      }
      
      final body = "It's time to $action $petName $emoji!";
      
      // Create notification channel for Android (if not exists)
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'pawfect_channel',
            'Reminders',
            description: 'Pet care reminders',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );
      }
      
      const androidDetails = AndroidNotificationDetails(
        'pawfect_channel',
        'Reminders',
        channelDescription: 'Pet care reminders',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        showWhen: true,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _flutterLocalNotificationsPlugin.show(
        999999, // Test notification ID
        title,
        body,
        details,
      );
      
      print('Immediate notification shown: $title - $body');
    } catch (e) {
      print('Error showing immediate notification: $e');
      rethrow;
    }
  }
}
