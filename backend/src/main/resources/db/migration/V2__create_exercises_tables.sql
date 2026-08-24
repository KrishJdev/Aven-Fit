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
