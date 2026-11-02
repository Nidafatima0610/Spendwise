import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/preview_banner.dart';
import '../../../data/sample_data.dart';
import '../../../models/transaction_model.dart';
import '../widgets/history_filter_bar.dart';
import '../widgets/transaction_list_tile.dart';

/// Screen C: Transaction History Screen
/// Comprehensive transaction timeline with interactive month & category filtering,
/// income/expense distinction, and empty-state presentation.
class HistoryScreen extends StatefulWidget {
  final VoidCallback? onAddTransactionTap;

  const HistoryScreen({
    super.key,
    this.onAddTransactionTap,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<String> _monthFilters = ['All Months', 'Nov 2026', 'Oct 2026', 'Sep 2026'];
  String _selectedMonth = 'All Months';

  final List<String> _typeFilters = ['All Types', 'Expenses', 'Income'];
  String _selectedType = 'All Types';

  String? _selectedCategoryId;
  String _searchQuery = '';

  List<TransactionModel> get _filteredTransactions {
    return SampleData.sampleTransactions.where((tx) {
      // 1. Filter by Type
      if (_selectedType == 'Expenses' && !tx.isExpense) return false;
      if (_selectedType == 'Income' && !tx.isIncome) return false;

      // 2. Filter by Category
      if (_selectedCategoryId != null && tx.categoryId != _selectedCategoryId) {
        return false;
      }

      // 3. Search Note / Category Name
      if (_searchQuery.trim().isNotEmpty) {
        final category = SampleData.categoryMap[tx.categoryId];
        final catName = category?.name.toLowerCase() ?? '';
        final note = tx.note?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        if (!catName.contains(query) && !note.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  int get _filteredIncomeMinor {
    return _filteredTransactions
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  int get _filteredExpenseMinor {
    return _filteredTransactions
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  void _resetFilters() {
    setState(() {
      _selectedMonth = 'All Months';
      _selectedType = 'All Types';
      _selectedCategoryId = null;
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _filteredTransactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.historyTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Filters',
            onPressed: _resetFilters,
          ),
          const SizedBox(width: AppDimensions.space8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Bar Area
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPaddingH,
                AppDimensions.space8,
                AppDimensions.screenPaddingH,
                AppDimensions.space12,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Column(
                children: [
                  HistoryFilterBar(
                    monthFilters: _monthFilters,
                    selectedMonth: _selectedMonth,
                    onMonthSelected: (month) => setState(() => _selectedMonth = month),
                    typeFilters: _typeFilters,
                    selectedType: _selectedType,
                    onTypeSelected: (type) => setState(() => _selectedType = type),
                    categories: SampleData.categories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: (catId) => setState(() => _selectedCategoryId = catId),
                  ),

                  const SizedBox(height: AppDimensions.space12),

                  // Filter Summary Strip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Showing ${transactions.length} transactions',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '+${CurrencyFormatter.formatMinorUnits(_filteredIncomeMinor, showDecimals: false)}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.incomeDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space8),
                          Text(
                            '-${CurrencyFormatter.formatMinorUnits(_filteredExpenseMinor, showDecimals: false)}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.expenseDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Transaction List or Empty State
            Expanded(
              child: transactions.isEmpty
                  ? EmptyStateView(
                      icon: Icons.receipt_long_rounded,
                      title: AppStrings.noTransactionsFound,
                      description: AppStrings.noTransactionsDesc,
                      buttonText: 'Reset Filters',
                      onButtonPressed: _resetFilters,
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.screenPaddingH,
                        vertical: AppDimensions.space16,
                      ),
                      itemCount: transactions.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const PreviewBanner(
                            text: 'Showing newest transactions first. Filter bar is interactive.',
                          );
                        }

                        final tx = transactions[index - 1];
                        final isLast = index == transactions.length;

                        return CustomCard(
                          margin: EdgeInsets.only(
                            bottom: isLast ? AppDimensions.space32 : AppDimensions.space10,
                          ),
                          padding: const EdgeInsets.all(AppDimensions.space6),
                          child: TransactionListTile(
                            transaction: tx,
                            category: SampleData.categoryMap[tx.categoryId],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

