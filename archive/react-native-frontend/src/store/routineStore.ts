import { create } from 'zustand';
import { db } from '../database';

export interface Routine {
  id: string;
  name: string;
  description: string;
}

export interface RoutineExercise {
  id: string;
  routine_id: string;
  exercise_id: string;
  position: number;
  name?: string; // joined from exercises table
}

interface RoutineState {
  routines: Routine[];
  activeRoutineExercises: RoutineExercise[];
  isLoading: boolean;
  loadRoutines: () => Promise<void>;
  createRoutine: (name: string, description?: string) => Promise<string>;
  loadRoutineExercises: (routineId: string) => Promise<void>;
}

export const useRoutineStore = create<RoutineState>((set, get) => ({
  routines: [],
  activeRoutineExercises: [],
  isLoading: false,

  loadRoutines: async () => {
    set({ isLoading: true });
    try {
      const res = await db.execute('SELECT * FROM routines ORDER BY created_at DESC');
      // @ts-ignore
      set({ routines: res.rows?._array || res.rows || [] });
    } catch (error) {
      console.error('Failed to load routines:', error);
    } finally {
      set({ isLoading: false });
    }
  },

  createRoutine: async (name: string, description = '') => {
    const id = `rt-${Date.now()}`;
    const now = new Date().toISOString();
    try {
      await db.execute(
        `INSERT INTO routines (id, name, description, created_at, updated_at) VALUES (?, ?, ?, ?, ?)`,
        [id, name, description, now, now]
      );
      await get().loadRoutines();
      return id;
    } catch (error) {
      console.error('Failed to create routine:', error);
      throw error;
    }
  },

  loadRoutineExercises: async (routineId: string) => {
    try {
      const res = await db.execute(
        `SELECT re.*, e.name 
         FROM routine_exercises re 
         JOIN exercises e ON re.exercise_id = e.id 
         WHERE re.routine_id = ? 
         ORDER BY re.position ASC`,
        [routineId]
      );
      // @ts-ignore
      set({ activeRoutineExercises: res.rows?._array || res.rows || [] });
    } catch (error) {
      console.error('Failed to load routine exercises:', error);
    }
  }
}));
