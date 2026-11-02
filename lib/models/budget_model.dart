import '../core/utils/currency_formatter.dart';

/// Data model representing a monthly budget limit for a specific category.
/// Prepares SpendWise for full budget management in Day 3.
class BudgetModel {
  final String id;
  final String categoryId;
  /// Maximum budget limit in minor currency units (paisas).
  final int limitAmount;
  /// Current amount spent in minor currency units (paisas).
  final int spentAmount;
  /// Target month in 'YYYY-MM' format (e.g. '2026-11').
  final String monthYear;

  const BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    this.spentAmount = 0,
    required this.monthYear,
  });

  /// Spending progress ratio between 0.0 and 1.0 (clamped).
  double get progressRatio {
    if (limitAmount <= 0) return 0.0;
    return (spentAmount / limitAmount).clamp(0.0, 1.0);
  }

  /// Exact progress percentage (can exceed 100% if over budget).
  double get percentage {
    if (limitAmount <= 0) return 0.0;
    return (spentAmount / limitAmount) * 100.0;
  }

  /// Whether the user has exceeded their budget limit.
  bool get isOverBudget => spentAmount > limitAmount;

  /// Remaining budget amount in minor currency units.
  /// If over budget, this returns 0.
  int get remainingAmount => (limitAmount - spentAmount) > 0 ? (limitAmount - spentAmount) : 0;

  /// Amount by which the budget was exceeded in minor units.
  int get overBudgetAmount => isOverBudget ? (spentAmount - limitAmount) : 0;

  String get formattedLimit => CurrencyFormatter.formatMinorUnits(limitAmount);
  String get formattedSpent => CurrencyFormatter.formatMinorUnits(spentAmount);
  String get formattedRemaining => CurrencyFormatter.formatMinorUnits(remainingAmount);
  String get formattedOverBudget => CurrencyFormatter.formatMinorUnits(overBudgetAmount);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'limit_amount': limitAmount,
      'month_year': monthYear,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map, {int currentSpent = 0}) {
    return BudgetModel(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      limitAmount: map['limit_amount'] as int? ?? 0,
      spentAmount: currentSpent,
      monthYear: map['month_year'] as String,
    );
  }

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    int? limitAmount,
    int? spentAmount,
    String? monthYear,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      monthYear: monthYear ?? this.monthYear,
    );
  }
}

