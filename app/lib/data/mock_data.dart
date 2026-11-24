/// Mock medicines and interactions used in Phase 3 (UI-only build).
///
/// IMPORTANT — SAFETY NOTE:
/// This data is for UI development ONLY.
/// - Only the examples from README §13 are used (Crocin 500, Dolo 650, paracetamol).
/// - The aspirin + warfarin interaction carries a PLACEHOLDER description.
///   It is NOT a medical claim. Real source text must come from a verified
///   dataset supplied by Person A before Phase 5.
/// - "Unknown Strip" deliberately has no ingredient to demonstrate the grey state.
/// - No other brand names, salts, or interactions are present.
library;

/// Raw JSON rows — structured exactly as the backend /medicines/search
/// endpoint returns them (README §13), so fromJson is exercised in tests.
const List<Map<String, dynamic>> kMockMedicineRows = [
  // ── README examples ────────────────────────────────────────────────────
  {
    'medicine_id': 101,
    'brand_name': 'Crocin 500',
    'salts': [
      {'id': 7, 'name': 'paracetamol', 'strength_text': '500 mg'},
    ],
    'match_score': 1.0,
  },
  {
    'medicine_id': 102,
    'brand_name': 'Dolo 650',
    'salts': [
      {'id': 7, 'name': 'paracetamol', 'strength_text': '650 mg'},
    ],
    'match_score': 1.0,
  },
  // ── Clearly labelled sample items ─────────────────────────────────────
  {
    'medicine_id': 201,
    'brand_name': 'Sample Aspirin 75 mg',
    'salts': [
      {'id': 11, 'name': 'aspirin', 'strength_text': '75 mg'},
    ],
    'match_score': 1.0,
  },
  {
    'medicine_id': 202,
    'brand_name': 'Sample Warfarin 5 mg',
    'salts': [
      {'id': 12, 'name': 'warfarin', 'strength_text': '5 mg'},
    ],
    'match_score': 1.0,
  },
  // ── Unknown Strip — no ingredient, demonstrates grey state ───────────
  {
    'medicine_id': 999,
    'brand_name': 'Unknown Strip',
    'salts': <Map<String, dynamic>>[],
    'match_score': 1.0,
  },
];

/// The only interaction in mock data — aspirin + warfarin, severity major.
/// Description is a placeholder; real text to be provided by Person A.
const Map<String, dynamic> kMockInteractionAspirinWarfarin = {
  'salt_a': 'aspirin',
  'salt_b': 'warfarin',
  'severity': 'major',
  'description':
      '[PLACEHOLDER — not a medical claim. '
      'Source text to be supplied by Person A from a verified dataset.]',
  'source': 'Mock data — not a real source',
  'source_date': null,
};

const String kMockDataVersion = 'mock-2026-11-24';
