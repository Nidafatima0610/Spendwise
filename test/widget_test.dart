import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spend_wise/app/app.dart';
import 'package:spend_wise/core/constants/app_strings.dart';
import 'package:spend_wise/models/category_model.dart';
import 'package:spend_wise/models/transaction_model.dart';
import 'package:spend_wise/core/utils/currency_formatter.dart';

void main() {
  group('SpendWise App & Navigation Tests', () {
    testWidgets('App renders Dashboard and bottom navigation destinations',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SpendWiseApp());
      await tester.pumpAndSettle();

      // Verify Welcome greeting and default user name
      expect(find.text(AppStrings.greetingPrefix), findsOneWidget);
      expect(find.text(AppStrings.defaultUserName), findsOneWidget);

      // Verify Navigation items exist by keys
      expect(find.byKey(const Key('nav_dashboard')), findsOneWidget);
      expect(find.byKey(const Key('nav_history')), findsOneWidget);
      expect(find.byKey(const Key('nav_add')), findsOneWidget);
      expect(find.byKey(const Key('nav_budgets')), findsOneWidget);
      expect(find.byKey(const Key('nav_settings')), findsOneWidget);

      // Tap on History tab via key
      await tester.tap(find.byKey(const Key('nav_history')));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.historyTitle), findsOneWidget);

      // Tap on Budgets tab via key
      await tester.tap(find.byKey(const Key('nav_budgets')));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.budgetsTitle), findsOneWidget);

      // Tap on Settings tab via key
      await tester.tap(find.byKey(const Key('nav_settings')));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.settingsTitle), findsOneWidget);

      // Tap on Add Transaction tab via central plus button key
      await tester.tap(find.byKey(const Key('nav_add')));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.addTransactionTitle), findsOneWidget);

      // Tap on Dashboard tab to return home
      await tester.tap(find.byKey(const Key('nav_dashboard')));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.greetingPrefix), findsOneWidget);
    });
  });

  group('Model & Minor Currency Unit Tests', () {
    test('Transaction Model minor currency units conversion', () {
      final tx = TransactionModel.fromMajorUnits(
        id: 'test_1',
        type: TransactionType.expense,
        majorAmount: 2500.50,
        date: DateTime(2026, 11, 2),
        categoryId: 'cat_food',
        note: 'Team lunch',
      );

      // 2500.50 PKR must be stored as 250050 paisas (minor units)
      expect(tx.amount, 250050);
      expect(tx.amountInMajorUnits, 2500.50);
      expect(tx.isExpense, isTrue);
      expect(tx.isIncome, isFalse);

      // Map serialization & deserialization
      final map = tx.toMap();
      final fromMap = TransactionModel.fromMap(map);
      expect(fromMap.id, tx.id);
      expect(fromMap.amount, 250050);
      expect(fromMap.type, TransactionType.expense);
    });

    test('Category Model serialization and icon resolution', () {
      const cat = CategoryModel(
        id: 'cat_food',
        name: 'Food & Dining',
        type: TransactionType.expense,
        iconName: 'food',
        colorValue: 0xFFF59E0B,
      );

      expect(cat.iconData, Icons.restaurant_rounded);
      expect(cat.color, const Color(0xFFF59E0B));

      final map = cat.toMap();
      final deserialized = CategoryModel.fromMap(map);
      expect(deserialized.id, 'cat_food');
      expect(deserialized.name, 'Food & Dining');
      expect(deserialized.type, TransactionType.expense);
    });

    test('CurrencyFormatter parses input and formats PKR accurately', () {
      expect(CurrencyFormatter.parseToMinorUnits('1500'), 150000);
      expect(CurrencyFormatter.parseToMinorUnits('1,500.25'), 150025);
      expect(CurrencyFormatter.parseToMinorUnits(''), 0);

      final formatted = CurrencyFormatter.formatMinorUnits(150025);
      expect(formatted, contains('1,500.25'));
    });
  });
}
