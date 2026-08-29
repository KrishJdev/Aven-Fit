import { db } from './src/database';
db.execute('SELECT * FROM workouts ORDER BY created_at DESC LIMIT 1').then(res => console.log(JSON.stringify(res, null, 2)));
