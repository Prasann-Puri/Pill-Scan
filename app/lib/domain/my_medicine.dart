import 'salt.dart';

/// A medicine that the user has confirmed and added to their list.
/// Stored in memory for Phase 3; persisted to SQLite in Phase 5.
class MyMedicine {
  final int medicineId;
  final String brandName;
  final List<Salt> salts;
  final DateTime confirmedAt;

  const MyMedicine({
    required this.medicineId,
    required this.brandName,
    required this.salts,
    required this.confirmedAt,
  });

  /// True when at least one active ingredient is known.
  /// False → this medicine will show as grey ("Could not check").
  bool get hasKnownIngredient => salts.isNotEmpty;

  /// Display-ready ingredient string, e.g. "paracetamol 500 mg".
  String get ingredientSummary {
    if (salts.isEmpty) return '';
    return salts.map((s) {
      final st = s.strengthText;
      return st != null ? '${s.name} $st' : s.name;
    }).join(', ');
  }
}
