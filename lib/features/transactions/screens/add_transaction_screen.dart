import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/preview_banner.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/category_model.dart';
import '../../../models/transaction_model.dart';
import '../../../data/sample_data.dart';

/// Screen B: Add Transaction Screen
/// Professional transaction entry interface prepared for Day 2 SQLite persistence.
class AddTransactionScreen extends StatefulWidget {
  final VoidCallback? onTransactionSavedPreview;

  const AddTransactionScreen({
    super.key,
    this.onTransactionSavedPreview,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Default to Food category for expense
    _selectedCategory = SampleData.catFood;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<CategoryModel> get _availableCategories {
    return SampleData.categories.where((cat) {
      if (_selectedType == TransactionType.income) {
        return cat.type == TransactionType.income;
      } else {
        return cat.type == TransactionType.expense;
      }
    }).toList();
  }

  void _handleTypeChange(TransactionType type) {
    if (_selectedType == type) return;
    setState(() {
      _selectedType = type;
      final filtered = _availableCategories;
      _selectedCategory = filtered.isNotEmpty ? filtered.first : null;
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category for this transaction.'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final int minorUnits = CurrencyFormatter.parseToMinorUnits(_amountController.text);

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
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.space10),
            const Text('Entry Validated'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction validated successfully!',
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              '• Type: ${_selectedType.name.toUpperCase()}\n'
              '• Amount: ${CurrencyFormatter.formatMinorUnits(minorUnits)}\n'
              '• Category: ${_selectedCategory!.name}\n'
              '• Date: ${DateFormatter.formatDate(_selectedDate)}\n'
              '• Note: ${_noteController.text.isEmpty ? "None" : _noteController.text}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: AppDimensions.space12),
            Container(
              padding: const EdgeInsets.all(AppDimensions.space10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLavender,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Text(
                'Note: Full SQLite persistence will be activated during Day 2.',
                style: AppTypography.labelSmall.copyWith(color: AppColors.primaryDark),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetForm();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _amountController.clear();
    _noteController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedCategory = _availableCategories.isNotEmpty ? _availableCategories.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.addTransactionTitle),
        actions: [
          TextButton.icon(
            onPressed: _resetForm,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text(AppStrings.resetFields),
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
                // Day 1 Architecture Notice
                const PreviewBanner(
                  text: 'Entry form is validation-ready. Full SQLite persistence arrives in Day 2.',
                ),

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
                          onTap: () => _handleTypeChange(TransactionType.expense),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: AppDimensions.space12),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.expense
                                  ? AppColors.expense
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              boxShadow: _selectedType == TransactionType.expense
                                  ? [
                                      BoxShadow(
                                        color: AppColors.expense.withValues(alpha: 0.3),
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
                          onTap: () => _handleTypeChange(TransactionType.income),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: AppDimensions.space12),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.income
                                  ? AppColors.income
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              boxShadow: _selectedType == TransactionType.income
                                  ? [
                                      BoxShadow(
                                        color: AppColors.income.withValues(alpha: 0.3),
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
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
                          final parsed = double.tryParse(value.replaceAll(',', ''));
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a valid amount greater than 0';
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
                      selected: isSelected,
                      onSelected: (selected) {
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
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
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
                  onTap: _pickDate,
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
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
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
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: AppStrings.noteHint,
                  ),
                ),

                const SizedBox(height: AppDimensions.space28),

                // 6. Action Button
                PrimaryButton(
                  text: AppStrings.saveTransaction,
                  leadingIcon: Icons.save_rounded,
                  onPressed: _submitForm,
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
        onPressed: () => _setPresetAmount(amount),
      ),
    );
  }
}

