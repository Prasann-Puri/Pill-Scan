/// CheckResult and its sub-models — mirrors the POST /check response (README §13).
///
/// SAFETY GUARDS are applied inside fromJson.
/// The client NEVER displays a status softer than what the data warrants.
library;

// ── Overall status ────────────────────────────────────────────────────────────

enum OverallStatus { green, yellow, red, grey }

OverallStatus _parseOverall(dynamic raw) {
  switch (raw) {
    case 'green':
      return OverallStatus.green;
    case 'yellow':
      return OverallStatus.yellow;
    case 'red':
      return OverallStatus.red;
    default:
      // Safety Rule §5-rule-6: unknown → grey, never green.
      return OverallStatus.grey;
  }
}

// ── Sub-models ────────────────────────────────────────────────────────────────

class DuplicateFinding {
  final String salt;
  final List<int> medicineIds;
  final String severity;
  final String message;

  const DuplicateFinding({
    required this.salt,
    required this.medicineIds,
    required this.severity,
    required this.message,
  });

  factory DuplicateFinding.fromJson(Map<String, dynamic> json) =>
      DuplicateFinding(
        salt: json['salt'] as String,
        medicineIds: (json['medicine_ids'] as List<dynamic>)
            .map((e) => e as int)
            .toList(),
        severity: json['severity'] as String,
        message: json['message'] as String,
      );
}

class InteractionFinding {
  final String saltA;
  final String saltB;
  final List<int> medicineIds;
  final String severity;
  final String description;
  final String source;
  final String? sourceDate;

  const InteractionFinding({
    required this.saltA,
    required this.saltB,
    required this.medicineIds,
    required this.severity,
    required this.description,
    required this.source,
    this.sourceDate,
  });

  factory InteractionFinding.fromJson(Map<String, dynamic> json) =>
      InteractionFinding(
        saltA: json['salt_a'] as String,
        saltB: json['salt_b'] as String,
        medicineIds: (json['medicine_ids'] as List<dynamic>)
            .map((e) => e as int)
            .toList(),
        severity: json['severity'] as String,
        description: json['description'] as String,
        source: json['source'] as String,
        sourceDate: json['source_date'] as String?,
      );
}

class UncheckedMedicine {
  final int medicineId;
  final String reason;

  const UncheckedMedicine({
    required this.medicineId,
    required this.reason,
  });

  factory UncheckedMedicine.fromJson(Map<String, dynamic> json) =>
      UncheckedMedicine(
        medicineId: json['medicine_id'] as int,
        reason: json['reason'] as String,
      );
}

// ── CheckResult ───────────────────────────────────────────────────────────────

class CheckResult {
  final OverallStatus overall;
  final String summary;
  final List<DuplicateFinding> duplicates;
  final List<InteractionFinding> interactions;
  final List<UncheckedMedicine> unchecked;
  final String dataVersion;
  final String disclaimer;

  const CheckResult({
    required this.overall,
    required this.summary,
    required this.duplicates,
    required this.interactions,
    required this.unchecked,
    required this.dataVersion,
    required this.disclaimer,
  });

  /// Parse a /check JSON response and apply client-side safety guards.
  ///
  /// Guards (applied in order, never soften):
  ///  1. Unknown/missing "overall" → grey.
  ///  2. Any unchecked medicine present → at least grey.
  ///  3. Any finding (duplicate or interaction) → at least yellow.
  ///  4. Any major interaction → red (regardless of declared status).
  factory CheckResult.fromJson(Map<String, dynamic> json) {
    final duplicates = (json['duplicates'] as List<dynamic>? ?? [])
        .map((e) => DuplicateFinding.fromJson(e as Map<String, dynamic>))
        .toList();
    final interactions = (json['interactions'] as List<dynamic>? ?? [])
        .map((e) => InteractionFinding.fromJson(e as Map<String, dynamic>))
        .toList();
    final unchecked = (json['unchecked'] as List<dynamic>? ?? [])
        .map((e) => UncheckedMedicine.fromJson(e as Map<String, dynamic>))
        .toList();

    // Start with declared status (Guard 1 handled inside _parseOverall).
    var status = _parseOverall(json['overall']);

    // Guard 2: unchecked medicine → at least grey.
    if (unchecked.isNotEmpty && status == OverallStatus.green) {
      status = OverallStatus.grey;
    }

    // Guard 3: any finding → at least yellow.
    if (duplicates.isNotEmpty || interactions.isNotEmpty) {
      if (status == OverallStatus.green || status == OverallStatus.grey) {
        status = OverallStatus.yellow;
      }
    }

    // Guard 4: any major interaction → red (always, overrides everything).
    if (interactions.any((i) => i.severity == 'major')) {
      status = OverallStatus.red;
    }

    return CheckResult(
      overall: status,
      summary: json['summary'] as String? ?? '',
      duplicates: duplicates,
      interactions: interactions,
      unchecked: unchecked,
      dataVersion: json['data_version'] as String? ?? '',
      disclaimer: json['disclaimer'] as String? ?? '',
    );
  }
}
