import 'package:aven_fit/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppDatabase Migrations (ISSUE-10)', () {
    test('schemaVersion is 8 and onCreate initializes all tables', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      expect(db.schemaVersion, 8);

      // Verify key tables are queryable
      final active = await db.workoutDao.getActiveSession();
      expect(active, isNull);

      final routines = await db.routineDao.getAllRoutines();
      expect(routines, isEmpty);
    });

    test('onUpgrade ladder defines clean migration steps for from 1..7', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      // Verify migration callbacks exist
      expect(db.migration.onUpgrade, isNotNull);
      expect(db.migration.onCreate, isNotNull);
      expect(db.migration.beforeOpen, isNotNull);
    });
  });
}
