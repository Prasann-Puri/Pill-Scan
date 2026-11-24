import '../core/strings.dart';
import '../domain/check_result.dart';
import '../domain/medicine_search_result.dart';
import 'medicine_repository.dart';
import 'mock_data.dart';

/// Phase 3 mock implementation of [MedicineRepository].
///
/// All logic is deterministic and data-driven from [mock_data.dart].
/// No medical knowledge is encoded here — the interaction table is
/// the only source of truth for what is flagged.
///
/// Phase 5: replace with ApiMedicineRepository; screens are unchanged.
class MockMedicineRepository implements MedicineRepository {
  // Parse all mock medicines once at construction.
  final List<MedicineSearchResult> _all = kMockMedicineRows
      .map((r) => MedicineSearchResult.fromJson(r))
      .toList();

  @override
  Future<List<MedicineSearchResult>> search(
    String query, {
    int limit = 5,
  }) async {
    // Simulate a small network delay so the UI shows loading state.
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (query.trim().isEmpty) return [];

    final q = query.toLowerCase();
    final results = _all.where((m) {
      final name = m.brandName.toLowerCase();
      // Check brand name AND each salt name.
      final saltMatch = m.salts.any((s) => s.name.contains(q));
      return name.contains(q) || saltMatch;
    }).toList();

    return results.take(limit).toList();
  }

  @override
  Future<CheckResult> check(List<int> medicineIds) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // De-duplicate IDs.
    final ids = medicineIds.toSet().toList();

    // Resolve each id → medicine; unknown ids go into unchecked.
    final Map<int, MedicineSearchResult?> resolved = {
      for (final id in ids)
        id: _all.cast<MedicineSearchResult?>().firstWhere(
              (m) => m!.medicineId == id,
              orElse: () => null,
            ),
    };

    final uncheckedRows = <Map<String, dynamic>>[];
    // Build salt → list of medicine_ids map (only for medicines with salts).
    final Map<String, List<int>> saltToMeds = {};

    for (final entry in resolved.entries) {
      final med = entry.value;
      if (med == null) {
        uncheckedRows.add({
          'medicine_id': entry.key,
          'reason': 'Medicine not found in database',
        });
        continue;
      }
      if (med.salts.isEmpty) {
        uncheckedRows.add({
          'medicine_id': entry.key,
          'reason': 'Active ingredient not found',
        });
        continue;
      }
      for (final salt in med.salts) {
        saltToMeds.putIfAbsent(salt.name, () => []).add(med.medicineId);
      }
    }

    // Duplicate detection: same salt in 2+ different medicines.
    final duplicateRows = <Map<String, dynamic>>[];
    for (final entry in saltToMeds.entries) {
      if (entry.value.length > 1) {
        duplicateRows.add({
          'salt': entry.key,
          'medicine_ids': entry.value,
          'severity': 'moderate',
          'message':
              'More than one of your medicines contains ${entry.key}. '
              'Please ask your doctor.',
        });
      }
    }

    // Interaction detection — only aspirin + warfarin in mock data.
    final interactionRows = <Map<String, dynamic>>[];
    final saltNames = saltToMeds.keys.toSet();
    if (saltNames.contains('aspirin') && saltNames.contains('warfarin')) {
      interactionRows.add({
        ...kMockInteractionAspirinWarfarin,
        'medicine_ids': [
          ...saltToMeds['aspirin']!,
          ...saltToMeds['warfarin']!,
        ],
      });
    }

    // Determine declared overall status.
    String declaredOverall;
    String summary;

    if (interactionRows.any((r) => r['severity'] == 'major')) {
      declaredOverall = 'red';
      summary =
          'Two of your medicines should not be taken together without '
          'asking your doctor.';
    } else if (duplicateRows.isNotEmpty || interactionRows.isNotEmpty) {
      declaredOverall = 'yellow';
      summary =
          'Two of your medicines share the same ingredient. '
          'Please ask your doctor.';
    } else if (uncheckedRows.isNotEmpty) {
      declaredOverall = 'grey';
      summary =
          'One or more medicines could not be checked. '
          'Please ask your doctor or pharmacist.';
    } else {
      declaredOverall = 'green';
      summary = 'No known problem found with your medicines.';
    }

    // Build the JSON map and parse through CheckResult.fromJson so that
    // client-side safety guards run on EVERY result — including mocks.
    final json = <String, dynamic>{
      'overall': declaredOverall,
      'summary': summary,
      'duplicates': duplicateRows,
      'interactions': interactionRows,
      'unchecked': uncheckedRows,
      'data_version': kMockDataVersion,
      'disclaimer': Strings.disclaimer,
    };

    return CheckResult.fromJson(json);
  }
}
