import 'package:flutter_test/flutter_test.dart';
import 'package:pillsafe/domain/check_result.dart';
import 'package:pillsafe/core/strings.dart';

/// Unit tests for CheckResult safety guards in fromJson.
/// These tests verify that the client NEVER shows a status softer
/// than what the data warrants (Phase 3 spec / README §5).
void main() {
  group('CheckResult safety guards', () {
    Map<String, dynamic> _base({
      required String overall,
      List<Map<String, dynamic>> duplicates = const [],
      List<Map<String, dynamic>> interactions = const [],
      List<Map<String, dynamic>> unchecked = const [],
    }) =>
        {
          'overall': overall,
          'summary': 'Test summary',
          'duplicates': duplicates,
          'interactions': interactions,
          'unchecked': unchecked,
          'data_version': 'test',
          'disclaimer': Strings.disclaimer,
        };

    test('Guard 1: unknown overall becomes grey', () {
      final result = CheckResult.fromJson(_base(overall: 'bogus'));
      expect(result.overall, OverallStatus.grey);
    });

    test('Guard 1: missing overall (null) becomes grey', () {
      final json = _base(overall: 'green')..remove('overall');
      final result = CheckResult.fromJson(json);
      expect(result.overall, OverallStatus.grey);
    });

    test('Guard 2: green with unchecked medicine becomes grey', () {
      final result = CheckResult.fromJson(_base(
        overall: 'green',
        unchecked: [
          {'medicine_id': 999, 'reason': 'Not found'}
        ],
      ));
      expect(result.overall, OverallStatus.grey);
    });

    test('Guard 2: yellow with unchecked stays yellow (not softened to grey)', () {
      final result = CheckResult.fromJson(_base(
        overall: 'yellow',
        unchecked: [
          {'medicine_id': 999, 'reason': 'Not found'}
        ],
        duplicates: [
          {
            'salt': 'paracetamol',
            'medicine_ids': [101, 102],
            'severity': 'moderate',
            'message': 'Duplicate',
          }
        ],
      ));
      expect(result.overall, OverallStatus.yellow);
    });

    test('Guard 3: green with a duplicate finding becomes yellow', () {
      final result = CheckResult.fromJson(_base(
        overall: 'green',
        duplicates: [
          {
            'salt': 'paracetamol',
            'medicine_ids': [101, 102],
            'severity': 'moderate',
            'message': 'Duplicate',
          }
        ],
      ));
      expect(result.overall, OverallStatus.yellow);
    });

    test('Guard 3: green with an interaction becomes at least yellow', () {
      final result = CheckResult.fromJson(_base(
        overall: 'green',
        interactions: [
          {
            'salt_a': 'aspirin',
            'salt_b': 'warfarin',
            'medicine_ids': [201, 202],
            'severity': 'minor',
            'description': 'Placeholder',
            'source': 'test',
            'source_date': null,
          }
        ],
      ));
      expect(result.overall, OverallStatus.yellow);
    });

    test('Guard 4: any major interaction becomes red regardless of declared status', () {
      final result = CheckResult.fromJson(_base(
        overall: 'yellow', // declared yellow, but guard must upgrade to red
        interactions: [
          {
            'salt_a': 'aspirin',
            'salt_b': 'warfarin',
            'medicine_ids': [201, 202],
            'severity': 'major',
            'description': 'Placeholder',
            'source': 'test',
            'source_date': null,
          }
        ],
      ));
      expect(result.overall, OverallStatus.red);
    });

    test('Guard 4: declared green with major interaction becomes red', () {
      final result = CheckResult.fromJson(_base(
        overall: 'green',
        interactions: [
          {
            'salt_a': 'aspirin',
            'salt_b': 'warfarin',
            'medicine_ids': [201, 202],
            'severity': 'major',
            'description': 'Placeholder',
            'source': 'test',
            'source_date': null,
          }
        ],
      ));
      expect(result.overall, OverallStatus.red);
    });

    test('Clean result with all identified medicines stays green', () {
      final result = CheckResult.fromJson(_base(overall: 'green'));
      expect(result.overall, OverallStatus.green);
    });
  });
}
