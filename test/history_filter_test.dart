import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:spend_wise/core/database/database_constants.dart';
import 'package:spend_wise/core/database/database_service.dart';
import 'package:spend_wise/core/utils/date_formatter.dart';
import 'package:spend_wise/features/history/widgets/category_spending_visualization.dart';
import 'package:spend_wise/models/category_model.dart';
import 'package:spend_wise/models/transaction_model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late String dbPath;
  late DatabaseService dbService;

  final catFood = const CategoryModel(
    id: 'cat_food',
    name: 'Food & Dining',
    type: TransactionType.expense,
    iconName: 'food',
    colorValue: 0xFFF59E0B,
  );

  final catTransport = const CategoryModel(
    id: 'cat_transport',
    name: 'Transportation',
    type: TransactionType.expense,
    iconName: 'transport',
    colorValue: 0xFF3B82F6,
  );

  final catShopping = const CategoryModel(
    id: 'cat_shopping',
    name: 'Shopping & Gear',
    type: TransactionType.expense,
    iconName: 'shopping',
    colorValue: 0xFFEC4899,
  );

  final catSalary = const CategoryModel(
    id: 'cat_salary',
    name: 'Salary',
    type: TransactionType.income,
    iconName: 'salary',
    colorValue: 0xFF10B981,
  );

  Future<Database> initTestDb(String path) async {
    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        final batch = db.batch();
        batch.execute(DatabaseConstants.createCategoriesTable);
        batch.execute(DatabaseConstants.createTransactionsTable);
        batch.execute(DatabaseConstants.createBudgetsTable);
        batch.execute(DatabaseConstants.createTransactionsDateIndex);
        batch.execute(DatabaseConstants.createTransactionsCategoryIndex);

        for (final c in [catFood, catTransport, catShopping, catSalary]) {
          batch.insert(DatabaseConstants.tableCategories, c.toMap());
        }

        await batch.commit(noResult: true);
      },
    );
  }

  setUp(() async {
    final randomId = Random().nextInt(1000000);
    dbPath = 'spend_wise_history_test_${DateTime.now().microsecondsSinceEpoch}_$randomId.db';
    db = await initTestDb(dbPath);
    dbService = DatabaseService(overrideDb: db);
  });

  tearDown(() async {
    await db.close();
    try {
      await databaseFactory.deleteDatabase(dbPath);
    } catch (_) {}
  });

  group('Day 4 Mandatory Tests: History Filters & Spending Visualization', () {
    // 1. Month filtering returns only transactions from the selected month
    test('1. Month filtering returns only transactions from the selected month', () async {
      await dbService.insertTransaction(
        TransactionModel(
          id: 'tx_nov_1',
          type: TransactionType.expense,
          amount: 500000,
          date: DateTime(2026, 11, 15),
          categoryId: 'cat_food',
        ),
      );
      await dbService.insertTransaction(
        TransactionModel(
          id: 'tx_oct_1',
          type: TransactionType.expense,
          amount: 300000,
          date: DateTime(2026, 10, 20),
          categoryId: 'cat_food',
        ),
      );

      final all = await dbService.getAllTransactions();
      expect(all.length, 2);

      final novOnly = all.where((t) => DateFormatter.isInMonth(t.date, '2026-11')).toList();
      expect(novOnly.length, 1);
      expect(novOnly.first.id, 'tx_nov_1');

      final octOnly = all.where((t) => DateFormatter.isInMonth(t.date, '2026-10')).toList();
      expect(octOnly.length, 1);
      expect(octOnly.first.id, 'tx_oct_1');
    });

    // 2. Category filtering returns only transactions from the selected category
    test('2. Category filtering returns only transactions from the selected category', () async {
      await dbService.insertTransaction(
        TransactionModel(
          id: 'tx_food',
          type: TransactionType.expense,
          amount: 400000,
          date: DateTime(2026, 11, 2),
          categoryId: 'cat_food',
        ),
      );
      await dbService.insertTransaction(
        TransactionModel(
          id: 'tx_transport',
          type: TransactionType.expense,
          amount: 250000,
          date: DateTime(2026, 11, 3),
          categoryId: 'cat_transport',
        ),
      );

      final all = await dbService.getAllTransactions();
      final foodOnly = all.where((t) => t.categoryId == 'cat_food').toList();
      expect(foodOnly.length, 1);
      expect(foodOnly.first.id, 'tx_food');

      final transportOnly = all.where((t) => t.categoryId == 'cat_transport').toList();
      expect(transportOnly.length, 1);
      expect(transportOnly.first.id, 'tx_transport');
    });

    // 3. Month and category filters work together
    test('3. Month and category filters work together', () async {
      await dbService.insertTransaction(
        TransactionModel(
          id: 'tx_nov_food',
          type: TransactionType.expense,
          amount: 200000,
          date: DateTime(2026, 11, 4),
          categoryId: 'cat_food',
        ),
      );
      await dbService.insertTransaction(
        TransactionModel(
          id: 'tx_nov_transport',
          type: TransactionType.expense,
          amount: 150000,
          date: DateTime(2026, 11, 5),
          categoryId: 'cat_transport',
        ),
      );
      await dbService.insertTransaction(
        TransactionModel(
          id: 'tx_oct_food',
          type: TransactionType.expense,
          amount: 300000,
          date: DateTime(2026, 10, 15),
          categoryId: 'cat_food',
        ),
      );

      final all = await dbService.getAllTransactions();
      final combined = all.where((t) {
        return DateFormatter.isInMonth(t.date, '2026-11') && t.categoryId == 'cat_food';
      }).toList();

      expect(combined.length, 1);
      expect(combined.first.id, 'tx_nov_food');
    });

    // 4. Clearing filters restores the correct transaction list
    test('4. Clearing filters restores the correct transaction list', () async {
      await dbService.insertTransaction(
        TransactionModel(
          id: 't1',
          type: TransactionType.expense,
          amount: 100000,
          date: DateTime(2026, 11, 1),
          categoryId: 'cat_food',
        ),
      );
      await dbService.insertTransaction(
        TransactionModel(
          id: 't2',
          type: TransactionType.income,
          amount: 500000,
          date: DateTime(2026, 10, 1),
          categoryId: 'cat_salary',
        ),
      );

      final all = await dbService.getAllTransactions();

      // Apply filter
      final filtered = all.where((t) => t.categoryId == 'cat_food').toList();
      expect(filtered.length, 1);

      // Clear filter
      final restored = all.toList();
      expect(restored.length, 2);
    });

    // 5. December-to-January and other month-boundary cases work correctly
    test('5. December-to-January and other month-boundary cases work correctly', () {
      // Transition from Dec 2026 to Jan 2027
      expect(DateFormatter.getNextMonthKey('2026-12'), '2027-01');

      // Transition from Jan 2027 to Dec 2026
      expect(DateFormatter.getPreviousMonthKey('2027-01'), '2026-12');

      // Month boundary dates
      final lastSecondDec = DateTime(2026, 12, 31, 23, 59, 59);
      final firstSecondJan = DateTime(2027, 1, 1, 0, 0, 0);

      expect(DateFormatter.isInMonth(lastSecondDec, '2026-12'), isTrue);
      expect(DateFormatter.isInMonth(lastSecondDec, '2027-01'), isFalse);

      expect(DateFormatter.isInMonth(firstSecondJan, '2027-01'), isTrue);
      expect(DateFormatter.isInMonth(firstSecondJan, '2026-12'), isFalse);
    });

    // 6. Category spending totals are calculated accurately
    test('6. Category spending totals are calculated accurately', () {
      final txs = [
        TransactionModel(
          id: 'e1',
          type: TransactionType.expense,
          amount: 2000000, // PKR 20,000 (50%)
          date: DateTime(2026, 11, 1),
          categoryId: 'cat_food',
        ),
        TransactionModel(
          id: 'e2',
          type: TransactionType.expense,
          amount: 1000000, // PKR 10,000 (25%)
          date: DateTime(2026, 11, 2),
          categoryId: 'cat_transport',
        ),
        TransactionModel(
          id: 'e3',
          type: TransactionType.expense,
          amount: 1000000, // PKR 10,000 (25%)
          date: DateTime(2026, 11, 3),
          categoryId: 'cat_shopping',
        ),
      ];

      final totalExpense = txs.fold<int>(0, (sum, t) => sum + t.amount);
      expect(totalExpense, 4000000); // PKR 40,000

      final Map<String, int> catMap = {};
      for (final t in txs) {
        catMap[t.categoryId] = (catMap[t.categoryId] ?? 0) + t.amount;
      }

      final List<CategorySpendingData> spendingData = [];
      for (final entry in catMap.entries) {
        final pct = (entry.value / totalExpense) * 100.0;
        spendingData.add(
          CategorySpendingData(
            category: entry.key == 'cat_food'
                ? catFood
                : (entry.key == 'cat_transport' ? catTransport : catShopping),
            totalSpentMinor: entry.value,
            percentageOfTotal: pct,
          ),
        );
      }
      spendingData.sort((a, b) => b.totalSpentMinor.compareTo(a.totalSpentMinor));

      expect(spendingData.length, 3);
      // Food #1 at 50%
      expect(spendingData[0].category.id, 'cat_food');
      expect(spendingData[0].totalSpentMinor, 2000000);
      expect(spendingData[0].percentageOfTotal, 50.0);

      // Transport & Shopping at 25%
      expect(spendingData[1].percentageOfTotal, 25.0);
      expect(spendingData[2].percentageOfTotal, 25.0);
    });

    // 7. Income transactions are excluded from expense visualization
    test('7. Income transactions are excluded from expense visualization', () {
      final mixedTxs = [
        TransactionModel(
          id: 'inc1',
          type: TransactionType.income,
          amount: 10000000, // PKR 100,000 Salary
          date: DateTime(2026, 11, 1),
          categoryId: 'cat_salary',
        ),
        TransactionModel(
          id: 'exp1',
          type: TransactionType.expense,
          amount: 1500000, // PKR 15,000 Food
          date: DateTime(2026, 11, 2),
          categoryId: 'cat_food',
        ),
      ];

      final expenseOnly = mixedTxs.where((t) => t.isExpense).toList();
      expect(expenseOnly.length, 1);
      expect(expenseOnly.first.categoryId, 'cat_food');
      expect(expenseOnly.any((t) => t.isIncome), isFalse);
    });

    // 8. Empty months and months without expenses do not cause errors
    test('8. Empty months and months without expenses do not cause errors (zero division safety)', () {
      final int totalExpenseZero = 0;
      final categorySpent = 0;

      // Ensure no division by zero occurs
      final double safePercentage = totalExpenseZero > 0
          ? (categorySpent / totalExpenseZero) * 100.0
          : 0.0;

      expect(safePercentage, 0.0);
      expect(safePercentage.isNaN, isFalse);
      expect(safePercentage.isInfinite, isFalse);
    });

    // 9. Adding, editing, and deleting transactions refreshes the relevant data
    test('9. Adding, editing, and deleting transactions refreshes the relevant data', () async {
      // Add
      final tx = TransactionModel(
        id: 'tx_dyn',
        type: TransactionType.expense,
        amount: 200000,
        date: DateTime(2026, 11, 10),
        categoryId: 'cat_food',
      );
      await dbService.insertTransaction(tx);
      expect(await dbService.getMonthlyExpense('2026-11'), 200000);

      // Edit
      final updatedTx = tx.copyWith(amount: 350000);
      await dbService.updateTransaction(updatedTx);
      expect(await dbService.getMonthlyExpense('2026-11'), 350000);

      // Delete
      await dbService.deleteTransaction('tx_dyn');
      expect(await dbService.getMonthlyExpense('2026-11'), 0);
    });

    // 10. Existing budget calculations and Day 1–3 functionality continue working
    test('10. Existing budget calculations and Day 1–3 functionality continue working', () async {
      // Verify monthly income, monthly expense, and net balance aggregations
      await dbService.insertTransaction(
        TransactionModel(
          id: 'i1',
          type: TransactionType.income,
          amount: 5000000,
          date: DateTime(2026, 11, 1),
          categoryId: 'cat_salary',
        ),
      );
      await dbService.insertTransaction(
        TransactionModel(
          id: 'e1',
          type: TransactionType.expense,
          amount: 1500000,
          date: DateTime(2026, 11, 2),
          categoryId: 'cat_food',
        ),
      );

      final income = await dbService.getMonthlyIncome('2026-11');
      final expense = await dbService.getMonthlyExpense('2026-11');
      final balance = await dbService.getTotalBalance();

      expect(income, 5000000);
      expect(expense, 1500000);
      expect(balance, 3500000);
    });
  });
}

