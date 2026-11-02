/// Database table names, column names, and SQL schema queries for SpendWise.
class DatabaseConstants {
  DatabaseConstants._();

  static const String databaseName = 'spend_wise.db';
  static const int databaseVersion = 1;

  // Table Names
  static const String tableCategories = 'categories';
  static const String tableTransactions = 'transactions';
  static const String tableBudgets = 'budgets';

  // Categories Columns
  static const String colCatId = 'id';
  static const String colCatName = 'name';
  static const String colCatType = 'type';
  static const String colCatIconName = 'icon_name';
  static const String colCatColorValue = 'color_value';
  static const String colCatIsDefault = 'is_default';

  // Transactions Columns
  static const String colTxId = 'id';
  static const String colTxType = 'type';
  static const String colTxAmount = 'amount'; // Integer in minor units
  static const String colTxDate = 'date';     // ISO-8601 string
  static const String colTxCategoryId = 'category_id';
  static const String colTxNote = 'note';

  // Budgets Columns (Prepared for Day 3)
  static const String colBudgetId = 'id';
  static const String colBudgetCategoryId = 'category_id';
  static const String colBudgetLimit = 'limit_amount'; // Integer in minor units
  static const String colBudgetMonthYear = 'month_year'; // YYYY-MM

  // DDL Queries
  static const String createCategoriesTable = '''
    CREATE TABLE $tableCategories (
      $colCatId TEXT PRIMARY KEY,
      $colCatName TEXT NOT NULL,
      $colCatType TEXT NOT NULL,
      $colCatIconName TEXT NOT NULL,
      $colCatColorValue INTEGER NOT NULL,
      $colCatIsDefault INTEGER NOT NULL DEFAULT 1
    );
  ''';

  static const String createTransactionsTable = '''
    CREATE TABLE $tableTransactions (
      $colTxId TEXT PRIMARY KEY,
      $colTxType TEXT NOT NULL,
      $colTxAmount INTEGER NOT NULL,
      $colTxDate TEXT NOT NULL,
      $colTxCategoryId TEXT NOT NULL,
      $colTxNote TEXT,
      FOREIGN KEY ($colTxCategoryId) REFERENCES $tableCategories ($colCatId) ON DELETE CASCADE
    );
  ''';

  static const String createBudgetsTable = '''
    CREATE TABLE $tableBudgets (
      $colBudgetId TEXT PRIMARY KEY,
      $colBudgetCategoryId TEXT NOT NULL,
      $colBudgetLimit INTEGER NOT NULL,
      $colBudgetMonthYear TEXT NOT NULL,
      FOREIGN KEY ($colBudgetCategoryId) REFERENCES $tableCategories ($colCatId) ON DELETE CASCADE
    );
  ''';

  // Indexes for high performance querying
  static const String createTransactionsDateIndex = '''
    CREATE INDEX idx_transactions_date ON $tableTransactions ($colTxDate DESC);
  ''';

  static const String createTransactionsCategoryIndex = '''
    CREATE INDEX idx_transactions_category ON $tableTransactions ($colTxCategoryId);
  ''';
}

