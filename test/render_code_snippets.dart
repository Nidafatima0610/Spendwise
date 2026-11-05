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
}

Widget buildCodeCard(String title, List<TextSpan> spans) {
  return Container(
    width: 900,
    padding: const EdgeInsets.all(24),
    color: const Color(0xFF0D1117),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titlebar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF21262D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFF30363D)),
              ),
            ),
            child: Row(
              children: [
                Row(
                  children: [
                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code Pre
          Padding(
            padding: const EdgeInsets.all(22),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFFC9D1D9),
                ),
                children: spans,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await loadRealFonts();
  });

  testWidgets('Render Additional Code Evidence Screenshots', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repaintKey = GlobalKey();

    // 1. Budget Controller Code
    final budgetSpans = [
      const TextSpan(text: '/// Loads all budgets for active month and computes threshold alerts\n', style: TextStyle(color: Color(0xFF8B949E), fontStyle: FontStyle.italic)),
      const TextSpan(text: 'Future', style: TextStyle(color: Color(0xFF79C0FF))),
      const TextSpan(text: '<void> '),
      const TextSpan(text: '_loadBudgetsAndMetrics', style: TextStyle(color: Color(0xFFD2A8FF))),
      const TextSpan(text: '() ', style: TextStyle(color: Color(0xFFC9D1D9))),
      const TextSpan(text: 'async ', style: TextStyle(color: Color(0xFFFF7B72), fontWeight: FontWeight.bold)),
      const TextSpan(text: '{\n  _budgets = ', style: TextStyle(color: Color(0xFFC9D1D9))),
      const TextSpan(text: 'await ', style: TextStyle(color: Color(0xFFFF7B72), fontWeight: FontWeight.bold)),
      const TextSpan(text: '_dbService.getBudgetsByMonth(_selectedMonthYear);\n\n  int totalCap = 0;\n  int totalSpent = 0;\n  int overCount = 0;\n\n  for (final b in _budgets) {\n    totalCap += b.limitAmount;\n    totalSpent += b.spentAmount;\n    if (b.isOverBudget) {\n      overCount++; // Real-time danger trigger\n    }\n  }\n\n  _totalBudgetCapMinor = totalCap;\n  _totalBudgetSpentMinor = totalSpent;\n  _overBudgetCount = overCount;\n}\n\n', style: TextStyle(color: Color(0xFFC9D1D9))),
      const TextSpan(text: '/// Threshold status getters for real-time visual alerts\n', style: TextStyle(color: Color(0xFF8B949E), fontStyle: FontStyle.italic)),
      const TextSpan(text: 'bool ', style: TextStyle(color: Color(0xFF79C0FF))),
      const TextSpan(text: 'get ', style: TextStyle(color: Color(0xFFFF7B72), fontWeight: FontWeight.bold)),
      const TextSpan(text: 'isWarning ', style: TextStyle(color: Color(0xFFD2A8FF))),
      const TextSpan(text: '=> spentPercentage >= 80.0 && spentPercentage < 100.0;\n', style: TextStyle(color: Color(0xFFC9D1D9))),
      const TextSpan(text: 'bool ', style: TextStyle(color: Color(0xFF79C0FF))),
      const TextSpan(text: 'get ', style: TextStyle(color: Color(0xFFFF7B72), fontWeight: FontWeight.bold)),
      const TextSpan(text: 'isOverBudget ', style: TextStyle(color: Color(0xFFD2A8FF))),
      const TextSpan(text: '=> spentAmount >= limitAmount;\n', style: TextStyle(color: Color(0xFFC9D1D9))),
      const TextSpan(text: 'double ', style: TextStyle(color: Color(0xFF79C0FF))),
      const TextSpan(text: 'get ', style: TextStyle(color: Color(0xFFFF7B72), fontWeight: FontWeight.bold)),
      const TextSpan(text: 'spentPercentage ', style: TextStyle(color: Color(0xFFD2A8FF))),
      const TextSpan(text: '=> limitAmount > 0 ? (spentAmount / limitAmount) * 100 : 0.0;\n', style: TextStyle(color: Color(0xFFC9D1D9))),
    ];

    await tester.pumpWidget(
      RepaintBoundary(
        key: repaintKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: const Color(0xFF0D1117),
            body: Center(
              child: buildCodeCard('lib/core/controllers/budget_controller.dart — Budget Calculations & Thresholds', budgetSpans),
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
      File('evidence/code/04_budget_controller_evidence.png').writeAsBytesSync(byteData!.buffer.asUint8List());
      print('Saved evidence/code/04_budget_controller_evidence.png');
    });

    // 2. History Filter & Spending Visualization Code
    final vizSpans = [
      const TextSpan(text: '/// Calculates category percentage share with zero-division safeguard\n', style: TextStyle(color: Color(0xFF8B949E), fontStyle: FontStyle.italic)),
      const TextSpan(text: 'double ', style: TextStyle(color: Color(0xFF79C0FF))),
      const TextSpan(text: '_calculatePercentage', style: TextStyle(color: Color(0xFFD2A8FF))),
      const TextSpan(text: '(int categorySpentMinor, int totalMonthlyExpenseMinor) {\n  if (totalMonthlyExpenseMinor <= 0) return 0.0;\n  final double percentage = (categorySpentMinor / totalMonthlyExpenseMinor) * 100.0;\n  return percentage.clamp(0.0, 100.0);\n}\n\n', style: TextStyle(color: Color(0xFFC9D1D9))),
      const TextSpan(text: '/// Dual month and category filtering query in HistoryScreen\n', style: TextStyle(color: Color(0xFF8B949E), fontStyle: FontStyle.italic)),
      const TextSpan(text: 'List', style: TextStyle(color: Color(0xFF79C0FF))),
      const TextSpan(text: '<TransactionModel> ', style: TextStyle(color: Color(0xFFC9D1D9))),
      const TextSpan(text: 'get ', style: TextStyle(color: Color(0xFFFF7B72), fontWeight: FontWeight.bold)),
      const TextSpan(text: 'filteredTransactions ', style: TextStyle(color: Color(0xFFD2A8FF))),
      const TextSpan(text: '{\n  return _controller.transactions.where((t) {\n    final matchMonth = DateFormatter.toMonthYearKey(t.date) == _selectedMonthYear;\n    final matchCat = _selectedCategoryId == null || t.categoryId == _selectedCategoryId;\n    return matchMonth && matchCat;\n  }).toList();\n}\n', style: TextStyle(color: Color(0xFFC9D1D9))),
    ];

    await tester.pumpWidget(
      RepaintBoundary(
        key: repaintKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: const Color(0xFF0D1117),
            body: Center(
              child: buildCodeCard('lib/features/history/widgets/category_spending_visualization.dart — Filters & Analytics', vizSpans),
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
      File('evidence/code/05_history_and_viz_evidence.png').writeAsBytesSync(byteData!.buffer.asUint8List());
      print('Saved evidence/code/05_history_and_viz_evidence.png');
    });
  });
}
