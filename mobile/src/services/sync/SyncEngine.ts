import { db } from '@/database/database';
import { apiClient } from '@/services/api/client';
import NetInfo from '@react-native-community/netinfo';
import AsyncStorage from '@react-native-async-storage/async-storage';

export class SyncEngine {
  private static isSyncing = false;

  static async init() {
    // Listen for network changes
    NetInfo.addEventListener(state => {
      if (state.isConnected && state.isInternetReachable) {
        this.runSync();
      }
    });
  }

  static async runSync() {
    if (this.isSyncing) return;
    
    try {
      this.isSyncing = true;
      console.log('🔄 Sync started...');
      
      await this.pushPendingChanges();
      await this.pullServerChanges();
      
      console.log('✅ Sync completed');
    } catch (e) {
      console.error('❌ Sync failed:', e);
    } finally {
      this.isSyncing = false;
    }
  }

  private static async pushPendingChanges() {
    // 1. Get all pending operations from sync_queue
    const queueRes = await db.execute(`SELECT * FROM sync_queue ORDER BY created_at ASC`);
    const pendingOps = queueRes.rows || [];

    if (pendingOps.length === 0) return;

    // 2. Group and extract actual entity data
    const payload = [];
    for (const op of pendingOps) {
      const entityRes = await db.execute(`SELECT * FROM ${op.table_name} WHERE id = ?`, [op.entity_id as string]);
      const entityData = entityRes.rows && entityRes.rows[0];
      
      if (entityData) {
        payload.push({
          queueId: op.id,
          tableName: op.table_name,
          operation: op.operation,
          data: entityData,
        });
      }
    }

    // 3. Push to server
    if (payload.length > 0) {
      const response = await apiClient<{ successIds: string[], conflicts: any[] }>('/sync/push', {
        method: 'POST',
        body: JSON.stringify({ operations: payload }),
      });

      // 4. Cleanup local queue on success
      if (response.successIds?.length > 0) {
        const placeholders = response.successIds.map(() => '?').join(',');
        await db.execute(`DELETE FROM sync_queue WHERE id IN (${placeholders})`, response.successIds);
        
        // Mark entities as SYNCED
        for (const op of payload.filter(p => response.successIds.includes(p.queueId as string))) {
          await db.execute(`UPDATE ${op.tableName} SET sync_status = 'SYNCED' WHERE id = ?`, [op.data.id as string]);
        }
      }
    }
  }

  private static async pullServerChanges() {
    const lastSync = await AsyncStorage.getItem('@AvenFit_lastSync') || '1970-01-01T00:00:00.000Z';
    
    const response = await apiClient<{
      timestamp: string;
      data: Record<string, any[]>;
    }>(`/sync/pull?since=${encodeURIComponent(lastSync)}`, {
      method: 'GET'
    });

    if (!response || !response.data) return;

    // Iterate through tables and upsert
    for (const [tableName, entities] of Object.entries(response.data)) {
      for (const entity of entities) {
        // Upsert logic (simplistic version for MVP)
        // In a real scenario, you'd check if the local item has PENDING status to avoid overwriting local edits.
        
        const cols = Object.keys(entity).join(', ');
        const placeholders = Object.keys(entity).map(() => '?').join(', ');
        const values = Object.values(entity) as (string | number | null)[];
        
        await db.execute(
          `INSERT OR REPLACE INTO ${tableName} (${cols}, sync_status) VALUES (${placeholders}, 'SYNCED')`,
          values
        );
      }
    }

    await AsyncStorage.setItem('@AvenFit_lastSync', response.timestamp);
  }
}
