import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/database/app_database.dart';

/// Application entry point for SpendWise — Personal Budget & Expense Tracker.
/// Stack & Scale Remote Internship 2026 | Week 02 (Day 1 Foundation).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database instance and ensure pre-seeded categories exist
  try {
    await AppDatabase.instance.database;
  } catch (e) {
    debugPrint('Database initialization notice: $e');
  }

  runApp(const SpendWiseApp());
}
