import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillsafe/core/strings.dart';
import 'package:pillsafe/domain/check_result.dart';
import 'package:pillsafe/widgets/status_banner.dart';

void main() {
  Widget wrap(OverallStatus status) => MaterialApp(
        home: Scaffold(body: StatusBanner(status: status)),
      );

  group('StatusBanner — every status shows both icon AND word', () {
    testWidgets('green: check icon + word', (tester) async {
      await tester.pumpWidget(wrap(OverallStatus.green));
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.text(Strings.statusGreen), findsOneWidget);
    });

    testWidgets('yellow: warning icon + word', (tester) async {
      await tester.pumpWidget(wrap(OverallStatus.yellow));
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
      expect(find.text(Strings.statusYellow), findsOneWidget);
    });

    testWidgets('red: block icon + word', (tester) async {
      await tester.pumpWidget(wrap(OverallStatus.red));
      expect(find.byIcon(Icons.block_outlined), findsOneWidget);
      expect(find.text(Strings.statusRed), findsOneWidget);
    });

    testWidgets('grey: help icon + word', (tester) async {
      await tester.pumpWidget(wrap(OverallStatus.grey));
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.text(Strings.statusGrey), findsOneWidget);
    });
  });
}
