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
    final double progress = totalBudgetCapMinor > 0
        ? (totalSpentMinor / totalBudgetCapMinor).clamp(0.0, 1.0)
        : 0.0;
    final int percentage = (progress * 100).round();
    final int remainingMinor = (totalBudgetCapMinor - totalSpentMinor) > 0
        ? (totalBudgetCapMinor - totalSpentMinor)
        : 0;

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
                  color: percentage > 85 ? AppColors.expenseLight : AppColors.primaryUltraLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '$percentage% Spent',
                  style: AppTypography.labelSmall.copyWith(
                    color: percentage > 85 ? AppColors.expenseDark : AppColors.primaryDark,
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
                percentage > 90
                    ? AppColors.expense
                    : (percentage > 75 ? AppColors.warning : AppColors.primary),
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
                    'Remaining',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppDimensions.space2),
                  Text(
                    CurrencyFormatter.formatMinorUnits(remainingMinor),
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
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

