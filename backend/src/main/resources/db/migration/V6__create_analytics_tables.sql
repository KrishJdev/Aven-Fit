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
