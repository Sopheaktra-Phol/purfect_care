import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/reminder_model.dart';
import 'package:purfect_care/providers/pet_provider.dart';
import 'package:purfect_care/providers/reminder_provider.dart';
import 'package:purfect_care/widgets/reminder_tile.dart';
import 'package:purfect_care/widgets/safe_image.dart';

class TodayTasksScreen extends StatelessWidget {
  const TodayTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petProv = context.watch<PetProvider>();
    final reminderProv = context.watch<ReminderProvider>();
    
    // Get today's reminders
    final now = DateTime.now();
    final todaysReminders = reminderProv.reminders.where((r) {
      return r.time.year == now.year && 
             r.time.month == now.month && 
             r.time.day == now.day;
    }).toList();
    
    // Get only remaining (incomplete) tasks
    final remainingTasks = todaysReminders.where((r) => !r.isCompleted).toList();
    
    // Group tasks by pet
    final Map<int, List<ReminderModel>> tasksByPet = {};
    for (var reminder in remainingTasks) {
      if (!tasksByPet.containsKey(reminder.petId)) {
        tasksByPet[reminder.petId] = [];
      }
      tasksByPet[reminder.petId]!.add(reminder);
    }
    
    // Sort tasks within each pet by time
    tasksByPet.forEach((petId, tasks) {
      tasks.sort((a, b) => a.time.compareTo(b.time));
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Remaining Tasks'),
      ),
      body: remainingTasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All tasks completed!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Great job taking care of your pets!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tasksByPet.length,
              itemBuilder: (context, index) {
                final petId = tasksByPet.keys.elementAt(index);
                final pet = petProv.pets.firstWhere(
                  (p) => p.id == petId,
                  orElse: () => PetModel(
                    name: 'Unknown Pet',
                    species: 'Unknown',
                    gender: 'Unknown',
                    age: 0,
                    breed: 'Unknown',
                  ),
                );
                final tasks = tasksByPet[petId]!;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            SafeCircleAvatar(
                              imagePath: pet.photoPath,
                              radius: 24,
                              child: const Icon(Icons.pets, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pet.name,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${tasks.length} task${tasks.length > 1 ? 's' : ''} remaining',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tasks list
                      ...tasks.map((reminder) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ReminderTile(reminder: reminder),
                      )),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

