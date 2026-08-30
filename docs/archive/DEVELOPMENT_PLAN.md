# DEVELOPMENT_PLAN.md — Aven Fit MVP

> **Project:** Aven Fit (Gym Tracker)
> **Phase:** MVP P0
> **Agents:** Antigravity (Frontend/Architecture) · OpenCode/Ox Alpha (Backend/Implementation)
> **Last updated:** 2026-08-24

---

## Table of Contents

1. [Overview & Conventions](#1-overview--conventions)
2. [Project Structure](#2-project-structure)
3. [Step 0 — Project Scaffolding](#step-0--project-scaffolding)
4. [Step 1 — Database Schema & Entities](#step-1--database-schema--entities)
5. [Step 2 — Authentication](#step-2--authentication)
6. [Step 3 — Exercise Library](#step-3--exercise-library)
7. [Step 4 — Workout Logging](#step-4--workout-logging-the-core)
8. [Step 5 — Routines](#step-5--routines)
9. [Step 6 — Rest Timer](#step-6--rest-timer)
10. [Step 7 — Analytics & PR Tracking](#step-7--analytics--pr-tracking)
11. [Step 8 — Indian Meal Logging](#step-8--indian-meal-logging)
12. [Step 9 — Offline Sync Layer](#step-9--offline-sync-layer)
13. [Step 10 — Polish & Release Prep](#step-10--polish--release-prep)
14. [Appendix A — Full PostgreSQL Schema](#appendix-a--full-postgresql-schema)
15. [Appendix B — Full SQLite Schema](#appendix-b--full-sqlite-schema)
16. [Appendix C — API Endpoint Summary](#appendix-c--api-endpoint-summary)

---

## 1. Overview & Conventions

### Development Order

Steps MUST be executed in order. Each step depends on the previous.

```
Step 0: Scaffolding        ← Both projects exist, build, run
Step 1: Database           ← All tables, entities, migrations
Step 2: Authentication     ← Users can sign in
Step 3: Exercise Library   ← Exercises exist to reference
Step 4: Workout Logging    ← THE CORE FEATURE
Step 5: Routines           ← Workout templates
Step 6: Rest Timer         ← Workout enhancement
Step 7: Analytics & PRs    ← Requires workout data
Step 8: Meal Logging       ← Separate domain, needs food DB
Step 9: Sync Layer         ← Connects local ↔ server
Step 10: Polish            ← Release readiness
```

### Agent Ownership

Each task is tagged with an owner:

| Tag | Agent | Meaning |
|:---|:---|:---|
| `[BACKEND]` | OpenCode / Ox Alpha | Spring Boot, PostgreSQL, API endpoints |
| `[FRONTEND]` | Antigravity | React Native, TypeScript, UI/UX |
| `[BOTH]` | Coordinated | Both agents contribute |
| `[SCHEMA]` | OpenCode (primary) | Database design and migrations |

### Naming Conventions

| Context | Convention | Example |
|:---|:---|:---|
| PostgreSQL tables | `snake_case`, plural | `workout_sets`, `muscle_groups` |
| PostgreSQL columns | `snake_case` | `created_at`, `user_id` |
| Java packages | `com.avenfit.{module}` | `com.avenfit.workout` |
| Java entities | `PascalCase`, singular | `WorkoutSet`, `Exercise` |
| Java fields | `camelCase` | `createdAt`, `userId` |
| REST endpoints | `/api/{resource}` | `/api/workouts`, `/api/exercises` |
| TypeScript types | `PascalCase` | `WorkoutSet`, `Exercise` |
| TypeScript variables | `camelCase` | `workoutSets`, `currentExercise` |
| React components | `PascalCase` | `SetLogRow`, `ExerciseCard` |
| Screen components | `PascalCase` + `Screen` | `ActiveWorkoutScreen` |
| SQLite tables | `snake_case`, plural | Same as PostgreSQL |

### ID Strategy

- All entities use **UUID v4** as primary key
- Mobile app generates UUIDs locally (enables offline creation)
- Column name: `id` (primary key), `{entity}_id` (foreign key)
- Java type: `UUID`
- PostgreSQL type: `uuid`
- SQLite type: `TEXT` (store as string)

### Timestamp Convention

Every table includes:

| Column | Type | Purpose |
|:---|:---|:---|
| `created_at` | `TIMESTAMP WITH TIME ZONE` | Record creation time |
| `updated_at` | `TIMESTAMP WITH TIME ZONE` | Last modification time |

- Backend: Auto-managed via JPA `@PrePersist` / `@PreUpdate` in a `BaseEntity`
- Mobile: Set explicitly on insert/update
- All timestamps in **UTC**

### HTTP Response Convention

All API responses follow this envelope:

```json
// Success
{
  "data": { ... },
  "message": "OK"
}

// Success (list)
{
  "data": [ ... ],
  "page": 0,
  "size": 20,
  "totalElements": 142,
  "totalPages": 8
}

// Error
{
  "error": "VALIDATION_ERROR",
  "message": "Weight must be positive",
  "details": { "field": "weightKg", "rejected": -5 }
}
```

HTTP status codes:
- `200` — Success
- `201` — Created
- `400` — Validation error
- `401` — Not authenticated
- `403` — Not authorized
- `404` — Not found
- `409` — Conflict (sync)
- `500` — Server error

---

## 2. Project Structure

### Repository Layout

```
aven-fit/
├── AGENTS.md
├── DEVELOPMENT_LOG.md
├── DEVELOPMENT_PLAN.md          ← this file
├── PRODUCT_ROADMAP.md
├── gym_tracker_analysis.md
├── README.md
│
├── backend/                     ← Spring Boot application
│   ├── build.gradle
│   ├── settings.gradle
│   ├── gradle/
│   ├── gradlew
│   ├── gradlew.bat
│   └── src/
│       ├── main/
│       │   ├── java/com/avenfit/
│       │   │   ├── AvenFitApplication.java
│       │   │   ├── common/
│       │   │   │   ├── entity/BaseEntity.java
│       │   │   │   ├── dto/ApiResponse.java
│       │   │   │   ├── dto/PagedResponse.java
│       │   │   │   ├── exception/GlobalExceptionHandler.java
│       │   │   │   ├── exception/ResourceNotFoundException.java
│       │   │   │   └── config/CorsConfig.java
│       │   │   ├── auth/
│       │   │   │   ├── config/SecurityConfig.java
│       │   │   │   ├── config/JwtProperties.java
│       │   │   │   ├── controller/AuthController.java
│       │   │   │   ├── dto/LoginRequest.java
│       │   │   │   ├── dto/AuthResponse.java
│       │   │   │   ├── dto/OtpRequest.java
│       │   │   │   ├── dto/GoogleAuthRequest.java
│       │   │   │   ├── entity/User.java
│       │   │   │   ├── entity/RefreshToken.java
│       │   │   │   ├── repository/UserRepository.java
│       │   │   │   ├── repository/RefreshTokenRepository.java
│       │   │   │   ├── service/AuthService.java
│       │   │   │   ├── service/JwtService.java
│       │   │   │   ├── service/OtpService.java
│       │   │   │   └── filter/JwtAuthenticationFilter.java
│       │   │   ├── user/
│       │   │   │   ├── controller/UserController.java
│       │   │   │   ├── dto/UserProfileDto.java
│       │   │   │   ├── dto/UpdateProfileRequest.java
│       │   │   │   └── service/UserService.java
│       │   │   ├── exercise/
│       │   │   │   ├── controller/ExerciseController.java
│       │   │   │   ├── dto/ExerciseDto.java
│       │   │   │   ├── dto/CreateExerciseRequest.java
│       │   │   │   ├── entity/Exercise.java
│       │   │   │   ├── entity/MuscleGroup.java
│       │   │   │   ├── entity/ExerciseMuscleGroup.java
│       │   │   │   ├── repository/ExerciseRepository.java
│       │   │   │   ├── repository/MuscleGroupRepository.java
│       │   │   │   └── service/ExerciseService.java
│       │   │   ├── workout/
│       │   │   │   ├── controller/WorkoutController.java
│       │   │   │   ├── dto/WorkoutDto.java
│       │   │   │   ├── dto/WorkoutSummaryDto.java
│       │   │   │   ├── dto/CreateWorkoutRequest.java
│       │   │   │   ├── dto/LogSetRequest.java
│       │   │   │   ├── dto/WorkoutExerciseDto.java
│       │   │   │   ├── entity/Workout.java
│       │   │   │   ├── entity/WorkoutExercise.java
│       │   │   │   ├── entity/WorkoutSet.java
│       │   │   │   ├── entity/WorkoutStatus.java
│       │   │   │   ├── entity/SetType.java
│       │   │   │   ├── repository/WorkoutRepository.java
│       │   │   │   ├── repository/WorkoutExerciseRepository.java
│       │   │   │   ├── repository/WorkoutSetRepository.java
│       │   │   │   └── service/WorkoutService.java
│       │   │   ├── routine/
│       │   │   │   ├── controller/RoutineController.java
│       │   │   │   ├── dto/RoutineDto.java
│       │   │   │   ├── dto/CreateRoutineRequest.java
│       │   │   │   ├── entity/Routine.java
│       │   │   │   ├── entity/RoutineExercise.java
│       │   │   │   ├── entity/RoutineSet.java
│       │   │   │   ├── repository/RoutineRepository.java
│       │   │   │   └── service/RoutineService.java
│       │   │   ├── nutrition/
│       │   │   │   ├── controller/NutritionController.java
│       │   │   │   ├── controller/FoodItemController.java
│       │   │   │   ├── dto/NutritionEntryDto.java
│       │   │   │   ├── dto/FoodItemDto.java
│       │   │   │   ├── dto/LogMealRequest.java
│       │   │   │   ├── entity/NutritionEntry.java
│       │   │   │   ├── entity/NutritionEntryItem.java
│       │   │   │   ├── entity/FoodItem.java
│       │   │   │   ├── entity/MealType.java
│       │   │   │   ├── repository/NutritionEntryRepository.java
│       │   │   │   ├── repository/FoodItemRepository.java
│       │   │   │   └── service/NutritionService.java
│       │   │   ├── analytics/
│       │   │   │   ├── controller/AnalyticsController.java
│       │   │   │   ├── dto/WorkoutSummaryAnalytics.java
│       │   │   │   ├── dto/ExerciseHistory.java
│       │   │   │   ├── dto/PersonalRecordDto.java
│       │   │   │   ├── entity/PersonalRecord.java
│       │   │   │   ├── repository/PersonalRecordRepository.java
│       │   │   │   └── service/AnalyticsService.java
│       │   │   └── sync/
│       │   │       ├── controller/SyncController.java
│       │   │       ├── dto/SyncPushRequest.java
│       │   │       ├── dto/SyncPullResponse.java
│       │   │       └── service/SyncService.java
│       │   └── resources/
│       │       ├── application.yml
│       │       ├── application-dev.yml
│       │       ├── application-prod.yml
│       │       └── db/migration/
│       │           ├── V1__create_users_table.sql
│       │           ├── V2__create_exercises_tables.sql
│       │           ├── V3__create_workout_tables.sql
│       │           ├── V4__create_routine_tables.sql
│       │           ├── V5__create_nutrition_tables.sql
│       │           ├── V6__create_analytics_tables.sql
│       │           ├── V7__seed_muscle_groups.sql
│       │           └── V8__seed_exercises.sql
│       └── test/
│           └── java/com/avenfit/
│               ├── auth/
│               ├── exercise/
│               ├── workout/
│               ├── routine/
│               ├── nutrition/
│               └── analytics/
│
└── mobile/                      ← React Native application
    ├── package.json
    ├── tsconfig.json
    ├── app.json
    ├── babel.config.js
    ├── metro.config.js
    ├── index.js
    ├── android/
    ├── src/
    │   ├── App.tsx
    │   ├── navigation/
    │   │   ├── AppNavigator.tsx
    │   │   ├── AuthNavigator.tsx
    │   │   └── MainTabNavigator.tsx
    │   ├── screens/
    │   │   ├── auth/
    │   │   │   ├── LoginScreen.tsx
    │   │   │   └── OtpVerificationScreen.tsx
    │   │   ├── workout/
    │   │   │   ├── WorkoutHomeScreen.tsx
    │   │   │   ├── ActiveWorkoutScreen.tsx
    │   │   │   └── WorkoutDetailScreen.tsx
    │   │   ├── history/
    │   │   │   └── WorkoutHistoryScreen.tsx
    │   │   ├── exercises/
    │   │   │   ├── ExerciseListScreen.tsx
    │   │   │   ├── ExerciseDetailScreen.tsx
    │   │   │   └── CreateExerciseScreen.tsx
    │   │   ├── routines/
    │   │   │   ├── RoutineListScreen.tsx
    │   │   │   ├── RoutineDetailScreen.tsx
    │   │   │   └── CreateRoutineScreen.tsx
    │   │   ├── nutrition/
    │   │   │   ├── NutritionDashboardScreen.tsx
    │   │   │   ├── MealLogScreen.tsx
    │   │   │   └── FoodSearchScreen.tsx
    │   │   └── profile/
    │   │       ├── ProfileScreen.tsx
    │   │       └── SettingsScreen.tsx
    │   ├── components/
    │   │   ├── common/
    │   │   │   ├── Button.tsx
    │   │   │   ├── Card.tsx
    │   │   │   ├── Header.tsx
    │   │   │   ├── EmptyState.tsx
    │   │   │   ├── LoadingSpinner.tsx
    │   │   │   └── TextInput.tsx
    │   │   ├── workout/
    │   │   │   ├── SetLogRow.tsx
    │   │   │   ├── ExerciseCard.tsx
    │   │   │   ├── RestTimerOverlay.tsx
    │   │   │   ├── RestTimerNotification.tsx
    │   │   │   └── WorkoutSummaryCard.tsx
    │   │   ├── exercise/
    │   │   │   ├── ExerciseListItem.tsx
    │   │   │   ├── MuscleGroupFilter.tsx
    │   │   │   └── ExerciseSearchBar.tsx
    │   │   └── nutrition/
    │   │       ├── MealCard.tsx
    │   │       ├── FoodItemRow.tsx
    │   │       └── MacroSummary.tsx
    │   ├── database/
    │   │   ├── database.ts
    │   │   ├── schema.ts
    │   │   ├── migrations.ts
    │   │   └── repositories/
    │   │       ├── exerciseRepository.ts
    │   │       ├── workoutRepository.ts
    │   │       ├── routineRepository.ts
    │   │       ├── nutritionRepository.ts
    │   │       └── syncRepository.ts
    │   ├── services/
    │   │   ├── api/
    │   │   │   ├── apiClient.ts
    │   │   │   ├── authApi.ts
    │   │   │   ├── exerciseApi.ts
    │   │   │   ├── workoutApi.ts
    │   │   │   ├── routineApi.ts
    │   │   │   └── nutritionApi.ts
    │   │   ├── auth/
    │   │   │   └── authService.ts
    │   │   └── sync/
    │   │       ├── syncEngine.ts
    │   │       └── conflictResolver.ts
    │   ├── hooks/
    │   │   ├── useActiveWorkout.ts
    │   │   ├── useExercises.ts
    │   │   ├── useRoutines.ts
    │   │   ├── useRestTimer.ts
    │   │   ├── useNutrition.ts
    │   │   └── useAuth.ts
    │   ├── store/
    │   │   ├── AuthContext.tsx
    │   │   ├── WorkoutContext.tsx
    │   │   └── AppContext.tsx
    │   ├── types/
    │   │   ├── exercise.ts
    │   │   ├── workout.ts
    │   │   ├── routine.ts
    │   │   ├── nutrition.ts
    │   │   ├── user.ts
    │   │   ├── analytics.ts
    │   │   └── api.ts
    │   ├── utils/
    │   │   ├── uuid.ts
    │   │   ├── formatting.ts
    │   │   ├── dateUtils.ts
    │   │   ├── workoutCalculations.ts
    │   │   └── constants.ts
    │   └── assets/
    │       ├── fonts/
    │       └── images/
    └── __tests__/
```

---

## Step 0 — Project Scaffolding

> **Goal:** Both projects exist, build successfully, and run.

---

### Task 0.1 — Scaffold Spring Boot Project `[BACKEND]`

**What to do:**

Generate a Spring Boot project with the following configuration:

| Setting | Value |
|:---|:---|
| Group | `com.avenfit` |
| Artifact | `aven-fit-backend` |
| Name | `AvenFit` |
| Java version | 21 |
| Spring Boot version | 3.3.x (latest stable 3.3) |
| Build tool | Gradle (Kotlin DSL) |
| Packaging | JAR |

**Dependencies to include in `build.gradle.kts`:**

```
// Core
spring-boot-starter-web
spring-boot-starter-data-jpa
spring-boot-starter-security
spring-boot-starter-validation

// Database
postgresql (runtime)
flyway-core
flyway-database-postgresql

// Auth
jjwt-api (io.jsonwebtoken, 0.12.x)
jjwt-impl (runtime)
jjwt-jackson (runtime)

// Dev
spring-boot-starter-test
spring-boot-devtools (developmentOnly)
lombok (compileOnly + annotationProcessor)
h2 (test runtime — for integration tests)
spring-security-test
```

**Files to create:**

1. `backend/build.gradle.kts` — Build file with dependencies above
2. `backend/settings.gradle.kts` — `rootProject.name = "aven-fit-backend"`
3. `backend/src/main/java/com/avenfit/AvenFitApplication.java` — Main class
4. `backend/src/main/resources/application.yml` — Base config
5. `backend/src/main/resources/application-dev.yml` — Dev profile config

**`application.yml` contents:**

```yaml
spring:
  application:
    name: aven-fit

  profiles:
    active: dev

  jpa:
    open-in-view: false
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        format_sql: true
        jdbc:
          time_zone: UTC

  flyway:
    enabled: true
    locations: classpath:db/migration

server:
  port: 8080
  servlet:
    context-path: /

logging:
  level:
    com.avenfit: DEBUG
    org.springframework.security: DEBUG
```

**`application-dev.yml` contents:**

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/avenfit_dev
    username: avenfit
    password: avenfit_dev_password
    driver-class-name: org.postgresql.Driver

  jpa:
    show-sql: true

jwt:
  secret: dev-secret-key-change-in-production-must-be-at-least-256-bits-long-for-hs256
  access-token-expiration-ms: 900000       # 15 minutes
  refresh-token-expiration-ms: 2592000000  # 30 days
```

**`BaseEntity.java` (create immediately):**

```java
package com.avenfit.common.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.Instant;
import java.util.UUID;

@MappedSuperclass
@Getter
@Setter
public abstract class BaseEntity {

    @Id
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @PrePersist
    protected void onCreate() {
        if (this.id == null) {
            this.id = UUID.randomUUID();
        }
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = Instant.now();
    }
}
```

**Acceptance criteria:**

- [ ] `cd backend && ./gradlew build` completes without errors
- [ ] `./gradlew bootRun` starts (will fail on DB connection — that's expected)
- [ ] All dependencies resolve
- [ ] `BaseEntity` compiles

---

### Task 0.2 — Create PostgreSQL Dev Database `[BACKEND]`

**What to do:**

Create the development database. Document the commands so any developer can run them.

```sql
CREATE USER avenfit WITH PASSWORD 'avenfit_dev_password';
CREATE DATABASE avenfit_dev OWNER avenfit;
GRANT ALL PRIVILEGES ON DATABASE avenfit_dev TO avenfit;
```

Create `backend/scripts/setup-dev-db.sql` with the above.

Also create `backend/scripts/README.md` explaining:
1. Install PostgreSQL 16+
2. Run the setup script
3. Verify connection

**Acceptance criteria:**

- [ ] Database `avenfit_dev` exists and is accessible
- [ ] `./gradlew bootRun` starts without database connection errors
- [ ] Flyway runs (no migrations yet — that's OK)

---

### Task 0.3 — Scaffold React Native Project `[FRONTEND]`

**What to do:**

Initialize a React Native project with TypeScript using React Native CLI (not Expo).

```bash
npx @react-native-community/cli init AvenFit --template react-native-template-typescript --directory mobile
```

**Post-init configuration:**

1. Verify `mobile/tsconfig.json` has strict mode enabled
2. Configure path aliases in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    },
    "strict": true
  }
}
```

3. Create the `src/` directory structure as shown in the Project Structure section
4. Move `App.tsx` into `src/App.tsx` and update `index.js` to point to it
5. Install essential dependencies:

```bash
# Navigation
npm install @react-navigation/native @react-navigation/bottom-tabs @react-navigation/native-stack
npm install react-native-screens react-native-safe-area-context

# SQLite (evaluate — candidate library)
npm install react-native-quick-sqlite
# OR
npm install op-sqlite

# UUID generation
npm install uuid
npm install --save-dev @types/uuid

# Async storage (for auth tokens)
npm install @react-native-async-storage/async-storage
```

**Acceptance criteria:**

- [ ] `cd mobile && npm run android` builds and launches on emulator/device
- [ ] TypeScript compiles without errors
- [ ] Navigation library is installed and importable
- [ ] SQLite library is installed (candidate — can be swapped)
- [ ] `src/` directory structure exists with placeholder files

---

### Task 0.4 — Verify End-to-End Setup `[BOTH]`

**What to do:**

Verify that both projects run independently:

| Check | How |
|:---|:---|
| Backend builds | `cd backend && ./gradlew build` |
| Backend runs | `cd backend && ./gradlew bootRun` (connects to PostgreSQL) |
| Mobile builds | `cd mobile && npm run android` |
| Mobile runs | App opens on Android emulator or device |

Create a simple health-check endpoint to test connectivity:

**Backend:** `GET /api/health` → `{ "status": "UP", "timestamp": "..." }`

**Mobile:** A temporary test screen that calls the health endpoint and displays the result.

**Acceptance criteria:**

- [ ] Backend health endpoint returns 200
- [ ] Mobile app can reach backend health endpoint from emulator (use `10.0.2.2:8080` for Android emulator)
- [ ] Both projects are committed and clean

---

## Step 1 — Database Schema & Entities

> **Goal:** All database tables exist. All JPA entities compile. Flyway migrations run cleanly.

---

### Task 1.1 — PostgreSQL Migrations `[SCHEMA]`

Create Flyway migration files in `backend/src/main/resources/db/migration/`.

Execute in this order — each file depends on the previous.

---

#### Migration V1 — Users

**File:** `V1__create_users_table.sql`

```sql
CREATE TABLE users (
    id              UUID PRIMARY KEY,
    phone_number    VARCHAR(20) UNIQUE,
    email           VARCHAR(255) UNIQUE,
    display_name    VARCHAR(100) NOT NULL,
    google_id       VARCHAR(255) UNIQUE,
    avatar_url      VARCHAR(500),
    height_cm       DECIMAL(5,1),
    weight_kg       DECIMAL(5,1),
    date_of_birth   DATE,
    gender          VARCHAR(20),
    unit_preference VARCHAR(10) NOT NULL DEFAULT 'METRIC',
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_unit_preference CHECK (unit_preference IN ('METRIC', 'IMPERIAL')),
    CONSTRAINT chk_gender CHECK (gender IN ('MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY') OR gender IS NULL),
    CONSTRAINT chk_auth_method CHECK (phone_number IS NOT NULL OR google_id IS NOT NULL)
);

CREATE TABLE refresh_tokens (
    id              UUID PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token           VARCHAR(500) NOT NULL UNIQUE,
    expires_at      TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_refresh_token_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_google_id ON users(google_id);
CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token);
```

---

#### Migration V2 — Exercises & Muscle Groups

**File:** `V2__create_exercises_tables.sql`

```sql
CREATE TABLE muscle_groups (
    id              UUID PRIMARY KEY,
    name            VARCHAR(50) NOT NULL UNIQUE,
    display_order   INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE exercises (
    id              UUID PRIMARY KEY,
    name            VARCHAR(200) NOT NULL,
    description     TEXT,
    category        VARCHAR(30) NOT NULL,
    equipment       VARCHAR(30) NOT NULL,
    is_custom       BOOLEAN NOT NULL DEFAULT FALSE,
    created_by      UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_category CHECK (category IN (
        'BARBELL', 'DUMBBELL', 'MACHINE', 'CABLE',
        'BODYWEIGHT', 'CARDIO', 'STRETCHING', 'OTHER'
    )),
    CONSTRAINT chk_equipment CHECK (equipment IN (
        'BARBELL', 'DUMBBELL', 'MACHINE', 'CABLE', 'KETTLEBELL',
        'BAND', 'BODYWEIGHT', 'SMITH_MACHINE', 'OTHER', 'NONE'
    ))
);

CREATE TABLE exercise_muscle_groups (
    id              UUID PRIMARY KEY,
    exercise_id     UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    muscle_group_id UUID NOT NULL REFERENCES muscle_groups(id) ON DELETE CASCADE,
    role            VARCHAR(10) NOT NULL DEFAULT 'PRIMARY',
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_role CHECK (role IN ('PRIMARY', 'SECONDARY')),
    CONSTRAINT uq_exercise_muscle UNIQUE (exercise_id, muscle_group_id)
);

CREATE INDEX idx_exercises_category ON exercises(category);
CREATE INDEX idx_exercises_equipment ON exercises(equipment);
CREATE INDEX idx_exercises_custom ON exercises(is_custom);
CREATE INDEX idx_exercises_created_by ON exercises(created_by);
CREATE INDEX idx_exercise_muscles_exercise ON exercise_muscle_groups(exercise_id);
CREATE INDEX idx_exercise_muscles_muscle ON exercise_muscle_groups(muscle_group_id);
```

---

#### Migration V3 — Workouts

**File:** `V3__create_workout_tables.sql`

```sql
CREATE TABLE workouts (
    id              UUID PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    routine_id      UUID,  -- FK added after routines table exists (V4)
    name            VARCHAR(200) NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'IN_PROGRESS',
    started_at      TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_at    TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER,
    notes           TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_workout_status CHECK (status IN ('IN_PROGRESS', 'COMPLETED', 'CANCELLED'))
);

CREATE TABLE workout_exercises (
    id              UUID PRIMARY KEY,
    workout_id      UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
    exercise_id     UUID NOT NULL REFERENCES exercises(id),
    position        INTEGER NOT NULL,
    rest_seconds    INTEGER DEFAULT 90,
    notes           TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_workout_exercise_position UNIQUE (workout_id, position)
);

CREATE TABLE workout_sets (
    id                  UUID PRIMARY KEY,
    workout_exercise_id UUID NOT NULL REFERENCES workout_exercises(id) ON DELETE CASCADE,
    position            INTEGER NOT NULL,
    set_type            VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    weight_kg           DECIMAL(7,2),
    reps                INTEGER,
    rpe                 DECIMAL(3,1),
    is_completed        BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at        TIMESTAMP WITH TIME ZONE,
    is_pr               BOOLEAN NOT NULL DEFAULT FALSE,
    notes               TEXT,
    created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_set_type CHECK (set_type IN ('NORMAL', 'WARMUP', 'DROP', 'FAILURE')),
    CONSTRAINT chk_weight_positive CHECK (weight_kg IS NULL OR weight_kg >= 0),
    CONSTRAINT chk_reps_positive CHECK (reps IS NULL OR reps >= 0),
    CONSTRAINT chk_rpe_range CHECK (rpe IS NULL OR (rpe >= 1 AND rpe <= 10))
);

CREATE INDEX idx_workouts_user ON workouts(user_id);
CREATE INDEX idx_workouts_status ON workouts(status);
CREATE INDEX idx_workouts_started ON workouts(started_at);
CREATE INDEX idx_workout_exercises_workout ON workout_exercises(workout_id);
CREATE INDEX idx_workout_exercises_exercise ON workout_exercises(exercise_id);
CREATE INDEX idx_workout_sets_workout_exercise ON workout_sets(workout_exercise_id);
CREATE INDEX idx_workout_sets_completed ON workout_sets(is_completed);
```

---

#### Migration V4 — Routines

**File:** `V4__create_routine_tables.sql`

```sql
CREATE TABLE routines (
    id              UUID PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    description     TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE routine_exercises (
    id              UUID PRIMARY KEY,
    routine_id      UUID NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
    exercise_id     UUID NOT NULL REFERENCES exercises(id),
    position        INTEGER NOT NULL,
    rest_seconds    INTEGER DEFAULT 90,
    notes           TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_routine_exercise_position UNIQUE (routine_id, position)
);

CREATE TABLE routine_sets (
    id                   UUID PRIMARY KEY,
    routine_exercise_id  UUID NOT NULL REFERENCES routine_exercises(id) ON DELETE CASCADE,
    position             INTEGER NOT NULL,
    set_type             VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    target_reps          INTEGER,
    target_weight_kg     DECIMAL(7,2),
    target_rpe           DECIMAL(3,1),
    created_at           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_routine_set_type CHECK (set_type IN ('NORMAL', 'WARMUP', 'DROP', 'FAILURE'))
);

-- Now add the FK from workouts.routine_id → routines.id
ALTER TABLE workouts
    ADD CONSTRAINT fk_workout_routine
    FOREIGN KEY (routine_id) REFERENCES routines(id) ON DELETE SET NULL;

CREATE INDEX idx_routines_user ON routines(user_id);
CREATE INDEX idx_routine_exercises_routine ON routine_exercises(routine_id);
CREATE INDEX idx_routine_sets_routine_exercise ON routine_sets(routine_exercise_id);
```

---

#### Migration V5 — Nutrition

**File:** `V5__create_nutrition_tables.sql`

```sql
CREATE TABLE food_items (
    id              UUID PRIMARY KEY,
    name            VARCHAR(300) NOT NULL,
    brand           VARCHAR(200),
    serving_size    DECIMAL(8,2) NOT NULL,
    serving_unit    VARCHAR(30) NOT NULL,
    calories        DECIMAL(8,2) NOT NULL,
    protein_g       DECIMAL(7,2) NOT NULL DEFAULT 0,
    carbs_g         DECIMAL(7,2) NOT NULL DEFAULT 0,
    fat_g           DECIMAL(7,2) NOT NULL DEFAULT 0,
    fiber_g         DECIMAL(7,2),
    is_vegetarian   BOOLEAN NOT NULL DEFAULT FALSE,
    food_category   VARCHAR(50),
    is_verified     BOOLEAN NOT NULL DEFAULT FALSE,
    barcode         VARCHAR(50),
    is_custom       BOOLEAN NOT NULL DEFAULT FALSE,
    created_by      UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_calories_positive CHECK (calories >= 0),
    CONSTRAINT chk_protein_positive CHECK (protein_g >= 0),
    CONSTRAINT chk_carbs_positive CHECK (carbs_g >= 0),
    CONSTRAINT chk_fat_positive CHECK (fat_g >= 0)
);

CREATE TABLE nutrition_entries (
    id              UUID PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    meal_type       VARCHAR(20) NOT NULL,
    logged_at       TIMESTAMP WITH TIME ZONE NOT NULL,
    notes           TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_meal_type CHECK (meal_type IN (
        'BREAKFAST', 'LUNCH', 'DINNER', 'SNACK', 'PRE_WORKOUT', 'POST_WORKOUT'
    ))
);

CREATE TABLE nutrition_entry_items (
    id                  UUID PRIMARY KEY,
    nutrition_entry_id  UUID NOT NULL REFERENCES nutrition_entries(id) ON DELETE CASCADE,
    food_item_id        UUID NOT NULL REFERENCES food_items(id),
    quantity            DECIMAL(8,2) NOT NULL,
    serving_unit        VARCHAR(30) NOT NULL,
    calories            DECIMAL(8,2) NOT NULL,
    protein_g           DECIMAL(7,2) NOT NULL,
    carbs_g             DECIMAL(7,2) NOT NULL,
    fat_g               DECIMAL(7,2) NOT NULL,
    created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_quantity_positive CHECK (quantity > 0)
);

CREATE INDEX idx_food_items_name ON food_items USING gin (to_tsvector('english', name));
CREATE INDEX idx_food_items_barcode ON food_items(barcode);
CREATE INDEX idx_food_items_category ON food_items(food_category);
CREATE INDEX idx_food_items_vegetarian ON food_items(is_vegetarian);
CREATE INDEX idx_nutrition_entries_user ON nutrition_entries(user_id);
CREATE INDEX idx_nutrition_entries_date ON nutrition_entries(logged_at);
CREATE INDEX idx_nutrition_entry_items_entry ON nutrition_entry_items(nutrition_entry_id);
```

---

#### Migration V6 — Analytics

**File:** `V6__create_analytics_tables.sql`

```sql
CREATE TABLE personal_records (
    id              UUID PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    exercise_id     UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    record_type     VARCHAR(20) NOT NULL,
    value           DECIMAL(10,2) NOT NULL,
    workout_set_id  UUID REFERENCES workout_sets(id) ON DELETE SET NULL,
    achieved_at     TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_record_type CHECK (record_type IN ('MAX_WEIGHT', 'MAX_REPS', 'MAX_VOLUME', 'EST_1RM'))
);

CREATE TABLE body_measurements (
    id              UUID PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    weight_kg       DECIMAL(5,1),
    body_fat_pct    DECIMAL(4,1),
    measured_at     TIMESTAMP WITH TIME ZONE NOT NULL,
    notes           TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_personal_records_user ON personal_records(user_id);
CREATE INDEX idx_personal_records_exercise ON personal_records(exercise_id);
CREATE INDEX idx_personal_records_type ON personal_records(record_type);
CREATE INDEX idx_body_measurements_user ON body_measurements(user_id);
CREATE INDEX idx_body_measurements_date ON body_measurements(measured_at);
```

---

#### Migration V7 — Seed Muscle Groups

**File:** `V7__seed_muscle_groups.sql`

```sql
INSERT INTO muscle_groups (id, name, display_order) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'Chest', 1),
    ('550e8400-e29b-41d4-a716-446655440002', 'Back', 2),
    ('550e8400-e29b-41d4-a716-446655440003', 'Shoulders', 3),
    ('550e8400-e29b-41d4-a716-446655440004', 'Biceps', 4),
    ('550e8400-e29b-41d4-a716-446655440005', 'Triceps', 5),
    ('550e8400-e29b-41d4-a716-446655440006', 'Forearms', 6),
    ('550e8400-e29b-41d4-a716-446655440007', 'Quadriceps', 7),
    ('550e8400-e29b-41d4-a716-446655440008', 'Hamstrings', 8),
    ('550e8400-e29b-41d4-a716-446655440009', 'Glutes', 9),
    ('550e8400-e29b-41d4-a716-446655440010', 'Calves', 10),
    ('550e8400-e29b-41d4-a716-446655440011', 'Abs', 11),
    ('550e8400-e29b-41d4-a716-446655440012', 'Traps', 12),
    ('550e8400-e29b-41d4-a716-446655440013', 'Lats', 13),
    ('550e8400-e29b-41d4-a716-446655440014', 'Lower Back', 14);
```

---

#### Migration V8 — Seed Exercises (first batch)

**File:** `V8__seed_exercises.sql`

This migration should insert at minimum **50 common exercises** across all muscle groups. Prioritize compound movements first.

**Required exercises (minimum — add more to reach 200+ total across later seeds):**

**Chest:**
- Barbell Bench Press (Barbell, PRIMARY: Chest, SECONDARY: Triceps, Shoulders)
- Incline Barbell Bench Press
- Dumbbell Bench Press
- Incline Dumbbell Bench Press
- Dumbbell Fly
- Cable Crossover
- Push-Up (Bodyweight)
- Chest Dip

**Back:**
- Barbell Row (Bent-Over)
- Deadlift
- Pull-Up (Bodyweight)
- Lat Pulldown (Cable)
- Seated Cable Row
- Dumbbell Row (One-Arm)
- T-Bar Row
- Face Pull

**Shoulders:**
- Overhead Press (Barbell)
- Dumbbell Shoulder Press
- Lateral Raise (Dumbbell)
- Front Raise (Dumbbell)
- Reverse Fly (Dumbbell)
- Arnold Press

**Biceps:**
- Barbell Curl
- Dumbbell Curl
- Hammer Curl
- Preacher Curl
- Concentration Curl
- Cable Curl

**Triceps:**
- Tricep Pushdown (Cable)
- Overhead Tricep Extension (Dumbbell)
- Skull Crusher (Barbell)
- Close-Grip Bench Press
- Tricep Dip

**Legs:**
- Barbell Squat (Back)
- Front Squat
- Leg Press (Machine)
- Romanian Deadlift
- Leg Curl (Machine)
- Leg Extension (Machine)
- Bulgarian Split Squat
- Calf Raise (Machine)
- Walking Lunge

**Abs:**
- Crunch
- Hanging Leg Raise
- Cable Crunch
- Plank (Bodyweight)
- Russian Twist

Each exercise must include:
- UUID (generate fixed UUIDs for seed data)
- Name
- Category
- Equipment
- `is_custom = FALSE`
- Corresponding rows in `exercise_muscle_groups` with PRIMARY and SECONDARY roles

**Acceptance criteria:**

- [ ] `./gradlew bootRun` starts and all 8 migrations run successfully
- [ ] `SELECT COUNT(*) FROM muscle_groups` returns 14
- [ ] `SELECT COUNT(*) FROM exercises` returns ≥ 50
- [ ] All foreign keys are valid

---

### Task 1.2 — JPA Entities `[BACKEND]`

Create JPA entities for every table. Each entity must:

1. Extend `BaseEntity` (gets `id`, `createdAt`, `updatedAt`)
2. Use `@Table(name = "...")` matching the PostgreSQL table name
3. Define all columns with proper `@Column` annotations
4. Define relationships with `@ManyToOne`, `@OneToMany`, etc.
5. Use `@Enumerated(EnumType.STRING)` for enum columns
6. Use Lombok `@Getter`, `@Setter`, `@NoArgsConstructor`

**Entities to create (13 total):**

| Entity | Package | Table |
|:---|:---|:---|
| `User` | `com.avenfit.auth.entity` | `users` |
| `RefreshToken` | `com.avenfit.auth.entity` | `refresh_tokens` |
| `MuscleGroup` | `com.avenfit.exercise.entity` | `muscle_groups` |
| `Exercise` | `com.avenfit.exercise.entity` | `exercises` |
| `ExerciseMuscleGroup` | `com.avenfit.exercise.entity` | `exercise_muscle_groups` |
| `Workout` | `com.avenfit.workout.entity` | `workouts` |
| `WorkoutExercise` | `com.avenfit.workout.entity` | `workout_exercises` |
| `WorkoutSet` | `com.avenfit.workout.entity` | `workout_sets` |
| `Routine` | `com.avenfit.routine.entity` | `routines` |
| `RoutineExercise` | `com.avenfit.routine.entity` | `routine_exercises` |
| `RoutineSet` | `com.avenfit.routine.entity` | `routine_sets` |
| `FoodItem` | `com.avenfit.nutrition.entity` | `food_items` |
| `NutritionEntry` | `com.avenfit.nutrition.entity` | `nutrition_entries` |
| `NutritionEntryItem` | `com.avenfit.nutrition.entity` | `nutrition_entry_items` |
| `PersonalRecord` | `com.avenfit.analytics.entity` | `personal_records` |
| `BodyMeasurement` | `com.avenfit.analytics.entity` | `body_measurements` |

**Enums to create:**

| Enum | Package | Values |
|:---|:---|:---|
| `WorkoutStatus` | `com.avenfit.workout.entity` | `IN_PROGRESS`, `COMPLETED`, `CANCELLED` |
| `SetType` | `com.avenfit.workout.entity` | `NORMAL`, `WARMUP`, `DROP`, `FAILURE` |
| `ExerciseCategory` | `com.avenfit.exercise.entity` | `BARBELL`, `DUMBBELL`, `MACHINE`, `CABLE`, `BODYWEIGHT`, `CARDIO`, `STRETCHING`, `OTHER` |
| `Equipment` | `com.avenfit.exercise.entity` | `BARBELL`, `DUMBBELL`, `MACHINE`, `CABLE`, `KETTLEBELL`, `BAND`, `BODYWEIGHT`, `SMITH_MACHINE`, `OTHER`, `NONE` |
| `MuscleRole` | `com.avenfit.exercise.entity` | `PRIMARY`, `SECONDARY` |
| `MealType` | `com.avenfit.nutrition.entity` | `BREAKFAST`, `LUNCH`, `DINNER`, `SNACK`, `PRE_WORKOUT`, `POST_WORKOUT` |
| `UnitPreference` | `com.avenfit.auth.entity` | `METRIC`, `IMPERIAL` |
| `Gender` | `com.avenfit.auth.entity` | `MALE`, `FEMALE`, `OTHER`, `PREFER_NOT_TO_SAY` |
| `RecordType` | `com.avenfit.analytics.entity` | `MAX_WEIGHT`, `MAX_REPS`, `MAX_VOLUME`, `EST_1RM` |

**Acceptance criteria:**

- [ ] All entities compile
- [ ] `./gradlew bootRun` validates all entities against the database schema (JPA `ddl-auto: validate`)
- [ ] No validation errors

---

### Task 1.3 — Spring Data Repositories `[BACKEND]`

Create JPA repositories for each entity.

Every repository extends `JpaRepository<EntityType, UUID>`.

Add custom query methods where useful:

```java
// UserRepository
Optional<User> findByPhoneNumber(String phoneNumber);
Optional<User> findByGoogleId(String googleId);
Optional<User> findByEmail(String email);

// ExerciseRepository
List<Exercise> findByIsCustomFalse();
List<Exercise> findByCreatedBy(User user);
List<Exercise> findByNameContainingIgnoreCase(String query);
List<Exercise> findByCategory(ExerciseCategory category);

// WorkoutRepository
List<Workout> findByUserIdOrderByStartedAtDesc(UUID userId);
List<Workout> findByUserIdAndStatus(UUID userId, WorkoutStatus status);
Optional<Workout> findByUserIdAndStatus(UUID userId, WorkoutStatus status);
List<Workout> findByUserIdAndStartedAtBetween(UUID userId, Instant start, Instant end);

// RoutineRepository
List<Routine> findByUserIdOrderByUpdatedAtDesc(UUID userId);

// FoodItemRepository
List<FoodItem> findByNameContainingIgnoreCase(String query);
Optional<FoodItem> findByBarcode(String barcode);
List<FoodItem> findByFoodCategory(String category);
List<FoodItem> findByIsVegetarian(boolean isVegetarian);

// NutritionEntryRepository
List<NutritionEntry> findByUserIdAndLoggedAtBetween(UUID userId, Instant start, Instant end);

// PersonalRecordRepository
List<PersonalRecord> findByUserIdAndExerciseIdOrderByAchievedAtDesc(UUID userId, UUID exerciseId);
List<PersonalRecord> findByUserIdOrderByAchievedAtDesc(UUID userId);
Optional<PersonalRecord> findTopByUserIdAndExerciseIdAndRecordTypeOrderByValueDesc(
    UUID userId, UUID exerciseId, RecordType recordType);

// BodyMeasurementRepository
List<BodyMeasurement> findByUserIdOrderByMeasuredAtDesc(UUID userId);
```

**Acceptance criteria:**

- [ ] All repositories compile
- [ ] Application starts without JPA errors

---

### Task 1.4 — Mobile SQLite Schema `[FRONTEND]`

Create the SQLite schema in `mobile/src/database/schema.ts`.

The mobile schema mirrors the server schema but adds sync tracking columns.

**Additional columns on every syncable table:**

```sql
sync_status TEXT NOT NULL DEFAULT 'PENDING'  -- 'PENDING', 'SYNCED', 'CONFLICT'
last_synced_at TEXT                           -- ISO 8601 timestamp, null if never synced
server_id TEXT                                -- UUID from server (may differ from local id initially)
is_deleted INTEGER NOT NULL DEFAULT 0         -- Soft delete for sync
```

**Additional table for sync queue:**

```sql
CREATE TABLE sync_queue (
    id TEXT PRIMARY KEY,
    entity_type TEXT NOT NULL,      -- 'workout', 'workout_set', 'routine', etc.
    entity_id TEXT NOT NULL,        -- UUID of the entity
    operation TEXT NOT NULL,        -- 'CREATE', 'UPDATE', 'DELETE'
    payload TEXT NOT NULL,          -- JSON of the entity data
    created_at TEXT NOT NULL,       -- ISO 8601
    retry_count INTEGER NOT NULL DEFAULT 0,
    last_error TEXT,
    status TEXT NOT NULL DEFAULT 'PENDING'  -- 'PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED'
);
```

**Acceptance criteria:**

- [ ] SQLite database initializes on app start without errors
- [ ] All tables are created
- [ ] `sync_queue` table exists
- [ ] Schema version is tracked (for future migrations)

---

## Step 2 — Authentication

> **Goal:** Users can create an account and sign in. API endpoints are protected.

---

### Task 2.1 — JWT Infrastructure `[BACKEND]`

**Files to create:**

1. `JwtService.java` — Token generation and validation
2. `JwtAuthenticationFilter.java` — Servlet filter that extracts JWT from `Authorization: Bearer <token>` header
3. `JwtProperties.java` — `@ConfigurationProperties` for JWT config
4. `SecurityConfig.java` — Spring Security configuration

**JwtService must provide:**

```java
String generateAccessToken(User user);
String generateRefreshToken(User user);
UUID extractUserId(String token);
boolean isTokenValid(String token);
```

**SecurityConfig must:**

- Disable CSRF (REST API)
- Set session management to STATELESS
- Permit unauthenticated access to: `/api/auth/**`, `/api/health`
- Require authentication for all other `/api/**` endpoints
- Register `JwtAuthenticationFilter` before `UsernamePasswordAuthenticationFilter`
- Configure CORS to allow requests from mobile app

**Acceptance criteria:**

- [ ] Unauthenticated requests to `/api/exercises` return 401
- [ ] Requests with valid JWT to `/api/exercises` return 200
- [ ] Expired tokens return 401
- [ ] `/api/health` is accessible without auth

---

### Task 2.2 — Auth Endpoints `[BACKEND]`

**Endpoints:**

#### `POST /api/auth/phone/request-otp`

Request:
```json
{ "phoneNumber": "+919876543210" }
```
Response:
```json
{ "data": { "message": "OTP sent", "expiresInSeconds": 300 } }
```

For MVP: Generate a static OTP (`123456`) and log it. Do NOT integrate a real SMS provider yet. Document this as a placeholder.

#### `POST /api/auth/phone/verify-otp`

Request:
```json
{ "phoneNumber": "+919876543210", "otp": "123456" }
```
Response:
```json
{
  "data": {
    "accessToken": "eyJhbG...",
    "refreshToken": "eyJhbG...",
    "user": {
      "id": "uuid",
      "phoneNumber": "+919876543210",
      "displayName": "User",
      "unitPreference": "METRIC"
    }
  }
}
```

Behavior:
- If phone number doesn't exist → create new user with `displayName = "Gym User"`
- If phone number exists → return existing user
- Always return new access + refresh tokens

#### `POST /api/auth/google`

Request:
```json
{ "idToken": "google-id-token-string" }
```
Response: Same shape as verify-otp response.

For MVP: Validate the Google ID token using Google's tokeninfo endpoint or Google API client library. Extract email, name, and Google ID.

#### `POST /api/auth/refresh`

Request:
```json
{ "refreshToken": "eyJhbG..." }
```
Response:
```json
{
  "data": {
    "accessToken": "new-eyJhbG...",
    "refreshToken": "new-eyJhbG..."
  }
}
```

#### `POST /api/auth/logout`

Request:
```json
{ "refreshToken": "eyJhbG..." }
```
Response: 200 OK. Delete the refresh token from the database.

**Acceptance criteria:**

- [ ] Can request OTP with a phone number
- [ ] Can verify OTP and receive JWT tokens
- [ ] Can use access token to call protected endpoints
- [ ] Can refresh expired access tokens
- [ ] Can logout (invalidate refresh token)
- [ ] New users are created automatically on first login

---

### Task 2.3 — User Profile Endpoints `[BACKEND]`

#### `GET /api/users/me`

Response:
```json
{
  "data": {
    "id": "uuid",
    "phoneNumber": "+919876543210",
    "email": null,
    "displayName": "Gym User",
    "avatarUrl": null,
    "heightCm": null,
    "weightKg": null,
    "dateOfBirth": null,
    "gender": null,
    "unitPreference": "METRIC",
    "createdAt": "2026-08-24T00:00:00Z"
  }
}
```

#### `PUT /api/users/me`

Request:
```json
{
  "displayName": "Krish",
  "heightCm": 175.0,
  "weightKg": 72.5,
  "gender": "MALE",
  "unitPreference": "METRIC"
}
```

All fields optional — only provided fields are updated.

**Acceptance criteria:**

- [ ] Authenticated user can read their profile
- [ ] Authenticated user can update their profile
- [ ] Cannot update another user's profile

---

### Task 2.4 — Mobile Auth Flow `[FRONTEND]`

**Screens:**

1. **LoginScreen** — Phone number input + "Send OTP" button, Google Sign-In button
2. **OtpVerificationScreen** — 6-digit OTP input + "Verify" button

**Auth state management:**

- Store tokens in `@react-native-async-storage/async-storage`
- Create `AuthContext` with: `user`, `isAuthenticated`, `isLoading`, `login()`, `logout()`, `refreshToken()`
- `apiClient.ts` should automatically attach `Authorization: Bearer <token>` header
- `apiClient.ts` should intercept 401 responses and attempt token refresh

**Navigation logic:**

```
App starts
  → Check for stored tokens
    → If valid token exists → MainTabNavigator
    → If no token or expired → AuthNavigator (LoginScreen)
```

**Acceptance criteria:**

- [ ] User can enter phone number and receive OTP (dev: always `123456`)
- [ ] User can verify OTP and land on main app
- [ ] Tokens are persisted — app remembers login across restarts
- [ ] Logout clears tokens and returns to login screen

---

## Step 3 — Exercise Library

> **Goal:** Users can browse, search, and view exercises. Users can create custom exercises.

---

### Task 3.1 — Exercise Endpoints `[BACKEND]`

#### `GET /api/exercises`

Query params: `?search=bench&category=BARBELL&muscleGroup=Chest&page=0&size=20`

All params optional. Returns paginated list.

Response:
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Barbell Bench Press",
      "description": "...",
      "category": "BARBELL",
      "equipment": "BARBELL",
      "isCustom": false,
      "muscleGroups": [
        { "name": "Chest", "role": "PRIMARY" },
        { "name": "Triceps", "role": "SECONDARY" },
        { "name": "Shoulders", "role": "SECONDARY" }
      ]
    }
  ],
  "page": 0, "size": 20, "totalElements": 52, "totalPages": 3
}
```

The endpoint must return:
- All system exercises (where `is_custom = false`)
- Custom exercises created by the authenticated user (where `is_custom = true AND created_by = currentUser`)
- NOT custom exercises from other users

#### `GET /api/exercises/{id}`

Returns single exercise with full details.

#### `POST /api/exercises`

Request:
```json
{
  "name": "Landmine Press",
  "description": "A shoulder-friendly pressing movement",
  "category": "BARBELL",
  "equipment": "BARBELL",
  "primaryMuscleGroupIds": ["uuid-shoulders"],
  "secondaryMuscleGroupIds": ["uuid-chest", "uuid-triceps"]
}
```

Sets `is_custom = true`, `created_by = currentUser`.

#### `PUT /api/exercises/{id}`

Only allowed for custom exercises created by the current user. Returns 403 otherwise.

#### `DELETE /api/exercises/{id}`

Only allowed for custom exercises created by the current user. Returns 403 otherwise.

#### `GET /api/muscle-groups`

Returns all muscle groups ordered by `display_order`.

```json
{
  "data": [
    { "id": "uuid", "name": "Chest", "displayOrder": 1 },
    { "id": "uuid", "name": "Back", "displayOrder": 2 }
  ]
}
```

**Acceptance criteria:**

- [ ] Can list all exercises with pagination
- [ ] Can search exercises by name (case-insensitive)
- [ ] Can filter by category and muscle group
- [ ] Can create custom exercises
- [ ] Can edit/delete own custom exercises
- [ ] Cannot edit/delete system exercises or other users' custom exercises
- [ ] Muscle groups endpoint returns all 14 groups

---

### Task 3.2 — Exercise Screens `[FRONTEND]`

**ExerciseListScreen:**
- Search bar at top
- Filter chips: All, Barbell, Dumbbell, Machine, Cable, Bodyweight
- Scrollable list of exercises
- Each row shows: name, primary muscle group, equipment icon
- Tap → ExerciseDetailScreen
- FAB (floating action button) → CreateExerciseScreen

**ExerciseDetailScreen:**
- Exercise name (large)
- Category and equipment badges
- Primary and secondary muscle groups
- Description text
- "Add to Workout" button (used later in Step 4)

**CreateExerciseScreen:**
- Name input
- Category picker
- Equipment picker
- Primary muscle group multi-select
- Secondary muscle group multi-select
- Description input
- Save button

**Data flow:**
1. On app start, fetch exercises from server and cache in local SQLite
2. Exercise list reads from local SQLite (offline-capable)
3. Search operates on local SQLite
4. Custom exercise creation writes to local SQLite first, then syncs to server

**Acceptance criteria:**

- [ ] Exercise list loads and displays 50+ exercises
- [ ] Search filters exercises by name in real-time
- [ ] Category filter chips work
- [ ] Exercise detail screen shows all information
- [ ] Can create a custom exercise
- [ ] Exercise list works offline (reads from SQLite)

---

## Step 4 — Workout Logging (The Core)

> **Goal:** Users can start a workout, add exercises, log sets, and complete the workout. This is the most important feature in the entire application.
>
> **Performance target:** Logging one set must take < 3 seconds.

---

### Task 4.1 — Workout Endpoints `[BACKEND]`

#### `POST /api/workouts`

Start a new workout.

Request:
```json
{
  "name": "Push Day",
  "routineId": "uuid-or-null",
  "startedAt": "2026-08-24T10:00:00Z"
}
```

If `routineId` is provided, pre-populate `workout_exercises` and `workout_sets` from the routine template.

Response: Full `WorkoutDto` (see below).

#### `GET /api/workouts`

Query params: `?page=0&size=20&status=COMPLETED`

Returns paginated workout summaries.

Response:
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Push Day",
      "status": "COMPLETED",
      "startedAt": "2026-08-24T10:00:00Z",
      "completedAt": "2026-08-24T11:15:00Z",
      "durationSeconds": 4500,
      "exerciseCount": 5,
      "setCount": 20,
      "totalVolumeKg": 5400.0,
      "prCount": 2
    }
  ]
}
```

#### `GET /api/workouts/{id}`

Returns full workout with all exercises and sets.

Response:
```json
{
  "data": {
    "id": "uuid",
    "name": "Push Day",
    "status": "IN_PROGRESS",
    "startedAt": "2026-08-24T10:00:00Z",
    "completedAt": null,
    "notes": null,
    "exercises": [
      {
        "id": "uuid",
        "exerciseId": "uuid",
        "exerciseName": "Barbell Bench Press",
        "position": 1,
        "restSeconds": 180,
        "sets": [
          {
            "id": "uuid",
            "position": 1,
            "setType": "WARMUP",
            "weightKg": 60.0,
            "reps": 10,
            "rpe": null,
            "isCompleted": true,
            "completedAt": "2026-08-24T10:05:00Z",
            "isPr": false
          },
          {
            "id": "uuid",
            "position": 2,
            "setType": "NORMAL",
            "weightKg": 100.0,
            "reps": 5,
            "rpe": 8.0,
            "isCompleted": true,
            "completedAt": "2026-08-24T10:12:00Z",
            "isPr": true
          }
        ]
      }
    ]
  }
}
```

#### `POST /api/workouts/{workoutId}/exercises`

Add an exercise to the workout.

Request:
```json
{
  "exerciseId": "uuid",
  "restSeconds": 180
}
```

Automatically assigns the next `position`. Returns the created `WorkoutExercise` with empty sets.

#### `POST /api/workouts/{workoutId}/exercises/{workoutExerciseId}/sets`

Log a set.

Request:
```json
{
  "setType": "NORMAL",
  "weightKg": 100.0,
  "reps": 5,
  "rpe": 8.0
}
```

The backend must:
1. Create the set with `is_completed = true`, `completed_at = now()`
2. Auto-assign `position`
3. Check if this is a PR (compare against `personal_records` for this user + exercise)
4. If PR, set `is_pr = true` and create/update a `personal_records` entry

Response:
```json
{
  "data": {
    "id": "uuid",
    "position": 1,
    "setType": "NORMAL",
    "weightKg": 100.0,
    "reps": 5,
    "rpe": 8.0,
    "isCompleted": true,
    "isPr": true,
    "prDetails": {
      "recordType": "MAX_WEIGHT",
      "previousValue": 95.0,
      "newValue": 100.0
    }
  }
}
```

#### `PUT /api/workouts/{workoutId}/sets/{setId}`

Update a set (change weight, reps, RPE, set type). Re-evaluate PR status.

#### `DELETE /api/workouts/{workoutId}/sets/{setId}`

Delete a set. Re-evaluate PR status if this was a PR set.

#### `PUT /api/workouts/{workoutId}/complete`

Complete the workout.

Request:
```json
{
  "notes": "Felt strong today"
}
```

Sets `status = COMPLETED`, `completed_at = now()`, calculates `duration_seconds`.

#### `PUT /api/workouts/{workoutId}/cancel`

Cancel the workout. Sets `status = CANCELLED`.

#### `DELETE /api/workouts/{workoutId}/exercises/{workoutExerciseId}`

Remove an exercise and all its sets from the workout. Re-order remaining exercise positions.

**Acceptance criteria:**

- [ ] Can start a workout (with or without routine)
- [ ] Can add exercises to a workout
- [ ] Can log sets with weight, reps, RPE
- [ ] Can mark sets as warmup/drop/failure
- [ ] Can update and delete sets
- [ ] Can complete a workout — duration is calculated
- [ ] Can cancel a workout
- [ ] PRs are automatically detected and recorded
- [ ] Can remove exercises from a workout
- [ ] Workout history is paginated and filterable

---

### Task 4.2 — Active Workout Screen `[FRONTEND]`

This is the **most critical screen** in the entire application.

**Screen layout:**

```
┌──────────────────────────────────────┐
│ ← Back    Push Day       ⏱ 23:45    │  ← Workout name + elapsed time
│                         [Finish ✓]   │  ← Finish button
├──────────────────────────────────────┤
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ 🏋️ Barbell Bench Press          │ │  ← Exercise card
│ │ ┌────┬─────────┬──────┬───────┐ │ │
│ │ │ SET│ PREV    │ KG   │ REPS  │ │ │  ← Column headers
│ │ ├────┼─────────┼──────┼───────┤ │ │
│ │ │ W  │ 60×10   │ [60] │ [10]  │✓│ │  ← Warmup set (completed)
│ │ │ 1  │ 95×5    │ [100]│ [5]   │✓│ │  ← Set 1 (completed, PR! 🎉)
│ │ │ 2  │ 95×5    │ [95] │ [5]   │ │ │  ← Set 2 (not yet completed)
│ │ │ 3  │ —       │ [  ] │ [  ]  │ │ │  ← Set 3 (empty)
│ │ └────┴─────────┴──────┴───────┘ │ │
│ │         [+ Add Set]              │ │
│ │  Rest: 3:00  ⚙️                 │ │  ← Rest timer setting
│ └──────────────────────────────────┘ │
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ 🏋️ Incline Dumbbell Press       │ │  ← Next exercise
│ │ ...                              │ │
│ └──────────────────────────────────┘ │
│                                      │
│       [+ Add Exercise]               │  ← Opens exercise picker
│                                      │
└──────────────────────────────────────┘
```

**Key interactions:**

1. **Logging a set:** User taps the weight field → number pad opens → enters weight → taps reps field → enters reps → taps the ✓ checkmark → set is logged. **Must feel instant.**

2. **PREV column:** Shows the user's weight × reps for the same set position from their last workout with this exercise. If no previous data exists, show "—".

3. **Auto-fill:** When a user taps into a new set's weight/reps fields, pre-fill with the values from the previous set in the same exercise.

4. **PR detection:** When a set is logged that exceeds the user's best for this exercise, show a brief celebratory animation (confetti or a badge) and mark the set with a PR indicator.

5. **Rest timer:** When a set is completed (✓ tapped), automatically start the rest timer for that exercise's configured rest duration. Show a countdown overlay (see Step 6).

6. **Finish button:** Prompts "Finish workout?" → completes the workout → navigates to a summary screen.

**Data flow (OFFLINE-FIRST):**

```
User taps ✓ on a set
  → Write to local SQLite immediately
  → Update UI instantly
  → Queue sync operation in sync_queue
  → If online, sync in background
```

The entire active workout flow MUST work without internet.

**Acceptance criteria:**

- [ ] Can start an empty workout and add exercises from the library
- [ ] Can log sets: enter weight, reps, tap checkmark
- [ ] Each set log takes < 3 seconds
- [ ] PREV column shows last workout data
- [ ] New sets auto-fill from previous set
- [ ] Can add additional sets to any exercise
- [ ] Can delete sets (swipe to delete or long-press)
- [ ] Can change set type (normal/warmup/drop/failure)
- [ ] Can add RPE (optional)
- [ ] Can reorder exercises (drag handle)
- [ ] Can remove exercises from workout
- [ ] Workout timer shows elapsed time
- [ ] Can finish workout — shows summary
- [ ] Can cancel workout
- [ ] Everything works offline

---

### Task 4.3 — Workout History Screen `[FRONTEND]`

**Screen layout:**

```
┌──────────────────────────────────────┐
│         Workout History              │
├──────────────────────────────────────┤
│                                      │
│  Today                               │
│  ┌──────────────────────────────────┐│
│  │ Push Day              1h 15m    ││
│  │ 5 exercises · 20 sets · 5400kg  ││
│  │ 🏆 2 PRs                       ││
│  └──────────────────────────────────┘│
│                                      │
│  Yesterday                           │
│  ┌──────────────────────────────────┐│
│  │ Pull Day              1h 05m    ││
│  │ 4 exercises · 16 sets · 4200kg  ││
│  └──────────────────────────────────┘│
│                                      │
│  Tap any card → WorkoutDetailScreen  │
└──────────────────────────────────────┘
```

**WorkoutDetailScreen:** Shows the full workout — all exercises, all sets, all weights/reps, PRs, notes, duration.

**Acceptance criteria:**

- [ ] Workout history shows completed workouts grouped by date
- [ ] Each card shows: name, duration, exercise count, set count, total volume, PR count
- [ ] Tapping a card opens the full workout detail
- [ ] History loads from local SQLite (works offline)
- [ ] Infinite scroll or pagination

---

## Step 5 — Routines

> **Goal:** Users can create workout templates and start workouts from them.

---

### Task 5.1 — Routine Endpoints `[BACKEND]`

#### `GET /api/routines`

Returns all routines for the authenticated user.

Response:
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Push Day",
      "description": "Chest, shoulders, triceps",
      "exerciseCount": 5,
      "createdAt": "2026-08-24T00:00:00Z"
    }
  ]
}
```

#### `GET /api/routines/{id}`

Returns full routine with exercises and default sets.

Response:
```json
{
  "data": {
    "id": "uuid",
    "name": "Push Day",
    "description": "Chest, shoulders, triceps",
    "exercises": [
      {
        "id": "uuid",
        "exerciseId": "uuid",
        "exerciseName": "Barbell Bench Press",
        "position": 1,
        "restSeconds": 180,
        "sets": [
          { "position": 1, "setType": "WARMUP", "targetReps": 10, "targetWeightKg": 60.0 },
          { "position": 2, "setType": "NORMAL", "targetReps": 5, "targetWeightKg": 100.0 },
          { "position": 3, "setType": "NORMAL", "targetReps": 5, "targetWeightKg": 100.0 },
          { "position": 4, "setType": "NORMAL", "targetReps": 5, "targetWeightKg": 100.0 }
        ]
      }
    ]
  }
}
```

#### `POST /api/routines`

Request:
```json
{
  "name": "Push Day",
  "description": "Chest, shoulders, triceps",
  "exercises": [
    {
      "exerciseId": "uuid",
      "position": 1,
      "restSeconds": 180,
      "sets": [
        { "position": 1, "setType": "WARMUP", "targetReps": 10, "targetWeightKg": 60.0 },
        { "position": 2, "setType": "NORMAL", "targetReps": 5, "targetWeightKg": 100.0 }
      ]
    }
  ]
}
```

#### `PUT /api/routines/{id}`

Same shape as POST. Replaces the entire routine (exercises and sets). Only the owner can edit.

#### `DELETE /api/routines/{id}`

Soft delete or hard delete. Only the owner can delete.

**Acceptance criteria:**

- [ ] Can CRUD routines with exercises and default sets
- [ ] Starting a workout from a routine pre-populates exercises and sets
- [ ] Only routine owner can edit/delete

---

### Task 5.2 — Routine Screens `[FRONTEND]`

**RoutineListScreen:**
- List of user's routines
- Each card: name, description, exercise count
- Tap → RoutineDetailScreen
- FAB → CreateRoutineScreen

**CreateRoutineScreen:**
- Name input
- Description input
- Add exercises (opens exercise picker)
- For each exercise: configure default sets (type, target weight, target reps)
- Reorder exercises (drag)
- Save button

**Starting a workout from routine:**
- On RoutineDetailScreen or RoutineListScreen, "Start Workout" button
- Creates a new workout pre-populated from the routine template
- Navigates to ActiveWorkoutScreen

**Acceptance criteria:**

- [ ] Can create a routine with multiple exercises and default sets
- [ ] Can edit existing routines
- [ ] Can delete routines
- [ ] Can start a workout from a routine — exercises and sets pre-populate
- [ ] Routines are stored locally (work offline)

---

## Step 6 — Rest Timer

> **Goal:** Automatic rest timer between sets with notification.

---

### Task 6.1 — Rest Timer Implementation `[FRONTEND]`

**Behavior:**

1. When user completes a set (taps ✓), the rest timer starts automatically
2. Rest duration comes from the exercise's `rest_seconds` (default: 90s for isolation, 180s for compounds)
3. Timer shows as an overlay at bottom of ActiveWorkoutScreen
4. Timer also shows as an Android notification (so it's visible on lock screen)
5. When timer reaches 0, play a short vibration/sound
6. User can:
   - Skip the timer (dismiss early)
   - Add 30 seconds
   - Subtract 30 seconds
   - Change default rest time for the current exercise

**Timer overlay UI:**

```
┌──────────────────────────────────────┐
│  Rest Timer                          │
│                                      │
│          ⏱️ 2:45                     │  ← Large countdown
│                                      │
│    [-30s]    [Skip]    [+30s]        │
└──────────────────────────────────────┘
```

**Android notification:**

Use React Native's notification API or a foreground service to show:
- Notification title: "Rest Timer"
- Notification body: "2:45 remaining"
- Update every second
- When complete: "Time to lift! 🏋️"

**Acceptance criteria:**

- [ ] Timer starts automatically after completing a set
- [ ] Countdown is visible on the workout screen
- [ ] Timer shows as Android notification
- [ ] Vibration/sound when timer reaches 0
- [ ] Can skip, +30s, -30s
- [ ] Timer persists if user navigates away and returns
- [ ] Can configure per-exercise rest time

---

## Step 7 — Analytics & PR Tracking

> **Goal:** Users can see workout history, personal records, and basic volume analytics.

---

### Task 7.1 — Analytics Endpoints `[BACKEND]`

#### `GET /api/analytics/personal-records`

Query: `?exerciseId=uuid` (optional — all PRs if omitted)

Response:
```json
{
  "data": [
    {
      "exerciseId": "uuid",
      "exerciseName": "Barbell Bench Press",
      "records": {
        "MAX_WEIGHT": { "value": 100.0, "achievedAt": "2026-08-24T10:12:00Z" },
        "MAX_REPS": { "value": 12, "achievedAt": "2026-08-20T09:30:00Z" },
        "EST_1RM": { "value": 120.0, "achievedAt": "2026-08-24T10:12:00Z" }
      }
    }
  ]
}
```

**Estimated 1RM formula:** Use Brzycki formula: `1RM = weight × (36 / (37 - reps))` (only for reps ≤ 10).

#### `GET /api/analytics/exercise/{exerciseId}/history`

Returns set history for an exercise across all workouts.

Response:
```json
{
  "data": {
    "exerciseId": "uuid",
    "exerciseName": "Barbell Bench Press",
    "history": [
      {
        "date": "2026-08-24",
        "sets": [
          { "weightKg": 100.0, "reps": 5, "setType": "NORMAL" },
          { "weightKg": 95.0, "reps": 8, "setType": "NORMAL" }
        ],
        "bestSet": { "weightKg": 100.0, "reps": 5 },
        "totalVolumeKg": 1260.0
      }
    ]
  }
}
```

#### `GET /api/analytics/summary`

Query: `?days=30`

Response:
```json
{
  "data": {
    "period": "30 days",
    "totalWorkouts": 12,
    "totalSets": 240,
    "totalVolumeKg": 54000.0,
    "totalDurationMinutes": 900,
    "avgWorkoutDurationMinutes": 75,
    "muscleGroupVolume": [
      { "muscleGroup": "Chest", "volumeKg": 12000.0, "sets": 48 },
      { "muscleGroup": "Back", "volumeKg": 10500.0, "sets": 42 }
    ],
    "newPRs": 5
  }
}
```

**Acceptance criteria:**

- [ ] PR endpoint returns max weight, max reps, est 1RM per exercise
- [ ] Exercise history returns chronological set data
- [ ] Summary shows workout count, volume, duration, muscle group breakdown
- [ ] Estimated 1RM uses Brzycki formula

---

### Task 7.2 — Analytics Screens `[FRONTEND]`

Integrate analytics into the app. For MVP, keep it simple:

1. **PR list:** Show all PRs on a dedicated tab or section in profile
2. **Exercise history chart:** On ExerciseDetailScreen, show a line chart of best set weight over time
3. **Workout summary stats:** On WorkoutHistoryScreen header, show 30-day summary (workouts, volume, PRs)

Use a charting library (candidate: `react-native-chart-kit` or `victory-native`).

**Acceptance criteria:**

- [ ] PR list shows all personal records grouped by exercise
- [ ] Exercise detail shows weight progression chart
- [ ] History screen shows 30-day summary
- [ ] All analytics data comes from local SQLite (offline-capable)

---

## Step 8 — Indian Meal Logging

> **Goal:** Users can log meals using an Indian food database.

---

### Task 8.1 — Food Item Endpoints `[BACKEND]`

#### `GET /api/food-items/search`

Query: `?q=paneer&vegetarian=true&page=0&size=20`

Response:
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Paneer Tikka",
      "brand": null,
      "servingSize": 100.0,
      "servingUnit": "g",
      "calories": 265.0,
      "proteinG": 18.0,
      "carbsG": 3.0,
      "fatG": 20.0,
      "fiberG": 0.5,
      "isVegetarian": true,
      "foodCategory": "INDIAN_SNACK",
      "isVerified": true
    }
  ]
}
```

#### `GET /api/food-items/{id}`

Single food item with full details.

#### `POST /api/food-items`

Create custom food item. Sets `is_custom = true`, `created_by = currentUser`.

**Acceptance criteria:**

- [ ] Search returns matching foods (case-insensitive, partial match)
- [ ] Can filter by vegetarian
- [ ] Can create custom food items

---

### Task 8.2 — Nutrition Entry Endpoints `[BACKEND]`

#### `GET /api/nutrition/entries`

Query: `?date=2026-08-24` (returns entries for that day)

Response:
```json
{
  "data": {
    "date": "2026-08-24",
    "totalCalories": 2150.0,
    "totalProteinG": 145.0,
    "totalCarbsG": 280.0,
    "totalFatG": 65.0,
    "meals": [
      {
        "id": "uuid",
        "mealType": "BREAKFAST",
        "loggedAt": "2026-08-24T08:00:00Z",
        "items": [
          {
            "id": "uuid",
            "foodItemId": "uuid",
            "foodItemName": "Oats with Milk",
            "quantity": 1.0,
            "servingUnit": "bowl",
            "calories": 350.0,
            "proteinG": 15.0,
            "carbsG": 55.0,
            "fatG": 8.0
          }
        ],
        "totalCalories": 350.0
      }
    ]
  }
}
```

#### `POST /api/nutrition/entries`

Request:
```json
{
  "mealType": "LUNCH",
  "loggedAt": "2026-08-24T13:00:00Z",
  "items": [
    { "foodItemId": "uuid", "quantity": 2.0, "servingUnit": "roti" },
    { "foodItemId": "uuid", "quantity": 1.0, "servingUnit": "katori" }
  ]
}
```

The backend calculates calories/macros from the food item data × quantity.

#### `DELETE /api/nutrition/entries/{id}`

Delete a nutrition entry and all its items.

**Acceptance criteria:**

- [ ] Can log a meal with multiple food items
- [ ] Daily summary calculates total calories/macros
- [ ] Can delete meal entries

---

### Task 8.3 — Indian Food Seed Data `[BACKEND]`

Create `V9__seed_indian_food_items.sql` with an initial set of verified Indian food items.

**Minimum: 200 entries to start.** Prioritize commonly consumed foods.

**Categories to cover:**

| Category | Example items |
|:---|:---|
| `GRAIN` | Roti (wheat), Rice (cooked), Naan, Paratha, Poha, Upma, Idli, Dosa |
| `DAL_LENTIL` | Moong dal, Toor dal, Chana dal, Masoor dal, Rajma, Chole |
| `VEGETABLE` | Aloo sabzi, Bhindi, Palak, Gobi, Baingan |
| `PANEER_DAIRY` | Paneer tikka, Paneer bhurji, Curd/Dahi, Lassi, Paneer butter masala |
| `NON_VEG` | Chicken curry, Egg bhurji, Fish curry, Chicken tikka, Mutton curry |
| `INDIAN_SNACK` | Samosa, Pakora, Bhel puri, Vada pav, Dhokla |
| `INDIAN_SWEET` | Gulab jamun, Jalebi, Ladoo, Rasgulla, Kheer |
| `BEVERAGE` | Chai (with milk/sugar), Coffee, Buttermilk, Nimbu pani |
| `PROTEIN_SUPPLEMENT` | Whey protein (per scoop), Sattu drink |
| `FRUIT` | Banana, Apple, Mango, Papaya, Chikoo |
| `DRY_FRUIT` | Almonds, Cashews, Peanuts, Makhana |

Each entry must have realistic macros per standard serving.

Mark items appropriately with `is_vegetarian`.

**Acceptance criteria:**

- [ ] ≥ 200 food items seeded
- [ ] All major Indian food categories covered
- [ ] Macros are realistic and verified
- [ ] `is_vegetarian` is correctly set
- [ ] Search returns expected results ("dal" → multiple dal varieties)

---

### Task 8.4 — Nutrition Screens `[FRONTEND]`

**NutritionDashboardScreen:**
- Date selector (today by default, can swipe between days)
- Daily macro summary: calories, protein, carbs, fat (ring/bar chart)
- Meals grouped by type: Breakfast, Lunch, Dinner, Snacks
- Each meal shows items and calories
- "+ Log Meal" button per meal type

**MealLogScreen:**
- Meal type header (e.g., "Log Lunch")
- Search bar → searches food database
- Recent foods section
- Selected items list with quantity adjusters
- Running total: calories, protein, carbs, fat
- Save button

**FoodSearchScreen:**
- Search input
- Results list with: name, calories per serving, veg/non-veg indicator (🟢/🔴)
- Tap → select food → set quantity → add to meal

**Acceptance criteria:**

- [ ] Can browse daily nutrition by date
- [ ] Can log a meal with multiple food items
- [ ] Can search the food database
- [ ] Macro totals calculate correctly
- [ ] Food database is cached locally (search works offline)
- [ ] Veg/non-veg indicators shown

---

## Step 9 — Offline Sync Layer

> **Goal:** Data created offline syncs to the server when connectivity returns.

---

### Task 9.1 — Sync Endpoints `[BACKEND]`

#### `POST /api/sync/push`

Client pushes locally created/updated/deleted entities to server.

Request:
```json
{
  "operations": [
    {
      "entityType": "workout",
      "entityId": "client-uuid",
      "operation": "CREATE",
      "data": { /* full entity JSON */ },
      "clientTimestamp": "2026-08-24T10:00:00Z"
    },
    {
      "entityType": "workout_set",
      "entityId": "client-uuid",
      "operation": "CREATE",
      "data": { /* full entity JSON */ },
      "clientTimestamp": "2026-08-24T10:05:00Z"
    }
  ]
}
```

Response:
```json
{
  "data": {
    "processed": 2,
    "conflicts": 0,
    "results": [
      { "clientId": "client-uuid", "serverId": "server-uuid", "status": "CREATED" },
      { "clientId": "client-uuid", "serverId": "server-uuid", "status": "CREATED" }
    ]
  }
}
```

#### `GET /api/sync/pull`

Query: `?since=2026-08-24T00:00:00Z`

Returns all entities modified since the given timestamp (for this user).

Response:
```json
{
  "data": {
    "exercises": [ /* updated exercises */ ],
    "workouts": [ /* updated workouts */ ],
    "routines": [ /* updated routines */ ],
    "foodItems": [ /* updated food items */ ],
    "lastSyncTimestamp": "2026-08-24T12:00:00Z"
  }
}
```

**Acceptance criteria:**

- [ ] Push endpoint accepts batched operations
- [ ] Pull endpoint returns changes since last sync
- [ ] Idempotent — re-pushing the same operation doesn't create duplicates
- [ ] Conflict detection based on timestamps

---

### Task 9.2 — Mobile Sync Engine `[FRONTEND]`

**Sync flow:**

```
App comes online (or periodic WorkManager trigger)
  → Read pending items from sync_queue
  → Batch into POST /api/sync/push
  → For each success: mark sync_queue item as COMPLETED, update entity sync_status = 'SYNCED'
  → For each conflict: mark entity sync_status = 'CONFLICT' (resolve later)
  → Call GET /api/sync/pull?since=lastSyncTimestamp
  → Upsert returned entities into local SQLite
  → Update lastSyncTimestamp
```

**Network detection:**

- Use React Native's `NetInfo` library to detect connectivity changes
- When connectivity is regained → trigger sync
- Also run sync on app foreground

**Retry strategy:**

- On failure: increment `retry_count`, set exponential backoff
- Max retries: 5
- After max retries: mark as FAILED, surface to user

**Acceptance criteria:**

- [ ] Entities created offline are synced when connectivity returns
- [ ] Sync is non-blocking (runs in background)
- [ ] Failed syncs retry with exponential backoff
- [ ] Pull updates local data with server changes
- [ ] Duplicate pushes don't create duplicate server records

---

## Step 10 — Polish & Release Prep

> **Goal:** The app is stable, tested, performant, and ready for internal testing.

---

### Task 10.1 — Error Handling `[BOTH]`

**Backend:**
- Global exception handler returns consistent error responses
- Validation errors return field-level details
- 404 for missing resources
- Proper HTTP status codes everywhere

**Frontend:**
- API errors show user-friendly toast messages
- Network errors show "You're offline — data saved locally"
- Form validation with inline error messages
- Loading states on all async operations
- Empty states with helpful messages

---

### Task 10.2 — Performance `[BOTH]`

**Backend:**
- Database queries use indexes (already defined in migrations)
- Paginate all list endpoints
- Lazy-load JPA relationships where appropriate
- No N+1 queries

**Frontend:**
- FlatList with proper `keyExtractor` and `getItemLayout` for smooth scrolling
- Memoize expensive computations
- Minimize re-renders in workout screen
- SQLite operations should not block the UI thread
- Test on a budget Android device (or emulator with limited RAM)

**Target:** APK < 30MB

---

### Task 10.3 — Testing `[BOTH]`

**Backend tests (JUnit + Spring Boot Test):**
- Unit tests for services (especially PR detection, workout completion, macro calculation)
- Integration tests for repositories (use H2 or Testcontainers)
- Controller tests for API endpoints (MockMvc)
- Auth tests (token generation, validation, protected endpoints)

**Frontend tests (Jest):**
- Unit tests for utility functions (1RM calculation, date formatting, macro math)
- Unit tests for database repositories
- Component tests for critical components (SetLogRow, RestTimerOverlay)

**Minimum coverage targets for MVP:**
- PR detection logic: 100%
- Auth flow: happy path + error cases
- Workout CRUD: happy path
- Nutrition calculation: happy path

---

### Task 10.4 — CI/CD Setup `[BACKEND]`

Create `.github/workflows/` with:

1. **`backend-ci.yml`** — On push/PR to `dev`:
   - Checkout
   - Setup JDK 21
   - `./gradlew build`
   - `./gradlew test`
   - Report test results

2. **`mobile-ci.yml`** — On push/PR to `dev`:
   - Checkout
   - Setup Node 20
   - `npm ci`
   - `npm run lint`
   - `npx tsc --noEmit`
   - `npm test`

---

### Task 10.5 — Build Release APK `[FRONTEND]`

1. Configure Android signing (keystore)
2. Build release APK: `cd mobile/android && ./gradlew assembleRelease`
3. Verify APK size < 30MB
4. Test on a physical Android device

---

## Appendix A — Full PostgreSQL Schema

Summary of all tables:

| Table | Rows at seed | References |
|:---|:---|:---|
| `users` | 0 | — |
| `refresh_tokens` | 0 | `users` |
| `muscle_groups` | 14 | — |
| `exercises` | 50+ | `users` (optional) |
| `exercise_muscle_groups` | ~100+ | `exercises`, `muscle_groups` |
| `workouts` | 0 | `users`, `routines` |
| `workout_exercises` | 0 | `workouts`, `exercises` |
| `workout_sets` | 0 | `workout_exercises` |
| `routines` | 0 | `users` |
| `routine_exercises` | 0 | `routines`, `exercises` |
| `routine_sets` | 0 | `routine_exercises` |
| `food_items` | 200+ | `users` (optional) |
| `nutrition_entries` | 0 | `users` |
| `nutrition_entry_items` | 0 | `nutrition_entries`, `food_items` |
| `personal_records` | 0 | `users`, `exercises`, `workout_sets` |
| `body_measurements` | 0 | `users` |

Total: **16 tables**

---

## Appendix B — Full SQLite Schema

The mobile SQLite schema mirrors the PostgreSQL schema with these additions per syncable table:

- `sync_status TEXT DEFAULT 'PENDING'`
- `last_synced_at TEXT`
- `is_deleted INTEGER DEFAULT 0`

Plus the `sync_queue` table for pending operations.

Tables that exist only locally and don't sync:
- Active workout state (in-memory or local-only table)
- Rest timer state
- App preferences

---

## Appendix C — API Endpoint Summary

| Method | Endpoint | Auth | Description |
|:---|:---|:---:|:---|
| `GET` | `/api/health` | ❌ | Health check |
| `POST` | `/api/auth/phone/request-otp` | ❌ | Request OTP |
| `POST` | `/api/auth/phone/verify-otp` | ❌ | Verify OTP, get tokens |
| `POST` | `/api/auth/google` | ❌ | Google sign-in |
| `POST` | `/api/auth/refresh` | ❌ | Refresh access token |
| `POST` | `/api/auth/logout` | ✅ | Logout |
| `GET` | `/api/users/me` | ✅ | Get profile |
| `PUT` | `/api/users/me` | ✅ | Update profile |
| `GET` | `/api/muscle-groups` | ✅ | List muscle groups |
| `GET` | `/api/exercises` | ✅ | List/search exercises |
| `GET` | `/api/exercises/{id}` | ✅ | Get exercise |
| `POST` | `/api/exercises` | ✅ | Create custom exercise |
| `PUT` | `/api/exercises/{id}` | ✅ | Update custom exercise |
| `DELETE` | `/api/exercises/{id}` | ✅ | Delete custom exercise |
| `GET` | `/api/workouts` | ✅ | List workouts |
| `POST` | `/api/workouts` | ✅ | Start workout |
| `GET` | `/api/workouts/{id}` | ✅ | Get workout detail |
| `POST` | `/api/workouts/{id}/exercises` | ✅ | Add exercise to workout |
| `DELETE` | `/api/workouts/{id}/exercises/{eid}` | ✅ | Remove exercise |
| `POST` | `/api/workouts/{id}/exercises/{eid}/sets` | ✅ | Log set |
| `PUT` | `/api/workouts/{id}/sets/{sid}` | ✅ | Update set |
| `DELETE` | `/api/workouts/{id}/sets/{sid}` | ✅ | Delete set |
| `PUT` | `/api/workouts/{id}/complete` | ✅ | Complete workout |
| `PUT` | `/api/workouts/{id}/cancel` | ✅ | Cancel workout |
| `GET` | `/api/routines` | ✅ | List routines |
| `POST` | `/api/routines` | ✅ | Create routine |
| `GET` | `/api/routines/{id}` | ✅ | Get routine detail |
| `PUT` | `/api/routines/{id}` | ✅ | Update routine |
| `DELETE` | `/api/routines/{id}` | ✅ | Delete routine |
| `GET` | `/api/food-items/search` | ✅ | Search food items |
| `GET` | `/api/food-items/{id}` | ✅ | Get food item |
| `POST` | `/api/food-items` | ✅ | Create custom food item |
| `GET` | `/api/nutrition/entries` | ✅ | Get daily nutrition |
| `POST` | `/api/nutrition/entries` | ✅ | Log meal |
| `DELETE` | `/api/nutrition/entries/{id}` | ✅ | Delete meal entry |
| `GET` | `/api/analytics/personal-records` | ✅ | Get PRs |
| `GET` | `/api/analytics/exercise/{id}/history` | ✅ | Exercise history |
| `GET` | `/api/analytics/summary` | ✅ | Workout summary |
| `POST` | `/api/sync/push` | ✅ | Push local changes |
| `GET` | `/api/sync/pull` | ✅ | Pull server changes |

**Total: 37 endpoints**

---

*Document created by Antigravity. 2026-08-24.*
*This document is the single source of truth for MVP implementation.*
*Both agents must follow this plan. Deviations require user approval.*
