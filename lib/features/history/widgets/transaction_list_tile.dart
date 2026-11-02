import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../app/theme/app_typography.dart';
import '../../../models/category_model.dart';
import '../../../models/transaction_model.dart';
import '../../../data/sample_data.dart';

/// Clean transaction list tile displaying category icon, title, note, date,
/// and visually distinguished income/expense amount.
class TransactionListTile extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel? category;
  final VoidCallback? onTap;

  const TransactionListTile({
    super.key,
    required this.transaction,
    this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve category if not passed directly
    final effectiveCategory = category ??
        SampleData.categoryMap[transaction.categoryId] ??
        SampleData.catOther;

    final isIncome = transaction.isIncome;
    final amountColor = isIncome ? AppColors.incomeDark : AppColors.textPrimary;
    final sign = isIncome ? '+' : '-';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space8,
            vertical: AppDimensions.space10,
          ),
          child: Row(
            children: [
              // Category Icon with Soft Background
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: effectiveCategory.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Icon(
                  effectiveCategory.iconData,
                  color: effectiveCategory.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppDimensions.space14),

              // Title and Note / Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      effectiveCategory.name,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space2),
                    Row(
                      children: [
                        Text(
                          DateFormatter.formatRelative(transaction.date),
                          style: AppTypography.bodySmall,
                        ),
                        if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                          const SizedBox(width: AppDimensions.space6),
                          Text(
                            '•',
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(width: AppDimensions.space6),
                          Expanded(
                            child: Text(
                              transaction.note!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppDimensions.space8),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign ${transaction.formattedAmount}',
                    style: AppTypography.titleMedium.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space6,
                      vertical: AppDimensions.space2,
                    ),
                    decoration: BoxDecoration(
                      color: isIncome ? AppColors.incomeLight : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      isIncome ? 'Income' : 'Expense',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 9.5,
                        color: isIncome ? AppColors.incomeDark : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

