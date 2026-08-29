import { create } from 'zustand';
import { db } from '../database';

export interface Exercise {
  id: string;
  name: string;
  category: string;
  equipment: string;
  is_custom: number;
}

interface ExerciseState {
  exercises: Exercise[];
  isLoading: boolean;
  loadExercises: () => Promise<void>;
  seedInitialData: () => Promise<void>;
}

const DEFAULT_EXERCISES = [
  { id: 'ex-1', name: 'Barbell Bench Press', category: 'Chest', equipment: 'Barbell' },
  { id: 'ex-2', name: 'Incline Dumbbell Press', category: 'Chest', equipment: 'Dumbbell' },
  { id: 'ex-3', name: 'Squat', category: 'Legs', equipment: 'Barbell' },
  { id: 'ex-4', name: 'Leg Extension', category: 'Legs', equipment: 'Machine' },
  { id: 'ex-5', name: 'Deadlift', category: 'Back', equipment: 'Barbell' },
  { id: 'ex-6', name: 'Pull-up', category: 'Back', equipment: 'Bodyweight' },
  { id: 'ex-7', name: 'Overhead Press', category: 'Shoulders', equipment: 'Barbell' },
  { id: 'ex-8', name: 'Lateral Raise', category: 'Shoulders', equipment: 'Dumbbell' },
  { id: 'ex-9', name: 'Bicep Curl', category: 'Arms', equipment: 'Dumbbell' },
  { id: 'ex-10', name: 'Tricep Extension', category: 'Arms', equipment: 'Cable' },
];

export const useExerciseStore = create<ExerciseState>((set, get) => ({
  exercises: [],
  isLoading: false,
  
  loadExercises: async () => {
    set({ isLoading: true });
    try {
      const res = await db.execute('SELECT * FROM exercises ORDER BY name ASC');
      // @ts-ignore - op-sqlite returns rows in _array
      const exercises = res.rows?._array || res.rows || [];
      
      if (exercises.length === 0) {
        await get().seedInitialData();
      } else {
        set({ exercises });
      }
    } catch (error) {
      console.error('Failed to load exercises:', error);
    } finally {
      set({ isLoading: false });
    }
  },

  seedInitialData: async () => {
    try {
      // Begin transaction manually if op-sqlite supports it, or just loop
      for (const ex of DEFAULT_EXERCISES) {
        await db.execute(
          `INSERT OR IGNORE INTO exercises (id, name, category, equipment, is_custom, created_at, updated_at) 
           VALUES (?, ?, ?, ?, 0, ?, ?)`,
          [ex.id, ex.name, ex.category, ex.equipment, new Date().toISOString(), new Date().toISOString()]
        );
      }
      
      const res = await db.execute('SELECT * FROM exercises ORDER BY name ASC');
      // @ts-ignore
      set({ exercises: res.rows?._array || res.rows || [] });
    } catch (error) {
      console.error('Failed to seed exercises:', error);
    }
  }
}));
