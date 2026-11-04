import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database_constants.dart';

/// SQLite Database Singleton manager for SpendWise.
/// 
/// ARCHITECTURAL LIFECYCLE:
/// ------------------------
/// - Enforces single open connection across the app lifecycle.
/// - Handles desktop FFI initialization (Windows, Linux, macOS, unit tests).
/// - Enforces SQLite foreign keys via PRAGMA foreign_keys = ON.
/// - Seeds initial default categories inside a database transaction during [onCreate].
/// - Upgrade-ready architecture via [onUpgrade] callback.
class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  /// Returns active Database instance, initializing if necessary.
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for Windows/Desktop or Test runners
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String dbPath = await getDatabasesPath();
    final String fullPath = p.join(dbPath, DatabaseConstants.databaseName);

    return await openDatabase(
      fullPath,
      version: DatabaseConstants.databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  /// Enables foreign key constraints on the SQLite connection.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  /// Ensures tables and indexes are ready on open.
  Future<void> _onOpen(Database db) async {
    await db.execute(
      DatabaseConstants.createBudgetsTable.replaceAll('CREATE TABLE', 'CREATE TABLE IF NOT EXISTS'),
    );
    await db.execute(DatabaseConstants.createBudgetsCategoryMonthIndex);
  }

  /// Creates schema tables, indexes, and pre-seeds default categories.
  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // 1. Create Tables
    batch.execute(DatabaseConstants.createCategoriesTable);
    batch.execute(DatabaseConstants.createTransactionsTable);
    batch.execute(DatabaseConstants.createBudgetsTable);

    // 2. Create Indexes
    batch.execute(DatabaseConstants.createTransactionsDateIndex);
    batch.execute(DatabaseConstants.createTransactionsCategoryIndex);
    batch.execute(DatabaseConstants.createBudgetsCategoryMonthIndex);

    // 3. Pre-seed Default Categories into SQLite
    _seedDefaultCategories(batch);

    await batch.commit(noResult: true);
  }

  /// Seed initial categories so the database is populated from the first run.
  void _seedDefaultCategories(Batch batch) {
    final defaultCategories = [
      // Income Categories
      {
        DatabaseConstants.colCatId: 'cat_salary',
        DatabaseConstants.colCatName: 'Salary',
        DatabaseConstants.colCatType: 'income',
        DatabaseConstants.colCatIconName: 'salary',
        DatabaseConstants.colCatColorValue: 0xFF10B981,
        DatabaseConstants.colCatIsDefault: 1,
      },
      {
        DatabaseConstants.colCatId: 'cat_freelance',
        DatabaseConstants.colCatName: 'Freelance & Projects',
        DatabaseConstants.colCatType: 'income',
        DatabaseConstants.colCatIconName: 'freelance',
        DatabaseConstants.colCatColorValue: 0xFF059669,
        DatabaseConstants.colCatIsDefault: 1,
      },
      {
        DatabaseConstants.colCatId: 'cat_investments',
        DatabaseConstants.colCatName: 'Investments',
        DatabaseConstants.colCatType: 'income',
        DatabaseConstants.colCatIconName: 'trending_up',
        DatabaseConstants.colCatColorValue: 0xFF6366F1,
        DatabaseConstants.colCatIsDefault: 1,
      },

      // Expense Categories
      {
        DatabaseConstants.colCatId: 'cat_food',
        DatabaseConstants.colCatName: 'Food & Dining',
        DatabaseConstants.colCatType: 'expense',
        DatabaseConstants.colCatIconName: 'food',
        DatabaseConstants.colCatColorValue: 0xFFF59E0B,
        DatabaseConstants.colCatIsDefault: 1,
      },
      {
        DatabaseConstants.colCatId: 'cat_transport',
        DatabaseConstants.colCatName: 'Transportation',
        DatabaseConstants.colCatType: 'expense',
        DatabaseConstants.colCatIconName: 'transport',
        DatabaseConstants.colCatColorValue: 0xFF3B82F6,
        DatabaseConstants.colCatIsDefault: 1,
      },
      {
        DatabaseConstants.colCatId: 'cat_shopping',
        DatabaseConstants.colCatName: 'Shopping',
        DatabaseConstants.colCatType: 'expense',
        DatabaseConstants.colCatIconName: 'shopping',
        DatabaseConstants.colCatColorValue: 0xFFEC4899,
        DatabaseConstants.colCatIsDefault: 1,
      },
      {
        DatabaseConstants.colCatId: 'cat_education',
        DatabaseConstants.colCatName: 'Education',
        DatabaseConstants.colCatType: 'expense',
        DatabaseConstants.colCatIconName: 'education',
        DatabaseConstants.colCatColorValue: 0xFF8B5CF6,
        DatabaseConstants.colCatIsDefault: 1,
      },
      {
        DatabaseConstants.colCatId: 'cat_bills',
        DatabaseConstants.colCatName: 'Bills & Utilities',
        DatabaseConstants.colCatType: 'expense',
        DatabaseConstants.colCatIconName: 'bills',
        DatabaseConstants.colCatColorValue: 0xFFEF4444,
        DatabaseConstants.colCatIsDefault: 1,
      },
      {
        DatabaseConstants.colCatId: 'cat_healthcare',
        DatabaseConstants.colCatName: 'Healthcare',
        DatabaseConstants.colCatType: 'expense',
        DatabaseConstants.colCatIconName: 'health',
        DatabaseConstants.colCatColorValue: 0xFF14B8A6,
        DatabaseConstants.colCatIsDefault: 1,
      },
      {
        DatabaseConstants.colCatId: 'cat_entertainment',
        DatabaseConstants.colCatName: 'Entertainment',
        DatabaseConstants.colCatType: 'expense',
        DatabaseConstants.colCatIconName: 'entertainment',
        DatabaseConstants.colCatColorValue: 0xFFA855F7,
        DatabaseConstants.colCatIsDefault: 1,
      },
      {
        DatabaseConstants.colCatId: 'cat_other',
        DatabaseConstants.colCatName: 'Other Expenses',
        DatabaseConstants.colCatType: 'expense',
        DatabaseConstants.colCatIconName: 'other',
        DatabaseConstants.colCatColorValue: 0xFF6B7280,
        DatabaseConstants.colCatIsDefault: 1,
      },
    ];

    for (final category in defaultCategories) {
      batch.insert(
        DatabaseConstants.tableCategories,
        category,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Upgrade migration handler for future iterations (Day 2-5).
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future database schema migrations will be handled here incrementally
  }

  /// Closes database connection safely.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
