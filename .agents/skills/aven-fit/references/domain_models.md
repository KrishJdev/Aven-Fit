# Domain Models & Core Objects Reference — Aven Fit

> **Scope:** Core immutable domain models, value objects, mathematical formulas, and business invariants.  
> **Source of Truth:** Pure Dart implementations under `mobile/lib/features/*/domain/` and database schemas under `mobile/lib/features/*/data/`.

---

## 1. Workout & Routine Models

### 1.1 `WorkoutSession`
Represents an active, completed, or discarded workout instance.
- **Fields:**
  - `id`: Client-generated UUIDv4 string.
  - `name`: Session title (time-of-day default e.g. "Morning Workout", or routine name).
  - `status`: `WorkoutStatus` (`active`, `completed`, `discarded`).
  - `startedAt`: `DateTime` timestamp.
  - `completedAt`: Nullable `DateTime` timestamp.
  - `durationSeconds`: Nullable stored integer duration (computed via epoch math upon finish).
  - `isPaused`: Boolean indicating active pause state.
  - `lastResumedAt`: Epoch millisecond marker of last resume or tick.
  - `pausedDurationSeconds`: Cumulative seconds spent paused across all pause cycles.
  - `routineId`: Optional foreign ID of source routine.
- **Elapsed Time Invariant (`elapsedSecondsNow()`):**
  - Running: `(now - startedAt) - pausedDurationSeconds`.
  - Paused: Frozen at `(lastResumedAt - startedAt) - pausedDurationSeconds`.
  - Completed: Returns persisted `durationSeconds` (falling back to `completedAt - startedAt`).
  - Clamped $\ge 0$.

### 1.2 `SessionExercise` & `WorkoutSet`
- **`SessionExercise`:** Bridges a workout session with an exercise.
  - `orderIndex`: Position of exercise in workout (reordering must be collision-safe).
  - `restSeconds`: Exercise-specific rest timer target.
  - `totalVolumeKg`: Sum of $(weight \times reps)$ across completed sets, **strictly excluding warm-ups (Law L1)**.
- **`WorkoutSet`:** An individual set row.
  - `setNumber`: 1-indexed sequential position per exercise. When sets are deleted, surviving sets must be renumbered `1..N` to avoid UNIQUE constraint collisions.
  - `setType`: `SetType` (`normal`, `warmup`, `dropSet`, `failure`).
  - `isCompleted`: Boolean toggled by the '✓' checkmark.
  - `isPr`: Boolean flag set dynamically by PR detection engine.

### 1.3 `GhostSet` & Prefill Resolution Hierarchy
Provides ghost watermark placeholder values for sets to enable sub-3s logging (Law L1).
- **Resolution Hierarchy:**
  1. **Routine Target:** If session was started from a Routine, prefill targets from `RoutineSet` (`targetWeightKg`, `targetReps`).
  2. **Historical Set N Match:** If historical performance exists for this exercise, prefill from Set $N$ of the last completed workout.
  3. **Active Session Previous Set:** If $N > 1$ and Set $N-1$ exists in the current session, copy weight/reps from Set $N-1$.
  4. **Historical Overflow Fallback:** If $N > \text{historical set count}$, fall back to the last historical set.
  5. **Empty Fallback:** `GhostSet(hasValue: false)` when no history or targets exist.

### 1.4 Warm-Up Pyramid Generator
Generates a 4-tier progressive warmup ladder preceding the working sets (§8.1):
1. Empty Bar: $20\text{ kg} \times 10\text{ reps}$ (or bodyweight / baseline)
2. 50% Working Load: $0.50 \times W \times 5\text{ reps}$
3. 70% Working Load: $0.70 \times W \times 3\text{ reps}$
4. 85% Working Load: $0.85 \times W \times 1\text{ rep}$
- **Rule:** Warm-up sets are inserted at positions `1..K`, shifting existing working sets down. Warm-up volume is strictly excluded from total volume totals.

---

## 2. Nutrition Domain Models

### 2.1 `FoodItem` & Serving Units
- **Fields:**
  - `id`: UUIDv4 string.
  - `name`: Food name (e.g. "Roti / Chapati", "Toor Dal (Cooked)").
  - `calories`, `proteinG`, `carbsG`, `fatG`, `fiberG`: Macronutrient values per standard serving.
  - `servingSizeG`: Standard serving size in grams.
  - `householdServingUnit`: Regional unit label (`"katori"`, `"roti"`, `"scoop"`, `"piece"`, `"bowl"`).
  - `householdUnitGramsRatio`: Gram equivalent for one household unit (e.g. 150g for 1 katori dal).
  - `isVeg`: Boolean.
  - `isSatvik`: Boolean flag (§11.10) for fasting compliance (sabudana, kuttu, singhara, makhana, fruits, plain dairy). Satvik implies vegetarian.
- **Macro Math (`scaleFor(quantity, unit)`):**
  - Unit `'g'`: Linear scaling: $(grams / servingSizeG) \times macros$.
  - Unit matching `householdServingUnit`: $(quantity \times householdUnitGramsRatio / servingSizeG) \times macros$.
  - Unknown unit: Interpreted as multiple of standard servings.
  - Zero-guard: Protects against NaN values propagating into daily totals.

### 2.2 `LoggedMealItem`
- Day-bucketed food log entry containing a **denormalized macro snapshot** taken at log time.
- Preserves historical accuracy: edits to the central food catalog do NOT mutate historical daily totals.

### 2.3 `NutritionGoals`
- Singleton configuration (`caloriesTarget`, `proteinGTarget`, `carbsGTarget`, `fatGTarget`).
- **Absence Rule (Law L4):** When no goals are set, the "Calories Remaining" card is hidden entirely. Never render arbitrary or default goals without user configuration.

---

## 3. Progress, PR & Streak Models

### 3.1 `PRRecord` & Record Types
- **Types (`RecordType`):**
  - `maxWeight`: Heaviest single weight lifted.
  - `epley1rm`: Estimated 1-Rep Max via Epley formula:
    $$\text{e1RM} = \text{weight} \times \left(1 + \frac{\text{reps}}{30}\right)$$
  - `maxRepsAtWeight`: Most reps achieved at a specific weight (weight-keyed).
  - `volume`: Highest single-set volume $(\text{weight} \times \text{reps})$.
- **Invariants:**
  - Warm-up sets (`SetType.warmup`) NEVER earn PRs.
  - Unconfirmed sets (`isCompleted == false`) NEVER earn PRs.
  - Strictly-greater rule: Record only updates if candidate strictly exceeds previous best.
  - **Self-Healing Parity (Law L7):** If a set is uncompleted or deleted, `recomputePRs(exerciseId)` wipes and replays surviving working sets to restore true PR state.

### 3.2 `StreakInfo` & Weekly Streak Engine
- **Engine Rules (§17, Law L4):**
  - Monday-anchored weeks (`StreakInfo.startOfWeek`).
  - Weekly goal (default 3 days). Meeting goal extends the streak by 1 week.
  - **Mid-Week Grace:** An in-progress week below target does NOT break the streak mid-week; it is evaluated against the previous completed week.
  - **Adherence-Neutral:** A streak of 0 is omitted or displayed as a neutral fact ("0 weeks"). Never show angry streak-break warnings.

---

## 4. Auth & Identity Models

### 4.1 `AuthState` (Sealed Union)
- `AuthState.loading()`: Initial Keystore check.
- `AuthState.guest(String clientUuid)`: Default state (Law L2). Full local functionality without account or network.
- `AuthState.authenticated(String userId, String accessToken, String refreshToken, ...)`: Linked cloud account.
- `AuthState.error(String message)`: Failsafe state; falls back to guest mode for offline resiliency.

### 4.2 Guest Linking Protocol (Law L7)
When upgrading from Guest to Authenticated via OTP or Google:
- Silent write-through links existing guest records (`user_id = null`) to the new `userId` across `WorkoutSessions` and `Routines` tables.
- Guest `clientUuid` is retained in secure storage across logout to preserve local device identity.
