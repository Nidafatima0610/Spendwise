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
  final String? monthLabel;

  const BudgetOverviewCard({
    super.key,
    required this.totalCapMinor,
    required this.totalSpentMinor,
    this.overBudgetCategoryCount = 0,
    this.monthLabel,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = totalCapMinor > 0
        ? (totalSpentMinor / totalCapMinor).clamp(0.0, 1.0)
        : 0.0;
    final int percentage = totalCapMinor > 0
        ? ((totalSpentMinor / totalCapMinor) * 100).round()
        : 0;
    final int remainingMinor = totalCapMinor - totalSpentMinor;
    final bool isOver = totalCapMinor > 0 && totalSpentMinor > totalCapMinor;

    String statusBadgeText;
    Color statusBadgeBg;
    if (totalCapMinor <= 0) {
      statusBadgeText = 'No Budget Set';
      statusBadgeBg = Colors.white.withValues(alpha: 0.2);
    } else if (isOver) {
      statusBadgeText = 'Pool Exceeded';
      statusBadgeBg = const Color(0xFFEF4444).withValues(alpha: 0.4);
    } else if (percentage >= 80) {
      statusBadgeText = '$percentage% Near Limit';
      statusBadgeBg = const Color(0xFFF59E0B).withValues(alpha: 0.4);
    } else {
      statusBadgeText = '$percentage% Allocated';
      statusBadgeBg = Colors.white.withValues(alpha: 0.2);
    }

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
                monthLabel != null
                    ? 'MONTHLY BUDGET POOL • ${monthLabel!.toUpperCase()}'
                    : 'MONTHLY BUDGET POOL',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space10,
                  vertical: AppDimensions.space4,
                ),
                decoration: BoxDecoration(
                  color: statusBadgeBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  statusBadgeText,
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
            totalCapMinor <= 0
                ? 'PKR 0.00'
                : (remainingMinor < 0
                    ? '-${CurrencyFormatter.formatMinorUnits(-remainingMinor)}'
                    : CurrencyFormatter.formatMinorUnits(remainingMinor)),
            style: AppTypography.displayMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.space4),
          Text(
            totalCapMinor <= 0
                ? 'No category budgets active for this month'
                : (isOver
                    ? 'Total expenses exceed monthly budget cap'
                    : 'Remaining to spend safely this month'),
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
              valueColor: AlwaysStoppedAnimation<Color>(
                isOver
                    ? const Color(0xFFF87171)
                    : (percentage >= 80 ? const Color(0xFFFBBF24) : const Color(0xFF6EE7B7)),
              ),
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
