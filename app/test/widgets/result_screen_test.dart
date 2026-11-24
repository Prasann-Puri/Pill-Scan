import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillsafe/core/strings.dart';
import 'package:pillsafe/domain/check_result.dart';
import 'package:pillsafe/features/result/result_screen.dart';
import 'package:pillsafe/widgets/disclaimer_bar.dart';

CheckResult _makeResult(OverallStatus status) => CheckResult(
      overall: status,
      summary: 'Test summary.',
      duplicates: const [],
      interactions: const [],
      unchecked: const [],
      dataVersion: 'test',
      disclaimer: Strings.disclaimer,
    );

CheckResult _redResult() => CheckResult(
      overall: OverallStatus.red,
      summary: 'Two of your medicines should not be taken together.',
      duplicates: const [],
      interactions: const [
        InteractionFinding(
          saltA: 'aspirin',
          saltB: 'warfarin',
          medicineIds: [201, 202],
          severity: 'major',
          description: '[PLACEHOLDER]',
          source: 'test',
        )
      ],
      unchecked: const [],
      dataVersion: 'test',
      disclaimer: Strings.disclaimer,
    );

void main() {
  Widget wrap(CheckResult result) =>
      MaterialApp(home: ResultScreen(result: result));

  group('ResultScreen', () {
    testWidgets('always shows DisclaimerBar for green', (tester) async {
      await tester.pumpWidget(wrap(_makeResult(OverallStatus.green)));
      expect(find.byType(DisclaimerBar), findsOneWidget);
      expect(find.text(Strings.disclaimer), findsOneWidget);
    });

    testWidgets('always shows DisclaimerBar for red', (tester) async {
      await tester.pumpWidget(wrap(_redResult()));
      expect(find.byType(DisclaimerBar), findsOneWidget);
      expect(find.text(Strings.disclaimer), findsOneWidget);
    });

    testWidgets('always shows DisclaimerBar for grey', (tester) async {
      await tester.pumpWidget(wrap(_makeResult(OverallStatus.grey)));
      expect(find.byType(DisclaimerBar), findsOneWidget);
    });

    testWidgets('red result shows Call button', (tester) async {
      await tester.pumpWidget(wrap(_redResult()));
      expect(find.text(Strings.resultCallButton), findsOneWidget);
    });

    testWidgets('green result does NOT show Call button', (tester) async {
      await tester.pumpWidget(wrap(_makeResult(OverallStatus.green)));
      expect(find.text(Strings.resultCallButton), findsNothing);
    });

    testWidgets('yellow result does NOT show Call button', (tester) async {
      await tester.pumpWidget(wrap(_makeResult(OverallStatus.yellow)));
      expect(find.text(Strings.resultCallButton), findsNothing);
    });

    testWidgets('shows StatusBanner', (tester) async {
      await tester.pumpWidget(wrap(_makeResult(OverallStatus.green)));
      expect(find.text(Strings.statusGreen), findsOneWidget);
    });

    testWidgets('Tell me more button is at least 64dp tall', (tester) async {
      await tester.pumpWidget(wrap(_makeResult(OverallStatus.green)));
      final btn = find.ancestor(
        of: find.text(Strings.resultTellMore),
        matching: find.byType(OutlinedButton),
      );
      expect(btn, findsOneWidget);
      final size = tester.getSize(btn);
      expect(size.height, greaterThanOrEqualTo(64));
    });
  });
}
