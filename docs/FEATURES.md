# Aven Fit — Comprehensive Feature Spec

> **Purpose:** The complete product feature specification — every feature, every screen, every sub-page across the full product vision (MVP → V2), with implementation-ready detail per screen.
> **Source:** Archived React Native frontend (tag `rn-final`) + `PRODUCT_ROADMAP.md` + archived UI/UX plan + competitor analysis + new proposals.
> **Rule:** Replicate behavior and UX intent, not code.
> **Last updated:** 2026-08-30

---

## 1. Product Overview

Aven Fit is an **offline-first gym tracker for Android**, targeting Indian fitness enthusiasts on budget phones. A user can log a workout at the gym with no account and no internet, and the app records everything, suggests weights from history, and shows progress — then handles the half of fitness no competitor in India handles well: **Indian food, fasting seasons, vegetarian protein, and regional language**.

**Positioning:** the only app that delivers **Hevy-level workout logging + MacroFactor-level nutrition intelligence + India-first cultural design** in a single, free-tier-friendly package.

Visual identity: dark "Sharp Glassmorphism" — pitch-black (OLED) surfaces, translucent glass cards, neon-cyan (#00F0FF) accent, sharp edges, tabular (monospaced) numerals so columns stack perfectly. Volt Green (#E2F835) for positive deltas/PRs; Burnt Orange (#E85D04) for destructive actions/warnings.

**Non-negotiable quality bar** (applies to every screen):

| Requirement | Target |
|:---|:---|
| APK size | <30MB |
| Set logging speed | <3s per set |
| Offline reliability | 100% for core workout flow — no network needed |
| First workout | <60s from install to first logged set |
| Cold start | <2s on a ₹9,000 phone |
| Battery | Minimal — no CPU polling; epoch-math timers, hardware sensors only |
| Target devices | Budget Android (₹8,000–₹15,000, incl. MIUI/ColorOS/FuntouchOS) |

---

## 2. Product Laws & Competitive Positioning

### 2.1 Product Laws (non-negotiable, learned from competitor failures)

These are **design laws**, not guidelines. Any feature that violates one gets cut or redesigned.

| # | Law | Why |
|:--|:---|:---|
| L1 | **Logging must be faster than lifting.** Any set loggable in <3s, one thumb. | The #1 judging criterion gym-goers use. 5+ taps = users return to pen & paper. |
| L2 | **Never require internet or an account** for core flows. | Basement gyms in Tier 2/3 cities have zero signal. Guest mode is full-featured. |
| L3 | **No paywall on core utility.** Unlimited routines forever. | Strong's 3-routine cap caused user revolt; MFP paywalling barcode scan felt like betrayal. |
| L4 | **Never shame.** No red over-calorie alarms, no angry streak-break screens. Adherence-neutral UI. | Calorie shaming → users stop logging honestly → data quality dies → product dies. |
| L5 | **No interruptions in the logging flow.** No ads, videos, or upsells inside Active Workout. | A quiet gym + unwanted media = instant uninstall. |
| L6 | **Every screen has designed empty / loading / error states.** Never blank, never crashed. | WorkoutSummary standard from the RN era. |
| L7 | **Destructive actions need confirmation; sessions survive crashes.** | Data-loss reports are the most damaging complaints in this category (Hevy reviews). |
| L8 | **Respect the battery and the OS.** No CPU polling; foreground service only during active sessions; obey Doze. | MIUI/ColorOS kill background apps; battery drain is a top Hevy/Strong complaint. |
| L9 | **Users own their data.** Full export always available; no lock-in mechanics. | Poor export is a recurring Strong/MFP complaint; lock-in causes backlash. |
| L10 | **India is not a localization — it's the product.** Food, fasts, veg protein, Hinglish, household servings are first-class data. | The entire moat. Western apps treat this as an afterthought. |

### 2.2 Why We Win (competitor pain → our answer)

| Competitor pain (documented) | Aven Fit's answer |
|:---|:---|
| Strong: 3-routine free cap | **Unlimited routines forever** (L3) |
| Hevy: analytics paywalled, subscription-only | Generous free tier; lifetime option later; 30-day analytics free |
| Hevy/Strong: no nutrition at all | Full Indian nutrition suite on the same tab bar |
| MFP/HealthifyMe: garbage crowd-sourced Indian food data | **Curated, verified Indian DB** with household units (katori, roti, ladle) — no unmoderated user entries |
| Western apps: no fasting awareness | **Vrat Mode** with festival calendar, satvik food switch, streak freezes |
| Everyone: "eat chicken breast" | **Vegetarian Protein Intelligence** (pairing engine, protein-gap alerts) |
| Western apps: English-only | Hinglish voice logging + Hindi, then Tamil/Telugu/Marathi |
| Hevy: offline unreliable, battery drain | Offline-first architecture (L2) + OEM battery survival kit (§16) |
| Hevy: data loss reports | Write-through SQLite per set + local rolling backups (L7, §16.2) |
| All: onboarding walls before first use | 60-second first-workout path, zero required fields (§5) |

---

## 3. Phase Legend

Every feature/screen is tagged with its roadmap phase. Build order = phase order.

| Tag | Phase | Meaning |
|:---|:---|:---|
| `[P0]` | MVP P0 — "Ship It" | Authorized for current development |
| `[P1]` | MVP P1 | Build after P0 is stable |
| `[V1.1]` | V1.1 — "Delight" | Build after MVP is released |
| `[V2]` | V2.0 — "Dominate" | Only when explicitly authorized |
| `[PROPOSED]` | — | New proposal not yet in `PRODUCT_ROADMAP.md`; needs user approval before building. Always paired with a suggested phase, e.g. `[P1][PROPOSED]` |

Within each phase, screens inherit the phase of their feature. A `[P0]` screen may contain `[P1]`-tagged sub-sections.

> **Promotion rule:** when the user approves a `[PROPOSED]` item, it gets added to `PRODUCT_ROADMAP.md` and loses its `[PROPOSED]` tag. This doc never promotes itself. A full ledger of proposals lives in §20.

---

## 4. Complete Screen Map

Every screen and sub-page in the product. Sub-pages are indented. This tree is the master index of the spec.

```
FIRST-RUN & ONBOARDING
├─ Welcome / 60-second path                          [P0]
├─ Optional 3-question setup quiz                    [P0][PROPOSED]
└─ Just-in-time permission primers                   [P0]

AUTH [P0]
├─ Login (phone number)                              [P0]
│  └─ OTP Verification                               [P0]
└─ (Google Sign-In — same entry screen)              [P0]

MAIN TABS [P0]
├─ Home                                              [P0]
├─ Workouts (Routines)                               [P0]
├─ Progress                                          [P0]
└─ Nutrition                                         [P0]

WORKOUT
├─ Active Workout                                    [P0]
│  ├─ Exercise Picker (in-session mode)              [P0]
│  ├─ Rest Timer bar + notification/lock screen      [P0]
│  ├─ Plate Calculator + visualizer                  [P1][PROPOSED]
│  ├─ Superset/dropset grouping                      [V1.1]
│  └─ Timed/bodyweight/cardio entry modes            [P1][PROPOSED]
├─ Workout Summary                                   [P0]
│  └─ Share-as-image card                            [P1][PROPOSED]
├─ Workout History list + calendar                   [P0][PROPOSED: calendar]
│  └─ Past Workout Detail                            [P0][PROPOSED]
│     └─ Compare-with-last diff                      [V1.1][PROPOSED]
└─ Routine Editor
   ├─ Routines List (+ folders)                      [P0] / folders [P1][PROPOSED]
   ├─ Routine Detail                                 [P0]
   ├─ Routine Metadata                               [P0]
   ├─ Routine Exercise Editor                        [P0]
   └─ Weekly Schedule (plan)                         [P1][PROPOSED]

EXERCISES
├─ Exercise Directory                                [P0]
├─ Exercise Detail                                   [P0]
│  ├─ Exercise History (per-exercise log)            [P0][PROPOSED]
│  ├─ Demo media (looped WebP/GIF)                   [P1][PROPOSED]
│  └─ Alternatives/substitutions                     [V1.1][PROPOSED]
└─ Create Custom Exercise                            [P0]

PROGRESS
├─ Progress Dashboard                                [P0]
│  ├─ PR Vault                                       [P0]
│  ├─ Body Weight History + log                      [P1]
│  ├─ Body Measurements (tape + body fat)            [P1][PROPOSED]
│  ├─ Progress Photos + compare                      [V1.1]
│  ├─ 1RM Chart per exercise                         [V1.1]
│  ├─ Muscle Volume Distribution                     [V1.1]
│  ├─ Workout Calendar (heatmap)                     [P0][PROPOSED]
│  ├─ Weekly Report card                             [V1.1][PROPOSED]
│  └─ Achievements / Badges                          [V1.1][PROPOSED]
└─ [V1.1] Advanced analytics (date ranges, heatmap polish)

NUTRITION
├─ Nutrition Dashboard (+ water row)                 [P0] / water [P1][PROPOSED]
│  ├─ Meal Logging (per-meal view)                   [P0]
│  │  ├─ Food Database Search                        [P0]
│  │  │  └─ Food Item Detail                         [P0]
│  │  ├─ Create Custom Food                          [P1][PROPOSED]
│  │  ├─ Barcode Scanner                             [P1]
│  │  ├─ Copy yesterday / last week                  [P1][PROPOSED]
│  │  └─ Saved Meals (templates)                     [P1][PROPOSED]
│  └─ Day Nutrition History                          [P1][PROPOSED]
├─ Thali quick-log + cooking modifiers               [V1.1][PROPOSED]
├─ Vrat/Fasting Mode                                 [V1.1]
├─ Vegetarian Protein Intelligence                   [V1.1]
└─ AI Photo Meal Recognition                         [V2]

ACCOUNT & SYNC
├─ Profile                                           [P0]
├─ Settings hub                                      [P1][PROPOSED]
│  ├─ Units (kg/lb)                                  [P1][PROPOSED]
│  ├─ Dark/Light theme                               [P1] (dark is default)
│  ├─ Language                                       [V1.1] (Hindi) / [V2]
│  ├─ Rest timer / haptics / sound defaults          [P1][PROPOSED]
│  ├─ Battery-optimization setup guide               [P1][PROPOSED]
│  ├─ Data Export + local backups                    [P1][PROPOSED]
│  ├─ Data Import (Hevy/Strong CSV)                  [P1][PROPOSED]
│  └─ Account / Sign out                             [V1.1] (sync-dependent)
└─ Sync status (background; surfaced in Settings)    [V1.1]

SOCIAL [V1.1]
├─ Social Feed (tab or entry from Home)              [V1.1]
│  ├─ Create Post (share workout)                    [V1.1]
│  ├─ Post Detail (kudos, comments)                  [V1.1]
│  ├─ Friend Search / Follow                         [V1.1]
│  └─ Notifications                                  [V1.1]
├─ Routine sharing (QR / deep link)                  [V1.1][PROPOSED]
├─ Private Squads & Challenges                       [V2]
└─ Trainer/Client Mode                               [V2]

AI [V2]
├─ AI Workout Generator                              [V2]
├─ Adaptive TDEE Engine (goal settings page)         [V2]
└─ Voice Logging (Hinglish)                          [V2]

PLATFORM SURFACES
├─ Active-session foreground notification            [P0]
│  └─ Lock-screen 1-tap set logger                   [P0][PROPOSED]
├─ Home-screen quick-start widget                    [P1][PROPOSED]
└─ Wear OS companion                                 [V2][PROPOSED]
```

Dead prototypes in the RN archive (`TrainScreen`, `TodayScreen`, `history/ProgressScreen`, `NutritionScreen` v1, `ProfileScreen` stub) were superseded by the final set above — do **not** re-implement them.

---

## 5. First-Run & Onboarding `[P0]`

**Purpose:** Deliver the 60-second promise: install → first logged set, with zero required input. Onboarding is an offer, never a wall (L1, L2).

### 5.1 Welcome / 60-second path `[P0]`
- First launch lands on **Home**, not a quiz. Home's empty state *is* the onboarding: giant "START FIRST WORKOUT" primary action + three-line explainer ("No account needed. Works offline.").
- The single fastest path must always be alive: **START → search "bench" → type 40×8 → ✓**. Nothing in between.

### 5.2 Optional setup quiz `[P0][PROPOSED]`
- **Skippable bottom sheet**, never blocking. Three questions max, each with a skip affordance:
  1. **Goal:** Build muscle / Lose fat / Get stronger / General fitness → seeds calorie/macro targets (Mifflin-St Jeor from profile values; height/weight asked in the same sheet, both optional).
  2. **Units:** kg (default) / lb.
  3. **Days per week:** 3 / 4 / 5 / 6 → seeds the matching **starter routine** (§8.9) and the weekly streak target (§17).
- Completing takes <20s and immediately yields: goals set + a routine ready + a weekly target. Skipping yields defaults (kg, no goals, 3/week target).

### 5.3 Just-in-time permission primers `[P0]`
- Permissions are requested **in context, never at launch**:
  - Notifications → the first time a rest timer needs lock-screen countdown (roadmap #4). Explainer: "See your rest countdown on the lock screen."
  - Camera → first barcode scan use.
  - SMS Retriever API for OTP autofill — **no SMS permission needed** (battery- and privacy-friendly).
- Denial never breaks a core flow: rest timer still works in-app; barcode has manual-entry fallback.

### 5.4 Guest mode `[P0]`
- Full feature set, local-only data, clearly labeled in Profile ("Local profile — sign in to back up").
- Sign-in later silently links local data to the account (client-generated UUIDs make this trivial — no merge conflicts possible for a fresh account).

---

## 6. Auth `[P0]`

### 6.1 Login Screen `[P0]`
**Purpose:** Sign in / sign up via phone number (no passwords — sign-up is implicit: same flow for new and returning users) or Google.

- **Elements:** app logo/wordmark, country code selector (+91 default, other codes for NRI users), phone number input, "Continue" button, Google Sign-In button, "Continue as guest" link, Privacy Policy + Terms link (DPDP Act transparency).
- **Interactions:** numeric keypad; paste support; 10-digit Indian validation primary; Continue → OTP Verification. Google → direct sign-in. Guest → Home.
- **States:**
  - *Empty/invalid phone:* inline validation error, no navigation.
  - *Network error:* toast/alert with retry.
  - *Guest mode:* everything works offline; sign-in offered later from Profile (§13.1).

### 6.2 OTP Verification `[P0]`
**Purpose:** Verify the phone number with a 6-digit OTP.

- **Elements:** 6-cell OTP input (auto-advance), SMS Retriever autofill (no permission), paste support, resend timer (30s countdown), change-number link.
- **Interactions:** auto-submit when 6 digits filled; resend; edit phone number.
- **States:** *verifying* (spinner), *invalid code* (shake + clear + error), *expired* (prompt resend), *success* → silently merge guest data into the account → Home.

---

## 7. Main Tabs & Home `[P0]`

Bottom tab bar: **Home · Workouts · Progress · Nutrition** — pitch-black bar, white active tint, glass border top. (Profile/Settings is reached from Home header, not a tab.)

### 7.1 Home `[P0]`
**Purpose:** Today's launchpad — resume or start a workout in one tap, see momentum at a glance.

- **Sections (top → bottom):**
  1. Greeting + date (time-of-day microcopy: GOOD MORNING / AFTERNOON / EVENING / NIGHT); profile/settings avatar (→ Profile).
  2. **Resume banner** *(conditional)*: if a session is in progress — cyan-bordered card "Workout in progress · 23:41 elapsed" → returns to Active Workout. Never buried.
  3. **START NEW SESSION** — giant primary action → Active Workout (empty session).
  4. **Suggested routine** card (if routines exist): P0 = most-used routine (or the one scheduled for today if §9.5 is approved); one-tap start. `[P1][PROPOSED: smart suggestion]` = rotate by least-recently-trained muscle groups.
  5. **Glance stats** (all real data; week-over-week delta badges in Volt Green / Burnt Orange):
     - Workouts this week vs. weekly goal ("2 of 4") — the forgiving streak (§17)
     - Volume this week (kg) + ▲/▼ vs last week
     - Sets this week
     - Current streak (with freeze indicator when frozen)
     - Today's calories remaining (only if goals are set; hidden otherwise — never a nag, L4)
  6. **Recent Logs:** last 10 completed workouts — name, relative date ("2d ago"), exercise list preview, `sets · volume · duration`, PR-count chip when any. Tap → Past Workout Detail (§8.8).
- **States:** *first-run empty* (welcome state driving to first workout — the 60s goal), *no recent workouts* ("Your history will appear here").
- **Polish:** no pull-to-refresh needed (local data is instant); any tap that starts a session must respond <100ms with a screen transition.

---

## 8. Workout — The Core Loop `[P0]`

The heart of the app: create a session, add exercises, log sets set-by-set. Offline-first, always. This section is the most detailed in the spec because it *is* the product.

### 8.1 Active Workout Screen `[P0]`
**Purpose:** The live logging surface. Fast, thumb-friendly, never loses state, never requires looking away from the weights.

**Entry points:** START NEW SESSION (Home) · START on a routine (Workouts tab) · Resume banner/notification.

**One-session rule:** only one active session may exist. Starting another while one is active prompts: **Resume / Save current as completed / Discard current** (confirm).

- **Header:** workout name (tappable to rename), ticking session timer, pause/resume button, FINISH button. Rest-timer slim bar lives under the header (never blocks content).
- **Auto-naming:** by time of day (randomized within a band) —
  | Time | Name options |
  |:---|:---|
  | 00:00–05:00 | Late Night Lift · Midnight Session |
  | 05:00–09:00 | Early Bird Workout · Dawn Patrol |
  | 09:00–12:00 | Morning Grind · Morning Workout |
  | 12:00–17:00 | Afternoon Pump · Midday Session |
  | 17:00–21:00 | Evening Workout · Sundown Session |
  | 21:00–24:00 | Night Session · Late Lift |
  Starting from a routine names it after the routine. User can always rename.
- **Exercise blocks:** each added exercise renders a block:
  - **Block header:** exercise name (tap → quick-info sheet: muscles, last performance summary "Last: 4 sets · best 62.5 kg × 8"), drag handle, overflow menu (Remove, Swap `[V1.1: smart same-muscle suggestions]`, Add note, Rest-time override `[P1][PROPOSED]`).
  - **Rows:** `SET # | PREV | KG | REPS | ✓` (+ optional RPE chip `[P1][PROPOSED]`, warm-up toggle `[P0][PROPOSED]`).
  - **Ghost placeholders:** ADD SET pre-fills the *hint* (not the value) with the most likely numbers — previous set this session, else last performance of this exercise. Type over it, or tap ✓ to accept.
  - **Routine targets:** when started from a routine, rows show targets ("Target: 80 × 8") and hints prefill from targets.
  - **Accepting a set:** ✓ auto-fills empty fields from the suggestion, locks the row (Volt Green accent, read-only), starts the rest timer, fires a short haptic tick. Row shows a tiny **PR badge** if it beat any personal record (weight, e1RM, reps-at-weight, volume) — computed instantly from local history.
  - **Quick steppers `[P0][PROPOSED]`:** +/−2.5 kg buttons flanking the weight field (adaptive step: 1 kg for dumbbells) so logging can avoid typing entirely.
  - **Input rules:** weight = decimals only (one point); reps = whole numbers only. Invalid entries blocked and reported inline — never silently dropped.
  - **Copy previous set `[P0][PROPOSED]`:** one tap duplicates the last row's values into a new row.
  - **Undo `[P0][PROPOSED]`:** accidental ✓ → snackbar "Set completed · UNDO" for 5s; completed rows also unlock via tap.
  - **Row actions:** swipe/tap to delete an unlocked set; completed sets editable via tap (long-press on constrained screens) `[PROPOSED: edit UX]`.
  - **Warm-up pyramid generator `[P0][PROPOSED]`:** ⚡ icon on the weight field (or long-press on a set row) auto-generates a progressive warm-up ladder from the working/target weight, inserted as flagged rows immediately before the working set:
    | Row | Load | Reps |
    |:--|:--|:--|
    | 1 | Empty bar (20 kg) | 10 |
    | 2 | 50% | 5 |
    | 3 | 70% | 3 |
    | 4 | 85% | 1 |
    | — | Working set (100%) | user's target |
    (target 100 kg → 20×10, 50×5, 70×3, 85×1, 100×target.) Every generated row carries `is_warmup: true` (the `set_type` warm-up flag §8.1 already anticipates): excluded from working volume, PR detection, and streak/e1RM math (§10.2), auto-collapsed under working sets, individually editable/removable. One tap replaces ~30s of manual warm-up entry — the L1 law extended to the pre-workout ritual. Optional toggle in Settings (default ON) for lifters who warm up their own way.
- **Set-type support:**
  - **Warm-up toggle `[P0][PROPOSED]`:** marks a row WARMUP (schema `set_type` ready); warm-ups are excluded from volume totals and PR detection; auto-collapse under working sets.
  - **Supersets/dropsets `[V1.1]`** (roadmap #17): multi-select blocks → group with A1/A2 letter markers; dropset = chained row under a parent set.
  - **Timed sets `[P1][PROPOSED]`:** exercises flagged "time-based" (planks, hangs) log seconds instead of reps, with optional countdown mode.
  - **Bodyweight ±load `[P1][PROPOSED]`:** pull-ups/dips log added weight; assisted variants log assist weight.
  - **Cardio mode `[P1][PROPOSED]`:** duration + distance (treadmill/cycle/rower) with auto-computed pace. Minimal — not a run tracker.
- **"+ ADD EXERCISE"** → Exercise Picker (in-session mode, §8.2).
- **Session timer:** continuously ticking. **Pause** freezes it and visibly marks PAUSED. Timer math is epoch-based (`started_at` + accumulated paused time via the `last_resumed_at` pattern from RN) — zero CPU cost, survives process death (L8).
- **Screen behavior:** keep screen awake while a session is active and the logging surface is visible `[P0][PROPOSED]` (toggle in Settings).
- **Foreground service `[P0]`:** persistent notification during active sessions — elapsed time + rest countdown + Finish action. This is the Android mechanism that makes rest timers survive lock screen and OEM app killers (roadmap #4, L8).
  - **Lock-screen 1-tap set logger `[P0][PROPOSED]`:** the notification's `RemoteViews` gains a direct action button — `[ ✓ Log Set: 80kg × 8 ]` — reflecting the current ghost/target set. One tap from the lock screen, without unlocking (sweaty/chalky hands never touch the touchscreen), commits the set: write-through to SQLite (L7), row locks Volt Green, advances to the next ghost set, restarts the rest countdown — all re-rendered live on the same lock-screen notification. A PR on the logged set fires the usual haptic badge on unlock. Battery-clean by construction: no polling, just notification re-render on state change inside the existing foreground service (L8). Actions always mirror app state (no stale "log set" after Finish); in-app undo (§8.1) still applies.
- **Persistence (critical, L7):** every confirmed set is written to SQLite immediately (write-through). Closing the app mid-session and reopening restores exact exercises, sets, elapsed time; resumed time keeps counting, paused time stays frozen (`last_resumed_at` pattern from RN). Survives crashes.
- **Finish:** optional rename dialog → save → Workout Summary.
- **Discard workout:** confirm dialog ("Discard session? This can't be undone") `[PROPOSED: explicit discard UX]`.
- **States:** *empty session* ("Add your first exercise" + shortcut to favourites), *restored session* banner ("Workout resumed"), *saving* spinner on Finish, *save error* with retry (data stays local, always recoverable).

### 8.2 Exercise Picker (in-session) `[P0]`
The Exercise Directory opened in workout mode (§10.1): tapping any exercise adds it to the session and returns. Multi-select `[P1][PROPOSED]` to add several at once (also the future entry point for superset grouping). **Recents + Favourites pinned at top** — most users repeat ~15 exercises.

### 8.3 Rest Timer `[P0]`
- Completing a set auto-starts a **90-second countdown**, rendered as a slim bar under the header (never blocks the screen).
- Controls: +15s / −15s, dismiss, restart. Manually startable from the header.
- **Auto-cancel:** logging the next set (any ✓) cancels the countdown — resting and lifting are mutually exclusive states.
- **Lock-screen / notification countdown `[P0]`:** via the foreground-service notification (§8.1) — countdown visible with a +15s action without unlocking (roadmap #4). The 1-tap logger action (§8.1 `[PROPOSED]`) lives on this same notification: logging the next set from the lock screen follows the same auto-cancel rule — the countdown is replaced by the restarted rest timer for the new set. Silent channel; optional completion sound/vibration per Settings `[P1][PROPOSED]`.
- **Per-exercise defaults `[P1][PROPOSED]`:** routine target rest overrides global default; muscle-tier fallback (compounds ~180s, isolation ~60–90s). Auto-suggested from the exercise's primary muscle + equipment when unknown.
- **Rest primer `[P1][PROPOSED]`:** optional 10s "get set" countdown when starting from a routine.

### 8.4 Plate Calculator `[P1][PROPOSED]`
- Tapping the KG field on any barbell exercise offers a bottom sheet: enter target weight → **per-side plate breakdown**, using the user's **gym plate inventory** (Settings: which of 0.5/1.25/2.5/5/10/15/20/25 kg plates exist; bar weight, default 20 kg).
- **Interactive tactile barbell visualizer `[P1][PROPOSED]`:** not a text list — a rendered side-view Olympic barbell diagram loaded with real-to-scale plates drawn from the user's **gym plate inventory** (25/20/15/10/5/2.5/1.25/0.5 kg; bumper vs iron visual styles, color-coded per IPF/IWF convention). Per-side breakdown as physically loaded (heaviest inward); tap any plate to inspect/adjust; inventory-aware alternatives shown when a plate is missing ("No 10s — 2×5 instead"). Per-side total always shown in tabular numerals. Handles uneven loads and converts lb plates if needed.
- Pure offline local rendering (Canvas/CustomPaint) — zero network, zero extra battery draw beyond a static layout pass (L2, L8).
- Rationale: named in the competitor analysis as a missing must-have (Hevy gap).

### 8.5 Workout Summary `[P0]`
Shown immediately after finishing (replaces the workout screen). This is the dopamine moment — make it feel earned.

- **Streak badge:** consecutive-day streak (counts today; tolerates a "yesterday" start; min 1). PR celebration micro-animation on new records `[PROPOSED]` — haptic buzz + brief Volt Green flash, never confetti-heavy (L5).
- **Stats grid:** duration · total volume (weight × reps of completed sets, warm-ups excluded) · set count · PRs hit (count, if any).
- **Workout breakdown:** one card per exercise, each completed set as `weight × reps`.
- **Inline rename:** pencil on title; saves on submit/blur; blank → "Workout".
- **Actions:** Done (→ Home) · Share `[V1.1 with social]`; `[P1][PROPOSED: share-as-image]` — renders a branded summary card image (dark, glass, cyan accent) shareable to WhatsApp/Instagram; no login required (L2).
- **"Save as routine" `[P1][PROPOSED]`:** convert this session into a reusable routine (one tap → Routine Editor pre-filled).
- **Error UX (preserve):** workout-not-found → clear state with a way back; never blank/crashed (L6).

### 8.6 Workout History `[P0]` + Calendar `[PROPOSED]`
**Purpose:** Browse every past workout. (Home shows only 10 — this is the full list.)

- **Full workout list** (dedicated screen; RN only surfaced 10 on Home): grouped by week/month; each row shows name, date, duration, volume, sets, PR chip.
- **Calendar view `[PROPOSED]`:** month grid with workout-day dots + streak visualization; tap a day → that day's workouts.
- **Filter/search `[PROPOSED]`:** by name, date range, exercise performed.

### 8.7 Past Workout Detail `[P0]` `[PROPOSED]`
**Purpose:** Read-only view of a finished workout. (Not built in RN — Home "Recent Logs" items went nowhere.)

- Same layout as Workout Summary minus celebrations.
- Actions: **Repeat this workout** (starts a new session pre-loaded with these exercises/sets), **Save as routine** `[P1][PROPOSED]`, rename, delete (confirm).
- **Compare-with-last `[V1.1][PROPOSED]`:** when repeating, show per-set deltas vs the previous occurrence ("+2.5 kg on squat").

### 8.8 Routine Editor `[P0]`
Three sub-pages designed in RN (builder was never wired — build for Flutter with this schema of intent), plus proposals:

#### 8.8.1 Routines List (Workouts tab) `[P0]`
- All routines: name + description + exercise-count; each has **START** (creates a pre-named session) and opens for detail/editing.
- Empty state guides users to create their first plan — or pick a **starter template** (§9.6).
- **Folders `[P1][PROPOSED]`:** group routines (e.g. "PPL", "Home"); simple expand/collapse, from the archived UI plan.
- **Duplicate `[P0][PROPOSED]`:** copy any routine as a starting point.

#### 8.8.2 Routine Detail `[P0]`
- Full routine preview: ordered exercises, per-exercise target sets, weight/reps/RPE targets, rest durations, est. session duration.
- Actions: START, Edit, Duplicate, Delete (confirm).

#### 8.8.3 Routine Metadata `[P0]`
- Name, description, (cover color/icon `[PROPOSED]`). Saves back to list.

#### 8.8.4 Routine Exercise Editor `[P0]`
- Ordered exercise list: add (→ Directory in picker mode), remove, reorder (drag), per-exercise editor: target sets, target weight/reps, RPE, rest seconds.
- **Per-exercise set schemes `[P1][PROPOSED]`:** e.g. "3×8–10" with a rep *range*, so later sessions can suggest within range.

#### 8.8.5 Weekly Schedule `[P1][PROPOSED]`
- Map routines to weekdays (Push Mon / Pull Wed / Legs Fri); drives the Home "suggested routine" card and the weekly-goal progress ("on track: Push today").
- Calendar sync is out of scope; this is an in-app plan only.

### 8.9 Starter Routine Templates `[P0][PROPOSED]`
- Ship with 4–6 quality templates: Full Body 3×, Push/Pull/Legs, Upper/Lower 4×, Dumbbell-Only Home, Bodyweight Beginner, 5×5.
- Offered at first-run (from setup quiz §5.2) and from the Routines empty state; one tap clones them into editable user routines.
- Cheap to build (pure seed data), massive time-to-first-workout win, and showcases unlimited routines (L3).

## 9. Exercises `[P0]`

### 9.1 Exercise Directory `[P0]`
- Searchable list, grouped by muscle category; ships with the starter library (roadmap: 200+ exercises with muscle-group tags; RN era had 10 common ones).
- **Equipment filter chips:** All / Barbell / Dumbbell / Machine / Cable / Bodyweight (+ Kettlebell, Band) `[PROPOSED: + muscle-group filter, favourites]`.
- **Favourites `[P0][PROPOSED]`:** star exercises; favourites + recently used float to top of picker mode.
- **Context-aware tap:** during an active workout → adds it to the session; otherwise → Exercise Detail.
- **Local-first library:** the 200+ exercise set ships inside the APK/asset bundle so search works with zero network (L2); server library updates are a sync-era enhancement.

### 9.2 Exercise Detail `[P0]`
- Name, muscle group(s) (primary/secondary), equipment, instructions/notes.
- **Exercise History `[PROPOSED]`:** last performances (date, best set, volume) + mini e1RM/volume trend — the data that powers ghost suggestions. This is where "what did I do last time" lives.
- **Demo media `[P1][PROPOSED]`:** looped WebP/GIF per exercise (APK-size budget: compressed, on-demand pack optional). Videos are a V1.1+ decision (L5: no autoplay with sound, ever).
- **Alternatives/substitutions `[V1.1][PROPOSED]`:** same-muscle, same-equipment swaps ("Shoulder hurts on OHP → landmine press").
- Actions: add to current session (if one is active), favourite `[P0][PROPOSED]`, edit (custom exercises), delete (custom only, confirm + re-assign logged data).

### 9.3 Create Custom Exercise `[P0]`
- Name (required, unique), muscle group(s), equipment type, notes, (optional: mark as time-based/cardio `[P1][PROPOSED]` to unlock those entry modes).
- Lands on its Detail.

---

## 10. Progress & Analytics `[P0]` (basics) → `[V1.1]` (advanced)

### 10.1 Progress Dashboard (tab) `[P0]`
Three real-calculation sections for Flutter (RN showed mocks) + calendar:
1. **PR Vault preview** — recent personal records → full PR Vault.
2. **Body Weight preview** — current weight + trend → Body Weight History `[P1]`.
3. **Strength preview** — top-exercise e1RM trend → 1RM Chart `[V1.1]`.
4. **Workout Calendar `[PROPOSED]`:** streak/consistency heatmap on the dashboard.
5. **Time-range selector `[P1][PROPOSED]:** 7D / 30D / 3M / 6M / 1Y / ALL across cards (from the archived UI plan).

### 10.2 PR Vault `[P0]`
Personal-record trophy room.
- **PR detection** = new max weight, estimated 1RM (Epley), max reps at a weight, and volume PRs per exercise `[PROPOSED: PR type breakdown]`; also all-time bodyweight-milestone badges ("Bodyweight Bench") `[V1.1][PROPOSED]`.
- Each entry: exercise, record type, value, date achieved. Filter by exercise; sort by date/value.
- Empty state explains how PRs are earned (L6).
- PRs are computed locally and incrementally at set-save time; warm-up sets never count.

### 10.3 Body Weight History `[P1]`
- Current weight, trend chart (7/30/90-day ranges), quick-add today's weight, edit/delete entries.
- **Trend line, not noise:** display 7-day rolling average as the headline number (adherence-neutral, L4 — raw daily swings discourage users).
- **Goal weight line `[PROPOSED]`;** optional; framed neutrally ("Goal: 75 kg · 3.2 kg to go") with no red/green judgment.
- **Measurements beyond weight `[P1][PROPOSED]:** waist, chest, arms, thighs, hips, body-fat % — same log/chart pattern (schema `body_measurements` already anticipates this). Named in the competitor analysis as a must-have Hevy/Strong gap.
- **Smart-scale import `[V2][PROPOSED]:** via Health Connect (§16.2).

### 10.4 Progress Photos `[V1.1]` (roadmap #18)
- Monthly photo log per pose (front/side/back), stored **locally and encrypted at rest**; never uploaded without explicit action (L9).
- **Compare tool:** pick two dates → side-by-side, synchronized zoom; optional overlay blend.
- Tied to weight trend so users can see "scale says +1 kg, photo says leaner" — the antidote to scale-only shaming (L4).

### 10.5 1RM Chart (per exercise) `[V1.1]`
- Exercise picker → estimated-1RM trend over time from set history (Epley formula), configurable range; overlay of actual top-set weight.

### 10.6 Muscle Volume Distribution `[V1.1]`
- Volume by muscle group over a selected period — bar/pie "heatmap" view; informs weak-point training.
- Weekly sets-per-muscle table with a 10–20 set guideline band `[V1.1][PROPOSED]` (evidence-based, never scolding, L4).

### 10.7 Advanced Analytics `[V1.1]`
- Custom date ranges across all analytics; muscle heatmap (roadmap #15).
- **Weekly Report `[V1.1][PROPOSED]:** auto-generated weekly/monthly training recap — sessions, volume, top PRs, consistency % — shown in Progress and (later) shareable (from competitor analysis "training reports").

### 10.8 Achievements & Badges `[V1.1][PROPOSED]`
- Milestone trophies: 100 Workouts, 1,000-Tonne Club (lifetime volume), Bodyweight Bench, 2× Bodyweight Deadlift, Perfect Week (hits weekly goal), Streak 30, First PR…
- Delivered with the same restraint as PR celebrations: haptic + card, no sounds, no confetti spam (L5). Viewable trophy room; zero notifications for badges.

---

## 11. Nutrition `[P0]` (basics) → `[P1]`/`[V1.1]`

Nutrition design law: **adherence-neutral** (L4). The dashboard shows facts, never verdicts. "2,150 / 2,400 kcal" with a calm bar — not red alarms. This is a deliberate differentiator vs calorie-shaming apps and directly protects data quality.

### 11.1 Nutrition Dashboard (tab) `[P0]`
- **Calories remaining vs. goal** (primary visual), **macro targets** — protein / carbs / fat consumed vs. target, as flat bars (no radius, no judgment colors — cyan fill on grey track).
- **Protein emphasized:** protein bar visually first-class (the #1 macro for this audience; see Protein Intelligence §11.9).
- **Water row `[P1][PROPOSED]:** `0.0 / 2.7 L` + quick-add buttons (+250 ml / +500 ml glass presets); from the archived UI plan; reminder optional, default off (L4).
- **Four meal sections:** Breakfast / Lunch / Dinner / Snacks — each lists logged foods (name, serving, kcal, protein) with quick-add. (+ Pre/Post-Workout meal types exist in schema `[P1][PROPOSED]` to surface them.)
- **Day navigation `[PROPOSED]`:** swipe/date-picker to view previous days (RN was today-only).
- **Copy yesterday / copy last `[P1][PROPOSED]:** one tap clones a previous day's meals into today — the single biggest daily-logging accelerator for repetitive Indian diets.
- **Saved Meals `[P1][PROPOSED]:** save a full meal combo ("My breakfast: 4 egg whites + 2 roti + curd") as a one-tap template.
- Goal editing (calorie + macro targets) lives on first-run onboarding or settings `[PROPOSED: onboarding quiz]`.

### 11.2 Meal Logging (per-meal view) `[P0]`
- Opens from a meal section: that meal's foods for the day, serving edit, remove item, add food → Food Database Search.
- Inline quantity adjust with instant macro recalculation.

### 11.3 Food Database Search `[P0]`
- Search ~5,000 curated Indian food entries (roadmap #8 — paneer, roti, dal, idli, poha, etc.) **with household servings** ("1 katori", "2 roti", "1 ladle", "1 glass").
- **Local search:** the food DB ships in the APK (or on-first-run local pack) so search works offline (L2). Sync-era updates refresh it in background.
- Results: name, standard serving, kcal, protein, 🟢/🔴 veg indicator (FSSAI convention) `[PROPOSED]`.
- **Recent/frequent foods at top `[PROPOSED]`;** recents are the fastest path (logging is repetition).
- **No unmoderated crowd-sourcing:** user customs are private by default; public sharing of food entries (if ever) requires curation (anti-MFP law, from the analysis "What to AVOID").

### 11.4 Food Item Detail `[P0]`
- Full nutrition panel (kcal, protein, carbs, fat, fiber `[PROPOSED]`), serving-size selector (household units + grams), quantity stepper, meal selection, Add.
- **Cooking-style modifiers `[V1.1][PROPOSED]:** ghee/oil toggles ("Ghee on roti: none / light / generous"), curry style (home-style / restaurant-rich) — captures the hidden calories Western DBs miss (from the analysis).

### 11.5 Create Custom Food `[P1]` `[PROPOSED]`
- Homemade recipes: name, serving definition, per-serving macros → searchable like database items.
- **Recipe builder `[P1][PROPOSED]:** compose a dish from other foods (the "family recipe" case: total pot → servings → per-serving macros). Complements the "family cooking calculator" idea from the analysis.

### 11.6 Barcode Scanner `[P1]` (roadmap #9)
- Scan packaged food → product lookup → same add-to-meal flow.
- **Indian brand coverage** prioritized: Amul, Mother Dairy, Haldiram's, MTR, Tata, Nestlé India, etc.
- Offline fallback: scan requires connectivity for lookup (remote DB), but **recently scanned items cache locally**; manual entry always available (L2).

### 11.7 Day Nutrition History `[P1]` `[PROPOSED]`
- Browse previous days (calendar or list), per-day macro totals; tap a day → read-only dashboard clone with "copy to today" action.

### 11.8 Thali Quick-Log `[V1.1][PROPOSED]`
- The multi-component meal killer: tap a "Thali" template → check off components (2 roti ✓, dal ✓, rice ✓, curd ✓) → one entry.
- Regional thali presets (North/South/Gujarati...) with editable components. From the competitor analysis — a genuinely novel differentiator.

### 11.9 Vegetarian Protein Intelligence `[V1.1]` (roadmap #16)
- **Protein-gap insight:** "You're 25 g short today. Try: 200 g paneer tikka (36 g) or 2 scoops whey (50 g)." Neutral, practical framing (L4).
- **Pairing engine:** complementary protein suggestions (dal + roti, rajma + rice) with simple quality context (PDCAAS/DIAAS-informed, not academic).
- **Veg-first suggestions everywhere:** when the app suggests foods/recipes, veg options lead (30–40% of the market; also most non-veg users eat veg most days).

### 11.10 Vrat/Fasting Mode `[V1.1]` (roadmap #14)
- Festival-calendar aware (Navratri, Shravan, Ramadan, Ekadashi, Karwa Chauth) with user opt-in and region/tradition toggle (never assumes, L4).
- **Behaviors per the analysis:**
  - Auto-switch food search to **satvik/vrat-friendly set** (sabudana, kuttu, singhara, makhana, fruits).
  - Adjusted calorie/macro targets for the fasting window (e.g. Ramadan → suhoor/iftar meal structure).
  - **Streak freeze:** fasting days count as "active rest" — never break a streak (retention × culture fit).
  - Training guidance tone-shift ("lighter volume is fine today") — suggestion, not command.
- Fasting calendar data ships as an annually refreshed asset.

## 12. Account, Profile & Settings

### 12.1 Profile `[P0]`
- Name, photo, body metrics (height, weight link to body-weight log `[PROPOSED]`), member-since, quick stats (total workouts, streak record, lifetime volume).
- Guest-mode status banner ("Local profile — sign in to back up") with one-tap sign-in (§5.4).
- Entry to Settings.

### 12.2 Settings Hub `[P1]` `[PROPOSED]`
- **Units (kg/lb):** display conversion; storage stays kg `[P1][PROPOSED]`.
- **Theme:** dark (default) / light — roadmap #11 `[P1]`.
- **Language:** English → Hindi `[V1.1]`; Tamil/Telugu/Marathi `[V2]` (roadmap #19, #27).
- **Workout defaults `[P1][PROPOSED]:** default rest duration, plate inventory + bar weight (feeds Plate Calculator §8.4), keep-screen-awake toggle, rest-completion sound/vibration.
- **Haptics/sound `[P1][PROPOSED]:** granular toggles; all default tasteful/off where possible (L5).
- **Battery-optimization setup guide `[P1][PROPOSED]:** OEM-specific walkthrough (MIUI/ColorOS/FuntouchOS/One UI → "Unrestricted battery / auto-launch") with deep links where possible — directly from the analysis's budget-phone survival guide (L8).
- **Data Export `[PROPOSED]:** CSV/JSON of workouts + nutrition (L9); automatic local rolling backups `[P1][PROPOSED]` (last 7 days, restored on fresh install of same DB version).
- **Data Import — Hevy/Strong CSV `[P1][PROPOSED]`:** migration engine (§12.4).
- **About/licenses/open-source notices `[PROPOSED]`.**

### 12.3 Auth & Multi-Device Sync `[V1.1]` (roadmap #12)
- Offline-first invariant: all features work with no account/connection; local SQLite is the primary store.
- **Background sync:** when signed in + online, push local changes, pull from other devices, conflict-safe (last-writer-wins per entity + operation queue pattern from the dev plan; workouts are largely append-only which minimizes conflicts).
- Client-generated UUIDs, `sync_status` flags, `sync_queue` table (schema per `DEVELOPMENT_PLAN.md` Step 1.4).
- Sync runs on WorkManager: network-constrained, battery-friendly, exponential backoff (L8).
- Sync status (last synced, pending count) + sign-out surfaced in Settings.

### 12.4 Data Import — Hevy & Strong 1-Tap CSV Migration `[P1][PROPOSED]` (Trojan Horse)
**Purpose:** the acquisition wedge. A lifter switching from Strong or Hevy migrates 3+ years of workout logs and PR history in **<5 seconds** — removing the single biggest switching cost in this category and turning "new app risk" into a no-brainer trial.

- **Entry:** Settings → Data Import (§12.2); also surfaced contextually (e.g. "Coming from Strong?" link) — never an onboarding wall (§5).
- **Flow:** pick export file (system file picker; Strong CSV or Hevy CSV) → parse → preview with mapping review → import → done. One screen with progress states (L6).
- **Offline-only parsing:** fully local CSV parser in the app — no upload, no server round-trip, no account required (guest mode imports too, L2). Raw user data never leaves the device (DPDP-conscious, L9).
- **Fuzzy exercise matching:** parser maps export exercise names to the built-in library via normalized-name matching (aliases, equipment variants, common abbreviations) with **confidence scoring**:
  - High → auto-mapped silently.
  - Medium → suggested, batch-reviewed on one confirmation screen ("Squat → Barbell Back Squat ✓ / change").
  - Low/unmatched → offered as **custom exercise creation** pre-filled from the CSV row — never silently dropped (L7 spirit: no data loss).
- **Imports:** workouts (date, duration, notes), sets (weight × reps, order; RPE where exported), warm-up flags preserved where the source marks them (§8.1 `is_warmup`), PR history (recomputed locally at import — §10.2 incremental detection runs against imported history).
- **Idempotent + safe:** import runs in a single transaction; cancel before commit leaves SQLite untouched; duplicate re-imports are detected (source-ID check) and skipped — never double-logged (L7).
- **Success state:** "Imported 412 workouts · 9,873 sets · 31 PRs" → land on Progress so the user immediately sees their whole history rendered in Aven Fit.

---

## 13. Social `[V1.1]`

| Screen | Phase | Detail |
|:---|:---|:---|
| Social Feed | `[V1.1]` | Followed users' workouts/kudos feed (roadmap #13); entry from Home or tab. **Opt-in and skippable** — social is never forced (analysis anti-pattern) |
| Create Post | `[V1.1]` | Share a completed workout (auto-card from Workout Summary) or text; share-as-image works without any account (§8.5) |
| Post Detail | `[V1.1]` | Kudos, comments |
| People Search / Follow | `[V1.1]` | Find friends, follow/unfollow, profile view |
| Notifications | `[V1.1]` | Kudos, comments, follows, streak milestones. **Frequency-capped**; body-serenity rules (L5) — no "come back!" nags (analysis anti-pattern #1 for permission loss) |
| Routine sharing (QR / deep link) | `[V1.1]` `[PROPOSED]` | 1-click share a routine via QR code shown on screen or deep link — friend scans → routine cloned into their library. Organic growth loop from the analysis; cheap to build on top of routines |
| Private Squads & Challenges | `[V2]` | Cooperative 3–8 person challenges ("Squad goal: 1,00,000 kg this month") (roadmap #22); cooperative > competitive per the analysis (3× retention) |
| Trainer/Client Mode | `[V2]` | Trainers assign routines, view client logs (roadmap #23) |

---

## 14. AI & Intelligence `[V2]`

| Feature | Detail |
|:---|:---|
| Adaptive TDEE Engine | Dynamic calorie/macro targets from weight trend + logging (roadmap #20) — MacroFactor-style, **no static BMR formula as headline**; adds a goal-settings page. Remains adherence-neutral (L4): targets adjust silently, never scold |
| AI Workout Generator | Goal/experience/equipment/time → generated routine, saved into the normal routine system (roadmap #21); free tier gets limited generations/month per monetization plan |
| Smart Exercise Substitutions | Pain/shortage-aware swaps ("Shoulder hurts → landmine press") (roadmap-adjacent, from analysis); pairs with §9.2 alternatives |
| Voice Logging (Hinglish) | Log sets/meals by voice (roadmap #24); the demo line from the analysis — *"do roti aur ek katori moong dal khayi with thoda sa ghee"* — must parse |
| AI Photo Meal Recognition | Photograph food → identify items + estimate portions (roadmap #25); confidence-shown, user-corrected (data quality, L4) |
| Wearable Integration | Google Health Connect (primary, replaces Google Fit) + Indian wearables (Noise/boAt/Fire-Boltt via Health Connect where possible) (roadmap #26); steps/sleep/HR into recovery context, never as CPU polling (L8) |
| Supplement Tracker | Stack logging + timing reminders (roadmap #28) |
| Cycle-Aware Training | Menstrual cycle-aware recommendations (roadmap #29); opt-in, private, neutral framing |
| Deload Suggestions | Auto-detect accumulated fatigue from volume/e1RM stagnation trends → suggest a lighter week (from analysis AI section) `[V2][PROPOSED]` |
| Quick-Commerce Rewards | Fitness coins → Blinkit/Zepto/Swiggy Instamart discounts (roadmap #30) |

---

## 15. Cross-Cutting Requirements (every phase)

- **Offline-first (L2):** core flows (workout, routines, history, exercise search, basic analytics, food search) work with zero connectivity; network is enhancement only.
- **Persistence (L7):** every screen survives app kill; write-through to SQLite at every meaningful action (set completion above all); destructive actions require confirmation.
- **Error UX (L6):** every screen has designed empty / loading / error states — never blank or crashed (WorkoutSummary standard).
- **Performance:** budget-phone targets; list virtualization; zero jank on set logging; <100ms tap→screen transitions on session start; image/media lazy loading.
- **Battery (L8):** no CPU polling; epoch math for timers; foreground service only during active sessions; hardware step sensor or Health Connect only.
- **Security:** no secrets in code; auth tokens per Spring Security backend contracts; progress photos + body measurements encrypted at rest; DPDP-Act-conscious consent & privacy copy.
- **Accessibility & inclusivity:** touch targets ≥48dp (sweaty-gym thumbs), high contrast on OLED dark, inclusive defaults (women/beginners are first-class in imagery, templates, and copy — analysis content anti-pattern).
- **Localization-ready:** all strings externalized from day one even though MVP ships English-only (Hindi in V1.1 becomes cheap, not a rewrite).

---

## 16. Platform Reliability Kit (Android survival)

> Most of this is invisible in UI but decides 1-star vs 5-star reviews on budget phones. Sources: competitor analysis §6, L7/L8.

### 16.1 Foreground Service & Notifications `[P0]`
- Active session = foreground service with persistent notification (elapsed time, live rest countdown, +15s action, Finish action).
- **1-tap set logger `[P0][PROPOSED]`:** the notification's `RemoteViews` carries a direct `[ ✓ Log Set: 80kg × 8 ]` action bound to a BroadcastReceiver that commits the current ghost set to SQLite write-through (L7), advances to the next ghost set, and restarts the rest countdown — all reflected on the same lock-screen notification without unlocking the phone. The killer interaction for sweaty/chalky hands: the set is done before the phone leaves the pocket. Notification re-render only on state change — no polling, no wakelocks beyond the existing foreground service (L8). Action always mirrors live session state; in-app undo still works.
- Rest countdown continues on lock screen without unlocking (roadmap #4). Silent channel; sound/vibration only on completion if enabled.
- No service when no session is active (battery law).

### 16.2 Data Safety `[P0/P1][PROPOSED]`
- Write-through SQLite per set (P0) — crash-safe by construction.
- **Rolling local backups `[P1][PROPOSED]:** nightly export of the DB to app-storage (7-day window); fresh-install detection offers restore.
- **Auto-sync to cloud `[V1.1]:** once accounts exist, WorkManager sync becomes the disaster-recovery layer (§12.3).
- Export-anytime CSV/JSON (L9). Import is the mirror image: the offline CSV migration engine (§12.4) parses everything on-device, in one transaction, with duplicate detection — external data becomes local data safely or not at all.

### 16.3 OEM Battery Survival `[P1][PROPOSED]`
- In-app guided setup per OEM (MIUI/ColorOS/FuntouchOS/One UI/VoltageOS-grade forks): unrestricted battery, auto-launch, lock-task whitelist for sessions.
- Detect aggressive background kills (e.g. session timer jump after process death) and surface the guide contextually, once, politely.

### 16.4 Home-Screen Widget `[P1][PROPOSED]`
- Quick-start widget: "START WORKOUT" + current streak + resume state (if session active).
- One glance, one tap → logging. Zero-lockscreen-worth-it feature for gym check-ins.

---

## 17. Gamification & Retention `[P0]` (basics) → `[V1.1]`

> Philosophy from the analysis: **forgiving beats punishing**. Retention mechanics never conflict with culture (fasts), rest, or life.

- **Forgiving weekly streak `[P0]`:** the headline streak is "workouts this week vs. goal (3–6)", not a daily chain (§7.1). Daily-chain streak exists as a secondary stat with **streak freezes** for rest/fasting days `[V1.1][PROPOSED]`.
- **PR celebrations `[P0]`:** haptic + micro-animation at row level (§8.1) and on Summary (§8.5). No sounds by default (L5).
- **Achievements/badges `[V1.1][PROPOSED]:** §10.8.
- **No punitive mechanics, ever:** no shame screens, no loss-aversion pushes, no "friends out-lifted you!" (L4, analysis gamification table).

---

## 18. Suggested Build Order (within phases)

| Order | Scope | Phase |
|:---|:---|:---|
| 1 | Theme + navigation shell + SQLite schema (+ write-through set persistence) | `[P0]` |
| 2 | Workout engine: Active Workout → Summary → Home | `[P0]` |
| 3 | Exercise Directory/Detail/Custom (+ favourites, in-session picker) | `[P0]` |
| 4 | Routines incl. builder (+ starter templates, duplicate) | `[P0]` |
| 5 | History + Past Workout Detail + PR Vault + dashboard basics | `[P0]` |
| 6 | Auth (phone OTP + Google) + guest mode | `[P0]` |
| 7 | Nutrition with real Indian food DB (local search) | `[P0]` |
| 8 | Foreground service + lock-screen rest timer (roadmap #4) | `[P0]` |
| 9 | Body weight, dark/light theme, barcode scanner, water row | `[P1]` |
| 10 | Settings hub (units, export, battery guide, local backups) | `[P1]` |
| 11 | Cloud sync | `[V1.1]` |
| 12 | Advanced analytics + social + routine sharing + vrat mode + protein intelligence + Hindi | `[V1.1]` |
| 13 | AI + squads + trainer mode + widgets polish | `[V2]` |

*(Final sequencing authority: `PRODUCT_ROADMAP.md`.)*

---

## 19. Explicitly Rejected (do not build)

Carried from the analysis "What to AVOID" and scope boundaries — recorded so future agents don't relitigate:

- Routine limits or paywalled core utility (Strong/MFP mistakes) — L3.
- Calorie shaming, red over-target alarms, punitive streak screens — L4.
- Ads/video/upsell inside Active Workout; autoplay media with sound — L5.
- Crowd-sourced unmoderated food entries — data-quality death (MFP's Indian-DB failure).
- 20-question onboarding walls before first use — kills the 60s promise.
- CPU-polling step counting; persistent background services when idle — battery death on MIUI/ColorOS.
- Run-tracking ambitions (Strava territory) — cardio logging stays minimal (§8.1).
- Microservices/Kafka/Redis/Kubernetes — locked out per `AGENTS.md` for MVP scale.

---

## 20. Proposal Ledger

Every `[PROPOSED]` item in one table for review/approval. Approving one = add to `PRODUCT_ROADMAP.md` + strip the tag here.

| # | Proposal | Suggested phase | Where | Rationale |
|:--|:---|:---|:---|:---|
| 1 | Setup quiz (goal/units/days) | P0 | §5.2 | Seeds goals + routine + weekly target in <20s |
| 2 | Starter routine templates | P0 | §8.9 | Time-to-first-workout; showcases unlimited routines |
| 3 | Quick steppers (+/−2.5 kg) | P0 | §8.1 | Zero-typing logging; L1 |
| 4 | Copy previous set | P0 | §8.1 | L1 |
| 5 | Set undo snackbar | P0 | §8.1 | L7 friendliness |
| 6 | Warm-up set toggle | P0 | §8.1 | Analytics integrity; schema ready |
| 7 | Keep-screen-awake during session | P0 | §8.1 | Gym UX |
| 8 | Favourites in exercise library | P0 | §9.1 | Picker speed; recents+stars |
| 9 | Workout calendar heatmap | P0 | §8.6/§10.1 | Consistency visibility |
| 10 | Full workout history screen | P0 | §8.6 | Home only shows 10 |
| 11 | Past Workout Detail screen | P0 | §8.7 | Dead-end fix from RN |
| 12 | Repeat workout / save-as-routine | P0 | §8.7/§8.5 | Routine loop closure |
| 13 | Duplicate routine | P0 | §8.8.1 | Iteration workflow |
| 14 | Foreground-service session notification | P0 | §8.1/§16.1 | Roadmap #4 lock-screen timer |
| 15 | Plate calculator + plate inventory | P1 | §8.4 | Must-have from analysis (Hevy gap) |
| 16 | RPE chip per set | P1 | §8.1 | Autoregulation data; optional |
| 17 | Per-exercise rest defaults (tiered) | P1 | §8.3 | Smart rest from analysis |
| 18 | Timed sets / bodyweight ±load / cardio entry | P1 | §8.1 | Entry-mode coverage |
| 19 | Rep ranges in routine targets (3×8–10) | P1 | §8.8.4 | Realistic programming |
| 20 | Weekly schedule (routine → weekday) | P1 | §8.8.5 | Drives Home suggestion |
| 21 | Routine folders | P1 | §8.8.1 | From archived UI plan |
| 22 | Water tracker row | P1 | §11.1 | Archived UI plan |
| 23 | Copy yesterday / saved meals | P1 | §11.1 | Daily-logging speed |
| 24 | Custom foods + recipe builder | P1 | §11.5 | Homemade dishes |
| 25 | Day nutrition history | P1 | §11.7 | Retrospection |
| 26 | Body measurements (tape/body-fat) | P1 | §10.3 | Hevy/Strong gap |
| 27 | Data export + rolling local backups | P1 | §12.2 | L9; crash insurance |
| 28 | Battery-optimization setup guide | P1 | §16.3 | Budget-phone survival |
| 29 | Home-screen quick-start widget | P1 | §16.4 | One-tap check-in |
| 30 | Share-as-image workout card | P1 | §8.5 | Organic growth; no login needed |
| 31 | Demo media (looped WebP) | P1 | §9.2 | Exercise clarity |
| 32 | Compare-with-last on repeat | V1.1 | §8.7 | Progressive-overload story |
| 33 | Smart exercise substitutions | V1.1 | §9.2 | Analysis AI-lite |
| 34 | 1RM chart + volume distribution | V1.1 | §10.5/§10.6 | Already roadmap #15 |
| 35 | Weekly report card | V1.1 | §10.7 | Retention + share |
| 36 | Achievements/badges | V1.1 | §10.8 | Long-term motivation |
| 37 | Streak freezes (festival/rest-aware) | V1.1 | §17 | Culture × retention |
| 38 | Thali quick-log + cooking modifiers | V1.1 | §11.8/§11.4 | The moat feature |
| 39 | Routine sharing via QR/deep link | V1.1 | §13 | Growth loop |
| 40 | Deload suggestions | V2 | §14 | Fatigue detection |
| 41 | Lock-screen 1-tap set logger (notification action) | P0 | §8.1/§8.3/§16.1 | L1 at its extreme: commit the set without unlocking; built for sweaty/chalky hands; L8-clean (re-render only) |
| 42 | 1-tap auto warm-up pyramid generator | P0 | §8.1 | L1 for the warm-up ritual: ⚡ generates 4 flagged `is_warmup` rows (empty bar → 50% → 70% → 85%); excluded from volume/PRs |
| 43 | Interactive tactile Olympic plate visualizer | P1 | §8.4 | Real-to-scale barbell diagram from the user's gym plate inventory; tap-to-inspect; offline Canvas render (L2/L8) |
| 44 | Hevy & Strong 1-tap CSV migration engine | P1 | §12.4/§4/§16.2 | Trojan horse: 3+ years of logs/PRs migrated offline in <5s; fuzzy matching + confidence review; no data leaves the device |

---

*(Final authority: `PRODUCT_ROADMAP.md` for sequencing; `AGENTS.md` for stack laws; archived RN code for UX intent.)*

