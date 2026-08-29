# Aven Fit — Comprehensive Feature Spec

> **Purpose:** The complete product feature specification — every feature, every screen, every sub-page across the full product vision (MVP → V2), with implementation-ready detail per screen.
> **Source:** Archived React Native frontend (tag `rn-final`) + `PRODUCT_ROADMAP.md` + new proposals.
> **Rule:** Replicate behavior and UX intent, not code.

---

## Phase Legend

Every feature/screen is tagged with its roadmap phase. Build order = phase order.

| Tag | Phase | Meaning |
|:---|:---|:---|
| `[P0]` | MVP P0 — "Ship It" | Authorized for current development |
| `[P1]` | MVP P1 | Build after P0 is stable |
| `[V1.1]` | V1.1 — "Delight" | Build after MVP is released |
| `[V2]` | V2.0 — "Dominate" | Only when explicitly authorized |
| `[PROPOSED]` | — | New proposal not yet in `PRODUCT_ROADMAP.md`; needs approval before building |

Within each phase, screens inherit the phase of their feature. A screen tagged `[P0]` may contain `[P1]`-tagged sub-sections.

---

## 1. Product Overview

Aven Fit is an **offline-first gym tracker for Android**, targeting Indian fitness enthusiasts on budget phones. A user can log a workout at the gym with no account and no internet, and the app records everything, suggests weights from history, and shows progress. Visual identity: dark "Sharp Glassmorphism" — pitch-black surfaces, translucent glass cards, neon-cyan (#00F0FF) accent.

**Non-negotiable quality bar** (applies to every screen):

| Requirement | Target |
|:---|:---|
| APK size | <30MB |
| Set logging speed | <3s per set |
| Offline reliability | 100% for core workout flow — no network needed |
| First workout | <60s from install to first logged set |
| Battery | Minimal — no CPU polling |
| Target devices | Budget Android (₹8,000–₹15,000) |

---

## 2. Complete Screen Map

Every screen and sub-page in the product. Sub-pages are indented.

```
AUTH [P0]
├─ Login (phone number)                       [P0]
│  └─ OTP Verification                        [P0]
└─ (Google Sign-In — same entry screen)       [P0]

MAIN TABS [P0]
├─ Home                                       [P0]
├─ Workouts (Routines)                        [P0]
├─ Progress                                   [P0]
└─ Nutrition                                  [P0]

WORKOUT
├─ Active Workout                             [P0]
│  ├─ Exercise Picker (in-session mode)       [P0]
│  └─ Rest Timer overlay/bar                  [P0]
├─ Workout Summary                            [P0]
├─ Workout History list + calendar            [P0][PROPOSED: calendar]
│  └─ Past Workout Detail                     [P0][PROPOSED]
└─ Routine Editor
   ├─ Routine Metadata (name/description)     [P0]
   └─ Routine Exercise Editor                 [P0]

EXERCISES
├─ Exercise Directory                         [P0]
├─ Exercise Detail                            [P0]
│  └─ Exercise History (per-exercise log)     [P0][PROPOSED]
└─ Create Custom Exercise                     [P0]

PROGRESS
├─ Progress Dashboard                         [P0]
│  ├─ PR Vault                                [P0]
│  ├─ Body Weight History + log               [P1]
│  ├─ 1RM Chart per exercise                  [V1.1]
│  ├─ Muscle Volume Distribution              [V1.1]
│  └─ Workout Calendar (heatmap)              [P0][PROPOSED]
└─ [V1.1] Advanced analytics (date ranges, heatmap polish)

NUTRITION
├─ Nutrition Dashboard                        [P0]
│  └─ Meal Logging (per-meal view)            [P0]
│     ├─ Food Database Search                 [P0]
│     │  └─ Food Item Detail                  [P0]
│     ├─ Create Custom Food                   [P1][PROPOSED]
│     └─ Barcode Scanner                      [P1]
│  └─ Day Nutrition History                   [P1][PROPOSED]
├─ Vrat/Fasting Mode                          [V1.1]
└─ AI Photo Meal Recognition                  [V2]

ACCOUNT & SYNC
├─ Profile                                    [P0]
├─ Settings hub                               [P1][PROPOSED]
│  ├─ Units (kg/lb)                           [P1][PROPOSED]
│  ├─ Dark/Light theme                        [P1] (dark is default)
│  ├─ Language                                [V1.1] (Hindi) / [V2]
│  ├─ Data Export                             [P1][PROPOSED]
│  └─ Account / Sign out                      [V1.1] (sync-dependent)
└─ Sync status (background; surfaced in Settings) [V1.1]

SOCIAL [V1.1]
├─ Social Feed (tab or entry from Home)       [V1.1]
│  ├─ Create Post (share workout)             [V1.1]
│  ├─ Post Detail (kudos, comments)           [V1.1]
│  ├─ Friend Search / Follow                  [V1.1]
│  └─ Notifications                           [V1.1]
├─ Private Squads & Challenges                [V2]
└─ Trainer/Client Mode                        [V2]

AI [V2]
├─ AI Workout Generator                       [V2]
├─ Adaptive TDEE Engine (goal settings page)  [V2]
└─ Voice Logging (Hinglish)                   [V2]
```

Dead prototypes in the RN archive (`TrainScreen`, `TodayScreen`, `history/ProgressScreen`, `NutritionScreen` v1, `ProfileScreen` stub) were superseded by the final set above — do **not** re-implement them.

---

## 3. Auth `[P0]`

### 3.1 Login Screen `[P0]`
**Purpose:** Sign in / sign up via phone number (no passwords — sign-up is implicit: same flow for new and returning users) or Google.

- **Elements:** app logo/wordmark, country code selector (+91 default), phone number input, "Continue" button, Google Sign-In button, skip/continue-as-guest link.
- **Interactions:** phone validation (10-digit Indian numbers primary); Continue → OTP Verification. Google → direct sign-in. Guest → lands on Home with local-only data.
- **States:**
  - *Empty/invalid phone:* inline validation error, no navigation.
  - *Network error:* toast/alert with retry.
  - *Guest mode:* everything works offline; sign-in offered later from Profile.

### 3.2 OTP Verification `[P0]`
**Purpose:** Verify the phone number with a 6-digit OTP.

- **Elements:** 6-cell OTP input (auto-advance, auto-read SMS where possible), resend timer (30s countdown), change-number link.
- **Interactions:** auto-submit when 6 digits filled; resend; edit phone number.
- **States:** *verifying* (spinner), *invalid code* (shake + clear + error), *expired* (prompt resend), *success* → Home.

---

## 4. Main Tabs `[P0]`

Bottom tab bar: **Home · Workouts · Progress · Nutrition** — pitch-black bar, white active tint, glass border top. (Profile/Settings is reached from Home header, not a tab.)

### 4.1 Home `[P0]`
**Purpose:** Today's launchpad — start a workout in one tap, see recent activity.

- **Sections:**
  1. Greeting + date; profile/settings avatar (→ Profile).
  2. **START NEW SESSION** — prominent primary action → Active Workout.
  3. **Suggested routine** card (if routines exist) — one-tap start from today's plan `[PROPOSED: smart suggestion]`.
  4. **Glance stats:** sets this week, this week's volume, current streak, today's calories remaining (wired to real data — was placeholder in RN).
  5. **Recent Logs:** last 10 completed workouts — name, date, exercise list, sets count, total volume. Tap → Past Workout Detail `[PROPOSED]`.
- **States:** *first-run empty* (welcome state that drives straight to first workout — the 60s goal), *no recent workouts* ("Your history will appear here").

### 4.2 Workouts Tab (Routines) `[P0]`
See §5.2 Routines.

### 4.3 Progress Tab `[P0]`
See §7 Progress.

### 4.4 Nutrition Tab `[P0]`
See §8 Nutrition.

---

## 5. Workout (Core Feature) `[P0]`

The heart of the app: create a session, add exercises, log sets set-by-set. Offline-first, always.

### 5.1 Active Workout Screen `[P0]`
**Purpose:** The live logging surface. Must be fast, thumb-friendly, and never lose state.

**Entry points:** START NEW SESSION (Home) · START on a routine (Workouts tab) · Resume notification/banner.

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
- **Exercise blocks:** each added exercise renders a block: exercise name, "+ ADD SET" button, rows of `SET # | PREV | KG | REPS | ✓`.
  - **Ghost placeholders:** ADD SET pre-fills the *hint* (not the value) with the most likely numbers — previous set this session, or last performance of this exercise. Type over it, or tap ✓ to accept.
  - **Accepting a set:** ✓ auto-fills empty fields from the suggestion, locks the row (green, read-only), and starts the rest timer.
  - **Input rules:** weight = decimals only (one point); reps = whole numbers only. Invalid entries blocked and reported — never silently dropped.
  - **Row actions:** swipe/tap to delete an unlocked set; completed sets can be edited via long-press/tap `[PROPOSED: edit UX]`.
- **Exercise block actions:** reorder (drag), remove exercise, swap exercise `[PROPOSED]`, add superset marker `[V1.1]`.
- **"+ ADD EXERCISE"** → Exercise Picker (in-session mode).
- **Session timer:** continuously ticking. **Pause** freezes it and visibly marks PAUSED.
- **Persistence (critical):** closing the app mid-session and reopening restores exact exercises, sets, elapsed time; resumed time keeps counting, paused time stays frozen (`last_resumed_at` pattern from RN). Survives crashes.
- **Finish:** optional rename dialog → save → Workout Summary.
- **Discard workout:** confirm dialog ("Discard session? This can't be undone") `[PROPOSED: explicit discard UX]`.
- **States:** *empty session* ("Add your first exercise"), *restored session* banner ("Workout resumed"), *saving* spinner on Finish, *save error* with retry (data stays local).

### 5.1.1 Exercise Picker (in-session) `[P0]`
The Exercise Directory opened in workout mode (see §6.1): tapping any exercise adds it to the session and returns.

### 5.1.2 Rest Timer `[P0]`
- Completing a set auto-starts a **90-second countdown**, rendered as a slim bar under the header (never blocks the screen).
- Controls: +15s / −15s, dismiss, restart. Manually startable from header.
- **Lock-screen / notification widget:** countdown persists outside the app (roadmap #4).
- `[PROPOSED]` per-exercise default rest durations (auto-set from routine target or muscle group).

### 5.2 Workout Summary `[P0]`
Shown immediately after finishing (replaces the workout screen).

- **Streak badge:** consecutive-day streak (counts today; tolerates a "yesterday" start; min 1). PR celebration micro-animation on new records `[PROPOSED]`.
- **Stats grid:** duration · total volume (weight × reps of completed sets) · set count.
- **Workout breakdown:** one card per exercise, each completed set as `weight × reps`.
- **Inline rename:** pencil on title; saves on submit/blur; blank → "Workout".
- **Actions:** Done (→ Home) · Share `[V1.1 with social]` `[PROPOSED: image export earlier]`.
- **Error UX (preserve):** workout-not-found → clear state with a way back; never blank/crashed.

### 5.3 Workout History `[P0]` + Calendar `[PROPOSED]`
**Purpose:** Browse every past workout. (Home shows only 10 — this is the full list.)

- **Full workout list** (this page itself is `[PROPOSED]` as a dedicated screen; RN only surfaced 10 on Home): grouped by week/month, name, date, duration, volume, sets.
- **Calendar view `[PROPOSED]`:** month grid with workout-day dots + streak visualization; tap a day → that day's workouts.
- **Filter/search `[PROPOSED]`:** by name, date range, exercise performed.

### 5.3.1 Past Workout Detail `[P0]` `[PROPOSED]`
**Purpose:** Read-only view of a finished workout. (Not built in RN — Home "Recent Logs" items went nowhere.)

- Same layout as Workout Summary minus celebrations; actions: **Repeat this workout** (starts a new session pre-loaded with these exercises/sets), rename, delete (with confirm).

### 5.4 Routine Editor `[P0]`
Three sub-pages (designed in RN, builder was never wired — build for Flutter with this schema of intent):

#### 5.4.1 Routines List (Workouts tab) `[P0]`
- All routines: name + description; each has **START** (creates pre-named session) and opens for detail/editing.
- Empty state guides users to create their first plan.

#### 5.4.2 Routine Detail `[P0]`
- Full routine preview: ordered exercises, per-exercise target sets, weight/reps/RPE targets, rest durations.
- Actions: START, Edit, Duplicate `[PROPOSED]`, Delete (confirm).

#### 5.4.3 Routine Metadata `[P0]`
- Name, description, (cover color/icon `[PROPOSED]`). Saves back to list.

#### 5.4.4 Routine Exercise Editor `[P0]`
- Ordered exercise list: add (→ Directory in picker mode), remove, reorder (drag), per-exercise editor: target sets, target weight/reps, RPE, rest seconds.

---

## 6. Exercises `[P0]`

### 6.1 Exercise Directory `[P0]`
- Searchable list, grouped by muscle category; ships with starter library (roadmap: 200+ exercises with muscle-group tags; RN era had 10 common ones).
- **Equipment filter chips:** All / Barbell / Dumbbell / Machine / Cable / Bodyweight `[PROPOSED: + muscle-group filter, favourites]`.
- **Context-aware tap:** during an active workout → adds it to the session; otherwise → Exercise Detail.

### 6.2 Exercise Detail `[P0]`
- Name, muscle group(s), equipment, instructions/notes.
- **Exercise History `[PROPOSED]`:** last performances (date, best set, volume) + mini 1RM/volume trend — the data that powers ghost suggestions.
- Actions: add to current session (if one is active), edit (custom exercises), delete (custom only, confirm + re-assign logged data).

### 6.3 Create Custom Exercise `[P0]`
- Name (required, unique), muscle group, equipment type, notes. Lands on its Detail.

---

## 7. Progress & Analytics `[P0]` (basics) → `[V1.1]` (advanced)

### 7.1 Progress Dashboard (tab) `[P0]`
Three sections (real calculations for Flutter — RN showed mocks):
1. **PR Vault preview** — recent personal records → full PR Vault.
2. **Body Weight preview** — current weight + trend → Body Weight History `[P1]`.
3. **Strength preview** — top-exercise 1RM trend → 1RM Chart `[V1.1]`.
4. **Workout Calendar `[PROPOSED]`:** streak/consistency heatmap on the dashboard.

### 7.2 PR Vault `[P0]`
Personal-record trophy room. PR detection = new max weight, and est. 1RM (Epley), and volume PRs per exercise `[PROPOSED: PR type breakdown]`. Each entry: exercise, record type, value, date. Empty state explains how PRs are earned.

### 7.3 Body Weight History `[P1]`
- Current weight, trend chart (7/30/90-day ranges), log entry (quick-add today's weight), edit/delete entries, goal weight line `[PROPOSED]`.

### 7.4 1RM Chart (per exercise) `[V1.1]`
- Exercise picker → estimated-1RM trend over time from set history (Epley formula), configurable range.

### 7.5 Muscle Volume Distribution `[V1.1]`
- Volume by muscle group over a selected period — bar/pie "heatmap" view; informs weak-point training.

### 7.6 Advanced Analytics `[V1.1]`
- Custom date ranges across all analytics; muscle heatmap (roadmap #15).

---

## 8. Nutrition `[P0]` (basics) → `[P1]`/`[V1.1]`

### 8.1 Nutrition Dashboard (tab) `[P0]`
- **Calories remaining vs. goal** (primary visual), **macro targets** — protein / carbs / fat consumed vs. target.
- **Four meal sections:** Breakfast / Lunch / Dinner / Snacks — each lists logged foods (name, serving, kcal, protein) with quick-add.
- **Day navigation `[PROPOSED]`:** swipe/date-picker to view previous days (RN was today-only).
- Goal editing (calorie + macro targets) lives on first-run onboarding or settings `[PROPOSED: onboarding quiz]`.

### 8.2 Meal Logging (per-meal view) `[P0]`
- Opens from a meal section: that meal's foods for the day, serving edit, remove item, add food → Food Database Search.

### 8.3 Food Database Search `[P0]`
- Search ~5,000 curated Indian food entries (roadmap #8 — paneer, roti, dal, idli, poha, etc., with household servings like "1 katori", "2 roti").
- Results: name, standard serving, kcal, protein. Tap → Food Item Detail. Recent/frequent foods at top `[PROPOSED]`.

### 8.4 Food Item Detail `[P0]`
- Full nutrition panel (kcal, protein, carbs, fat, fiber `[PROPOSED]`), serving-size selector (household units + grams), quantity stepper, meal selection, Add.

### 8.5 Create Custom Food `[P1]` `[PROPOSED]`
- Homemade recipes: name, serving definition, per-serving macros → searchable like database items.

### 8.6 Barcode Scanner `[P1]`
- Scan packaged food → product lookup (roadmap #9) → same add-to-meal flow.

### 8.7 Vrat/Fasting Mode `[V1.1]`
- Festival-calendar aware fasting mode (roadmap #14): adjusts calorie/macro targets, offers fasting-friendly food suggestions.

### 8.8 Vegetarian Protein Intelligence `[V1.1]`
- Protein-gap insights + veg-friendly protein suggestions (roadmap #16).

---

## 9. Account, Profile & Settings

### 9.1 Profile `[P0]`
- Name, photo, body metrics (height, weight link to body-weight log `[PROPOSED]`), member-since, quick stats (total workouts, streak record).
- Entry to Settings.

### 9.2 Settings Hub `[P1]` `[PROPOSED]`
- **Units (kg/lb):** display conversion; storage stays kg `[P1][PROPOSED]`.
- **Theme:** dark (default) / light — roadmap #11 `[P1]`.
- **Language:** English → Hindi `[V1.1]`; Tamil/Telugu/Marathi `[V2]` (roadmap #19, #27).
- **Data Export `[PROPOSED]:** CSV/JSON of workouts + nutrition; automatic local backups `[PROPOSED]`.
- **Default rest timer `[PROPOSED]`, haptics/sound `[PROPOSED]`, about/licenses `[PROPOSED]`.**

### 9.3 Auth & Multi-Device Sync `[V1.1]`
- Offline-first invariant: all features work with no account/connection; local SQLite is the primary store.
- **Background sync (roadmap #12):** when signed in + online, push local changes, pull from other devices, conflict-safe (last-writer-wins per entity + operation queue pattern).
- Sync status + sign-out surfaced in Settings.

---

## 10. Social `[V1.1]`

| Screen | Phase | Detail |
|:---|:---|:---|
| Social Feed | `[V1.1]` | Followed users' workouts/kudos feed (roadmap #13); entry from Home or tab |
| Create Post | `[V1.1]` | Share a completed workout (auto-card from Workout Summary) or text |
| Post Detail | `[V1.1]` | Kudos, comments |
| People Search / Follow | `[V1.1]` | Find friends, follow/unfollow, profile view |
| Notifications | `[V1.1]` | Kudos, comments, follows, streak milestones |
| Private Squads & Challenges | `[V2]` | Cooperative challenges (roadmap #22) |
| Trainer/Client Mode | `[V2]` | Trainers assign routines, view client logs (roadmap #23) |

---

## 11. AI & Intelligence `[V2]`

| Feature | Detail |
|:---|:---|
| Adaptive TDEE Engine | Dynamic calorie/macro targets from weight trend + logging (roadmap #20); adds a goal-settings page |
| AI Workout Generator | Goal/experience/equipment → generated routine, saved into the normal routine system (roadmap #21) |
| Voice Logging (Hinglish) | Log sets/meals by voice (roadmap #24) |
| AI Photo Meal Recognition | Photograph food → identify + estimate macros (roadmap #25) |
| Wearable Integration | Google Health Connect + Indian wearables (roadmap #26) |
| Supplement Tracker | Stack logging + schedules (roadmap #28) |
| Cycle-Aware Training | Menstrual cycle-aware recommendations (roadmap #29) |
| Quick-Commerce Rewards | Reward integrations (roadmap #30) |

---

## 12. Cross-Cutting Requirements (every phase)

- **Offline-first:** core flows (workout, routines, history, basic analytics) work with zero connectivity; network is enhancement only.
- **Persistence:** every screen survives app kill; destructive actions require confirmation.
- **Error UX:** every screen has designed empty / loading / error states — never blank or crashed (WorkoutSummary standard).
- **Performance:** budget-phone targets; list virtualization; no jank on set logging.
- **Security:** no secrets in code; auth tokens handled per Spring Security backend contracts.

---

## 13. Suggested Build Order (within phases)

| Order | Scope | Phase |
|:---|:---|:---|
| 1 | Theme + navigation shell + SQLite schema | `[P0]` |
| 2 | Workout engine: Active Workout → Summary → Home | `[P0]` |
| 3 | Exercise Directory/Detail/Custom | `[P0]` |
| 4 | Routines incl. builder | `[P0]` |
| 5 | History + Past Workout Detail + PR Vault + dashboard basics | `[P0]` |
| 6 | Auth (phone OTP + Google) | `[P0]` |
| 7 | Nutrition with real Indian food DB | `[P0]` |
| 8 | Body weight, dark/light theme, barcode scanner | `[P1]` |
| 9 | Settings hub (units, export) | `[P1]` |
| 10 | Cloud sync | `[V1.1]` |
| 11 | Advanced analytics + social + vrat mode + Hindi | `[V1.1]` |
| 12 | AI + squads + trainer mode | `[V2]` |

*(Final sequencing authority: `PRODUCT_ROADMAP.md`.)*
