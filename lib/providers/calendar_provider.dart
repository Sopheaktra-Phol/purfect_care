import 'package:flutter/material.dart';
import 'package:purfect_care/models/calendar_event_model.dart';
import 'package:purfect_care/models/reminder_model.dart';
import 'package:purfect_care/models/vaccination_model.dart';
import 'package:purfect_care/models/health_record_model.dart';
import 'package:purfect_care/models/milestone_model.dart';
import 'package:purfect_care/models/activity_model.dart';
import 'package:purfect_care/models/expense_model.dart';
import 'package:purfect_care/providers/reminder_provider.dart';
import 'package:purfect_care/providers/vaccination_provider.dart';
import 'package:purfect_care/providers/health_record_provider.dart';
import 'package:purfect_care/providers/milestone_provider.dart';
import 'package:purfect_care/providers/activity_provider.dart';
import 'package:purfect_care/providers/expense_provider.dart';
import 'package:purfect_care/providers/pet_provider.dart';

class CalendarProvider extends ChangeNotifier {
  final ReminderProvider reminderProvider;
  final VaccinationProvider vaccinationProvider;
  final HealthRecordProvider healthRecordProvider;
  final MilestoneProvider milestoneProvider;
  final ActivityProvider activityProvider;
  final ExpenseProvider expenseProvider;
  final PetProvider petProvider;

  CalendarProvider({
    required this.reminderProvider,
    required this.vaccinationProvider,
    required this.healthRecordProvider,
    required this.milestoneProvider,
    required this.activityProvider,
    required this.expenseProvider,
    required this.petProvider,
  });

  // Get all events for a specific date
  List<CalendarEventModel> getEventsForDate(DateTime date) {
    final events = <CalendarEventModel>[];
    final targetDate = DateTime(date.year, date.month, date.day);

    // Add reminders
    for (var reminder in reminderProvider.reminders) {
      final reminderDate = DateTime(
        reminder.time.year,
        reminder.time.month,
        reminder.time.day,
      );
      if (reminderDate.isAtSameMomentAs(targetDate)) {
        final pet = petProvider.pets.firstWhere(
          (p) => p.id == reminder.petId,
          orElse: () => petProvider.pets.first,
        );
        events.add(CalendarEventModel(
          id: reminder.id?.toString() ?? '',
          type: 'reminder',
          title: reminder.title,
          date: reminder.time,
          time: TimeOfDay.fromDateTime(reminder.time),
          petId: reminder.petId,
          color: Colors.blue,
          originalData: reminder,
        ));
      }
    }

    // Add vaccinations (next due dates)
    for (var pet in petProvider.pets) {
      if (pet.id == null) continue;
      final vaccinations = vaccinationProvider.getVaccinations(pet.id!);
      for (var vaccination in vaccinations) {
        if (vaccination.nextDueDate != null) {
          final dueDate = DateTime(
            vaccination.nextDueDate!.year,
            vaccination.nextDueDate!.month,
            vaccination.nextDueDate!.day,
          );
          if (dueDate.isAtSameMomentAs(targetDate)) {
            events.add(CalendarEventModel(
              id: vaccination.id?.toString() ?? '',
              type: 'vaccination',
              title: '${vaccination.vaccineName} due',
              date: vaccination.nextDueDate!,
              petId: pet.id,
              color: Colors.orange,
              originalData: vaccination,
            ));
          }
        }
      }
    }

    // Add health records
    for (var record in healthRecordProvider.healthRecords) {
      final recordDate = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );
      if (recordDate.isAtSameMomentAs(targetDate)) {
        events.add(CalendarEventModel(
          id: record.id?.toString() ?? '',
          type: 'health',
          title: record.title,
          date: record.date,
          petId: record.petId,
          color: Colors.red,
          originalData: record,
        ));
      }
    }

    // Add milestones
    for (var pet in petProvider.pets) {
      if (pet.id == null) continue;
      final milestones = milestoneProvider.getMilestones(pet.id!);
      for (var milestone in milestones) {
        // Check if milestone occurs on this date (considering year wrap-around for birthdays)
        final now = DateTime.now();
        final milestoneDate = DateTime(now.year, milestone.date.month, milestone.date.day);
        final targetMilestoneDate = DateTime(targetDate.year, milestone.date.month, milestone.date.day);
        
        if (milestoneDate.isAtSameMomentAs(targetDate) || 
            targetMilestoneDate.isAtSameMomentAs(targetDate)) {
          events.add(CalendarEventModel(
            id: milestone.id?.toString() ?? '',
            type: 'milestone',
            title: milestone.title,
            date: milestone.date,
            petId: pet.id,
            color: milestone.type == 'birthday' ? Colors.pink : Colors.blue,
            originalData: milestone,
          ));
        }
      }
    }

    // Add activities
    for (var pet in petProvider.pets) {
      if (pet.id == null) continue;
      final activities = activityProvider.getActivities(pet.id!);
      for (var activity in activities) {
        final activityDate = DateTime(
          activity.date.year,
          activity.date.month,
          activity.date.day,
        );
        if (activityDate.isAtSameMomentAs(targetDate)) {
          events.add(CalendarEventModel(
            id: activity.id?.toString() ?? '',
            type: 'activity',
            title: '${activity.type.toUpperCase()} - ${activity.duration}min',
            date: activity.date,
            time: TimeOfDay.fromDateTime(activity.date),
            petId: pet.id,
            color: Colors.green,
            originalData: activity,
          ));
        }
      }
    }

    // Add expenses
    for (var pet in petProvider.pets) {
      if (pet.id == null) continue;
      final expenses = expenseProvider.getExpenses(pet.id!);
      for (var expense in expenses) {
        final expenseDate = DateTime(
          expense.date.year,
          expense.date.month,
          expense.date.day,
        );
        if (expenseDate.isAtSameMomentAs(targetDate)) {
          events.add(CalendarEventModel(
            id: expense.id?.toString() ?? '',
            type: 'expense',
            title: '\$${expense.amount.toStringAsFixed(2)} - ${expense.description}',
            date: expense.date,
            petId: pet.id,
            color: Colors.purple,
            originalData: expense,
          ));
        }
      }
    }

    // Sort events by time if available, otherwise by date
    events.sort((a, b) {
      if (a.time != null && b.time != null) {
        final aMinutes = a.time!.hour * 60 + a.time!.minute;
        final bMinutes = b.time!.hour * 60 + b.time!.minute;
        return aMinutes.compareTo(bMinutes);
      }
      return a.date.compareTo(b.date);
    });

    return events;
  }

  // Get all events (for calendar markers)
  List<CalendarEventModel> getAllEvents() {
    final events = <CalendarEventModel>[];
    final now = DateTime.now();

    // Add reminders
    for (var reminder in reminderProvider.reminders) {
      events.add(CalendarEventModel(
        id: reminder.id?.toString() ?? '',
        type: 'reminder',
        title: reminder.title,
        date: reminder.time,
        time: TimeOfDay.fromDateTime(reminder.time),
        petId: reminder.petId,
        color: Colors.blue,
        originalData: reminder,
      ));
    }

    // Add vaccinations (next due dates)
    for (var pet in petProvider.pets) {
      if (pet.id == null) continue;
      final vaccinations = vaccinationProvider.getVaccinations(pet.id!);
      for (var vaccination in vaccinations) {
        if (vaccination.nextDueDate != null) {
          events.add(CalendarEventModel(
            id: vaccination.id?.toString() ?? '',
            type: 'vaccination',
            title: '${vaccination.vaccineName} due',
            date: vaccination.nextDueDate!,
            petId: pet.id,
            color: Colors.orange,
            originalData: vaccination,
          ));
        }
      }
    }

    // Add health records
    for (var record in healthRecordProvider.healthRecords) {
      events.add(CalendarEventModel(
        id: record.id?.toString() ?? '',
        type: 'health',
        title: record.title,
        date: record.date,
        petId: record.petId,
        color: Colors.red,
        originalData: record,
      ));
    }

    // Add milestones (for current year)
    for (var pet in petProvider.pets) {
      if (pet.id == null) continue;
      final milestones = milestoneProvider.getMilestones(pet.id!);
      for (var milestone in milestones) {
        final milestoneDate = DateTime(now.year, milestone.date.month, milestone.date.day);
        events.add(CalendarEventModel(
          id: milestone.id?.toString() ?? '',
          type: 'milestone',
          title: milestone.title,
          date: milestoneDate,
          petId: pet.id,
          color: milestone.type == 'birthday' ? Colors.pink : Colors.blue,
          originalData: milestone,
        ));
      }
    }

    // Add activities
    for (var pet in petProvider.pets) {
      if (pet.id == null) continue;
      final activities = activityProvider.getActivities(pet.id!);
      for (var activity in activities) {
        events.add(CalendarEventModel(
          id: activity.id?.toString() ?? '',
          type: 'activity',
          title: '${activity.type.toUpperCase()} - ${activity.duration}min',
          date: activity.date,
          time: TimeOfDay.fromDateTime(activity.date),
          petId: pet.id,
          color: Colors.green,
          originalData: activity,
        ));
      }
    }

    // Add expenses
    for (var pet in petProvider.pets) {
      if (pet.id == null) continue;
      final expenses = expenseProvider.getExpenses(pet.id!);
      for (var expense in expenses) {
        events.add(CalendarEventModel(
          id: expense.id?.toString() ?? '',
          type: 'expense',
          title: '\$${expense.amount.toStringAsFixed(2)} - ${expense.description}',
          date: expense.date,
          petId: pet.id,
          color: Colors.purple,
          originalData: expense,
        ));
      }
    }

    return events;
  }
}

