import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/reminder_model.dart';
import 'package:purfect_care/models/health_record_model.dart';
import 'package:purfect_care/providers/reminder_provider.dart';
import 'package:purfect_care/providers/pet_provider.dart';
import 'package:purfect_care/providers/health_record_provider.dart';
import 'package:purfect_care/providers/weight_provider.dart';
import 'package:purfect_care/providers/milestone_provider.dart';
import 'package:purfect_care/providers/vaccination_provider.dart';
import 'package:purfect_care/providers/photo_provider.dart';
import 'package:purfect_care/providers/activity_provider.dart';
import 'package:purfect_care/providers/expense_provider.dart';
import 'package:purfect_care/models/milestone_model.dart';
import 'package:purfect_care/models/activity_model.dart';
import 'package:purfect_care/models/expense_model.dart';
import 'package:purfect_care/widgets/safe_image.dart';
import 'package:purfect_care/widgets/milestone_card.dart';
import 'package:purfect_care/screens/add_reminder_screen.dart';
import 'package:purfect_care/screens/health_tracker_screen.dart';
import 'package:purfect_care/screens/today_tasks_screen.dart';
import 'package:purfect_care/screens/weight_tracking_screen.dart';
import 'package:purfect_care/screens/add_milestone_screen.dart';
import 'package:purfect_care/screens/vaccination_screen.dart';
import 'package:purfect_care/screens/photo_gallery_screen.dart';
import 'package:purfect_care/screens/activity_tracking_screen.dart';
import 'package:purfect_care/screens/expense_tracking_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'add_pet_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final PetModel pet;
  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load data once when screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasInitialized) return;
      _hasInitialized = true;
      
      final petProv = context.read<PetProvider>();
      final weightProv = context.read<WeightProvider>();
      final milestoneProv = context.read<MilestoneProvider>();
      final vaccinationProv = context.read<VaccinationProvider>();
      final photoProv = context.read<PhotoProvider>();
      final activityProv = context.read<ActivityProvider>();
      final expenseProv = context.read<ExpenseProvider>();
      
      // Get the current pet
      PetModel currentPet;
      if (widget.pet.id != null) {
        try {
          currentPet = petProv.pets.firstWhere((p) => p.id == widget.pet.id);
        } catch (e) {
          currentPet = widget.pet;
        }
      } else {
        currentPet = widget.pet;
      }
      
      // Load data if pet has ID and data hasn't been loaded
      if (currentPet.id != null) {
        if (!weightProv.hasLoadedWeightEntries(currentPet.id!)) {
          weightProv.loadWeightEntries(currentPet.id!);
        }
        if (!milestoneProv.hasLoadedMilestones(currentPet.id!)) {
          milestoneProv.loadMilestones(currentPet.id!);
        }
        if (!vaccinationProv.hasLoadedVaccinations(currentPet.id!)) {
          vaccinationProv.loadVaccinations(currentPet.id!);
        }
        if (!photoProv.hasLoadedPhotos(currentPet.id!)) {
          photoProv.loadPhotos(currentPet.id!);
        }
        if (!activityProv.hasLoadedActivities(currentPet.id!)) {
          activityProv.loadActivities(currentPet.id!);
        }
        if (!expenseProv.hasLoadedExpenses(currentPet.id!)) {
          expenseProv.loadExpenses(currentPet.id!);
        }
      }
    });
  }

  // Helper to format age (e.g., "3 Months Old", "1 Years Old", "1 Year 1 Month Old")
  String _formatAge(int ageInMonths) {
    if (ageInMonths < 12) {
      return '$ageInMonths ${ageInMonths == 1 ? 'Month' : 'Months'} Old';
    }
    final years = ageInMonths ~/ 12;
    final months = ageInMonths % 12;
    if (months == 0) {
      return '$years ${years == 1 ? 'Year' : 'Years'} Old';
    }
    final yearText = years == 1 ? 'Year' : 'Years';
    final monthText = months == 1 ? 'Month' : 'Months';
    return '$years $yearText $months $monthText Old';
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
    final weightProv = context.watch<WeightProvider>();
    final milestoneProv = context.watch<MilestoneProvider>();
    final vaccinationProv = context.watch<VaccinationProvider>();
    final photoProv = context.watch<PhotoProvider>();
    final activityProv = context.watch<ActivityProvider>();
    final expenseProv = context.watch<ExpenseProvider>();
    
    // Get the latest pet data from provider if available, otherwise use the passed pet
    // Always prefer the provider's version as it has the latest data
    PetModel currentPet = widget.pet; // Default to widget.pet
    
    if (widget.pet.id != null) {
      // Always try to get the pet from provider first (it has the latest data)
      try {
        final providerPet = petProv.pets.firstWhere((p) => p.id == widget.pet.id);
        currentPet = providerPet; // Use provider's version (has latest photoPath)
        print('📸 Pet detail screen - Using provider pet, photoPath: ${currentPet.photoPath}');
      } catch (e) {
        // Pet not found in provider list
        print('⚠️ Pet not found in provider list, using widget.pet');
        print('⚠️ Provider has ${petProv.pets.length} pets, isLoading: ${petProv.isLoading}');
        
        // If provider list is empty and not loading, try to load pets
        if (petProv.pets.isEmpty && !petProv.isLoading) {
          print('🔄 Provider list is empty, loading pets...');
          petProv.loadPets();
        }
        
        // Use widget.pet as fallback (but this has old data)
        currentPet = widget.pet;
        print('📸 Pet detail screen - Using widget.pet (fallback), photoPath: ${currentPet.photoPath}');
      }
    }
    
    final reminders = remProv.reminders.where((r) => r.petId == currentPet.id).toList();
    final healthRecords = healthProv.healthRecords.where((r) => r.petId == currentPet.id).toList();
    
    // Data loading is now handled in initState, so we just read the data here
    final latestWeight = currentPet.id != null ? weightProv.getLatestWeight(currentPet.id!) : null;
    final petMilestones = currentPet.id != null ? milestoneProv.getMilestones(currentPet.id!) : [];
    final petVaccinations = currentPet.id != null ? vaccinationProv.getVaccinations(currentPet.id!) : [];
    final upcomingVaccinations = petVaccinations.where((v) => 
      v.nextDueDate != null && v.nextDueDate!.isAfter(DateTime.now())
    ).toList();
    final overdueVaccinations = petVaccinations.where((v) => 
      v.nextDueDate != null && v.nextDueDate!.isBefore(DateTime.now())
    ).toList();
    upcomingVaccinations.sort((a, b) => (a.nextDueDate ?? DateTime.now()).compareTo(b.nextDueDate ?? DateTime.now()));
    
    // Photos loading is now handled in initState
    final petPhotos = currentPet.id != null ? photoProv.getPhotos(currentPet.id!) : [];
    final primaryPhoto = currentPet.id != null ? photoProv.getPrimaryPhoto(currentPet.id!) : null;
    
    // Activities and expenses loading is now handled in initState
    final petActivities = currentPet.id != null ? activityProv.getActivities(currentPet.id!) : [];
    final todayActivities = currentPet.id != null ? activityProv.getTodayActivities(currentPet.id!) : [];
    final weekActivities = currentPet.id != null ? activityProv.getWeekActivities(currentPet.id!) : [];
    final todayDuration = currentPet.id != null ? activityProv.getTotalDuration(List<ActivityModel>.from(todayActivities)) : 0;
    final weekDuration = currentPet.id != null ? activityProv.getTotalDuration(List<ActivityModel>.from(weekActivities)) : 0;
    
    final petExpenses = currentPet.id != null ? expenseProv.getExpenses(currentPet.id!) : [];
    final monthExpenses = currentPet.id != null ? expenseProv.getMonthExpenses(currentPet.id!) : [];
    final monthTotal = currentPet.id != null ? expenseProv.getTotalAmount(List<ExpenseModel>.from(monthExpenses)) : 0.0;
    
    // Calculate next birthday
    DateTime? nextBirthday;
    int? daysUntilBirthday;
    if (currentPet.birthDate != null) {
      final now = DateTime.now();
      final thisYear = DateTime(now.year, currentPet.birthDate!.month, currentPet.birthDate!.day);
      if (thisYear.isBefore(now) || thisYear.isAtSameMomentAs(now)) {
        nextBirthday = DateTime(now.year + 1, currentPet.birthDate!.month, currentPet.birthDate!.day);
      } else {
        nextBirthday = thisYear;
      }
      daysUntilBirthday = nextBirthday.difference(now).inDays;
    }
    
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
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? theme.colorScheme.surface : const Color(0xFFFB930B),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: isDark ? theme.colorScheme.onSurface : Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          currentPet.name,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: isDark ? theme.colorScheme.onSurface : Colors.white,
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
                // Prevent multiple simultaneous delete operations
                if (petProv.isLoading) {
                  return; // Already processing
                }
                
                // Show improved confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Delete Pet',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Are you sure you want to delete ${currentPet.name}?',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This action cannot be undone. All data related to this pet will be permanently deleted.',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true && context.mounted) {
                  // Show improved loading dialog with animation
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => PopScope(
                      canPop: false,
                      child: Dialog(
                        backgroundColor: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Deleting ${currentPet.name}...',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please wait',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                  
                  try {
                    // Get all providers before deletion
                    final reminderProv = context.read<ReminderProvider>();
                    final healthProv = context.read<HealthRecordProvider>();
                    final weightProv = context.read<WeightProvider>();
                    final milestoneProv = context.read<MilestoneProvider>();
                    final vaccinationProv = context.read<VaccinationProvider>();
                    final photoProv = context.read<PhotoProvider>();
                    final activityProv = context.read<ActivityProvider>();
                    final expenseProv = context.read<ExpenseProvider>();
                    
                    // Delete pet from Firestore (this also deletes all related data in Firestore)
                    await petProv.deletePet(currentPet.id!);
                    
                    if (!context.mounted) return;
                    
                    // Close loading dialog
                    Navigator.of(context).pop();
                    
                    // Check for errors
                    if (petProv.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  petProv.errorMessage!,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                      return;
                    }
                    
                    // Clear all related data from local providers
                    // This ensures the UI updates immediately
                    final petIdInt = currentPet.id!;
                    
                    // Clear reminders (uses List)
                    reminderProv.reminders.removeWhere((r) => r.petId == petIdInt);
                    reminderProv.notifyListeners();
                    
                    // Reload reminders from Firestore to ensure UI is fully updated
                    try {
                      await reminderProv.loadReminders(pets: petProv.pets);
                    } catch (e) {
                      print('⚠️ Could not reload reminders: $e');
                    }
                    
                    // Clear health records (uses List)
                    healthProv.healthRecords.removeWhere((hr) => hr.petId == petIdInt);
                    healthProv.notifyListeners();
                    
                    // Clear weight entries (uses Map - remove the entire entry for this pet)
                    weightProv.deleteAllWeightEntriesForPet(petIdInt);
                    
                    // Clear milestones (uses Map - remove the entire entry for this pet)
                    milestoneProv.deleteAllMilestonesForPet(petIdInt);
                    
                    // Clear vaccinations (uses Map - remove the entire entry for this pet)
                    vaccinationProv.deleteAllVaccinationsForPet(petIdInt);
                    
                    // Clear photos (uses Map - remove the entire entry for this pet)
                    photoProv.deleteAllPhotosForPet(petIdInt);
                    
                    // Clear activities (uses Map - remove the entire entry for this pet)
                    activityProv.deleteAllActivitiesForPet(petIdInt);
                    
                    // Clear expenses (uses Map - remove the entire entry for this pet)
                    expenseProv.deleteAllExpensesForPet(petIdInt);
                    
                    print('✅ Cleared all related data from local providers');
                    
                    // Success - show success message first, then navigate
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${currentPet.name} and all related data deleted successfully',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    
                    // Wait a moment for user to see success message, then navigate
                    await Future.delayed(const Duration(milliseconds: 500));
                    
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;
                    
                    // Close loading dialog
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    
                    // Show error with better UI
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Failed to delete pet: ${e.toString()}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 4),
                      ),
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
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? theme.colorScheme.outline : Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotoGalleryScreen(pet: currentPet),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (primaryPhoto != null)
                        CachedNetworkImage(
                          imageUrl: primaryPhoto.photoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.surfaceVariant ?? const Color(0xFFF5F5F5),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: theme.colorScheme.surfaceVariant ?? const Color(0xFFF5F5F5),
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        )
                      else if (currentPet.photoPath != null)
                        SafeImage(
                          imagePath: currentPet.photoPath,
                          fit: BoxFit.cover,
                          placeholder: Container(
                            color: theme.colorScheme.surfaceVariant ?? const Color(0xFFF5F5F5),
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          color: theme.colorScheme.surfaceVariant ?? const Color(0xFFF5F5F5),
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      // Gallery indicator
                      if (petPhotos.isNotEmpty)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.photo_library, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${petPhotos.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
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
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? theme.colorScheme.outline : Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
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
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentPet.breed,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            color: theme.colorScheme.onSurfaceVariant,
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
                      border: Border.all(
                        color: isDark ? theme.colorScheme.surface : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
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
                      Icon(Icons.pets, size: 20, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 8),
                      Text(
                        'About ${currentPet.name}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Info cards - show all user-provided data in horizontal row
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? theme.colorScheme.surfaceVariant?.withOpacity(0.5)
                          : const Color(0xFFFFE5D4).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _InfoCard(
                          label: 'Age',
                          value: currentPet.age > 0 ? _formatAge(currentPet.age) : 'N/A',
                          icon: Icons.cake,
                          iconColor: const Color(0xFFFB930B), // Orange
                        ),
                        _InfoCard(
                          label: 'Weight',
                          value: currentPet.weight != null && currentPet.weight!.isNotEmpty 
                              ? '${currentPet.weight!} kg' 
                              : 'N/A',
                          icon: Icons.scale,
                          iconColor: Colors.green,
                        ),
                        _InfoCard(
                          label: 'Height',
                          value: currentPet.height != null && currentPet.height!.isNotEmpty 
                              ? '${currentPet.height!} cm' 
                              : 'N/A',
                          icon: Icons.straighten,
                          iconColor: Colors.blue,
                        ),
                        _InfoCard(
                          label: 'Breed',
                          value: currentPet.breed.isNotEmpty 
                              ? currentPet.breed 
                              : 'N/A',
                          icon: Icons.pets,
                          iconColor: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bio text
                  if (currentPet.notes != null && currentPet.notes!.isNotEmpty)
                    Text(
                      currentPet.notes!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    )
                  else
                    Text(
                      'No additional information available.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
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
                      Icon(Icons.home, size: 20, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 8),
                      Text(
                        '${currentPet.name}\'s Status',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
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
                  // Weight tracking status
                  if (currentPet.id != null)
                    _StatusItem(
                      icon: Icons.monitor_weight,
                      iconColor: Colors.green,
                      title: 'Weight',
                      status: latestWeight != null
                          ? '${latestWeight.weight.toStringAsFixed(1)} lbs [${_formatTimeAgo(latestWeight.date)}]'
                          : 'No weight entries',
                      timeInfo: latestWeight != null
                          ? '${weightProv.getWeightEntries(currentPet.id!).length} entr${weightProv.getWeightEntries(currentPet.id!).length == 1 ? 'y' : 'ies'}'
                          : 'Start tracking',
                      buttonText: 'View History >',
                      buttonColor: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WeightTrackingScreen(pet: currentPet),
                          ),
                        );
                      },
                    ),
                  if (currentPet.id != null) const SizedBox(height: 12),
                  // Vaccination status
                  if (currentPet.id != null)
                    _StatusItem(
                      icon: Icons.medical_services,
                      iconColor: Colors.blue,
                      title: 'Vaccinations',
                      status: overdueVaccinations.isNotEmpty
                          ? '${overdueVaccinations.length} overdue'
                          : upcomingVaccinations.isNotEmpty
                              ? 'Next due: ${DateFormat('MMM dd').format(upcomingVaccinations.first.nextDueDate!)}'
                              : petVaccinations.isNotEmpty
                                  ? '${petVaccinations.length} record${petVaccinations.length == 1 ? '' : 's'}'
                                  : 'No vaccinations',
                      timeInfo: petVaccinations.isNotEmpty
                          ? '${petVaccinations.length} total'
                          : 'Start tracking',
                      buttonText: 'View All >',
                      buttonColor: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VaccinationScreen(pet: currentPet),
                          ),
                        );
                      },
                    ),
                  if (currentPet.id != null) const SizedBox(height: 12),
                  // Activity status
                  if (currentPet.id != null)
                    _StatusItem(
                      icon: Icons.directions_walk,
                      iconColor: Colors.green,
                      title: 'Activity',
                      status: todayDuration > 0
                          ? '$todayDuration min today'
                          : weekDuration > 0
                              ? '$weekDuration min this week'
                              : 'No activities',
                      timeInfo: petActivities.isNotEmpty
                          ? '${petActivities.length} total'
                          : 'Start tracking',
                      buttonText: 'View All >',
                      buttonColor: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ActivityTrackingScreen(pet: currentPet),
                          ),
                        );
                      },
                    ),
                  if (currentPet.id != null) const SizedBox(height: 12),
                  // Expense status
                  if (currentPet.id != null)
                    _StatusItem(
                      icon: Icons.receipt_long,
                      iconColor: Colors.purple,
                      title: 'Expenses',
                      status: monthTotal > 0
                          ? '\$${monthTotal.toStringAsFixed(2)} this month'
                          : petExpenses.isNotEmpty
                              ? '\$${expenseProv.getTotalAmount(List<ExpenseModel>.from(petExpenses)).toStringAsFixed(2)} total'
                              : 'No expenses',
                      timeInfo: petExpenses.isNotEmpty
                          ? '${petExpenses.length} record${petExpenses.length == 1 ? '' : 's'}'
                          : 'Start tracking',
                      buttonText: 'View All >',
                      buttonColor: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpenseTrackingScreen(pet: currentPet),
                          ),
                        );
                      },
                    ),
                  if (currentPet.id != null) const SizedBox(height: 12),
                  // Milestones & Birthday section
                  if (currentPet.birthDate != null || currentPet.adoptionDate != null || petMilestones.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? theme.colorScheme.outline : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.cake, size: 20, color: theme.colorScheme.onSurface),
                              const SizedBox(width: 8),
                              Text(
                                'Milestones & Special Dates',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Birthday info
                          if (currentPet.birthDate != null) ...[
                            Row(
                              children: [
                                Icon(Icons.cake, color: Colors.pink, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Birthday',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        '${DateFormat('MMM dd, yyyy').format(currentPet.birthDate!)} • ${daysUntilBirthday == 0 ? 'Today!' : daysUntilBirthday == 1 ? 'Tomorrow' : '$daysUntilBirthday days until next birthday'}',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (currentPet.adoptionDate != null || petMilestones.isNotEmpty)
                              const SizedBox(height: 12),
                          ],
                          // Adoption date
                          if (currentPet.adoptionDate != null) ...[
                            Row(
                              children: [
                                Icon(Icons.home, color: Colors.blue, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Adoption Date',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('MMM dd, yyyy').format(currentPet.adoptionDate!),
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (petMilestones.isNotEmpty) const SizedBox(height: 12),
                          ],
                          // Custom milestones
                          if (petMilestones.isNotEmpty) ...[
                            ...petMilestones.take(3).map((milestone) => InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddMilestoneScreen(
                                      pet: currentPet,
                                      milestone: milestone,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      milestone.type == 'birthday' ? Icons.cake : milestone.type == 'adoption' ? Icons.home : Icons.star,
                                      color: milestone.type == 'birthday' ? Colors.pink : milestone.type == 'adoption' ? Colors.blue : Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            milestone.title,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('MMM dd, yyyy').format(milestone.date),
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12,
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                            if (petMilestones.length > 3)
                              TextButton(
                                onPressed: () {
                                  // Show all milestones in a dialog or navigate to a full screen
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('All Milestones'),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: petMilestones.length,
                                          itemBuilder: (context, index) {
                                            final milestone = petMilestones[index];
                                            return ListTile(
                                              leading: Icon(
                                                milestone.type == 'birthday' ? Icons.cake : milestone.type == 'adoption' ? Icons.home : Icons.star,
                                                color: milestone.type == 'birthday' ? Colors.pink : milestone.type == 'adoption' ? Colors.blue : Colors.orange,
                                              ),
                                              title: Text(milestone.title),
                                              subtitle: Text(DateFormat('MMM dd, yyyy').format(milestone.date)),
                                              onTap: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => AddMilestoneScreen(
                                                      pet: currentPet,
                                                      milestone: milestone,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Text(
                                  'View all ${petMilestones.length} milestones',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                          // Add Milestone Button
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddMilestoneScreen(pet: currentPet),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text(
                              'Add Milestone',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (currentPet.birthDate != null || currentPet.adoptionDate != null || petMilestones.isNotEmpty)
                    const SizedBox(height: 12),
                  // Task status - only show if there are reminders
                  if (reminders.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? theme.colorScheme.outline : Colors.grey[200]!,
                          width: 1,
                        ),
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
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lastReminder != null && lastReminder.time.isBefore(DateTime.now())
                                      ? 'Last ${lastReminder.title} [${_formatTimeAgo(lastReminder.time)}]'
                                      : lastReminder != null && !lastReminder.isCompleted
                                          ? 'Next ${lastReminder.title} [${_formatTimeInFuture(lastReminder.time)}]'
                                          : 'No recent tasks',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
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
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? theme.colorScheme.outline : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'No status information available yet.\nAdd health records or reminders to see status updates.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: theme.colorScheme.onSurfaceVariant,
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
                            icon: Icon(
                              Icons.add,
                              color: isDark ? theme.colorScheme.onPrimary : Colors.white,
                            ),
                            label: Text(
                              'Add Reminder',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? theme.colorScheme.onPrimary : Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? theme.colorScheme.primary : const Color(0xFFFB930B),
                              foregroundColor: isDark ? theme.colorScheme.onPrimary : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isDark ? theme.colorScheme.outline : Colors.black,
                                  width: 1.5,
                                ),
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
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? theme.colorScheme.outline : Colors.grey[200]!,
                          width: 1,
                        ),
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
                        icon: Icon(
                          Icons.add,
                          color: isDark ? theme.colorScheme.onPrimary : Colors.white,
                        ),
                        label: Text(
                          'Add Reminder',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? theme.colorScheme.onPrimary : Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? theme.colorScheme.primary : const Color(0xFFFB930B),
                          foregroundColor: isDark ? theme.colorScheme.onPrimary : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDark ? theme.colorScheme.outline : Colors.black,
                              width: 1.5,
                            ),
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
  final IconData icon;
  final Color iconColor;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon in white circular background
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surface : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          // Value text (like "3.5 kg" in the design)
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? theme.colorScheme.outline : Colors.grey[200]!,
          width: 1,
        ),
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
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeInfo,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: isDark ? theme.colorScheme.primary : const Color(0xFFFB930B),
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
      // Menu opened
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
          child: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return _MenuButtonItem(
                icon: Icons.edit_outlined,
                iconColor: theme.brightness == Brightness.dark 
                    ? theme.colorScheme.primary 
                    : const Color(0xFFFB930B),
                title: 'Edit Pet',
                titleColor: theme.colorScheme.onSurface,
                onTap: () {
                  Navigator.pop(context);
                  widget.onEdit();
                },
              );
            },
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return _MenuButtonItem(
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                title: 'Delete Pet',
                titleColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete();
                },
              );
            },
          ),
        ),
      ],
    ).then((_) {
      if (mounted) {
        setState(() {
          // Menu closed
        });
        _transformController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _scaleController.forward();
      },
      onTapUp: (_) {
        _scaleController.reverse();
        _showMenu(context);
      },
      onTapCancel: () {
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
              child: Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;
                  final iconColor = isDark ? theme.colorScheme.onSurface : Colors.white;
                  return CustomPaint(
                    painter: _DotsToChevronPainter(
                      progress: _transformAnimation.value,
                      color: iconColor,
                    ),
                    child: const SizedBox.expand(),
                  );
                },
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
  final Color color;

  _DotsToChevronPainter({
    required this.progress,
    this.color = Colors.white,
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
        ..color = color.withOpacity(opacity)
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
        ..color = color.withOpacity(chevronProgress)
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
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? theme.colorScheme.outline : Colors.grey[200]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
