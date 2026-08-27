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
  
  durationCounter: number;
  isPaused: boolean;
  tickDuration: () => void;
  togglePause: () => void;
  
  startWorkout: (routineId?: string) => Promise<string>;
  finishWorkout: (finalName?: string) => Promise<string | null>;
  
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
  
  durationCounter: 0,
  isPaused: false,
  
  tickDuration: () => {
    const { isPaused, activeWorkoutId } = get();
    if (activeWorkoutId && !isPaused) {
      set(state => ({ durationCounter: state.durationCounter + 1 }));
    }
  },
  
  togglePause: () => {
    set(state => ({ isPaused: !state.isPaused }));
  },

  loadRecentWorkouts: async () => {
    try {
      const res = await db.execute(`
        SELECT 
          w.id, w.name, w.started_at, w.completed_at, w.status,
          COALESCE(SUM(ws.weight_kg * ws.reps), 0) as volume,
          COUNT(ws.id) as sets,
          GROUP_CONCAT(DISTINCT e.name) as exercisesStr
        FROM workouts w
        LEFT JOIN workout_exercises we ON we.workout_id = w.id
        LEFT JOIN exercises e ON we.exercise_id = e.id
        LEFT JOIN workout_sets ws ON ws.workout_exercise_id = we.id AND ws.is_completed = 1
        WHERE w.status = 'COMPLETED'
        GROUP BY w.id
        ORDER BY w.completed_at DESC LIMIT 10
      `);
      // @ts-ignore
      const workouts = res.rows?._array || res.rows || [];
      
      const summaries = workouts.map((w: any) => ({
        ...w,
        volume: w.volume || 0,
        sets: w.sets || 0,
        exercisesStr: w.exercisesStr ? w.exercisesStr.split(',').join(' • ') : 'No exercises',
      }));
      set({ recentWorkouts: summaries });
    } catch (e) {
      console.error(e);
    }
  },

  startWorkout: async (routineId?: string) => {
    const id = `wk-${Date.now()}`;
    const now = new Date();
    const nowIso = now.toISOString();
    
    // Dynamic naming based on time
    const hour = now.getHours();
    let defaultName = 'Workout';
    if (hour >= 0 && hour < 5) defaultName = Math.random() > 0.5 ? 'Late Night Lift' : 'Midnight Session';
    else if (hour >= 5 && hour < 9) defaultName = Math.random() > 0.5 ? 'Early Bird Workout' : 'Dawn Patrol';
    else if (hour >= 9 && hour < 12) defaultName = Math.random() > 0.5 ? 'Morning Grind' : 'Morning Workout';
    else if (hour >= 12 && hour < 17) defaultName = Math.random() > 0.5 ? 'Afternoon Pump' : 'Midday Session';
    else if (hour >= 17 && hour < 21) defaultName = Math.random() > 0.5 ? 'Evening Workout' : 'Sundown Session';
    else defaultName = Math.random() > 0.5 ? 'Night Session' : 'Late Lift';

    let name = defaultName;
    
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
        [id, name, nowIso, 'IN_PROGRESS', routineId || null, nowIso, nowIso]
      );
      
      set({ 
        activeWorkoutId: id, 
        activeWorkoutName: name, 
        activeExercises: [],
        durationCounter: 0,
        isPaused: false
      });
      return id;
    } catch (e) {
      console.error(e);
      throw e;
    }
  },

  finishWorkout: async (finalName?: string): Promise<string | null> => {
    const { activeWorkoutId, durationCounter } = get();
    if (!activeWorkoutId) return null;
    
    try {
      if (finalName) {
        await db.execute(
          `UPDATE workouts SET status = 'COMPLETED', completed_at = ?, duration_seconds = ?, name = ? WHERE id = ?`,
          [new Date().toISOString(), durationCounter, finalName, activeWorkoutId]
        );
      } else {
        await db.execute(
          `UPDATE workouts SET status = 'COMPLETED', completed_at = ?, duration_seconds = ? WHERE id = ?`,
          [new Date().toISOString(), durationCounter, activeWorkoutId]
        );
      }
      
      const finishedId = activeWorkoutId;
      
      set({ 
        activeWorkoutId: null, 
        activeWorkoutName: 'Workout', 
        activeExercises: [],
        durationCounter: 0,
        isPaused: false
      });
      await get().loadRecentWorkouts();
      return finishedId;
    } catch (e) {
      console.error(e);
      return null;
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
    
    let suggestedKg = '';
    let suggestedReps = '';

    try {
      if (position > 0) {
        // Carry over from the previous set in the current workout
        const prevSet = ex.sets[position - 1];
        if (prevSet.kg) suggestedKg = prevSet.kg;
        if (prevSet.reps) suggestedReps = prevSet.reps;
      } else {
        // First set, look up the last completed set for this exercise in DB history
        const histRes = await db.execute(`
          SELECT ws.weight_kg, ws.reps 
          FROM workout_sets ws
          JOIN workout_exercises we ON ws.workout_exercise_id = we.id
          WHERE we.exercise_id = (SELECT exercise_id FROM workout_exercises WHERE id = ?)
            AND ws.is_completed = 1
          ORDER BY ws.created_at DESC
          LIMIT 1
        `, [workoutExerciseId]);
        
        // @ts-ignore
        const histSet = histRes.rows?._array?.[0] || histRes.rows?.item?.(0);
        if (histSet) {
          suggestedKg = histSet.weight_kg ? histSet.weight_kg.toString() : '';
          suggestedReps = histSet.reps ? histSet.reps.toString() : '';
        }
      }

      await db.execute(
        `INSERT INTO workout_sets (id, workout_exercise_id, position, set_type, weight_kg, reps, is_completed, created_at)
         VALUES (?, ?, ?, 'NORMAL', 0, 0, 0, ?)`,
        [setId, workoutExerciseId, position, new Date().toISOString()]
      );
      
      const newSet: SetData = {
        id: setId,
        index: position + 1,
        previousString: suggestedKg && suggestedReps ? `${suggestedKg} kg × ${suggestedReps}` : '-',
        kg: '',
        reps: '',
        isCompleted: false,
        suggestedKg,
        suggestedReps
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
      const resW = await db.execute(
        `SELECT name, duration_seconds, status, started_at FROM workouts WHERE id = ?`, 
        [workoutId]
      );
      // @ts-ignore
      const wRow = resW.rows?._array?.[0] || resW.rows?.item?.(0);
      const wName = wRow?.name || 'Workout';
      
      let initialDuration = wRow?.duration_seconds || 0;
      let initialPaused = wRow?.status === 'PAUSED';
      
      // If it's IN_PROGRESS, calculate elapsed time since started_at (naive approach for MVP)
      if (wRow?.status === 'IN_PROGRESS' && wRow?.started_at && !initialDuration) {
        initialDuration = Math.floor((Date.now() - new Date(wRow.started_at).getTime()) / 1000);
      }

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
        const sets: SetData[] = [];
        
        for (let i = 0; i < dbSets.length; i++) {
          const s = dbSets[i];
          let sKg = '';
          let sReps = '';
          
          if (i > 0) {
             const prev = sets[i-1];
             if (prev.kg) sKg = prev.kg;
             if (prev.reps) sReps = prev.reps;
          } else {
             // For the first set, we should ideally fetch history, but for resumed workouts, 
             // we can skip this heavy query unless the user adds a new set.
          }

          sets.push({
            id: s.id,
            index: s.position + 1,
            previousString: '-', // Could fetch history if needed
            kg: s.weight_kg ? s.weight_kg.toString() : '',
            reps: s.reps ? s.reps.toString() : '',
            isCompleted: s.is_completed === 1,
            suggestedKg: sKg,
            suggestedReps: sReps
          });
        }
        
        populatedExercises.push({
          id: we.id,
          name: we.name,
          sets
        });
      }
      
      set({ 
        activeWorkoutId: workoutId, 
        activeWorkoutName: wName, 
        activeExercises: populatedExercises,
        durationCounter: Math.max(0, initialDuration),
        isPaused: initialPaused
      });
    } catch (e) {
      console.error(e);
    }
  }
}));
