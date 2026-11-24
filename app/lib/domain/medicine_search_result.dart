import 'salt.dart';

/// One result row from GET /medicines/search (README §13).
library;

class MedicineSearchResult {
  final int medicineId;
  final String brandName;
  final List<Salt> salts;
  final double matchScore;

  const MedicineSearchResult({
    required this.medicineId,
    required this.brandName,
    required this.salts,
    required this.matchScore,
  });

  factory MedicineSearchResult.fromJson(Map<String, dynamic> json) =>
      MedicineSearchResult(
        medicineId: json['medicine_id'] as int,
        brandName: json['brand_name'] as String,
        salts: (json['salts'] as List<dynamic>)
            .map((s) => Salt.fromJson(s as Map<String, dynamic>))
            .toList(),
        matchScore: (json['match_score'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'medicine_id': medicineId,
        'brand_name': brandName,
        'salts': salts.map((s) => s.toJson()).toList(),
        'match_score': matchScore,
      };

  /// True when the backend knows at least one active ingredient.
  bool get hasKnownIngredient => salts.isNotEmpty;
}
