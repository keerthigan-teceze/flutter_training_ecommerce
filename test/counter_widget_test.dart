import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shopping/main_counter.dart'; // 👈 CHANGE if needed

void main() {
  testWidgets('counter UI test', (tester) async {
    await tester.pumpWidget(const ShoppingCounterApp());

    // ✅ wait for UI to render
    await tester.pumpAndSettle();

    // initial state
    expect(find.text('0'), findsOneWidget);

    // ✅ ensure button exists
    expect(find.byKey(const Key('incrementBtn')), findsOneWidget);

    // tap increment
    await tester.tap(find.byKey(const Key('incrementBtn')));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);

    // tap decrement
    await tester.tap(find.byKey(const Key('decrementBtn')));
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
  });
}