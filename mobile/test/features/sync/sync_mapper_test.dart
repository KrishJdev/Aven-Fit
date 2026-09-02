import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/routine/data/routine_local_source.dart';
import 'package:aven_fit/features/sync/data/sync_dto_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncDtoMapper Enum Mappings (ISSUE-11)', () {
    test('workout status maps bidirectionally with fallback', () {
      expect(SyncDtoMapper.workoutStatusToBackend('active'), 'IN_PROGRESS');
      expect(SyncDtoMapper.workoutStatusToBackend('completed'), 'COMPLETED');
      expect(SyncDtoMapper.workoutStatusToBackend('discarded'), 'CANCELLED');
      expect(SyncDtoMapper.workoutStatusToBackend('unknown'), 'IN_PROGRESS');

      expect(SyncDtoMapper.workoutStatusToLocal('IN_PROGRESS'), 'active');
      expect(SyncDtoMapper.workoutStatusToLocal('COMPLETED'), 'completed');
      expect(SyncDtoMapper.workoutStatusToLocal('CANCELLED'), 'discarded');
      expect(SyncDtoMapper.workoutStatusToLocal('UNKNOWN'), 'active');
    });

    test('set type maps bidirectionally with dropSet <-> DROP parity', () {
      expect(SyncDtoMapper.setTypeToBackend('normal'), 'NORMAL');
      expect(SyncDtoMapper.setTypeToBackend('warmup'), 'WARMUP');
      expect(SyncDtoMapper.setTypeToBackend('dropSet'), 'DROP');
      expect(SyncDtoMapper.setTypeToBackend('failure'), 'FAILURE');
      expect(SyncDtoMapper.setTypeToBackend('other'), 'NORMAL');

      expect(SyncDtoMapper.setTypeToLocal('NORMAL'), 'normal');
      expect(SyncDtoMapper.setTypeToLocal('WARMUP'), 'warmup');
      expect(SyncDtoMapper.setTypeToLocal('DROP'), 'dropSet');
      expect(SyncDtoMapper.setTypeToLocal('FAILURE'), 'failure');
      expect(SyncDtoMapper.setTypeToLocal('OTHER'), 'normal');
    });
  });

  group('SyncDtoMapper Push Operations (ISSUE-11)', () {
    test('workoutSessionToOperation maps fields to backend schema', () {
      final now = DateTime.utc(2026, 9, 3, 2, 0);
      final row = WorkoutSessionRow(
        id: 'ws_123',
        name: 'Morning Lift',
        startedAt: now,
        completedAt: now.add(const Duration(minutes: 45)),
        durationSeconds: 2700,
        status: 'completed',
        isPaused: false,
        pausedDurationSeconds: 0,
        notes: 'Good session',
        createdAt: now,
        updatedAt: now,
      );

      final op = SyncDtoMapper.workoutSessionToOperation(row);
      expect(op.entityType, 'workout');
      expect(op.entityId, 'ws_123');
      expect(op.operation, 'CREATE');
      expect(op.data!['name'], 'Morning Lift');
      expect(op.data!['status'], 'COMPLETED');
      expect(op.data!['startedAt'], now.toIso8601String());
      expect(op.data!['completedAt'], now.add(const Duration(minutes: 45)).toIso8601String());
      expect(op.data!['durationSeconds'], 2700);
      expect(op.data!['notes'], 'Good session');
    });

    test('sessionExerciseToOperation maps orderIndex to position', () {
      final now = DateTime.utc(2026, 9, 3, 2, 5);
      final row = SessionExerciseRow(
        id: 'se_456',
        sessionId: 'ws_123',
        exerciseId: 'ex_bench',
        orderIndex: 2,
        restSeconds: 120,
        notes: 'Form cue',
        createdAt: now,
        updatedAt: now,
      );

      final op = SyncDtoMapper.sessionExerciseToOperation(row);
      expect(op.entityType, 'workout_exercise');
      expect(op.entityId, 'se_456');
      expect(op.data!['workoutId'], 'ws_123');
      expect(op.data!['exerciseId'], 'ex_bench');
      expect(op.data!['position'], 2);
      expect(op.data!['restSeconds'], 120);
      expect(op.data!['notes'], 'Form cue');
    });

    test('workoutSetToOperation maps setNumber to position and dropSet to DROP', () {
      final now = DateTime.utc(2026, 9, 3, 2, 10);
      final row = WorkoutSetRow(
        id: 'set_789',
        sessionId: 'ws_123',
        sessionExerciseId: 'se_456',
        setNumber: 3,
        weightKg: 85.0,
        reps: 6,
        setType: 'dropSet',
        isCompleted: true,
        isPr: false,
        rpe: 8.5,
        completedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      final op = SyncDtoMapper.workoutSetToOperation(row);
      expect(op.entityType, 'workout_set');
      expect(op.entityId, 'set_789');
      expect(op.data!['workoutExerciseId'], 'se_456');
      expect(op.data!['position'], 3);
      expect(op.data!['setType'], 'DROP');
      expect(op.data!['weightKg'], 85.0);
      expect(op.data!['reps'], 6);
      expect(op.data!['rpe'], 8.5);
      expect(op.data!['isCompleted'], isTrue);
    });

    test('routineToOperation maps nested exercises and target sets', () {
      final now = DateTime.utc(2026, 9, 3, 1, 0);
      final routine = RoutineWithExercises(
        routine: RoutineRow(
          id: 'r_push',
          name: 'Push Day',
          description: 'Chest and triceps',
          createdAt: now,
          updatedAt: now,
        ),
        exercises: [
          RoutineExerciseWithSets(
            routineExercise: RoutineExerciseRow(
              id: 're_1',
              routineId: 'r_push',
              exerciseId: 'ex_bench',
              orderIndex: 0,
              restSeconds: 90,
              createdAt: now,
              updatedAt: now,
            ),
            exercise: null,
            sets: [
              RoutineSetRow(
                id: 'rs_1',
                routineExerciseId: 're_1',
                position: 1,
                setType: 'warmup',
                targetReps: 10,
                targetWeightKg: 40.0,
                createdAt: now,
                updatedAt: now,
              ),
              RoutineSetRow(
                id: 'rs_2',
                routineExerciseId: 're_1',
                position: 2,
                setType: 'normal',
                targetReps: 8,
                targetWeightKg: 80.0,
                createdAt: now,
                updatedAt: now,
              ),
            ],
          ),
        ],
      );

      final op = SyncDtoMapper.routineToOperation(routine);
      expect(op.entityType, 'routine');
      expect(op.entityId, 'r_push');
      expect(op.data!['name'], 'Push Day');
      final exercises = op.data!['exercises'] as List;
      expect(exercises, hasLength(1));
      expect(exercises[0]['exerciseId'], 'ex_bench');
      expect(exercises[0]['position'], 0);
      final sets = exercises[0]['sets'] as List;
      expect(sets, hasLength(2));
      expect(sets[0]['setType'], 'WARMUP');
      expect(sets[0]['targetWeightKg'], 40.0);
      expect(sets[1]['setType'], 'NORMAL');
      expect(sets[1]['targetReps'], 8);
    });
  });

  group('SyncDtoMapper Pull Conversions (ISSUE-11)', () {
    test('workoutDtoToSessionCompanion parses backend JSON cleanly', () {
      final json = {
        'id': 'ws_remote_1',
        'name': 'Cloud Workout',
        'status': 'COMPLETED',
        'startedAt': '2026-09-02T10:00:00Z',
        'completedAt': '2026-09-02T11:00:00Z',
        'durationSeconds': 3600,
        'notes': 'Synced from cloud',
      };

      final companion = SyncDtoMapper.workoutDtoToSessionCompanion(json, userId: 'usr_1');
      expect(companion.id.value, 'ws_remote_1');
      expect(companion.userId.value, 'usr_1');
      expect(companion.name.value, 'Cloud Workout');
      expect(companion.status.value, 'completed');
      expect(companion.durationSeconds.value, 3600);
      expect(companion.notes.value, 'Synced from cloud');
    });

    test('routineDtoToCompanions parses routine with nested exercises and sets', () {
      final json = {
        'id': 'r_cloud_1',
        'name': 'Legs',
        'description': 'Quad focused',
        'exercises': [
          {
            'id': 're_cloud_1',
            'exerciseId': 'ex_squat',
            'position': 1,
            'restSeconds': 120,
            'sets': [
              {
                'position': 1,
                'setType': 'NORMAL',
                'targetReps': 5,
                'targetWeightKg': 100,
              }
            ],
          }
        ],
      };

      final tuple = SyncDtoMapper.routineDtoToCompanions(json, userId: 'usr_1');
      expect(tuple.routine.id.value, 'r_cloud_1');
      expect(tuple.routine.name.value, 'Legs');
      expect(tuple.exercises, hasLength(1));
      expect(tuple.exercises[0].exerciseId.value, 'ex_squat');
      expect(tuple.exercises[0].orderIndex.value, 1);
      expect(tuple.sets, hasLength(1));
      expect(tuple.sets[0].setType.value, 'normal');
      expect(tuple.sets[0].targetWeightKg.value, 100.0);
      expect(tuple.sets[0].targetReps.value, 5);
    });
  });
}
