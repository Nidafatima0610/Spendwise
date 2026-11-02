import 'package:sqflite/sqflite.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import 'app_database.dart';
import 'database_constants.dart';

/// Database service repository providing CRUD operations for SpendWise.
/// 
/// DAY 1 SCOPE:
/// Database initialization, schema setup, categories seeding, and helper methods
/// are implemented and tested today. Live transaction persistence connects
/// via UI state in Day 2.
class DatabaseService {
  final AppDatabase _appDatabase;

  DatabaseService({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db async => await _appDatabase.database;

  /// Verifies SQLite database connection and table readiness.
  Future<bool> testConnection() async {
    try {
      final db = await _db;
      final result = await db.rawQuery('SELECT 1');
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ================= CATEGORIES =================

  /// Retrieves all seeded or user-defined categories.
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await _db;
    final maps = await db.query(
      DatabaseConstants.tableCategories,
      orderBy: '${DatabaseConstants.colCatName} ASC',
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  /// Retrieves categories filtered by transaction type (income or expense).
  Future<List<CategoryModel>> getCategoriesByType(TransactionType type) async {
    final db = await _db;
    final maps = await db.query(
      DatabaseConstants.tableCategories,
      where: '${DatabaseConstants.colCatType} = ?',
      whereArgs: [type.name],
      orderBy: '${DatabaseConstants.colCatName} ASC',
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  /// Retrieves a specific category by ID.
  Future<CategoryModel?> getCategoryById(String id) async {
    final db = await _db;
    final maps = await db.query(
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
    final db = await _db;
    return await db.insert(
      DatabaseConstants.tableCategories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns total number of categories in SQLite.
  Future<int> getCategoryCount() async {
    final db = await _db;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseConstants.tableCategories}'),
    );
    return count ?? 0;
  }

  // ================= TRANSACTIONS (Prepared for Day 2) =================

  /// Retrieves all saved transactions sorted newest first.
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await _db;
    final maps = await db.query(
      DatabaseConstants.tableTransactions,
      orderBy: '${DatabaseConstants.colTxDate} DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Inserts a transaction into SQLite.
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await _db;
    return await db.insert(
      DatabaseConstants.tableTransactions,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Deletes a transaction by ID.
  Future<int> deleteTransaction(String id) async {
    final db = await _db;
    return await db.delete(
      DatabaseConstants.tableTransactions,
      where: '${DatabaseConstants.colTxId} = ?',
      whereArgs: [id],
    );
  }

  /// Returns count of persisted transactions.
  Future<int> getTransactionCount() async {
    final db = await _db;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseConstants.tableTransactions}'),
    );
    return count ?? 0;
  }
}

