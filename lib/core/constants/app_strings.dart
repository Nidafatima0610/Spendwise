/// Static text strings and constants used across the SpendWise app.
class AppStrings {
  AppStrings._();

  // App Meta
  static const String appName = 'SpendWise';
  static const String appTagline = 'Personal Budget & Expense Tracker';
  static const String appVersion = 'v1.0.0 (Production Release)';

  // Currency Configuration (Centralized)
  /// Default currency code. Configured to PKR as required by Stack & Scale Week 02.
  /// Can be switched globally here to USD, EUR, GBP, etc.
  static const String defaultCurrencyCode = 'PKR';
  static const String defaultCurrencySymbol = 'Rs.';
  static const String currencyName = 'Pakistani Rupee';

  // Navigation Items
  static const String navDashboard = 'Home';
  static const String navHistory = 'History';
  static const String navAdd = 'Add';
  static const String navBudgets = 'Budgets';
  static const String navSettings = 'Settings';

  // Dashboard
  static const String greetingPrefix = 'Welcome back,';
  static const String defaultUserName = 'Alex Rivera';
  static const String totalBalance = 'Total Balance';
  static const String monthlyIncome = 'Total Income';
  static const String monthlyExpenses = 'Total Expenses';
  static const String monthlyBudget = 'Monthly Budget';
  static const String spendingOverview = 'Spending Breakdown';
  static const String recentTransactions = 'Recent Transactions';
  static const String viewAll = 'View All';
  static const String previewNotice = 'Preview Mode • Sample Presentation Data (Day 1)';

  // Add Transaction
  static const String addTransactionTitle = 'New Transaction';
  static const String expense = 'Expense';
  static const String income = 'Income';
  static const String amountLabel = 'Amount';
  static const String categoryLabel = 'Category';
  static const String dateLabel = 'Transaction Date';
  static const String noteLabel = 'Notes & Description';
  static const String noteHint = 'e.g. Lunch with team, Groceries, Client milestone';
  static const String saveTransaction = 'Record Transaction';
  static const String resetFields = 'Reset Form';

  // History
  static const String historyTitle = 'Transaction History';
  static const String filterAll = 'All';
  static const String noTransactionsFound = 'No transactions found';
  static const String noTransactionsDesc = 'Try tweaking your filters or add a new transaction.';

  // Budgets
  static const String budgetsTitle = 'Budget Planner';
  static const String budgetRemaining = 'Remaining';
  static const String budgetSpent = 'Spent';
  static const String budgetOverBudget = 'Over Budget!';
  static const String budgetOnTrack = 'On Track';
  static const String budgetAddPlaceholder = 'Create New Budget';
  static const String budgetNotice = 'Category budget creation and limit editing will be unlocked in Day 3.';

  // Settings
  static const String settingsTitle = 'Preferences & About';
  static const String profileSection = 'Fintech Profile';
  static const String currencySection = 'Currency & Regional';
  static const String databaseSection = 'Local Storage & SQLite';
  static const String aboutSection = 'About SpendWise';
}

