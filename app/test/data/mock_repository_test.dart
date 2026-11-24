import 'package:flutter_test/flutter_test.dart';
import 'package:pillsafe/data/mock_repository.dart';
import 'package:pillsafe/domain/check_result.dart';

/// Unit tests for mock check logic.
/// Verifies that the mock repository returns the correct status
/// for each scenario described in the Phase 3 spec.
void main() {
  late MockMedicineRepository repo;

  setUp(() => repo = MockMedicineRepository());

  group('MockMedicineRepository.check()', () {
    test('Two paracetamol medicines → yellow with duplicate', () async {
      // Crocin 500 (id:101) and Dolo 650 (id:102) both contain paracetamol.
      final result = await repo.check([101, 102]);
      expect(result.overall, OverallStatus.yellow);
      expect(result.duplicates, isNotEmpty);
      expect(result.duplicates.first.salt, 'paracetamol');
      expect(result.interactions, isEmpty);
    });

    test('Aspirin + warfarin → red', () async {
      // Sample Aspirin 75mg (id:201) + Sample Warfarin 5mg (id:202).
      final result = await repo.check([201, 202]);
      expect(result.overall, OverallStatus.red);
      expect(result.interactions, isNotEmpty);
      expect(result.interactions.first.severity, 'major');
      expect(result.duplicates, isEmpty);
    });

    test('Unknown Strip alone → grey', () async {
      // Unknown Strip (id:999) has no active ingredient.
      final result = await repo.check([999]);
      expect(result.overall, OverallStatus.grey);
      expect(result.unchecked, isNotEmpty);
      expect(result.duplicates, isEmpty);
      expect(result.interactions, isEmpty);
    });

    test('Single known medicine → green', () async {
      // Crocin 500 alone — identified, no interactions.
      final result = await repo.check([101]);
      expect(result.overall, OverallStatus.green);
      expect(result.duplicates, isEmpty);
      expect(result.interactions, isEmpty);
      expect(result.unchecked, isEmpty);
    });

    test('Empty list → green (no findings)', () async {
      final result = await repo.check([]);
      expect(result.overall, OverallStatus.green);
    });

    test('Known + unknown → grey (not green)', () async {
      final result = await repo.check([101, 999]);
      // Green would be wrong — 999 is unchecked.
      expect(result.overall, isNot(OverallStatus.green));
    });
  });

  group('MockMedicineRepository.search()', () {
    test('Empty query returns empty list', () async {
      final results = await repo.search('');
      expect(results, isEmpty);
    });

    test('Search "crocin" returns Crocin 500', () async {
      final results = await repo.search('crocin');
      expect(results.any((r) => r.brandName == 'Crocin 500'), isTrue);
    });

    test('Search "paracetamol" matches by salt name', () async {
      final results = await repo.search('paracetamol');
      expect(results, isNotEmpty);
    });

    test('Search "zzz" returns empty', () async {
      final results = await repo.search('zzz');
      expect(results, isEmpty);
    });
  });
}
