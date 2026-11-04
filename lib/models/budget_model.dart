import '../core/utils/currency_formatter.dart';

/// Status classification for a monthly category budget according to Stack & Scale rules.
enum BudgetStatus {
  /// Spending is under 80% of the allocated budget limit.
  normal,

  /// Spending is 80% or higher, but below 100% of the budget limit.
  warning,

  /// Spending has reached or exceeded 100% of the budget limit.
  overBudget,
}

/// Data model representing a monthly budget limit for a specific category.
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

  /// Spending progress ratio between 0.0 and 1.0 (clamped for progress bars).
  double get progressRatio {
    if (limitAmount <= 0) return 0.0;
    return (spentAmount / limitAmount).clamp(0.0, 1.0);
  }

  /// Exact progress percentage (can exceed 100% if over budget).
  double get percentage {
    if (limitAmount <= 0) return 0.0;
    return (spentAmount / limitAmount) * 100.0;
  }

  /// Evaluates the budget status based on the exact spending ratio:
  /// - Under 80%: [BudgetStatus.normal]
  /// - 80% to below 100%: [BudgetStatus.warning]
  /// - 100% or above: [BudgetStatus.overBudget]
  BudgetStatus get status {
    if (limitAmount <= 0) {
      return spentAmount > 0 ? BudgetStatus.overBudget : BudgetStatus.normal;
    }
    final ratio = spentAmount / limitAmount;
    if (ratio >= 1.0) return BudgetStatus.overBudget;
    if (ratio >= 0.8) return BudgetStatus.warning;
    return BudgetStatus.normal;
  }

  bool get isNormal => status == BudgetStatus.normal;
  bool get isWarning => status == BudgetStatus.warning;
  bool get isOverBudget => status == BudgetStatus.overBudget;

  /// Remaining budget amount in minor currency units:
  /// Remaining Budget = Budget Amount - Actual Expense.
  /// Yields a negative number when spending exceeds the budget cap.
  int get remainingAmount => limitAmount - spentAmount;

  /// Amount by which the budget was exceeded in minor units.
  int get overBudgetAmount => spentAmount > limitAmount ? (spentAmount - limitAmount) : 0;

  String get formattedLimit => CurrencyFormatter.formatMinorUnits(limitAmount);
  String get formattedSpent => CurrencyFormatter.formatMinorUnits(spentAmount);

  /// Formatted remaining budget string.
  /// If negative (e.g. -2,000 PKR), correctly formats with leading minus sign: "-PKR 2,000.00".
  String get formattedRemaining {
    if (remainingAmount < 0) {
      return '-${CurrencyFormatter.formatMinorUnits(-remainingAmount)}';
    }
    return CurrencyFormatter.formatMinorUnits(remainingAmount);
  }

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

