import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillsafe/core/strings.dart';
import 'package:pillsafe/features/home/home_screen.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('shows Scan medicine button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: HomeScreen()),
        ),
      );
      expect(find.text(Strings.homeScan), findsOneWidget);
    });

    testWidgets('shows My medicines button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: HomeScreen()),
        ),
      );
      expect(find.text(Strings.homeMyMeds), findsOneWidget);
    });

    testWidgets('Scan medicine button is at least 64dp tall', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: HomeScreen()),
        ),
      );
      // Find the ElevatedButton containing "Scan medicine".
      final button = find.ancestor(
        of: find.text(Strings.homeScan),
        matching: find.byType(ElevatedButton),
      );
      expect(button, findsOneWidget);
      final size = tester.getSize(button);
      expect(size.height, greaterThanOrEqualTo(64));
    });
  });
}
