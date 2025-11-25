import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
        autoCancel: true,
        ongoing: false,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      );
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      // Convert to timezone-aware datetime
      final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
      
      // Ensure the scheduled time is in the future
      final now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduleTime = scheduledTZ;
      
      if (scheduledTZ.isBefore(now)) {
        print('⚠ Warning: Scheduled time is in the past. Adjusting to 10 seconds from now for testing.');
        // For testing, schedule 10 seconds from now if past time
        scheduleTime = now.add(const Duration(seconds: 10));
      }
      
      print('=== Scheduling Notification ===');
      print('ID: $id');
      print('Title: $title');
      print('Body: $body');
      print('Scheduled time: ${scheduleTime.toString()}');
      print('Current time: ${now.toString()}');
      print('Repeat: $repeat');
      
      if (repeat == 'none') {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduleTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        print('✓ One-time notification scheduled');
      } else {
        await _scheduleRepeating(id, title, body, scheduleTime, details, repeat);
        print('✓ Repeating notification scheduled');
      }

      // Verify notification was scheduled
      await Future.delayed(const Duration(milliseconds: 500)); // Wait a bit for system to register
      final pending = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      print('=== Notification Scheduling Verification ===');
      print('Total pending notifications: ${pending.length}');
      final thisNotification = pending.where((n) => n.id == id).toList();
      if (thisNotification.isNotEmpty) {
        print('✓ Notification confirmed in pending list');
        print('  - ID: ${thisNotification.first.id}');
        print('  - Title: ${thisNotification.first.title}');
        print('  - Body: ${thisNotification.first.body}');
        print('  - Scheduled for: ${thisNotification.first.payload}');
      } else {
        print('⚠ WARNING: Notification not found in pending list!');
        print('  This means the notification may not fire.');
        print('  Scheduled ID: $id');
        print('  Scheduled time: ${scheduleTime.toString()}');
        print('  Current time: ${now.toString()}');
      }
      
      // List all pending notifications for debugging
      if (pending.isNotEmpty) {
        print('\nAll pending notifications:');
        for (var notif in pending) {
          print('  - ID: ${notif.id}, Title: ${notif.title}');
        }
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
        autoCancel: true,
        ongoing: false,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
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
