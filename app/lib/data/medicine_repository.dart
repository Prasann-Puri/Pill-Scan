import '../domain/medicine_search_result.dart';
import '../domain/check_result.dart';

/// Abstract repository — the interface that every screen uses.
///
/// Phase 3: implemented by MockMedicineRepository.
/// Phase 5: implemented by ApiMedicineRepository (real HTTP calls).
/// Screens never import the concrete class — only this interface.
abstract class MedicineRepository {
  /// Fuzzy-search for a medicine by brand name.
  /// Returns up to [limit] results sorted by match score descending.
  Future<List<MedicineSearchResult>> search(String query, {int limit = 5});

  /// Run a duplicate + interaction check for the confirmed medicine list.
  /// [medicineIds] corresponds to [MyMedicine.medicineId] values.
  Future<CheckResult> check(List<int> medicineIds);
}
