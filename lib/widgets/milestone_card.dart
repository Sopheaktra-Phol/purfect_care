import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purfect_care/models/milestone_model.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/theme/app_theme.dart';

class MilestoneCard extends StatelessWidget {
  final MilestoneModel milestone;
  final PetModel? pet;
  final VoidCallback? onTap;

  const MilestoneCard({
    super.key,
    required this.milestone,
    this.pet,
    this.onTap,
  });

  String _getDaysUntil(DateTime date) {
    final now = DateTime.now();
    final thisYear = DateTime(now.year, date.month, date.day);
    final nextYear = DateTime(now.year + 1, date.month, date.day);
    
    DateTime targetDate;
    if (thisYear.isBefore(now) || thisYear.isAtSameMomentAs(now)) {
      targetDate = nextYear;
    } else {
      targetDate = thisYear;
    }
    
    final difference = targetDate.difference(now);
    if (difference.inDays == 0) {
      return 'Today!';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 7) {
      return 'in ${difference.inDays} days';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'in $weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'in $months ${months == 1 ? 'month' : 'months'}';
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'birthday':
        return Icons.cake;
      case 'adoption':
        return Icons.home;
      default:
        return Icons.star;
    }
  }

  Color _getColorForType(String type, bool isDark) {
    switch (type) {
      case 'birthday':
        return isDark ? Colors.pink : Colors.pink[300]!;
      case 'adoption':
        return isDark ? Colors.blue : Colors.blue[300]!;
      default:
        return isDark ? Colors.orange : Colors.orange[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final daysUntil = _getDaysUntil(milestone.date);
    final isToday = daysUntil == 'Today!';
    final isTomorrow = daysUntil == 'Tomorrow';

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
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getColorForType(milestone.type, isDark).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForType(milestone.type),
                  color: _getColorForType(milestone.type, isDark),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (pet != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        pet!.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd').format(milestone.date),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isToday || isTomorrow
                          ? (isDark ? theme.colorScheme.primary : AppTheme.accentOrange)
                          : _getColorForType(milestone.type, isDark))
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  daysUntil,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isToday || isTomorrow
                        ? (isDark ? theme.colorScheme.primary : AppTheme.accentOrange)
                        : _getColorForType(milestone.type, isDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

