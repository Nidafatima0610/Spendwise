import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/controllers/transaction_controller.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/category_model.dart';
import '../../../models/transaction_model.dart';
import '../../../data/sample_data.dart';

/// Screen B: Add & Edit Transaction Screen
/// 
/// Fully functional transaction creation and editing interface backed by SQLite.
/// Supports income/expense switching, integer minor-unit conversion, field validation,
/// duplicate submission prevention, and reactive state updates.
class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transactionToEdit;
  final VoidCallback? onTransactionSaved;

  const AddTransactionScreen({
    super.key,
    this.transactionToEdit,
    this.onTransactionSaved,
  });

  bool get isEditing => transactionToEdit != null;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _selectedType;
  CategoryModel? _selectedCategory;
  late DateTime _selectedDate;
  bool _isSubmitting = false;

  final TransactionController _controller = TransactionController.instance;

  @override
  void initState() {
    super.initState();

    final editTx = widget.transactionToEdit;
    if (editTx != null) {
      // Edit Mode: Pre-fill existing record
      _selectedType = editTx.type;
      final double major = editTx.amountInMajorUnits;
      // Format major without trailing zeroes if whole number
      _amountController = TextEditingController(
        text: major == major.roundToDouble()
            ? major.toInt().toString()
            : major.toStringAsFixed(2),
      );
      _noteController = TextEditingController(text: editTx.note ?? '');
      _selectedDate = editTx.date;
      _selectedCategory = _controller.getCategory(editTx.categoryId);
    } else {
      // Create Mode: Defaults
      _selectedType = TransactionType.expense;
      _amountController = TextEditingController();
      _noteController = TextEditingController();
      _selectedDate = DateTime.now();
      _selectedCategory = _defaultCategoryFor(_selectedType);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  CategoryModel? _defaultCategoryFor(TransactionType type) {
    final available = _availableCategoriesFor(type);
    return available.isNotEmpty ? available.first : null;
  }

  List<CategoryModel> _availableCategoriesFor(TransactionType type) {
    final loaded = _controller.getCategoriesForType(type);
    if (loaded.isNotEmpty) return loaded;

    // Fallback to SampleData definitions if controller not yet loaded
    return SampleData.categories.where((cat) => cat.type == type).toList();
  }

  List<CategoryModel> get _availableCategories =>
      _availableCategoriesFor(_selectedType);

  void _handleTypeChange(TransactionType type) {
    if (_selectedType == type) return;
    setState(() {
      _selectedType = type;
      _selectedCategory = _defaultCategoryFor(type);
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _setPresetAmount(double amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(0);
    });
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    // 1. Prevent duplicate submissions
    if (_isSubmitting) return;

    // 2. Validate Form Key
    if (!_formKey.currentState!.validate()) return;

    // 3. Validate Category Selection
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category for this transaction.'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    // 4. Validate Amount range and minor unit parsing
    final int minorUnits =
        CurrencyFormatter.parseToMinorUnits(_amountController.text);
    if (minorUnits <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Amount must be greater than zero.'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    if (minorUnits > 10000000000) {
      // Cap at 100 million PKR
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Amount exceeds the maximum supported limit.'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String noteText = _noteController.text.trim();
      final String? optionalNote = noteText.isEmpty ? null : noteText;

      bool success = false;

      if (widget.isEditing) {
        // UPDATE TRANSACTION
        final updatedTx = widget.transactionToEdit!.copyWith(
          type: _selectedType,
          amount: minorUnits,
          date: _selectedDate,
          categoryId: _selectedCategory!.id,
          note: optionalNote,
        );
        success = await _controller.updateTransaction(updatedTx);
      } else {
        // CREATE NEW TRANSACTION
        final newTx = TransactionModel(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          type: _selectedType,
          amount: minorUnits,
          date: _selectedDate,
          categoryId: _selectedCategory!.id,
          note: optionalNote,
        );
        success = await _controller.addTransaction(newTx);
      }

      if (!mounted) return;

      if (success) {
        final message = widget.isEditing
            ? 'Transaction updated successfully.'
            : 'Transaction saved to SQLite successfully.';

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: AppDimensions.space10),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: AppColors.incomeDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
          ),
        );

        if (widget.isEditing) {
          // In edit mode, return to previous screen
          Navigator.pop(context, true);
        } else {
          // In create mode, reset form and notify callback
          _resetForm();
          widget.onTransactionSaved?.call();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database error: Unable to save transaction.'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } catch (e) {
      debugPrint('Transaction save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();
    if (widget.isEditing) {
      final editTx = widget.transactionToEdit!;
      final double major = editTx.amountInMajorUnits;
      _amountController.text = major == major.roundToDouble()
          ? major.toInt().toString()
          : major.toStringAsFixed(2);
      _noteController.text = editTx.note ?? '';
      setState(() {
        _selectedType = editTx.type;
        _selectedDate = editTx.date;
        _selectedCategory = _controller.getCategory(editTx.categoryId);
      });
    } else {
      _amountController.clear();
      _noteController.clear();
      setState(() {
        _selectedDate = DateTime.now();
        _selectedCategory = _defaultCategoryFor(_selectedType);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.isEditing ? 'Edit Transaction' : AppStrings.addTransactionTitle;
    final buttonText = widget.isEditing ? 'Update Transaction' : AppStrings.saveTransaction;
    final resetText = widget.isEditing ? 'Revert Changes' : AppStrings.resetFields;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(titleText),
        actions: [
          TextButton.icon(
            onPressed: _isSubmitting ? null : _resetForm,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(resetText),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Income / Expense Segmented Controller
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      // Expense Toggle
                      Expanded(
                        child: GestureDetector(
                          onTap: _isSubmitting
                              ? null
                              : () => _handleTypeChange(TransactionType.expense),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.space12),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.expense
                                  ? AppColors.expense
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusSmall),
                              boxShadow: _selectedType == TransactionType.expense
                                  ? [
                                      BoxShadow(
                                        color: AppColors.expense
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 18,
                                  color: _selectedType == TransactionType.expense
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppDimensions.space6),
                                Text(
                                  AppStrings.expense,
                                  style: AppTypography.labelLarge.copyWith(
                                    color: _selectedType == TransactionType.expense
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Income Toggle
                      Expanded(
                        child: GestureDetector(
                          onTap: _isSubmitting
                              ? null
                              : () => _handleTypeChange(TransactionType.income),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.space12),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.income
                                  ? AppColors.income
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusSmall),
                              boxShadow: _selectedType == TransactionType.income
                                  ? [
                                      BoxShadow(
                                        color: AppColors.income
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 18,
                                  color: _selectedType == TransactionType.income
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppDimensions.space6),
                                Text(
                                  AppStrings.income,
                                  style: AppTypography.labelLarge.copyWith(
                                    color: _selectedType == TransactionType.income
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space20),

                // 2. Amount Input Card
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.amountLabel,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      TextFormField(
                        key: const Key('amount_input_field'),
                        controller: _amountController,
                        enabled: !_isSubmitting,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: AppTypography.displayMedium.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.space14,
                              vertical: AppDimensions.space12,
                            ),
                            child: Text(
                              AppStrings.defaultCurrencyCode,
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                          hintText: '0.00',
                          hintStyle: AppTypography.displayMedium.copyWith(
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceLavender,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space16,
                            vertical: AppDimensions.space12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a transaction amount';
                          }
                          final sanitized =
                              value.replaceAll(',', '').replaceAll(' ', '').trim();
                          final parsed = double.tryParse(sanitized);
                          if (parsed == null) {
                            return 'Please enter a valid numeric amount';
                          }
                          if (parsed <= 0) {
                            return 'Amount must be greater than zero';
                          }
                          if (parsed > 100000000) {
                            return 'Amount exceeds maximum supported limit (100M PKR)';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppDimensions.space12),

                      // Quick preset amount pills
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPresetChip('+500', 500),
                            _buildPresetChip('+1,000', 1000),
                            _buildPresetChip('+2,500', 2500),
                            _buildPresetChip('+5,000', 5000),
                            _buildPresetChip('+10,000', 10000),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space20),

                // 3. Category Selector
                Text(
                  AppStrings.categoryLabel,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.space10),
                Wrap(
                  spacing: AppDimensions.space8,
                  runSpacing: AppDimensions.space8,
                  children: _availableCategories.map((cat) {
                    final isSelected = _selectedCategory?.id == cat.id;
                    return ChoiceChip(
                      key: Key('cat_chip_${cat.id}'),
                      selected: isSelected,
                      onSelected: _isSubmitting
                          ? null
                          : (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              }
                            },
                      avatar: Icon(
                        cat.iconData,
                        size: 18,
                        color: isSelected ? Colors.white : cat.color,
                      ),
                      label: Text(
                        cat.name,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space10,
                        vertical: AppDimensions.space6,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppDimensions.space20),

                // 4. Date Selection Tile
                CustomCard(
                  onTap: _isSubmitting ? null : _pickDate,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space16,
                    vertical: AppDimensions.space14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.space8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryUltraLight,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusSmall),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.dateLabel,
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space2),
                              Text(
                                DateFormatter.formatDate(_selectedDate),
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space20),

                // 5. Notes & Description (Optional)
                Text(
                  AppStrings.noteLabel,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                TextFormField(
                  key: const Key('note_input_field'),
                  controller: _noteController,
                  enabled: !_isSubmitting,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: AppStrings.noteHint,
                  ),
                ),

                const SizedBox(height: AppDimensions.space28),

                // 6. Action Button
                PrimaryButton(
                  text: buttonText,
                  leadingIcon: widget.isEditing
                      ? Icons.check_circle_rounded
                      : Icons.save_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submitForm,
                ),

                const SizedBox(height: AppDimensions.space32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.space8),
      child: ActionChip(
        label: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryUltraLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        onPressed: _isSubmitting ? null : () => _setPresetAmount(amount),
      ),
    );
  }
}
