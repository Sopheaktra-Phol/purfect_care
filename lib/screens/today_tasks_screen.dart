import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/reminder_model.dart';
import 'package:purfect_care/providers/pet_provider.dart';
import 'package:purfect_care/providers/reminder_provider.dart';
import 'package:purfect_care/widgets/reminder_tile.dart';
import 'package:purfect_care/widgets/safe_image.dart';

class TodayTasksScreen extends StatelessWidget {
  final PetModel? pet; // Optional pet filter
  const TodayTasksScreen({super.key, this.pet});

  @override
  Widget build(BuildContext context) {
    final petProv = context.watch<PetProvider>();
    final reminderProv = context.watch<ReminderProvider>();
    
    // Get today's reminders
    final now = DateTime.now();
    var todaysReminders = reminderProv.reminders.where((r) {
      return r.time.year == now.year && 
             r.time.month == now.month && 
             r.time.day == now.day;
    }).toList();
    
    // Filter out reminders for deleted pets (safety check)
    todaysReminders = todaysReminders.where((r) {
      return petProv.pets.any((p) => p.id == r.petId);
    }).toList();
    
    // Filter by pet if specified
    if (pet != null) {
      todaysReminders = todaysReminders.where((r) => r.petId == pet!.id).toList();
    }
    
    // Get only remaining (incomplete) tasks
    final remainingTasks = todaysReminders.where((r) => !r.isCompleted).toList();
    
    // Sort tasks by time
    remainingTasks.sort((a, b) => a.time.compareTo(b.time));

    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F5), // Light beige background - matching theme
      appBar: AppBar(
        backgroundColor: const Color(0xFFFB930B), // Orange - matching theme
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          pet != null 
              ? '${pet!.name}\'s Tasks'
              : 'Today\'s Remaining Tasks',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: remainingTasks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Colors.green[400],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      pet != null 
                          ? 'All tasks completed for ${pet!.name}!'
                          : 'All tasks completed!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Great job taking care of your pet! 🎉',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : pet != null
              // Show single pet's tasks (no grouping needed)
              ? ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: remainingTasks.length,
                  itemBuilder: (context, index) {
                    return ReminderTile(reminder: remainingTasks[index]);
                  },
                )
              // Show all pets' tasks grouped by pet
              : _buildGroupedTasksList(context, petProv, remainingTasks),
    );
  }

  Widget _buildGroupedTasksList(BuildContext context, PetProvider petProv, List<ReminderModel> remainingTasks) {
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

    return ListView.builder(
      padding: const EdgeInsets.all(24),
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
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFB930B).withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
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
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${tasks.length} task${tasks.length > 1 ? 's' : ''} remaining',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
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
    );
  }
}

