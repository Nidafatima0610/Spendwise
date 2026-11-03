import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:spend_wise/core/database/database_constants.dart';
import 'package:spend_wise/core/database/database_service.dart';
import 'package:spend_wise/models/transaction_model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late String dbPath;
  late DatabaseService dbService;

  setUp(() async {
    final randomId = Random().nextInt(1000000);
    dbPath = 'spend_wise_test_${DateTime.now().microsecondsSinceEpoch}_$randomId.db';

    db = await openDatabase(
      dbPath,
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

        // Seed income & expense categories
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

        await batch.commit(noResult: true);
      },
    );

    dbService = DatabaseService(overrideDb: db);
  });

  tearDown(() async {
    await db.close();
    await deleteDatabase(dbPath);
  });

  group('Day 2 SQLite Operations & Aggregations', () {
    test('Valid income and expense creation and retrieval', () async {
      final incomeTx = TransactionModel(
        id: 'tx_income_1',
        type: TransactionType.income,
        amount: 8500000, // PKR 85,000.00
        date: DateTime(2026, 11, 2, 9, 30),
        categoryId: 'cat_salary',
        note: 'Monthly salary payout',
      );

      final expenseTx = TransactionModel(
        id: 'tx_expense_1',
        type: TransactionType.expense,
        amount: 320000, // PKR 3,200.00
        date: DateTime(2026, 11, 2, 13, 0),
        categoryId: 'cat_food',
        note: 'Team buffet',
      );

      // Insert both
      final res1 = await dbService.insertTransaction(incomeTx);
      final res2 = await dbService.insertTransaction(expenseTx);
      expect(res1, isPositive);
      expect(res2, isPositive);

      // Verify count
      expect(await dbService.getTransactionCount(), 2);

      // Retrieve by ID
      final retrievedIncome = await dbService.getTransactionById('tx_income_1');
      expect(retrievedIncome, isNotNull);
      expect(retrievedIncome!.amount, 8500000);
      expect(retrievedIncome.amountInMajorUnits, 85000.0);
      expect(retrievedIncome.isIncome, isTrue);

      final retrievedExpense = await dbService.getTransactionById('tx_expense_1');
      expect(retrievedExpense, isNotNull);
      expect(retrievedExpense!.amount, 320000);
      expect(retrievedExpense.isExpense, isTrue);
    });

    test('Newest-first ordering across multiple transactions', () async {
      final txOlder = TransactionModel(
        id: 'tx_old',
        type: TransactionType.expense,
        amount: 100000,
        date: DateTime(2026, 10, 15, 10, 0),
        categoryId: 'cat_food',
        note: 'Older October meal',
      );

      final txMiddle = TransactionModel(
        id: 'tx_mid',
        type: TransactionType.income,
        amount: 200000,
        date: DateTime(2026, 11, 1, 10, 0),
        categoryId: 'cat_salary',
        note: 'Yesterday payment',
      );

      final txNewest = TransactionModel(
        id: 'tx_new',
        type: TransactionType.expense,
        amount: 300000,
        date: DateTime(2026, 11, 2, 15, 0),
        categoryId: 'cat_food',
        note: 'Latest transaction today',
      );

      await dbService.insertTransaction(txOlder);
      await dbService.insertTransaction(txMiddle);
      await dbService.insertTransaction(txNewest);

      final all = await dbService.getAllTransactions();
      expect(all.length, 3);
      expect(all[0].id, 'tx_new');
      expect(all[1].id, 'tx_mid');
      expect(all[2].id, 'tx_old');
    });

    test('Transaction editing updates the existing SQLite record without duplicating', () async {
      final initialTx = TransactionModel(
        id: 'tx_edit_test',
        type: TransactionType.expense,
        amount: 150000, // PKR 1,500.00
        date: DateTime(2026, 11, 2, 10, 0),
        categoryId: 'cat_food',
        note: 'Original lunch',
      );
      await dbService.insertTransaction(initialTx);
      expect(await dbService.getTransactionCount(), 1);

      // Edit amount and note
      final editedTx = initialTx.copyWith(
        amount: 220000, // PKR 2,200.00
        note: 'Updated team lunch with dessert',
      );
      final rowsAffected = await dbService.updateTransaction(editedTx);
      expect(rowsAffected, 1);

      // Verify count is still 1 (no duplicate created)
      expect(await dbService.getTransactionCount(), 1);

      // Verify values updated in DB
      final updated = await dbService.getTransactionById('tx_edit_test');
      expect(updated!.amount, 220000);
      expect(updated.amountInMajorUnits, 2200.0);
      expect(updated.note, 'Updated team lunch with dessert');
    });

    test('Transaction deletion removes record from SQLite', () async {
      final tx = TransactionModel(
        id: 'tx_delete_me',
        type: TransactionType.expense,
        amount: 50000,
        date: DateTime(2026, 11, 2),
        categoryId: 'cat_food',
      );
      await dbService.insertTransaction(tx);
      expect(await dbService.getTransactionCount(), 1);

      final deletedRows = await dbService.deleteTransaction('tx_delete_me');
      expect(deletedRows, 1);
      expect(await dbService.getTransactionCount(), 0);

      final queryResult = await dbService.getTransactionById('tx_delete_me');
      expect(queryResult, isNull);
    });

    test('Dashboard aggregations (Monthly Income, Monthly Expense, Net Balance)', () async {
      // 1. November Income: 100,000 PKR (10,000,000 paisas)
      await dbService.insertTransaction(
        TransactionModel(
          id: 'nov_inc_1',
          type: TransactionType.income,
          amount: 10000000,
          date: DateTime(2026, 11, 1, 9, 0),
          categoryId: 'cat_salary',
        ),
      );

      // 2. November Expense: 15,000 PKR (1,500,000 paisas)
      await dbService.insertTransaction(
        TransactionModel(
          id: 'nov_exp_1',
          type: TransactionType.expense,
          amount: 1500000,
          date: DateTime(2026, 11, 2, 12, 0),
          categoryId: 'cat_food',
        ),
      );

      // 3. November Expense: 5,000 PKR (500,000 paisas)
      await dbService.insertTransaction(
        TransactionModel(
          id: 'nov_exp_2',
          type: TransactionType.expense,
          amount: 500000,
          date: DateTime(2026, 11, 2, 14, 0),
          categoryId: 'cat_transport',
        ),
      );

      // 4. October Expense: 8,000 PKR (800,000 paisas) - should NOT count in November
      await dbService.insertTransaction(
        TransactionModel(
          id: 'oct_exp_1',
          type: TransactionType.expense,
          amount: 800000,
          date: DateTime(2026, 10, 20, 14, 0),
          categoryId: 'cat_food',
        ),
      );

      // Check November aggregates
      final novIncome = await dbService.getMonthlyIncome('2026-11');
      expect(novIncome, 10000000); // 100,000.00 PKR

      final novExpense = await dbService.getMonthlyExpense('2026-11');
      expect(novExpense, 2000000); // 15,000 + 5,000 = 20,000.00 PKR

      // Total Net Balance: All Income (100k) - All Expense (20k + 8k) = 72k PKR
      final totalBalance = await dbService.getTotalBalance();
      expect(totalBalance, 7200000); // 72,000.00 PKR

      // Category spending breakdown for November
      final spending = await dbService.getCategorySpending('2026-11');
      expect(spending.length, 2);
      expect(spending[0]['category_id'], 'cat_food');
      expect(spending[0]['total_spent'], 1500000);
      expect(spending[1]['category_id'], 'cat_transport');
      expect(spending[1]['total_spent'], 500000);
    });

    test('Enforces foreign key constraint with categories', () async {
      final invalidTx = TransactionModel(
        id: 'invalid_tx',
        type: TransactionType.expense,
        amount: 100000,
        date: DateTime.now(),
        categoryId: 'non_existent_category',
      );

      expect(
        () async => await dbService.insertTransaction(invalidTx),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
