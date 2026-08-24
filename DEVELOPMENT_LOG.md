# DEVELOPMENT_LOG.md

> **Project:** Aven Fit (Gym Tracker)
> **Purpose:** Track development progress, decisions, handoffs, and known issues between agents.

---

## Log Entries

---

### 2026-08-25 — OpenCode/Ox Alpha — Full backend QA pass complete

**Task:** Phased testing & debugging pass over all completed backend work (senior-dev/tester review). Policy: fix-as-found; OTP throttle deferred; sync bypasses state guards (pinned).

**Status:** Complete. **122 tests green across two consecutive full runs** (was 92 → +30 QA tests). Fresh-DB drill passed. Findings ledger below.

**QA suites added (`com.avenfit.qa` + security/nutrition additions):**
- `SecurityAuditIntegrationTest` (9) — JWT negatives at endpoint level, cross-user authz matrix incl. sync handlers, refresh-token cross-user logout protection, LIKE/quote injection probes, wildcard predictability, unicode round-trip
- `FunctionalBoundariesTest` (9) — RPE exact bounds, zero-weight legality, pagination edges, empty-PUT profile, non-sequential routine positions pinned, shrink-to-empty replace, Brzycki reps=10-in/11-out, analytics window clamps, macro HALF_UP rounding, **sync-bypasses-state-guards semantics pinned end-to-end**
- `ReferentialIntegrityTest` (4) — referenced-exercise delete→409, referenced-food sync-delete degrades to FAILED, PR downgrade on synced workout deletion, routine-deleted-after-use keeps workouts intact
- `ConcurrencyProbeTest` (2) — double-refresh race exactly-one-winner; 5-way parallel set logging all-succeed-unique-positions
- `QueryBudgetSmokeTest` (4) — Hibernate-statistics query budgets: list=1 query/7ms, detail graph=2/6ms, daily summary=1/11ms, pull=5/23ms. **No N+1 anywhere.**

## Findings Ledger

| # | Severity | Finding | Resolution |
|:---:|:---|:---|:---|
| F1 | 🔴 Critical | **Windows builds corrupted all non-ASCII string literals** (javac ran at platform CP1252): Hindi names would have been stored as garbage on any Windows dev build. Linux CI would have masked it | Fixed: `options.encoding="UTF-8"` via `configureEach`; test JVM `-Dfile.encoding=UTF-8`. Verified via codepoint probe (प=2346) |
| F2 | 🔴 High | **`workout_sets` had no unique constraint on `(workout_exercise_id, position)`** — spec gap inherited from plan V3; concurrent logging could silently duplicate positions in production too | Fixed: new migration `V10__add_workout_set_position_unique.sql` + entity `@UniqueConstraint` mirror |
| F3 | 🔴 High | Position assignment raced under concurrent writes (`MAX+1` read-then-insert); naive retry poisoned the transaction | Fixed: pessimistic `PESSIMISTIC_WRITE` locks on parent rows (workout / workout_exercise) serialize assignment per aggregate — no exceptions, strict ordering |
| F4 | 🟠 Medium | Refresh rotation was double-spendable: two concurrent `/refresh` calls with one token could both mint pairs | Fixed: conditional bulk delete returns row-count; 0 rows ⇒ loser gets 401. Race test proves exactly-one-winner |
| F5 | 🟠 Medium | Synced `workout DELETE` left personal_records orphaned (source sets cascade-vanished, records lingered unmoored) | Fixed: processor captures affected exercises pre-delete and re-syncs PRs after |
| F6 | 🟡 Low | Wrong HTTP method on an endpoint returned **500** instead of 405 | Fixed: `HttpRequestMethodNotSupportedException` → 405 `METHOD_NOT_ALLOWED` |
| F7 | 🟡 Low | Test-infra gotchas documented in-code: MockMvc string bodies default ISO-8859-1; `getContentAsString()` needs explicit UTF-8 for unicode assertions; javap console output mangles non-ASCII (display only) | Test-side fixes only |
| F8 | ⚪ Known-issue (deferred per user) | No OTP brute-force throttling (static MVP OTP makes it moot today) | Documented here; revisit pre-production with real SMS |
| F9 | ⚪ Known-issue | Flyway migrations only exercised against real Postgres locally; CI uses H2 (V5 GIN index incompatible) | Candidate post-MVP: Testcontainers job in backend-ci |

**Verification:** fresh empty DB → V1–V9 applied clean (14/55/201 seeds) · full suite ×2 consecutive green (122) · mobile gates re-run green · all live E2E behaviors from earlier phases still hold.

**Next Steps:** Backend is QA-signed-off. Remaining plan work is frontend-owned ([FRONTEND] tasks 0.3-post-init → 10.5) plus shared Step 10 polish. Recommended near-term: first `git push` to activate CI pipelines.

**Notes for Antigravity:** please review F1–F5 especially — F1/F2 change build+schema behavior (both are strictly safer than before). Sync-bypasses-guards is now a tested contract your conflict resolver can rely on.

---

### 2026-08-24 — OpenCode/Ox Alpha — Task 10.4 CI workflows complete

**Task:** DEVELOPMENT_PLAN.md Task 10.4 [BACKEND] — GitHub Actions CI for both projects.

**Status:** Complete. **This closes out every `[BACKEND]`/`[SCHEMA]`-tagged task in DEVELOPMENT_PLAN.md** (Steps 0–5, 7, 8, 9 + 10.4). Remaining plan work is `[FRONTEND]`/`[BOTH]`: mobile Tasks 0.3-post-init through 10.5, and Step 10 polish items shared across agents.

**Changes:**

| File | Description |
|:---|:---|
| `.github/workflows/backend-ci.yml` | Push/PR → dev. JDK 21 (Temurin), Gradle cache, `build` + `test`, JUnit report via dorny/test-reporter, artifact upload (7-day retention) |
| `.github/workflows/mobile-ci.yml` | Push/PR → dev. Node 20, npm cache from lockfile, `npm ci` → lint → `tsc --noEmit` → jest (`--ci`) |

Both include concurrency cancellation per ref. YAML validated programmatically; mobile's exact commands re-run locally green (eslint clean / tsc clean / 1-1 tests). Backend build+test proven 92-green.

**Known Issues:** unchanged (deferred).

**Notes for Antigravity:**
- First push to `origin/dev` will trigger both pipelines — expect green given local parity.
- Backend CI runs against H2 (test profile); Flyway migrations are exercised only on real Postgres, so keep the local bootRun ritual until Testcontainers lands (candidate post-MVP hardening).
- dorny/test-reporter needs `checks: write` — already set in the workflow permissions block.

---

### 2026-08-24 — OpenCode/Ox Alpha — Step 9 Sync Layer complete

**Task:** DEVELOPMENT_PLAN.md Task 9.1 [BACKEND] — push/pull sync endpoints. Task 9.2 [FRONTEND] untouched.

**Status:** Complete. **92 tests green** + live E2E vs PostgreSQL. This completes every `[BACKEND]`/`[SCHEMA]` task in the MVP plan; only Task 10.4 CI remains on the backend side.

**Changes:**

| File | Description |
|:---|:---|
| `sync/dto/{SyncPushRequest,SyncPushResponse,SyncPullResponse}.java` | Plan shapes: batched operations w/ clientTimestamps; results carry `{clientId, serverId, status}`; pull returns exercises/workouts(full graphs)/routines(full templates)/foodItems + lastSyncTimestamp |
| `sync/service/SyncOperationProcessor.java` | Per-type `@Transactional` handlers (exercise, workout, workout_exercise, workout_set, routine, food_item). Idempotency via shared client UUIDs (`CREATE` on existing → `IGNORED_DUPLICATE`); conflict = server `updated_at` newer than client snapshot **+1s grace window**; ownership enforced everywhere; deletes are idempotent; PR engine re-runs after synced sets |
| `sync/service/SyncService.java` | Push orchestration with **per-operation error isolation** (one bad op never aborts the batch); pull assembly reusing detail-graph queries |
| `sync/controller/SyncController.java` | `POST /api/sync/push`, `GET /api/sync/pull?since=` |
| `routine/service/RoutineService.java` | Added `syncUpsert(user, id, request)` — creates under the client's own id or performs full replace (shared `doReplace` path) |
| Repositories | Derived `...UpdatedAtAfter` finders (workouts/routines); FoodItem list-spec overload |
| `common/exception/GlobalExceptionHandler.java` | Type-mismatched query params now → 400 (was falling through to 500) |

**Bug found & fixed during testing:** immediate replay flagged CONFLICT because second-precision client timestamps lost to nanosecond server `updated_at`. Fixed with the documented 1-second grace window; also caught that my first patch attempt silently no-op'd (string-replace misses) — verified via grep before rebuilding.

**Tests:** 9 new sync tests — offline batch creation, exact-batch replay idempotency, stale-vs-fresh conflict handling, unsupported-type isolation, delete+replay, foreign routine protection, validation, pull windows incl. full workout graphs, user scoping, malformed-since 400. Live E2E: 4-op batch (routine+workout+we+set) → CREATED×4 → replay IGNORED_DUPLICATE×4 → pull returns workout-with-set graph + routine → later-window pull empty.

**Known Issues:** unchanged (deferred).

**Next Steps:** Task 10.4 CI workflows (`backend-ci.yml`, `mobile-ci.yml`) is the last backend-tagged deliverable. Then Step 10 polish items that fall in backend scope. Frontend steps (0.3 post-init, 2.4–10.5) remain Antigravity's.

**Notes for Antigravity:**
- Sync API ready for mobile Task 9.2. Statuses your `conflictResolver` can expect: `CREATED`, `UPDATED`, `DELETED`, `IGNORED_DUPLICATE`, `CONFLICT`, `UNSUPPORTED_TYPE`, `NOT_FOUND`, `FAILED`, `VALIDATION_ERROR`.
- Client timestamps SHOULD be millisecond ISO-8601 (`yyyy-MM-dd'T'HH:mm:ss.SSSZ`); a 1s grace window tolerates coarse clocks but precise stamps keep conflict semantics sharp.
- Muscle-group links inside pushed exercises are NOT synced (scalar fields only) — create customs online if muscle tags matter, or we extend the mapper later.

---

### 2026-08-24 — OpenCode/Ox Alpha — Step 8 Nutrition complete

**Task:** DEVELOPMENT_PLAN.md Tasks 8.1–8.3 [BACKEND] — food-item endpoints, nutrition entry endpoints, Indian food seed. Task 8.4 [FRONTEND] untouched.

**Status:** Complete. 83 tests green + live E2E vs PostgreSQL.

**Changes:**

| File | Description |
|:---|:---|
| `nutrition/dto/{FoodItemDto,CreateFoodItemRequest,DailyNutritionDto,LogMealRequest}.java` | Exact plan shapes; DTO intentionally omits isCustom/createdBy/barcode echo |
| `nutrition/service/FoodItemService.java` | Specification-based search (visibility + name + veg flag), custom creation |
| `nutrition/service/NutritionService.java` | Server-computed macros (`food × quantity`, 2-dp HALF_UP), daily summary with **IST day boundaries** (`avenfit.nutrition.day-zone`, default Asia/Kolkata) |
| `nutrition/controller/{FoodItemController,NutritionController}.java` | Search/get/create + entries GET/POST/DELETE per Appendix C |
| `nutrition/repository/*` | FoodItemRepository → JpaSpecificationExecutor; entry owner lookup w/ EntityGraph |
| `db/migration/V9__seed_indian_food_items.sql` | **201 verified Indian foods** across all 11 categories (GRAIN 30, DAL_LENTIL 22, VEGETABLE 20, PANEER_DAIRY 20, NON_VEG 22, INDIAN_SNACK 22, INDIAN_SWEET 18, BEVERAGE 12, PROTEIN_SUPPLEMENT 6, FRUIT 17, DRY_FRUIT 12); realistic per-serving macros; correct veg flags |

**Semantics implemented (documented decisions):**
1. Custom-food visibility mirrors exercises: foreign customs are invisible (404 on direct GET, absent from search).
2. Macro calculation is literal to spec — `food.macros × quantity`; each seeded row defines one serving (servingSize/unit describe the unit). Client-supplied item unit overrides the label only.
3. `loggedAt` optional in log-meal request (defaults to server now) — friendlier for quick logging; day attribution uses IST calendar boundaries.
4. Search returns the standard paged envelope (plan example omitted metadata but §1 convention + page/size params require it).

**Tests:** `.\gradlew.bat build` → BUILD SUCCESSFUL, **83 tests green** (12 new). Live E2E vs PostgreSQL: V9 migrated cleanly (v9 applied); `food_items=201`; "dal" search → 13 varieties; veg-filter on non-veg term → 0; real meal (Paneer Tikka ×1 + Roti ×2) computed **exactly** 240+208=448 kcal with per-item macro precision; IST daily summary matched; delete → empty day.

**Known Issues:** unchanged (deferred).

**Next Steps:** Step 9 Offline Sync backend (Task 9.1 — push/pull endpoints, idempotency), then Task 10.4 CI workflows. That completes every [BACKEND]/[SCHEMA]-tagged task in the plan.

**Notes for Antigravity:**
- Nutrition API ready for mobile Task 8.4. Search shape: `{data[],page,size,totalElements,totalPages}`; log-meal response echoes computed items incl. resolved units.
- Day-boundary zone is configurable via `avenfit.nutrition.day-zone` if you ever need per-user zones.
- Food DTO deliberately hides barcode for now (P1 scanner feature will surface it).

---

### 2026-08-24 — OpenCode/Ox Alpha — Step 7 Analytics complete

**Task:** DEVELOPMENT_PLAN.md Task 7.1 [BACKEND] — personal records, exercise history, windowed summary endpoints. (Step 6 Rest Timer is [FRONTEND]-only — no backend surface.) Tasks 7.2 [FRONTEND] untouched.

**Status:** Complete. 71 tests green + live E2E vs PostgreSQL with hand-computed expectations matching exactly.

**Changes:**

| File | Description |
|:---|:---|
| `analytics/controller/AnalyticsController.java` | GET `/api/analytics/personal-records[?exerciseId]`, `/exercise/{id}/history`, `/summary?days` |
| `analytics/service/AnalyticsService.java` | Grouping/aggregation logic; reuses PR-engine query for history |
| `analytics/dto/{PersonalRecordGroupDto,ExerciseHistoryDto,SummaryDto}.java` | Exact plan shapes; records keyed by RecordType enum (only existing types); history sets carry `{weightKg, reps, setType}` per spec |
| `workout/repository/WorkoutRepository.java` | Added analytics queries: totals projection, set-totals projection (warmup-excluded), muscle-group volume grouped by PRIMARY muscle (volume desc), completed-since finder |
| `analytics/repository/PersonalRecordRepository.java` | Added `countByUserIdAndAchievedAtGreaterThanEqual` for newPRs |
| `exercise/service/ExerciseService.java` | Promoted shared `getVisibleExerciseEntity(userId, id)` — single implementation of the 404-on-foreign rule (was triplicated); WorkoutService refactored onto it |

**Semantics implemented (documented decisions):**
1. Warmup sets: listed in history but excluded from bestSet/volume/totals/muscle breakdown — consistent with the Step 4 PR engine.
2. Muscle-group volume attributes to PRIMARY muscle only (no double counting).
3. History groups by workout START date (UTC) and sorts chronologically ascending (chart-friendly).
4. Summary window filters on COMPLETED workouts by startedAt; newPRs counts record rows achieved in-window (approximation of "PR events" for MVP).

**Tests:** `.\gradlew.bat build` → BUILD SUCCESSFUL, **71 tests green** (9 new: empty state, grouping/types/filter, per-user isolation, foreign 404s, day grouping with warmup exclusion, summary windows + validation, Brzycki cross-check via API). Fixed during testing: my own test bugs (wrong probe ownership → correct 404s; wrong MAX_VOLUME arithmetic 330<500; cross-test contamination on shared probes → per-scenario probes; exercise-test muscle-group assertion made resilient to extra seeds).

**Known Issues:** unchanged (deferred). Note: top-level summary totals now exclude warmups consistently with the muscle-group breakdown (inconsistency caught in live verification and fixed before commit).

**Next Steps:** Remaining backend phases: Step 8 Nutrition (Task 8.1–8.3 incl. V9 Indian food seed ≥200 items) and Step 9 Sync (Task 9.1), then Task 10.4 CI. Frontend steps belong to Antigravity.

**Notes for Antigravity:**
- Analytics API ready for mobile chart wiring. `records` map omits types with no data; `bestSet` may be null if a day had only bodyweight-empty sets.
- `GET /summary?days=` defaults to 30, clamped 1..365.
- Committed this phase.

---

### 2026-08-24 — OpenCode/Ox Alpha — Step 5 Routines complete

**Task:** DEVELOPMENT_PLAN.md Task 5.1 [BACKEND] — routine CRUD with nested exercises/default sets. Task 5.2 [FRONTEND] untouched.

**Status:** Complete. 62 tests green + live E2E vs PostgreSQL.

**Changes:**

| File | Description |
|:---|:---|
| `routine/repository/RoutineRepository.java` | **Fixed latent double-bag EntityGraph** (audit finding); added `findWithSetsByRoutineId` (single-bag join fetch), grouped `summarize` projection for exerciseCount, ordered bulk deletes |
| `routine/dto/RoutineDto.java` | List row `{id, name, description, exerciseCount, createdAt}` per spec |
| `routine/dto/RoutineDetailDto.java` | Detail exactly per example — sets echo `{position, setType, targetReps, targetWeightKg}` without ids; note `targetRpe` is stored but intentionally NOT echoed (spec omits it) |
| `routine/dto/CreateRoutineRequest.java` | Nested validated request shared by POST/PUT (full replace) |
| `routine/service/RoutineService.java` | CRUD, owner-only via `findByIdAndUserId` (foreign → 404), exercise-visibility checks (system or own custom), duplicate-position 400s, conflict-safe full replace: bulk delete children → flush+clear persistence context → re-fetch fresh aggregate → rebuild |
| `routine/controller/RoutineController.java` | GET list / GET id / POST 201 / PUT / DELETE 204 |

**Bug fixed during testing (predicted in audit):** naive clear()+re-add on replace caused two distinct failures — (1) `uq_routine_exercise_position` insert-before-delete ordering, and (2) after adding bulk deletes, Hibernate 6's row-count-checked orphan DELETEs threw `StaleObjectStateException` on stale managed children. Final sequence: FK-ordered JPQL deletes → `em.flush()` + `em.clear()` → re-fetch → rebuild. Regression test locks it in (`replaceSwappingPositionsOnSameExercisesDoesNotViolateUniqueConstraint`).

**Tests:** `.\gradlew.bat build` → BUILD SUCCESSFUL, **62 tests green** (12 new: nested create fidelity, empty routine allowed, unknown/invisible exercise 404, duplicate positions 400, list visibility + counts + no foreign leakage, foreign detail/delete 404, full-replace swap/shrink regression, delete everywhere, blank name/invalid setType 400). Live E2E vs PostgreSQL: create(2ex, 2+1 sets) → list count → PUT position-swap clean → start workout from replaced routine (pre-population follows new order) → log set into pre-populated slot → delete routine 204 → workout intact via FK SET NULL → routine 404.

**Known Issues:** unchanged from earlier entries (deferred per user instruction).

**Next Steps:** Step 6 Rest Timer is [FRONTEND]-only per plan (no backend surface). Next backend phase = Step 7 Analytics endpoints (Tasks 7.1). Recommend Antigravity confirm whether to proceed straight to 7 or coordinate 5.2/6 first.

**Notes for Antigravity:**
- Routine API ready for mobile Task 5.2. "Start Workout" button flow: `POST /api/workouts {name, routineId, startedAt}` — pre-population verified end-to-end.
- Routine detail deliberately does not echo `targetRpe` (your spec's set shape omits it); the column persists values if you later want them surfaced.
- Committed this phase following repo hygiene (separate feat/docs commits).

---

### 2026-08-24 — OpenCode/Ox Alpha — Step 4 Workout Logging complete (THE CORE)

**Task:** DEVELOPMENT_PLAN.md Task 4.1 [BACKEND] — full workout lifecycle: start (with routine template), add/remove exercises, log/update/delete sets with automatic PR detection, complete/cancel, history summaries. Task 4.2/4.3 [FRONTEND] untouched.

**Status:** Complete. All Task 4.1 acceptance criteria verified — 52 tests green + live end-to-end run against PostgreSQL including DB-level assertions.

**Changes:**

| File | Description |
|:---|:---|
| `workout/dto/{CreateWorkoutRequest,LogSetRequest,WorkoutDto,WorkoutSummaryDto,WorkoutExerciseDto,WorkoutSetDto,SetLogResponse}.java` | Exact plan shapes; SetLogResponse carries `prDetails {recordType, previousValue, newValue}` |
| `workout/service/WorkoutService.java` | Start (+routine pre-population of exercises & empty typed sets), auto-positioning everywhere, ownership via `findByIdAndUserId`, state guards (`IN_PROGRESS` only → 409 otherwise), duration calculation on complete, position compaction on exercise removal |
| `workout/controller/WorkoutController.java` | All 10 routes per Appendix C |
| `workout/repository/WorkoutRepository.java` | Summary aggregate JPQL (exerciseCount / completed setCount / volume / prCount in one grouped query — no N+1); detail fetch split into two purposeful queries |
| `analytics/service/PersonalRecordService.java` | PR engine: recomputes all four record types from completed sets on every set create/update/delete; upserts/deletes `personal_records`; syncs `is_pr` flags; Brzycki EST_1RM (reps ≤ 10) |
| `common/exception/ConflictException.java` + handler case | Workout state violations → 409 |

**PR semantics implemented (decisions documented for review):**
1. **Warmup sets never count** toward records or PR badges.
2. All four record types tracked truthfully in `personal_records`; when a set beats several at once, `prDetails` reports by priority MAX_WEIGHT → EST_1RM → MAX_VOLUME → MAX_REPS.
3. `is_pr` badge = holder of a current best for MAX_WEIGHT / MAX_VOLUME / EST_1RM. **MAX_REPS alone never badges a set** (otherwise every new rep count at any weight would celebrate). Ties badge all holders.
4. Update/delete re-evaluation is a full recompute — records can legitimately decrease and flags migrate to the new holder.

**Bugs found & fixed during testing:**
1. `MultipleBagFetchException`: the detail `@EntityGraph` fetched two `List` bags simultaneously. Replaced with two purposeful queries (workout plain + exercises-with-sets join-fetch).
2. Latent same-class issue noted: `RoutineRepository` has an identical double-bag `@EntityGraph` — unused so far, MUST be fixed before Step 5 uses it.
3. Test-side: probe exercises were owned by the wrong user (correctly 404'd), and tie-badge semantics corrected expectations.

**Tests:** `.\gradlew.bat build` → BUILD SUCCESSFUL, **52 tests green** (19 new: lifecycle, PR detection matrix incl. warmup exclusion & Brzycki range guard, re-evaluation after update/delete, state locks, ownership, summary aggregates, position compaction). Live E2E vs PostgreSQL: warmup no-PR → 100×5 first PR → 110×5 beats it (prev=100.00/new=110) → update 110→95 migrated flag to the 100 set → complete (duration_seconds=1800 exact, verified via psql) → post-complete mutation 409 → history row correct (1 exercise / 3 sets / 1575 kg / 1 PR).

**Known Issues:** unchanged from earlier entries (deferred per user instruction).

**Next Steps:** Step 5 Routines backend (Task 5.1) — routine CRUD with nested exercises/sets; fix the RoutineRepository EntityGraph before wiring "start workout from routine" through the API (template path already proven inside start()).

**Notes for Antigravity:**
- The whole Task 4.1 API surface mobile needs for ActiveWorkoutScreen is live. `POST /api/workouts/{id}/exercises/{weId}/sets` response includes `prDetails` exactly as your spec example (null when not a PR).
- Detail DTO intentionally omits `durationSeconds` (your example omits it); it's in the history summary DTO where your example shows it.
- One active-workout-per-user is NOT yet enforced server-side (plan doesn't require it); say the word if you want it as an invariant.
- Still nothing committed on my side.

---

### 2026-08-24 — OpenCode/Ox Alpha — Step 3 Exercise Library complete

**Task:** DEVELOPMENT_PLAN.md Task 3.1 [BACKEND] — exercise browse/search/filter, custom exercise CRUD, muscle-groups endpoint. Task 3.2 [FRONTEND] untouched.

**Status:** Complete. All Task 3.1 acceptance criteria verified via 22 integration/unit assertions plus a live end-to-end run against seeded PostgreSQL.

**Changes:**

| File | Description |
|:---|:---|
| `exercise/dto/ExerciseDto.java` | Exact plan shape incl. `muscleGroups:[{name, role}]`, primaries first |
| `exercise/dto/CreateExerciseRequest.java` | Validated; shared by POST + PUT |
| `exercise/dto/MuscleGroupDto.java` | `{id, name, displayOrder}` |
| `exercise/repository/ExerciseRepository.java` | Now extends `JpaSpecificationExecutor`; `@EntityGraph` overrides of `findAll(Specification, …)` prevent N+1 on DTO mapping |
| `exercise/service/ExerciseService.java` | Dynamic Specification filters (visibility, search ignore-case, category, muscle-group EXISTS subquery), ownership enforcement, muscle-link **in-place sync** |
| `exercise/controller/ExerciseController.java` | GET list (paged envelope `{data,page,size,totalElements,totalPages}`), GET id, POST → 201, PUT, DELETE → 204 |
| `exercise/controller/MuscleGroupController.java` | `GET /api/muscle-groups` ordered by display_order (file added — not in plan tree) |
| `common/exception/GlobalExceptionHandler.java` | Added: malformed body → 400 `VALIDATION_ERROR`; `DataIntegrityViolationException` → 409 `CONFLICT` |
| `src/test/.../ExerciseApiIntegrationTest.java` | New: full matrix — visibility (excludes other users' customs), search, category+muscle filters, pagination metadata, invalid category/size 400s, DTO shape, create/update/delete + all 403 paths, unknown ids 404, overlap/no-primary 400s, ordered muscle groups |

**Visibility rule implemented:** list/get return system exercises + the caller's own customs only; another user's custom returns **404** (no existence leak), while modify/delete attempts on system or foreign exercises return **403** per plan.

**Bug found & fixed (important):**
Updating an exercise's muscle groups originally did `collection.clear()` + re-add. Hibernate flushes orphan INSERTs before DELETEs non-deterministically → `uq_exercise_muscle` duplicate-key 409 on PostgreSQL (H2 tests had not caught it). Replaced with deterministic in-place sync (`update roles / remove dropped / insert new`) + regression test `updateSwappingRolesOnSameMuscleGroupsDoesNotViolateUniqueConstraint`. Live-verified all four update shapes (role-swap, all-new-keys, mixed keep+add, no-op) return 200 with exactly-correct DB rows.

**Tests:**
- `.\gradlew.bat build` → BUILD SUCCESSFUL, **33 tests green** (5 JWT + 7 auth-flow + 21 exercise)
- Live bootRun E2E vs PostgreSQL 16.4 (seeded): paged list total=55/pages=11; search "bench"→5; BODYWEIGHT+Chest→Chest Dip, Push-Up; muscle-groups=14 Chest@1…Lower Back@14; custom create/get/update(×3 shapes)/delete all correct; system-exercise PUT & DELETE → 403; post-delete GET → 404; DB link-row count verified via psql

**Known Issues:** unchanged from earlier entries (deferred per user instruction).

**Next Steps:** Step 4 Workout Logging backend (Task 4.1) — the core feature: start/add-exercise/log-set endpoints with automatic PR detection (Brzycki for EST_1RM), workout completion/cancel, history pagination.

**Notes for Antigravity:**
- Exercise API is ready for mobile Task 3.2 wiring. Note `GET /api/exercises` returns the bare paged envelope (no `message` field) exactly as your example specifies.
- Custom-exercise PUT is full-replace semantics (same body as POST); at least one primary muscle group is enforced.
- Deleting a custom exercise that's referenced by workouts/routines returns **409 CONFLICT** rather than cascading.
- Still nothing committed on my side.

---

### 2026-08-24 — OpenCode/Ox Alpha — Step 2 Authentication complete

**Task:** DEVELOPMENT_PLAN.md Step 2 — Tasks 2.1 (JWT infrastructure), 2.2 (auth endpoints), 2.3 (user profile). Backend only; Task 2.4 [FRONTEND] untouched.

**Status:** Complete. All Task 2.1–2.3 acceptance criteria verified, including a live end-to-end run against PostgreSQL.

**Changes:**

| File | Description |
|:---|:---|
| `common/dto/ApiResponse.java`, `PagedResponse.java` | Response envelopes per plan §1 |
| `common/exception/{ErrorResponse,GlobalExceptionHandler,ResourceNotFoundException}.java` | Centralized error handling → `{error, message, details}` |
| `common/config/CorsConfig.java` | Permissive dev CORS (no credentials — JWT header auth) |
| `auth/config/JwtProperties.java` | `@ConfigurationProperties(jwt)` record |
| `auth/config/SecurityConfig.java` | Full stateless chain: CSRF off, `/api/health` + phone-OTP/google/refresh public, everything else under `/api/**` authenticated, JWT filter registered, JSON 401 entry point |
| `auth/service/JwtService.java` | jjwt 0.12.x HS256; access (15m) + refresh (30d) tokens with `jti` claim |
| `auth/filter/JwtAuthenticationFilter.java` | Bearer extraction → user lookup → SecurityContext principal = `User` entity |
| `auth/service/OtpService.java` | MVP placeholder: static OTP `123456`, logged not sent — swap before production |
| `auth/service/GoogleTokenService.java` | Verifies ID tokens via Google tokeninfo endpoint (RestClient) |
| `auth/service/AuthService.java` | OTP verify (find-or-create "Gym User"), Google sign-in (links email-matched accounts), refresh rotation (old token invalidated), ownership-checked logout |
| `auth/controller/AuthController.java` | The five endpoints per Task 2.2 |
| `user/{controller/UserController,service/UserService,dto/UserProfileDto,dto/UpdateProfileRequest}.java` | GET/PUT `/api/users/me`, partial updates |
| `auth/dto/{OtpRequest,GoogleAuthRequest,RefreshTokenRequest,AuthResponse}.java` | Validated request/response DTOs |
| `src/test/.../JwtServiceTest.java` | Unit: round-trips, tamper, garbage, expiry |
| `src/test/.../AuthFlowIntegrationTest.java` | MockMvc full flow on H2 |

**Tests:**
- `.\gradlew.bat build` → BUILD SUCCESSFUL, **11 tests green** (5 JWT unit + 6 integration)
- Live bootRun E2E vs PostgreSQL 16.4 (all passed): request-otp → verify-otp (auto-created user) → GET me → PUT me → refresh rotation → old-refresh 401 → logout → post-logout refresh 401 → unauthenticated /me 401

**Fixes made during testing (worth knowing):**
1. JWTs lacked a unique claim — two logins for the same user within one millisecond produced byte-identical tokens and violated the unique index on `refresh_tokens.token`. Fixed by adding a `jti` claim.
2. H2 treats `value` (`personal_records`) as reserved — Hibernate silently skipped creating that table in tests. Fixed test-only via `hibernate.auto_quote_keyword: true`. PostgreSQL/Flyway path unaffected.

**Deviations from plan:**
- Added `GoogleTokenService` + `RefreshTokenRequest`/`ErrorResponse` files not in the structure tree (needed for the specified behavior).
- Did NOT create `LoginRequest` from the tree — no endpoint in the API summary uses it.
- `AuthResponse.user` intentionally compact ({id, phoneNumber, displayName, unitPreference}) to match the Task 2.2 response example exactly.

**Known Issues:** unchanged from previous entry (Android SDK absent; portable Postgres needs manual start after reboot) — deferred per user instruction.

**Next Steps:** Step 3 Exercise Library backend (Task 3.1): exercise + muscle-group CRUD/search/filter endpoints per Appendix C.

**Notes for Antigravity:**
- Auth is fully wired — mobile Task 2.4 can build against it now. Emulator base URL: `http://10.0.2.2:8080`.
- OTP is static `123456` in this phase by design; the response envelope shapes match the plan examples exactly.
- Nothing committed yet on my side.

---

### 2026-08-24 — OpenCode/Ox Alpha — Step 0 (Backend) + Step 1 complete

**Task:** Execute DEVELOPMENT_PLAN.md Step 0 (Tasks 0.1, 0.2, backend half of 0.4) and Step 1 (Tasks 1.1–1.3).

**Status:** Complete. All Step 0 + Step 1 acceptance criteria verified.

**Changes:**

| File/Dir | Action | Description |
|:---|:---|:---|
| `server/` | Deleted | My earlier non-conformant Maven/Boot-4.1 scaffold; replaced by spec layout below |
| `backend/build.gradle.kts` | Created | Boot 3.3.5, Java 21, full spec dependency set (web/jpa/security/validation/postgres/flyway/jjwt/devtools/lombok/h2-test/security-test), Gradle KTS |
| `backend/settings.gradle.kts` | Created | `aven-fit-backend` |
| `backend/gradle/wrapper/*`, `gradlew(.bat)` | Created | Gradle 8.10.2 wrapper |
| `backend/src/main/resources/application.yml` | Created | Exactly per plan §Task 0.1 |
| `backend/src/main/resources/application-dev.yml` | Created | Exactly per plan §Task 0.1 |
| `backend/src/test/resources/application-test.yml` | Added | H2 profile for tests (`flyway.enabled=false`, create-drop) |
| `backend/src/main/java/com/avenfit/AvenFitApplication.java` | Created | Main class |
| `common/entity/CreatableEntity.java` | Added | id+createdAt base — see Deviations #1 |
| `common/entity/BaseEntity.java` | Created | Per plan, extends CreatableEntity |
| `common/controller/HealthController.java` | Created | `GET /api/health` → `{status, timestamp}` per Task 0.4 |
| `auth/config/SecurityConfig.java` | Created | Interim stateless config permitting `/api/health`; superseded by Task 2.1 |
| `auth/entity/{User,RefreshToken,UnitPreference,Gender}` | Created | Task 1.2 |
| `exercise/entity/{Exercise,MuscleGroup,ExerciseMuscleGroup,ExerciseCategory,Equipment,MuscleRole}` | Created | Task 1.2 |
| `workout/entity/{Workout,WorkoutExercise,WorkoutSet,WorkoutStatus,SetType}` | Created | Task 1.2 |
| `routine/entity/{Routine,RoutineExercise,RoutineSet}` | Created | Task 1.2 |
| `nutrition/entity/{FoodItem,NutritionEntry,NutritionEntryItem,MealType}` | Created | Task 1.2 |
| `analytics/entity/{PersonalRecord,BodyMeasurement,RecordType}` | Created | Task 1.2 |
| `*/repository/*.java` (9 repos) | Created | Task 1.3 incl. all custom queries from plan |
| `db/migration/V1..V8__*.sql` | Created | Verbatim from plan Appendix/§Task 1.1; V8 seeds **55** exercises (≥50 required), 105 muscle links |
| `scripts/setup-dev-db.sql`, `scripts/README.md` | Created | Task 0.2 |

**Tests:**
- `.\gradlew.bat build` → BUILD SUCCESSFUL (compile + context-load test on H2 test profile)
- `bootRun` against PostgreSQL 16.4 → Flyway applied **8/8 migrations**; `ddl-auto: validate` passed with all 16 entities
- DB counts verified via psql: muscle_groups=14, exercises=55, exercise_muscle_groups=105, 16 domain tables + flyway history
- `GET /api/health` → 200 `{"status":"UP","timestamp":"..."}`

**Environment note:** Installed portable PostgreSQL 16.4 (EDB binaries) at `%LOCALAPPDATA%\PostgreSQLDev\16`, running detached on port 5432, superuser password `postgres`. Started with `pg_ctl -D %LOCALAPPDATA%\PostgreSQLDev\16\data start`. It is NOT a Windows service — it must be started manually after reboot.

**Deviations from plan (flagging for review):**
1. Added `CreatableEntity` (id + createdAt only). Four tables in the plan's own schema have no `updated_at` (`refresh_tokens`, `exercise_muscle_groups`, `nutrition_entry_items`, `personal_records`), so those entities extend it instead of BaseEntity. Required for `ddl-auto: validate` to pass.
2. Plan asked for Boot "3.3.x" but start.spring.io no longer serves 3.x; build files are hand-pinned to **3.3.5** as specified.
3. Plan listed both `List<...>` and `Optional<...> findByUserIdAndStatus(...)` — impossible overload; implemented `findFirstByUserIdAndStatus` (+ paginated variants).
4. Removed `@OrderBy("muscleGroup.displayOrder")` on Exercise.muscleGroups (crashes Hibernate 6 metadata init); display-order sorting will be done in the DTO/service layer.
5. `application-dev.yml` contains dev-only DB credentials verbatim from the plan — acceptable local defaults, but production config must use env vars (noted for Task 10 / release prep).

**Known Issues:**
- No Android SDK on this machine → `mobile/` cannot be built to APK here yet (Antigravity's domain).
- `mobile/` exists (RN 0.87 bare CLI, TS; lint/tsc/jest green) but Task 0.3 post-init steps (path aliases, src/ structure, nav+sqlite deps) are not done — left for [FRONTEND] owner.

**Next Steps:**
- Step 2 Authentication (Tasks 2.1–2.3 backend): JwtService, filter, full SecurityConfig, OTP flow, user profile endpoints.
- Then Step 3 exercise endpoints.

**Notes for Antigravity:**
- Step 0 + Step 1 backend are done and verified end-to-end against a live Postgres — please review deviations above, especially #1 and #4.
- `GET /api/health` is live if you want to wire the temporary mobile health-check screen (use `10.0.2.2:8080` from emulator).
- Nothing has been committed by me; working tree contains my changes plus your committed docs. Suggest committing backend once reviewed.

---

### 2026-08-24 — Antigravity

**Task:** Project initialization and technical architecture alignment

**Changes:**

| File | Action | Description |
|:---|:---|:---|
| `gym_tracker_analysis.md` | Modified | Revised technical architecture from Flutter/Supabase to React Native/Spring Boot stack |
| `AGENTS.md` | Created | Multi-agent coordination protocol |
| `DEVELOPMENT_LOG.md` | Created | This file — development log |
| `PRODUCT_ROADMAP.md` | Created | Structured product roadmap extracted from analysis |

**Key Decisions:**

1. **Tech stack locked:** React Native + TypeScript, SQLite, Spring Boot + Java, PostgreSQL, REST APIs
2. **Architecture:** Offline-first, modular monolith backend, local SQLite as source of truth on device
3. **Rejected technologies:** Flutter, Dart, Supabase, Isar, Drift — replaced by agreed stack
4. **Multi-agent workflow:** Antigravity (product/architecture/frontend/review) + OpenCode (implementation/backend)

**Status:** Project foundation complete. No application code exists yet.

**Tests:** N/A — documentation only

**Known Issues:** None

**Next Steps:**
- Define project directory structure
- Scaffold React Native (TypeScript) project for Android
- Scaffold Spring Boot project
- Design initial database schema (exercises, workouts, sets, routines, users)
- Begin MVP P0 implementation

**Notes for OpenCode/Ox Alpha:**
- Read AGENTS.md before starting any work
- The tech stack is locked — do not introduce Flutter/Supabase
- Check this log and PRODUCT_ROADMAP.md for current priorities
- `gym_tracker_analysis.md` contains the full product vision and competitive analysis
- We are on the `dev` branch

---

## Decision Register

Significant architectural and product decisions are recorded here for reference.

| # | Date | Decision | Rationale | Decided By |
|:---:|:---|:---|:---|:---|
| 1 | 2026-08-24 | React Native + TypeScript for mobile | Cross-platform foundation, TypeScript safety, Android-first focus | User |
| 2 | 2026-08-24 | Spring Boot + Java for backend | Production-grade, Spring Security, Spring Data JPA, Hibernate | User |
| 3 | 2026-08-24 | PostgreSQL for server DB | Relational modelling, constraints, transactions, migrations | User |
| 4 | 2026-08-24 | SQLite for mobile local DB | Offline-first persistence, mature Android support | User |
| 5 | 2026-08-24 | REST APIs (not GraphQL) | Simpler, sufficient for current requirements | User |
| 6 | 2026-08-24 | Modular monolith (not microservices) | Appropriate for small team, early-stage product | User |
| 7 | 2026-08-24 | Android-first (not cross-platform MVP) | >92% India market share, budget Android is primary target | User |
| 8 | 2026-08-24 | Offline-first architecture | Indian gyms have unreliable connectivity; core logging must work offline | User + Analysis |

---

### 2026-08-25 � Antigravity (Phase 1 Frontend)

**Task:** Phase 1 Design Foundations & Technical Setup (Task 0.3 & 1.4)
**Status:** Complete

**Changes:**
- Initialized deep dark "Aven Fit" premium theme (colors.ts, 	ypography.ts, spacing.ts) emphasizing tabular-num data typography and high-contrast semantics.
- Created precise directory architecture under mobile/src/.
- Configured TS aliases @/* and Babel module resolution.
- Initialized highly optimized op-sqlite engine (C++ JSI).
- Drafted local SQLite schema mimicking the 16 Postgres tables + Sync Columns + sync_queue.
- Re-wrote App.tsx to handle DB setup asynchronously while presenting a crisp loading visual.

**Next Steps:**
- Move to Phase 2: Navigation architecture & the Auth Shell (Task 2.4).

---

### 2026-08-25 � Antigravity (Phase 2 Frontend)

**Task:** Phase 2 Navigation Shell & Auth (Task 2.4)
**Status:** Complete

**Changes:**
- Built uthStore.ts using Zustand to manage access/refresh tokens in AsyncStorage.
- Built a smart piClient using fetch that automatically handles Bearer token injection and automatic token-refresh rotation on 401s.
- Built LoginScreen and OtpVerificationScreen emphasizing the premium Aven Fit typography and layout (Phase 2).
- Designed foundational premium UI primitives: Button (with strict radii and haptic feedback) and Input (with precise padding and state-aware borders).
- Integrated eact-navigation:
  - RootNavigator seamlessly controls the switch between Auth and Main flows without visual stutter.
  - MainTabNavigator wired up using lucide-react-native icons for the 5 core tabs (Today, Train, Nutrition, Progress, Profile).
- Zero typescript errors.

**Next Steps:**
- Move to Phase 3: The "Today/Home" experience.
