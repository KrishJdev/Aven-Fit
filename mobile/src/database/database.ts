import { open } from '@op-engineering/op-sqlite';

// Initialize OP-SQLite DB connection.
export const db = open({
  name: 'avenfit.sqlite',
});

// Helper for executing queries with parameters easily
export const execute = async (query: string, params: any[] = []) => {
  return await db.execute(query, params);
};

// Helper for executing multiple statements in a transaction
export const transaction = async (queries: { query: string; params?: any[] }[]) => {
  await db.transaction(async (tx) => {
    for (const q of queries) {
      await tx.execute(q.query, q.params || []);
    }
  });
};
