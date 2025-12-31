import 'package:flutter/material.dart';
import '../models/pet_model.dart';
import '../models/reminder_model.dart';
import '../services/firestore_database_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  List<ReminderModel> reminders = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadReminders({List<PetModel>? pets}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      reminders = await FirestoreDatabaseService.getAllReminders();
      
      // Clean up orphaned reminders (reminders for deleted pets)
      if (pets != null) {
        await _cleanupOrphanedReminders(pets);
      }
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load reminders.';
      print('Error loading reminders: $e');
      reminders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Remove reminders that belong to deleted pets
  Future<void> _cleanupOrphanedReminders(List<PetModel> pets) async {
    // If there are no pets, delete all reminders
    if (pets.isEmpty) {
      print('🧹 No pets found, deleting all reminders');
      final allReminders = List<ReminderModel>.from(reminders);
      for (var reminder in allReminders) {
        try {
          if (reminder.id != null) {
            // Cancel notification if exists
            if (reminder.notificationId != null) {
              await NotificationService().cancelNotification(reminder.notificationId!);
            }
            // Delete from Firestore
            await FirestoreDatabaseService.deleteReminder(reminder.id!.toString());
            print('✅ Deleted reminder: ${reminder.title} (petId: ${reminder.petId})');
          }
        } catch (e) {
          print('⚠️ Error deleting reminder ${reminder.id}: $e');
        }
      }
      reminders.clear();
      print('🧹 Cleanup complete: All reminders removed (no pets)');
      return;
    }
    
    // Otherwise, only delete reminders for pets that don't exist
    final petIds = pets.map((p) => p.id).where((id) => id != null).toSet();
    final orphanedReminders = reminders.where((r) => !petIds.contains(r.petId)).toList();
    
    if (orphanedReminders.isEmpty) {
      return; // No orphaned reminders
    }
    
    print('🧹 Found ${orphanedReminders.length} orphaned reminders to delete');
    
    for (var reminder in orphanedReminders) {
      try {
        if (reminder.id != null) {
          // Cancel notification if exists
          if (reminder.notificationId != null) {
            await NotificationService().cancelNotification(reminder.notificationId!);
          }
          // Delete from Firestore
          await FirestoreDatabaseService.deleteReminder(reminder.id!.toString());
          print('✅ Deleted orphaned reminder: ${reminder.title} (petId: ${reminder.petId})');
        }
      } catch (e) {
        print('⚠️ Error deleting orphaned reminder ${reminder.id}: $e');
      }
    }
    
    // Remove from local list
    reminders.removeWhere((r) => orphanedReminders.contains(r));
    print('🧹 Cleanup complete: ${orphanedReminders.length} orphaned reminders removed');
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
              await FirestoreDatabaseService.updateReminder(reminder.id!.toString(), reminder);
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Don't schedule notification if task is already completed
    if (r.isCompleted) {
      try {
        final id = await FirestoreDatabaseService.addReminder(r);
        r.id = int.tryParse(id) ?? 0;
        reminders.add(r);
        _errorMessage = null;
      } catch (e) {
        _errorMessage = 'Failed to add reminder.';
        print('Error adding reminder: $e');
      } finally {
        _isLoading = false;
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
      
      final id = await FirestoreDatabaseService.addReminder(r);
      r.id = int.tryParse(id) ?? 0;
      reminders.add(r);
      _errorMessage = null;
    } catch (e) {
      print('Error adding reminder notification: $e');
      // Still save the reminder even if notification fails
      try {
        final id = await FirestoreDatabaseService.addReminder(r);
        r.id = int.tryParse(id) ?? 0;
        reminders.add(r);
      } catch (saveError) {
        _errorMessage = 'Failed to add reminder.';
        print('Error saving reminder: $saveError');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReminder(int id, ReminderModel r, PetModel pet) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final old = reminders.firstWhere((e) => e.id == id);
    final notificationService = NotificationService();
    
    // Cancel old notification if it exists
    if (old.notificationId != null) {
      await notificationService.cancelNotification(old.notificationId!);
    }
    
    // Don't schedule notification if task is completed
    if (r.isCompleted) {
      await notificationService.cancelNotificationsByTitle(r.title);
      r.notificationId = null;
      try {
        await FirestoreDatabaseService.updateReminder(id.toString(), r);
        final i = reminders.indexWhere((e) => e.id == id);
        if (i >= 0) {
          reminders[i] = r;
          _errorMessage = null;
        }
      } catch (e) {
        _errorMessage = 'Failed to update reminder.';
        print('Error updating reminder: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
      return;
    }
    
    // Ensure permissions are granted
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
    } catch (e) {
      print('Error updating reminder notification: $e');
    }
    
    try {
      await FirestoreDatabaseService.updateReminder(id.toString(), r);
      final i = reminders.indexWhere((e) => e.id == id);
      if (i >= 0) {
        reminders[i] = r;
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to update reminder.';
      print('Error updating reminder: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReminder(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final r = reminders.firstWhere((e) => e.id == id);
      if (r.notificationId != null) {
        await NotificationService().cancelNotification(r.notificationId!);
      }
      await FirestoreDatabaseService.deleteReminder(id.toString());
      reminders.removeWhere((e) => e.id == id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to delete reminder.';
      print('Error deleting reminder: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
