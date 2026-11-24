# docs/decisions.md — Architecture Decision Log

Decisions are recorded here as they are made.
Format: **ADR-NNN: Title** | Date | Decision | Reason | Alternatives considered.

---

## ADR-001: Duplicate severity vs. overall colour — README §13 inconsistency

**Date:** 2026-11-24
**Status:** OPEN — needs resolution from Person A and Person B

**Observation:**
The sample `/check` response in README §13 shows:
```json
"overall": "yellow",
"duplicates": [{ "severity": "major", ... }]
```
But the colour rules in the same section state:
> `red` if any **major** interaction or a **dangerous duplicate** exists.

A duplicate labelled `severity: "major"` should produce `overall: "red"` by that rule,
yet the sample shows `"yellow"`.

**The ambiguity:**
The word "dangerous" in "dangerous duplicate" is never defined.
Possible interpretations:
1. All duplicates are always yellow (only interactions can be red). The word "dangerous" is a placeholder that means nothing further.
2. A duplicate with `severity: "major"` is "dangerous" and therefore red.
3. "Dangerous" refers to a specific clinical concept (e.g. narrow-therapeutic-index drugs) that the data layer must classify separately.

**Impact on the Flutter app (Phase 3):**
The client-side safety guard in `CheckResult.fromJson` upgrades status to red only on
**major interactions**, not on major duplicates. This matches the sample response literally.
If Person A's backend ever returns `overall: "red"` for a duplicate, the client displays red
(the guard never softens the declared status).

**Action required:**
Person A to clarify the intended rule and update either the sample response or the colour-rule
prose. The JSON field names (`severity`, `overall`) must not change — only the documented rule.

---

## ADR-002: State management — Riverpod chosen

**Date:** 2026-11-24
**Status:** DECIDED

README §9 says "Riverpod (or Bloc) — pick one and stay consistent."
**Decision:** Riverpod.
**Reason:** Smaller boilerplate for a small screen count; provider overrides make testing clean.
No switching — all features in all phases use Riverpod.

---

## ADR-003: Navigation — Navigator.push with constructor arguments

**Date:** 2026-11-24
**Status:** DECIDED

**Decision:** Use `Navigator.push` with `MaterialPageRoute` and typed constructor arguments.
No go_router or named routes for Phase 3.
**Reason:** Avoids an extra dependency; type-safe; straightforward for ≤6 screens.
go_router can be adopted in Phase 5 if deep-linking or complex back-stack management is needed.

---

## ADR-004: Mock data scope

**Date:** 2026-11-24
**Status:** DECIDED

Per Phase 3 spec, mock data must NOT contain invented medical information.
Exact contents allowed:
- Crocin 500 and Dolo 650 (paracetamol) — from README §13 example.
- Sample Aspirin 75 mg and Sample Warfarin 5 mg — clearly labelled "sample".
- "Unknown Strip" — medicine with no known ingredient, to demonstrate grey state.
- One interaction: aspirin + warfarin, severity major, with placeholder description text
  (explicitly not a medical claim; source text to be provided by Person A).

No other brand names, salts, or interactions are present in the codebase.

---

## ADR-005: Confirm screen → "Yes, add it" navigation

**Date:** 2026-11-24
**Status:** DECIDED

After confirming a medicine, the app pops all intermediate screens (Scan, Find)
and navigates to My Medicines, so the user always has a consistent landing point.
Implementation: `Navigator.popUntil(isFirst)` then `push(MyMedicinesScreen)`.

---

## ADR-006: "Call my doctor / family" button — Phase 3 behaviour

**Date:** 2026-11-24
**Status:** DECIDED

The spec says the button "may show a dialog saying calling is not set up yet."
In Phase 3 the button shows an `AlertDialog` with the text from `Strings.resultCallDialogBody`.
Real calling (via `url_launcher` with `tel:` URI) will be wired up in Phase 5 or 6
using the `caregiver_contact` / `doctor_contact` from local settings.
