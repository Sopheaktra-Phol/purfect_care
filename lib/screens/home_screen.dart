import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawfect_care/providers/reminder_provider.dart';
import '../providers/pet_provider.dart';
import '../widgets/pet_card.dart';
import 'add_pet_screen.dart';
import 'pet_detail_screen.dart';
import '../widgets/next_task_card.dart';
import '../widgets/progress_tracker.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      appBar: AppBar(title: const Text('Pawfect Care')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (nextReminder != null)
            NextTaskCard(reminder: nextReminder),
          if (todaysReminders.isNotEmpty)
            ProgressTracker(
              completedTasks: completedTodaysReminders.length,
              totalTasks: todaysReminders.length,
            ),
          const SizedBox(height: 12),
          Text(
            'My Pets',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          petProv.pets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No pets yet.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPetScreen())),
                        child: const Text('Add Pet'),
                      ),
                    ],
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
                      child: PetCard(pet: pet),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPetScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
