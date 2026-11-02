import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/preview_banner.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../data/sample_data.dart';
import '../widgets/balance_card.dart';
import '../widgets/income_expense_summary.dart';
import '../widgets/remaining_budget_card.dart';
import '../widgets/category_spend_bar.dart';
import '../widgets/month_selector_pill.dart';
import '../../history/widgets/transaction_list_tile.dart';

/// Screen A: Dashboard
/// Premium home dashboard providing high-level financial overview,
/// current month selector, balance card, income/expense breakdown,
/// category spending preview, and recent transactions preview.
class DashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToHistory;
  final VoidCallback? onNavigateToAddTransaction;
  final VoidCallback? onNavigateToBudgets;

  const DashboardScreen({
    super.key,
    this.onNavigateToHistory,
    this.onNavigateToAddTransaction,
    this.onNavigateToBudgets,
  });

  @override
  Widget build(BuildContext context) {
    final recentTransactions = SampleData.sampleTransactions.take(4).toList();

    // Top spending categories preview items
    final categoryPreviewItems = [
      CategorySpendItem(
        category: SampleData.catBills,
        spentAmountMinor: 1240000,
        percentageOfTotal: 30.1,
      ),
      CategorySpendItem(
        category: SampleData.catFood,
        spentAmountMinor: 1125000,
        percentageOfTotal: 27.3,
      ),
      CategorySpendItem(
        category: SampleData.catShopping,
        spentAmountMinor: 920000,
        percentageOfTotal: 22.4,
      ),
      CategorySpendItem(
        category: SampleData.catTransport,
        spentAmountMinor: 480000,
        percentageOfTotal: 11.7,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
            vertical: AppDimensions.screenPaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Personalized Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.greetingPrefix,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space2),
                      Row(
                        children: [
                          Text(
                            AppStrings.defaultUserName,
                            style: AppTypography.headlineLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space6),
                          const Text('👋', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ],
                  ),
                  // Avatar or Initial Pill
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryUltraLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'AR',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.space16),

              // 2. Month Selector & Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MonthSelectorPill(
                    selectedMonth: 'November 2026',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Month selector: active cycle is November 2026.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space10,
                      vertical: AppDimensions.space6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLavender,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.income,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space6),
                        Text(
                          'PKR Standard',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.space16),

              // 3. Transparent Day 1 Preview Notice
              const PreviewBanner(),

              // 4. Total Balance Card
              BalanceCard(
                balanceMinorUnits: SampleData.currentBalanceMinor,
                monthlySavingsRate: 18.4,
                onAddTap: onNavigateToAddTransaction,
              ),

              const SizedBox(height: AppDimensions.space16),

              // 5. Monthly Income & Expense Summary
              IncomeExpenseSummary(
                incomeMinorUnits: SampleData.totalMonthlyIncomeMinor,
                expenseMinorUnits: SampleData.totalMonthlyExpenseMinor,
                onIncomeTap: onNavigateToHistory,
                onExpenseTap: onNavigateToHistory,
              ),

              const SizedBox(height: AppDimensions.space16),

              // 6. Remaining Budget Overview
              RemainingBudgetCard(
                totalBudgetCapMinor: SampleData.totalMonthlyBudgetCapMinor,
                totalSpentMinor: SampleData.totalMonthlyExpenseMinor,
                onManageBudgetTap: onNavigateToBudgets,
              ),

              // 7. Spending Overview / Category Spending Preview
              SectionHeader(
                title: AppStrings.spendingOverview,
                subtitle: 'Top spending allocations for this month',
                actionText: 'Budgets',
                onAction: onNavigateToBudgets,
              ),
              CategorySpendPreview(items: categoryPreviewItems),

              // 8. Recent Transactions Preview
              SectionHeader(
                title: AppStrings.recentTransactions,
                subtitle: 'Newest activity first',
                actionText: AppStrings.viewAll,
                onAction: onNavigateToHistory,
              ),

              // Transactions List Card
              CustomCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space8,
                  vertical: AppDimensions.space6,
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < recentTransactions.length; i++) ...[
                      TransactionListTile(
                        transaction: recentTransactions[i],
                        category: SampleData.categoryMap[recentTransactions[i].categoryId],
                        onTap: onNavigateToHistory,
                      ),
                      if (i < recentTransactions.length - 1)
                        const Divider(height: 1, indent: 64),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }
}

