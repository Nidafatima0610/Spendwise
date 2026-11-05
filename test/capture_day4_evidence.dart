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

class Day4EvidenceDbService extends DatabaseService {
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
      amount: 2200000, // PKR 22,000 for Food
      date: DateTime(2026, 11, 4, 13, 30),
      categoryId: 'cat_food',
      note: 'Weekly gourmet groceries & lunch',
    ),
    TransactionModel(
      id: 'tx_2',
      type: TransactionType.expense,
      amount: 1100000, // PKR 11,000 for Shopping
      date: DateTime(2026, 11, 3, 17, 15),
      categoryId: 'cat_shopping',
      note: 'Noise cancelling headphones',
    ),
    TransactionModel(
      id: 'tx_3',
      type: TransactionType.expense,
      amount: 850000, // PKR 8,500 for Bills
      date: DateTime(2026, 11, 2, 11, 0),
      categoryId: 'cat_bills',
      note: 'Fiber internet & cloud server',
    ),
    TransactionModel(
      id: 'tx_4',
      type: TransactionType.expense,
      amount: 450000, // PKR 4,500 for Transport
      date: DateTime(2026, 11, 2, 9, 30),
      categoryId: 'cat_transport',
      note: 'Fuel & Careem rides',
    ),
    TransactionModel(
      id: 'tx_5',
      type: TransactionType.income,
      amount: 14000000, // PKR 140,000 Salary
      date: DateTime(2026, 11, 1, 9, 0),
      categoryId: 'cat_salary',
      note: 'Tech fellowship monthly stipend',
    ),
  ];

  final List<BudgetModel> _budgets = [
    const BudgetModel(
      id: 'b_food',
      categoryId: 'cat_food',
      limitAmount: 2500000,
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

  @override
  Future<int> insertTransaction(TransactionModel tx) async {
    _txs.removeWhere((t) => t.id == tx.id);
    _txs.insert(0, tx);
    return 1;
  }

  // Budget stubs
  @override
  Future<List<BudgetModel>> getBudgetsByMonth(String monthYear) async => List.from(_budgets);
  @override
  Future<int> getTotalBudgetForMonth(String monthYear) async => 2500000;
}

void main() {
  setUpAll(() async {
    await loadRealFonts();
  });

  testWidgets('Capture Day 4 Visual Evidence Screenshots', (WidgetTester tester) async {
    // Standard flagship viewport: 1080x2400 physical, 2.5 ratio (432dp logical width)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeDb = Day4EvidenceDbService();
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
        File('evidence/day_4/$filename').writeAsBytesSync(bytes);
        print('Captured evidence/day_4/$filename (${bytes.length} bytes)');
      });
    }

    // Navigate to History Screen (Tab index 1)
    await tester.tap(find.byKey(const Key('nav_history')));
    await tester.pumpAndSettle();

    // ==========================================
    // 01_history_month_selector.png
    // History screen with month selector (November 2026 active)
    // ==========================================
    await capture('01_history_month_selector.png');

    // ==========================================
    // 02_history_category_filter.png
    // History screen with category filter selected (Food & Dining active)
    // ==========================================
    await tester.tap(find.byKey(const Key('history_cat_cat_food')));
    await tester.pumpAndSettle();
    await capture('02_history_category_filter.png');

    // ==========================================
    // 03_combined_filters.png
    // History screen with both month and category filters applied
    // ==========================================
    await capture('03_combined_filters.png');

    // Reset Category Filter back to all
    await tester.tap(find.byKey(const Key('history_cat_all')));
    await tester.pumpAndSettle();

    // ==========================================
    // 04_spending_visualization.png
    // Category-wise spending visualization (Breakdown mode with horizontal bars & percentages)
    // ==========================================
    await tester.tap(find.byKey(const Key('view_mode_breakdown')));
    await tester.pumpAndSettle();
    await capture('04_spending_visualization.png');

    // ==========================================
    // 05_empty_history_state.png
    // Empty history state for a month without transactions (e.g. December 2026)
    // ==========================================
    // Switch to List mode first
    await tester.tap(find.byKey(const Key('view_mode_transactions')));
    await tester.pumpAndSettle();
    // Navigate forward to December 2026
    await tester.tap(find.byKey(const Key('history_next_month')));
    await tester.pumpAndSettle();
    await capture('05_empty_history_state.png');

    // Return to November 2026
    await tester.tap(find.byKey(const Key('history_prev_month')));
    await tester.pumpAndSettle();

    // ==========================================
    // 06_updated_visualization_after_tx.png
    // Updated visualization after transaction changes (add Education expense)
    // ==========================================
    await fakeDb.insertTransaction(
      TransactionModel(
        id: 'tx_6_new',
        type: TransactionType.expense,
        amount: 1500000, // PKR 15,000 for Transport
        date: DateTime(2026, 11, 4, 18, 0),
        categoryId: 'cat_transport',
        note: 'City commute pass renewal',
      ),
    );
    await txController.refresh();
    await tester.pumpAndSettle();

    // Switch to Breakdown mode to capture updated distribution
    await tester.tap(find.byKey(const Key('view_mode_breakdown')));
    await tester.pumpAndSettle();
    await capture('06_updated_visualization_after_tx.png');

    // ==========================================
    // 07_responsive_small_screen.png
    // Responsive layout on a small screen (360x780 logical width, 0 overflow)
    // ==========================================
    tester.view.physicalSize = const Size(720, 1560);
    tester.view.devicePixelRatio = 2.0;
    await tester.pumpAndSettle();
    await capture('07_responsive_small_screen.png');

    print('ALL 7 DAY 4 SCREENSHOTS CAPTURED SUCCESSFULLY!');
  });
}

