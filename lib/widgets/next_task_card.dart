import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/reminder_model.dart';
import '../models/pet_model.dart';
import '../providers/pet_provider.dart';
import '../screens/today_tasks_screen.dart';
import 'safe_image.dart';

class NextTaskCard extends StatelessWidget {
  final ReminderModel reminder;

  const NextTaskCard({super.key, required this.reminder});

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
    } else {
      return DateFormat.yMd().add_jm().format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProv = context.watch<PetProvider>();
    PetModel? pet;
    try {
      pet = petProv.pets.firstWhere((p) => p.id == reminder.petId);
    } catch (e) {
      // Pet not found
    }

    final iconData = _getReminderIcon(reminder.title);
    final timeText = _formatTimeInFuture(reminder.time);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to today's tasks
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TodayTasksScreen()),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (iconData['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    iconData['icon'] as IconData,
                    color: iconData['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label
                      Text(
                        'Next Task',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Task title
                      Text(
                        reminder.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Pet name and time
                      Row(
                        children: [
                          if (pet != null) ...[
                            SafeCircleAvatar(
                              imagePath: pet.photoPath,
                              radius: 12,
                              child: const Icon(Icons.pets, size: 12),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              pet.name,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeText,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
