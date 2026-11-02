import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';
import '../../../models/category_model.dart';

/// Interactive filter bar for the Transaction History screen.
/// Supports filtering by Month and by Category / Type.
class HistoryFilterBar extends StatelessWidget {
  final List<String> monthFilters;
  final String selectedMonth;
  final ValueChanged<String> onMonthSelected;

  final List<String> typeFilters;
  final String selectedType;
  final ValueChanged<String> onTypeSelected;

  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  const HistoryFilterBar({
    super.key,
    required this.monthFilters,
    required this.selectedMonth,
    required this.onMonthSelected,
    required this.typeFilters,
    required this.selectedType,
    required this.onTypeSelected,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: monthFilters.map((month) {
              final isSelected = month == selectedMonth;
              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.space8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(month),
                  labelStyle: AppTypography.labelSmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                  ),
                  onSelected: (_) => onMonthSelected(month),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: AppDimensions.space10),

        // Type / Category Filter Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // All / Income / Expense Filter chips
              ...typeFilters.map((type) {
                final isSelected = selectedCategoryId == null && type == selectedType;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.space8),
                  child: ChoiceChip(
                    selected: isSelected,
                    label: Text(type),
                    labelStyle: AppTypography.labelSmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    selectedColor: AppColors.primaryLight,
                    backgroundColor: AppColors.surfaceLavender,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryLight : AppColors.border,
                        width: 1,
                      ),
                    ),
                    onSelected: (_) {
                      onCategorySelected(null);
                      onTypeSelected(type);
                    },
                  ),
                );
              }),

              // Category specific chips
              ...categories.take(6).map((cat) {
                final isSelected = selectedCategoryId == cat.id;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.space8),
                  child: FilterChip(
                    selected: isSelected,
                    avatar: Icon(
                      cat.iconData,
                      size: 14,
                      color: isSelected ? Colors.white : cat.color,
                    ),
                    label: Text(cat.name),
                    labelStyle: AppTypography.labelSmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 1,
                      ),
                    ),
                    onSelected: (_) {
                      onCategorySelected(isSelected ? null : cat.id);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

