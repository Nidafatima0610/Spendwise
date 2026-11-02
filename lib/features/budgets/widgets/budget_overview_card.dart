import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';

/// Top monthly budget aggregate overview card.
class BudgetOverviewCard extends StatelessWidget {
  final int totalCapMinor;
  final int totalSpentMinor;
  final int overBudgetCategoryCount;

  const BudgetOverviewCard({
    super.key,
    required this.totalCapMinor,
    required this.totalSpentMinor,
    this.overBudgetCategoryCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = totalCapMinor > 0
        ? (totalSpentMinor / totalCapMinor).clamp(0.0, 1.0)
        : 0.0;
    final int percentage = (progress * 100).round();
    final int remainingMinor = (totalCapMinor - totalSpentMinor) > 0
        ? (totalCapMinor - totalSpentMinor)
        : 0;

    return CustomCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF5B2CBF),
          Color(0xFF3F198C),
        ],
      ),
      padding: const EdgeInsets.all(AppDimensions.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MONTHLY BUDGET POOL',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space10,
                  vertical: AppDimensions.space4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '$percentage% Allocated',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Text(
            CurrencyFormatter.formatMinorUnits(remainingMinor),
            style: AppTypography.displayMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.space4),
          Text(
            'Remaining to spend safely this month',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Multi-layer progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6EE7B7)),
            ),
          ),
          const SizedBox(height: AppDimensions.space14),

          // Total Cap and Total Spent
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${CurrencyFormatter.formatMinorUnits(totalSpentMinor)}',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Cap: ${CurrencyFormatter.formatMinorUnits(totalCapMinor)}',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
