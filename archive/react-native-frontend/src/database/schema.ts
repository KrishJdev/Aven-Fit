import { db } from './database';

export const SYNC_COLUMNS = `
  sync_status TEXT DEFAULT 'PENDING', -- 'PENDING', 'SYNCED', 'CONFLICT', 'ERROR'
  last_synced_at TEXT,
  server_updated_at TEXT, -- The timestamp the server has for this row (for conflict resolution)
  is_deleted INTEGER DEFAULT 0 -- Soft delete marker for local rows before syncing deletion
`;

const INITIALIZATION_QUERIES = [
  // 1. User Profile (Singleton on device)
  `CREATE TABLE IF NOT EXISTS user_profile (
    id TEXT PRIMARY KEY,
    phone_number TEXT,
    display_name TEXT,
    gender TEXT,
    height_cm REAL,
    date_of_birth TEXT,
    unit_preference TEXT,
    created_at TEXT,
    updated_at TEXT,
    ${SYNC_COLUMNS}
  );`,

  // 2. Muscle Groups
  `CREATE TABLE IF NOT EXISTS muscle_groups (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    display_order INTEGER NOT NULL,
    created_at TEXT,
    updated_at TEXT,
    ${SYNC_COLUMNS}
  );`,

  // 3. Exercises
  `CREATE TABLE IF NOT EXISTS exercises (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL,
    equipment TEXT NOT NULL,
    is_custom INTEGER DEFAULT 0,
    created_by TEXT, -- UUID of user if custom
    created_at TEXT,
    updated_at TEXT,
    ${SYNC_COLUMNS}
  );`,

  // 4. Exercise Muscle Groups
  `CREATE TABLE IF NOT EXISTS exercise_muscle_groups (
    exercise_id TEXT NOT NULL,
    muscle_group_id TEXT NOT NULL,
    role TEXT NOT NULL,
    PRIMARY KEY (exercise_id, muscle_group_id),
    FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE,
    FOREIGN KEY (muscle_group_id) REFERENCES muscle_groups(id) ON DELETE CASCADE
  );`,

  // 5. Workouts
  `CREATE TABLE IF NOT EXISTS workouts (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    notes TEXT,
    started_at TEXT NOT NULL,
    completed_at TEXT,
    duration_seconds INTEGER,
    status TEXT NOT NULL, -- IN_PROGRESS, COMPLETED, CANCELLED
    routine_id TEXT, -- nullable
    created_at TEXT,
    updated_at TEXT,
    ${SYNC_COLUMNS}
  );`,

  // 6. Workout Exercises
  `CREATE TABLE IF NOT EXISTS workout_exercises (
    id TEXT PRIMARY KEY,
    workout_id TEXT NOT NULL,
    exercise_id TEXT NOT NULL,
    position INTEGER NOT NULL,
    notes TEXT,
    created_at TEXT,
    updated_at TEXT,
    ${SYNC_COLUMNS},
    FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
  );`,

  // 7. Workout Sets
  `CREATE TABLE IF NOT EXISTS workout_sets (
    id TEXT PRIMARY KEY,
    workout_exercise_id TEXT NOT NULL,
    position INTEGER NOT NULL,
    set_type TEXT NOT NULL, -- NORMAL, WARMUP, DROP, FAILURE
    weight_kg REAL NOT NULL,
    reps INTEGER NOT NULL,
    rpe REAL,
    is_completed INTEGER DEFAULT 0,
    is_pr INTEGER DEFAULT 0,
    created_at TEXT,
    updated_at TEXT,
    ${SYNC_COLUMNS},
    FOREIGN KEY (workout_exercise_id) REFERENCES workout_exercises(id) ON DELETE CASCADE
  );`,

  // 8. Routines
  `CREATE TABLE IF NOT EXISTS routines (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    created_at TEXT,
    updated_at TEXT,
    ${SYNC_COLUMNS}
  );`,

  // 9. Routine Exercises
  `CREATE TABLE IF NOT EXISTS routine_exercises (
    id TEXT PRIMARY KEY,
    routine_id TEXT NOT NULL,
    exercise_id TEXT NOT NULL,
    position INTEGER NOT NULL,
    rest_timer_seconds INTEGER,
    created_at TEXT,
    updated_at TEXT,
    ${SYNC_COLUMNS},
    FOREIGN KEY (routine_id) REFERENCES routines(id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
  );`,

  // 10. Routine Sets
  `CREATE TABLE IF NOT EXISTS routine_sets (
    id TEXT PRIMARY KEY,
    routine_exercise_id TEXT NOT NULL,
    position INTEGER NOT NULL,
    set_type TEXT NOT NULL,
    target_weight_kg REAL,
    target_reps INTEGER,
    target_rpe REAL,
    created_at TEXT,
    updated_at TEXT,
    ${SYNC_COLUMNS},
    FOREIGN KEY (routine_exercise_id) REFERENCES routine_exercises(id) ON DELETE CASCADE
  );`,

  // 11. Sync Queue (Records order of operations to push)
  `CREATE TABLE IF NOT EXISTS sync_queue (
    id TEXT PRIMARY KEY,
    entity_name TEXT NOT NULL, -- e.g., 'workout_set'
    entity_id TEXT NOT NULL,
    operation TEXT NOT NULL, -- 'CREATE', 'UPDATE', 'DELETE'
    timestamp TEXT NOT NULL, -- When the local change occurred (ISO 8601)
    payload TEXT, -- JSON snapshot of the local row for the push operation
    status TEXT DEFAULT 'PENDING',
    retry_count INTEGER DEFAULT 0,
    last_error TEXT
  );`,
  
  // Create indices for fast lookup
  `CREATE INDEX IF NOT EXISTS idx_sync_queue_status ON sync_queue(status);`,
  `CREATE INDEX IF NOT EXISTS idx_workouts_status ON workouts(status);`,
  `CREATE INDEX IF NOT EXISTS idx_workout_exercises_workout ON workout_exercises(workout_id);`,
  `CREATE INDEX IF NOT EXISTS idx_workout_sets_we ON workout_sets(workout_exercise_id);`
];

export const initDatabase = async () => {
  try {
    for (const query of INITIALIZATION_QUERIES) {
      await db.execute(query);
    }
    try {
      await db.execute('ALTER TABLE workouts ADD COLUMN last_resumed_at TEXT');
    } catch (e) {
      // Column might already exist
    }
    console.log('📦 SQLite Schema initialized successfully');
  } catch (error) {
    console.error('❌ Error initializing SQLite schema:', error);
    throw error;
  }
};
