# Aven Fit — Features & Workflows

> **Purpose:** Business-level feature spec, extracted from the archived React Native frontend (tag `rn-final`). This is the source of truth for *what the app does and how users flow through it* — implementation details are intentionally excluded.
> **Rule:** Replicate behavior and UX intent, not code.
> **Extracted:** 2026-08-30

**Status legend:** ✅ Fully built in the archived app (re-implement first) · ◐ UI/design exists, logic not wired · 🔜 Planned, not built

---

## 1. Product Overview

Aven Fit is an **offline-first gym tracker** for Android. A user can log a workout at the gym with no account and no internet, and the app still records everything, suggests weights from history, and shows progress. Visual identity: dark, translucent "glass" surfaces with a neon-cyan accent — premium and focused.

---

## 2. Workout Logging (Core Feature) ✅

The heart of the app: create a session, add exercises, log sets set-by-set.

### Workflow: Start → Log → Finish

1. **Start** — User taps **START NEW SESSION** (Home tab) or **START** on a saved routine (Workouts tab).
2. **Auto-naming** — The workout is named by time of day (randomized within a band), e.g.:
   | Time | Name options |
   |:---|:---|
   | 00:00–05:00 | Late Night Lift · Midnight Session |
   | 05:00–09:00 | Early Bird Workout · Dawn Patrol |
   | 09:00–12:00 | Morning Grind · Morning Workout |
   | 12:00–17:00 | Afternoon Pump · Midday Session |
   | 17:00–21:00 | Evening Workout · Sundown Session |
   | 21:00–24:00 | Night Session · Late Lift |

   Starting from a routine names the workout after the routine instead. The user can always rename later.
3. **Add exercises** — "+ ADD EXERCISE" opens the Exercise Directory; picking one adds it as a block in the session and automatically preparses one empty set row.
4. **Log sets** — For each exercise, rows show: SET # | PREV (previous performance) | KG | REPS | ✓.
   - **Ghost placeholders:** tapping ADD SET pre-fills the *hint* text (not the value) with the most likely numbers — the previous set in this session, or for a first set, the last time this exercise was performed. The user can type over it, or simply tap ✓ to accept the suggestion.
   - **Accepting a set:** ✓ auto-fills any empty field from the suggestion, then locks the row (green, read-only).
   - **Input rules:** weight accepts decimals only (one decimal point); reps accepts whole numbers only. Invalid entries are blocked and reported, never silently dropped.
5. **Rest timer** — Completing a set automatically starts a **90-second rest countdown** shown as a slim bar under the header (never blocks the screen). User can add/remove 15s or dismiss it; it can also be started manually from the header.
6. **Session timer** — Header shows elapsed time, continuously ticking.
   - **Pause** freezes the timer and visibly marks the session as PAUSED.
   - **Pause/resume survives app restarts:** closing the app mid-session and reopening restores the exact exercises, sets, and elapsed time — resumed time keeps counting; paused time stays frozen.
7. **Finish** — "FINISH WORKOUT" offers an optional rename, then saves the session and lands on the Workout Summary.

### Workflow: Resume an interrupted session

Reopening an unfinished workout restores full state from local storage: exercise order, logged sets, timer (elapsed + paused/unpaused). The user never loses a session to a crash or app switch.

---

## 3. Workout Summary ✅

Shown immediately after finishing (replaces the workout screen).

- **Streak badge** — consecutive-day training streak (counts today's workout; tolerates a "yesterday" start; minimum 1).
- **Stats grid:** session duration · total volume (weight × reps of completed sets) · set count.
- **Workout breakdown:** one card per exercise listing each completed set as `weight × reps`.
- **Inline rename** — pencil icon on the title; saves on submit/blur; blank names fall back to "Workout".
- **Robust error UX** — if the workout can't be found, a clear "Workout not found" state with a way back (never a blank/crashed screen). Preserve this quality bar.

---

## 4. Dashboard / Recent History ✅

- Prominent start button and greeting.
- **Recent Logs:** the last 10 completed workouts — name, date, exercise list, sets count, and total volume.
- Glance stats (sets this week, calories) — placeholder in the archived app; wire to real data in Flutter.

---

## 5. Exercise Directory ✅

- Searchable list of exercises with **equipment filter chips** (All / Barbell / Dumbbell / Machine / Cable / Bodyweight).
- Ships with a starter set of 10 common exercises (bench press, squat, deadlift, pull-up, OHP, etc.) grouped by muscle category; users can add custom exercises.
- **Context-aware tap:** during an active workout, tapping an exercise adds it to the session; outside a workout, it opens the exercise's detail view.

---

## 6. Routines (Workouts Tab) ◐

- "All Routines" list with name + description; each routine can be **START**ed (creates a pre-named session) or opened for detail/editing.
- The routine **builder** (name/description metadata, ordered exercise list, per-exercise target sets with weight/reps/RPE and rest durations) was designed but never wired — build for Flutter using this schema of intent.
- Empty state guides users to create their first plan.

---

## 7. Progress & Analytics ◐

- Dashboard with three sections: **PR Vault** (personal-record trophy room), **Body Weight** (current weight + trend), **Strength 1RM** (pick an exercise, see estimated 1RM trend over time).
- Sub-pages: body-weight log, 1RM chart per exercise, PR list, muscle-group volume distribution.
- All displayed with mock data in the archived app — the screens define the UX target; the calculations (1RM from set history, PR detection, volume by muscle group) must be built for Flutter.

---

## 8. Nutrition ◐

- Daily dashboard: calories remaining vs. goal, plus macro targets (protein / carbs / fat — consumed vs. target).
- Four meal sections (Breakfast / Lunch / Dinner / Snacks), each listing logged foods (name, serving, kcal, protein) with quick add.
- Food flow: meal → food database search → item detail → add to meal.
- Entirely mock data in the archived app — no storage existed. Build data layer for Flutter.

---

## 9. Account & Multi-Device Sync 🔜

- **Sign-in:** phone number + OTP (no passwords). Sign-up is implicit — same flow for new and returning users.
- **Offline-first:** all features above work with no account and no connection. Local data is the primary store.
- **Background sync:** when the app has an account and connectivity, it pushes local changes and pulls changes from other devices (conflict-safe). Backend was not built in the RN era; the app must behave identically offline.

---

## 10. Suggested Re-Implementation Priority

| Phase | Scope |
|:---|:---|
| 1 | Workout logging engine, summary, dashboard, exercise directory (all ✅ features) |
| 2 | Routines incl. builder |
| 3 | Progress analytics with real calculations |
| 4 | Nutrition with real data |
| 5 | Auth + background sync |

*(Final sequencing per `PRODUCT_ROADMAP.md`.)*

---

## 11. User-Facing Surfaces (Inventory)

| Area | Screens |
|:---|:---|
| Auth | Login (phone), OTP verification |
| Tabs | Home · Workouts (routines) · Progress · Nutrition |
| Workout | Active workout · Workout summary · Routine detail · Routine metadata · Routine exercise editor |
| Exercises | Directory · Detail · Create custom |
| Progress | Dashboard · Body weight log · 1RM chart · PR vault · Muscle volume distribution |
| Nutrition | Dashboard · Meal logging · Food search · Food item detail |
| Other | Profile |
