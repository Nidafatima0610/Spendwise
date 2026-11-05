import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/database/database_service.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';

/// Screen E: Settings & System Status Screen
/// Clean fintech settings interface highlighting currency configuration and SQLite health.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _dbService = DatabaseService();
  String? _dbStatusText;
  bool _isCheckingDb = false;

  Future<void> _checkDatabaseHealth() async {
    setState(() {
      _isCheckingDb = true;
      _dbStatusText = 'Checking SQLite database...';
    });

    final bool isHealthy = await _dbService.testConnection();
    final int categoryCount = await _dbService.getCategoryCount();
    final int txCount = await _dbService.getTransactionCount();

    if (!mounted) return;

    setState(() {
      _isCheckingDb = false;
      if (isHealthy) {
        _dbStatusText =
            '✅ SQLite Connected & Ready\n• Pre-seeded Categories: $categoryCount\n• Persisted Transactions: $txCount\n• Schema Version: 1.0 (Offline-First SQLite Engine)';
      } else {
        _dbStatusText = '⚠️ SQLite connection issue. Check permissions.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
            vertical: AppDimensions.screenPaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. User Profile Card
              CustomCard(
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppColors.primaryButtonShadow,
                      ),
                      child: const Center(
                        child: Text(
                          'AR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.defaultUserName,
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space2),
                          Text(
                            'Student / Early-Career Tier',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space2),
                          Text(
                            'alex.rivera@spendwise.local',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space24),

              // 2. Currency & Region Section
              Text(
                AppStrings.currencySection,
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppDimensions.space10),
              CustomCard(
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.currency_exchange_rounded,
                      title: 'Display Currency',
                      subtitle: '${AppStrings.defaultCurrencyCode} (${AppStrings.currencyName})',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryUltraLight,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Text(
                          AppStrings.defaultCurrencyCode,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.calculate_outlined,
                      title: 'Internal Precision',
                      subtitle: 'Minor Units (Paisas / Integers - Zero rounding loss)',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space24),

              // 3. SQLite Local Storage Section
              Text(
                AppStrings.databaseSection,
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppDimensions.space10),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSettingsTile(
                      icon: Icons.storage_rounded,
                      title: 'Local SQLite Engine',
                      subtitle: 'Offline-First • No external cloud dependencies',
                      trailing: TextButton(
                        onPressed: _isCheckingDb ? null : _checkDatabaseHealth,
                        child: Text(_isCheckingDb ? 'Testing...' : 'Test DB'),
                      ),
                    ),
                    if (_dbStatusText != null) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.space12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppDimensions.space12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLavender,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          ),
                          child: Text(
                            _dbStatusText!,
                            style: AppTypography.bodySmall.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space24),

              // 4. About SpendWise
              Text(
                AppStrings.aboutSection,
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppDimensions.space10),
              CustomCard(
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.school_rounded,
                      title: 'Internship Program',
                      subtitle: 'Stack & Scale Remote Internship 2026 | Week 02',
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Milestone Scope',
                      subtitle: 'Full Release: Offline Tracker, Budgets & Visualizations',
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.verified_rounded,
                      title: 'Version',
                      subtitle: AppStrings.appVersion,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space8),
            decoration: BoxDecoration(
              color: AppColors.primaryUltraLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppDimensions.space14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppDimensions.space2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
