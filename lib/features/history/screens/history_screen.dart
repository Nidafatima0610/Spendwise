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
import '../widgets/history_filter_bar.dart';
import '../widgets/transaction_list_tile.dart';

/// Screen C: Transaction History Screen
/// 
/// Real-time transaction timeline connected to local SQLite storage.
/// Supports dynamic filtering, newest-first ordering, editing, and confirmed deletion.
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

  String _selectedMonth = 'All Months';
  String _selectedType = 'All Types';
  String? _selectedCategoryId;
  String _searchQuery = '';

  final List<String> _typeFilters = ['All Types', 'Expenses', 'Income'];

  /// Dynamically computes available month filter options based on recorded transactions.
  List<String> _computeMonthFilters(List<TransactionModel> transactions) {
    final Set<String> months = {'All Months'};
    final now = DateTime.now();
    months.add(DateFormatter.formatMonthYear(now));

    for (final tx in transactions) {
      months.add(DateFormatter.formatMonthYear(tx.date));
    }

    return months.toList();
  }

  List<TransactionModel> _applyFilters(List<TransactionModel> allTransactions) {
    return allTransactions.where((tx) {
      // 1. Month Filter
      if (_selectedMonth != 'All Months') {
        final txMonth = DateFormatter.formatMonthYear(tx.date);
        if (txMonth != _selectedMonth) return false;
      }

      // 2. Type Filter
      if (_selectedType == 'Expenses' && !tx.isExpense) return false;
      if (_selectedType == 'Income' && !tx.isIncome) return false;

      // 3. Category Filter
      if (_selectedCategoryId != null && tx.categoryId != _selectedCategoryId) {
        return false;
      }

      // 4. Search Filter
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
  }

  void _resetFilters() {
    setState(() {
      _selectedMonth = 'All Months';
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
        final filteredTransactions = _applyFilters(allTransactions);

        final filteredIncomeMinor = filteredTransactions
            .where((t) => t.isIncome)
            .fold<int>(0, (sum, t) => sum + t.amount);

        final filteredExpenseMinor = filteredTransactions
            .where((t) => t.isExpense)
            .fold<int>(0, (sum, t) => sum + t.amount);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(AppStrings.historyTitle),
            actions: [
              IconButton(
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
                        monthFilters: monthFilters,
                        selectedMonth: _selectedMonth,
                        onMonthSelected: (month) => setState(() => _selectedMonth = month),
                        typeFilters: _typeFilters,
                        selectedType: _selectedType,
                        onTypeSelected: (type) => setState(() => _selectedType = type),
                        categories: _controller.categories,
                        selectedCategoryId: _selectedCategoryId,
                        onCategorySelected: (catId) =>
                            setState(() => _selectedCategoryId = catId),
                      ),

                      const SizedBox(height: AppDimensions.space12),

                      // Filter Summary Strip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${filteredTransactions.length} records',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '+${CurrencyFormatter.formatMinorUnits(filteredIncomeMinor, showDecimals: false)}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.incomeDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.space8),
                              Text(
                                '-${CurrencyFormatter.formatMinorUnits(filteredExpenseMinor, showDecimals: false)}',
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

                // Main Content: List or Empty States
                Expanded(
                  child: allTransactions.isEmpty
                      ? EmptyStateView(
                          icon: Icons.receipt_long_rounded,
                          title: 'No Transactions Yet',
                          description:
                              'You have not recorded any transactions yet. Tap the button below to add your first income or expense.',
                          buttonText: 'Record First Transaction',
                          onButtonPressed: widget.onAddTransactionTap,
                        )
                      : filteredTransactions.isEmpty
                          ? EmptyStateView(
                              icon: Icons.filter_alt_off_rounded,
                              title: AppStrings.noTransactionsFound,
                              description:
                                  'No transactions match the selected filters. Try choosing a different month or category.',
                              buttonText: 'Reset Filters',
                              onButtonPressed: _resetFilters,
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.screenPaddingH,
                                vertical: AppDimensions.space16,
                              ),
                              itemCount: filteredTransactions.length,
                              itemBuilder: (context, index) {
                                final tx = filteredTransactions[index];
                                final isLast =
                                    index == filteredTransactions.length - 1;

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
