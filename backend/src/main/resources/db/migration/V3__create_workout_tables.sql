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
