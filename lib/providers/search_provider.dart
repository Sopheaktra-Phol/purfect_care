import 'package:flutter/material.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/reminder_model.dart';
import 'package:purfect_care/models/health_record_model.dart';
import 'package:purfect_care/models/vaccination_model.dart';
import 'package:purfect_care/models/milestone_model.dart';
import 'package:purfect_care/models/activity_model.dart';
import 'package:purfect_care/models/expense_model.dart';
import 'package:purfect_care/providers/pet_provider.dart';
import 'package:purfect_care/providers/reminder_provider.dart';
import 'package:purfect_care/providers/health_record_provider.dart';
import 'package:purfect_care/providers/vaccination_provider.dart';
import 'package:purfect_care/providers/milestone_provider.dart';
import 'package:purfect_care/providers/activity_provider.dart';
import 'package:purfect_care/providers/expense_provider.dart';

enum SearchResultType {
  pet,
  reminder,
  health,
  vaccination,
  milestone,
  activity,
  expense,
}

class SearchResult {
  final SearchResultType type;
  final String id;
  final String title;
  final String subtitle;
  final int? petId;
  final dynamic originalData;
  final Color color;

  SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    this.petId,
    this.originalData,
    required this.color,
  });
}

class SearchProvider extends ChangeNotifier {
  final PetProvider petProvider;
  final ReminderProvider reminderProvider;
  final HealthRecordProvider healthRecordProvider;
  final VaccinationProvider vaccinationProvider;
  final MilestoneProvider milestoneProvider;
  final ActivityProvider activityProvider;
  final ExpenseProvider expenseProvider;

  SearchProvider({
    required this.petProvider,
    required this.reminderProvider,
    required this.healthRecordProvider,
    required this.vaccinationProvider,
    required this.milestoneProvider,
    required this.activityProvider,
    required this.expenseProvider,
  });

  List<SearchResult> search(String query, {List<SearchResultType>? filterTypes}) {
    if (query.trim().isEmpty) return [];

    final queryLower = query.toLowerCase().trim();
    final results = <SearchResult>[];

    // Search pets
    if (filterTypes == null || filterTypes.contains(SearchResultType.pet)) {
      for (var pet in petProvider.pets) {
        if (_matchesQuery(queryLower, [
          pet.name,
          pet.breed,
          pet.species,
          pet.notes ?? '',
        ])) {
          results.add(SearchResult(
            type: SearchResultType.pet,
            id: pet.id?.toString() ?? '',
            title: pet.name,
            subtitle: '${pet.species} • ${pet.breed}',
            petId: pet.id,
            originalData: pet,
            color: Colors.blue,
          ));
        }
      }
    }

    // Search reminders
    if (filterTypes == null || filterTypes.contains(SearchResultType.reminder)) {
      for (var reminder in reminderProvider.reminders) {
        if (_matchesQuery(queryLower, [reminder.title])) {
          final pet = petProvider.pets.firstWhere(
            (p) => p.id == reminder.petId,
            orElse: () => petProvider.pets.first,
          );
          results.add(SearchResult(
            type: SearchResultType.reminder,
            id: reminder.id?.toString() ?? '',
            title: reminder.title,
            subtitle: 'Reminder for ${pet.name}',
            petId: reminder.petId,
            originalData: reminder,
            color: Colors.blue,
          ));
        }
      }
    }

    // Search health records
    if (filterTypes == null || filterTypes.contains(SearchResultType.health)) {
      for (var record in healthRecordProvider.healthRecords) {
        if (_matchesQuery(queryLower, [
          record.title,
          record.notes ?? '',
        ])) {
          final pet = petProvider.pets.firstWhere(
            (p) => p.id == record.petId,
            orElse: () => petProvider.pets.first,
          );
          results.add(SearchResult(
            type: SearchResultType.health,
            id: record.id?.toString() ?? '',
            title: record.title,
            subtitle: 'Health record for ${pet.name}',
            petId: record.petId,
            originalData: record,
            color: Colors.red,
          ));
        }
      }
    }

    // Search vaccinations
    if (filterTypes == null || filterTypes.contains(SearchResultType.vaccination)) {
      for (var pet in petProvider.pets) {
        if (pet.id == null) continue;
        final vaccinations = vaccinationProvider.getVaccinations(pet.id!);
        for (var vaccination in vaccinations) {
          if (_matchesQuery(queryLower, [
            vaccination.vaccineName,
            vaccination.vetName ?? '',
            vaccination.notes ?? '',
          ])) {
            results.add(SearchResult(
              type: SearchResultType.vaccination,
              id: vaccination.id?.toString() ?? '',
              title: vaccination.vaccineName,
              subtitle: 'Vaccination for ${pet.name}',
              petId: pet.id,
              originalData: vaccination,
              color: Colors.orange,
            ));
          }
        }
      }
    }

    // Search milestones
    if (filterTypes == null || filterTypes.contains(SearchResultType.milestone)) {
      for (var pet in petProvider.pets) {
        if (pet.id == null) continue;
        final milestones = milestoneProvider.getMilestones(pet.id!);
        for (var milestone in milestones) {
          if (_matchesQuery(queryLower, [
            milestone.title,
            milestone.notes ?? '',
          ])) {
            results.add(SearchResult(
              type: SearchResultType.milestone,
              id: milestone.id?.toString() ?? '',
              title: milestone.title,
              subtitle: 'Milestone for ${pet.name}',
              petId: pet.id,
              originalData: milestone,
              color: milestone.type == 'birthday' ? Colors.pink : Colors.blue,
            ));
          }
        }
      }
    }

    // Search activities
    if (filterTypes == null || filterTypes.contains(SearchResultType.activity)) {
      for (var pet in petProvider.pets) {
        if (pet.id == null) continue;
        final activities = activityProvider.getActivities(pet.id!);
        for (var activity in activities) {
          if (_matchesQuery(queryLower, [
            activity.type,
            activity.notes ?? '',
          ])) {
            results.add(SearchResult(
              type: SearchResultType.activity,
              id: activity.id?.toString() ?? '',
              title: '${activity.type.toUpperCase()} - ${activity.duration}min',
              subtitle: 'Activity for ${pet.name}',
              petId: pet.id,
              originalData: activity,
              color: Colors.green,
            ));
          }
        }
      }
    }

    // Search expenses
    if (filterTypes == null || filterTypes.contains(SearchResultType.expense)) {
      for (var pet in petProvider.pets) {
        if (pet.id == null) continue;
        final expenses = expenseProvider.getExpenses(pet.id!);
        for (var expense in expenses) {
          if (_matchesQuery(queryLower, [
            expense.description,
            expense.category,
            expense.amount.toString(),
          ])) {
            results.add(SearchResult(
              type: SearchResultType.expense,
              id: expense.id?.toString() ?? '',
              title: '\$${expense.amount.toStringAsFixed(2)} - ${expense.description}',
              subtitle: 'Expense for ${pet.name}',
              petId: pet.id,
              originalData: expense,
              color: Colors.purple,
            ));
          }
        }
      }
    }

    return results;
  }

  bool _matchesQuery(String query, List<String> fields) {
    for (var field in fields) {
      if (field.toLowerCase().contains(query)) {
        return true;
      }
    }
    return false;
  }
}

