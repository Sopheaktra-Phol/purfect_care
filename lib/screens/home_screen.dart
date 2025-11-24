import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purfect_care/providers/reminder_provider.dart';
import '../providers/pet_provider.dart';
import '../widgets/pet_card.dart';
import 'add_pet_screen.dart';
import 'pet_detail_screen.dart';
import 'today_tasks_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import '../widgets/next_task_card.dart';
import '../widgets/progress_tracker.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Request notification permissions when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notificationService = NotificationService();
      final hasPermission = await notificationService.areNotificationsEnabled();
      if (!hasPermission) {
        print('Requesting notification permissions from HomeScreen...');
        await notificationService.requestPermissions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final petProv = context.watch<PetProvider>();
    final reminderProv = context.watch<ReminderProvider>();
    final upcomingReminders = reminderProv.reminders.where((r) => r.time.isAfter(DateTime.now())).toList();
    upcomingReminders.sort((a, b) => a.time.compareTo(b.time));
    final nextReminder = upcomingReminders.isNotEmpty ? upcomingReminders.first : null;
    final todaysReminders = reminderProv.reminders.where((r) {
      final now = DateTime.now();
      return r.time.year == now.year && r.time.month == now.month && r.time.day == now.day;
    }).toList();
    final completedTodaysReminders = todaysReminders.where((r) => r.isCompleted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F5), // Light beige background - matching theme
      appBar: AppBar(
        backgroundColor: const Color(0xFFFB930B), // Orange - matching theme
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
        title: const Text(
          'Purfect Care',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (nextReminder != null)
            NextTaskCard(reminder: nextReminder),
          if (todaysReminders.isNotEmpty)
            ProgressTracker(
              completedTasks: completedTodaysReminders.length,
              totalTasks: todaysReminders.length,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TodayTasksScreen()),
                );
              },
            ),
          const SizedBox(height: 24),
          const Text(
            'My Pets',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          petProv.pets.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No pets yet.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPetScreen())),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFB930B), // Orange
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.black, width: 1.5),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Add Pet',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: petProv.pets.length,
                  itemBuilder: (context, i) {
                    final pet = petProv.pets[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PetDetailScreen(pet: pet))),
                      onLongPress: () async {
                        // Long press to edit directly
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddPetScreen(pet: pet)),
                        );
                        // Refresh pets after editing
                        petProv.loadPets();
                      },
                      child: PetCard(pet: pet),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPetScreen())),
        backgroundColor: const Color(0xFFFB930B), // Orange
        foregroundColor: Colors.white,
        elevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }
}
