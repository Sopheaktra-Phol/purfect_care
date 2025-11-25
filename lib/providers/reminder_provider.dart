import 'package:flutter/material.dart';
import '../models/pet_model.dart';
import '../models/reminder_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  List<ReminderModel> reminders = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void loadReminders() {
    reminders = DatabaseService.getAllReminders();
    notifyListeners();
  }
  
  // Reschedule all notifications - call this with pets list from outside
  Future<void> rescheduleAllNotifications(List<PetModel> pets) async {
    final notificationService = NotificationService();
    final hasPermission = await notificationService.areNotificationsEnabled();
    if (!hasPermission) {
      print('⚠ Cannot reschedule notifications: permissions not granted');
      return;
    }
    
    print('=== Rescheduling all notifications ===');
    int rescheduled = 0;
    
    for (var reminder in reminders) {
      // Only reschedule if reminder is not completed and time is in the future
      if (!reminder.isCompleted) {
        PetModel pet;
        try {
          pet = pets.firstWhere((p) => p.id == reminder.petId);
        } catch (e) {
          // Pet not found, skip this reminder
          continue;
        }
        
        {
          try {
            // Cancel old notification if exists
            if (reminder.notificationId != null) {
              await notificationService.cancelNotification(reminder.notificationId!);
            }
            
            // Reschedule if time is in the future
            final now = DateTime.now();
            if (reminder.time.isAfter(now)) {
              final newNotificationId = await notificationService.scheduleNotification(
                petName: pet.name,
                title: reminder.title,
                scheduledDate: reminder.time,
                repeat: reminder.repeat,
              );
              reminder.notificationId = newNotificationId;
              await DatabaseService.updateReminder(reminder.id!, reminder);
              rescheduled++;
              print('✓ Rescheduled: ${reminder.title} for ${pet.name}');
            }
          } catch (e) {
            print('Error rescheduling notification for reminder ${reminder.id}: $e');
          }
        }
      }
    }
    
    print('✓ Rescheduled $rescheduled notifications');
    notifyListeners();
  }

  Future<void> addReminder(ReminderModel r, PetModel pet) async {
    // Don't schedule notification if task is already completed
    if (r.isCompleted) {
      final id = await DatabaseService.addReminder(r);
      r.id = id;
      reminders.add(r);
      notifyListeners();
      return;
    }
    
    // Ensure permissions are granted
    final notificationService = NotificationService();
    final hasPermission = await notificationService.areNotificationsEnabled();
    if (!hasPermission) {
      await notificationService.requestPermissions();
    }
    
    try {
      final notificationId = await notificationService.scheduleNotification(
      petName: pet.name,
      title: r.title,
      scheduledDate: r.time,
      repeat: r.repeat,
    );
    r.notificationId = notificationId;
      final id = await DatabaseService.addReminder(r);
      r.id = id;
      reminders.add(r);
      notifyListeners();
    } catch (e) {
      print('Error adding reminder notification: $e');
      // Still save the reminder even if notification fails
      final id = await DatabaseService.addReminder(r);
    r.id = id;
    reminders.add(r);
    notifyListeners();
    }
  }

  Future<void> updateReminder(int id, ReminderModel r, PetModel pet) async {
    final old = reminders.firstWhere((e) => e.id == id);
    final notificationService = NotificationService();
    
    // Always cancel the old notification if it exists
    if (old.notificationId != null) {
      print('Cancelling old notification ${old.notificationId} for reminder ${old.title}');
      await notificationService.cancelNotification(old.notificationId!);
    }
    
    // Don't schedule notification if task is completed
    if (r.isCompleted) {
      print('Task ${r.title} is completed - cancelling all related notifications');
      // Cancel by stored ID first
      if (old.notificationId != null) {
        await notificationService.cancelNotification(old.notificationId!);
      }
      // Also try to cancel by title as a fallback (in case ID doesn't match)
      await notificationService.cancelNotificationsByTitle(r.title);
      
      r.notificationId = null; // Clear notification ID for completed tasks
      await DatabaseService.updateReminder(id, r);
      final i = reminders.indexWhere((e) => e.id == id);
      if (i >= 0) {
        reminders[i] = r;
        notifyListeners();
      }
      return;
    }
    
    // Ensure permissions are granted
    final notificationService = NotificationService();
    final hasPermission = await notificationService.areNotificationsEnabled();
    if (!hasPermission) {
      await notificationService.requestPermissions();
    }
    
    try {
      final notificationId = await notificationService.scheduleNotification(
      petName: pet.name,
      title: r.title,
      scheduledDate: r.time,
      repeat: r.repeat,
    );
    r.notificationId = notificationId;
      await DatabaseService.updateReminder(id, r);
      final i = reminders.indexWhere((e) => e.id == id);
      if (i >= 0) {
        reminders[i] = r;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating reminder notification: $e');
      // Still update the reminder even if notification fails
      await DatabaseService.updateReminder(id, r);
    final i = reminders.indexWhere((e) => e.id == id);
      if (i >= 0) {
    reminders[i] = r;
    notifyListeners();
      }
    }
  }

  Future<void> deleteReminder(int id) async {
    final r = reminders.firstWhere((e) => e.id == id);
    if (r.notificationId != null) {
      await NotificationService().cancelNotification(r.notificationId!);
    }
    await DatabaseService.deleteReminder(id);
    reminders.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
