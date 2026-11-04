import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:spend_wise/core/database/database_constants.dart';
import 'package:spend_wise/core/database/database_service.dart';
import 'package:spend_wise/core/utils/currency_formatter.dart';
import 'package:spend_wise/models/budget_model.dart';
import 'package:spend_wise/models/transaction_model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late String dbPath;
  late DatabaseService dbService;

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
        batch.execute(DatabaseConstants.createBudgetsCategoryMonthIndex);

        // Pre-seed categories
        batch.insert(
          DatabaseConstants.tableCategories,
          {
            DatabaseConstants.colCatId: 'cat_salary',
            DatabaseConstants.colCatName: 'Salary',
            DatabaseConstants.colCatType: 'income',
            DatabaseConstants.colCatIconName: 'salary',
            DatabaseConstants.colCatColorValue: 0xFF10B981,
            DatabaseConstants.colCatIsDefault: 1,
          },
        );
        batch.insert(
          DatabaseConstants.tableCategories,
          {
            DatabaseConstants.colCatId: 'cat_food',
            DatabaseConstants.colCatName: 'Food & Dining',
            DatabaseConstants.colCatType: 'expense',
            DatabaseConstants.colCatIconName: 'food',
            DatabaseConstants.colCatColorValue: 0xFFF59E0B,
            DatabaseConstants.colCatIsDefault: 1,
          },
        );
        batch.insert(
          DatabaseConstants.tableCategories,
          {
            DatabaseConstants.colCatId: 'cat_transport',
            DatabaseConstants.colCatName: 'Transportation',
            DatabaseConstants.colCatType: 'expense',
            DatabaseConstants.colCatIconName: 'transport',
            DatabaseConstants.colCatColorValue: 0xFF3B82F6,
            DatabaseConstants.colCatIsDefault: 1,
          },
        );
        batch.insert(
          DatabaseConstants.tableCategories,
          {
            DatabaseConstants.colCatId: 'cat_shopping',
            DatabaseConstants.colCatName: 'Shopping',
            DatabaseConstants.colCatType: 'expense',
            DatabaseConstants.colCatIconName: 'shopping',
            DatabaseConstants.colCatColorValue: 0xFFEC4899,
            DatabaseConstants.colCatIsDefault: 1,
          },
        );

        await batch.commit(noResult: true);
      },
    );
  }

  setUp(() async {
    final randomId = Random().nextInt(1000000);
    dbPath = 'spend_wise_budget_test_${DateTime.now().microsecondsSinceEpoch}_$randomId.db';
    db = await initTestDb(dbPath);
    dbService = DatabaseService(overrideDb: db);
  });

  tearDown(() async {
    await db.close();
    try {
      await databaseFactory.deleteDatabase(dbPath);
    } catch (_) {}
  });

  group('Day 3 Master Implementation: Monthly Budget Management Tests', () {
    // 1. Creating a valid monthly budget
    test('1. Creating a valid monthly budget', () async {
      final budget = BudgetModel(
        id: 'b_food_nov',
        categoryId: 'cat_food',
        limitAmount: 2000000, // PKR 20,000.00 in minor units
        monthYear: '2026-11',
      );

      final rows = await dbService.insertBudget(budget);
      expect(rows, greaterThan(0));

      final retrieved = await dbService.getBudgetsByMonth('2026-11');
      expect(retrieved.length, 1);
      expect(retrieved.first.id, 'b_food_nov');
      expect(retrieved.first.categoryId, 'cat_food');
      expect(retrieved.first.limitAmount, 2000000);
      expect(retrieved.first.formattedLimit, 'PKR 20,000.00');
    });

    // 2. Rejecting empty budget amounts
    test('2. Rejecting empty budget amounts', () {
      expect(CurrencyFormatter.parseToMinorUnits(''), 0);
      expect(CurrencyFormatter.parseToMinorUnits('   '), 0);
    });

    // 3. Rejecting zero and negative budget amounts
    test('3. Rejecting zero and negative budget amounts', () {
      expect(CurrencyFormatter.parseToMinorUnits('0'), 0);
      expect(CurrencyFormatter.parseToMinorUnits('0.00'), 0);
      expect(CurrencyFormatter.parseToMinorUnits('-500'), 0);
      expect(CurrencyFormatter.parseToMinorUnits('-12.50'), 0);
    });

    // 4. Rejecting invalid budget values
    test('4. Rejecting invalid budget values', () {
      expect(CurrencyFormatter.parseToMinorUnits('abc'), 0);
      expect(CurrencyFormatter.parseToMinorUnits('invalid_amount'), 0);
      expect(CurrencyFormatter.parseToMinorUnits('\$#@'), 0);
    });

    // 5. Preventing duplicate category budgets for the same month
    test('5. Preventing duplicate category budgets for the same month', () async {
      final budget1 = BudgetModel(
        id: 'b_food_nov_1',
        categoryId: 'cat_food',
        limitAmount: 1500000,
        monthYear: '2026-11',
      );
      await dbService.insertBudget(budget1);

      // Attempting to insert a second budget for cat_food in 2026-11 must be rejected
      final budget2 = BudgetModel(
        id: 'b_food_nov_2',
        categoryId: 'cat_food',
        limitAmount: 2500000,
        monthYear: '2026-11',
      );

      expect(
        () async => await dbService.insertBudget(budget2),
        throwsA(isA<ArgumentError>()),
      );

      // Total count in November must remain 1
      final budgets = await dbService.getBudgetsByMonth('2026-11');
      expect(budgets.length, 1);
      expect(budgets.first.limitAmount, 1500000);
    });

    // 6. Editing an existing budget without duplication
    test('6. Editing an existing budget without duplication', () async {
      final budget = BudgetModel(
        id: 'b_transport_nov',
        categoryId: 'cat_transport',
        limitAmount: 1000000, // PKR 10,000
        monthYear: '2026-11',
      );
      await dbService.insertBudget(budget);

      // Update limit to PKR 15,000
      final updated = budget.copyWith(limitAmount: 1500000);
      final affected = await dbService.updateBudget(updated);
      expect(affected, 1);

      final retrieved = await dbService.getBudgetsByMonth('2026-11');
      expect(retrieved.length, 1);
      expect(retrieved.first.limitAmount, 1500000);
      expect(retrieved.first.formattedLimit, 'PKR 15,000.00');
    });

    // 7. Deleting a budget
    test('7. Deleting a budget', () async {
      final budget = BudgetModel(
        id: 'b_del',
        categoryId: 'cat_shopping',
        limitAmount: 800000,
        monthYear: '2026-11',
      );
      await dbService.insertBudget(budget);
      expect(await dbService.getBudgetCount(), 1);

      final deletedRows = await dbService.deleteBudget('b_del');
      expect(deletedRows, 1);

      final after = await dbService.getBudgetsByMonth('2026-11');
      expect(after, isEmpty);
      expect(await dbService.getBudgetCount(), 0);
    });

    // 8. Calculating remaining budget correctly
    test('8. Calculating remaining budget correctly (positive and negative)', () async {
      // Limit = PKR 10,000 (1,000,000 paisa)
      final budget = BudgetModel(
        id: 'b_calc',
        categoryId: 'cat_food',
        limitAmount: 1000000,
        monthYear: '2026-11',
      );
      await dbService.insertBudget(budget);

      // Add expense PKR 6,000
      await dbService.insertTransaction(
        TransactionModel(
          id: 'tx_food_1',
          type: TransactionType.expense,
          amount: 600000,
          date: DateTime(2026, 11, 5),
          categoryId: 'cat_food',
        ),
      );

      final retrieved1 = (await dbService.getBudgetsByMonth('2026-11')).first;
      expect(retrieved1.spentAmount, 600000);
      expect(retrieved1.remainingAmount, 400000); // PKR 4,000
      expect(retrieved1.formattedRemaining, 'PKR 4,000.00');

      // Add another expense PKR 6,000 (total spent = PKR 12,000)
      await dbService.insertTransaction(
        TransactionModel(
          id: 'tx_food_2',
          type: TransactionType.expense,
          amount: 600000,
          date: DateTime(2026, 11, 10),
          categoryId: 'cat_food',
        ),
      );

      final retrieved2 = (await dbService.getBudgetsByMonth('2026-11')).first;
      expect(retrieved2.spentAmount, 1200000);
      expect(retrieved2.remainingAmount, -200000); // -PKR 2,000
      expect(retrieved2.formattedRemaining, '-PKR 2,000.00');
      expect(retrieved2.overBudgetAmount, 200000);
      expect(retrieved2.formattedOverBudget, 'PKR 2,000.00');
    });

    // 9. Calculating spending percentage correctly
    test('9. Calculating spending percentage correctly', () {
      final b1 = BudgetModel(
        id: 'b1',
        categoryId: 'cat_food',
        limitAmount: 1000000,
        spentAmount: 600000,
        monthYear: '2026-11',
      );
      expect(b1.percentage, 60.0);

      final b2 = BudgetModel(
        id: 'b2',
        categoryId: 'cat_food',
        limitAmount: 1000000,
        spentAmount: 1200000,
        monthYear: '2026-11',
      );
      expect(b2.percentage, 120.0);
    });

    // 10. Warning status at 80%
    test('10. Warning status at 80% to below 100%', () {
      // Exactly 80%
      final b80 = BudgetModel(
        id: 'b80',
        categoryId: 'cat_food',
        limitAmount: 1000000,
        spentAmount: 800000,
        monthYear: '2026-11',
      );
      expect(b80.status, BudgetStatus.warning);
      expect(b80.isWarning, isTrue);
      expect(b80.isNormal, isFalse);
      expect(b80.isOverBudget, isFalse);

      // 95%
      final b95 = BudgetModel(
        id: 'b95',
        categoryId: 'cat_food',
        limitAmount: 1000000,
        spentAmount: 950000,
        monthYear: '2026-11',
      );
      expect(b95.status, BudgetStatus.warning);
      expect(b95.isWarning, isTrue);
    });

    // 11. Over Budget status at 100% or above
    test('11. Over Budget status at 100% or above', () {
      // Exactly 100%
      final b100 = BudgetModel(
        id: 'b100',
        categoryId: 'cat_food',
        limitAmount: 1000000,
        spentAmount: 1000000,
        monthYear: '2026-11',
      );
      expect(b100.status, BudgetStatus.overBudget);
      expect(b100.isOverBudget, isTrue);
      expect(b100.progressRatio, 1.0);

      // 150%
      final b150 = BudgetModel(
        id: 'b150',
        categoryId: 'cat_food',
        limitAmount: 1000000,
        spentAmount: 1500000,
        monthYear: '2026-11',
      );
      expect(b150.status, BudgetStatus.overBudget);
      expect(b150.isOverBudget, isTrue);
      expect(b150.percentage, 150.0);
      // Progress bar is capped at 1.0 (100%) to avoid UI layout overflow
      expect(b150.progressRatio, 1.0);
    });

    // 12. Correct calculations when a category has no expenses
    test('12. Correct calculations when a category has no expenses', () async {
      final budget = BudgetModel(
        id: 'b_zero_spend',
        categoryId: 'cat_shopping',
        limitAmount: 2500000, // PKR 25,000
        monthYear: '2026-11',
      );
      await dbService.insertBudget(budget);

      final retrieved = (await dbService.getBudgetsByMonth('2026-11')).first;
      expect(retrieved.spentAmount, 0);
      expect(retrieved.remainingAmount, 2500000);
      expect(retrieved.percentage, 0.0);
      expect(retrieved.progressRatio, 0.0);
      expect(retrieved.status, BudgetStatus.normal);
      expect(retrieved.isNormal, isTrue);
      expect(retrieved.isOverBudget, isFalse);
    });

    // 13. Keeping different months separate
    test('13. Keeping different months separate', () async {
      // November budget: PKR 20,000
      await dbService.insertBudget(
        const BudgetModel(
          id: 'b_nov',
          categoryId: 'cat_food',
          limitAmount: 2000000,
          monthYear: '2026-11',
        ),
      );

      // December budget: PKR 30,000 for same category
      await dbService.insertBudget(
        const BudgetModel(
          id: 'b_dec',
          categoryId: 'cat_food',
          limitAmount: 3000000,
          monthYear: '2026-12',
        ),
      );

      // November transaction: PKR 5,000
      await dbService.insertTransaction(
        TransactionModel(
          id: 'tx_nov',
          type: TransactionType.expense,
          amount: 500000,
          date: DateTime(2026, 11, 15),
          categoryId: 'cat_food',
        ),
      );

      // Verify November budget
      final novBudgets = await dbService.getBudgetsByMonth('2026-11');
      expect(novBudgets.length, 1);
      expect(novBudgets.first.limitAmount, 2000000);
      expect(novBudgets.first.spentAmount, 500000);
      expect(novBudgets.first.remainingAmount, 1500000);

      // Verify December budget is untouched by November transactions
      final decBudgets = await dbService.getBudgetsByMonth('2026-12');
      expect(decBudgets.length, 1);
      expect(decBudgets.first.limitAmount, 3000000);
      expect(decBudgets.first.spentAmount, 0);
      expect(decBudgets.first.remainingAmount, 3000000);
    });

    // 14. Dashboard budget and transaction calculations
    test('14. Dashboard budget and transaction calculations', () async {
      // Insert monthly budgets for November
      await dbService.insertBudget(
        const BudgetModel(
          id: 'b_food',
          categoryId: 'cat_food',
          limitAmount: 2000000,
          monthYear: '2026-11',
        ),
      );
      await dbService.insertBudget(
        const BudgetModel(
          id: 'b_transport',
          categoryId: 'cat_transport',
          limitAmount: 1000000,
          monthYear: '2026-11',
        ),
      );

      // Total Budget Cap = 20,000 + 10,000 = 30,000 (3,000,000 paisa)
      final totalBudget = await dbService.getTotalBudgetForMonth('2026-11');
      expect(totalBudget, 3000000);

      // Record Income: PKR 100,000
      await dbService.insertTransaction(
        TransactionModel(
          id: 'tx_inc',
          type: TransactionType.income,
          amount: 10000000,
          date: DateTime(2026, 11, 1),
          categoryId: 'cat_salary',
        ),
      );

      // Record Expenses: Food PKR 8,000, Transport PKR 4,000
      await dbService.insertTransaction(
        TransactionModel(
          id: 'tx_exp1',
          type: TransactionType.expense,
          amount: 800000,
          date: DateTime(2026, 11, 3),
          categoryId: 'cat_food',
        ),
      );
      await dbService.insertTransaction(
        TransactionModel(
          id: 'tx_exp2',
          type: TransactionType.expense,
          amount: 400000,
          date: DateTime(2026, 11, 4),
          categoryId: 'cat_transport',
        ),
      );

      final monthlyIncome = await dbService.getMonthlyIncome('2026-11');
      final monthlyExpense = await dbService.getMonthlyExpense('2026-11');
      final totalBalance = await dbService.getTotalBalance();

      expect(monthlyIncome, 10000000);
      expect(monthlyExpense, 1200000);
      expect(totalBalance, 8800000); // 100,000 - 12,000 = 88,000
    });

    // 15. Budget persistence after database reopening
    test('15. Budget persistence after database reopening', () async {
      await dbService.insertBudget(
        const BudgetModel(
          id: 'b_persist',
          categoryId: 'cat_food',
          limitAmount: 4500000, // PKR 45,000
          monthYear: '2026-11',
        ),
      );

      // Close the active database
      await db.close();

      // Reopen the database from the same path
      final reopenedDb = await initTestDb(dbPath);
      final newService = DatabaseService(overrideDb: reopenedDb);

      final retrieved = await newService.getBudgetsByMonth('2026-11');
      expect(retrieved.length, 1);
      expect(retrieved.first.id, 'b_persist');
      expect(retrieved.first.limitAmount, 4500000);
      expect(retrieved.first.formattedLimit, 'PKR 45,000.00');

      await reopenedDb.close();
    });
  });
}

