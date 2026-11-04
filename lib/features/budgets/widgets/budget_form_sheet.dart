import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/controllers/budget_controller.dart';
import '../../../core/controllers/transaction_controller.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../app/theme/app_typography.dart';
import '../../../models/budget_model.dart';
import '../../../models/category_model.dart';
import '../../../models/transaction_model.dart';

/// Modal bottom sheet for creating or editing a monthly category budget.
class BudgetFormSheet extends StatefulWidget {
  final BudgetModel? budgetToEdit;
  final String? initialMonthYear;

  const BudgetFormSheet({
    super.key,
    this.budgetToEdit,
    this.initialMonthYear,
  });

  static Future<bool?> show(
    BuildContext context, {
    BudgetModel? budgetToEdit,
    String? initialMonthYear,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BudgetFormSheet(
        budgetToEdit: budgetToEdit,
        initialMonthYear: initialMonthYear,
      ),
    );
  }

  @override
  State<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  late String _monthYear;
  CategoryModel? _selectedCategory;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.budgetToEdit != null;

  @override
  void initState() {
    super.initState();
    final budgetController = BudgetController.instance;
    final txController = TransactionController.instance;

    _monthYear = widget.initialMonthYear ??
        widget.budgetToEdit?.monthYear ??
        budgetController.selectedMonthYear;

    final expenseCategories = txController.getCategoriesForType(TransactionType.expense);

    if (_isEditing) {
      final existing = widget.budgetToEdit!;
      _selectedCategory = txController.getCategory(existing.categoryId);
      final double majorAmount = existing.limitAmount / 100.0;
      _amountController.text = majorAmount % 1 == 0
          ? majorAmount.toInt().toString()
          : majorAmount.toStringAsFixed(2);
    } else {
      // Find first unbudgeted category, if any
      final available = budgetController.getAvailableExpenseCategories(expenseCategories);
      if (available.isNotEmpty) {
        _selectedCategory = available.first;
      } else if (expenseCategories.isNotEmpty) {
        _selectedCategory = expenseCategories.first;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _addPreset(int amount) {
    final current = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    final updated = current + amount;
    setState(() {
      _amountController.text = updated.toInt().toString();
    });
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a budget amount';
    }
    final sanitized = value.replaceAll(',', '').replaceAll(' ', '').trim();
    final parsed = double.tryParse(sanitized);
    if (parsed == null) {
      return 'Please enter a valid numeric amount';
    }
    if (parsed <= 0) {
      return 'Budget amount must be greater than zero';
    }
    if (parsed > 100000000) {
      return 'Amount exceeds maximum supported limit';
    }
    return null;
  }

  Future<void> _submitForm() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      setState(() {
        _errorMessage = 'Please select an expense category';
      });
      return;
    }

    final minorUnits = CurrencyFormatter.parseToMinorUnits(_amountController.text);
    if (minorUnits <= 0) {
      setState(() {
        _errorMessage = 'Budget amount must be greater than zero';
      });
      return;
    }

    final budgetController = BudgetController.instance;

    // Check duplicate check on create
    if (!_isEditing) {
      if (budgetController.isCategoryBudgeted(_selectedCategory!.id, monthYear: _monthYear)) {
        setState(() {
          _errorMessage = 'A budget for ${_selectedCategory!.name} already exists in this month.';
        });
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      bool success;
      if (_isEditing) {
        final updated = widget.budgetToEdit!.copyWith(
          limitAmount: minorUnits,
          categoryId: _selectedCategory!.id,
          monthYear: _monthYear,
        );
        success = await budgetController.updateBudget(updated);
      } else {
        final newBudget = BudgetModel(
          id: 'b_${DateTime.now().millisecondsSinceEpoch}',
          categoryId: _selectedCategory!.id,
          limitAmount: minorUnits,
          monthYear: _monthYear,
        );
        success = await budgetController.addBudget(newBudget);
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Budget for ${_selectedCategory!.name} updated!'
                  : 'Budget for ${_selectedCategory!.name} created successfully!',
            ),
            backgroundColor: AppColors.incomeDark,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMessage = 'Failed to save budget to database.';
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final txController = TransactionController.instance;
    final budgetController = BudgetController.instance;
    final expenseCategories = txController.getCategoriesForType(TransactionType.expense);
    final monthLabel = DateFormatter.formatMonthYearKey(_monthYear);

    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.screenPaddingH,
        right: AppDimensions.screenPaddingH,
        top: AppDimensions.space20,
        bottom: AppDimensions.space20 + viewInsets,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Title & Month Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? 'Edit Monthly Budget' : 'Set Monthly Budget',
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space2),
                      Text(
                        'Spending limit for $monthLabel',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.space20),

              // Error banner if any
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  decoration: BoxDecoration(
                    color: AppColors.expenseLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(color: AppColors.expense.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.expenseDark, size: 20),
                      const SizedBox(width: AppDimensions.space8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.expenseDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),
              ],

              // 1. Category Selection Label
              Text(
                'Expense Category',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.space8),

              // Category Choice Chips
              Wrap(
                spacing: AppDimensions.space8,
                runSpacing: AppDimensions.space8,
                children: expenseCategories.map((category) {
                  final isSelected = _selectedCategory?.id == category.id;
                  final isAlreadyBudgeted = !_isEditing &&
                      budgetController.isCategoryBudgeted(category.id, monthYear: _monthYear);

                  return ChoiceChip(
                    avatar: Icon(
                      category.iconData,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : (isAlreadyBudgeted ? AppColors.textMuted : category.color),
                    ),
                    label: Text(
                      isAlreadyBudgeted ? '${category.name} (Budgeted)' : category.name,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (isAlreadyBudgeted ? AppColors.textMuted : AppColors.textPrimary),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceVariant,
                    disabledColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    onSelected: isAlreadyBudgeted
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            }
                          },
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimensions.space20),

              // 2. Budget Amount Label & Field
              Text(
                'Monthly Budget Limit',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.space8),

              TextFormField(
                key: const Key('budget_amount_input'),
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateAmount,
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixText: 'PKR ',
                  prefixStyle: AppTypography.headlineLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                  hintText: '0.00',
                  hintStyle: AppTypography.displayMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.expense, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.space12),

              // Quick preset amount increments
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPresetChip('+1,000', 1000),
                    const SizedBox(width: AppDimensions.space8),
                    _buildPresetChip('+5,000', 5000),
                    const SizedBox(width: AppDimensions.space8),
                    _buildPresetChip('+10,000', 10000),
                    const SizedBox(width: AppDimensions.space8),
                    _buildPresetChip('+20,000', 20000),
                    const SizedBox(width: AppDimensions.space8),
                    _buildPresetChip('+50,000', 50000),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space24),

              // 3. Save / Update Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const Key('save_budget_button'),
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Budget' : 'Save Budget',
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: AppDimensions.space12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, int amount) {
    return ActionChip(
      label: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.primaryUltraLight,
      side: BorderSide.none,
      onPressed: () => _addPreset(amount),
    );
  }
}

