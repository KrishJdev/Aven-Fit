// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_local_source.dart';

// ignore_for_file: type=lint
mixin _$NutritionDaoMixin on DatabaseAccessor<AppDatabase> {
  $FoodItemsTable get foodItems => attachedDatabase.foodItems;
  $LoggedMealItemsTable get loggedMealItems => attachedDatabase.loggedMealItems;
  $NutritionGoalsTable get nutritionGoals => attachedDatabase.nutritionGoals;
  NutritionDaoManager get managers => NutritionDaoManager(this);
}

class NutritionDaoManager {
  final _$NutritionDaoMixin _db;
  NutritionDaoManager(this._db);
  $$FoodItemsTableTableManager get foodItems =>
      $$FoodItemsTableTableManager(_db.attachedDatabase, _db.foodItems);
  $$LoggedMealItemsTableTableManager get loggedMealItems =>
      $$LoggedMealItemsTableTableManager(
        _db.attachedDatabase,
        _db.loggedMealItems,
      );
  $$NutritionGoalsTableTableManager get nutritionGoals =>
      $$NutritionGoalsTableTableManager(
        _db.attachedDatabase,
        _db.nutritionGoals,
      );
}
