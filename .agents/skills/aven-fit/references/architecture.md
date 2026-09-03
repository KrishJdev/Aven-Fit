# Architecture Reference — Aven Fit

> **Scope:** Full-stack system architecture, client layer contracts, database configuration, and backend sync contracts.  
> **Source of Truth:** Corresponds to root `ARCHITECTURE.md` and ratified tech stack decisions.

---

## 1. Architectural Philosophy

Aven Fit is designed ground-up as an **Offline-First, High-Performance Mobile Client** optimized for budget Android devices (₹8,000–₹15,000 class, running MIUI, ColorOS, FuntouchOS, etc.).

- **Offline Primacy (Law L2):** Local SQLite via Drift is the primary source of truth during all live usage. Network connectivity is never a precondition for core logging, searching, or navigation workflows.
- **Sub-3s Logging (Law L1):** Every user action performs an optimistic UI update and synchronously writes through to local SQLite before triggering any background or network operations.
- **Battery & Hardware Respect (Law L8):** Zero CPU polling. All timers rely on monotonic epoch timestamps. Background sync is offloaded to OS-managed constraints via Android `WorkManager`.

---

## 2. Feature-First Clean Architecture

The client application (`mobile/lib/`) is structured strictly around **Feature-First Clean Architecture**. Features are self-contained vertical slices owning their domain, data, and presentation layers.

```
mobile/lib/
├── core/                           # Shared primitives & global infrastructure
│   ├── database/                   # Drift SQLite AppDatabase, schema & migrations
│   ├── network/                    # Dio HTTP client, AuthInterceptor & API client
│   ├── notifications/              # Local notifications service & channel priming
│   ├── router/                     # GoRouter declarative routing & shell navigation
│   ├── services/                   # Native platform channel bridges (Foreground service)
│   ├── sync/                       # WorkManager background dispatcher
│   ├── theme/                      # Sharp Glassmorphism design tokens & typography
│   └── widgets/                    # Core UI components (EmptyState, ErrorState, LoadingState)
│
└── features/                       # Self-contained vertical feature slices
    ├── workout/                    # Active workout engine, sets, rest timer
    ├── routine/                    # Routine templates, schedules & builder
    ├── exercise/                   # Exercise library (catalog, custom, search)
    ├── nutrition/                  # Indian food DB (948+ items), household units, macros
    ├── history/                    # Workout history feed, past workout detail, lifetime stats
    ├── progress/                   # PR detection vault, streak calculation, body metrics
    ├── profile/                    # Profile dashboard, guest/auth view, app settings
    ├── auth/                       # Phone OTP, secure storage, guest session
    └── sync/                       # Queue draining, DTO translation, push/pull engine
        ├── domain/                 # 1. Pure immutable entities, value objects & contracts
        ├── data/                   # 2. Drift tables, DAOs, local sources & repository impl
        └── presentation/           # 3. Freezed UI state, Riverpod controllers & Consumer widgets
```

### Boundary & Dependency Rules

1. **Feature Encapsulation:** Features must NEVER import internal data or presentation implementations from another feature (`features/workout/data/` cannot import `features/nutrition/data/`).
2. **Shared Infrastructure:** Shared logic lives exclusively in `lib/core/`. Features depend on `lib/core/`, but `lib/core/` NEVER depends on any feature.
3. **Inward Layer Dependency:** Dependencies flow strictly inwards:
   $$\text{Presentation} \longrightarrow \text{Domain} \longleftarrow \text{Data}$$
   - **Domain:** Pure Dart. Zero imports from `package:flutter/material.dart`, `package:drift/drift.dart`, or `package:dio/dio.dart`.
   - **Data:** Implements Domain repository contracts; interacts with Drift SQLite and Dio.
   - **Presentation:** Interacts with Domain models and consumes Repository interfaces through Riverpod Notifiers.

---

## 3. Layer Contracts & Implementation Details

### 3.1 Domain Layer (`features/<feature>/domain/`)
- **Entities & Value Objects:** Pure immutable models generated with Freezed 4 (`@freezed`) and `json_serializable`.
- **Domain Logic:** Deterministic formulas (e.g., Epley 1RM: $\text{weight} \times (1 + \text{reps}/30)$, Atwater macro scaling, warmup ladder calculations, streak calculation).
- **Repository Contracts:** Abstract interfaces specifying asynchronous operations and reactive streams (`Stream<T>`).

### 3.2 Data Layer (`features/<feature>/data/`)
- **Drift Tables:** Schema definitions using client-generated UUIDv4 primary keys (`TextColumn get id => text()()`).
- **DAOs (`@DriftAccessor`):** Isolate-safe, compile-time SQL queries exposing reactive streams (`watch*()`) and batch transactional mutations.
- **Repository Implementations:** Maps Drift rows to Domain entities and vice versa. Enforces write-through to SQLite and triggers self-healing mechanics (e.g., PR recompute on set deletion).

### 3.3 Presentation Layer (`features/<feature>/presentation/`)
- **UI State (`@freezed`):** Pure immutable state record containing all visual state (loading flags, entities, active filters, epoch deadlines).
- **Controllers (`AsyncNotifier` / `Notifier`):** Unidirectional state containers. Listens to repository streams, performs optimistic state mutations, dispatches write-through repository calls, and updates state. Explicitly NO legacy `ChangeNotifier` or two-way bindings.
- **Declarative Views (`ConsumerWidget`):** Stateless or lifecycle-aware widgets styled with Sharp Glassmorphism design tokens (`AppTheme`).

---

## 4. Unidirectional Data Flow (The 5-Step Cycle)

```
[ User Interaction: Tap '✓' Set Complete ]
                     │
                     ▼
 1. UI Event Dispatch (ConsumerWidget calls ref.read(controller.notifier).toggleSet(...))
                     │
                     ▼
 2. Controller Optimistic Update (Controller updates Freezed UI State immediately)
                     │
                     ▼
 3. Repository Write-Through (Repository calls DAO.updateSetRecord(...) in SQLite)
                     │
                     ▼
 4. SQLite Transaction Commit (Drift executes query; emits reactive stream on isolate)
                     │
                     ▼
 5. Declarative UI Re-render (ConsumerWidget rebuilds with updated state in <16ms)
```

---

## 5. Local Database Engine (Drift SQLite)

- **Engine:** `drift: ^2.34.3`, `drift_flutter: ^0.3.1`, `sqlite3_flutter_libs: ^0.6.0+eol`.
- **Database Class:** `AppDatabase` located at `lib/core/database/app_database.dart`.
- **Isolate Sharing:** Configured with `driftDatabase(name: 'avenfit_db', shareAcrossIsolates: true)`.
- **Referential Integrity:** Enabled in `beforeOpen`:
  ```dart
  beforeOpen: (details) async {
    await customStatement('PRAGMA foreign_keys = ON;');
  }
  ```
- **Linear Migration Strategy:**
  - Migrations are sequential and guarded with `if (from < N)`.
  - Schema history:
    - v1: `WorkoutSessions`, `WorkoutSets`
    - v2: `MuscleGroups`, `Exercises`, `ExerciseMuscleGroups`
    - v3: `Routines`, `RoutineExercises`, `RoutineSets`
    - v4: `SessionExercises` table + FK columns in `WorkoutSets`
    - v5: `PersonalRecords` table
    - v6: Pause columns (`isPaused`, `lastResumedAt`, `pausedDurationSeconds`)
    - v7: `StreakSettings` table
    - v8: `FoodItems`, `LoggedMealItems`, `NutritionGoals` tables

---

## 6. Backend Architecture & Sync Contract

### 6.1 Backend Stack
- **Framework:** Spring Boot 3.3.x + Java 21.
- **Database:** PostgreSQL 16 managed via Flyway migrations (`V1` through `V10`).
- **Security:** Spring Security with JWT tokens, Phone OTP, and Google token validation.

### 6.2 Mobile $\leftrightarrow$ Backend Sync Contract
- **Sync Endpoints:**
  - `POST /api/sync/push`: Submits client mutation batch (`SyncPushRequest`).
  - `GET /api/sync/pull?since={timestamp}`: Fetches server changes (`SyncPullResponse`).
- **Mapping Specifications (`SyncDtoMapper`):**
  - Enums map between SQLite lowercase/camelCase and Backend UPPERCASE:
    - `WorkoutStatus`: `active` $\leftrightarrow$ `IN_PROGRESS`, `completed` $\leftrightarrow$ `COMPLETED`, `discarded` $\leftrightarrow$ `CANCELLED`.
    - `SetType`: `normal` $\leftrightarrow$ `NORMAL`, `warmup` $\leftrightarrow$ `WARMUP`, `dropSet` $\leftrightarrow$ `DROP`, `failure` $\leftrightarrow$ `FAILURE`.
  - Key aliases:
    - `orderIndex` $\leftrightarrow$ `position`
    - `setNumber` $\leftrightarrow$ `position`
    - `sessionId` $\leftrightarrow$ `workoutId`
    - `sessionExerciseId` $\leftrightarrow$ `workoutExerciseId`
- **Conflict Resolution:** Last-Writer-Wins (LWW) utilizing monotonic timestamps, atomic SQLite ingestion within transactions.
