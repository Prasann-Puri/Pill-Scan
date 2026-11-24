import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'domain/my_medicine.dart';
import 'data/medicine_repository.dart';
import 'data/mock_repository.dart';

// ── Repository provider ───────────────────────────────────────────────────────

/// Provides the active [MedicineRepository].
/// Override in tests: `overrides: [repositoryProvider.overrideWithValue(...)]`
/// Override in Phase 5: swap MockMedicineRepository for ApiMedicineRepository.
final repositoryProvider = Provider<MedicineRepository>(
  (ref) => MockMedicineRepository(),
);

// ── Medicine list ─────────────────────────────────────────────────────────────

/// Holds the list of medicines the user has confirmed.
/// Stored in memory for Phase 3; SQLite persistence added in Phase 5.
class MedicineListNotifier extends StateNotifier<List<MyMedicine>> {
  MedicineListNotifier() : super([]);

  /// Add a confirmed medicine. Ignores exact duplicate IDs.
  void add(MyMedicine medicine) {
    if (state.any((m) => m.medicineId == medicine.medicineId)) return;
    state = [...state, medicine];
  }

  /// Remove a medicine by ID.
  void remove(int medicineId) {
    state = state.where((m) => m.medicineId != medicineId).toList();
  }
}

final medicineListProvider =
    StateNotifierProvider<MedicineListNotifier, List<MyMedicine>>(
  (ref) => MedicineListNotifier(),
);
