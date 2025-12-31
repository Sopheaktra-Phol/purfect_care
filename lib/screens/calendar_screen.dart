import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:purfect_care/models/calendar_event_model.dart';
import 'package:purfect_care/providers/calendar_provider.dart';
import 'package:purfect_care/providers/pet_provider.dart';
import 'package:purfect_care/providers/reminder_provider.dart';
import 'package:purfect_care/providers/vaccination_provider.dart';
import 'package:purfect_care/providers/health_record_provider.dart';
import 'package:purfect_care/providers/milestone_provider.dart';
import 'package:purfect_care/providers/activity_provider.dart';
import 'package:purfect_care/providers/expense_provider.dart';
import 'package:purfect_care/theme/app_theme.dart';
import 'day_events_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late ValueNotifier<List<CalendarEventModel>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    _loadAllData();
  }

  void _loadAllData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final petProvider = context.read<PetProvider>();
      final reminderProvider = context.read<ReminderProvider>();
      final vaccinationProvider = context.read<VaccinationProvider>();
      final healthProvider = context.read<HealthRecordProvider>();
      final milestoneProvider = context.read<MilestoneProvider>();
      final activityProvider = context.read<ActivityProvider>();
      final expenseProvider = context.read<ExpenseProvider>();

      // Load all data if not already loaded
      if (petProvider.pets.isEmpty) {
        await petProvider.loadPets();
      }
      if (reminderProvider.reminders.isEmpty) {
        await reminderProvider.loadReminders(pets: petProvider.pets);
      }
      if (healthProvider.healthRecords.isEmpty) {
        await healthProvider.loadHealthRecords();
      }

      // Load data for each pet
      for (var pet in petProvider.pets) {
        if (pet.id != null) {
          if (!vaccinationProvider.hasLoadedVaccinations(pet.id!)) {
            vaccinationProvider.loadVaccinations(pet.id!);
          }
          if (!milestoneProvider.hasLoadedMilestones(pet.id!)) {
            milestoneProvider.loadMilestones(pet.id!);
          }
          if (!activityProvider.hasLoadedActivities(pet.id!)) {
            activityProvider.loadActivities(pet.id!);
          }
          if (!expenseProvider.hasLoadedExpenses(pet.id!)) {
            expenseProvider.loadExpenses(pet.id!);
          }
        }
      }
    });
  }

  List<CalendarEventModel> _getEventsForDay(DateTime day) {
    final calendarProvider = CalendarProvider(
      reminderProvider: context.read<ReminderProvider>(),
      vaccinationProvider: context.read<VaccinationProvider>(),
      healthRecordProvider: context.read<HealthRecordProvider>(),
      milestoneProvider: context.read<MilestoneProvider>(),
      activityProvider: context.read<ActivityProvider>(),
      expenseProvider: context.read<ExpenseProvider>(),
      petProvider: context.read<PetProvider>(),
    );
    return calendarProvider.getEventsForDate(day);
  }

  Map<DateTime, List<CalendarEventModel>> _getEventsMap() {
    final calendarProvider = CalendarProvider(
      reminderProvider: context.read<ReminderProvider>(),
      vaccinationProvider: context.read<VaccinationProvider>(),
      healthRecordProvider: context.read<HealthRecordProvider>(),
      milestoneProvider: context.read<MilestoneProvider>(),
      activityProvider: context.read<ActivityProvider>(),
      expenseProvider: context.read<ExpenseProvider>(),
      petProvider: context.read<PetProvider>(),
    );
    final allEvents = calendarProvider.getAllEvents();
    
    final eventsMap = <DateTime, List<CalendarEventModel>>{};
    for (var event in allEvents) {
      final dateKey = DateTime(event.date.year, event.date.month, event.date.day);
      eventsMap[dateKey] ??= [];
      eventsMap[dateKey]!.add(event);
    }
    return eventsMap;
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch all providers to rebuild when data changes
    context.watch<PetProvider>();
    context.watch<ReminderProvider>();
    context.watch<VaccinationProvider>();
    context.watch<HealthRecordProvider>();
    context.watch<MilestoneProvider>();
    context.watch<ActivityProvider>();
    context.watch<ExpenseProvider>();
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final eventsMap = _getEventsMap();
    
    // Update selected events when data changes
    _selectedEvents.value = _getEventsForDay(_selectedDay);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? theme.colorScheme.surface : AppTheme.accentOrange,
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Calendar
          TableCalendar<CalendarEventModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: (day) => eventsMap[DateTime(day.year, day.month, day.day)] ?? [],
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(
                color: isDark ? theme.colorScheme.onSurface : Colors.black87,
                fontFamily: 'Poppins',
              ),
              defaultTextStyle: TextStyle(
                color: isDark ? theme.colorScheme.onSurface : Colors.black87,
                fontFamily: 'Poppins',
              ),
              selectedDecoration: BoxDecoration(
                color: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: (isDark ? theme.colorScheme.primary : AppTheme.accentOrange).withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              markerDecoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerSize: 6,
              markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                ),
              ),
              formatButtonTextStyle: TextStyle(
                color: theme.colorScheme.onSurface,
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
              titleTextStyle: TextStyle(
                color: theme.colorScheme.onSurface,
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                
                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events.take(3).map((event) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        decoration: BoxDecoration(
                          color: event.color,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Selected Day Events
          Expanded(
            child: ValueListenableBuilder<List<CalendarEventModel>>(
              valueListenable: _selectedEvents,
              builder: (context, events, _) {
                if (events.isEmpty) {
                  return Center(
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
                          'No events on ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _buildEventTile(event, theme, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(CalendarEventModel event, ThemeData theme, bool isDark) {
    IconData icon;
    switch (event.type) {
      case 'reminder':
        icon = Icons.notifications;
        break;
      case 'vaccination':
        icon = Icons.medical_services;
        break;
      case 'health':
        icon = Icons.favorite;
        break;
      case 'milestone':
        icon = Icons.cake;
        break;
      case 'activity':
        icon = Icons.directions_walk;
        break;
      case 'expense':
        icon = Icons.receipt_long;
        break;
      default:
        icon = Icons.event;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: event.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DayEventsScreen(
                date: _selectedDay,
                events: _selectedEvents.value,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: event.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: event.color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (event.time != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.time!.format(context),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

