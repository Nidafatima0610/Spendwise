import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../models/category_model.dart';

/// Data structure representing a single category's spending aggregation.
class CategorySpendingData {
  final CategoryModel category;
  final int totalSpentMinor;
  final double percentageOfTotal;

  const CategorySpendingData({
    required this.category,
    required this.totalSpentMinor,
    required this.percentageOfTotal,
  });
}

/// Category-wise expense distribution visualization widget for Day 4.
/// 
/// Displays proportional horizontal progress bars color-coded by category,
/// sorted by highest spending first, strictly excluding income transactions.
/// Handles zero-expense months safely without division-by-zero errors.
class CategorySpendingVisualization extends StatelessWidget {
  final List<CategorySpendingData> spendingData;
  final int totalExpenseMinor;
  final String monthLabel;
  final ValueChanged<String>? onCategoryTap;

  const CategorySpendingVisualization({
    super.key,
    required this.spendingData,
    required this.totalExpenseMinor,
    required this.monthLabel,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (spendingData.isEmpty || totalExpenseMinor <= 0) {
      return CustomCard(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryUltraLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 26,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.space12),
              Text(
                'No Expenses in $monthLabel',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.space4),
              Text(
                'Expense transactions logged for this month will appear here in a proportional category breakdown.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return CustomCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Total Expense Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryUltraLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Text(
                    'Spending Breakdown',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space8,
                  vertical: AppDimensions.space4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.expenseLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  CurrencyFormatter.formatMinorUnits(totalExpenseMinor),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.expenseDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.space4),
          Text(
            'Proportional share of total expenses for $monthLabel',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11.5,
            ),
          ),

          const SizedBox(height: AppDimensions.space16),

          // Stacked Category Rows
          ...List.generate(spendingData.length, (index) {
            final item = spendingData[index];
            final rank = index + 1;
            final isLast = index == spendingData.length - 1;

            return InkWell(
              onTap: onCategoryTap != null
                  ? () => onCategoryTap!(item.category.id)
                  : null,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.space6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category icon, name, percentage, amount
                    Row(
                      children: [
                        // Rank Badge
                        Container(
                          width: 20,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '#$rank',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),

                        // Category Icon
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: item.category.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          ),
                          child: Icon(
                            item.category.iconData,
                            size: 16,
                            color: item.category.color,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space10),

                        // Category Name
                        Expanded(
                          child: Text(
                            item.category.name,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Percentage Share
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space6,
                            vertical: AppDimensions.space2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          ),
                          child: Text(
                            '${item.percentageOfTotal.toStringAsFixed(1)}%',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),

                        // PKR Amount
                        Text(
                          CurrencyFormatter.formatMinorUnits(item.totalSpentMinor),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.space8),

                    // Proportional Horizontal Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      child: LinearProgressIndicator(
                        value: (item.percentageOfTotal / 100.0).clamp(0.0, 1.0),
                        minHeight: 7,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(item.category.color),
                      ),
                    ),

                    if (!isLast) const SizedBox(height: AppDimensions.space6),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

