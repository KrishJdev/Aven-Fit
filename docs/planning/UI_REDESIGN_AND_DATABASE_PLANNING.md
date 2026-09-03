# UI Redesign & Database Overhaul Planning

> **Date:** 2026-09-04  
> **Target Branch:** `dev`  
> **Status:** Scheduled for Planning Session  
> **Originating Context:** Manual live inspection of P0 MVP on Android Emulator (`medium_phone` / API 36).

---

## 1. Executive Summary & User Feedback

During manual on-device testing of the P0 MVP on the local Android emulator, the live user experience was evaluated with the following primary takeaways:

1. **UI/UX Aesthetics & Ergonomics:**  
   The initial UI implementation is rudimentary and substandard in real usage ("The UI is terrible"). The visual hierarchy, typography, glassmorphism execution, touch targets, and overall polish do not meet production standards for a top-tier gym and nutrition application.
2. **Database & Data Content:**  
   The database content and data state ("databases are not updated for the workouts and other things") require a major overhaul. The exercise catalog needs expansion and deeper metadata, routine presets and workout split templates are absent or minimal, and data pipelines between SQLite tables and UI views require tighter synchronization and verified consistency.
3. **Directive:**  
   Freeze new feature development and conduct a **comprehensive UI/UX design and database planning session tomorrow** to thoroughly architect the redesign before code implementation.

---

## 2. Identified Gaps & Deficiencies

### A. User Interface & Design Gaps
- **Visual Balance & Spacing:** Excessive empty black space on tall displays (1080×2400); lack of cohesive section dividers, elevation depth, and subtle container borders.
- **Glassmorphism Treatment:** Current containers feel flat rather than layered with refined glassmorphism (lacking calibrated border glows, backdrop filters, and subtle ambient gradients).
- **Typography & Scale:** Headings, tabular numerals, and helper text require unified scale rules, tighter letter-spacing, and better visual weight balance between labels and values.
- **Active Workout Screen:** In-session tracking UI feels sparse; needs high-ergonomics set logging cards, prominent rest timer feedback, clear exercise reordering handles, and intuitive warm-up/working set distinctions.
- **Exercise & Food Pickers:** Simple list view cards lack micro-interactions, rich visual cues (equipment icons, muscle region highlights), and instant tactile feedback.
- **Navigation & Shell:** Bottom navigation bar and app bar transitions need smoother active indicators, standardized icon treatments, and refined pill styling.

### B. Database & Content Gaps
- **Exercise Library:** Currently limited to 55 initial exercises. Needs expansion to comprehensive gym movements (compound lifts, cables, machines, bodyweight, dumbbell variations) with verified muscle activations (primary/secondary), equipment tags, and instructions.
- **Pre-Built Routine Templates:** Need curated, standard workout templates (e.g., Push-Pull-Legs, Upper/Lower, 4-day Split, Full Body) ready to inspect and clone on a fresh install.
- **Indian Food Catalog:** Bundled 948-item catalog requires auditing for macro accuracy, standard regional variations, and intuitive household portion measurements (katori, roti, glass, scoop).
- **Data Reactive Sync & Prefills:** Ensure instant write-through across all screens with zero stale state, seamless ghost prefill transitions, and robust recovery across app lifecycle events.

---

## 3. Agenda for Tomorrow's Full Planning Session

### Session Phase 1: Design System & Wireframe Blueprint
1. **Design Tokens Refinement:**
   - Palette specification: OLED Black (`#000000`), Dark Surface (`#0A0A0A` / `#121212`), Border/Stroke levels, Neon Cyan (`#00F5D4`), Volt Green (`#76FF03`), Burnt Orange (`#FF5722`), and Muted Grays.
   - Component guidelines: Card corner radiuses, stroke widths (1px razor borders), backdrop blur strengths, and touch target minimums (48dp+).
   - Typography audit: Inter display hierarchy + JetBrains Mono tabular numeral alignment.
2. **Screen-by-Screen UX Mapping:**
   - **Home Dashboard:** Hero streak banner, weekly adherence glance, quick-start CTA, recent workout cards, daily macro glance.
   - **Active Workout Screen:** Sticky header with epoch timer & rest countdown, collapsible exercise blocks, fast set logging row (Set #, Type, Previous Ghost, kg, Reps, Checkmark), plate calculator access, exercise reordering.
   - **Workout / Routine Tab:** Routine folders/splits, template inspector, drag-and-drop routine builder.
   - **Exercise Directory:** Categorized muscle group explorer, multi-tag filter carousel, exercise performance history graphs, custom exercise creator.
   - **Nutrition Dashboard & Food Search:** Meal cards (Breakfast/Lunch/Dinner/Snacks), circular or bar macro summary (Protein/Carb/Fat/Calories), instant search with veg/satvik chips, household unit serving picker.
   - **Progress & PR Vault:** PR trophies/records by lift, weekly volume charts, streak calendar.

### Session Phase 2: Database Schema & Seed Data Overhaul
1. **Exercise Database Expansion:**
   - Curate comprehensive exercise catalog (150+ standard gym movements).
   - Verify primary and secondary muscle group mappings and equipment metadata.
2. **Routine Templates Seeding:**
   - Design initial template routines (PPL, Upper-Lower, Arnold Split, Full Body 3-day).
   - Bundle templates in JSON seed asset with seamless SQLite first-run ingestion.
3. **Data Integrity & Controller Audit:**
   - Audit Riverpod controllers and Drift DAOs to eliminate any race conditions, ensure instant SQLite write-through (<100ms), and enforce database constraints cleanly.

---

## 4. Current Technical Baseline (Session 48)

The following foundational milestones and environment fixes are verified and ready for tomorrow's work:

- **Local Development Environment:**
  - Linux toolchains configured: Eclipse Temurin OpenJDK 21, Android SDK (34, 35, 36), Flutter 3.47.2 (Dart 3.13.2).
  - Android Virtual Device `medium_phone` (API 36) operational with hardware-accelerated rendering.
- **Android Build & Packaging:**
  - Java 8/17 core library desugaring enabled in `mobile/android/app/build.gradle.kts`.
  - Android library subproject compilation pinned to API 36 (`sentry_flutter`, `package_info_plus`).
  - Debug APK compiles in <10 seconds and installs cleanly via ADB.
- **Database & Code State:**
  - Exercise picker controller updated with initial seed guarantee (`await exerciseRepo.seedInitialData()`).
  - **387 / 387 unit and widget tests passing green** across the full Flutter test suite.
  - Spring Boot backend clean and passing (`./gradlew test`).
