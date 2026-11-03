import 'package:sqflite/sqflite.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import 'app_database.dart';
import 'database_constants.dart';

/// Database service repository providing complete CRUD operations for SpendWise.
/// 
/// DAY 2 SCOPE:
/// - Full transaction CRUD (Insert, Read, Update, Delete).
/// - Parameterized queries for security and reliability.
/// - Filtering by type, category, date/month.
/// - Integer minor-unit aggregations for Dashboard financial summaries.
class DatabaseService {
  final AppDatabase _appDatabase;
  final Database? overrideDb;

  DatabaseService({AppDatabase? appDatabase, this.overrideDb})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get db async => overrideDb ?? await _appDatabase.database;

  /// Verifies SQLite database connection and table readiness.
  Future<bool> testConnection() async {
    try {
      final activeDb = await db;
      final result = await activeDb.rawQuery('SELECT 1');
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ================= CATEGORIES =================

  /// Retrieves all seeded or user-defined categories.
  Future<List<CategoryModel>> getAllCategories() async {
    final activeDb = await db;
    final maps = await activeDb.query(
      DatabaseConstants.tableCategories,
      orderBy: '${DatabaseConstants.colCatName} ASC',
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  /// Retrieves categories filtered by transaction type (income or expense).
  Future<List<CategoryModel>> getCategoriesByType(TransactionType type) async {
    final activeDb = await db;
    final maps = await activeDb.query(
      DatabaseConstants.tableCategories,
      where: '${DatabaseConstants.colCatType} = ?',
      whereArgs: [type.name],
      orderBy: '${DatabaseConstants.colCatName} ASC',
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  /// Retrieves a specific category by ID.
  Future<CategoryModel?> getCategoryById(String id) async {
    final activeDb = await db;
    final maps = await activeDb.query(
      DatabaseConstants.tableCategories,
      where: '${DatabaseConstants.colCatId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first);
  }

  /// Inserts a new category.
  Future<int> insertCategory(CategoryModel category) async {
    final activeDb = await db;
    return await activeDb.insert(
      DatabaseConstants.tableCategories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns total number of categories in SQLite.
  Future<int> getCategoryCount() async {
    final activeDb = await db;
    final count = Sqflite.firstIntValue(
      await activeDb.rawQuery('SELECT COUNT(*) FROM ${DatabaseConstants.tableCategories}'),
    );
    return count ?? 0;
  }

  // ================= TRANSACTIONS (CRUD) =================

  /// Inserts a new transaction into SQLite.
  Future<int> insertTransaction(TransactionModel transaction) async {
    final activeDb = await db;
    return await activeDb.insert(
      DatabaseConstants.tableTransactions,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all saved transactions sorted newest first.
  Future<List<TransactionModel>> getAllTransactions() async {
    final activeDb = await db;
    final maps = await activeDb.query(
      DatabaseConstants.tableTransactions,
      orderBy: '${DatabaseConstants.colTxDate} DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Retrieves a single transaction by its unique ID.
  Future<TransactionModel?> getTransactionById(String id) async {
    final activeDb = await db;
    final maps = await activeDb.query(
      DatabaseConstants.tableTransactions,
      where: '${DatabaseConstants.colTxId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TransactionModel.fromMap(maps.first);
  }

  /// Retrieves transactions filtered by type (income or expense), newest first.
  Future<List<TransactionModel>> getTransactionsByType(TransactionType type) async {
    final activeDb = await db;
    final maps = await activeDb.query(
      DatabaseConstants.tableTransactions,
      where: '${DatabaseConstants.colTxType} = ?',
      whereArgs: [type.name],
      orderBy: '${DatabaseConstants.colTxDate} DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Retrieves transactions filtered by category ID, newest first.
  Future<List<TransactionModel>> getTransactionsByCategory(String categoryId) async {
    final activeDb = await db;
    final maps = await activeDb.query(
      DatabaseConstants.tableTransactions,
      where: '${DatabaseConstants.colTxCategoryId} = ?',
      whereArgs: [categoryId],
      orderBy: '${DatabaseConstants.colTxDate} DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Retrieves transactions for a specific month (e.g. '2026-11'), newest first.
  Future<List<TransactionModel>> getTransactionsByMonth(String monthYear) async {
    final activeDb = await db;
    final maps = await activeDb.query(
      DatabaseConstants.tableTransactions,
      where: '${DatabaseConstants.colTxDate} LIKE ?',
      whereArgs: ['$monthYear%'],
      orderBy: '${DatabaseConstants.colTxDate} DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Updates an existing transaction in SQLite.
  /// Returns the number of rows affected (should be 1).
  Future<int> updateTransaction(TransactionModel transaction) async {
    final activeDb = await db;
    return await activeDb.update(
      DatabaseConstants.tableTransactions,
      transaction.toMap(),
      where: '${DatabaseConstants.colTxId} = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Deletes a transaction by ID.
  /// Returns the number of rows affected.
  Future<int> deleteTransaction(String id) async {
    final activeDb = await db;
    return await activeDb.delete(
      DatabaseConstants.tableTransactions,
      where: '${DatabaseConstants.colTxId} = ?',
      whereArgs: [id],
    );
  }

  /// Returns total count of persisted transactions.
  Future<int> getTransactionCount() async {
    final activeDb = await db;
    final count = Sqflite.firstIntValue(
      await activeDb.rawQuery('SELECT COUNT(*) FROM ${DatabaseConstants.tableTransactions}'),
    );
    return count ?? 0;
  }

  // ================= AGGREGATIONS & DASHBOARD CALCULATIONS =================

  /// Calculates total income for a specific month in minor currency units (paisas).
  Future<int> getMonthlyIncome(String monthYear) async {
    final activeDb = await db;
    final result = await activeDb.rawQuery(
      'SELECT COALESCE(SUM(${DatabaseConstants.colTxAmount}), 0) as total '
      'FROM ${DatabaseConstants.tableTransactions} '
      'WHERE ${DatabaseConstants.colTxType} = ? AND ${DatabaseConstants.colTxDate} LIKE ?',
      [TransactionType.income.name, '$monthYear%'],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  /// Calculates total expenses for a specific month in minor currency units (paisas).
  Future<int> getMonthlyExpense(String monthYear) async {
    final activeDb = await db;
    final result = await activeDb.rawQuery(
      'SELECT COALESCE(SUM(${DatabaseConstants.colTxAmount}), 0) as total '
      'FROM ${DatabaseConstants.tableTransactions} '
      'WHERE ${DatabaseConstants.colTxType} = ? AND ${DatabaseConstants.colTxDate} LIKE ?',
      [TransactionType.expense.name, '$monthYear%'],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  /// Calculates current net balance across all recorded transactions in minor units.
  /// Balance = Total All-Time Income - Total All-Time Expenses.
  Future<int> getTotalBalance() async {
    final activeDb = await db;
    final incomeResult = await activeDb.rawQuery(
      'SELECT COALESCE(SUM(${DatabaseConstants.colTxAmount}), 0) as total '
      'FROM ${DatabaseConstants.tableTransactions} '
      'WHERE ${DatabaseConstants.colTxType} = ?',
      [TransactionType.income.name],
    );
    final expenseResult = await activeDb.rawQuery(
      'SELECT COALESCE(SUM(${DatabaseConstants.colTxAmount}), 0) as total '
      'FROM ${DatabaseConstants.tableTransactions} '
      'WHERE ${DatabaseConstants.colTxType} = ?',
      [TransactionType.expense.name],
    );

    final int totalIncome = (incomeResult.first['total'] as int?) ?? 0;
    final int totalExpense = (expenseResult.first['total'] as int?) ?? 0;

    return totalIncome - totalExpense;
  }

  /// Computes category-wise expense totals for a specific month, ordered by highest spend first.
  /// Returns a list of maps containing 'category_id' and 'total_spent'.
  Future<List<Map<String, dynamic>>> getCategorySpending(String monthYear) async {
    final activeDb = await db;
    final result = await activeDb.rawQuery(
      'SELECT ${DatabaseConstants.colTxCategoryId} as category_id, '
      'SUM(${DatabaseConstants.colTxAmount}) as total_spent '
      'FROM ${DatabaseConstants.tableTransactions} '
      'WHERE ${DatabaseConstants.colTxType} = ? AND ${DatabaseConstants.colTxDate} LIKE ? '
      'GROUP BY ${DatabaseConstants.colTxCategoryId} '
      'ORDER BY total_spent DESC',
      [TransactionType.expense.name, '$monthYear%'],
    );
    return result;
  }

  /// Deletes all transactions. Useful for testing or account reset.
  Future<int> clearAllTransactions() async {
    final activeDb = await db;
    return await activeDb.delete(DatabaseConstants.tableTransactions);
  }
}
