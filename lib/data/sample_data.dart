import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

/// Presentation sample data for Day 1 UI Preview.
/// 
/// TRANSPARENCY NOTICE (Stack & Scale Week 02 Requirement):
/// ---------------------------------------------------------
/// These records are strictly sample presentation fixtures to demonstrate the
/// UI, layout responsiveness, and aesthetic hierarchy before live SQLite CRUD
/// connects in Day 2 & Day 3.
/// They are explicitly isolated from real persisted user records.
class SampleData {
  SampleData._();

  // ================= 1. SAMPLE CATEGORIES =================
  static const CategoryModel catSalary = CategoryModel(
    id: 'cat_salary',
    name: 'Salary',
    type: TransactionType.income,
    iconName: 'salary',
    colorValue: 0xFF10B981, // Emerald
  );

  static const CategoryModel catFreelance = CategoryModel(
    id: 'cat_freelance',
    name: 'Freelance & Projects',
    type: TransactionType.income,
    iconName: 'freelance',
    colorValue: 0xFF059669,
  );

  static const CategoryModel catInvestments = CategoryModel(
    id: 'cat_investments',
    name: 'Investments',
    type: TransactionType.income,
    iconName: 'trending_up',
    colorValue: 0xFF6366F1,
  );

  static const CategoryModel catFood = CategoryModel(
    id: 'cat_food',
    name: 'Food & Dining',
    type: TransactionType.expense,
    iconName: 'food',
    colorValue: 0xFFF59E0B, // Amber
  );

  static const CategoryModel catTransport = CategoryModel(
    id: 'cat_transport',
    name: 'Transportation',
    type: TransactionType.expense,
    iconName: 'transport',
    colorValue: 0xFF3B82F6, // Blue
  );

  static const CategoryModel catShopping = CategoryModel(
    id: 'cat_shopping',
    name: 'Shopping & Gear',
    type: TransactionType.expense,
    iconName: 'shopping',
    colorValue: 0xFFEC4899, // Pink
  );

  static const CategoryModel catEducation = CategoryModel(
    id: 'cat_education',
    name: 'Education & Courses',
    type: TransactionType.expense,
    iconName: 'education',
    colorValue: 0xFF8B5CF6, // Purple
  );

  static const CategoryModel catBills = CategoryModel(
    id: 'cat_bills',
    name: 'Bills & Utilities',
    type: TransactionType.expense,
    iconName: 'bills',
    colorValue: 0xFFEF4444, // Red
  );

  static const CategoryModel catHealthcare = CategoryModel(
    id: 'cat_healthcare',
    name: 'Healthcare',
    type: TransactionType.expense,
    iconName: 'health',
    colorValue: 0xFF14B8A6, // Teal
  );

  static const CategoryModel catEntertainment = CategoryModel(
    id: 'cat_entertainment',
    name: 'Entertainment',
    type: TransactionType.expense,
    iconName: 'entertainment',
    colorValue: 0xFFA855F7,
  );

  static const CategoryModel catOther = CategoryModel(
    id: 'cat_other',
    name: 'Other Expenses',
    type: TransactionType.expense,
    iconName: 'other',
    colorValue: 0xFF6B7280,
  );

  static List<CategoryModel> get categories => [
        catSalary,
        catFreelance,
        catInvestments,
        catFood,
        catTransport,
        catShopping,
        catEducation,
        catBills,
        catHealthcare,
        catEntertainment,
        catOther,
      ];

  static Map<String, CategoryModel> get categoryMap => {
        for (final cat in categories) cat.id: cat,
      };

  // ================= 2. SAMPLE TRANSACTIONS =================
  // Display newest first.
  // Minor units: e.g. 12000000 = PKR 120,000.00
  static List<TransactionModel> get sampleTransactions {
    final now = DateTime.now();

    return [
      TransactionModel(
        id: 'tx_001',
        type: TransactionType.income,
        amount: 12000000, // PKR 120,000.00
        date: DateTime(now.year, now.month, now.day, 9, 30),
        categoryId: catSalary.id,
        note: 'Monthly salary from Tech Studio',
      ),
      TransactionModel(
        id: 'tx_002',
        type: TransactionType.expense,
        amount: 850000, // PKR 8,500.00
        date: DateTime(now.year, now.month, now.day, 13, 15),
        categoryId: catFood.id,
        note: 'Weekly grocery restock at Hyperstar',
      ),
      TransactionModel(
        id: 'tx_003',
        type: TransactionType.expense,
        amount: 480000, // PKR 4,800.00
        date: DateTime(now.year, now.month, now.day - 1, 18, 45),
        categoryId: catTransport.id,
        note: 'Fuel refill and Uber commute',
      ),
      TransactionModel(
        id: 'tx_004',
        type: TransactionType.income,
        amount: 3500000, // PKR 35,000.00
        date: DateTime(now.year, now.month, now.day - 2, 11, 20),
        categoryId: catFreelance.id,
        note: 'Milestone 2 payment: Flutter dashboard UI',
      ),
      TransactionModel(
        id: 'tx_005',
        type: TransactionType.expense,
        amount: 1240000, // PKR 12,400.00
        date: DateTime(now.year, now.month, now.day - 3, 10, 00),
        categoryId: catBills.id,
        note: 'Fiber internet & electricity bills',
      ),
      TransactionModel(
        id: 'tx_006',
        type: TransactionType.expense,
        amount: 920000, // PKR 9,200.00
        date: DateTime(now.year, now.month, now.day - 4, 16, 30),
        categoryId: catShopping.id,
        note: 'Ergonomic keyboard & desk gear',
      ),
      TransactionModel(
        id: 'tx_007',
        type: TransactionType.expense,
        amount: 350000, // PKR 3,500.00
        date: DateTime(now.year, now.month, now.day - 5, 14, 10),
        categoryId: catEducation.id,
        note: 'Advanced Dart & Architecture eBook',
      ),
      TransactionModel(
        id: 'tx_008',
        type: TransactionType.expense,
        amount: 275000, // PKR 2,750.00
        date: DateTime(now.year, now.month, now.day - 6, 20, 15),
        categoryId: catFood.id,
        note: 'Team dinner & coffee meetup',
      ),
    ];
  }

  // ================= 3. SAMPLE BUDGETS =================
  // Prepared for Day 3 Budget screen & Dashboard remaining budget overview
  static List<BudgetModel> get sampleBudgets {
    const monthKey = '2026-11';
    return [
      const BudgetModel(
        id: 'bgt_food',
        categoryId: 'cat_food',
        limitAmount: 1800000, // Limit: PKR 18,000.00
        spentAmount: 1125000, // Spent: PKR 11,250.00 (62.5% On Track)
        monthYear: monthKey,
      ),
      const BudgetModel(
        id: 'bgt_bills',
        categoryId: 'cat_bills',
        limitAmount: 1500000, // Limit: PKR 15,000.00
        spentAmount: 1240000, // Spent: PKR 12,400.00 (82.6% Near Limit)
        monthYear: monthKey,
      ),
      const BudgetModel(
        id: 'bgt_shopping',
        categoryId: 'cat_shopping',
        limitAmount: 800000,  // Limit: PKR 8,000.00
        spentAmount: 920000,  // Spent: PKR 9,200.00 (115% OVER BUDGET!)
        monthYear: monthKey,
      ),
      const BudgetModel(
        id: 'bgt_transport',
        categoryId: 'cat_transport',
        limitAmount: 800000,  // Limit: PKR 8,000.00
        spentAmount: 480000,  // Spent: PKR 4,800.00 (60% On Track)
        monthYear: monthKey,
      ),
      const BudgetModel(
        id: 'bgt_education',
        categoryId: 'cat_education',
        limitAmount: 1000000, // Limit: PKR 10,000.00
        spentAmount: 350000,  // Spent: PKR 3,500.00 (35% On Track)
        monthYear: monthKey,
      ),
    ];
  }

  // ================= 4. AGGREGATE CALCULATIONS =================
  /// Total sample monthly income in minor currency units (PKR 155,000.00).
  static int get totalMonthlyIncomeMinor => 15500000;

  /// Total sample monthly expenses in minor currency units (PKR 41,150.00).
  static int get totalMonthlyExpenseMinor => 4115000;

  /// Net balance in minor currency units (PKR 143,850.00 including starting reserve).
  static int get currentBalanceMinor => 14385000;

  /// Overall monthly budget ceiling in minor currency units (PKR 59,000.00).
  static int get totalMonthlyBudgetCapMinor => 5900000;

  /// Remaining monthly budget in minor currency units (PKR 17,850.00).
  static int get remainingBudgetMinor => 1785000;
}

