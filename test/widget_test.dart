import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shopping/main.dart';
import 'package:shopping/models/offline_product.dart';
import 'package:shopping/providers/connectivity_provider.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for tests in a temporary directory
    final tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OfflineProductAdapter());
    }
  });

  testWidgets('App starts and shows loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override connectivity providers to prevent infinite loops/timeouts in pumpAndSettle
          connectivityProvider.overrideWith((ref) => Stream.value(true)),
          serverStatusProvider.overrideWith((ref) => Stream.value(true)),
          // We can also override isFullyOnlineProvider directly
          isFullyOnlineProvider.overrideWithValue(true),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that our app starts (it shows a loading indicator initially while auth is null)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // We can use pump() instead of pumpAndSettle() if we expect things to stay in loading state
    await tester.pump();
  });
}