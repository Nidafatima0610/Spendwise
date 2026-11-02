import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../models/category_model.dart';

class CategorySpendItem {
  final CategoryModel category;
  final int spentAmountMinor;
  final double percentageOfTotal;

  const CategorySpendItem({
    required this.category,
    required this.spentAmountMinor,
    required this.percentageOfTotal,
  });
}

/// Category spending distribution preview widget for the Dashboard.
class CategorySpendPreview extends StatelessWidget {
  final List<CategorySpendItem> items;

  const CategorySpendPreview({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      child: Column(
        children: items.map((item) {
          final isLast = item == items.last;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.space6),
                          decoration: BoxDecoration(
                            color: item.category.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          ),
                          child: Icon(
                            item.category.iconData,
                            size: 16,
                            color: item.category.color,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space10),
                        Expanded(
                          child: Text(
                            item.category.name,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${item.percentageOfTotal.toStringAsFixed(1)}%',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Text(
                          CurrencyFormatter.formatMinorUnits(item.spentAmountMinor),
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      child: LinearProgressIndicator(
                        value: (item.percentageOfTotal / 100).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(item.category.color),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

