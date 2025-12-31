import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/activity_model.dart';
import 'package:purfect_care/providers/activity_provider.dart';
import 'package:purfect_care/theme/app_theme.dart';
import 'add_activity_screen.dart';
import '../widgets/activity_stats_card.dart';

class ActivityTrackingScreen extends StatefulWidget {
  final PetModel pet;

  const ActivityTrackingScreen({super.key, required this.pet});

  @override
  State<ActivityTrackingScreen> createState() => _ActivityTrackingScreenState();
}

class _ActivityTrackingScreenState extends State<ActivityTrackingScreen> {
  bool _hasLoaded = false; // Guard to prevent multiple loads

  @override
  void initState() {
    super.initState();
    // Load activities when screen opens - only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded && mounted && widget.pet.id != null) {
        _hasLoaded = true;
        final activityProvider = context.read<ActivityProvider>();
        // The provider will check if already loaded or loading
        activityProvider.loadActivities(widget.pet.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activities = activityProvider.getActivities(widget.pet.id!);
    final todayActivities = activityProvider.getTodayActivities(widget.pet.id!);
    final weekActivities = activityProvider.getWeekActivities(widget.pet.id!);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? theme.colorScheme.surface : AppTheme.accentOrange,
        elevation: 0,
        title: const Text(
          'Activity Tracking',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: activityProvider.isLoading && activities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : activities.isEmpty
              ? _buildEmptyState(context, theme, isDark)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Statistics Cards
                    ActivityStatsCard(
                      todayActivities: todayActivities,
                      weekActivities: weekActivities,
                      activityProvider: activityProvider,
                    ),
                    const SizedBox(height: 24),
                    // Activity List Header
                    Text(
                      'Activity History',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Activity List
                    ...activities.map((activity) => _buildActivityCard(activity, theme, isDark)),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddActivityScreen(pet: widget.pet),
            ),
          );
        },
        backgroundColor: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
        foregroundColor: isDark ? theme.colorScheme.onPrimary : Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_walk_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No activities recorded yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking ${widget.pet.name}\'s activities',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddActivityScreen(pet: widget.pet),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
                foregroundColor: isDark ? theme.colorScheme.onPrimary : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Activity',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel activity, ThemeData theme, bool isDark) {
    IconData icon;
    Color color;
    
    switch (activity.type) {
      case 'walk':
        icon = Icons.directions_walk;
        color = Colors.blue;
        break;
      case 'play':
        icon = Icons.sports_tennis;
        color = Colors.orange;
        break;
      case 'exercise':
        icon = Icons.fitness_center;
        color = Colors.green;
        break;
      case 'training':
        icon = Icons.school;
        color = Colors.purple;
        break;
      default:
        icon = Icons.emoji_events;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? theme.colorScheme.outline : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddActivityScreen(
                pet: widget.pet,
                activity: activity,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.type.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${activity.duration} min',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (activity.distance != null) ...[
                          const SizedBox(width: 16),
                          Icon(Icons.straighten, size: 14, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.distance!.toStringAsFixed(1)} mi',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(activity.date),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        activity.notes!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

