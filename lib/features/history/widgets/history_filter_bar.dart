import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';
import '../../../models/category_model.dart';

/// Interactive filter bar for the Transaction History screen.
/// Supports Month navigation, Category chips, Type filters, and View switching.
class HistoryFilterBar extends StatelessWidget {
  final List<String> monthFilters;
  final String selectedMonth;
  final ValueChanged<String> onMonthSelected;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;

  final List<String> typeFilters;
  final String selectedType;
  final ValueChanged<String> onTypeSelected;

  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  final bool isBreakdownView;
  final ValueChanged<bool>? onToggleView;

  const HistoryFilterBar({
    super.key,
    required this.monthFilters,
    required this.selectedMonth,
    required this.onMonthSelected,
    this.onPrevMonth,
    this.onNextMonth,
    required this.typeFilters,
    required this.selectedType,
    required this.onTypeSelected,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.isBreakdownView = false,
    this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAllMonths = selectedMonth == 'All Months';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Month Navigation Strip
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space6,
            vertical: AppDimensions.space4,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                key: const Key('history_prev_month'),
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
                onPressed: onPrevMonth,
                tooltip: 'Previous Month',
                visualDensity: VisualDensity.compact,
              ),

              InkWell(
                onTap: () {
                  // If All Months is currently selected, switch to first specific month or vice versa
                  if (isAllMonths && monthFilters.length > 1) {
                    onMonthSelected(monthFilters[1]);
                  } else {
                    onMonthSelected('All Months');
                  }
                },
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space10,
                    vertical: AppDimensions.space4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppDimensions.space6),
                      Text(
                        selectedMonth,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isAllMonths) ...[
                        const SizedBox(width: AppDimensions.space4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryUltraLight,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Text(
                            'All Time',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              IconButton(
                key: const Key('history_next_month'),
                icon: const Icon(Icons.chevron_right_rounded, size: 22),
                onPressed: onNextMonth,
                tooltip: 'Next Month',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.space8),

        // 2. View Mode Switcher & Month Pills Row
        Row(
          children: [
            // View Mode Segmented Pill
            if (onToggleView != null) ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewTab(
                      key: const Key('view_mode_transactions'),
                      icon: Icons.list_alt_rounded,
                      label: 'List',
                      isSelected: !isBreakdownView,
                      onTap: () => onToggleView!(false),
                    ),
                    _buildViewTab(
                      key: const Key('view_mode_breakdown'),
                      icon: Icons.pie_chart_rounded,
                      label: 'Breakdown',
                      isSelected: isBreakdownView,
                      onTap: () => onToggleView!(true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
            ],

            // Horizontal Month Pills
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: monthFilters.map((month) {
                    final isSelected = month == selectedMonth;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppDimensions.space6),
                      child: ChoiceChip(
                        key: Key('history_month_pill_${month.replaceAll(" ", "_")}'),
                        selected: isSelected,
                        label: Text(month),
                        labelStyle: AppTypography.labelSmall.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 11,
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
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.space8),

        // 3. Category & Type Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // "All Categories" chip
              Padding(
                padding: const EdgeInsets.only(right: AppDimensions.space8),
                child: ChoiceChip(
                  key: const Key('history_cat_all'),
                  selected: selectedCategoryId == null,
                  avatar: const Icon(
                    Icons.dashboard_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  label: const Text('All Categories'),
                  labelStyle: AppTypography.labelSmall.copyWith(
                    color: selectedCategoryId == null ? Colors.white : AppColors.textPrimary,
                    fontWeight: selectedCategoryId == null ? FontWeight.w700 : FontWeight.w500,
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    side: BorderSide(
                      color: selectedCategoryId == null ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                  ),
                  onSelected: (_) => onCategorySelected(null),
                ),
              ),

              // Individual Category Chips
              ...categories.map((cat) {
                final isSelected = selectedCategoryId == cat.id;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.space8),
                  child: FilterChip(
                    key: Key('history_cat_${cat.id}'),
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

              // Type filters divider & chips
              const SizedBox(width: AppDimensions.space4),
              Container(width: 1, height: 24, color: AppColors.border),
              const SizedBox(width: AppDimensions.space8),

              ...typeFilters.map((type) {
                final isSelected = selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.space6),
                  child: ChoiceChip(
                    key: Key('history_type_${type.replaceAll(" ", "_")}'),
                    selected: isSelected,
                    label: Text(type),
                    labelStyle: AppTypography.labelSmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 11,
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
                    onSelected: (_) => onTypeSelected(type),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewTab({
    required Key key,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
