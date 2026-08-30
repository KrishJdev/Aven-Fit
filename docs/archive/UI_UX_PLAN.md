# Aven Fit: UI/UX & Design System Plan

## 1. The "Signature Style": Editorial Brutalism 

To ensure Aven Fit doesn't look like a generic fitness app clone while maintaining the clean, organized layout of the references, we will employ an **Editorial Brutalist** design language.

### Core Principles
- **Geometry:** `0px` border radii. No bubbly cards, no rounded pills, no soft shadows. Everything is sharp, blocky, and precise.
- **Backgrounds:** Pitch black (`#000000`) or ultra-dark Zinc (`#09090B`) for the absolute background to save OLED battery and increase contrast.
- **Cards & Surfaces:** Slightly lighter Zinc (`#18181B`) with sharp 1px borders (`#27272A`) to define edges without relying on drop shadows. 
- **Typography-First:** Information density driven by type hierarchy rather than containers. Large, aggressive headers (e.g., 32pt - 40pt) paired with tiny, tracked-out technical microcopy (all-caps, 10pt).
- **Tabular Alignment:** All numbers (weights, reps, times, macros) must use tabular lining (monospaced numbers) so they stack perfectly in columns.
- **Accents:** 
  - **Volt Green** (`#E2F835`) for positive changes (PRs, weight gained/lost in the right direction).
  - **Burnt Orange** (`#E85D04`) for destructive actions, warnings, or high RPE.
  - **Pure White** (`#FFFFFF`) for primary calls to action (e.g., "Start Workout", "Log Food"). High contrast against the dark theme.

---

## 2. Screen-by-Screen Layouts

### A. Home Screen (`/home`)
*Goal: Quick jump into action and immediate high-level stats.*

- **Header Row:**
  - Microcopy above: `GOOD MORNING / AFTERNOON / NIGHT`
  - Huge Title: `Home 👋`
- **Primary Action:**
  - Giant, full-width sharp button (White background, black text): `► START EMPTY WORKOUT`
- **Glance Stats (2 Columns):**
  - Left: `COMPLETED` (e.g., 3 workouts)
  - Right: `TOTAL VOLUME` (e.g., 29,900 kg)
- **Recent Completed Workouts List:**
  - Section Header: `RECENT COMPLETED WORKOUTS`
  - **History Card:** Sharp Zinc card. 
    - Top row: Workout Name (e.g. "Lower") & Date.
    - Middle: Comma-separated exercise preview (e.g., "Squat • Leg Ext • Leg Curl").
    - Bottom row: `23 sets • 18265 kg` (Left) | `111m 33s` (Right).
  - Bottom Action: Outline sharp button `SHOW ALL WORKOUTS`.

### B. Workouts Screen (`/workouts`)
*Goal: Managing routines and starting planned sessions.*

- **Header Row:**
  - Microcopy: `TRAINING`
  - Title: `My workouts`
- **Action Bar:**
  - A segmented row of sharp buttons: `+ New Plan`, `+ New Folder`, `Import`.
- **Folder / Group View:**
  - Folders act as expanding sections (e.g., `U/L-P/P/L` or `PPL`).
  - **Routine Card:** 
    - Left side: Icon/Thumbnail, Routine Name, Target Muscles (microcopy).
    - Right side: White sharp button `► Start`, 3-dot menu.
  - At the bottom of each folder: Outline sharp button `+ Add workout plan`.

### C. Nutrition Screen (`/nutrition`)
*Goal: Tracking macros, water, and logging meals with minimal friction.*

- **Header Row:**
  - Microcopy: `DAILY INTAKE`
  - Title: `Nutrition 🥗`
  - Top Right: Chart Icon, Search/Food Icon, Settings Gear.
- **Date Selector:**
  - Centered block: `< 🗓️ Today >`
- **Summary Card (The Dashboard):**
  - Massive text: `0 / 3350 kcal` (with remaining text below).
  - Macro Row: 3 equal columns for Protein, Carbs, Fat (e.g., `0 / 156g`). Flat, sharp progress bars under each.
  - Water Tracker Row: `0.0 / 2.7 L` with quick add buttons `+250 ml`, `+500 ml`.
- **Meals List:**
  - Section Header: `MEALS` | Right link: `Saved Meals`.
  - **Meal Cards (Breakfast, Lunch, Dinner, Snack):**
    - Large section label.
    - Right side: A `+` icon to quickly add to that specific meal.
    - If empty: Italicized grey text "No foods logged yet."
- **Floating Action Button (FAB):**
  - Bottom Right, sticky.
  - White block, black text: `+ LOG FOOD`. 

### D. Progress Screen (`/progress`)
*Goal: Visualizing data trends, strength gains, and body weight over time.*

- **Header Row:**
  - Microcopy: `PROGRESS DASHBOARD`
  - Title: `Progress 📈`
- **Time Range Selector:**
  - Row of sharp toggle buttons: `7D`, `30D`, `3M`, `6M`, `1Y`, `ALL`. Active state is inverted (White bg, Black text).
- **Body Weight Section:**
  - Header: `[Icon] BODY WEIGHT`
  - Big stat: `78.0 kg` next to a Volt Green badge `0.0 kg` or `+1.2 kg`.
  - Chart Card: Line graph showing the trend.
- **Strength Section:**
  - Header: `[Icon] STRENGTH`
  - Exercise Dropdown Selector (e.g., `Alternating Dumbbell Curl ▼`).
  - Big stat: `10 kg` next to change badge.
  - Chart Card: Trend line for max weight, estimated 1RM, or volume.
- **Muscle Training Volume:**
  - Filters: Muscle Dropdown (`All Muscles ▼`), Metric Dropdown (`SETS ▼`).
  - Heatmap or Bar Chart card showing weekly sets per muscle.

---

## 3. Component Library Spec

To keep the UI consistent and development fast, we will build these core primitives:

1. **`BrutalistButton`**: `radii: 0`, variant `primary` (White bg, Black text), `outline` (Transparent bg, 1px Border), `ghost` (Text only).
2. **`BrutalistCard`**: `radii: 0`, Background `#18181B`, `borderWidth: 1`, `borderColor: #27272A`. Padding 16px.
3. **`Typography`**:
   - `Hero`: 40pt, Bold.
   - `Header`: 24pt, Bold.
   - `Title`: 18pt, SemiBold.
   - `Body`: 14pt, Regular.
   - `Microcopy`: 10pt, Bold, All-Caps, Tracking/Letter-spacing 1.5px.
4. **`Badge`**: `radii: 0`, Background `#003300` (Dark Green) with Volt Green text for positive, Dark Red with Burnt Orange for negative.
5. **`MacroBar`**: 0px radius, flat colored `View` nested in a grey track `View`.

## Next Steps for Execution
1. Update navigation router to include these 4 main tabs correctly.
2. Build the `BrutalistCard` and `BrutalistButton` primitives.
3. Implement the `Home` and `Workouts` screens first as they are the core loops.
