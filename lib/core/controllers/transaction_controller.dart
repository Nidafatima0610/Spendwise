import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../data/sample_data.dart';
import '../database/database_service.dart';
import '../utils/date_formatter.dart';
import '../../features/dashboard/widgets/category_spend_bar.dart';
import 'budget_controller.dart';

/// Central state manager for SpendWise transactions and financial metrics.
/// 
/// Uses standard Flutter [ChangeNotifier] to provide reactive updates
/// across Dashboard, History, and Add screens without third-party dependencies.
class TransactionController extends ChangeNotifier {
  static TransactionController instance = TransactionController();

  final DatabaseService _dbService;

  TransactionController({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  Map<String, CategoryModel> _categoryMap = {};

  int _totalBalanceMinor = 0;
  int _monthlyIncomeMinor = 0;
  int _monthlyExpenseMinor = 0;
  int _monthlyBudgetCapMinor = 0;
  List<CategorySpendItem> _categorySpending = [];

  String _currentMonthYear = DateFormatter.toMonthYearKey(DateTime.now());
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  Map<String, CategoryModel> get categoryMap => _categoryMap;

  int get totalBalanceMinor => _totalBalanceMinor;
  int get monthlyIncomeMinor => _monthlyIncomeMinor;
  int get monthlyExpenseMinor => _monthlyExpenseMinor;
  int get monthlyBudgetCapMinor => _monthlyBudgetCapMinor;
  List<CategorySpendItem> get categorySpending => _categorySpending;

  String get currentMonthYear => _currentMonthYear;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get hasTransactions => _transactions.isNotEmpty;

  /// Recent transactions (up to 4 newest records).
  List<TransactionModel> get recentTransactions =>
      _transactions.take(4).toList();

  /// Loads categories and transactions from SQLite.
  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Load Categories from SQLite
      _categories = await _dbService.getAllCategories();
      if (_categories.isEmpty) {
        // Fallback to sample category definitions if SQLite not yet seeded
        _categories = SampleData.categories;
      }
      _categoryMap = {for (final cat in _categories) cat.id: cat};

      // 2. Load Transactions and compute metrics
      await _loadTransactionsAndMetrics();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error loading initial transaction data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes transactions and financial metrics from SQLite.
  Future<void> refresh() async {
    await _loadTransactionsAndMetrics();
    notifyListeners();
  }

  /// Internal worker to reload transactions and compute aggregates.
  Future<void> _loadTransactionsAndMetrics() async {
    // 1. Fetch all transactions (ordered newest first)
    _transactions = await _dbService.getAllTransactions();

    // 2. Fetch monthly totals
    _monthlyIncomeMinor = await _dbService.getMonthlyIncome(_currentMonthYear);
    _monthlyExpenseMinor = await _dbService.getMonthlyExpense(_currentMonthYear);
    _totalBalanceMinor = await _dbService.getTotalBalance();
    _monthlyBudgetCapMinor = await _dbService.getTotalBudgetForMonth(_currentMonthYear);

    // 3. Compute Category Spending breakdown for active month
    final rawSpending = await _dbService.getCategorySpending(_currentMonthYear);
    final List<CategorySpendItem> items = [];

    for (final row in rawSpending) {
      final categoryId = row['category_id'] as String;
      final spentAmount = (row['total_spent'] as int?) ?? 0;
      final category = _categoryMap[categoryId] ??
          SampleData.categoryMap[categoryId] ??
          SampleData.catOther;

      final double percentage = _monthlyExpenseMinor > 0
          ? (spentAmount / _monthlyExpenseMinor) * 100.0
          : 0.0;

      items.add(
        CategorySpendItem(
          category: category,
          spentAmountMinor: spentAmount,
          percentageOfTotal: percentage,
        ),
      );
    }

    _categorySpending = items;
  }

  /// Adds a new transaction to SQLite and refreshes state.
  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      final rows = await _dbService.insertTransaction(transaction);
      if (rows > 0) {
        await _loadTransactionsAndMetrics();
        notifyListeners();
        BudgetController.instance.refresh();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error inserting transaction: $e');
      return false;
    }
  }

  /// Updates an existing transaction in SQLite and refreshes state.
  Future<bool> updateTransaction(TransactionModel transaction) async {
    try {
      final rows = await _dbService.updateTransaction(transaction);
      if (rows > 0) {
        await _loadTransactionsAndMetrics();
        notifyListeners();
        BudgetController.instance.refresh();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      return false;
    }
  }

  /// Deletes a transaction from SQLite by ID and refreshes state.
  Future<bool> deleteTransaction(String id) async {
    try {
      final rows = await _dbService.deleteTransaction(id);
      if (rows > 0) {
        await _loadTransactionsAndMetrics();
        notifyListeners();
        BudgetController.instance.refresh();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }

  /// Resolves category for a given ID.
  CategoryModel getCategory(String categoryId) {
    return _categoryMap[categoryId] ??
        SampleData.categoryMap[categoryId] ??
        SampleData.catOther;
  }

  /// Returns categories filtered by income or expense.
  List<CategoryModel> getCategoriesForType(TransactionType type) {
    return _categories.where((cat) => cat.type == type).toList();
  }

  /// Changes the active month key (e.g. '2026-11') and recalculates.
  Future<void> setMonth(String monthYear) async {
    if (_currentMonthYear == monthYear) return;
    _currentMonthYear = monthYear;
    await _loadTransactionsAndMetrics();
    notifyListeners();
    BudgetController.instance.setMonth(monthYear);
  }
}
