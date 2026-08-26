import { create } from 'zustand';
import { db } from '../database';
import { ExerciseBlockData } from '../components/workout/ExerciseBlock';
import { SetData } from '../components/workout/SetRow';

interface WorkoutSummary {
  id: string;
  name: string;
  started_at: string;
  completed_at: string;
  status: string;
  volume: number;
  sets: number;
  exercisesStr: string;
}

interface WorkoutState {
  activeWorkoutId: string | null;
  activeWorkoutName: string;
  activeExercises: ExerciseBlockData[];
  recentWorkouts: WorkoutSummary[];
  
  startWorkout: (routineId?: string) => Promise<string>;
  finishWorkout: () => Promise<void>;
  
  addExerciseToWorkout: (exerciseId: string, exerciseName: string) => Promise<void>;
  addSetToExercise: (workoutExerciseId: string) => Promise<void>;
  updateSet: (setId: string, field: 'kg' | 'reps', value: string) => Promise<void>;
  toggleSetComplete: (setId: string) => Promise<void>;
  
  loadActiveWorkoutState: (workoutId: string) => Promise<void>;
  loadRecentWorkouts: () => Promise<void>;
}

export const useWorkoutStore = create<WorkoutState>((set, get) => ({
  activeWorkoutId: null,
  activeWorkoutName: 'Workout',
  activeExercises: [],
  recentWorkouts: [],

  loadRecentWorkouts: async () => {
    try {
      const res = await db.execute(`
        SELECT id, name, started_at, completed_at, status
        FROM workouts 
        WHERE status = 'COMPLETED' 
        ORDER BY completed_at DESC LIMIT 10
      `);
      // @ts-ignore
      const workouts = res.rows?._array || res.rows || [];
      
      const summaries = workouts.map((w: any) => ({
        ...w,
        volume: 0,
        sets: 0,
        exercisesStr: 'Workout data',
      }));
      set({ recentWorkouts: summaries });
    } catch (e) {
      console.error(e);
    }
  },

  startWorkout: async (routineId?: string) => {
    const id = `wk-${Date.now()}`;
    const now = new Date().toISOString();
    let name = 'Empty Workout';
    
    try {
      if (routineId) {
        const rRes = await db.execute(`SELECT name FROM routines WHERE id = ?`, [routineId]);
        // @ts-ignore
        const rName = rRes.rows?._array?.[0]?.name || rRes.rows?.item?.(0)?.name;
        if (rName) name = rName;
      }
      
      await db.execute(
        `INSERT INTO workouts (id, name, started_at, status, routine_id, created_at, updated_at) 
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [id, name, now, 'IN_PROGRESS', routineId || null, now, now]
      );
      set({ activeWorkoutId: id, activeWorkoutName: name, activeExercises: [] });
      return id;
    } catch (e) {
      console.error(e);
      throw e;
    }
  },

  finishWorkout: async () => {
    const { activeWorkoutId } = get();
    if (!activeWorkoutId) return;
    try {
      const now = new Date().toISOString();
      await db.execute(
        `UPDATE workouts SET status = 'COMPLETED', completed_at = ? WHERE id = ?`,
        [now, activeWorkoutId]
      );
      set({ activeWorkoutId: null, activeExercises: [] });
      get().loadRecentWorkouts();
    } catch (e) {
      console.error(e);
    }
  },

  addExerciseToWorkout: async (exerciseId: string, exerciseName: string) => {
    const { activeWorkoutId, activeExercises } = get();
    if (!activeWorkoutId) return;
    
    const weId = `we-${Date.now()}`;
    const position = activeExercises.length;
    
    try {
      await db.execute(
        `INSERT INTO workout_exercises (id, workout_id, exercise_id, position, created_at) VALUES (?, ?, ?, ?, ?)`,
        [weId, activeWorkoutId, exerciseId, position, new Date().toISOString()]
      );
      
      const newEx: ExerciseBlockData = {
        id: weId,
        name: exerciseName,
        sets: []
      };
      
      set({ activeExercises: [...activeExercises, newEx] });
      // Add first empty set
      await get().addSetToExercise(weId);
    } catch (e) {
      console.error(e);
    }
  },

  addSetToExercise: async (workoutExerciseId: string) => {
    const { activeExercises } = get();
    const exIndex = activeExercises.findIndex(ex => ex.id === workoutExerciseId);
    if (exIndex === -1) return;
    
    const ex = activeExercises[exIndex];
    const position = ex.sets.length;
    const setId = `ws-${Date.now()}`;
    
    try {
      await db.execute(
        `INSERT INTO workout_sets (id, workout_exercise_id, position, set_type, weight_kg, reps, is_completed, created_at)
         VALUES (?, ?, ?, 'NORMAL', 0, 0, 0, ?)`,
        [setId, workoutExerciseId, position, new Date().toISOString()]
      );
      
      const newSet: SetData = {
        id: setId,
        index: position + 1,
        previousString: '-',
        kg: '',
        reps: '',
        isCompleted: false
      };
      
      const updatedEx = { ...ex, sets: [...ex.sets, newSet] };
      const newExercises = [...activeExercises];
      newExercises[exIndex] = updatedEx;
      set({ activeExercises: newExercises });
      
    } catch (e) {
      console.error(e);
    }
  },

  updateSet: async (setId: string, field: 'kg' | 'reps', value: string) => {
    const { activeExercises } = get();
    // Update local state optimistic
    const newExercises = activeExercises.map(ex => ({
      ...ex,
      sets: ex.sets.map(s => s.id === setId ? { ...s, [field]: value } : s)
    }));
    set({ activeExercises: newExercises });
    
    // DB Update
    try {
      const numVal = parseFloat(value) || 0;
      const dbField = field === 'kg' ? 'weight_kg' : 'reps';
      await db.execute(`UPDATE workout_sets SET ${dbField} = ? WHERE id = ?`, [numVal, setId]);
    } catch (e) {
      console.error(e);
    }
  },

  toggleSetComplete: async (setId: string) => {
    const { activeExercises } = get();
    let isCompletedNow = false;
    
    const newExercises = activeExercises.map(ex => ({
      ...ex,
      sets: ex.sets.map(s => {
        if (s.id === setId) {
          isCompletedNow = !s.isCompleted;
          return { ...s, isCompleted: isCompletedNow };
        }
        return s;
      })
    }));
    set({ activeExercises: newExercises });
    
    try {
      await db.execute(`UPDATE workout_sets SET is_completed = ? WHERE id = ?`, [isCompletedNow ? 1 : 0, setId]);
    } catch (e) {
      console.error(e);
    }
  },

  loadActiveWorkoutState: async (workoutId: string) => {
    try {
      const resW = await db.execute(`SELECT name FROM workouts WHERE id = ?`, [workoutId]);
      // @ts-ignore
      const wName = resW.rows?._array?.[0]?.name || resW.rows?.item?.(0)?.name || 'Workout';
      
      const resWe = await db.execute(`
        SELECT we.id, e.name 
        FROM workout_exercises we
        JOIN exercises e ON we.exercise_id = e.id
        WHERE we.workout_id = ?
        ORDER BY we.position ASC
      `, [workoutId]);
      
      // @ts-ignore
      const workoutExercises = resWe.rows?._array || resWe.rows || [];
      const populatedExercises: ExerciseBlockData[] = [];
      
      for (const we of workoutExercises) {
        const resSets = await db.execute(`
          SELECT id, position, weight_kg, reps, is_completed 
          FROM workout_sets 
          WHERE workout_exercise_id = ? 
          ORDER BY position ASC
        `, [we.id]);
        
        // @ts-ignore
        const dbSets = resSets.rows?._array || resSets.rows || [];
        const sets: SetData[] = dbSets.map((s: any) => ({
          id: s.id,
          index: s.position + 1,
          previousString: '-', // Need separate query for history
          kg: s.weight_kg ? s.weight_kg.toString() : '',
          reps: s.reps ? s.reps.toString() : '',
          isCompleted: s.is_completed === 1
        }));
        
        populatedExercises.push({
          id: we.id,
          name: we.name,
          sets
        });
      }
      
      set({ activeWorkoutId: workoutId, activeWorkoutName: wName, activeExercises: populatedExercises });
    } catch (e) {
      console.error(e);
    }
  }
}));
