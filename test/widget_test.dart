import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spend_wise/app/app.dart';
import 'package:spend_wise/core/constants/app_strings.dart';
import 'package:spend_wise/core/controllers/budget_controller.dart';
import 'package:spend_wise/core/controllers/transaction_controller.dart';
import 'package:spend_wise/core/database/database_service.dart';
import 'package:spend_wise/core/utils/currency_formatter.dart';
import 'package:spend_wise/core/utils/date_formatter.dart';
import 'package:spend_wise/features/transactions/screens/add_transaction_screen.dart';
import 'package:spend_wise/models/budget_model.dart';
import 'package:spend_wise/models/category_model.dart';
import 'package:spend_wise/models/transaction_model.dart';

/// In-memory database repository used for Flutter Widget Tests to avoid
/// FFI background isolate deadlock within Flutter test's fakeAsync zone.
/// Complete real SQLite integration is comprehensively verified in test/database_test.dart.
class FakeDatabaseService extends DatabaseService {
  final List<CategoryModel> _fakeCategories = [
    const CategoryModel(
      id: 'cat_food',
      name: 'Food & Dining',
      type: TransactionType.expense,
      iconName: 'food',
      colorValue: 0xFFF59E0B,
      isDefault: true,
    ),
    const CategoryModel(
      id: 'cat_salary',
      name: 'Salary',
      type: TransactionType.income,
      iconName: 'salary',
      colorValue: 0xFF10B981,
      isDefault: true,
    ),
  ];

  final List<TransactionModel> _fakeTransactions = [];
  final List<BudgetModel> _fakeBudgets = [];

  @override
  Future<List<CategoryModel>> getAllCategories() async => List.from(_fakeCategories);

  @override
  Future<List<CategoryModel>> getCategoriesByType(TransactionType type) async =>
      _fakeCategories.where((c) => c.type == type).toList();

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      return _fakeCategories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    final list = List<TransactionModel>.from(_fakeTransactions);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<List<TransactionModel>> getTransactionsByType(TransactionType type) async {
    return _fakeTransactions.where((t) => t.type == type).toList();
  }

  @override
  Future<List<TransactionModel>> getTransactionsByCategory(String categoryId) async {
    return _fakeTransactions.where((t) => t.categoryId == categoryId).toList();
  }

  @override
  Future<List<TransactionModel>> getTransactionsByMonth(String monthYear) async {
    return _fakeTransactions
        .where((t) => DateFormatter.toMonthYearKey(t.date) == monthYear)
        .toList();
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      return _fakeTransactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> insertTransaction(TransactionModel transaction) async {
    _fakeTransactions.removeWhere((t) => t.id == transaction.id);
    _fakeTransactions.insert(0, transaction);
    return 1;
  }

  @override
  Future<int> updateTransaction(TransactionModel transaction) async {
    final idx = _fakeTransactions.indexWhere((t) => t.id == transaction.id);
    if (idx != -1) {
      _fakeTransactions[idx] = transaction;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteTransaction(String id) async {
    final count = _fakeTransactions.where((t) => t.id == id).length;
    _fakeTransactions.removeWhere((t) => t.id == id);
    return count;
  }

  @override
  Future<int> getTransactionCount() async => _fakeTransactions.length;

  @override
  Future<int> getMonthlyIncome(String monthYear) async {
    return _fakeTransactions
        .where((t) => t.isIncome && DateFormatter.toMonthYearKey(t.date) == monthYear)
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  @override
  Future<int> getMonthlyExpense(String monthYear) async {
    return _fakeTransactions
        .where((t) => t.isExpense && DateFormatter.toMonthYearKey(t.date) == monthYear)
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  @override
  Future<int> getTotalBalance() async {
    final income = _fakeTransactions
        .where((t) => t.isIncome)
        .fold<int>(0, (sum, t) => sum + t.amount);
    final expense = _fakeTransactions
        .where((t) => t.isExpense)
        .fold<int>(0, (sum, t) => sum + t.amount);
    return income - expense;
  }

  @override
  Future<List<Map<String, dynamic>>> getCategorySpending(String monthYear) async {
    final Map<String, int> spendMap = {};
    for (final tx in _fakeTransactions) {
      if (tx.isExpense && DateFormatter.toMonthYearKey(tx.date) == monthYear) {
        spendMap[tx.categoryId] = (spendMap[tx.categoryId] ?? 0) + tx.amount;
      }
    }
    final list = spendMap.entries
        .map((e) => {'category_id': e.key, 'total_spent': e.value})
        .toList();
    list.sort((a, b) => (b['total_spent'] as int).compareTo(a['total_spent'] as int));
    return list;
  }

  // Budget Overrides for Widget Tests
  @override
  Future<int> insertBudget(BudgetModel budget) async {
    final exists = _fakeBudgets.any(
      (b) => b.categoryId == budget.categoryId && b.monthYear == budget.monthYear,
    );
    if (exists) {
      throw ArgumentError('A budget for this category and month already exists.');
    }
    _fakeBudgets.add(budget);
    return 1;
  }

  @override
  Future<List<BudgetModel>> getBudgetsByMonth(String monthYear) async {
    final list = _fakeBudgets.where((b) => b.monthYear == monthYear).toList();
    return Future.wait(list.map((b) async {
      final spent = await getCategorySpentAmount(b.categoryId, monthYear);
      return b.copyWith(spentAmount: spent);
    }));
  }

  @override
  Future<BudgetModel?> getBudgetByCategoryAndMonth(String categoryId, String monthYear) async {
    try {
      final b = _fakeBudgets.firstWhere(
        (b) => b.categoryId == categoryId && b.monthYear == monthYear,
      );
      final spent = await getCategorySpentAmount(categoryId, monthYear);
      return b.copyWith(spentAmount: spent);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BudgetModel?> getBudgetById(String id) async {
    try {
      final b = _fakeBudgets.firstWhere((b) => b.id == id);
      final spent = await getCategorySpentAmount(b.categoryId, b.monthYear);
      return b.copyWith(spentAmount: spent);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> updateBudget(BudgetModel budget) async {
    final idx = _fakeBudgets.indexWhere((b) => b.id == budget.id);
    if (idx != -1) {
      _fakeBudgets[idx] = budget;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteBudget(String id) async {
    final count = _fakeBudgets.where((b) => b.id == id).length;
    _fakeBudgets.removeWhere((b) => b.id == id);
    return count;
  }

  @override
  Future<int> getCategorySpentAmount(String categoryId, String monthYear) async {
    return _fakeTransactions
        .where((t) =>
            t.isExpense &&
            t.categoryId == categoryId &&
            DateFormatter.toMonthYearKey(t.date) == monthYear)
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  @override
  Future<int> getTotalBudgetForMonth(String monthYear) async {
    return _fakeBudgets
        .where((b) => b.monthYear == monthYear)
        .fold<int>(0, (sum, b) => sum + b.limitAmount);
  }

  @override
  Future<int> getBudgetCount() async => _fakeBudgets.length;

  @override
  Future<int> clearAllBudgets() async {
    final count = _fakeBudgets.length;
    _fakeBudgets.clear();
    return count;
  }
}

void main() {
  late FakeDatabaseService fakeDb;
  late TransactionController testController;
  late BudgetController testBudgetController;

  setUp(() async {
    fakeDb = FakeDatabaseService();
    testController = TransactionController(dbService: fakeDb);
    testBudgetController = BudgetController(dbService: fakeDb);
    await testController.loadInitialData();
    await testBudgetController.loadBudgets();

    // Set test singletons
    TransactionController.instance = testController;
    BudgetController.instance = testBudgetController;
  });

  group('Day 2 Form Validation Tests', () {
    testWidgets('Rejects empty amount submission', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AddTransactionScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Record Transaction without entering amount
      await tester.ensureVisible(find.text(AppStrings.saveTransaction));
      await tester.tap(find.text(AppStrings.saveTransaction));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a transaction amount'), findsOneWidget);
    });

    testWidgets('Rejects zero and negative amount submission', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AddTransactionScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter 0
      await tester.enterText(find.byKey(const Key('amount_input_field')), '0');
      await tester.ensureVisible(find.text(AppStrings.saveTransaction));
      await tester.tap(find.text(AppStrings.saveTransaction));
      await tester.pumpAndSettle();
      expect(find.text('Amount must be greater than zero'), findsOneWidget);

      // Enter negative number
      await tester.enterText(find.byKey(const Key('amount_input_field')), '-50');
      await tester.ensureVisible(find.text(AppStrings.saveTransaction));
      await tester.tap(find.text(AppStrings.saveTransaction));
      await tester.pumpAndSettle();
      expect(find.text('Amount must be greater than zero'), findsOneWidget);
    });
  });

  group('Day 2 UI Workflow: Create, View, Edit, and Delete', () {
    testWidgets('App allows creating, viewing, editing, and deleting transactions',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const SpendWiseApp());
      await tester.pumpAndSettle();

      // 1. Initial State: Empty recent transactions shown on dashboard
      expect(find.text('No Transactions Recorded'), findsOneWidget);

      // 2. Navigate to Add Tab
      await tester.tap(find.byKey(const Key('nav_add')));
      await tester.pumpAndSettle();

      // 3. Enter amount "3500", note "Team dinner"
      await tester.enterText(find.byKey(const Key('amount_input_field')), '3500');
      await tester.enterText(find.byKey(const Key('note_input_field')), 'Team dinner');
      await tester.ensureVisible(find.text(AppStrings.saveTransaction));
      await tester.tap(find.text(AppStrings.saveTransaction));
      await tester.pumpAndSettle();

      // Verify success snackbar appears
      expect(find.text('Transaction saved to SQLite successfully.'), findsOneWidget);

      // 4. Navigate to History Tab
      await tester.tap(find.byKey(const Key('nav_history')));
      await tester.pumpAndSettle();

      // Verify transaction appears in history
      expect(find.text('Food & Dining'), findsWidgets);
      expect(find.text('Team dinner'), findsOneWidget);
      expect(find.text('- PKR 3,500.00'), findsOneWidget);

      // 5. Open Edit Mode via action menu
      final tx = TransactionController.instance.transactions.first;
      await tester.tap(find.byKey(Key('tx_menu_${tx.id}')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit Entry'));
      await tester.pumpAndSettle();

      // Verify in Edit Mode
      expect(find.text('Edit Transaction'), findsOneWidget);

      // Update amount to 4200 and note to "Team dinner with dessert"
      await tester.enterText(find.byKey(const Key('amount_input_field')), '4200');
      await tester.enterText(find.byKey(const Key('note_input_field')), 'Team dinner with dessert');
      await tester.ensureVisible(find.text('Update Transaction'));
      await tester.tap(find.text('Update Transaction'));
      await tester.pumpAndSettle();

      // Verify updated values in History
      expect(find.text('- PKR 4,200.00'), findsOneWidget);
      expect(find.text('Team dinner with dessert'), findsOneWidget);

      // 6. Delete Transaction with confirmation
      await tester.tap(find.byKey(Key('tx_menu_${tx.id}')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify delete confirmation dialog appears
      expect(find.text('Delete Record?'), findsOneWidget);
      expect(find.byKey(const Key('confirm_delete_button')), findsOneWidget);

      // Tap Delete
      await tester.tap(find.byKey(const Key('confirm_delete_button')));
      await tester.pumpAndSettle();

      // Verify transaction was deleted and empty state appears
      expect(find.text('Transaction deleted successfully.'), findsOneWidget);
      expect(find.text('No Transactions Yet'), findsOneWidget);
    });
  });

  group('Model & Minor Currency Unit Tests', () {
    test('Transaction Model minor currency units conversion', () {
      final tx = TransactionModel.fromMajorUnits(
        id: 'test_1',
        type: TransactionType.expense,
        majorAmount: 2500.50,
        date: DateTime(2026, 11, 2),
        categoryId: 'cat_food',
        note: 'Team lunch',
      );

      // 2500.50 PKR must be stored as 250050 paisas (minor units)
      expect(tx.amount, 250050);
      expect(tx.amountInMajorUnits, 2500.50);
      expect(tx.isExpense, isTrue);
      expect(tx.isIncome, isFalse);

      final map = tx.toMap();
      final fromMap = TransactionModel.fromMap(map);
      expect(fromMap.id, tx.id);
      expect(fromMap.amount, 250050);
      expect(fromMap.type, TransactionType.expense);
    });

    test('Category Model serialization and icon resolution', () {
      const cat = CategoryModel(
        id: 'cat_food',
        name: 'Food & Dining',
        type: TransactionType.expense,
        iconName: 'food',
        colorValue: 0xFFF59E0B,
      );

      expect(cat.iconData, Icons.restaurant_rounded);
      expect(cat.color, const Color(0xFFF59E0B));

      final map = cat.toMap();
      final deserialized = CategoryModel.fromMap(map);
      expect(deserialized.id, 'cat_food');
      expect(deserialized.name, 'Food & Dining');
      expect(deserialized.type, TransactionType.expense);
    });

    test('CurrencyFormatter parses input and formats PKR accurately', () {
      expect(CurrencyFormatter.parseToMinorUnits('1500'), 150000);
      expect(CurrencyFormatter.parseToMinorUnits('1,500.25'), 150025);
      expect(CurrencyFormatter.parseToMinorUnits(''), 0);

      final formatted = CurrencyFormatter.formatMinorUnits(150025);
      expect(formatted, contains('1,500.25'));
    });
  });
}
