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
