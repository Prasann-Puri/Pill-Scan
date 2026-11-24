import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillsafe/core/strings.dart';
import 'package:pillsafe/data/mock_repository.dart';
import 'package:pillsafe/domain/medicine_search_result.dart';
import 'package:pillsafe/domain/salt.dart';
import 'package:pillsafe/features/confirm/confirm_screen.dart';
import 'package:pillsafe/providers.dart';

void main() {
  final testMedicine = MedicineSearchResult(
    medicineId: 101,
    brandName: 'Crocin 500',
    salts: const [Salt(id: 7, name: 'paracetamol', strengthText: '500 mg')],
    matchScore: 1.0,
  );

  Widget wrapConfirm(MedicineSearchResult medicine) => ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(MockMedicineRepository()),
        ],
        child: MaterialApp(home: ConfirmScreen(medicine: medicine)),
      );

  group('ConfirmScreen — medicine added only after "Yes, add it"', () {
    testWidgets('medicine NOT in list before tapping Yes', (tester) async {
      final container = ProviderContainer(
        overrides: [
          repositoryProvider.overrideWithValue(MockMedicineRepository()),
        ],
      );
      addTearDown(container.dispose);

      // Confirm screen is shown but user hasn't tapped anything.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: ConfirmScreen(medicine: testMedicine)),
        ),
      );

      // List must still be empty.
      final list = container.read(medicineListProvider);
      expect(list, isEmpty);
    });

    testWidgets('medicine IS in list after tapping Yes, add it', (tester) async {
      final container = ProviderContainer(
        overrides: [
          repositoryProvider.overrideWithValue(MockMedicineRepository()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: ConfirmScreen(medicine: testMedicine)),
        ),
      );

      // Tap "Yes, add it".
      await tester.tap(find.text(Strings.confirmYes));
      await tester.pumpAndSettle();

      final list = container.read(medicineListProvider);
      expect(list.length, 1);
      expect(list.first.medicineId, 101);
    });

    testWidgets('"No, search again" does NOT add medicine', (tester) async {
      final container = ProviderContainer(
        overrides: [
          repositoryProvider.overrideWithValue(MockMedicineRepository()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: ConfirmScreen(medicine: testMedicine)),
        ),
      );

      await tester.tap(find.text(Strings.confirmNo));
      await tester.pumpAndSettle();

      final list = container.read(medicineListProvider);
      expect(list, isEmpty);
    });
  });
}
