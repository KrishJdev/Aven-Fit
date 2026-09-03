# Screen & Feature Map Reference — Aven Fit

> **Scope:** Screen navigation map, route definitions, Sharp Glassmorphism design tokens, and roadmap phases.  
> **Source of Truth:** Corresponds to `FEATURES.md` §4, §14 and `lib/core/router/app_router.dart`.

---

## 1. Declarative Route Registry (GoRouter 18)

Aven Fit uses `GoRouter 18` with a `StatefulShellRoute.indexedStack` bottom navigation bar hosting the 4 core tabs, supplemented by standalone full-screen push routes.

```
/ (ShellRoute: Main Bottom Navigation)
├── /home                        # Home Dashboard (greeting, resume banner, suggested routine, glance stats)
├── /routines                    # Routines List (catalog, create button, start routine)
├── /progress                    # Progress Dashboard (streak, PR vault preview, recent workouts)
└── /nutrition                   # Nutrition Dashboard (daily log, macro progress, calories remaining)

Standalone / Sub-Routes:
├── /workout/active              # Live Workout Screen (sets, steppers, rest bar, finish)
│   └── /workout/picker          # In-session Exercise Picker modal (search, filters, recents, favourites)
├── /workout/summary/:id         # Workout Summary Screen (stats grid, PR flash, rename, done)
│
├── /routines/new                # Routine Builder (new template)
├── /routines/:id                # Routine Detail Screen (sets breakdown, START WORKOUT)
├── /routines/:id/edit           # Routine Editor (reorder, target tuning, delete)
│
├── /exercises                   # Exercise Library Catalog (search, muscle chips, favourites)
├── /exercises/new               # Create Custom Exercise form
├── /exercises/:id               # Exercise Detail view (instructions, anatomy, delete custom)
│
├── /history                     # Full Workout History Feed (date-grouped, pagination)
│   └── /history/:id             # Past Workout Detail (repeat workout, save as routine, delete)
│
├── /progress/prs                # Full PR Vault (exercise-grouped, sort by newest/best)
│
├── /foods                       # Indian Food Search Screen (categories, veg/satvik filter)
│   └── /foods/:id               # Food Item Detail / Log Screen (quantity, household unit picker)
│
├── /profile                     # User Profile Screen (guest banner / auth card, lifetime stats)
├── /auth/login                  # Phone OTP & Google Login entry screen (prominent guest CTA)
└── /auth/otp                    # 6-cell auto-advancing OTP Verification screen
```

---

## 2. Sharp Glassmorphism Design Tokens (`AppTheme`)

The design system is engineered for OLED power efficiency, sharp tactical legibility, and high-contrast gym visibility.

### 2.1 Color Palette
- **`AppTheme.oledBlack` (`#000000`):** Pitch-black canvas base; pixels turned completely off on OLED screens.
- **`AppTheme.glassFill` (`#121216` at ~70–85% opacity):** Translucent card background.
- **`AppTheme.glassBorder` (`#26262E`):** Crisp 1px solid card borders. Sharp corners or subtle 8px–12px radii.
- **`AppTheme.neonCyan` (`#00F0FF`):** Primary brand accent; active tabs, focused inputs, timer countdowns, completed checkmarks.
- **`AppTheme.voltGreen` (`#E2F835`):** Positive delta indicators, Personal Record (PR) badges, goal-met streaks.
- **`AppTheme.burntOrange` (`#E85D04`):** Destructive actions (delete, discard), warning states, error banners.
- **`AppTheme.textPrimary` (`#FFFFFF`):** High-contrast primary headers and data labels.
- **`AppTheme.textSecondary` (`#9E9EA8`):** Subtitles, inactive tabs, unit labels (`kg`, `reps`).

### 2.2 Typography
- **UI Elements (Headers, Labels, Body):** Clean, modern grotesque typography (`Inter`).
- **Numerical Data (`AppTheme.num`):** Tabular, monospaced numerical figures (`JetBrains Mono`). MUST be applied to:
  - Weight values (`kg`)
  - Repetition counts (`reps`)
  - Rest timer countdowns (`MM:SS`)
  - Macro grams (Protein, Carbs, Fat, Fiber) and calorie totals (`kcal`)
  - Set sequence badges (`1`, `2`, `3`)
  *Rationale:* Tabular lining numerals prevent visual jitter and column misalignment during live adjustments.

---

## 3. Standard State Widgets (Law L6)

Every screen and async query must implement explicit loading, empty, and error handling via `mobile/lib/core/widgets/`:

| State | Component | Behavior & Visual Pattern |
|:---|:---|:---|
| **Loading** | `LoadingStateWidget` | Glass skeleton card (header bar + row placeholders). Static display (no animated shimmers to conserve CPU/battery on budget hardware). |
| **Empty** | `EmptyStateWidget` | Centered glass card containing Lucide icon, adherence-neutral headline, helpful guidance copy, and a primary action button (e.g. "START FIRST WORKOUT", "ADD EXERCISE"). |
| **Error** | `ErrorStateWidget` | Burnt-orange alert card showing what failed, why it failed, and a guaranteed `RETRY` button bound to `ref.invalidate(provider)`. |

---

## 4. Product Phase Legend & Roadmap Priorities

Features and work units are scheduled across distinct phases defined in `FEATURES.md`:

| Phase Tag | Definition | Scope |
|:---|:---|:---|
| **`[P0]`** | **MVP P0 — "Ship It"** | Core offline workout engine, ghost prefill, rest timer, exercise catalog, routine builder, Indian nutrition log, streak, phone OTP/guest auth, SQLite write-through. (All 5 vertical slices completed). |
| **`[P1]`** | **MVP P1 — "Solidify"** | Trojan Horse CSV Importer (Hevy/Strong), plate calculator, wrapped share cards, body weight tracker, custom meal templates. |
| **`[V1.1]`** | **V1.1 — "Delight"** | Vrat Mode (fasting calendar & Satvik filter), offline EMA TDEE recalculation, multi-device cloud sync engine, superset/dropset grouping. |
| **`[V2]`** | **V2.0 — "Dominate"** | AI Hinglish voice logger, computer-vision meal logger, gym trainer QR roster, community feed. |
| **`[PROPOSED]`** | **Pending Proposal** | Proposed features requiring explicit user approval before execution. Promoted by removing `[PROPOSED]` in `FEATURES.md`. |
