import '../core/utils/currency_formatter.dart';

/// Transaction classification: Income or Expense.
enum TransactionType {
  income,
  expense;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TransactionType.expense,
    );
  }
}

/// Core transaction data model representing income or expense entries.
///
/// NOTE: In accordance with fintech precision standards, [amount] is stored
/// strictly as an INTEGER in minor currency units (e.g. 250000 paisas = PKR 2,500.00).
class TransactionModel {
  final String id;
  final TransactionType type;
  /// Amount stored in minor currency units (paisas / cents).
  final int amount;
  final DateTime date;
  final String categoryId;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.note,
  });

  /// Convenience constructor accepting major units (e.g. PKR 2500.50).
  factory TransactionModel.fromMajorUnits({
    required String id,
    required TransactionType type,
    required double majorAmount,
    required DateTime date,
    required String categoryId,
    String? note,
  }) {
    return TransactionModel(
      id: id,
      type: type,
      amount: CurrencyFormatter.toMinorUnits(majorAmount),
      date: date,
      categoryId: categoryId,
      note: note,
    );
  }

  /// Amount in major currency units (e.g., PKR).
  double get amountInMajorUnits => CurrencyFormatter.toMajorUnits(amount);

  /// Formatted currency string (e.g., "PKR 2,500.00").
  String get formattedAmount => CurrencyFormatter.formatMinorUnits(amount);

  /// Signed formatted string (e.g., "+ PKR 2,500.00" or "- PKR 1,200.00").
  String get signedFormattedAmount {
    final prefix = type == TransactionType.income ? '+ ' : '- ';
    return '$prefix$formattedAmount';
  }

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  /// Converts transaction to SQLite Map representation.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'category_id': categoryId,
      'note': note,
    };
  }

  /// Creates a TransactionModel from SQLite Map.
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      type: TransactionType.fromString(map['type'] as String? ?? 'expense'),
      amount: map['amount'] as int? ?? 0,
      date: DateTime.parse(map['date'] as String),
      categoryId: map['category_id'] as String,
      note: map['note'] as String?,
    );
  }

  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    int? amount,
    DateTime? date,
    String? categoryId,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

