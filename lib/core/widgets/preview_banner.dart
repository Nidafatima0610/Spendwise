import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../../app/theme/app_typography.dart';

/// Distinctive badge/banner that explicitly identifies sample preview data
/// during the Day 1 foundation phase.
class PreviewBanner extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const PreviewBanner({
    super.key,
    this.text = 'Day 1 Foundation • Sample Presentation Data',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.space16),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space14,
        vertical: AppDimensions.space10,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryUltraLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: AppDimensions.space10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PREVIEW MODE',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: AppDimensions.space2),
                Text(
                  text,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

