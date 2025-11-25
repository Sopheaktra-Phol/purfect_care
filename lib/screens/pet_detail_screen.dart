import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/reminder_model.dart';
import 'package:purfect_care/models/health_record_model.dart';
import 'package:purfect_care/providers/reminder_provider.dart';
import 'package:purfect_care/providers/pet_provider.dart';
import 'package:purfect_care/providers/health_record_provider.dart';
import 'package:purfect_care/widgets/safe_image.dart';
import 'package:purfect_care/screens/add_reminder_screen.dart';
import 'package:purfect_care/screens/health_tracker_screen.dart';
import 'package:purfect_care/screens/today_tasks_screen.dart';
import 'package:purfect_care/theme/app_theme.dart';
import 'add_pet_screen.dart';
import 'package:intl/intl.dart';

class PetDetailScreen extends StatelessWidget {
  final PetModel pet;
  const PetDetailScreen({super.key, required this.pet});

  // Helper to format age (e.g., "1y 4m 11d")
  String _formatAge(int ageInMonths) {
    if (ageInMonths < 12) {
      return '$ageInMonths m';
    }
    final years = ageInMonths ~/ 12;
    final months = ageInMonths % 12;
    if (months == 0) {
      return '${years}y';
    }
    return '${years}y ${months}m';
  }

  // Helper to format time ago (e.g., "Just now", "10mins ago", "2 days ago")
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return minutes == 1 ? '1min ago' : '${minutes}mins ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return hours == 1 ? '1 hour ago' : '${hours} hours ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return days == 1 ? '1 day ago' : '${days} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '${weeks} weeks ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '${months} months ago';
    }
  }

  // Helper to format time in the future (e.g., "in 10mins", "in 2 days")
  String _formatTimeInFuture(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return minutes == 1 ? 'in 1min' : 'in ${minutes}mins';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return hours == 1 ? 'in 1 hour' : 'in ${hours} hours';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return days == 1 ? 'in 1 day' : 'in ${days} days';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'in 1 week' : 'in ${weeks} weeks';
    } else {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'in 1 month' : 'in ${months} months';
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProv = context.watch<PetProvider>();
    final remProv = context.watch<ReminderProvider>();
    final healthProv = context.watch<HealthRecordProvider>();
    
    // Get the latest pet data from provider if available, otherwise use the passed pet
    PetModel currentPet;
    if (pet.id != null) {
      try {
        currentPet = petProv.pets.firstWhere((p) => p.id == pet.id);
      } catch (e) {
        currentPet = pet;
      }
    } else {
      currentPet = pet;
    }
    
    final reminders = remProv.reminders.where((r) => r.petId == currentPet.id).toList();
    final healthRecords = healthProv.healthRecords.where((r) => r.petId == currentPet.id).toList();
    
    // Get last health check
    HealthRecordModel? lastHealthCheck;
    if (healthRecords.isNotEmpty) {
      healthRecords.sort((a, b) => b.date.compareTo(a.date));
      lastHealthCheck = healthRecords.first;
    }
    
    // Get the most recent/upcoming reminder (any type)
    ReminderModel? lastReminder;
    final now = DateTime.now();
    
    if (reminders.isNotEmpty) {
      // Check if there are any incomplete reminders
      final incompleteReminders = reminders.where((r) => !r.isCompleted).toList();
      
      // Get only reminders that have already passed (time is in the past)
      final pastReminders = reminders.where((r) => r.time.isBefore(now)).toList();
      
      if (pastReminders.isNotEmpty) {
        // Sort by time descending to get the most recent past reminder
        pastReminders.sort((a, b) => b.time.compareTo(a.time));
        lastReminder = pastReminders.first;
      } else if (incompleteReminders.isNotEmpty) {
        // If no past reminders but there are incomplete reminders, show the nearest future one
        incompleteReminders.sort((a, b) => a.time.compareTo(b.time)); // Sort ascending to get nearest future
        lastReminder = incompleteReminders.first;
      }
      // If all reminders are completed (both past and future), don't show anything
    }
    
    // Helper to get icon and color based on reminder title
    Map<String, dynamic> _getReminderIcon(String title) {
      final lowerTitle = title.toLowerCase();
      if (lowerTitle.contains('feed') || lowerTitle.contains('food') || lowerTitle.contains('meal')) {
        return {
          'icon': Icons.restaurant,
          'color': const Color(0xFFFB930B), // Orange
        };
      } else if (lowerTitle.contains('walk')) {
        return {
          'icon': Icons.directions_walk,
          'color': Colors.blue,
        };
      } else if (lowerTitle.contains('vet') || lowerTitle.contains('health')) {
        return {
          'icon': Icons.local_hospital,
          'color': Colors.red,
        };
      } else if (lowerTitle.contains('groom')) {
        return {
          'icon': Icons.content_cut,
          'color': Colors.purple,
        };
      } else {
        return {
          'icon': Icons.notifications,
          'color': const Color(0xFFFB930B), // Orange
        };
      }
    }
    
    // Get icon and color for the last reminder
    final reminderIconData = lastReminder != null 
        ? _getReminderIcon(lastReminder.title)
        : {'icon': Icons.notifications, 'color': const Color(0xFFFB930B)};
    
    // Get remaining tasks count
    final remainingTasks = reminders.where((r) => !r.isCompleted).toList();
    final remainingTasksCount = remainingTasks.length;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F5), // Light beige background - matching theme
      appBar: AppBar(
        backgroundColor: const Color(0xFFFB930B), // Orange - matching theme
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          currentPet.name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          _SwallowMenuButton(
            onEdit: () async {
              final updatedPet = await Navigator.push<PetModel>(
                context,
                MaterialPageRoute(builder: (_) => AddPetScreen(pet: currentPet)),
              );
              if (updatedPet != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pet updated successfully')),
                );
              }
            },
            onDelete: () async {
              if (currentPet.id != null) {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    title: const Text(
                      'Delete Pet',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    content: Text(
                      'Are you sure you want to delete ${currentPet.name}?',
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await petProv.deletePet(currentPet.id!);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pet deleted successfully')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Picture placeholder at top
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SafeImage(
                  imagePath: currentPet.photoPath,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: const Color(0xFFF5F5F5),
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Profile card with name and breed
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentPet.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentPet.breed,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: currentPet.gender == 'Female' 
                          ? const Color(0xFFFFB6C1) // Pink for female
                          : const Color(0xFFADD8E6), // Light blue for male
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      currentPet.gender == 'Female' ? Icons.female : Icons.male,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // About section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 32.0, 20.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
                      const Icon(Icons.pets, size: 20, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        'About ${currentPet.name}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Info cards - show all user-provided data
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          label: 'Age',
                          value: currentPet.age > 0 ? _formatAge(currentPet.age) : 'N/A',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          label: 'Weight',
                          value: currentPet.weight != null && currentPet.weight!.isNotEmpty 
                              ? currentPet.weight! 
                              : 'N/A',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          label: 'Height',
                          value: currentPet.height != null && currentPet.height!.isNotEmpty 
                              ? currentPet.height! 
                              : 'N/A',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          label: 'Color',
                          value: currentPet.color != null && currentPet.color!.isNotEmpty 
                              ? currentPet.color! 
                              : 'N/A',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Bio text
                  if (currentPet.notes != null && currentPet.notes!.isNotEmpty)
                    Text(
                      currentPet.notes!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    )
                  else
                    Text(
                      'No additional information available.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.grey[600]!.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Status section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.home, size: 20, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        '${currentPet.name}\'s Status',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Health status - only show if there are health records
                  if (healthRecords.isNotEmpty)
                    _StatusItem(
                      icon: Icons.favorite,
                      iconColor: const Color(0xFFE54D4D), // Red
                      title: 'Health',
                      status: lastHealthCheck != null 
                          ? 'Last Checked [${_formatTimeAgo(lastHealthCheck.date)}]'
                          : 'No recent records',
                      timeInfo: '${healthRecords.length} record${healthRecords.length == 1 ? '' : 's'}',
                      buttonText: 'View Records >',
                      buttonColor: const Color(0xFFE54D4D), // Red
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HealthTrackerScreen(pet: currentPet),
                          ),
                        );
                      },
                    ),
                  if (healthRecords.isNotEmpty) const SizedBox(height: 12),
                  // Task status - only show if there are reminders
                  if (reminders.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            reminderIconData['icon'] as IconData,
                            color: reminderIconData['color'] as Color,
                            size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                Text(
                                  lastReminder != null ? lastReminder.title : 'Tasks',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lastReminder != null && lastReminder.time.isBefore(DateTime.now())
                                      ? 'Last ${lastReminder.title} [${_formatTimeAgo(lastReminder.time)}]'
                                      : lastReminder != null && !lastReminder.isCompleted
                                          ? 'Next ${lastReminder.title} [${_formatTimeInFuture(lastReminder.time)}]'
                                          : 'No recent tasks',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$remainingTasksCount task${remainingTasksCount == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: reminderIconData['color'] as Color,
                ),
              ),
            ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // View Reminders button
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TodayTasksScreen(pet: currentPet),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: reminderIconData['color'] as Color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'View >',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Add Reminder button
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddReminderScreen(pet: currentPet),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: reminderIconData['color'] as Color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Add +',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Show message if no status data available
                   if (healthRecords.isEmpty && reminders.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'No status information available yet.\nAdd health records or reminders to see status updates.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
          ),
          const SizedBox(height: 16),
              ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                  context,
                                MaterialPageRoute(
                                  builder: (_) => AddReminderScreen(pet: currentPet),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Add Reminder',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFB930B), // Orange
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.black, width: 1.5),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                   // Always show "Add Reminder" button if there are health records but no reminders
                   if (reminders.isEmpty && healthRecords.isNotEmpty)
                     const SizedBox(height: 12),
                   if (reminders.isEmpty && healthRecords.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                  context,
                            MaterialPageRoute(
                              builder: (_) => AddReminderScreen(pet: currentPet),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Add Reminder',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFB930B), // Orange
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.black, width: 1.5),
                          ),
                          elevation: 0,
                        ),
                      ),
          ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Info card widget for Age, Weight, Height, Color
class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Light green background - matching add pet screen
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// Status item widget for Health, Food, Mood
class _StatusItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String status;
  final String timeInfo;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onTap;

  const _StatusItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.status,
    required this.timeInfo,
    required this.buttonText,
    required this.buttonColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeInfo,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: const Color(0xFFFB930B), // Orange for time info
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom animated swallow/arrow menu button
class _SwallowMenuButton extends StatefulWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SwallowMenuButton({
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_SwallowMenuButton> createState() => _SwallowMenuButtonState();
}

class _SwallowMenuButtonState extends State<_SwallowMenuButton>
    with TickerProviderStateMixin {
  bool _isMenuOpen = false;
  bool _isPressed = false;
  late final AnimationController _transformController;
  late final AnimationController _scaleController;
  late final Animation<double> _transformAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _transformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _transformAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transformController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _transformController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _showMenu(BuildContext context) {
    final RenderBox? button = context.findRenderObject() as RenderBox?;
    if (button == null) return;
    
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero);
    final Size buttonSize = button.size;

    setState(() {
      _isMenuOpen = true;
    });
    _transformController.forward();

    showMenu(
      context: context,
      color: Colors.transparent,
      elevation: 0,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx + buttonSize.width - 200, // Align to right
        buttonPosition.dy + buttonSize.height + 8, // Below button
        overlay.size.width - buttonPosition.dx - buttonSize.width,
        overlay.size.height - buttonPosition.dy - buttonSize.height - 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: _MenuButtonItem(
            icon: Icons.edit_outlined,
            iconColor: const Color(0xFFFB930B),
            title: 'Edit Pet',
            titleColor: Colors.black,
            onTap: () {
              Navigator.pop(context);
              widget.onEdit();
            },
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: _MenuButtonItem(
            icon: Icons.delete_outline,
            iconColor: Colors.red,
            title: 'Delete Pet',
            titleColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              widget.onDelete();
            },
          ),
        ),
      ],
    ).then((_) {
      if (mounted) {
        setState(() {
          _isMenuOpen = false;
        });
        _transformController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _scaleController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _scaleController.reverse();
        _showMenu(context);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _scaleController.reverse();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_transformController, _scaleController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: _DotsToChevronPainter(
                  progress: _transformAnimation.value,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DotsToChevronPainter extends CustomPainter {
  final double progress; // 0.0 = 3 dots, 1.0 = chevron

  _DotsToChevronPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final dotRadius = 2.5;
    final dotSpacing = 6.5;
    final chevronSize = 10.0;

    if (progress < 0.5) {
      // Show 3 dots, fade out
      final opacity = 1.0 - (progress * 2);
      
      // Create paint for solid dots - simple and clean
      final dotPaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Top dot - solid circle
      canvas.drawCircle(
        Offset(centerX, centerY - dotSpacing),
        dotRadius,
        dotPaint,
      );
      
      // Middle dot - solid circle
      canvas.drawCircle(
        Offset(centerX, centerY),
        dotRadius,
        dotPaint,
      );
      
      // Bottom dot - solid circle
      canvas.drawCircle(
        Offset(centerX, centerY + dotSpacing),
        dotRadius,
        dotPaint,
      );
    } else {
      // Show chevron, fade in
      final chevronProgress = (progress - 0.5) * 2;
      
      final chevronPaint = Paint()
        ..color = Colors.white.withOpacity(chevronProgress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Draw chevron pointing down (V shape)
      final path = Path();
      path.moveTo(centerX - chevronSize / 2, centerY - chevronSize / 4);
      path.lineTo(centerX, centerY + chevronSize / 3);
      path.lineTo(centerX + chevronSize / 2, centerY - chevronSize / 4);

      canvas.drawPath(path, chevronPaint);
    }
  }

  @override
  bool shouldRepaint(_DotsToChevronPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

// Custom menu button item with improved UI/UX
class _MenuButtonItem extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final VoidCallback onTap;

  const _MenuButtonItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.onTap,
  });

  @override
  State<_MenuButtonItem> createState() => _MenuButtonItemState();
}

class _MenuButtonItemState extends State<_MenuButtonItem>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: widget.iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.iconColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: widget.titleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
