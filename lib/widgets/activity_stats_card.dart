import 'package:flutter/material.dart';
import 'package:purfect_care/models/activity_model.dart';
import 'package:purfect_care/providers/activity_provider.dart';
import 'package:purfect_care/theme/app_theme.dart';

class ActivityStatsCard extends StatelessWidget {
  final List<ActivityModel> todayActivities;
  final List<ActivityModel> weekActivities;
  final ActivityProvider activityProvider;

  const ActivityStatsCard({
    super.key,
    required this.todayActivities,
    required this.weekActivities,
    required this.activityProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final todayDuration = activityProvider.getTotalDuration(todayActivities);
    final weekDuration = activityProvider.getTotalDuration(weekActivities);
    final weekDistance = activityProvider.getTotalDistance(
      weekActivities.where((a) => a.type == 'walk').toList()
    );
    final weekBreakdown = activityProvider.getActivityBreakdown(weekActivities);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? theme.colorScheme.outline : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Statistics',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Today's Stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Today',
                  '$todayDuration min',
                  Icons.today,
                  Colors.blue,
                  theme,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'This Week',
                  '$weekDuration min',
                  Icons.calendar_view_week,
                  Colors.green,
                  theme,
                  isDark,
                ),
              ),
            ],
          ),
          if (weekDistance > 0) ...[
            const SizedBox(height: 12),
            _buildStatItem(
              'Total Distance',
              '${weekDistance.toStringAsFixed(1)} mi',
              Icons.straighten,
              Colors.orange,
              theme,
              isDark,
              fullWidth: true,
            ),
          ],
          if (weekBreakdown.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Activity Breakdown',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...weekBreakdown.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value} min',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
    bool isDark, {
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

