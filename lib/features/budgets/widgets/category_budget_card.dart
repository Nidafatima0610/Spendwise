import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../models/budget_model.dart';
import '../../../models/category_model.dart';
import '../../../data/sample_data.dart';

/// Card displaying spending status, progress, and alerts for an individual category budget.
class CategoryBudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback? onTap;

  const CategoryBudgetCard({
    super.key,
    required this.budget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final CategoryModel category = SampleData.categoryMap[budget.categoryId] ?? SampleData.catOther;
    final bool isOver = budget.isOverBudget;
    final double percentage = budget.percentage;

    // Determine status badge colors
    Color statusColor;
    String statusText;
    Color progressColor;

    if (isOver) {
      statusColor = AppColors.expense;
      statusText = 'OVER BUDGET';
      progressColor = AppColors.expense;
    } else if (percentage >= 80) {
      statusColor = AppColors.warning;
      statusText = 'NEAR LIMIT';
      progressColor = AppColors.warning;
    } else {
      statusColor = AppColors.incomeDark;
      statusText = 'ON TRACK';
      progressColor = category.color;
    }

    return CustomCard(
      onTap: onTap,
      border: isOver ? Border.all(color: AppColors.expenseLight, width: 1.5) : null,
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon, Name & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                    child: Icon(
                      category.iconData,
                      color: category.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space2),
                      Text(
                        'Limit: ${budget.formattedLimit}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space8,
                  vertical: AppDimensions.space4,
                ),
                decoration: BoxDecoration(
                  color: isOver ? AppColors.expenseLight : (percentage >= 80 ? AppColors.warningLight : AppColors.incomeLight),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isOver) ...[
                      const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.expenseDark),
                      const SizedBox(width: AppDimensions.space4),
                    ],
                    Text(
                      statusText,
                      style: AppTypography.labelSmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.space14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: budget.progressRatio,
              minHeight: 7,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),

          const SizedBox(height: AppDimensions.space12),

          // Footer: Spent vs Remaining or Over Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${budget.formattedSpent} (${percentage.toStringAsFixed(0)}%)',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                isOver
                    ? 'Exceeded by ${budget.formattedOverBudget}'
                    : '${budget.formattedRemaining} left',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isOver ? AppColors.expenseDark : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
