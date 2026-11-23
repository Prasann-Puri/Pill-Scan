# 💊 PillSafe: Prescription Interaction & Dosage Conflict Checker

> Scan a medicine strip. Know if your medicines are safe together.

This document is the **complete project brief**. It is written so that a developer or an AI coding agent can read it from top to bottom and understand what to build, why, how, and what must never be done. **Read the "Non-Negotiable Safety Rules" section before writing any code.**

---

## Table of Contents

1. [Project Summary](#1-project-summary)
2. [Problem Statement](#2-problem-statement)
3. [Target Users](#3-target-users)
4. [Goals and Non-Goals](#4-goals-and-non-goals)
5. [Non-Negotiable Safety Rules](#5-non-negotiable-safety-rules)
6. [User Flow](#6-user-flow)
7. [Features](#7-features)
8. [System Architecture](#8-system-architecture)
9. [Tech Stack](#9-tech-stack)
10. [Repository Structure](#10-repository-structure)
11. [Data Sources](#11-data-sources)
12. [Data Models](#12-data-models)
13. [Backend API Specification](#13-backend-api-specification)
14. [Scan and Recognition Pipeline](#14-scan-and-recognition-pipeline)
15. [Interaction Checking Logic](#15-interaction-checking-logic)
16. [AI Layer](#16-ai-layer)
17. [Schedule Generation](#17-schedule-generation)
18. [UI / UX Specification](#18-ui--ux-specification)
19. [Localization](#19-localization)
20. [Privacy and Security](#20-privacy-and-security)
21. [Testing Strategy](#21-testing-strategy)
22. [Build Order (Milestones)](#22-build-order-milestones)
23. [Instructions for AI Coding Agents](#23-instructions-for-ai-coding-agents)
24. [Known Limitations](#24-known-limitations)
25. [Medical Disclaimer](#25-medical-disclaimer)
26. [Contributing and License](#26-contributing-and-license)

---

## 1. Project Summary

**PillSafe** is a mobile app (Flutter) with a backend service (FastAPI, Python) that lets an elderly person scan the strip (blister pack) of each medicine they take. The app:

1. Reads the medicine name from the strip using the camera.
2. Identifies the **active salt(s)** (generic ingredient) behind that brand name.
3. Cross-checks all of the person's medicines against open pharmacological data to find **drug-to-drug interactions** and **duplicate active ingredients**.
4. Produces a **color-coded safety result** and a simple **daily medicine schedule**.
5. Explains every result in **plain, short language**, optionally read aloud in the user's own language.

The app is an **informational helper**. It never replaces a doctor or pharmacist.

---

## 2. Problem Statement

Elderly patients often take medicines prescribed by **multiple doctors** who do not see each other's prescriptions. This leads to two dangers:

- **Drug-to-drug interactions:** two medicines that are harmful, or reduce each other's effect, when taken together.
- **Duplicate ingredients:** the same active salt hiding under different brand names (for example, two different tablets that both contain paracetamol), which can cause accidental overdose.

Existing interaction checkers are built for professionals or for tech-comfortable users. They require typing medicine names, reading dense text, and understanding pharmacology. Elderly users often cannot do this.

---

## 3. Target Users

**Primary user: the elderly patient**
- Age 60+, may have poor eyesight, shaky hands, limited smartphone experience.
- May speak Hindi or another regional language rather than English.
- Takes 3 or more medicines daily, often from different doctors.

**Secondary user: the caregiver**
- A family member who helps manage the elderly person's medicines, possibly from another phone.

Every design decision must favor the primary user. If a feature makes the main screen more complex, it belongs in a caregiver-only area or it should be cut.

---

## 4. Goals and Non-Goals

### Goals
- Make scanning a medicine strip a **one-tap** action.
- Detect duplicate active ingredients across all of a person's medicines.
- Detect known drug-drug interactions using **verified data sources**.
- Present results with large text, three clear colors, and a one-sentence summary.
- Work acceptably on mid-range Android phones with a weak internet connection.

### Non-Goals (do NOT build these)
- Diagnosing any condition.
- Recommending that a user start, stop, or change any medicine or dose.
- Replacing prescriptions or acting as a pharmacy.
- Claiming any combination is "safe". (Only "no known interaction found".)
- Social features, ads, or selling user data.

---

## 5. Non-Negotiable Safety Rules

These rules override every other instruction in this document. Any code that violates them is a bug.

1. **Interaction decisions come from verified data, never from an AI model's memory.** An LLM must never be the source of truth for whether two drugs interact.
2. **The app never says "safe".** The wording for the green state is **"No known problem found"**. Always include: "Please confirm with your doctor or pharmacist."
3. **The user confirms every scanned medicine before any check runs.** The app shows "Did you scan: Crocin 500 (Paracetamol)?" with Yes / No / Type it myself.
4. **Low confidence means ask, not guess.** If recognition confidence is below the threshold, ask the user to rescan or type the name. Never silently pick a best guess.
5. **The app never suggests dose changes or stopping a medicine.** It may say "Please ask your doctor about this combination."
6. **Unknown is not safe.** If a medicine cannot be identified, or a pair has no data, the result is shown as **unknown/unchecked** (grey), never green.
7. **The AI explanation layer may only rephrase facts supplied by the backend.** It must not add new medical claims. See [AI Layer](#16-ai-layer).
8. **The disclaimer is shown on every result screen** and cannot be dismissed permanently.
9. **Severe results always offer a one-tap "Call my doctor / family" action.**

---

## 6. User Flow

```
Open app
   │
   ▼
[Home] One big button: "Scan medicine"
   │
   ▼
[Camera] Guidance: "Hold the strip steady..." ──► vibration/sound on success
   │
   ▼
[Confirm] "Did you scan: Crocin 500 (Paracetamol)?"
   │        ├── Yes  ──► added to My Medicines
   │        ├── No   ──► rescan
   │        └── Type it myself ──► search by name
   ▼
[My Medicines] List of all scanned medicines + "Scan another" + "Check my medicines"
   │
   ▼
[Result] Overall color + ONE sentence + "Tell me more" + "Call doctor/family"
   │
   ▼
[Schedule] Morning / Afternoon / Night timeline with check-off buttons
```

Maximum depth from Home to a result: **4 screens**. No menus, no hamburger icons, no swipe-only gestures.

---

## 7. Features

### MVP (build first)
| Feature | Description |
|---|---|
| Strip scan | Camera capture, on-device OCR, name extraction |
| Brand-to-salt mapping | Map a brand name to active salt(s) using a local dataset |
| Manual entry fallback | Type or search a medicine name with large-text autocomplete |
| Duplicate detection | Flag two or more medicines sharing an active salt |
| Interaction check | Check all salt pairs against the interaction dataset |
| Color-coded result | Green / Yellow / Red / Grey with word + icon |
| Plain-language summary | One sentence first, details on request |
| Daily schedule | Morning / Afternoon / Night view with check-off |
| Disclaimer | Always visible on results |

### Phase 2
| Feature | Description |
|---|---|
| AI plain-language explanations | LLM rewrites database findings in simple words |
| Voice read-out | Text-to-speech of results |
| Regional languages | Hindi first, then others |
| Reminders | Local notifications at schedule times |
| Vision fallback | Cloud vision model for hard-to-read strips |

### Phase 3
| Feature | Description |
|---|---|
| Caregiver sharing | Caregiver views/edits the medicine list from their own phone |
| Voice questions | "Can I take this with my BP tablet?" answered from verified data |
| Weekly caregiver summary | New medicines added, unresolved warnings |
| Prescription photo import | Read a doctor's prescription (with user confirmation) |

---

## 8. System Architecture

```
┌──────────────────────────── Mobile App (Flutter) ────────────────────────────┐
│  Camera ─► On-device OCR (ML Kit) ─► Candidate name + confidence             │
│  Local DB (SQLite): my medicines, schedule, settings                         │
│  TTS, notifications, large-text UI                                           │
└───────────────┬──────────────────────────────────────────────────────────────┘
                │ HTTPS (JSON)
                ▼
┌──────────────────────────── Backend (FastAPI) ───────────────────────────────┐
│  /medicines/search     fuzzy match brand name ─► medicine + salts            │
│  /check                duplicates + interactions (rule engine, data-driven)  │
│  /explain   (Phase 2)  LLM rewrites verified findings in simple language     │
│  /vision    (Phase 2)  cloud vision fallback for low-confidence scans        │
└───────────────┬──────────────────────────────────────────────────────────────┘
                ▼
┌──────────────────────────────── Data Layer ──────────────────────────────────┐
│  PostgreSQL (or SQLite for dev):                                             │
│    medicines (brand → salts), salts, interactions, sources                   │
│  Loaded from open datasets via import scripts in /data                       │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Design principle:** the **rule engine** decides; the **AI layer** only explains and assists. Keep them in separate modules so the AI can be switched off without breaking safety checks.

**Offline behavior:** Scanning and viewing the saved medicine list must work offline. Checking should work offline against a bundled, versioned snapshot of the interaction data where feasible, and otherwise show a clear "Connect to internet to check" message. It must never show a stale result as if it were fresh without a visible data date.

---

## 9. Tech Stack

| Layer | Choice | Notes |
|---|---|---|
| Mobile app | **Flutter (Dart)** | Android first, iOS later |
| State management | Riverpod (or Bloc) | Pick one and stay consistent |
| On-device OCR | Google ML Kit Text Recognition | Free, works offline |
| Local storage | SQLite (drift or sqflite) | Medicine list, schedule |
| Backend | **FastAPI (Python 3.11+)** | Async, auto-generated docs |
| Database | PostgreSQL (SQLite acceptable in dev) | SQLAlchemy + Alembic |
| Fuzzy matching | rapidfuzz | Brand name matching |
| AI (Phase 2) | Pluggable LLM provider | Behind an interface so it can be swapped |
| Speech | Flutter TTS plugin + platform STT | Hindi support needed |
| Testing | pytest, flutter_test | See testing section |
| Deployment | Docker | Backend container |

---

## 10. Repository Structure

```
pillsafe/
├── README.md                  # this file
├── app/                       # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/              # theme, constants, accessibility helpers
│   │   ├── data/              # local DB, API client, repositories
│   │   ├── domain/            # models: Medicine, Salt, CheckResult, ScheduleItem
│   │   ├── features/
│   │   │   ├── home/
│   │   │   ├── scan/
│   │   │   ├── confirm/
│   │   │   ├── my_medicines/
│   │   │   ├── result/
│   │   │   ├── schedule/
│   │   │   └── settings/
│   │   └── widgets/           # BigButton, StatusBanner, DisclaimerBar
│   ├── assets/                # fonts, icons, translations
│   └── test/
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── api/               # route modules
│   │   ├── core/              # config, logging
│   │   ├── models/            # SQLAlchemy models
│   │   ├── schemas/           # Pydantic schemas
│   │   ├── services/
│   │   │   ├── matching.py    # brand name fuzzy matching
│   │   │   ├── checker.py     # duplicate + interaction rule engine
│   │   │   ├── scheduler.py   # schedule generation
│   │   │   └── ai/            # explain.py, vision.py (Phase 2, pluggable)
│   │   └── db/                # session, migrations
│   ├── tests/
│   ├── requirements.txt
│   └── Dockerfile
├── data/
│   ├── raw/                   # downloaded source datasets (not committed if large)
│   ├── scripts/               # import and cleaning scripts
│   └── README.md              # sources, licenses, import steps
└── docs/
    ├── screens.md             # screen-by-screen design notes
    └── decisions.md           # architecture decision log
```

---

## 11. Data Sources

Data quality decides whether this app is useful or dangerous. **Verify the current availability and license of every source before depending on it.**

| Need | Candidate sources | Notes |
|---|---|---|
| Brand name → active salt (India) | Public Indian medicine datasets (for example community datasets of Indian medicines with composition), CDSCO listings | Must be cleaned and deduplicated. Check license. |
| Generic drug names / identifiers | **RxNorm / RxNav** (US National Library of Medicine), WHO ATC codes | Good for normalizing salt names. |
| Interaction data | openFDA drug label text (interaction sections), open datasets such as DDInter, licensed sources such as DrugBank if budget allows | **Important:** the NLM RxNav *Drug Interaction API* was discontinued in 2024, so do not build on it. Confirm what is currently available. |

**Rules for data handling**
- Store the **source and retrieval date** with every interaction record.
- Normalize salt names (lowercase, strip salts/forms, e.g. "paracetamol", not "Paracetamol IP 500 mg").
- Keep severity labels from the source; map them into the app's 3 levels in one single, documented place.
- Show "Data last updated: <date>" in settings or on results.
- Open data is incomplete. The product must communicate this honestly (see Safety Rules).

---

## 12. Data Models

### Backend (relational)

```sql
-- Active ingredients
salts(
  id            INTEGER PRIMARY KEY,
  name          TEXT UNIQUE NOT NULL,      -- normalized, e.g. "paracetamol"
  aliases       TEXT[]                      -- alternate names
)

-- Branded medicines
medicines(
  id            INTEGER PRIMARY KEY,
  brand_name    TEXT NOT NULL,              -- "Crocin 500"
  normalized    TEXT NOT NULL,              -- lowercase, cleaned, for matching
  manufacturer  TEXT,
  form          TEXT,                       -- tablet, capsule, syrup
  strength_text TEXT                        -- "500 mg" (informational)
)

-- Many-to-many: a medicine can contain several salts
medicine_salts(
  medicine_id   INTEGER REFERENCES medicines(id),
  salt_id       INTEGER REFERENCES salts(id),
  strength_text TEXT,
  PRIMARY KEY (medicine_id, salt_id)
)

-- Interactions are stored once per unordered salt pair
interactions(
  id            INTEGER PRIMARY KEY,
  salt_a_id     INTEGER REFERENCES salts(id),
  salt_b_id     INTEGER REFERENCES salts(id),
  severity      TEXT NOT NULL,              -- 'minor' | 'moderate' | 'major'
  description   TEXT NOT NULL,              -- verified source text, plain
  source        TEXT NOT NULL,              -- dataset/source name
  source_date   DATE,
  CHECK (salt_a_id < salt_b_id)             -- enforce one row per pair
)
```

### Mobile (local SQLite)

```
my_medicines(id, medicine_id, brand_name, salts_json, confirmed_at, scan_confidence)
schedule_items(id, my_medicine_id, time_slot, label, taken_today BOOLEAN, last_taken_at)
settings(language, text_scale, voice_enabled, caregiver_contact, doctor_contact)
```

---

## 13. Backend API Specification

Base path: `/api/v1`. All responses are JSON. Use Pydantic schemas for validation.

### `GET /medicines/search?q=<text>&limit=5`
Fuzzy search by brand name.

Response:
```json
{
  "query": "crocln 500",
  "results": [
    {
      "medicine_id": 101,
      "brand_name": "Crocin 500",
      "salts": [{"id": 7, "name": "paracetamol", "strength_text": "500 mg"}],
      "match_score": 0.93
    }
  ]
}
```

### `POST /check`
Check a list of confirmed medicines.

Request:
```json
{ "medicine_ids": [101, 205, 310] }
```

Response:
```json
{
  "overall": "yellow",
  "summary": "Two of your medicines share the same ingredient. Please ask your doctor.",
  "duplicates": [
    {
      "salt": "paracetamol",
      "medicine_ids": [101, 205],
      "severity": "major",
      "message": "Both medicines contain paracetamol."
    }
  ],
  "interactions": [
    {
      "salt_a": "aspirin",
      "salt_b": "warfarin",
      "medicine_ids": [205, 310],
      "severity": "major",
      "description": "<verified source text>",
      "source": "<dataset name>",
      "source_date": "2025-06-01"
    }
  ],
  "unchecked": [{"medicine_id": 999, "reason": "Active ingredient not found"}],
  "data_version": "2026-11-01",
  "disclaimer": "This is a helping tool. Please confirm with your doctor or pharmacist."
}
```

`overall` values: `green` | `yellow` | `red` | `grey`
- `red` if any **major** interaction or a dangerous duplicate exists.
- `yellow` if any **moderate/minor** interaction or non-dangerous duplicate exists.
- `grey` if any medicine is unchecked and nothing worse was found (never green in that case).
- `green` only when every medicine was identified and no known problem was found.

### `POST /explain` *(Phase 2)*
Input: the verified `/check` result and a target language. Output: simple-language text. See [AI Layer](#16-ai-layer).

### `POST /vision/read-strip` *(Phase 2)*
Input: image. Output: candidate names with confidences, to be confirmed by the user.

### `GET /health`
Returns service status and data version.

---

## 14. Scan and Recognition Pipeline

1. **Capture.** Camera preview with an on-screen frame. Prompt: "Hold the strip steady and closer." Detect blur/glare where possible and ask the user to adjust.
2. **On-device OCR.** Run ML Kit text recognition. Collect all text blocks.
3. **Candidate extraction.** Clean the text: lowercase, remove batch numbers, dates, prices, and "MFG/EXP" lines; keep strings that look like medicine names (letters followed by optional strength).
4. **Matching.** Send candidate strings to `/medicines/search`. The backend uses fuzzy matching (rapidfuzz) against `medicines.normalized`, and also against salt names printed on the strip (strips often print the salt in small text).
5. **Confidence decision.**
   - `score >= 0.90` → show confirmation screen with the match preselected.
   - `0.70 <= score < 0.90` → show top 3 matches and ask the user to choose.
   - `score < 0.70` → ask to rescan or type the name. **Do not guess.**
6. **User confirmation (mandatory).** Only after the user taps "Yes" is the medicine added.
7. **Fallback (Phase 2).** If OCR repeatedly fails, offer a cloud vision attempt, still ending in user confirmation.

Thresholds must be **configuration values**, not hard-coded, and tuned using real photographed strips.

---

## 15. Interaction Checking Logic

Implemented in `backend/app/services/checker.py`. It must be **deterministic and data-driven**: same input, same output.

```
Input: list of medicine_ids
1. Resolve each medicine to its set of salts.
   - If a medicine has no salts → add to `unchecked`.
2. Duplicate detection:
   - Count medicines per salt. If a salt appears in 2+ different medicines → duplicate finding.
3. Interaction detection:
   - For every unordered pair of distinct salts across the full set,
     look up the `interactions` table.
   - Skip pairs where both salts come from the SAME single medicine (combination products
     are designed that way).
4. Severity aggregation:
   - overall = worst severity found, with the rules in /check above.
5. Return findings, unchecked list, data_version, and disclaimer.
```

Edge cases to handle and test:
- A combination tablet containing several salts.
- The same medicine scanned twice (de-duplicate by `medicine_id`, but allow a "taking two of this" flag later).
- Salt-name variants ("acetaminophen" and "paracetamol" are the same; use aliases).
- Empty list or a single medicine (duplicate/interaction checks return empty, overall depends on identification).

---

## 16. AI Layer

AI is used to **assist and explain**, never to decide.

### 16.1 Where AI is used
| Use | Module | Notes |
|---|---|---|
| Reading hard strips | `ai/vision.py` | Fallback only; result must be user-confirmed |
| Plain-language explanations | `ai/explain.py` | Rephrases verified findings |
| Voice Q&A (Phase 3) | `ai/voice_qa.py` | Answers only from verified `/check` data |
| Caregiver summaries (Phase 3) | `ai/summary.py` | Summarizes activity, no new medical claims |

### 16.2 Where AI must NOT be used
- Deciding whether two medicines interact.
- Recommending doses, starting, or stopping a medicine.
- Declaring a combination safe.

### 16.3 Grounding contract for `/explain`
The model receives **only** the structured `/check` findings plus a target language. The system prompt must enforce:

```
You rewrite verified medicine-safety findings for an elderly reader.
Rules:
- Use only the facts in the provided findings. Do not add medical information.
- Use short sentences and simple words, at about a grade-5 reading level.
- Start with ONE sentence that gives the main message.
- Never say a combination is "safe". Say "no known problem was found" if applicable.
- Never advise changing, stopping, or adjusting any medicine or dose.
- Always end with: ask your doctor or pharmacist.
- If the findings are empty or unclear, say the app could not check and to ask a pharmacist.
- Reply in the requested language.
```

### 16.4 AI guardrails (implement in code, not only in the prompt)
- **Output validation:** reject and fall back to a templated sentence if the output contains forbidden phrases (for example "safe to take", "stop taking", "increase the dose") or mentions a drug not present in the input.
- **Fallback template:** every severity level has a hand-written, human-reviewed template sentence in each supported language. If the AI call fails, times out, or is rejected by validation, show the template. The app must remain fully functional with AI disabled.
- **Provider abstraction:** wrap the LLM behind an interface (`ExplainProvider`) so the vendor can be swapped and mocked in tests.
- **Logging:** log (without personal data) when validation rejects an AI output, to improve prompts.
- **Evaluation set:** keep a fixed set of known findings with expected key messages; run it on every prompt or model change.

### 16.5 Cost and privacy
- Keep scan, lookup, check, and schedule on the cheap, local/simple path. Call AI only for explanations or hard scans.
- Do not send names, contacts, or identifiers to any AI provider. Send only the structured findings (salt names and severities).
- If an image is sent to a cloud model, tell the user first and do not store it.

---

## 17. Schedule Generation

Goal: a simple Morning / Afternoon / Night view.

- Phase 1: the **user** assigns each medicine to time slots using large buttons (Morning / Afternoon / Night / Before bed). Do not guess timings from the strip.
- If a red or yellow finding exists between two medicines, the schedule shows a visible warning on those items and **does not** try to "fix" it by separating times (that is a medical decision). It says: "Please ask your doctor about this combination."
- Each item has a large "Taken" check-off button. Reset daily.
- Optional local notifications at the chosen times (Phase 2).

---

## 18. UI / UX Specification

This is the most important product area. The test: **could a 75-year-old with weak eyesight use this without help?**

### Layout and interaction
- **One primary action per screen.**
- Home screen: one very large **"Scan medicine"** button, plus a secondary **"My medicines"** button. Nothing else.
- Minimum tap target: **64 dp** (larger than the 48 dp standard).
- Minimum body text: **20 sp**; headings 28 sp or larger. Respect the system font scale and offer an in-app "Bigger text" setting.
- No hamburger menus, no tabs hidden under icons, no swipe-only gestures, no long-press actions, no time-limited toasts for important messages.
- Every icon has a text label.
- Confirmation dialogs use plain words ("Yes, add it" / "No, scan again").

### Color and meaning
| State | Color | Icon | Word |
|---|---|---|---|
| No known problem | Green | ✅ | "No known problem found" |
| Ask your doctor | Yellow/Amber | ⚠️ | "Ask your doctor" |
| Do not combine without advice | Red | ⛔ | "Do not take together without asking your doctor" |
| Could not check | Grey | ❔ | "Could not check" |

- Never use color alone. Always pair with icon and words (color-blind safety).
- Contrast ratio at least **7:1** for text (WCAG AAA) on key screens.
- Light theme by default; high-contrast theme as a setting.

### Result screen structure
1. Large status banner (color, icon, word).
2. **One sentence** summary.
3. Button: **"Tell me more"** (expands details: which medicines, source, data date).
4. Button: **"Call my doctor / family"** (always shown on red).
5. Button: **"Read aloud"** (Phase 2).
6. Persistent disclaimer bar at the bottom.

### Camera screen
- Large frame overlay, short instruction text, flashlight toggle (labeled), vibration and soft sound on success, and a clear "Type the name instead" button.

### Error and empty states
Use plain, calm language: "We could not read this strip. Please try again closer to the light." Never show stack traces, error codes, or technical terms.

### Accessibility checklist
- Screen reader labels on all elements (TalkBack).
- Works with system large-text and bold-text settings.
- Haptic and audio feedback on key events.
- No reliance on hearing or color alone.

---

## 19. Localization

- All user-visible strings go in translation files, never hard-coded.
- Languages: **English and Hindi at launch**; the structure must allow adding more regional languages without code changes.
- Medicine names stay in Latin script as printed; only surrounding explanations are translated.
- The templated fallback sentences (see AI guardrails) must exist in every supported language and be reviewed by a fluent speaker, ideally a pharmacist or doctor.
- Text-to-speech must be tested with real Hindi voices for clarity and speed (slower default speech rate).

---

## 20. Privacy and Security

- Health data is sensitive. **Minimize collection.** The default design keeps the medicine list **on the device**.
- If cloud sync or caregiver sharing is added, use encryption in transit (HTTPS/TLS) and at rest, explicit opt-in consent, and a way to delete all data.
- Backend `/check` and `/search` should work with medicine IDs, not personal identifiers. Do not log request bodies containing a person's medicine list together with identifying data.
- No third-party analytics SDKs that collect health data. No ads.
- Secrets (API keys) go in environment variables, never in the repository.
- Rate-limit the backend; validate all inputs with Pydantic.
- Show a short, plain-language privacy explanation on first launch.
- Comply with applicable laws (for example India's DPDP Act) and review requirements before public release.

---

## 21. Testing Strategy

**Backend (pytest)**
- Unit tests for the checker: duplicates, interactions, combination products, alias handling, severity aggregation, `grey` vs `green` logic.
- Unit tests for matching: typos, spacing, strength suffixes, uppercase/lowercase.
- Contract tests for every endpoint's schema.
- A **golden test set** of known pairs with expected severities (reviewed by a pharmacist if possible).

**Mobile (flutter_test)**
- Widget tests: tap target sizes, text scaling, presence of icon+word on every status.
- Integration test of the full flow: scan → confirm → check → result → schedule.

**Real-world scan testing (critical)**
- Photograph **at least 100 real strips** (varied brands, lighting, angles, glare, partly cut text). Record OCR accuracy and tune thresholds. Do not trust synthetic images alone.

**AI evaluation**
- Fixed evaluation set for `/explain`: check that outputs contain no forbidden phrases, mention only supplied drugs, and keep reading level low.

**Usability testing**
- Test with real elderly users before any public release. Observe without helping. Fix every point of confusion.

---

## 22. Build Order (Milestones)

Build in this order. Each milestone should work end-to-end before the next begins.

**Milestone 1: Data foundation**
1. Create backend skeleton, database models, migrations.
2. Write import scripts for the brand-to-salt dataset and interaction data. Document sources and licenses in `data/README.md`.
3. Implement `/medicines/search` with fuzzy matching and tests.

**Milestone 2: Checker**
4. Implement `checker.py` (duplicates, interactions, severity aggregation) and `/check`, with the golden test set.

**Milestone 3: Minimal mobile app**
5. Flutter app: Home, My Medicines (manual add through search), Result screen with color banner. Large-text theme and accessibility from the start.

**Milestone 4: Scanning**
6. Camera screen + ML Kit OCR + candidate extraction + confirmation screen with confidence logic.

**Milestone 5: Schedule**
7. Time-slot assignment, daily schedule view, taken check-off, local persistence.

**Milestone 6: Polish and safety review**
8. Disclaimer everywhere, grey/unknown states, error messages, offline behavior, data-date display.
9. Hindi localization. Usability test with elderly users.

**Milestone 7: AI features (Phase 2)**
10. `ExplainProvider` with validation, templates, and evaluation set.
11. Voice read-out. Vision fallback. Reminders.

**Milestone 8: Caregiver features (Phase 3)**
12. Opt-in sharing, voice questions, weekly summaries.

---

## 23. Instructions for AI Coding Agents

If you are an AI agent building this project, follow these rules:

1. **Read [Non-Negotiable Safety Rules](#5-non-negotiable-safety-rules) first** and keep them in mind for every file you write.
2. **Follow the build order** in section 22. Do not start AI features before the deterministic checker and basic app work.
3. **Do not invent medical data.** Never hard-code interaction pairs, severities, or brand-to-salt mappings from memory. Load them from the documented datasets through import scripts. If data is missing, leave the app showing "Could not check".
4. **Do not use an LLM to decide interactions**, anywhere, ever.
5. **Keep modules separate:** rule engine (`checker.py`) must not import from `services/ai/`.
6. **Make thresholds and wording configurable** (OCR confidence thresholds, disclaimer text, template sentences).
7. **Accessibility is a requirement, not polish.** Use the sizes, contrast, and labeling rules in section 18 from the first screen.
8. **Write tests alongside code**, especially for the checker and matching.
9. **Ask before assuming** when a data source's license or availability is unclear; note it in `docs/decisions.md`.
10. **Keep the UI minimal.** If you are tempted to add a screen, setting, or option to the elderly user's main flow, don't. Put it in a caregiver area or leave it out.
11. **Code style:** Dart with `flutter_lints`; Python with type hints, `ruff`, and `black`. Small functions, clear names, docstrings on services.
12. **Document decisions** in `docs/decisions.md` (what was chosen, why, alternatives).

---

## 24. Known Limitations

- Blister strips are shiny and curved, so OCR accuracy varies. The user-confirmation step is the safety net.
- Open interaction datasets are incomplete and may lag behind current medical guidance. The app can only say "no known problem found".
- Coverage of Indian brand names in international databases is limited; building and maintaining a good local brand-to-salt dataset is a major part of the work.
- The app does not account for dose, age, kidney or liver function, food, alcohol, or the person's medical conditions. It checks ingredient pairs only.
- Strength and dose differences are informational only in the MVP.

---

## 25. Medical Disclaimer

PillSafe is an **informational helper, not medical advice**. It does not diagnose, prescribe, or replace a doctor or pharmacist. A result of "no known problem found" does **not** mean a combination is safe. Always confirm your medicines with a qualified healthcare professional before starting, stopping, or changing anything.

---

## 26. Contributing and License

Contributions are welcome. Please open an issue to discuss significant changes first. Changes touching safety logic, interaction data, or medical wording require extra review.

License: MIT (update as needed).
