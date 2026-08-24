-- QA Phase 4 finding: workout_sets lacked the positional uniqueness that
-- every other ordered child table has (workout_exercises, routine_exercises,
-- exercise_muscle_groups). Concurrent set logging could silently produce
-- duplicate positions. Safe to add as long as existing rows are distinct;
-- positions were always auto-assigned MAX+1, so collisions cannot exist.
ALTER TABLE workout_sets
    ADD CONSTRAINT uq_workout_set_position UNIQUE (workout_exercise_id, position);
