// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spend_wise/app/app.dart';
import 'package:spend_wise/core/controllers/budget_controller.dart';
import 'package:spend_wise/core/controllers/transaction_controller.dart';
import 'package:spend_wise/core/database/database_service.dart';
import 'package:spend_wise/core/utils/date_formatter.dart';
import 'package:spend_wise/models/budget_model.dart';
import 'package:spend_wise/models/category_model.dart';
import 'package:spend_wise/models/transaction_model.dart';

Future<void> loadRealFonts() async {
  final robotoLoader = FontLoader('Roboto');
  robotoLoader.addFont(
    File('C:/SRC/flutter/bin/cache/artifacts/material_fonts/roboto-regular.ttf')
        .readAsBytes()
        .then((b) => ByteData.view(b.buffer)),
  );
  robotoLoader.addFont(
    File('C:/SRC/flutter/bin/cache/artifacts/material_fonts/roboto-medium.ttf')
        .readAsBytes()
        .then((b) => ByteData.view(b.buffer)),
  );
  robotoLoader.addFont(
    File('C:/SRC/flutter/bin/cache/artifacts/material_fonts/roboto-bold.ttf')
        .readAsBytes()
        .then((b) => ByteData.view(b.buffer)),
  );
  await robotoLoader.load();

  final iconsLoader = FontLoader('MaterialIcons');
  iconsLoader.addFont(
    File('C:/SRC/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf')
        .readAsBytes()
        .then((b) => ByteData.view(b.buffer)),
  );
  await iconsLoader.load();
}

class FinalEvidenceDbService extends DatabaseService {
  final List<CategoryModel> _cats = [
    const CategoryModel(
      id: 'cat_food',
      name: 'Food & Dining',
      type: TransactionType.expense,
      iconName: 'food',
      colorValue: 0xFFF59E0B,
      isDefault: true,
    ),
    const CategoryModel(
      id: 'cat_transport',
      name: 'Transportation',
      type: TransactionType.expense,
      iconName: 'transport',
      colorValue: 0xFF3B82F6,
      isDefault: true,
    ),
    const CategoryModel(
      id: 'cat_bills',
      name: 'Bills & Utilities',
      type: TransactionType.expense,
      iconName: 'receipt',
      colorValue: 0xFF8B5CF6,
      isDefault: true,
    ),
    const CategoryModel(
      id: 'cat_shopping',
      name: 'Shopping & Gear',
      type: TransactionType.expense,
      iconName: 'shopping',
      colorValue: 0xFFEC4899,
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
    const CategoryModel(
      id: 'cat_freelance',
      name: 'Freelance & Projects',
      type: TransactionType.income,
      iconName: 'laptop',
      colorValue: 0xFF06B6D4,
      isDefault: true,
    ),
  ];

  final List<TransactionModel> _txs = [
    // Income
    TransactionModel(
      id: 'tx_inc_1',
      type: TransactionType.income,
      amount: 18500000, // PKR 185,000.00
      date: DateTime(2026, 11, 1, 9, 30),
      categoryId: 'cat_salary',
      note: 'Monthly Senior Dev Salary',
    ),
    TransactionModel(
      id: 'tx_inc_2',
      type: TransactionType.income,
      amount: 6500000, // PKR 65,000.00
      date: DateTime(2026, 11, 2, 16, 45),
      categoryId: 'cat_freelance',
      note: 'Mobile App Milestone Payment',
    ),
    // Expenses
    TransactionModel(
      id: 'tx_exp_1',
      type: TransactionType.expense,
      amount: 1200000, // PKR 12,000.00
      date: DateTime(2026, 11, 3, 14, 15),
      categoryId: 'cat_shopping',
      note: 'Ergonomic Desk Accessories & Gear',
    ),
    TransactionModel(
      id: 'tx_exp_2',
      type: TransactionType.expense,
      amount: 850000, // PKR 8,500.00
      date: DateTime(2026, 11, 4, 19, 0),
      categoryId: 'cat_food',
      note: 'Weekly Organic Grocery Run',
    ),
    TransactionModel(
      id: 'tx_exp_3',
      type: TransactionType.expense,
      amount: 650000, // PKR 6,500.00 (Exceeds 6,000 budget!)
      date: DateTime(2026, 11, 4, 11, 30),
      categoryId: 'cat_bills',
      note: 'High-Speed Fiber Internet & Electricity',
    ),
    TransactionModel(
      id: 'tx_exp_4',
      type: TransactionType.expense,
      amount: 580000, // PKR 5,800.00
      date: DateTime(2026, 11, 4, 17, 20),
      categoryId: 'cat_transport',
      note: 'Fuel Refill & Monthly Metro Pass',
    ),
    TransactionModel(
      id: 'tx_exp_5',
      type: TransactionType.expense,
      amount: 420000, // PKR 4,200.00 (Total food = 12,700 / 15,000 = 84.7% warning!)
      date: DateTime(2026, 11, 5, 13, 0),
      categoryId: 'cat_food',
      note: 'Team Strategy Lunch & Coffee',
    ),
  ];

  final List<BudgetModel> _budgets = [
    // 84.7% Spent -> Warning!
    const BudgetModel(
      id: 'b_food',
      categoryId: 'cat_food',
      limitAmount: 1500000, // PKR 15,000
      monthYear: '2026-11',
    ),
    // 108.3% Spent -> Over Budget!
    const BudgetModel(
      id: 'b_bills',
      categoryId: 'cat_bills',
      limitAmount: 600000, // PKR 6,000
      monthYear: '2026-11',
    ),
    // 58.0% Spent -> On Track
    const BudgetModel(
      id: 'b_transport',
      categoryId: 'cat_transport',
      limitAmount: 1000000, // PKR 10,000
      monthYear: '2026-11',
    ),
    // 60.0% Spent -> On Track
    const BudgetModel(
      id: 'b_shopping',
      categoryId: 'cat_shopping',
      limitAmount: 2000000, // PKR 20,000
      monthYear: '2026-11',
    ),
  ];

  @override
  Future<List<CategoryModel>> getAllCategories() async => List.from(_cats);

  @override
  Future<List<TransactionModel>> getAllTransactions() async => List.from(_txs);

  @override
  Future<List<TransactionModel>> getTransactionsByMonth(String monthYear) async {
    return _txs
        .where((t) => DateFormatter.toMonthYearKey(t.date) == monthYear)
        .toList();
  }

  @override
  Future<int> getMonthlyIncome(String monthYear) async {
    return _txs
        .where((t) => t.isIncome && DateFormatter.toMonthYearKey(t.date) == monthYear)
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  @override
  Future<int> getMonthlyExpense(String monthYear) async {
    return _txs
        .where((t) => t.isExpense && DateFormatter.toMonthYearKey(t.date) == monthYear)
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  @override
  Future<int> getTotalBalance() async {
    final inc = _txs.where((t) => t.isIncome).fold<int>(0, (s, t) => s + t.amount);
    final exp = _txs.where((t) => t.isExpense).fold<int>(0, (s, t) => s + t.amount);
    return inc - exp;
  }

  @override
  Future<List<Map<String, dynamic>>> getCategorySpending(String monthYear) async {
    final Map<String, int> spendMap = {};
    for (final tx in _txs) {
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

  @override
  Future<int> insertTransaction(TransactionModel tx) async {
    _txs.removeWhere((t) => t.id == tx.id);
    _txs.insert(0, tx);
    return 1;
  }

  @override
  Future<List<BudgetModel>> getBudgetsByMonth(String monthYear) async {
    return _budgets.where((b) => b.monthYear == monthYear).map((b) {
      final spent = _txs
          .where((t) =>
              t.isExpense &&
              t.categoryId == b.categoryId &&
              DateFormatter.toMonthYearKey(t.date) == monthYear)
          .fold<int>(0, (sum, t) => sum + t.amount);
      return b.copyWith(spentAmount: spent);
    }).toList();
  }

  @override
  Future<int> getTotalBudgetForMonth(String monthYear) async {
    return _budgets
        .where((b) => b.monthYear == monthYear)
        .fold<int>(0, (sum, b) => sum + b.limitAmount);
  }
}

void main() {
  setUpAll(() async {
    await loadRealFonts();
  });

  testWidgets('Capture Day 5 Final Submission Evidence Screenshots', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeDb = FinalEvidenceDbService();
    final txController = TransactionController(dbService: fakeDb);
    final budgetController = BudgetController(dbService: fakeDb);

    await txController.loadInitialData();
    await budgetController.loadBudgets(monthYear: '2026-11');

    TransactionController.instance = txController;
    BudgetController.instance = budgetController;

    final repaintKey = GlobalKey();

    await tester.pumpWidget(
      RepaintBoundary(
        key: repaintKey,
        child: const SpendWiseApp(),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> capture(String filename) async {
      await tester.runAsync(() async {
        final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();
        File('evidence/final_submission/$filename').writeAsBytesSync(bytes);
        print('Captured evidence/final_submission/$filename (${bytes.length} bytes)');
      });
    }

    // ==========================================
    // 01_dashboard.png
    // Dashboard showing balance, income & expense summary, quick actions, recent transactions
    // ==========================================
    await capture('01_dashboard.png');

    // ==========================================
    // 02_add_income.png
    // Add Income form with category, amount, date, and note
    // ==========================================
    await tester.tap(find.byKey(const Key('nav_add')));
    await tester.pumpAndSettle();

    // Switch to Income tab
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    // Fill sample values for a clean demonstration
    await tester.enterText(find.byKey(const Key('amount_input_field')), '45000');
    await tester.enterText(find.byKey(const Key('note_input_field')), 'Freelance UI Design Sprint');
    await tester.pumpAndSettle();
    await capture('02_add_income.png');

    // ==========================================
    // 03_add_expense.png
    // Add Expense form with category, amount, date, and note
    // ==========================================
    await tester.tap(find.text('Expense'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('amount_input_field')), '3500');
    await tester.enterText(find.byKey(const Key('note_input_field')), 'Client Coffee & Discussion');
    await tester.pumpAndSettle();
    await capture('03_add_expense.png');

    // ==========================================
    // 09_validation_errors.png
    // Form validation state showing error message when empty amount is submitted
    // ==========================================
    await tester.enterText(find.byKey(const Key('amount_input_field')), '');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record Transaction'));
    await tester.pumpAndSettle();
    await capture('09_validation_errors.png');

    // ==========================================
    // 04_monthly_budgets.png
    // Budgets screen showing monthly allocations, spent vs budget progress, remaining
    // ==========================================
    await tester.tap(find.byKey(const Key('nav_budgets')));
    await tester.pumpAndSettle();
    await capture('04_monthly_budgets.png');

    // ==========================================
    // 05_budget_warning_overbudget.png
    // Budget cards highlighting Warning (80-99%) and Over-Budget (>=100%) states
    // ==========================================
    // Scroll slightly to focus on category cards
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -260));
    await tester.pumpAndSettle();
    await capture('05_budget_warning_overbudget.png');

    // ==========================================
    // 06_history_combined_filters.png
    // History screen showing month navigation + category chip filtering (Food & Dining)
    // ==========================================
    await tester.tap(find.byKey(const Key('nav_history')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('history_cat_cat_food')));
    await tester.pumpAndSettle();
    await capture('06_history_combined_filters.png');

    // Reset category filter
    await tester.tap(find.byKey(const Key('history_cat_all')));
    await tester.pumpAndSettle();

    // ==========================================
    // 07_category_spending_visualization.png
    // Category-wise expense breakdown with horizontal progress bars and percentage share
    // ==========================================
    await tester.tap(find.byKey(const Key('view_mode_breakdown')));
    await tester.pumpAndSettle();
    await capture('07_category_spending_visualization.png');

    // ==========================================
    // 08_empty_state.png
    // Clean empty state when viewing a month with no transactions (e.g. December 2026)
    // ==========================================
    await tester.tap(find.byKey(const Key('view_mode_transactions')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('history_next_month')));
    await tester.pumpAndSettle();
    await capture('08_empty_state.png');

    // Return to November 2026
    await tester.tap(find.byKey(const Key('history_prev_month')));
    await tester.pumpAndSettle();
    await capture('11_history_all.png');

    // ==========================================
    // 10_settings_storage.png
    // Settings screen showing SQLite Local Database verification
    // ==========================================
    await tester.tap(find.byKey(const Key('nav_settings')));
    await tester.pumpAndSettle();
    // Tap Test DB button to show active health output
    await tester.tap(find.text('Test DB'));
    await tester.pumpAndSettle();
    await capture('10_settings_storage.png');

    print('SUCCESS: All Day 5 Final Submission Evidence Screenshots Captured!');
  });
}
