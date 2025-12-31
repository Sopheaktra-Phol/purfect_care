import 'package:flutter/material.dart';
import 'package:purfect_care/models/expense_model.dart';
import 'package:purfect_care/services/firestore_database_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final Map<int, List<ExpenseModel>> _expenses = {}; // petId -> list of expenses
  final Set<int> _loadingPetIds = {}; // Track which pet IDs are currently loading
  bool _isLoading = false;
  String? _errorMessage;
  int _nextId = 1; // Simple ID counter for in-memory storage

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  bool isLoadingForPet(int petId) => _loadingPetIds.contains(petId);

  List<ExpenseModel> getExpenses(int petId) {
    return _expenses[petId] ?? [];
  }

  bool hasLoadedExpenses(int petId) {
    return _expenses.containsKey(petId);
  }

  // Get expenses for a specific date range
  List<ExpenseModel> getExpensesForDateRange(int petId, DateTime startDate, DateTime endDate) {
    final expenses = _expenses[petId] ?? [];
    return expenses.where((e) => 
      e.date.isAfter(startDate.subtract(const Duration(days: 1))) && 
      e.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }

  // Get this month's expenses
  List<ExpenseModel> getMonthExpenses(int petId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getExpensesForDateRange(petId, startOfMonth, endOfMonth);
  }

  // Get this year's expenses
  List<ExpenseModel> getYearExpenses(int petId) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
    return getExpensesForDateRange(petId, startOfYear, endOfYear);
  }

  // Calculate total amount for expenses
  double getTotalAmount(List<ExpenseModel> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get expense breakdown by category
  Map<String, double> getCategoryBreakdown(List<ExpenseModel> expenses) {
    final breakdown = <String, double>{};
    for (var expense in expenses) {
      breakdown[expense.category] = (breakdown[expense.category] ?? 0.0) + expense.amount;
    }
    return breakdown;
  }

  // Get average monthly spending
  double getAverageMonthlySpending(int petId) {
    final yearExpenses = getYearExpenses(petId);
    if (yearExpenses.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final monthsPassed = now.month;
    if (monthsPassed == 0) return 0.0;
    
    final total = getTotalAmount(yearExpenses);
    return total / monthsPassed;
  }

  Future<void> loadExpenses(int petId) async {
    // Prevent multiple simultaneous loads for the same pet
    if (_loadingPetIds.contains(petId)) {
      print('⚠️ Already loading expenses for pet $petId, skipping...');
      return;
    }
    
    // Don't reload if we've already loaded expenses for this pet (even if empty)
    if (_expenses.containsKey(petId)) {
      print('⚠️ Expenses already loaded for pet $petId (${_expenses[petId]!.length} items), skipping...');
      return;
    }
    
    _loadingPetIds.add(petId);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📥 Loading expenses for pet $petId...');
      final expenses = await FirestoreDatabaseService.getExpensesForPet(petId.toString());
      _expenses[petId] = expenses;
      _errorMessage = null;
      print('✅ Loaded ${expenses.length} expenses for pet $petId');
    } catch (e) {
      _errorMessage = 'Failed to load expenses.';
      print('❌ Error loading expenses: $e');
      _expenses[petId] = [];
    } finally {
      _loadingPetIds.remove(petId);
      _isLoading = _loadingPetIds.isNotEmpty;
      notifyListeners();
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await FirestoreDatabaseService.addExpense(expense);
      expense.id = int.tryParse(id) ?? 0;
      _expenses[expense.petId] ??= [];
      _expenses[expense.petId]!.add(expense);
      // Sort by date descending
      _expenses[expense.petId]!.sort((a, b) => b.date.compareTo(a.date));
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to add expense.';
      print('Error adding expense: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExpense(int petId, int id, ExpenseModel expense) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirestoreDatabaseService.updateExpense(id.toString(), expense);
      final expenses = _expenses[petId] ?? [];
      final idx = expenses.indexWhere((e) => e.id == id);
      if (idx >= 0) {
        expenses[idx] = expense;
        // Sort by date descending
        expenses.sort((a, b) => b.date.compareTo(a.date));
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to update expense.';
      print('Error updating expense: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(int petId, int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirestoreDatabaseService.deleteExpense(id.toString());
      _expenses[petId]?.removeWhere((e) => e.id == id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to delete expense.';
      print('Error deleting expense: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all expenses for a pet (used when pet is deleted)
  void deleteAllExpensesForPet(int petId) {
    _expenses.remove(petId);
    notifyListeners();
  }
}

