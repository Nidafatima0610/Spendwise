import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/preview_banner.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/sample_data.dart';
import '../widgets/budget_overview_card.dart';
import '../widgets/category_budget_card.dart';

/// Screen D: Budgets Screen
/// Monthly budget manager showing category limits, progress bars,
/// over-budget visual indicators, and educational empty states for Day 3.
class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  void _showAddBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space8),
              decoration: BoxDecoration(
                color: AppColors.primaryUltraLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pie_chart_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.space10),
            const Text('Day 3 Milestone'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Budget Creation & Editing',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              'Dynamic category budget limits, threshold alerts, and editable monthly caps are scheduled for Day 3 of the Stack & Scale internship roadmap.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgets = SampleData.sampleBudgets;
    final overBudgetItems = budgets.where((b) => b.isOverBudget).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.budgetsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: AppStrings.budgetAddPlaceholder,
            onPressed: () => _showAddBudgetDialog(context),
          ),
          const SizedBox(width: AppDimensions.space8),
        ],
      ),
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
              // Preview banner
              const PreviewBanner(
                text: 'Category limits and threshold calculations preview. Custom creation arrives in Day 3.',
              ),

              // 1. Overall Monthly Budget Pool Card
              BudgetOverviewCard(
                totalCapMinor: SampleData.totalMonthlyBudgetCapMinor,
                totalSpentMinor: SampleData.totalMonthlyExpenseMinor,
                overBudgetCategoryCount: overBudgetItems.length,
              ),

              const SizedBox(height: AppDimensions.space16),

              // 2. Over Budget Warning Notice (if any category exceeded)
              if (overBudgetItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space14),
                  decoration: BoxDecoration(
                    color: AppColors.expenseLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(color: AppColors.expense.withValues(alpha: 0.3), width: 1),
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
                              'Attention: 1 Category Exceeded',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.expenseDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.space2),
                            Text(
                              'Shopping & Gear is 15% over its monthly budget limit.',
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

              // 3. Category Budgets Header
              SectionHeader(
                title: 'Category Allocations',
                subtitle: '${budgets.length} active spending caps',
                actionText: 'Add Budget',
                onAction: () => _showAddBudgetDialog(context),
              ),

              // 4. Category Budget Cards List
              ...budgets.map((budget) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.space12),
                  child: CategoryBudgetCard(
                    budget: budget,
                    onTap: () => _showAddBudgetDialog(context),
                  ),
                );
              }),

              const SizedBox(height: AppDimensions.space12),

              // 5. Educational Empty State Card explaining Day 3 Budget Engine
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
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
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
                      'alerting you before you overspend. Full budget customization and notifications '
                      'will be enabled in Day 3.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
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

