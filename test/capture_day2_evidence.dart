// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spend_wise/app/app.dart';
import 'package:spend_wise/core/constants/app_strings.dart';
import 'package:spend_wise/core/controllers/transaction_controller.dart';
import 'package:spend_wise/core/database/database_service.dart';
import 'package:spend_wise/core/utils/date_formatter.dart';
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

class Day2EvidenceDbService extends DatabaseService {
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
      amount: 450000,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      categoryId: 'cat_food',
      note: 'Team lunch & coffee',
    ),
    TransactionModel(
      id: 'tx_2',
      type: TransactionType.expense,
      amount: 180000,
      date: DateTime.now().subtract(const Duration(hours: 6)),
      categoryId: 'cat_transport',
      note: 'Fuel & toll charges',
    ),
    TransactionModel(
      id: 'tx_3',
      type: TransactionType.expense,
      amount: 850000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      categoryId: 'cat_bills',
      note: 'Fiber internet bill',
    ),
    TransactionModel(
      id: 'tx_4',
      type: TransactionType.income,
      amount: 12500000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      categoryId: 'cat_salary',
      note: 'November tech stipend',
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
  Future<List<TransactionModel>> getTransactionsByType(TransactionType type) async =>
      _txs.where((t) => t.type == type).toList();

  @override
  Future<List<TransactionModel>> getTransactionsByCategory(String categoryId) async =>
      _txs.where((t) => t.categoryId == categoryId).toList();

  @override
  Future<List<TransactionModel>> getTransactionsByMonth(String monthYear) async =>
      _txs.where((t) => DateFormatter.toMonthYearKey(t.date) == monthYear).toList();

  @override
  Future<int> insertTransaction(TransactionModel transaction) async {
    _txs.removeWhere((t) => t.id == transaction.id);
    _txs.insert(0, transaction);
    return 1;
  }

  @override
  Future<int> updateTransaction(TransactionModel transaction) async {
    final idx = _txs.indexWhere((t) => t.id == transaction.id);
    if (idx != -1) {
      _txs[idx] = transaction;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteTransaction(String id) async {
    final count = _txs.where((t) => t.id == id).length;
    _txs.removeWhere((t) => t.id == id);
    return count;
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
    final inc = _txs.where((t) => t.isIncome).fold<int>(0, (sum, t) => sum + t.amount);
    final exp = _txs.where((t) => t.isExpense).fold<int>(0, (sum, t) => sum + t.amount);
    return inc - exp;
  }

  @override
  Future<List<Map<String, dynamic>>> getCategorySpending(String monthYear) async {
    final Map<String, int> spend = {};
    for (final tx in _txs) {
      if (tx.isExpense && DateFormatter.toMonthYearKey(tx.date) == monthYear) {
        spend[tx.categoryId] = (spend[tx.categoryId] ?? 0) + tx.amount;
      }
    }
    final list = spend.entries.map((e) => {'category_id': e.key, 'total_spent': e.value}).toList();
    list.sort((a, b) => (b['total_spent'] as int).compareTo(a['total_spent'] as int));
    return list;
  }
}

void main() {
  setUpAll(() async {
    await loadRealFonts();
  });

  testWidgets('Capture Day 2 Visual Evidence', (WidgetTester tester) async {
    // 1080x2400 standard high resolution mobile display with 2.5 pixel ratio (432 x 960 dp)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final db = Day2EvidenceDbService();
    final controller = TransactionController(dbService: db);
    await controller.loadInitialData();
    TransactionController.instance = controller;

    final repaintKey = GlobalKey();

    await tester.pumpWidget(
      RepaintBoundary(
        key: repaintKey,
        child: const SpendWiseApp(),
      ),
    );
    await tester.pumpAndSettle();

    final evidenceDir = Directory('evidence/day_2');
    if (!evidenceDir.existsSync()) {
      evidenceDir.createSync(recursive: true);
    }

    Future<void> capture(String filename) async {
      await tester.runAsync(() async {
        final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();
        File('evidence/day_2/$filename').writeAsBytesSync(bytes);
        print('Captured evidence/day_2/$filename (${bytes.length} bytes)');
      });
    }

    // 1. Dashboard Screen (Balance, Income, Expense, Budget Goal, Recent Transactions)
    await capture('01_dashboard.png');

    // 2. Add Expense Form (Tab index 2, Expense mode with preset chips & categories)
    await tester.tap(find.byKey(const Key('nav_add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('amount_input_field')), '4500');
    await tester.enterText(find.byKey(const Key('note_input_field')), 'Team lunch & coffee');
    await tester.pumpAndSettle();
    await capture('02_add_expense.png');

    // 3. Add Income Form (Income toggle active with emerald green accent & income categories)
    await tester.tap(find.text(AppStrings.income));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('amount_input_field')), '125000');
    await tester.enterText(find.byKey(const Key('note_input_field')), 'Monthly stipend');
    await tester.pumpAndSettle();
    await capture('03_add_income.png');

    // 4. Transaction History Screen (Tab index 1, Newest first, Income/Expense badges)
    await tester.tap(find.byKey(const Key('nav_history')));
    await tester.pumpAndSettle();
    await capture('04_transaction_history.png');

    // 5. Transaction Filters (Filtering History by category or type)
    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();
    await capture('07_transaction_filters.png');

    // Reset filter
    await tester.tap(find.text('All Types'));
    await tester.pumpAndSettle();

    // 6. Edit Transaction Screen (pre-filled with data)
    await tester.tap(find.byKey(const Key('tx_menu_tx_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Entry'));
    await tester.pumpAndSettle();
    await capture('05_edit_transaction.png');

    // Return to History
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 7. Delete Confirmation Dialog
    await tester.tap(find.byKey(const Key('tx_menu_tx_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await capture('06_delete_confirmation.png');

    // Dismiss dialog with Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // 8. Budgets Screen (Tab index 3)
    await tester.tap(find.byKey(const Key('nav_budgets')));
    await tester.pumpAndSettle();
    await capture('08_budgets_screen.png');

    // 9. Settings Screen (Tab index 4)
    await tester.tap(find.byKey(const Key('nav_settings')));
    await tester.pumpAndSettle();
    await capture('09_settings_screen.png');

    print('ALL 9 DAY 2 SCREENSHOTS CAPTURED SUCCESSFULLY!');
  });
}
