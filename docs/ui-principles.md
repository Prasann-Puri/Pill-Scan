# 🧓 PillSafe — UI Design Principles for Elderly Users

> **This document is a hard constraint, not a guideline.**
> Every screen, widget, and interaction in PillSafe must pass the test below before it ships:
>
> **"Could a 75-year-old with weak eyesight, slightly shaky hands, and limited smartphone experience use this screen alone — without help, without reading a manual?"**
>
> If the answer is **no** or **maybe** — redesign the screen.

---

## 1. The Golden Rules (Non-Negotiable)

| # | Rule | Why |
|---|---|---|
| 1 | **One action per screen** | Elderly users get confused when faced with multiple choices |
| 2 | **No hamburger menus, no tabs hidden under icons** | They are invisible to low-tech users |
| 3 | **No swipe-only gestures, no long-press, no double-tap** | Shaky hands and unfamiliarity make these unusable |
| 4 | **Every icon MUST have a text label** | Icons alone are ambiguous |
| 5 | **No time-limited toasts for important info** | Users may miss them; use persistent banners |
| 6 | **Plain words only** — no medical jargon, no tech terms | Target reading level: Grade 5 |
| 7 | **Never show error codes, stack traces, or HTTP status** | Show: "We couldn't read this strip. Please try again." |
| 8 | **Minimum tap target: 64 dp** (larger than standard 48 dp) | Accounts for shaky or arthritic hands |

---

## 2. Typography

| Element | Min Size | Notes |
|---|---|---|
| Body text | **20 sp** | Never go below this |
| Headings | **28 sp** | Key screen titles, results |
| Button labels | **22 sp** | Must be readable inside the button |
| Disclaimer text | **18 sp** | Still readable, visually secondary |

- Always **respect system font scale** — do not cap or override the user's accessibility text size setting.
- Provide an **in-app "Bigger text" toggle** as a shortcut (doesn't replace system setting).
- Use **high-weight fonts** (medium or semi-bold) for all important text.

---

## 3. Color & Contrast

- **Minimum contrast ratio: 7:1** (WCAG AAA) on result and action screens.
- **Never use color alone** to convey meaning — always pair with an icon AND a word.
- Default theme: **light** (white/off-white background, dark text).
- Provide a **High Contrast theme** in settings (black background, white text, yellow accents).

### Color Meanings — Do Not Deviate

| Color | Icon | Word shown to user |
|---|---|---|
| 🟢 Green | ✅ | "No known problem found" |
| 🟡 Yellow/Amber | ⚠️ | "Ask your doctor" |
| 🔴 Red | ⛔ | "Do not take together without asking your doctor" |
| ⬜ Grey | ❔ | "Could not check" |

---

## 4. Screen Layout Rules

```
┌─────────────────────────────────┐
│  [Back button — large, labeled] │  ← always visible if not home
│                                 │
│   Clear heading (28 sp+)        │
│                                 │
│   [ ONE primary action button ] │  ← full width, tall (min 64 dp)
│                                 │
│   [ secondary action — smaller] │  ← only if truly needed
│                                 │
│   ─────── Disclaimer bar ─────  │  ← always pinned to bottom on result screens
└─────────────────────────────────┘
```

- **Back button**: large, labeled "Back" — not just a chevron icon.
- **Primary button**: full-width, tall, high-contrast fill color.
- **Max depth**: 4 screens from Home to result. No deeper.

---

## 5. Screen-by-Screen Checklist

### Home Screen
- [ ] One very large **"Scan Medicine"** button (primary, center screen)
- [ ] One secondary **"My Medicines"** button (smaller, below)
- [ ] Nothing else — no news, no tips, no progress bars, no banners

### Camera / Scan Screen
- [ ] Large frame overlay with text: *"Hold the strip steady and closer"*
- [ ] Flashlight toggle button — labeled **"Light On / Off"** (not an icon alone)
- [ ] **"Type the name instead"** button — always visible, not hidden
- [ ] Vibration + soft sound on successful scan
- [ ] No countdown timer, no auto-capture without user action

### Confirm Screen
- [ ] Shows: *"Did you scan: Crocin 500 (Paracetamol)?"*
- [ ] Three large buttons: **"Yes, add it"** / **"No, scan again"** / **"I'll type it"**
- [ ] No auto-advance — user must tap a choice

### My Medicines Screen
- [ ] Simple list — medicine name, salt in smaller text below
- [ ] Large **"Scan Another"** button at top
- [ ] Large **"Check My Medicines"** button at bottom
- [ ] Delete with confirmation dialog (not swipe-to-delete)

### Result Screen
- [ ] Large color banner (full width) with icon + word + sentence
- [ ] One-sentence summary in large text (20 sp+)
- [ ] **"Tell me more"** button to expand details
- [ ] **"Call my doctor / family"** button — always shown when result is Red
- [ ] Disclaimer bar pinned to bottom — cannot be dismissed

### Schedule Screen
- [ ] Three clear rows: **Morning / Afternoon / Night**
- [ ] Large **"Taken ✓"** check-off buttons per medicine
- [ ] Warning label (not color alone) if two medicines in the same slot have a known issue

---

## 6. Feedback & Accessibility

- **Haptic feedback** on every successful action (scan success, button tap, check-off)
- **Audio feedback** on scan success (soft chime)
- **TalkBack / screen reader** labels on every element — no unlabeled icons
- Works correctly with **system large text, bold text, and high contrast** modes
- Never rely on **hearing or color alone** to convey critical information
- Speech rate for TTS: **slower than default** — elderly users need more time

---

## 7. Language & Tone

| ❌ Don't write | ✅ Write instead |
|---|---|
| "Contraindication detected" | "These two medicines may cause a problem together" |
| "OCR confidence below threshold" | "We couldn't read this strip clearly. Please try again." |
| "API error 503" | "Something went wrong. Please check your connection." |
| "Safe to combine" | "No known problem found" |
| "Interaction severity: moderate" | "Ask your doctor about this combination" |
| "Null result" | "Could not check" |

- **Always end instructions with what to do next.** Never leave the user without a next action.
- Use **"you"** and **"your"** — personal, warm, not clinical.
- Keep sentences **under 15 words** where possible.

---

## 8. What NOT to Build (Ever)

- ❌ Hamburger menu
- ❌ Bottom navigation bar with icon-only tabs
- ❌ Swipe-to-delete or swipe-to-reveal actions
- ❌ Collapsible/accordion sections on main flow screens
- ❌ Tooltips (elderly users don't know to tap-and-hold)
- ❌ Pagination or infinite scroll
- ❌ Any animation that lasts longer than 300 ms on a core action
- ❌ Splash screens with timers
- ❌ "Onboarding tours" with skip buttons — use a simple first-use prompt instead

---

## 9. Quick Review Test

Before submitting any screen for review, answer these:

1. Is there **more than one primary action** visible at once? → Remove the extra.
2. Is any text **below 20 sp**? → Increase it.
3. Is any tap target **below 64 dp**? → Enlarge it.
4. Does any icon appear **without a text label**? → Add the label.
5. Is any important message in a **toast or auto-dismissing element**? → Make it persistent.
6. Does any error message contain a **technical term or code**? → Rewrite in plain language.
7. Is color used as the **only** way to convey status? → Add icon and word.
8. Is the **disclaimer** visible on result screens? → It must be.

---

*This document must be read by every developer and AI agent working on PillSafe UI before writing any Flutter widget code.*
