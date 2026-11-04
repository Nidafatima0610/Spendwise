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

class Day3EvidenceDbService extends DatabaseService {
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
    TransactionModel(
      id: 'tx_1',
      type: TransactionType.expense,
      amount: 2300000, // PKR 23,000 for Food (Budget is 20,000 => 115% OVER BUDGET)
      date: DateTime(2026, 11, 2, 14, 30),
      categoryId: 'cat_food',
      note: 'Monthly groceries & dining',
    ),
    TransactionModel(
      id: 'tx_2',
      type: TransactionType.expense,
      amount: 850000, // PKR 8,500 for Bills (Budget is 10,000 => 85% NEAR LIMIT)
      date: DateTime(2026, 11, 1, 10, 15),
      categoryId: 'cat_bills',
      note: 'Electricity and fiber internet',
    ),
    TransactionModel(
      id: 'tx_3',
      type: TransactionType.expense,
      amount: 400000, // PKR 4,000 for Transport (Budget is 10,000 => 40% ON TRACK)
      date: DateTime(2026, 11, 3, 9, 0),
      categoryId: 'cat_transport',
      note: 'Fuel & Careem rides',
    ),
    TransactionModel(
      id: 'tx_4',
      type: TransactionType.expense,
      amount: 1200000, // PKR 12,000 for Shopping (Budget is 20,000 => 60% ON TRACK)
      date: DateTime(2026, 11, 3, 16, 45),
      categoryId: 'cat_shopping',
      note: 'Work desk setup accessories',
    ),
    TransactionModel(
      id: 'tx_5',
      type: TransactionType.income,
      amount: 14000000, // PKR 140,000 Salary
      date: DateTime(2026, 11, 1, 9, 0),
      categoryId: 'cat_salary',
      note: 'Stack & Scale tech stipend',
    ),
  ];

  final List<BudgetModel> _budgets = [
    const BudgetModel(
      id: 'b_food',
      categoryId: 'cat_food',
      limitAmount: 2000000, // PKR 20,000
      monthYear: '2026-11',
    ),
    const BudgetModel(
      id: 'b_bills',
      categoryId: 'cat_bills',
      limitAmount: 1000000, // PKR 10,000
      monthYear: '2026-11',
    ),
    const BudgetModel(
      id: 'b_transport',
      categoryId: 'cat_transport',
      limitAmount: 1000000, // PKR 10,000
      monthYear: '2026-11',
    ),
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
  Future<List<CategoryModel>> getCategoriesByType(TransactionType type) async =>
      _cats.where((c) => c.type == type).toList();

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      return _cats.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    final list = List<TransactionModel>.from(_txs);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

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

  // Budget Methods
  @override
  Future<List<BudgetModel>> getBudgetsByMonth(String monthYear) async {
    final list = _budgets.where((b) => b.monthYear == monthYear).toList();
    return Future.wait(list.map((b) async {
      final spent = await getCategorySpentAmount(b.categoryId, monthYear);
      return b.copyWith(spentAmount: spent);
    }));
  }

  @override
  Future<int> getCategorySpentAmount(String categoryId, String monthYear) async {
    return _txs
        .where((t) =>
            t.isExpense &&
            t.categoryId == categoryId &&
            DateFormatter.toMonthYearKey(t.date) == monthYear)
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  @override
  Future<int> getTotalBudgetForMonth(String monthYear) async {
    return _budgets
        .where((b) => b.monthYear == monthYear)
        .fold<int>(0, (sum, b) => sum + b.limitAmount);
  }

  @override
  Future<int> insertBudget(BudgetModel budget) async {
    _budgets.add(budget);
    return 1;
  }

  @override
  Future<int> updateBudget(BudgetModel budget) async {
    final idx = _budgets.indexWhere((b) => b.id == budget.id);
    if (idx != -1) {
      _budgets[idx] = budget;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteBudget(String id) async {
    final count = _budgets.where((b) => b.id == id).length;
    _budgets.removeWhere((b) => b.id == id);
    return count;
  }
}

void main() {
  setUpAll(() async {
    await loadRealFonts();
  });

  testWidgets('Capture Day 3 High-Fidelity Genuine Screenshots', (WidgetTester tester) async {
    // 1080x2400 physical size with devicePixelRatio 2.5 (432dp logical width, 0 overflow)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeDb = Day3EvidenceDbService();
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
        File('evidence/day_3/$filename').writeAsBytesSync(bytes);
        print('Captured evidence/day_3/$filename (${bytes.length} bytes)');
      });
    }

    // ==========================================
    // 07_dashboard_integration.png
    // Dashboard with real budget and financial calculations
    // ==========================================
    await capture('07_dashboard_integration.png');

    // Navigate to Budgets Screen (Tab index 3)
    await tester.tap(find.byKey(const Key('nav_budgets')));
    await tester.pumpAndSettle();

    // ==========================================
    // 01_budgets_dashboard.png
    // Main Budgets screen showing Pool, Warning Banner, Category Allocations
    // ==========================================
    await capture('01_budgets_dashboard.png');

    // ==========================================
    // 04_budget_progress.png
    // Category budgets with actual spending & progress bars
    // ==========================================
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -180));
    await tester.pumpAndSettle();
    await capture('04_budget_progress.png');

    // ==========================================
    // 05_warning_status.png
    // Highlight near-limit / warning state (Bills at 85%)
    // ==========================================
    await capture('05_warning_status.png');

    // Scroll back to top
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();

    // ==========================================
    // 06_over_budget.png
    // Over Budget state (Food at 115% with alert banner)
    // ==========================================
    await capture('06_over_budget.png');

    // ==========================================
    // 02_add_monthly_budget.png
    // Add Budget form
    // ==========================================
    await tester.tap(find.byKey(const Key('fab_add_budget')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('budget_amount_input')), '15000');
    await tester.pumpAndSettle();
    await capture('02_add_monthly_budget.png');

    // Close Add Budget form
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // ==========================================
    // 03_edit_monthly_budget.png
    // Edit Budget form pre-filled with existing data
    // ==========================================
    final foodBudget = budgetController.budgets.firstWhere((b) => b.categoryId == 'cat_food');
    await tester.tap(find.byKey(Key('budget_menu_${foodBudget.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Limit'));
    await tester.pumpAndSettle();
    await capture('03_edit_monthly_budget.png');

    // Close Edit Budget form
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // ==========================================
    // 08_empty_budget_state.png
    // Empty state when navigated to a month without budgets (e.g. December 2026)
    // ==========================================
    await tester.tap(find.byKey(const Key('next_month_budget_button')));
    await tester.pumpAndSettle();
    await capture('08_empty_budget_state.png');

    print('ALL 8 DAY 3 SCREENSHOTS CAPTURED SUCCESSFULLY!');
  });
}
