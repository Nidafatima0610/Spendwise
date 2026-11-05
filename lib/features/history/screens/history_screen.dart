import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/controllers/transaction_controller.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../models/transaction_model.dart';
import '../../transactions/screens/add_transaction_screen.dart';
import '../widgets/category_spending_visualization.dart';
import '../widgets/history_filter_bar.dart';
import '../widgets/transaction_list_tile.dart';

/// Screen C: Transaction History Screen
/// 
/// Real-time transaction timeline with Month filtering, Category filtering,
/// proportional Category Spending Visualization, editing, and deletion.
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
  final TransactionController _controller = TransactionController.instance;

  // Month filtering key: 'ALL' or 'YYYY-MM' (e.g. '2026-11')
  String _selectedMonthKey = DateFormatter.toMonthYearKey(DateTime.now());
  String _selectedType = 'All Types';
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _isBreakdownView = false;

  final List<String> _typeFilters = ['All Types', 'Expenses', 'Income'];

  String get _currentMonthLabel {
    if (_selectedMonthKey == 'ALL') {
      return 'All Months';
    }
    return DateFormatter.formatMonthYearKey(_selectedMonthKey);
  }

  void _onPrevMonth() {
    setState(() {
      if (_selectedMonthKey == 'ALL') {
        _selectedMonthKey = DateFormatter.toMonthYearKey(DateTime.now());
      }
      _selectedMonthKey = DateFormatter.getPreviousMonthKey(_selectedMonthKey);
    });
  }

  void _onNextMonth() {
    setState(() {
      if (_selectedMonthKey == 'ALL') {
        _selectedMonthKey = DateFormatter.toMonthYearKey(DateTime.now());
      }
      _selectedMonthKey = DateFormatter.getNextMonthKey(_selectedMonthKey);
    });
  }

  void _onMonthSelected(String month) {
    setState(() {
      if (month == 'All Months') {
        _selectedMonthKey = 'ALL';
      } else {
        final date = DateFormatter.parseMonthYearKey(month);
        _selectedMonthKey = DateFormatter.toMonthYearKey(date);
      }
    });
  }

  List<String> _computeMonthFilters(List<TransactionModel> transactions) {
    final Set<String> months = {'All Months'};
    final now = DateTime.now();
    months.add(DateFormatter.formatMonthYear(now));

    for (final tx in transactions) {
      months.add(DateFormatter.formatMonthYear(tx.date));
    }

    return months.toList();
  }

  void _resetFilters() {
    setState(() {
      _selectedMonthKey = DateFormatter.toMonthYearKey(DateTime.now());
      _selectedType = 'All Types';
      _selectedCategoryId = null;
      _searchQuery = '';
    });
  }

  Future<void> _openEditTransaction(TransactionModel tx) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          transactionToEdit: tx,
        ),
      ),
    );

    if (result == true && mounted) {
      await _controller.refresh();
    }
  }

  Future<void> _confirmDeleteTransaction(TransactionModel tx) async {
    final category = _controller.getCategory(tx.categoryId);

    final bool? confirmed = await showDialog<bool>(
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
                color: AppColors.expenseLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.expense,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.space10),
            const Text('Delete Record?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to permanently delete this transaction from local storage? This action cannot be undone.',
              style: TextStyle(height: 1.45),
            ),
            const SizedBox(height: AppDimensions.space14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLavender,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category.name,
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        tx.signedFormattedAmount,
                        style: AppTypography.titleMedium.copyWith(
                          color: tx.isIncome ? AppColors.incomeDark : AppColors.expenseDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    '${DateFormatter.formatDate(tx.date)}${tx.note != null ? " • ${tx.note}" : ""}',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirm_delete_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _controller.deleteTransaction(tx.id);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                SizedBox(width: AppDimensions.space10),
                Text('Transaction deleted successfully.'),
              ],
            ),
            backgroundColor: AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete transaction.'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final allTransactions = _controller.transactions;
        final monthFilters = _computeMonthFilters(allTransactions);

        // 1. Transactions belonging to selected month (or all)
        final List<TransactionModel> monthTransactions = _selectedMonthKey == 'ALL'
            ? allTransactions
            : allTransactions
                .where((tx) => DateFormatter.isInMonth(tx.date, _selectedMonthKey))
                .toList();

        // 2. Exact Month financial calculations
        final int monthIncomeMinor = monthTransactions
            .where((t) => t.isIncome)
            .fold<int>(0, (sum, t) => sum + t.amount);

        final int monthExpenseMinor = monthTransactions
            .where((t) => t.isExpense)
            .fold<int>(0, (sum, t) => sum + t.amount);

        final int monthBalanceMinor = monthIncomeMinor - monthExpenseMinor;

        // 3. Category Spending Breakdown data (strictly expenses, ordered highest first)
        final Map<String, int> catSpendMap = {};
        for (final tx in monthTransactions.where((t) => t.isExpense)) {
          catSpendMap[tx.categoryId] = (catSpendMap[tx.categoryId] ?? 0) + tx.amount;
        }

        final List<CategorySpendingData> spendingData = [];
        for (final entry in catSpendMap.entries) {
          final category = _controller.getCategory(entry.key);
          final double percentage = monthExpenseMinor > 0
              ? (entry.value / monthExpenseMinor) * 100.0
              : 0.0;
          spendingData.add(
            CategorySpendingData(
              category: category,
              totalSpentMinor: entry.value,
              percentageOfTotal: percentage,
            ),
          );
        }
        spendingData.sort((a, b) => b.totalSpentMinor.compareTo(a.totalSpentMinor));

        // 4. Filtered Transactions (combining Month, Category, Type, and Search)
        final List<TransactionModel> filteredTransactions = monthTransactions.where((tx) {
          // Type Filter
          if (_selectedType == 'Expenses' && !tx.isExpense) return false;
          if (_selectedType == 'Income' && !tx.isIncome) return false;

          // Category Filter
          if (_selectedCategoryId != null && tx.categoryId != _selectedCategoryId) {
            return false;
          }

          // Search Filter
          if (_searchQuery.trim().isNotEmpty) {
            final category = _controller.getCategory(tx.categoryId);
            final catName = category.name.toLowerCase();
            final note = tx.note?.toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();
            if (!catName.contains(query) && !note.contains(query)) {
              return false;
            }
          }

          return true;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(AppStrings.historyTitle),
            actions: [
              IconButton(
                key: const Key('history_refresh_button'),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh / Reset Filters',
                onPressed: () {
                  _resetFilters();
                  _controller.refresh();
                },
              ),
              const SizedBox(width: AppDimensions.space8),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Filter Controls Area
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPaddingH,
                    AppDimensions.space6,
                    AppDimensions.screenPaddingH,
                    AppDimensions.space10,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
                  ),
                  child: Column(
                    children: [
                      HistoryFilterBar(
                        monthFilters: monthFilters,
                        selectedMonth: _currentMonthLabel,
                        onMonthSelected: _onMonthSelected,
                        onPrevMonth: _onPrevMonth,
                        onNextMonth: _onNextMonth,
                        typeFilters: _typeFilters,
                        selectedType: _selectedType,
                        onTypeSelected: (type) => setState(() => _selectedType = type),
                        categories: _controller.categories,
                        selectedCategoryId: _selectedCategoryId,
                        onCategorySelected: (catId) =>
                            setState(() => _selectedCategoryId = catId),
                        isBreakdownView: _isBreakdownView,
                        onToggleView: (val) => setState(() => _isBreakdownView = val),
                      ),

                      const SizedBox(height: AppDimensions.space10),

                      // Month Financial Summary Strip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Showing ${filteredTransactions.length} ${filteredTransactions.length == 1 ? "record" : "records"}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Net: ${monthBalanceMinor >= 0 ? '+' : '-'}${CurrencyFormatter.formatMinorUnits(monthBalanceMinor.abs(), showDecimals: false)}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: monthBalanceMinor >= 0
                                      ? AppColors.incomeDark
                                      : AppColors.expenseDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.incomeLight,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                ),
                                child: Text(
                                  '+${CurrencyFormatter.formatMinorUnits(monthIncomeMinor, showDecimals: false)}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.incomeDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.space6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.expenseLight,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                ),
                                child: Text(
                                  '-${CurrencyFormatter.formatMinorUnits(monthExpenseMinor, showDecimals: false)}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.expenseDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Content View: Breakdown or Transactions List
                Expanded(
                  child: _isBreakdownView
                      // 1. Category-wise Spending Visualization
                      ? SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
                          child: CategorySpendingVisualization(
                            spendingData: spendingData,
                            totalExpenseMinor: monthExpenseMinor,
                            monthLabel: _currentMonthLabel,
                            onCategoryTap: (catId) {
                              setState(() {
                                _selectedCategoryId = catId;
                                _isBreakdownView = false;
                              });
                            },
                          ),
                        )
                      // 2. Filtered Transactions Timeline List
                      : allTransactions.isEmpty
                          ? EmptyStateView(
                              icon: Icons.receipt_long_rounded,
                              title: 'No Transactions Yet',
                              description:
                                  'You have not recorded any transactions yet. Tap the button below to add your first income or expense.',
                              buttonText: 'Record First Transaction',
                              onButtonPressed: widget.onAddTransactionTap,
                            )
                          : monthTransactions.isEmpty
                              ? EmptyStateView(
                                  icon: Icons.calendar_today_rounded,
                                  title: 'No Transactions in $_currentMonthLabel',
                                  description:
                                      'There are no transactions recorded for this cycle. Tap below to log your first income or expense.',
                                  buttonText: 'Record Transaction',
                                  onButtonPressed: widget.onAddTransactionTap,
                                )
                              : filteredTransactions.isEmpty
                              ? EmptyStateView(
                                  icon: Icons.filter_alt_off_rounded,
                                  title: AppStrings.noTransactionsFound,
                                  description:
                                      'No transactions match the selected category or type in $_currentMonthLabel.',
                                  buttonText: 'Clear Category Filter',
                                  onButtonPressed: () {
                                    setState(() {
                                      _selectedCategoryId = null;
                                      _selectedType = 'All Types';
                                    });
                                  },
                                )
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.screenPaddingH,
                                    vertical: AppDimensions.space12,
                                  ),
                                  itemCount: filteredTransactions.length,
                                  itemBuilder: (context, index) {
                                    final tx = filteredTransactions[index];
                                    final isLast = index == filteredTransactions.length - 1;

                                    return CustomCard(
                                      margin: EdgeInsets.only(
                                        bottom: isLast
                                            ? AppDimensions.space32
                                            : AppDimensions.space10,
                                      ),
                                      padding: const EdgeInsets.all(AppDimensions.space6),
                                      child: TransactionListTile(
                                        transaction: tx,
                                        category: _controller.getCategory(tx.categoryId),
                                        onTap: () => _openEditTransaction(tx),
                                        onEdit: () => _openEditTransaction(tx),
                                        onDelete: () => _confirmDeleteTransaction(tx),
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
