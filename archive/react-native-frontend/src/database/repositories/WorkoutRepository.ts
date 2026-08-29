import { BaseRepository, BaseModel } from './BaseRepository';
import { db } from '../database';

export interface WorkoutModel extends BaseModel {
  routine_id?: string;
  name: string;
  started_at: string;
  ended_at?: string;
  status: 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';
  notes?: string;
}

class WorkoutRepositoryClass extends BaseRepository<WorkoutModel> {
  constructor() {
    super('workouts');
  }

  async startWorkout(name: string, routineId?: string): Promise<WorkoutModel> {
    const now = new Date().toISOString();
    const workout: WorkoutModel = {
      id: this.generateId(),
      routine_id: routineId,
      name,
      started_at: now,
      status: 'IN_PROGRESS',
      created_at: now,
      updated_at: now,
      sync_status: 'PENDING',
      is_deleted: 0
    };

    await db.execute(
      `INSERT INTO workouts (id, routine_id, name, started_at, status, created_at, updated_at, sync_status, is_deleted)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        workout.id, 
        workout.routine_id || null, 
        workout.name, 
        workout.started_at, 
        workout.status, 
        workout.created_at, 
        workout.updated_at, 
        workout.sync_status, 
        workout.is_deleted
      ]
    );

    await this.queueSyncOperation(workout.id, 'INSERT');
    return workout;
  }

  async completeWorkout(id: string): Promise<void> {
    const now = new Date().toISOString();
    await db.execute(
      `UPDATE workouts SET status = 'COMPLETED', ended_at = ?, updated_at = ?, sync_status = 'PENDING' WHERE id = ?`,
      [now, now, id]
    );
    await this.queueSyncOperation(id, 'UPDATE');
  }
}

export const WorkoutRepository = new WorkoutRepositoryClass();
