// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> loadRealFonts() async {
  final robotoLoader = FontLoader('Roboto');
  robotoLoader.addFont(
    File('C:/SRC/flutter/bin/cache/artifacts/material_fonts/roboto-regular.ttf')
        .readAsBytes()
        .then((b) => ByteData.view(b.buffer)),
  );
  robotoLoader.addFont(
    File('C:/SRC/flutter/bin/cache/artifacts/material_fonts/roboto-medium.ttf')
        .readAsBytes()
        .then((b) => ByteData.view(b.buffer)),
  );
  robotoLoader.addFont(
    File('C:/SRC/flutter/bin/cache/artifacts/material_fonts/roboto-bold.ttf')
        .readAsBytes()
        .then((b) => ByteData.view(b.buffer)),
  );
  await robotoLoader.load();

  final iconsLoader = FontLoader('MaterialIcons');
  iconsLoader.addFont(
    File('C:/SRC/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf')
        .readAsBytes()
        .then((b) => ByteData.view(b.buffer)),
  );
  await iconsLoader.load();
}

Future<ui.Image> loadUiImage(String path) async {
  final bytes = File(path).readAsBytesSync();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}

class SlideModel {
  final String filename;
  final double duration; // in seconds
  final int activeNavIndex; // 0 to 7
  final String screenshotPath;
  final String badge;
  final String title;
  final String description;
  final List<String> bulletPoints;
  final String narration;
  final String timeRange;

  const SlideModel({
    required this.filename,
    required this.duration,
    required this.activeNavIndex,
    required this.screenshotPath,
    required this.badge,
    required this.title,
    required this.description,
    required this.bulletPoints,
    required this.narration,
    required this.timeRange,
  });
}

class PresentationSlideWidget extends StatelessWidget {
  final SlideModel model;
  final ui.Image appImage;

  const PresentationSlideWidget({
    super.key,
    required this.model,
    required this.appImage,
  });

  static const List<String> navItems = [
    '1. Executive Dashboard',
    '2. Add Transactions',
    '3. Monthly Budgets',
    '4. History & Filters',
    '5. SQLite Local Storage',
    '6. Technical Learnings',
    '7. Challenges & Architecture',
    '8. Project Handover',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1920,
      height: 1080,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF040A14), // Ultra deep navy
            Color(0xFF081426), // Mid deep navy
            Color(0xFF0B1E38), // Oceanic navy slate
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle background glow orbs in Teal/Cyan
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: 200,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF14B8A6).withValues(alpha: 0.06),
              ),
            ),
          ),

          // Main Column Layout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Bar
                _buildHeaderBar(),
                const SizedBox(height: 28),

                // Main Split Body: Left Column (430px), Center Phone (470px), Right Column (800px)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT COLUMN: App Branding & Navigation Tracker
                      SizedBox(
                        width: 440,
                        child: Column(
                          children: [
                            _buildAppBrandingCard(),
                            const SizedBox(height: 20),
                            Expanded(child: _buildNavigationTrackerCard()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 44),

                      // CENTER COLUMN: Smartphone Mockup
                      _buildSmartphoneMockup(),
                      const SizedBox(width: 44),

                      // RIGHT COLUMN: Feature Spotlight, Narration Box & Specs
                      Expanded(
                        child: Column(
                          children: [
                            _buildFeatureSpotlightCard(),
                            const SizedBox(height: 20),
                            _buildNarrationSubtitleBox(),
                            const SizedBox(height: 20),
                            _buildTechStackBar(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: const Text(
                'STACK & SCALE REMOTE INTERNSHIP 2026',
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'WEEK 02 • FINAL PROJECT DEMONSTRATION',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF14B8A6).withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_rounded, size: 16, color: Color(0xFF2DD4BF)),
              SizedBox(width: 8),
              Text(
                'PRESENTER: NOMAN',
                style: TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBrandingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0B172B).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1E3A5F).withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6536C7), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6536C7).withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SpendWise',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Personal Budget & Expense',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Offline-first personal finance platform engineered with Flutter, Material 3, and embedded SQLite for students & young professionals.',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTrackerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0B172B).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1E3A5F).withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DEMONSTRATION TIMELINE & MILESTONES',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: navItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final isActive = idx == model.activeNavIndex;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF0EA5E9).withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF0EA5E9).withValues(alpha: 0.6)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? const Color(0xFF0EA5E9)
                              : const Color(0xFF1E293B),
                        ),
                        child: Center(
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : const Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          navItems[idx],
                          style: TextStyle(
                            color: isActive ? Colors.white : const Color(0xFF94A3B8),
                            fontSize: 13.5,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartphoneMockup() {
    // Flagship phone bezel: width ~410px, height ~890px
    return Container(
      width: 410,
      height: 890,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(46),
        border: Border.all(
          color: const Color(0xFF334155),
          width: 6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          children: [
            // App Screenshot (Synchronously Decoded ui.Image)
            Positioned.fill(
              child: RawImage(
                image: appImage,
                fit: BoxFit.cover,
              ),
            ),

            // Top Dynamic Island Pill
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 120,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9).withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSpotlightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0B172B).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1E3A5F).withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              model.badge.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF38BDF8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            model.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            model.description,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),

          // Bullet points
          Column(
            children: model.bulletPoints.map((bp) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFF14B8A6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bp,
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrationSubtitleBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF071120).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF14B8A6).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF14B8A6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'AUTHENTIC VOICE NARRATION (NOMAN)',
                    style: TextStyle(
                      color: Color(0xFF2DD4BF),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  model.timeRange,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '"${model.narration}"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStackBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B172B).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF1E3A5F).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Framework: Flutter 3.x (Material 3)',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '•',
            style: TextStyle(color: Color(0xFF475569)),
          ),
          Text(
            'Database: SQLite (sqflite_ffi)',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '•',
            style: TextStyle(color: Color(0xFF475569)),
          ),
          Text(
            'Precision: Integer Paisas (PKR)',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '•',
            style: TextStyle(color: Color(0xFF475569)),
          ),
          Text(
            'Mode: 100% Offline',
            style: TextStyle(
              color: Color(0xFF38BDF8),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  setUpAll(() async {
    await loadRealFonts();
  });

  testWidgets('Render All 13 Synchronized Presentation Slides', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final outputDir = Directory('evidence/final_submission/video_frames');
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final slides = [
      // 1. Intro (00:00 - 00:20.5) = 20.5s
      const SlideModel(
        filename: 'slide_01.png',
        duration: 20.5,
        activeNavIndex: 0,
        screenshotPath: 'evidence/final_submission/01_dashboard.png',
        badge: 'Project Introduction',
        title: 'SpendWise — Fintech Expense & Budget Tracker',
        description: 'Offline-first personal finance application for students and early-career professionals.',
        bulletPoints: [
          'Engineered for Stack & Scale Remote Internship 2026 Week 02.',
          'Offline-first architecture with embedded SQLite database engine.',
          'Distinctive purple/violet fintech theme (#6536C7) with Material 3.',
        ],
        narration: 'Hello everyone, my name is Noman, and today I am presenting my internship project SpendWise: Personal Budget and Expense Tracker, developed using Flutter and Dart. SpendWise helps users manage their income, expenses, and monthly budgets.',
        timeRange: '00:00 - 00:20',
      ),

      // 2. Dashboard (00:20.5 - 00:30.0) = 9.5s
      const SlideModel(
        filename: 'slide_02.png',
        duration: 9.5,
        activeNavIndex: 0,
        screenshotPath: 'evidence/final_submission/01_dashboard.png',
        badge: 'Executive Dashboard',
        title: 'Real-Time Income, Expenses & Net Balance',
        description: 'Unified financial health cockpit calculating balances and budget progress instantly.',
        bulletPoints: [
          'Hero Net Balance card aggregating all recorded income minus expenses.',
          'Monthly income and expense summary cards with live calculation.',
          'Remaining budget progress indicator and recent transaction ledger.',
        ],
        narration: 'Here is the dashboard where users can view their total income, expenses, and balance.',
        timeRange: '00:21 - 00:30',
      ),

      // 3a. Add Income (00:30.0 - 00:36.5) = 6.5s
      const SlideModel(
        filename: 'slide_03a.png',
        duration: 6.5,
        activeNavIndex: 1,
        screenshotPath: 'evidence/final_submission/02_add_income.png',
        badge: 'Transaction Management',
        title: 'Income Recording & Minor Unit Conversion',
        description: 'Fast entry for salary, freelancing, and client payments with exact currency handling.',
        bulletPoints: [
          'Smooth toggle between Expense and Income transaction types.',
          'Dynamic category chips tailored to income streams (Salary, Freelance).',
          'Exact integer minor currency unit storage (1 PKR = 100 Paisas).',
        ],
        narration: 'Users can easily add income and expense transactions with amount, date, category, and note.',
        timeRange: '00:30 - 00:36',
      ),

      // 3b. Add Expense (00:36.5 - 00:43.0) = 6.5s
      const SlideModel(
        filename: 'slide_03b.png',
        duration: 6.5,
        activeNavIndex: 1,
        screenshotPath: 'evidence/final_submission/03_add_expense.png',
        badge: 'Expense Operations',
        title: 'Expense Recording & Date Picker Validation',
        description: 'Log daily spending across food, transport, bills, and shopping with notes and dates.',
        bulletPoints: [
          'Intuitive Material 3 date picker defaulting to current transaction time.',
          'Category selection with custom colored icons and distinct metadata.',
          'Immediate reactive update across Dashboard and History upon saving.',
        ],
        narration: 'Users can easily add income and expense transactions with amount, date, category, and note.',
        timeRange: '00:36 - 00:43',
      ),

      // 4a. Monthly Budgets (00:43.0 - 00:48.0) = 5.0s
      const SlideModel(
        filename: 'slide_04a.png',
        duration: 5.0,
        activeNavIndex: 2,
        screenshotPath: 'evidence/final_submission/04_monthly_budgets.png',
        badge: 'Monthly Budgeting',
        title: 'Category Spending Caps & Allocation',
        description: 'Set spending limits for each category to keep monthly expenditures disciplined.',
        bulletPoints: [
          'Interactive month-by-month budget allocation with SQLite storage.',
          'Total monthly budget overview showing spent, limit, and remaining.',
          'Duplicate prevention: only one budget cap per category per month.',
        ],
        narration: 'The app also allows users to create monthly budgets, tracking their spending, and see category-wise expense breakdowns.',
        timeRange: '00:43 - 00:48',
      ),

      // 4b. Budget Warning & Over-Budget (00:48.0 - 00:53.0) = 5.0s
      const SlideModel(
        filename: 'slide_04b.png',
        duration: 5.0,
        activeNavIndex: 2,
        screenshotPath: 'evidence/final_submission/05_budget_warning_overbudget.png',
        badge: 'Budget Warning System',
        title: 'Automated 80% Warning & 100% Danger Alerts',
        description: 'Real-time threshold monitoring alerts users before overspending occurs.',
        bulletPoints: [
          'On Track (<80%): Neutral primary status badge with remaining allowance.',
          'Warning (80%-99%): Yellow warning badge alerting user of nearing cap.',
          'Over Budget (≥100%): Red danger alert badge showing exact overspent amount.',
        ],
        narration: 'The app also allows users to create monthly budgets, tracking their spending, and see category-wise expense breakdowns.',
        timeRange: '00:48 - 00:53',
      ),

      // 5a. History & Filters (00:53.0 - 00:58.0) = 5.0s
      const SlideModel(
        filename: 'slide_05a.png',
        duration: 5.0,
        activeNavIndex: 3,
        screenshotPath: 'evidence/final_submission/06_history_combined_filters.png',
        badge: 'Audit Ledger',
        title: 'Month Navigation & Category Filtering',
        description: 'Easily filter through financial history across specific months and categories.',
        bulletPoints: [
          'Month selector navigation pills allowing smooth back-and-forth traversal.',
          'Category chip filter isolating specific spending channels like Food & Dining.',
          'Active filter count badge with one-tap "Clear All" shortcut.',
        ],
        narration: 'In the history section, users can filter transactions by month and category. They can also edit and delete transactions.',
        timeRange: '00:53 - 00:58',
      ),

      // 5b. Spending Visualization (00:58.0 - 01:03.5) = 5.5s
      const SlideModel(
        filename: 'slide_05b.png',
        duration: 5.5,
        activeNavIndex: 3,
        screenshotPath: 'evidence/final_submission/07_category_spending_visualization.png',
        badge: 'Data Visualization',
        title: 'Category-Wise Expense Breakdown & Percentages',
        description: 'Visual breakdown showing where money went each month with horizontal progress bars.',
        bulletPoints: [
          'Ranked category distribution sorted by highest expenditure first.',
          'Percentage share calculation: (Category Expense ÷ Total Expense) × 100%.',
          'Zero-division safe: handles empty months with clean illustrations.',
        ],
        narration: 'They can also edit and delete transactions.',
        timeRange: '00:58 - 01:03',
      ),

      // 6. SQLite Persistence (01:03.5 - 01:14.5) = 11.0s
      const SlideModel(
        filename: 'slide_06.png',
        duration: 11.0,
        activeNavIndex: 4,
        screenshotPath: 'evidence/final_submission/10_settings_storage.png',
        badge: 'Offline Architecture',
        title: 'Local SQLite Engine & State Persistence',
        description: 'Complete data permanence without cloud logins, network latency, or tracking.',
        bulletPoints: [
          'SQLite foreign key integrity enforced with PRAGMA foreign_keys = ON.',
          'Data persists permanently across app restarts and device reboots.',
          'In-app SQLite diagnostic tool verifying tables, counts, and health.',
        ],
        narration: 'SpendWise uses SQLite for local data storage, so information remains saved even after restarting the app.',
        timeRange: '01:03 - 01:14',
      ),

      // 7a. Form Validation (01:14.5 - 01:25.0) = 10.5s
      const SlideModel(
        filename: 'slide_07a.png',
        duration: 10.5,
        activeNavIndex: 5,
        screenshotPath: 'evidence/final_submission/09_validation_errors.png',
        badge: 'Form Integrity',
        title: 'Rigorous Form Validation & Error Handling',
        description: 'Strict input guards preventing invalid, negative, or corrupted transaction entries.',
        bulletPoints: [
          'Prevents empty submissions with clear inline Material 3 error messages.',
          'Rejects zero and negative amounts, enforcing valid numeric input.',
          'Immediate visual feedback ensuring users cannot submit invalid states.',
        ],
        narration: 'During this project, I learned about Flutter UI development, SQLite CRUD operations, form validation, budget calculations, and automated testing.',
        timeRange: '01:14 - 01:25',
      ),

      // 7b. Technical Learnings (01:25.0 - 01:36.0) = 11.0s
      const SlideModel(
        filename: 'slide_07b.png',
        duration: 11.0,
        activeNavIndex: 5,
        screenshotPath: 'evidence/final_submission/01_dashboard.png',
        badge: 'Quality Assurance',
        title: 'Automated Testing Suite (37/37 Passing)',
        description: 'Comprehensive test coverage across models, SQLite repository, controllers, and UI.',
        bulletPoints: [
          '37 automated unit, widget, and database tests executing in under 10s.',
          'Zero Flutter analyzer warnings or hints (flutter analyze passes cleanly).',
          'Production-ready APK build completed without build errors.',
        ],
        narration: 'During this project, I learned about Flutter UI development, SQLite CRUD operations, form validation, budget calculations, and automated testing.',
        timeRange: '01:25 - 01:36',
      ),

      // 8. Engineering Challenges (01:36.0 - 01:51.0) = 15.0s
      const SlideModel(
        filename: 'slide_08.png',
        duration: 15.0,
        activeNavIndex: 6,
        screenshotPath: 'evidence/final_submission/11_history_all.png',
        badge: 'Engineering Challenges',
        title: 'UI Synchronization & Floating-Point Prevention',
        description: 'Overcame complex database-to-UI reactive state challenges and arithmetic rounding.',
        bulletPoints: [
          'Eliminated floating-point rounding bugs by adopting integer minor units everywhere.',
          'Synchronized multi-table SQLite queries with ChangeNotifier controller state.',
          'Handled edge cases: month boundaries, leap years, empty months, and budget limits.',
        ],
        narration: 'One challenge was connecting the database with the user interface and maintaining accurate calculations. I solved this by improving the database logic and testing with different scenarios.',
        timeRange: '01:36 - 01:51',
      ),

      // 9. Conclusion & Handover (01:51.0 - 02:03.0) = 12.0s
      const SlideModel(
        filename: 'slide_09.png',
        duration: 12.0,
        activeNavIndex: 7,
        screenshotPath: 'evidence/final_submission/01_dashboard.png',
        badge: 'Final Deliverable',
        title: 'SpendWise Production Handover Complete',
        description: 'Successfully concluded Week 02 of the Stack & Scale Remote Internship 2026.',
        bulletPoints: [
          'Complete offline-first personal budget and expense tracking application.',
          'Full technical documentation, architectural diagrams, and test suite.',
          'Authentic video demonstration synchronized with presenter audio.',
        ],
        narration: 'Overall, this project improved my Flutter development and problem-solving skills. Thank you for watching my project demonstration.',
        timeRange: '01:51 - 02:02',
      ),
    ];

    final repaintKey = GlobalKey();

    for (int i = 0; i < slides.length; i++) {
      final slide = slides[i];
      final appImage = (await tester.runAsync(() => loadUiImage(slide.screenshotPath)))!;

      await tester.pumpWidget(
        RepaintBoundary(
          key: repaintKey,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: PresentationSlideWidget(
                model: slide,
                appImage: appImage,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();
        final path = 'evidence/final_submission/video_frames/${slide.filename}';
        File(path).writeAsBytesSync(bytes);
        print('Rendered [${i + 1}/${slides.length}] $path (${bytes.length} bytes, duration: ${slide.duration}s)');
      });
    }

    // Write concat file for ffmpeg
    final concatBuffer = StringBuffer();
    for (final slide in slides) {
      concatBuffer.writeln("file '${slide.filename}'");
      concatBuffer.writeln("duration ${slide.duration}");
    }
    // Repeat last frame for ffmpeg concat requirement
    concatBuffer.writeln("file '${slides.last.filename}'");
    File('evidence/final_submission/video_frames/slides_concat.txt')
        .writeAsStringSync(concatBuffer.toString());

    print('ALL 13 PRESENTATION SLIDES & CONCAT MANIFEST RENDERED SUCCESSFULLY!');
  });
}
