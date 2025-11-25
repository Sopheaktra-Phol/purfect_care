import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:purfect_care/providers/reminder_provider.dart';
import 'package:purfect_care/providers/pet_provider.dart';
import 'package:purfect_care/models/reminder_model.dart';
import 'package:purfect_care/models/pet_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  // Helper to format time ago or scheduled time
  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.isNegative) {
      // Past time - show how long ago
      final pastDiff = now.difference(dateTime);
      if (pastDiff.inMinutes < 1) {
        return 'Just now';
      } else if (pastDiff.inMinutes < 60) {
        return '${pastDiff.inMinutes}m ago';
      } else if (pastDiff.inHours < 24) {
        return '${pastDiff.inHours}h ago';
      } else if (pastDiff.inDays < 7) {
        return '${pastDiff.inDays}d ago';
      } else {
        return DateFormat.yMd().add_jm().format(dateTime);
      }
    } else {
      // Future time - show when it's scheduled
      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return 'In ${difference.inMinutes}m';
        }
        return 'In ${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return 'In ${difference.inDays}d';
      } else {
        return DateFormat.yMd().add_jm().format(dateTime);
      }
    }
  }

  // Get icon and color based on reminder title
  Map<String, dynamic> _getReminderIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('feed') || lowerTitle.contains('food')) {
      return {
        'icon': Icons.restaurant,
        'color': const Color(0xFFFB930B), // Orange
      };
    } else if (lowerTitle.contains('walk')) {
      return {
        'icon': Icons.directions_walk,
        'color': Colors.blue,
      };
    } else if (lowerTitle.contains('vet')) {
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

  Future<void> _onRefresh() async {
    // Reload reminders from the provider
    final reminderProv = context.read<ReminderProvider>();
    final petProv = context.read<PetProvider>();
    
    // Reload both reminders and pets
    reminderProv.loadReminders();
    petProv.loadPets();
    
    // Wait a bit to show the refresh animation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final reminderProv = context.watch<ReminderProvider>();
    final petProv = context.watch<PetProvider>();
    
    // Load reminders if not already loaded
    if (reminderProv.reminders.isEmpty) {
      reminderProv.loadReminders();
    }
    
    // Get only reminders that have already passed (notifications already sent)
    final now = DateTime.now();
    final pastReminders = reminderProv.reminders
        .where((reminder) => reminder.time.isBefore(now))
        .toList();
    
    // Sort by time (most recent first)
    pastReminders.sort((a, b) => b.time.compareTo(a.time));

    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F5), // Light beige background - matching theme
      appBar: AppBar(
        backgroundColor: const Color(0xFFFB930B), // Orange - matching theme
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFFFB930B), // Orange color for refresh indicator
        backgroundColor: Colors.white,
        child: pastReminders.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when empty
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200, // Account for AppBar
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No notifications yet',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Notifications will appear here after\ntheir scheduled time has passed',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Pull down to refresh',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
                padding: const EdgeInsets.all(24.0),
                itemCount: pastReminders.length,
                itemBuilder: (context, index) {
                  final reminder = pastReminders[index];
                  PetModel? pet;
                  try {
                    pet = petProv.pets.firstWhere((p) => p.id == reminder.petId);
                  } catch (e) {
                    // Pet not found, skip this reminder
                    return const SizedBox.shrink();
                  }
                  
                  if (pet == null) return const SizedBox.shrink();
                  
                  final iconData = _getReminderIcon(reminder.title);
                  
                  return _NotificationTile(
                    icon: iconData['icon'] as IconData,
                    iconColor: iconData['color'] as Color,
                    title: reminder.title,
                    message: "It's time to ${reminder.title.toLowerCase()} ${pet.name}!",
                    timestamp: _formatTimestamp(reminder.time),
                    isUpcoming: false, // All shown notifications are past
                    repeat: reminder.repeat,
                  );
                },
              ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String timestamp;
  final bool isUpcoming;
  final String repeat;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isUpcoming = true,
    this.repeat = 'none',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        onTap: () {
          // Handle notification tap
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped on: $title - $message'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: iconColor, width: 1.5),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              // Title and message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (repeat != 'none')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              repeat.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: iconColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Timestamp and arrow
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    timestamp,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


