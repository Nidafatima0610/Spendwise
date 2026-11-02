import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../../app/theme/app_typography.dart';

/// Primary brand action button with gradient background and subtle shadow.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final Gradient? gradient;
  final Color? backgroundColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.gradient,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? (backgroundColor == null ? AppColors.primaryGradient : null);

    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else ...[
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 20, color: Colors.white),
            const SizedBox(width: AppDimensions.space8),
          ],
          Text(
            text,
            style: AppTypography.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    return Container(
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: effectiveGradient == null ? (backgroundColor ?? AppColors.primary) : null,
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: onPressed == null ? null : AppColors.primaryButtonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space24,
              vertical: AppDimensions.space16,
            ),
            child: buttonContent,
          ),
        ),
      ),
    );
  }
}

