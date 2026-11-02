import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:spend_wise/core/database/database_constants.dart';
import 'package:spend_wise/models/transaction_model.dart';

void main() {
  // Initialize sqflite ffi for in-memory or local testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
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

        // Seed sample category
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

        await batch.commit(noResult: true);
      },
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('SQLite Schema & CRUD Unit Tests', () {
    test('Verifies Categories and Transactions schema and constraints', () async {
      // 1. Verify category exists
      final categories = await db.query(DatabaseConstants.tableCategories);
      expect(categories.length, 1);
      expect(categories.first['name'], 'Food & Dining');

      // 2. Insert transaction linked to category
      final tx = TransactionModel(
        id: 'tx_unit_1',
        type: TransactionType.expense,
        amount: 550000, // PKR 5,500.00 in minor units
        date: DateTime(2026, 11, 2, 14, 0),
        categoryId: 'cat_food',
        note: 'Grocery bill',
      );

      final insertResult = await db.insert(
        DatabaseConstants.tableTransactions,
        tx.toMap(),
      );
      expect(insertResult, isPositive);

      // 3. Query back transaction
      final txRows = await db.query(
        DatabaseConstants.tableTransactions,
        where: '${DatabaseConstants.colTxId} = ?',
        whereArgs: ['tx_unit_1'],
      );
      expect(txRows.length, 1);
      final retrievedTx = TransactionModel.fromMap(txRows.first);
      expect(retrievedTx.amount, 550000);
      expect(retrievedTx.amountInMajorUnits, 5500.0);
      expect(retrievedTx.note, 'Grocery bill');
    });

    test('Enforces foreign key constraint between transactions and categories', () async {
      // Attempt to insert a transaction with non-existent category
      final invalidTx = TransactionModel(
        id: 'tx_invalid',
        type: TransactionType.expense,
        amount: 100000,
        date: DateTime.now(),
        categoryId: 'cat_non_existent',
      );

      expect(
        () async => await db.insert(
          DatabaseConstants.tableTransactions,
          invalidTx.toMap(),
        ),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
