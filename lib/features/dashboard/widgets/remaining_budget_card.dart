import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';

/// Card displaying the monthly budget cap, spent amount, and remaining budget progress.
class RemainingBudgetCard extends StatelessWidget {
  final int totalBudgetCapMinor;
  final int totalSpentMinor;
  final VoidCallback? onManageBudgetTap;

  const RemainingBudgetCard({
    super.key,
    required this.totalBudgetCapMinor,
    required this.totalSpentMinor,
    this.onManageBudgetTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasBudget = totalBudgetCapMinor > 0;
    final double progress = hasBudget
        ? (totalSpentMinor / totalBudgetCapMinor).clamp(0.0, 1.0)
        : 0.0;
    final int percentage = hasBudget
        ? ((totalSpentMinor / totalBudgetCapMinor) * 100).round()
        : 0;
    final int remainingMinor = totalBudgetCapMinor - totalSpentMinor;
    final bool isOver = hasBudget && totalSpentMinor > totalBudgetCapMinor;

    String badgeLabel;
    Color badgeColor;
    Color badgeTextColor;

    if (!hasBudget) {
      badgeLabel = 'No Budget Set';
      badgeColor = AppColors.surfaceVariant;
      badgeTextColor = AppColors.textSecondary;
    } else if (isOver) {
      badgeLabel = 'Over Budget';
      badgeColor = AppColors.expenseLight;
      badgeTextColor = AppColors.expenseDark;
    } else if (percentage >= 80) {
      badgeLabel = '$percentage% Near Limit';
      badgeColor = AppColors.warningLight;
      badgeTextColor = AppColors.warning;
    } else {
      badgeLabel = '$percentage% Spent';
      badgeColor = AppColors.primaryUltraLight;
      badgeTextColor = AppColors.primaryDark;
    }

    return CustomCard(
      onTap: onManageBudgetTap,
      padding: const EdgeInsets.all(AppDimensions.space18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      Icons.pie_chart_outline_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Text(
                    'Monthly Budget Goal',
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
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  badgeLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: badgeTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOver
                    ? AppColors.expense
                    : (percentage >= 80 ? AppColors.warning : AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space14),

          // Spent & Remaining breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOver ? 'Exceeded' : 'Remaining',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppDimensions.space2),
                  Text(
                    !hasBudget
                        ? 'PKR 0.00'
                        : (isOver
                            ? '-${CurrencyFormatter.formatMinorUnits(-remainingMinor)}'
                            : CurrencyFormatter.formatMinorUnits(remainingMinor)),
                    style: AppTypography.titleMedium.copyWith(
                      color: isOver ? AppColors.expenseDark : AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Budget Cap',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppDimensions.space2),
                  Text(
                    CurrencyFormatter.formatMinorUnits(totalBudgetCapMinor),
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
