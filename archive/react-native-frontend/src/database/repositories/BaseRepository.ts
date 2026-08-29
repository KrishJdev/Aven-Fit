import { db } from '../database';

export interface BaseModel {
  id: string;
  user_id?: string;
  created_at: string;
  updated_at: string;
  sync_status: 'SYNCED' | 'PENDING' | 'CONFLICT';
  last_synced_at?: string;
  server_updated_at?: string;
  is_deleted: number; // 0 or 1
}

export class BaseRepository<T extends BaseModel> {
  constructor(protected tableName: string) {}

  protected generateId(): string {
    return Math.random().toString(36).substring(2, 15);
  }

  async findById(id: string): Promise<T | null> {
    const res = await db.execute(`SELECT * FROM ${this.tableName} WHERE id = ? AND is_deleted = 0`, [id]);
    return ((res.rows && res.rows[0]) as unknown as T) || null;
  }

  async findAll(): Promise<T[]> {
    const res = await db.execute(`SELECT * FROM ${this.tableName} WHERE is_deleted = 0 ORDER BY created_at DESC`);
    return (res.rows || []) as unknown as T[];
  }

  async softDelete(id: string): Promise<void> {
    const now = new Date().toISOString();
    await db.execute(
      `UPDATE ${this.tableName} 
       SET is_deleted = 1, sync_status = 'PENDING', updated_at = ? 
       WHERE id = ?`,
      [now, id]
    );
    await this.queueSyncOperation(id, 'DELETE');
  }

  protected async queueSyncOperation(entityId: string, operation: 'INSERT' | 'UPDATE' | 'DELETE') {
    const now = new Date().toISOString();
    await db.execute(
      `INSERT INTO sync_queue (id, table_name, entity_id, operation, created_at)
       VALUES (?, ?, ?, ?, ?)`,
      [this.generateId(), this.tableName, entityId, operation, now]
    );
  }
}
