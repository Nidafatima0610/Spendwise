import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/metric_card.dart';

/// Side-by-side summary row presenting total monthly income and expenses.
class IncomeExpenseSummary extends StatelessWidget {
  final int incomeMinorUnits;
  final int expenseMinorUnits;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpenseTap;

  const IncomeExpenseSummary({
    super.key,
    required this.incomeMinorUnits,
    required this.expenseMinorUnits,
    this.onIncomeTap,
    this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MetricCard(
          title: AppStrings.monthlyIncome,
          amount: CurrencyFormatter.formatMinorUnits(incomeMinorUnits),
          icon: Icons.arrow_downward_rounded,
          accentColor: AppColors.incomeDark,
          backgroundColor: AppColors.incomeLight,
          subtitle: 'Active',
          onTap: onIncomeTap,
        ),
        const SizedBox(width: AppDimensions.space12),
        MetricCard(
          title: AppStrings.monthlyExpenses,
          amount: CurrencyFormatter.formatMinorUnits(expenseMinorUnits),
          icon: Icons.arrow_upward_rounded,
          accentColor: AppColors.expenseDark,
          backgroundColor: AppColors.expenseLight,
          subtitle: 'Tracked',
          onTap: onExpenseTap,
        ),
      ],
    );
  }
}

