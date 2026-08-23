# PRODUCT_ROADMAP.md

> **Project:** Aven Fit (Gym Tracker)
> **Target Market:** Indian fitness enthusiasts (Tier 1, 2 & 3 cities)
> **Platform:** Android-first
> **Last updated:** 2026-08-24

---

## Current Phase: MVP P0

**Goal:** Ship a fast, offline-capable workout logger with basic Indian meal tracking.

**Guiding principle:** A user should be able to install the app and log their first workout within 60 seconds.

---

## MVP P0 — "Ship It" (Months 1–3)

> [!IMPORTANT]
> These are the only features authorized for current development. Do not work on V1.1 or V2 features.

| # | Feature | Category | Status |
|:---:|:---|:---|:---:|
| 1 | Workout logging with 1-tap sets | Workout | ⬜ Not started |
| 2 | Unlimited workout routines | Workout | ⬜ Not started |
| 3 | Exercise library (200+ exercises with muscle group tags) | Content | ⬜ Not started |
| 4 | Rest timer with lock screen widget | Workout | ⬜ Not started |
| 5 | Basic analytics (volume, PR tracking, 30-day charts) | Analytics | ⬜ Not started |
| 6 | Offline-first local database (SQLite) | Technical | ⬜ Not started |
| 7 | Phone OTP + Google Sign-In authentication | Auth | ⬜ Not started |
| 8 | Basic meal logging with Indian food database (~5,000 entries) | Nutrition | ⬜ Not started |

### MVP P0 — Technical Milestones

| # | Milestone | Status |
|:---:|:---|:---:|
| T1 | React Native project scaffolded (TypeScript, Android-first) | ⬜ Not started |
| T2 | Spring Boot project scaffolded (modular monolith) | ⬜ Not started |
| T3 | PostgreSQL schema designed (users, exercises, workouts, sets, routines) | ⬜ Not started |
| T4 | SQLite local schema designed (mirrors server entities + sync queue) | ⬜ Not started |
| T5 | REST API contracts defined | ⬜ Not started |
| T6 | Spring Security + auth flow implemented | ⬜ Not started |
| T7 | Offline workout logging end-to-end | ⬜ Not started |
| T8 | Basic sync layer (device → server) | ⬜ Not started |

---

## MVP P1 — After P0 Is Stable

> Do not begin P1 work until P0 features are functional and tested.

| # | Feature | Category | Status |
|:---:|:---|:---|:---:|
| 9 | Barcode scanner for packaged foods | Nutrition | ⬜ Not started |
| 10 | Body weight tracking with graph | Measurements | ⬜ Not started |
| 11 | Dark mode | UI | ⬜ Not started |

---

## V1.1 — "Delight" (Months 4–6)

> Do not begin V1.1 work until MVP (P0 + P1) is stable and released.

| # | Feature | Category | Priority |
|:---:|:---|:---|:---:|
| 12 | Cloud sync across devices (Spring Boot + PostgreSQL) | Sync | P0 |
| 13 | Social feed — share workouts, kudos, follow friends | Social | P0 |
| 14 | Vrat/Fasting mode with festival calendar | Nutrition | P0 |
| 15 | Advanced analytics — 1RM tracking, muscle heatmap, custom date ranges | Analytics | P1 |
| 16 | Vegetarian protein intelligence engine | Nutrition | P1 |
| 17 | Superset/dropset/circuit logging | Workout | P1 |
| 18 | Progress photos with comparison tool | Measurements | P1 |
| 19 | Hindi language support | Localization | P1 |

---

## V2.0 — "Dominate" (Months 7–12)

> Do not begin V2 work until explicitly authorized by the user.

| # | Feature | Category | Priority |
|:---:|:---|:---|:---:|
| 20 | Adaptive TDEE engine (dynamic calorie/macro targets) | Nutrition/AI | P0 |
| 21 | AI workout generator | AI | P0 |
| 22 | Private squads & cooperative challenges | Social | P0 |
| 23 | Trainer/client mode | Social | P0 |
| 24 | Voice logging (Hinglish) | UX | P1 |
| 25 | AI photo meal recognition | AI | P1 |
| 26 | Wearable integration (Google Health Connect, Indian wearables) | Integration | P1 |
| 27 | Tamil, Telugu, Marathi language support | Localization | P1 |
| 28 | Supplement tracker | Wellness | P2 |
| 29 | Menstrual cycle-aware training | Wellness | P2 |
| 30 | Quick-commerce reward integrations | Monetization | P2 |

---

## Scope Boundaries

### What IS in scope for MVP

- Fast workout logging (the core differentiator)
- Offline-first — workout logging must work without internet
- Basic exercise library with muscle group tags
- Basic workout routines (create, edit, reorder, use)
- Rest timer
- PR tracking and basic volume analytics
- Authentication (phone OTP + Google)
- Basic Indian meal logging with a curated food database
- Android APK that runs on budget phones (<30MB)

### What is NOT in scope for MVP

- iOS support
- Cloud synchronization (V1.1)
- Social features (V1.1)
- AI features (V2)
- Wearable integrations (V2)
- Payments/subscriptions
- Coach/trainer mode (V2)
- Voice logging (V2)
- Photo meal recognition (V2)
- Multi-language support beyond English (V1.1+)
- Advanced nutrition (adaptive TDEE, macro cycling) (V2)
- Gamification beyond basic PR celebrations

### Non-Negotiable Quality Requirements

| Requirement | Target |
|:---|:---|
| APK size | <30MB |
| Set logging speed | <3 seconds per set |
| Offline reliability | 100% — no network needed for core workout flow |
| Target devices | Budget Android phones (₹8,000–₹15,000 range) |
| First workout time | <60 seconds from install to first logged set |
| Battery impact | Minimal — no CPU polling, use hardware sensors |

---

## Status Legend

| Icon | Meaning |
|:---:|:---|
| ⬜ | Not started |
| 🔵 | In progress |
| 🟡 | Blocked / needs input |
| ✅ | Complete |
| ❌ | Cancelled / descoped |
