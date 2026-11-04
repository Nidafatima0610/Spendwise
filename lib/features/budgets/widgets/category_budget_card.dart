import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/controllers/transaction_controller.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../models/budget_model.dart';
import '../../../models/category_model.dart';

/// Card displaying spending status, progress, and alerts for an individual category budget.
class CategoryBudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final CategoryModel? category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryBudgetCard({
    super.key,
    required this.budget,
    this.category,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final CategoryModel cat = category ??
        TransactionController.instance.getCategory(budget.categoryId);
    final bool isOver = budget.isOverBudget;
    final bool isWarn = budget.isWarning;
    final double percentage = budget.percentage;

    // Determine status badge colors and label
    Color statusColor;
    String statusText;
    Color progressColor;
    Color badgeBg;

    if (isOver) {
      statusColor = AppColors.expenseDark;
      statusText = 'OVER BUDGET';
      progressColor = AppColors.expense;
      badgeBg = AppColors.expenseLight;
    } else if (isWarn) {
      statusColor = AppColors.warning;
      statusText = 'NEAR LIMIT';
      progressColor = AppColors.warning;
      badgeBg = AppColors.warningLight;
    } else {
      statusColor = AppColors.incomeDark;
      statusText = 'ON TRACK';
      progressColor = cat.color;
      badgeBg = AppColors.incomeLight;
    }

    return CustomCard(
      onTap: onTap ?? onEdit,
      border: isOver
          ? Border.all(color: AppColors.expense.withValues(alpha: 0.4), width: 1.5)
          : (isWarn
              ? Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1.0)
              : null),
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon, Name & Status Badge & Actions Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      child: Icon(
                        cat.iconData,
                        color: cat.color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.name,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppDimensions.space2),
                          Text(
                            'Limit: ${budget.formattedLimit}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space8,
                  vertical: AppDimensions.space4,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isOver) ...[
                      const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.expenseDark),
                      const SizedBox(width: AppDimensions.space4),
                    ] else if (isWarn) ...[
                      const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.warning),
                      const SizedBox(width: AppDimensions.space4),
                    ],
                    Text(
                      statusText,
                      style: AppTypography.labelSmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions Menu
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  key: Key('budget_menu_${budget.id}'),
                  icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  onSelected: (action) {
                    if (action == 'edit') {
                      onEdit?.call();
                    } else if (action == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                          SizedBox(width: AppDimensions.space8),
                          Text('Edit Limit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.expense),
                          SizedBox(width: AppDimensions.space8),
                          Text('Delete Budget', style: TextStyle(color: AppColors.expense)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: AppDimensions.space14),

          // Progress Bar (capped visually at 100%)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: budget.progressRatio,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),

          const SizedBox(height: AppDimensions.space12),

          // Footer: Spent vs Remaining or Exceeded Amount
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
