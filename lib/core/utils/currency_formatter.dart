import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

/// Centralized Currency Formatter for SpendWise.
/// 
/// ARCHITECTURAL DECISION & CURRENCY CHOICE:
/// -----------------------------------------
/// As specified in the Stack & Scale Week 02 project brief, PKR (Pakistani Rupee)
/// is selected as the initial display currency for students and early-career
/// professionals in the target demographic.
///
/// FINTECH MINOR UNITS STANDARD:
/// ------------------------------
/// To eliminate IEEE 754 floating-point rounding errors and precision loss
/// during arithmetic operations, all monetary amounts throughout SpendWise
/// (models, SQLite storage, and business calculations) are stored strictly
/// as INTEGERS in minor currency units (paisas / cents).
///
/// 1 Major Unit (PKR 1.00) = 100 Minor Units (100 Paisa).
/// For example:
/// - PKR 2,500.00 is stored as integer 250000.
/// - PKR 50.75 is stored as integer 5075.
///
/// This file acts as the single source of truth for converting between
/// integer minor units and formatted user-facing currency strings.
class CurrencyFormatter {
  CurrencyFormatter._();

  static const String currencyCode = AppStrings.defaultCurrencyCode;
  static const String currencySymbol = AppStrings.defaultCurrencySymbol;

  static final NumberFormat _formatterWithDecimals = NumberFormat.currency(
    symbol: '$currencyCode ',
    decimalDigits: 2,
  );

  static final NumberFormat _formatterWithoutDecimals = NumberFormat.currency(
    symbol: '$currencyCode ',
    decimalDigits: 0,
  );

  /// Converts minor currency units (e.g. 250000 paisa) to a formatted string (e.g. "PKR 2,500.00").
  static String formatMinorUnits(
    int minorUnits, {
    bool showDecimals = true,
    bool showSymbol = true,
  }) {
    final double majorUnits = minorUnits / 100.0;
    return formatMajorUnits(
      majorUnits,
      showDecimals: showDecimals,
      showSymbol: showSymbol,
    );
  }

  /// Converts major currency units (e.g. 2500.0) to a formatted string.
  static String formatMajorUnits(
    double majorUnits, {
    bool showDecimals = true,
    bool showSymbol = true,
  }) {
    final formatter = showDecimals ? _formatterWithDecimals : _formatterWithoutDecimals;
    final formatted = formatter.format(majorUnits);
    if (!showSymbol) {
      return formatted.replaceFirst('$currencyCode ', '').trim();
    }
    return formatted;
  }

  /// Compact format for dashboard chips or summary charts (e.g. "PKR 45.2K").
  static String formatCompact(int minorUnits) {
    final double major = minorUnits / 100.0;
    if (major >= 1000000) {
      return '$currencyCode ${(major / 1000000).toStringAsFixed(1)}M';
    } else if (major >= 1000) {
      return '$currencyCode ${(major / 1000).toStringAsFixed(1)}K';
    }
    return formatMinorUnits(minorUnits, showDecimals: false);
  }

  /// Converts a user input text string (e.g. "2500.50") into integer minor currency units (250050).
  /// Returns 0 if invalid.
  static int parseToMinorUnits(String input) {
    if (input.trim().isEmpty) return 0;
    final sanitized = input.replaceAll(',', '').replaceAll(' ', '').trim();
    final double? parsed = double.tryParse(sanitized);
    if (parsed == null || parsed <= 0) return 0;
    return (parsed * 100).round();
  }

  /// Converts minor units to double major units for calculations.
  static double toMajorUnits(int minorUnits) => minorUnits / 100.0;

  /// Converts double major units to integer minor units.
  static int toMinorUnits(double majorUnits) => (majorUnits * 100).round();
}

