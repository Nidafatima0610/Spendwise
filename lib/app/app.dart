import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import 'theme/app_theme.dart';
import 'navigation/app_scaffold.dart';

/// SpendWise root application widget.
class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppScaffold(),
    );
  }
}

