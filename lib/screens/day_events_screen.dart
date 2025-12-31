import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:purfect_care/models/calendar_event_model.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/reminder_model.dart';
import 'package:purfect_care/models/vaccination_model.dart';
import 'package:purfect_care/models/health_record_model.dart';
import 'package:purfect_care/models/milestone_model.dart';
import 'package:purfect_care/models/activity_model.dart';
import 'package:purfect_care/models/expense_model.dart';
import 'package:purfect_care/providers/pet_provider.dart';
import 'package:purfect_care/screens/add_reminder_screen.dart';
import 'package:purfect_care/screens/add_vaccination_screen.dart';
import 'package:purfect_care/screens/add_health_record_screen.dart';
import 'package:purfect_care/screens/add_milestone_screen.dart';
import 'package:purfect_care/screens/add_activity_screen.dart';
import 'package:purfect_care/screens/add_expense_screen.dart';
import 'package:purfect_care/theme/app_theme.dart';

class DayEventsScreen extends StatelessWidget {
  final DateTime date;
  final List<CalendarEventModel> events;

  const DayEventsScreen({
    super.key,
    required this.date,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final petProvider = context.read<PetProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? theme.colorScheme.surface : AppTheme.accentOrange,
        elevation: 0,
        title: Text(
          DateFormat('EEEE, MMM dd, yyyy').format(date),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: events.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No events on this day',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                PetModel? pet;
                if (event.petId != null) {
                  try {
                    pet = petProvider.pets.firstWhere((p) => p.id == event.petId);
                  } catch (e) {
                    pet = null;
                  }
                }

                return _buildEventCard(context, event, pet, theme, isDark);
              },
            ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    CalendarEventModel event,
    PetModel? pet,
    ThemeData theme,
    bool isDark,
  ) {
    IconData icon;
    String typeLabel;
    
    switch (event.type) {
      case 'reminder':
        icon = Icons.notifications;
        typeLabel = 'Reminder';
        break;
      case 'vaccination':
        icon = Icons.medical_services;
        typeLabel = 'Vaccination';
        break;
      case 'health':
        icon = Icons.favorite;
        typeLabel = 'Health Record';
        break;
      case 'milestone':
        icon = Icons.cake;
        typeLabel = 'Milestone';
        break;
      case 'activity':
        icon = Icons.directions_walk;
        typeLabel = 'Activity';
        break;
      case 'expense':
        icon = Icons.receipt_long;
        typeLabel = 'Expense';
        break;
      default:
        icon = Icons.event;
        typeLabel = 'Event';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: event.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(context, event, pet),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: event.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: event.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: event.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: event.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (pet != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        pet.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (event.time != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.time!.format(context),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, CalendarEventModel event, PetModel? pet) {
    if (pet == null) return;

    switch (event.type) {
      case 'reminder':
        if (event.originalData is ReminderModel) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddReminderScreen(
                pet: pet,
                reminder: event.originalData as ReminderModel,
              ),
            ),
          );
        }
        break;
      case 'vaccination':
        if (event.originalData is VaccinationModel) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddVaccinationScreen(
                pet: pet,
                vaccination: event.originalData as VaccinationModel,
              ),
            ),
          );
        }
        break;
      case 'health':
        if (event.originalData is HealthRecordModel) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddHealthRecordScreen(
                pet: pet,
                record: event.originalData as HealthRecordModel,
              ),
            ),
          );
        }
        break;
      case 'milestone':
        if (event.originalData is MilestoneModel) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMilestoneScreen(
                pet: pet,
                milestone: event.originalData as MilestoneModel,
              ),
            ),
          );
        }
        break;
      case 'activity':
        if (event.originalData is ActivityModel) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddActivityScreen(
                pet: pet,
                activity: event.originalData as ActivityModel,
              ),
            ),
          );
        }
        break;
      case 'expense':
        if (event.originalData is ExpenseModel) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(
                pet: pet,
                expense: event.originalData as ExpenseModel,
              ),
            ),
          );
        }
        break;
    }
  }
}

