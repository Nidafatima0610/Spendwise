import 'package:flutter/material.dart';
import '../../models/budget_model.dart';
import '../../models/category_model.dart';
import '../database/database_service.dart';
import '../utils/date_formatter.dart';
import 'transaction_controller.dart';

/// Central state manager for SpendWise monthly budgets.
/// 
/// Uses standard Flutter [ChangeNotifier] to provide reactive updates
/// across the Budgets screen and Home Dashboard without third-party packages.
class BudgetController extends ChangeNotifier {
  static BudgetController instance = BudgetController();

  final DatabaseService _dbService;

  BudgetController({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  List<BudgetModel> _budgets = [];
  String _selectedMonthYear = DateFormatter.toMonthYearKey(DateTime.now());
  bool _isLoading = false;

  int _totalBudgetCapMinor = 0;
  int _totalBudgetSpentMinor = 0;
  int _overBudgetCount = 0;

  // Getters
  List<BudgetModel> get budgets => List.unmodifiable(_budgets);
  String get selectedMonthYear => _selectedMonthYear;
  bool get isLoading => _isLoading;
  int get totalBudgetCapMinor => _totalBudgetCapMinor;
  int get totalBudgetSpentMinor => _totalBudgetSpentMinor;
  int get remainingBudgetMinor => _totalBudgetCapMinor - _totalBudgetSpentMinor;
  int get overBudgetCount => _overBudgetCount;
  bool get hasBudgets => _budgets.isNotEmpty;

  /// Loads all budgets for the currently selected month and recalculates aggregates.
  Future<void> loadBudgets({String? monthYear}) async {
    if (monthYear != null) {
      _selectedMonthYear = monthYear;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _loadBudgetsAndMetrics();
    } catch (e) {
      debugPrint('Error loading budgets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Changes the active month filter (e.g. '2026-11') and reloads.
  Future<void> setMonth(String monthYear) async {
    if (_selectedMonthYear == monthYear) return;
    _selectedMonthYear = monthYear;
    _isLoading = true;
    notifyListeners();

    try {
      await _loadBudgetsAndMetrics();
    } catch (e) {
      debugPrint('Error changing budget month: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes budgets for the active month (e.g., when transactions change).
  Future<void> refresh() async {
    await _loadBudgetsAndMetrics();
    notifyListeners();
  }

  /// Internal worker to query SQLite for budgets and calculate metrics.
  Future<void> _loadBudgetsAndMetrics() async {
    _budgets = await _dbService.getBudgetsByMonth(_selectedMonthYear);

    int totalCap = 0;
    int totalSpent = 0;
    int overCount = 0;

    for (final b in _budgets) {
      totalCap += b.limitAmount;
      totalSpent += b.spentAmount;
      if (b.isOverBudget) {
        overCount++;
      }
    }

    _totalBudgetCapMinor = totalCap;
    _totalBudgetSpentMinor = totalSpent;
    _overBudgetCount = overCount;
  }

  /// Adds a new category budget to SQLite.
  /// Prevents duplicate entries for the same category and month.
  Future<bool> addBudget(BudgetModel budget) async {
    try {
      final rows = await _dbService.insertBudget(budget);
      if (rows > 0) {
        await _loadBudgetsAndMetrics();
        notifyListeners();
        // Cross-refresh transaction controller to update dashboard budget summary
        TransactionController.instance.refresh();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error inserting budget: $e');
      return false;
    }
  }

  /// Updates an existing category budget limit.
  Future<bool> updateBudget(BudgetModel budget) async {
    try {
      final rows = await _dbService.updateBudget(budget);
      if (rows > 0) {
        await _loadBudgetsAndMetrics();
        notifyListeners();
        // Cross-refresh transaction controller to update dashboard budget summary
        TransactionController.instance.refresh();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating budget: $e');
      return false;
    }
  }

  /// Deletes a budget by its unique ID.
  Future<bool> deleteBudget(String id) async {
    try {
      final rows = await _dbService.deleteBudget(id);
      if (rows > 0) {
        await _loadBudgetsAndMetrics();
        notifyListeners();
        // Cross-refresh transaction controller to update dashboard budget summary
        TransactionController.instance.refresh();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting budget: $e');
      return false;
    }
  }

  /// Checks if a budget has already been established for a category in the selected month.
  bool isCategoryBudgeted(String categoryId, {String? monthYear}) {
    final targetMonth = monthYear ?? _selectedMonthYear;
    return _budgets.any(
      (b) => b.categoryId == categoryId && b.monthYear == targetMonth,
    );
  }

  /// Retrieves an existing budget for a category, if present.
  BudgetModel? getBudgetForCategory(String categoryId) {
    try {
      return _budgets.firstWhere((b) => b.categoryId == categoryId);
    } catch (_) {
      return null;
    }
  }

  /// Filters expense categories that do not yet have a budget for this month.
  List<CategoryModel> getAvailableExpenseCategories(List<CategoryModel> allCategories) {
    final budgetedCategoryIds = _budgets.map((b) => b.categoryId).toSet();
    return allCategories
        .where((c) => c.isExpense && !budgetedCategoryIds.contains(c.id))
        .toList();
  }
}

