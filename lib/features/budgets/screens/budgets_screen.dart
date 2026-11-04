import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/controllers/budget_controller.dart';
import '../../../core/controllers/transaction_controller.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../models/budget_model.dart';
import '../widgets/budget_form_sheet.dart';
import '../widgets/budget_overview_card.dart';
import '../widgets/category_budget_card.dart';

/// Screen D: Budgets Screen
/// Real-time monthly budget manager featuring SQLite persistence,
/// category spending caps, progress bars, threshold warning states,
/// and complete Add/Edit/Delete capabilities.
class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final BudgetController _budgetController = BudgetController.instance;
  final TransactionController _txController = TransactionController.instance;

  @override
  void initState() {
    super.initState();
    _budgetController.loadBudgets();
  }

  void _prevMonth() {
    final current = DateFormatter.parseMonthYearKey(_budgetController.selectedMonthYear);
    final prev = DateTime(current.year, current.month - 1);
    _budgetController.setMonth(DateFormatter.toMonthYearKey(prev));
  }

  void _nextMonth() {
    final current = DateFormatter.parseMonthYearKey(_budgetController.selectedMonthYear);
    final next = DateTime(current.year, current.month + 1);
    _budgetController.setMonth(DateFormatter.toMonthYearKey(next));
  }

  Future<void> _openAddBudget(BuildContext context) async {
    await BudgetFormSheet.show(
      context,
      initialMonthYear: _budgetController.selectedMonthYear,
    );
  }

  Future<void> _openEditBudget(BuildContext context, BudgetModel budget) async {
    await BudgetFormSheet.show(
      context,
      budgetToEdit: budget,
      initialMonthYear: _budgetController.selectedMonthYear,
    );
  }

  void _showDeleteConfirmation(BuildContext context, BudgetModel budget) {
    final category = _txController.getCategory(budget.categoryId);
    final monthLabel = DateFormatter.formatMonthYearKey(budget.monthYear);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('delete_budget_dialog'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space8),
              decoration: BoxDecoration(
                color: AppColors.expenseLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.expenseDark,
                size: 22,
              ),
            ),
            const SizedBox(width: AppDimensions.space10),
            const Text('Delete Budget?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the spending cap for ${category.name} in $monthLabel? Recorded transactions will remain untouched.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await _budgetController.deleteBudget(budget.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Budget for ${category.name} removed.'),
                    backgroundColor: AppColors.expenseDark,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _budgetController,
      builder: (context, _) {
        final budgets = _budgetController.budgets;
        final monthLabel = DateFormatter.formatMonthYearKey(_budgetController.selectedMonthYear);
        final overBudgetItems = budgets.where((b) => b.isOverBudget).toList();
        final warningItems = budgets.where((b) => b.isWarning).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(AppStrings.budgetsTitle),
            actions: [
              IconButton(
                key: const Key('add_budget_appbar_button'),
                icon: const Icon(Icons.add_circle_outline_rounded),
                tooltip: 'Add Budget Limit',
                onPressed: () => _openAddBudget(context),
              ),
              const SizedBox(width: AppDimensions.space8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('fab_add_budget'),
            onPressed: () => _openAddBudget(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Budget',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => _budgetController.refresh(),
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
                    // Month Navigator Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space10,
                        vertical: AppDimensions.space4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            key: const Key('prev_month_budget_button'),
                            icon: const Icon(Icons.chevron_left_rounded, size: 22),
                            onPressed: _prevMonth,
                            tooltip: 'Previous Month',
                            visualDensity: VisualDensity.compact,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppDimensions.space6),
                              Text(
                                monthLabel,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            key: const Key('next_month_budget_button'),
                            icon: const Icon(Icons.chevron_right_rounded, size: 22),
                            onPressed: _nextMonth,
                            tooltip: 'Next Month',
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.space16),

                    // 1. Overall Monthly Budget Pool Card
                    BudgetOverviewCard(
                      totalCapMinor: _budgetController.totalBudgetCapMinor,
                      totalSpentMinor: _budgetController.totalBudgetSpentMinor,
                      overBudgetCategoryCount: overBudgetItems.length,
                      monthLabel: monthLabel,
                    ),

                    const SizedBox(height: AppDimensions.space16),

                    // 2. Over Budget Warning Notice (if any category exceeded 100%)
                    if (overBudgetItems.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.space14),
                        decoration: BoxDecoration(
                          color: AppColors.expenseLight,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(
                            color: AppColors.expense.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppDimensions.space6),
                              decoration: BoxDecoration(
                                color: AppColors.expense.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.expenseDark,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Attention: ${overBudgetItems.length} ${overBudgetItems.length == 1 ? 'Category' : 'Categories'} Exceeded',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.expenseDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: AppDimensions.space2),
                                  Text(
                                    '${_txController.getCategory(overBudgetItems.first.categoryId).name} is ${overBudgetItems.first.percentage.toStringAsFixed(0)}% of limit (exceeded by ${overBudgetItems.first.formattedOverBudget}).',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.expenseDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),
                    ] else if (warningItems.isNotEmpty) ...[
                      // Warning state when categories are between 80% and 99%
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.space14),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppDimensions.space6),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.warning,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Caution: ${warningItems.length} ${warningItems.length == 1 ? 'Category' : 'Categories'} Near Limit',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: AppDimensions.space2),
                                  Text(
                                    '${_txController.getCategory(warningItems.first.categoryId).name} has reached ${warningItems.first.percentage.toStringAsFixed(0)}% of its spending limit.',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),
                    ],

                    // 3. Category Budgets Header
                    SectionHeader(
                      title: 'Category Allocations',
                      subtitle: '${budgets.length} active spending caps for $monthLabel',
                      actionText: 'Add Budget',
                      onAction: () => _openAddBudget(context),
                    ),

                    // 4. Category Budget Cards List or Empty State
                    if (budgets.isEmpty)
                      CustomCard(
                        padding: const EdgeInsets.all(AppDimensions.space24),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryUltraLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.pie_chart_outline_rounded,
                                  size: 28,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space14),
                              Text(
                                'No Budgets Set for $monthLabel',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space6),
                              Text(
                                'Establish monthly limits for categories like Food, Transport, and Shopping to track quota progress in real-time.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.45,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.space18),
                              OutlinedButton.icon(
                                key: const Key('empty_state_add_budget_button'),
                                onPressed: () => _openAddBudget(context),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Create First Budget'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppDimensions.radiusMedium),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...budgets.map((budget) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.space12),
                          child: CategoryBudgetCard(
                            budget: budget,
                            onEdit: () => _openEditBudget(context, budget),
                            onDelete: () => _showDeleteConfirmation(context, budget),
                          ),
                        );
                      }),

                    const SizedBox(height: AppDimensions.space16),

                    // 5. Educational Card explaining Category Budgets
                    CustomCard(
                      backgroundColor: AppColors.surfaceLavender,
                      border: Border.all(color: AppColors.border, width: 1),
                      padding: const EdgeInsets.all(AppDimensions.space18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppDimensions.space6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(AppDimensions.radiusSmall),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.space10),
                              Text(
                                'How Category Budgets Work',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.space8),
                          Text(
                            'SpendWise lets you assign individual spending caps to each category. '
                            'Whenever you log an expense, the app recalculates your remaining quota in real time, '
                            'alerting you before you overspend. Progress bars stay capped at 100% while accurately tracking overspending.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80), // Extra space for FAB and navigation bar
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
