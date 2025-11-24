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

  // Helper to format time ago (e.g., "3min Ago", "2h Ago")
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min Ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h Ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d Ago';
    } else {
      return DateFormat.yMd().format(dateTime);
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
    
    // Get last fed reminder (look for food-related reminders)
    ReminderModel? lastFedReminder;
    final foodReminders = reminders.where((r) => 
      r.title.toLowerCase().contains('feed') || 
      r.title.toLowerCase().contains('food') ||
      r.title.toLowerCase().contains('meal')
    ).toList();
    if (foodReminders.isNotEmpty) {
      foodReminders.sort((a, b) => b.time.compareTo(a.time));
      lastFedReminder = foodReminders.first;
    }
    
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
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Show options menu
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text(
                        'Edit Pet',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
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
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text(
                        'Delete Pet',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
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
                          if (confirmed == true && currentPet.id != null && context.mounted) {
                            await petProv.deletePet(currentPet.id!);
                            if (context.mounted && Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
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
                  // Food status - only show if there are food-related reminders
                  if (foodReminders.isNotEmpty)
                    _StatusItem(
                      icon: Icons.restaurant,
                      iconColor: const Color(0xFFFB930B), // Orange
                      title: 'Food',
                      status: lastFedReminder != null
                          ? 'Last Fed [${_formatTimeAgo(lastFedReminder.time)}]'
                          : 'No recent feeding',
                      timeInfo: '${foodReminders.length} reminder${foodReminders.length == 1 ? '' : 's'}',
                      buttonText: 'View Reminders >',
                      buttonColor: const Color(0xFFFB930B), // Orange
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddReminderScreen(pet: currentPet),
                          ),
                        );
                      },
                    ),
                  // Show message if no status data available
                  if (healthRecords.isEmpty && foodReminders.isEmpty)
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
                  // Always show "Add Reminder" button if there are health records but no food reminders
                  if (foodReminders.isEmpty && healthRecords.isNotEmpty)
                    const SizedBox(height: 12),
                  if (foodReminders.isEmpty && healthRecords.isNotEmpty)
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
