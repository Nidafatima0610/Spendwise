import 'package:flutter/material.dart';

/// Centralized color palette for SpendWise.
/// 
/// Follows a premium fintech design system featuring a sophisticated
/// violet/purple brand identity (#6536C7), soft lavender surfaces,
/// and high-contrast semantic indicators for income, expense, and warnings.
class AppColors {
  AppColors._();

  // Brand Primaries
  static const Color primary = Color(0xFF6536C7);
  static const Color primaryDark = Color(0xFF4F28A4);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryUltraLight = Color(0xFFEDE9FE);
  static const Color primaryGhost = Color(0xFFF5F3FF);

  // Secondary & Accents
  static const Color secondary = Color(0xFF7C3AED);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentViolet = Color(0xFFA78BFA);

  // Background & Surfaces
  static const Color background = Color(0xFFF9F8FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLavender = Color(0xFFF6F4FC);
  static const Color surfaceVariant = Color(0xFFF1EEF9);

  // Borders & Dividers
  static const Color border = Color(0xFFEBE7F5);
  static const Color borderLight = Color(0xFFF3F0FA);
  static const Color divider = Color(0xFFE5E1F0);

  // Semantic Colors
  // Income (Emerald)
  static const Color income = Color(0xFF10B981);
  static const Color incomeLight = Color(0xFFD1FAE5);
  static const Color incomeDark = Color(0xFF047857);

  // Expense (Coral Red)
  static const Color expense = Color(0xFFEF4444);
  static const Color expenseLight = Color(0xFFFEE2E2);
  static const Color expenseDark = Color(0xFFB91C1C);

  // Warning (Amber)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  // Info (Sky Blue)
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Neutral & Typography
  static const Color textPrimary = Color(0xFF1E1435);
  static const Color textSecondary = Color(0xFF6B647D);
  static const Color textMuted = Color(0xFF9E98AD);
  static const Color textLight = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7342DC),
      Color(0xFF5525B2),
    ],
  );

  static const LinearGradient balanceCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6E3CD4),
      Color(0xFF4C21A4),
      Color(0xFF3B158B),
    ],
  );

  static const LinearGradient incomePillGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );

  static const LinearGradient expensePillGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF4444),
      Color(0xFFDC2626),
    ],
  );

  // Subtle shadows
  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color(0x081E1435),
          blurRadius: 16,
          offset: Offset(0, 4),
          spreadRadius: 0,
        ),
        const BoxShadow(
          color: Color(0x041E1435),
          blurRadius: 4,
          offset: Offset(0, 1),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get primaryButtonShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.35),
          blurRadius: 14,
          offset: const Offset(0, 6),
          spreadRadius: 0,
        ),
      ];
}

