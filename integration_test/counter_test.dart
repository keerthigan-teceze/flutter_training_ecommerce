import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:shopping/main_counter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full counter flow test', (tester) async {
    await tester.pumpWidget(const ShoppingCounterApp());

    // ✅ WAIT FOR UI
    await tester.pumpAndSettle();

    // initial state
    expect(find.text('0'), findsOneWidget);

    // ✅ INCREMENT (SAFE)
    final incBtn = find.byKey(const Key('incrementBtn'));
    expect(incBtn, findsOneWidget);

    await tester.ensureVisible(incBtn);
    await tester.tap(incBtn);
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);

    // ✅ DECREMENT (SAFE)
    final decBtn = find.byKey(const Key('decrementBtn'));
    expect(decBtn, findsOneWidget);

    await tester.ensureVisible(decBtn);
    await tester.tap(decBtn);
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
  });
}