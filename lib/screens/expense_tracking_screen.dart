import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/expense_model.dart';
import 'package:purfect_care/providers/expense_provider.dart';
import 'package:purfect_care/theme/app_theme.dart';
import 'add_expense_screen.dart';
import '../widgets/expense_stats_card.dart';

class ExpenseTrackingScreen extends StatefulWidget {
  final PetModel pet;

  const ExpenseTrackingScreen({super.key, required this.pet});

  @override
  State<ExpenseTrackingScreen> createState() => _ExpenseTrackingScreenState();
}

class _ExpenseTrackingScreenState extends State<ExpenseTrackingScreen> {
  String _selectedFilter = 'all'; // 'all', 'month', 'year'
  bool _hasLoaded = false; // Guard to prevent multiple loads

  @override
  void initState() {
    super.initState();
    // Load expenses when screen opens - only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded && mounted && widget.pet.id != null) {
        _hasLoaded = true;
        final expenseProvider = context.read<ExpenseProvider>();
        // The provider will check if already loaded or loading
        expenseProvider.loadExpenses(widget.pet.id!);
      }
    });
  }

  List<ExpenseModel> _getFilteredExpenses(List<ExpenseModel> allExpenses) {
    final expenseProvider = context.read<ExpenseProvider>();
    switch (_selectedFilter) {
      case 'month':
        return expenseProvider.getMonthExpenses(widget.pet.id!);
      case 'year':
        return expenseProvider.getYearExpenses(widget.pet.id!);
      default:
        return allExpenses;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allExpenses = expenseProvider.getExpenses(widget.pet.id!);
    final filteredExpenses = _getFilteredExpenses(allExpenses);
    final monthExpenses = expenseProvider.getMonthExpenses(widget.pet.id!);
    final yearExpenses = expenseProvider.getYearExpenses(widget.pet.id!);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? theme.colorScheme.surface : AppTheme.accentOrange,
        elevation: 0,
        title: const Text(
          'Expenses',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 'all', theme, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('This Month', 'month', theme, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('This Year', 'year', theme, isDark),
              ],
            ),
          ),
        ),
      ),
      body: expenseProvider.isLoading && allExpenses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : allExpenses.isEmpty
              ? _buildEmptyState(context, theme, isDark)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Statistics Card
                    ExpenseStatsCard(
                      monthExpenses: monthExpenses,
                      yearExpenses: yearExpenses,
                      expenseProvider: expenseProvider,
                    ),
                    const SizedBox(height: 24),
                    // Expense List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Expense History',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Total: \$${expenseProvider.getTotalAmount(filteredExpenses).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Expense List
                    ...filteredExpenses.map((expense) => _buildExpenseCard(expense, theme, isDark)),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(pet: widget.pet),
            ),
          );
        },
        backgroundColor: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
        foregroundColor: isDark ? theme.colorScheme.onPrimary : Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, ThemeData theme, bool isDark) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      selectedColor: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
              Icons.receipt_long_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses recorded yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking ${widget.pet.name}\'s expenses',
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
                    builder: (_) => AddExpenseScreen(pet: widget.pet),
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
                'Add Expense',
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

  Widget _buildExpenseCard(ExpenseModel expense, ThemeData theme, bool isDark) {
    IconData icon;
    Color color;
    
    switch (expense.category) {
      case 'vet':
        icon = Icons.local_hospital;
        color = Colors.red;
        break;
      case 'food':
        icon = Icons.restaurant;
        color = Colors.orange;
        break;
      case 'grooming':
        icon = Icons.content_cut;
        color = Colors.purple;
        break;
      case 'toys':
        icon = Icons.toys;
        color = Colors.blue;
        break;
      case 'medication':
        icon = Icons.medication;
        color = Colors.green;
        break;
      default:
        icon = Icons.category;
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
              builder: (_) => AddExpenseScreen(
                pet: widget.pet,
                expense: expense,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            expense.description,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            expense.category.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM dd, yyyy').format(expense.date),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
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

