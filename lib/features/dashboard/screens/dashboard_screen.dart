import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/controllers/transaction_controller.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../models/transaction_model.dart';
import '../widgets/balance_card.dart';
import '../widgets/income_expense_summary.dart';
import '../widgets/remaining_budget_card.dart';
import '../widgets/category_spend_bar.dart';
import '../widgets/month_selector_pill.dart';
import '../../history/widgets/transaction_list_tile.dart';
import '../../transactions/screens/add_transaction_screen.dart';

/// Screen A: Dashboard
/// 
/// Real-time financial dashboard driven by local SQLite transactions.
/// Features dynamic balance calculations, current month income/expenses,
/// live category spending breakdown, and newest transactions feed.
class DashboardScreen extends StatefulWidget {
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
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TransactionController _controller = TransactionController.instance;

  Future<void> _openEditTransaction(TransactionModel transaction) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          transactionToEdit: transaction,
        ),
      ),
    );

    if (result == true && mounted) {
      await _controller.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final recentTransactions = _controller.recentTransactions;
        final categorySpending = _controller.categorySpending;
        final bool hasAnyTransactions = _controller.hasTransactions;

        // Current Month Formatted Label
        final currentMonthLabel =
            DateFormatter.formatMonthYear(DateTime.now());

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => _controller.refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
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
                        // Avatar Initials Badge
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

                    // 2. Month Selector & Regional Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MonthSelectorPill(
                          selectedMonth: currentMonthLabel,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Active cycle is $currentMonthLabel.'),
                                duration: const Duration(seconds: 2),
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
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusFull),
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

                    // 3. Status Notice: Live SQLite Active
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: AppDimensions.space16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space14,
                        vertical: AppDimensions.space10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryUltraLight,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.space6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.storage_rounded,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LOCAL SQLITE STORAGE ACTIVE',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space2),
                                Text(
                                  hasAnyTransactions
                                      ? 'Displaying real-time records from your offline database.'
                                      : 'No saved transactions yet. Tap Add to record your first entry.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 4. Real Total Balance Card
                    BalanceCard(
                      balanceMinorUnits: _controller.totalBalanceMinor,
                      monthlySavingsRate: _calculateSavingsRate(
                        _controller.monthlyIncomeMinor,
                        _controller.monthlyExpenseMinor,
                      ),
                      onAddTap: widget.onNavigateToAddTransaction,
                    ),

                    const SizedBox(height: AppDimensions.space16),

                    // 5. Monthly Income & Expense Summary (Real Data)
                    IncomeExpenseSummary(
                      incomeMinorUnits: _controller.monthlyIncomeMinor,
                      expenseMinorUnits: _controller.monthlyExpenseMinor,
                      onIncomeTap: widget.onNavigateToHistory,
                      onExpenseTap: widget.onNavigateToHistory,
                    ),

                    const SizedBox(height: AppDimensions.space16),

                    // 6. Remaining Budget Overview (Connected to real monthly budget and expenses)
                    RemainingBudgetCard(
                      totalBudgetCapMinor: _controller.monthlyBudgetCapMinor,
                      totalSpentMinor: _controller.monthlyExpenseMinor,
                      onManageBudgetTap: widget.onNavigateToBudgets,
                    ),

                    // 7. Spending Overview / Category Spending Breakdown
                    SectionHeader(
                      title: AppStrings.spendingOverview,
                      subtitle: 'Real category allocations for $currentMonthLabel',
                      actionText: 'Budgets',
                      onAction: widget.onNavigateToBudgets,
                    ),

                    if (categorySpending.isEmpty)
                      CustomCard(
                        padding: const EdgeInsets.all(AppDimensions.space20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.pie_chart_outline_rounded,
                                size: 36,
                                color: AppColors.primary.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: AppDimensions.space10),
                              Text(
                                'No Expense Activity This Month',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space4),
                              Text(
                                'Record your expenses to see a live visual breakdown here.',
                                style: AppTypography.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      CategorySpendPreview(items: categorySpending),

                    // 8. Recent Transactions Preview (Real SQLite Transactions)
                    SectionHeader(
                      title: AppStrings.recentTransactions,
                      subtitle: hasAnyTransactions
                          ? 'Newest saved transactions first'
                          : 'No recorded activity',
                      actionText: hasAnyTransactions ? AppStrings.viewAll : null,
                      onAction: widget.onNavigateToHistory,
                    ),

                    if (!hasAnyTransactions)
                      CustomCard(
                        padding: const EdgeInsets.all(AppDimensions.space20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_rounded,
                                size: 36,
                                color: AppColors.primary.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: AppDimensions.space10),
                              Text(
                                'No Transactions Recorded',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space6),
                              Text(
                                'Tap the + button below to log your first income or expense.',
                                style: AppTypography.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.space14),
                              OutlinedButton.icon(
                                onPressed: widget.onNavigateToAddTransaction,
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Add Transaction'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
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
                                category: _controller
                                    .getCategory(recentTransactions[i].categoryId),
                                onTap: () =>
                                    _openEditTransaction(recentTransactions[i]),
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
          ),
        );
      },
    );
  }

  double _calculateSavingsRate(int incomeMinor, int expenseMinor) {
    if (incomeMinor <= 0) return 0.0;
    final int netSavings = incomeMinor - expenseMinor;
    if (netSavings <= 0) return 0.0;
    return (netSavings / incomeMinor) * 100.0;
  }
}
