import 'package:flutter/material.dart';
import 'package:purfect_care/models/expense_model.dart';
import 'package:purfect_care/providers/expense_provider.dart';
import 'package:purfect_care/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseStatsCard extends StatelessWidget {
  final List<ExpenseModel> monthExpenses;
  final List<ExpenseModel> yearExpenses;
  final ExpenseProvider expenseProvider;

  const ExpenseStatsCard({
    super.key,
    required this.monthExpenses,
    required this.yearExpenses,
    required this.expenseProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final monthTotal = expenseProvider.getTotalAmount(monthExpenses);
    final yearTotal = expenseProvider.getTotalAmount(yearExpenses);
    final averageMonthly = expenseProvider.getAverageMonthlySpending(monthExpenses.isNotEmpty ? monthExpenses.first.petId : 0);
    final categoryBreakdown = expenseProvider.getCategoryBreakdown(yearExpenses);

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
            'Expense Statistics',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Summary Stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'This Month',
                  '\$${monthTotal.toStringAsFixed(2)}',
                  Icons.calendar_month,
                  Colors.blue,
                  theme,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'This Year',
                  '\$${yearTotal.toStringAsFixed(2)}',
                  Icons.calendar_today,
                  Colors.green,
                  theme,
                  isDark,
                ),
              ),
            ],
          ),
          if (averageMonthly > 0) ...[
            const SizedBox(height: 12),
            _buildStatItem(
              'Avg Monthly',
              '\$${averageMonthly.toStringAsFixed(2)}',
              Icons.trending_up,
              Colors.orange,
              theme,
              isDark,
              fullWidth: true,
            ),
          ],
          // Category Breakdown Chart
          if (categoryBreakdown.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Category Breakdown (This Year)',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categoryBreakdown.entries.map((entry) {
                    final colors = _getColorForCategory(entry.key);
                    return PieChartSectionData(
                      value: entry.value,
                      title: '\$${entry.value.toStringAsFixed(0)}',
                      color: colors,
                      radius: 60,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: categoryBreakdown.entries.map((entry) {
                final colors = _getColorForCategory(entry.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.key.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
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

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'vet':
        return Colors.red;
      case 'food':
        return Colors.orange;
      case 'grooming':
        return Colors.purple;
      case 'toys':
        return Colors.blue;
      case 'medication':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

