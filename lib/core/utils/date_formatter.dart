import 'package:intl/intl.dart';

/// Centralized Date and Time Formatter for SpendWise.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM');
  static final DateFormat _standardDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _fullDateTimeFormat = DateFormat('MMM dd, yyyy • hh:mm a');
  static final DateFormat _timeOnlyFormat = DateFormat('hh:mm a');

  /// Formats a DateTime to "November 2026".
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Formats a DateTime to "02 Nov".
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Formats a DateTime to "Nov 02, 2026".
  static String formatDate(DateTime date) {
    return _standardDateFormat.format(date);
  }

  /// Formats a DateTime to "Nov 02, 2026 • 02:30 PM".
  static String formatDateTime(DateTime date) {
    return _fullDateTimeFormat.format(date);
  }

  /// Formats relative time ("Today, 02:30 PM", "Yesterday", or "Oct 28, 2026").
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(itemDate).inDays;

    if (difference == 0) {
      return 'Today, ${_timeOnlyFormat.format(date)}';
    } else if (difference == 1) {
      return 'Yesterday, ${_timeOnlyFormat.format(date)}';
    } else if (difference == -1) {
      return 'Tomorrow';
    } else if (difference < 7 && difference > 1) {
      return '${DateFormat('EEEE').format(date)}, ${_timeOnlyFormat.format(date)}';
    } else {
      return _standardDateFormat.format(date);
    }
  }

  /// Formats date for month-year storage key (e.g. "2026-11").
  static String toMonthYearKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  /// Parses a month-year storage key (e.g. "2026-11") into a DateTime object.
  static DateTime parseMonthYearKey(String key) {
    try {
      final parts = key.split('-');
      if (parts.length >= 2) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        return DateTime(year, month);
      }
    } catch (_) {}
    return DateTime.now();
  }

  /// Formats a month-year storage key (e.g. "2026-11") to "November 2026".
  static String formatMonthYearKey(String key) {
    final date = parseMonthYearKey(key);
    return formatMonthYear(date);
  }
}

