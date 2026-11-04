import 'package:flutter/material.dart';
import 'transaction_model.dart';

/// Represents a transaction category in SpendWise (e.g., Food, Salary, Transport).
class CategoryModel {
  final String id;
  final String name;
  final TransactionType type;
  final String iconName;
  final int colorValue;
  final bool isDefault;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.iconName,
    required this.colorValue,
    this.isDefault = true,
  });

  /// Flutter Color representation of [colorValue].
  Color get color => Color(colorValue);

  /// Whether this is an expense category.
  bool get isExpense => type == TransactionType.expense;

  /// Whether this is an income category.
  bool get isIncome => type == TransactionType.income;

  /// Resolves the icon identifier string to an appropriate Material IconData.
  IconData get iconData {
    switch (iconName.toLowerCase()) {
      case 'work':
      case 'salary':
        return Icons.work_rounded;
      case 'laptop':
      case 'freelance':
        return Icons.laptop_mac_rounded;
      case 'investment':
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'restaurant':
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
      case 'car':
        return Icons.directions_car_rounded;
      case 'shopping':
      case 'bag':
        return Icons.shopping_bag_rounded;
      case 'school':
      case 'education':
        return Icons.school_rounded;
      case 'receipt':
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'hospital':
      case 'health':
        return Icons.local_hospital_rounded;
      case 'movie':
      case 'entertainment':
        return Icons.movie_rounded;
      case 'savings':
        return Icons.savings_rounded;
      case 'card_giftcard':
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'fitness':
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'other':
      default:
        return Icons.category_rounded;
    }
  }

  /// Converts this category instance to a Map for SQLite storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'icon_name': iconName,
      'color_value': colorValue,
      'is_default': isDefault ? 1 : 0,
    };
  }

  /// Creates a CategoryModel from a SQLite Map.
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: TransactionType.fromString(map['type'] as String? ?? 'expense'),
      iconName: map['icon_name'] as String? ?? 'other',
      colorValue: map['color_value'] as int? ?? 0xFF6536C7,
      isDefault: (map['is_default'] as int? ?? 1) == 1,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    TransactionType? type,
    String? iconName,
    int? colorValue,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

