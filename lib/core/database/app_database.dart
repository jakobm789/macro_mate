import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

@DataClassName('GoalRow')
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dailyCalories => integer().named('daily_calories')();
  IntColumn get carbPercentage => integer().named('carb_percentage')();
  IntColumn get proteinPercentage => integer().named('protein_percentage')();
  IntColumn get fatPercentage => integer().named('fat_percentage')();
  IntColumn get sugarPercentage => integer().named('sugar_percentage')();
  IntColumn get autoCalorieMode =>
      integer().named('auto_calorie_mode').withDefault(const Constant(0))();
  RealColumn get customPercentPerMonth => real()
      .named('custom_percent_per_month')
      .withDefault(const Constant(1.0))();
  IntColumn get useCustomStartCalories => integer()
      .named('use_custom_start_calories')
      .withDefault(const Constant(0))();
  IntColumn get userStartCalories => integer()
      .named('user_start_calories')
      .withDefault(const Constant(2000))();
  IntColumn get userAge =>
      integer().named('user_age').withDefault(const Constant(30))();
  RealColumn get userActivityLevel =>
      real().named('user_activity_level').withDefault(const Constant(1.3))();
  TextColumn get lastMondayCheck =>
      text().named('last_monday_check').nullable()();
  IntColumn get firstWeekInitialized => integer()
      .named('first_week_initialized')
      .withDefault(const Constant(0))();
  RealColumn get userHeight =>
      real().named('user_height').withDefault(const Constant(170))();
  IntColumn get useProteinPerKg =>
      integer().named('use_protein_per_kg').withDefault(const Constant(0))();
  RealColumn get proteinPerKg =>
      real().named('protein_per_kg').withDefault(const Constant(2.0))();
  RealColumn get targetWeight => real().named('target_weight').nullable()();
  TextColumn get targetDate => text().named('target_date').nullable()();
  RealColumn get targetWeeklyChange =>
      real().named('target_weekly_change').nullable()();

  @override
  String get tableName => 'Goals';
}

@DataClassName('ConsumedFoodRow')
class ConsumedFoods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get mealName => text().named('meal_name')();
  IntColumn get foodId => integer().named('food_id')();
  IntColumn get quantity => integer()();
  TextColumn get uuid => text().nullable()();

  @override
  String get tableName => 'ConsumedFoods';
}

@DataClassName('SavedMealRow')
class SavedMeals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get defaultMealName => text().named('default_meal_name')();
  TextColumn get createdAt => text().named('created_at')();
  IntColumn get recipeTotalWeight =>
      integer().named('recipe_total_weight').nullable()();
  TextColumn get uuid => text().nullable()();

  @override
  String get tableName => 'SavedMeals';
}

@DataClassName('SavedMealIngredientRow')
class SavedMealIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get savedMealId => integer()
      .named('saved_meal_id')
      .references(SavedMeals, #id, onDelete: KeyAction.cascade)();
  IntColumn get foodId => integer().named('food_id')();
  IntColumn get quantity => integer()();

  @override
  String get tableName => 'SavedMealIngredients';
}

@DataClassName('FavoriteFoodRow')
class FavoriteFoods extends Table {
  IntColumn get foodId => integer().named('food_id')();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {foodId};

  @override
  String get tableName => 'FavoriteFoods';
}

@DataClassName('FoodUsageRow')
class FoodUsage extends Table {
  IntColumn get foodId => integer().named('food_id')();
  IntColumn get lastUsedQuantity => integer().named('last_used_quantity')();
  TextColumn get lastUsedAt => text().named('last_used_at')();
  IntColumn get useCount =>
      integer().named('use_count').withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {foodId};

  @override
  String get tableName => 'FoodUsage';
}

@DataClassName('OfflineQueueRow')
class OfflineQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionType => text().named('action_type')();
  TextColumn get payload => text()();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get lastError => text().named('last_error').nullable()();

  @override
  String get tableName => 'OfflineQueue';
}

@DataClassName('LocalFoodRow')
class LocalFoods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get brand => text()();
  TextColumn get barcode => text().nullable()();
  IntColumn get caloriesPer100g => integer().named('calories_per_100g')();
  RealColumn get fatPer100g => real().named('fat_per_100g')();
  RealColumn get carbsPer100g => real().named('carbs_per_100g')();
  RealColumn get sugarPer100g => real().named('sugar_per_100g')();
  RealColumn get proteinPer100g => real().named('protein_per_100g')();
  TextColumn get createdAt => text().named('created_at')();
  IntColumn get lastUsedQuantity =>
      integer().named('last_used_quantity').withDefault(const Constant(100))();
  TextColumn get source => text().withDefault(const Constant('ai'))();
  IntColumn get isVerified =>
      integer().named('is_verified').withDefault(const Constant(0))();
  TextColumn get uuid => text().nullable()();

  @override
  String get tableName => 'LocalFoods';
}

@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get darkMode =>
      integer().named('dark_mode').withDefault(const Constant(0))();
  IntColumn get reminderWeighEnabled => integer()
      .named('reminder_weigh_enabled')
      .withDefault(const Constant(0))();
  TextColumn get reminderWeighTime => text()
      .named('reminder_weigh_time')
      .withDefault(const Constant('08:00'))();
  TextColumn get reminderWeighTime2 => text()
      .named('reminder_weigh_time2')
      .withDefault(const Constant('09:00'))();
  IntColumn get reminderSupplementEnabled => integer()
      .named('reminder_supplement_enabled')
      .withDefault(const Constant(0))();
  TextColumn get reminderSupplementTime => text()
      .named('reminder_supplement_time')
      .withDefault(const Constant('10:00'))();
  TextColumn get reminderSupplementTime2 => text()
      .named('reminder_supplement_time2')
      .withDefault(const Constant('11:00'))();
  IntColumn get reminderMealsEnabled => integer()
      .named('reminder_meals_enabled')
      .withDefault(const Constant(0))();
  TextColumn get reminderBreakfast =>
      text().named('reminder_breakfast').withDefault(const Constant('07:00'))();
  TextColumn get reminderLunch =>
      text().named('reminder_lunch').withDefault(const Constant('12:30'))();
  TextColumn get reminderDinner =>
      text().named('reminder_dinner').withDefault(const Constant('19:00'))();

  @override
  String get tableName => 'Settings';
}

@DataClassName('WeightEntryRow')
class WeightEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  RealColumn get weight => real()();
  TextColumn get uuid => text().nullable()();

  @override
  String get tableName => 'WeightEntries';
}

@DataClassName('AppDatabaseMetadataRow')
class AppDatabaseMetadata extends Table {
  IntColumn get id => integer()();
  IntColumn get schemaVersion => integer().named('schema_version')();
  TextColumn get createdAtUtc => text().named('created_at_utc')();
  TextColumn get migratedAtUtc => text().named('migrated_at_utc')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('HealthSourceRow')
class HealthSources extends Table {
  TextColumn get id => text()();
  TextColumn get sourceName => text().named('source_name')();
  TextColumn get sourceDeviceId =>
      text().named('source_device_id').nullable()();
  TextColumn get platform => text()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get discoveredAtUtc => text().named('discovered_at_utc')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('HealthSyncStateRow')
class HealthSyncStates extends Table {
  TextColumn get sourceId => text().named('source_id')();
  TextColumn get cursorUtc => text().named('cursor_utc').nullable()();
  TextColumn get lastSuccessUtc =>
      text().named('last_success_utc').nullable()();
  TextColumn get lastError => text().named('last_error').nullable()();
  TextColumn get status => text().withDefault(const Constant('never'))();

  @override
  Set<Column<Object>> get primaryKey => {sourceId};
}

@DataClassName('HealthRecordRow')
class HealthRecords extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get sourceId => text().named('source_id')();
  TextColumn get startUtc => text().named('start_utc')();
  TextColumn get endUtc => text().named('end_utc')();
  RealColumn get value => real()();
  TextColumn get unit => text()();
  TextColumn get localDay => text().named('local_day')();
  TextColumn get payloadJson => text().named('payload_json').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DailyHealthAggregateRow')
class DailyHealthAggregates extends Table {
  TextColumn get day => text()();
  IntColumn get steps => integer().withDefault(const Constant(0))();
  RealColumn get activeKcal =>
      real().named('active_kcal').withDefault(const Constant(0))();
  RealColumn get totalKcal => real().named('total_kcal').nullable()();
  RealColumn get distanceM =>
      real().named('distance_m').withDefault(const Constant(0))();
  RealColumn get heartRateAvg => real().named('heart_rate_avg').nullable()();
  RealColumn get restingHr => real().named('resting_hr').nullable()();
  RealColumn get sleepMinutes => real().named('sleep_minutes').nullable()();
  TextColumn get sourceIds =>
      text().named('source_ids').withDefault(const Constant('[]'))();
  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  Set<Column<Object>> get primaryKey => {day};
}

@DataClassName('SleepSessionRow')
class SleepSessions extends Table {
  TextColumn get id => text()();
  TextColumn get startUtc => text().named('start_utc')();
  TextColumn get endUtc => text().named('end_utc')();
  IntColumn get durationMinutes => integer().named('duration_minutes')();
  TextColumn get sourceId => text().named('source_id')();
  TextColumn get stagesJson => text().named('stages_json').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('WorkoutSessionRow')
class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get startUtc => text().named('start_utc')();
  TextColumn get endUtc => text().named('end_utc')();
  RealColumn get durationSeconds => real().named('duration_seconds')();
  RealColumn get distanceM => real().named('distance_m').nullable()();
  RealColumn get energyKcal => real().named('energy_kcal').nullable()();
  TextColumn get sourceId => text().named('source_id')();
  TextColumn get routeStatus =>
      text().named('route_status').withDefault(const Constant('unavailable'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('WorkoutRoutePointRow')
class WorkoutRoutePoints extends Table {
  TextColumn get workoutId => text().named('workout_id')();
  IntColumn get sequence => integer()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get timestampUtc => text().named('timestamp_utc')();

  @override
  Set<Column<Object>> get primaryKey => {workoutId, sequence};
}

@DataClassName('CycleProfileRow')
class CycleProfiles extends Table {
  IntColumn get id => integer()();
  IntColumn get typicalCycleLength =>
      integer().named('typical_cycle_length').withDefault(const Constant(28))();
  IntColumn get typicalPeriodLength =>
      integer().named('typical_period_length').withDefault(const Constant(5))();
  BoolColumn get predictionsEnabled => boolean()
      .named('predictions_enabled')
      .withDefault(const Constant(true))();
  BoolColumn get healthImportEnabled => boolean()
      .named('health_import_enabled')
      .withDefault(const Constant(false))();
  TextColumn get timezone => text().withDefault(const Constant('UTC'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PeriodEntryRow')
class PeriodEntries extends Table {
  TextColumn get id => text()();
  TextColumn get startDay => text().named('start_day')();
  TextColumn get endDay => text().named('end_day').nullable()();
  TextColumn get flowJson => text().named('flow_json').nullable()();
  TextColumn get source => text().withDefault(const Constant('local'))();
  TextColumn get createdAtUtc => text().named('created_at_utc')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CycleDailyLogRow')
class CycleDailyLogs extends Table {
  TextColumn get day => text()();
  TextColumn get bleeding => text().nullable()();
  TextColumn get mood => text().nullable()();
  IntColumn get pain => integer().nullable()();
  IntColumn get energy => integer().nullable()();
  IntColumn get sleepQuality => integer().named('sleep_quality').nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get tagsJson =>
      text().named('tags_json').withDefault(const Constant('[]'))();
  TextColumn get source => text().withDefault(const Constant('local'))();
  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  Set<Column<Object>> get primaryKey => {day};
}

@DataClassName('SymptomDefinitionRow')
class SymptomDefinitions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SymptomLogRow')
class SymptomLogs extends Table {
  TextColumn get id => text()();
  TextColumn get day => text()();
  TextColumn get symptomId => text().named('symptom_id')();
  IntColumn get intensity => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CyclePredictionRow')
class CyclePredictions extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get windowStart => text().named('window_start')();
  TextColumn get windowEnd => text().named('window_end')();
  RealColumn get confidence => real()();
  TextColumn get rationale => text()();
  TextColumn get calculatedAtUtc => text().named('calculated_at_utc')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('NotificationPreferenceRow')
class NotificationPreferences extends Table {
  TextColumn get id => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  IntColumn get leadMinutes =>
      integer().named('lead_minutes').withDefault(const Constant(0))();
  TextColumn get quietStart => text().named('quiet_start').nullable()();
  TextColumn get quietEnd => text().named('quiet_end').nullable()();
  TextColumn get weekdaysJson => text()
      .named('weekdays_json')
      .withDefault(const Constant('[1,2,3,4,5,6,7]'))();
  BoolColumn get discreteLockScreen => boolean()
      .named('discrete_lock_screen')
      .withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('BackupManifestRow')
class BackupManifests extends Table {
  TextColumn get id => text()();
  IntColumn get schemaVersion => integer().named('schema_version')();
  TextColumn get appVersion => text().named('app_version')();
  TextColumn get createdAtUtc => text().named('created_at_utc')();
  TextColumn get categoriesJson => text().named('categories_json')();
  IntColumn get recordCount => integer().named('record_count')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('GymExerciseRow')
class GymExercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get primaryMuscle => text().named('primary_muscle')();
  TextColumn get secondaryMusclesJson =>
      text().named('secondary_muscles_json').withDefault(const Constant('[]'))();
  TextColumn get equipment => text()();
  TextColumn get instructions => text().nullable()();
  TextColumn get gifUrl => text().named('gif_url').nullable()();
  BoolColumn get isCustom =>
      boolean().named('is_custom').withDefault(const Constant(false))();
  BoolColumn get isTimed =>
      boolean().named('is_timed').withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('GymWorkoutPlanRow')
class GymWorkoutPlans extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get daysPerWeek =>
      integer().named('days_per_week').withDefault(const Constant(3))();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  TextColumn get createdAtUtc => text().named('created_at_utc')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('GymPlanRoutineRow')
class GymPlanRoutines extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text()
      .named('plan_id')
      .references(GymWorkoutPlans, #id, onDelete: KeyAction.cascade)();
  IntColumn get dayOfWeek => integer().named('day_of_week')();
  TextColumn get name => text()();
  TextColumn get progressionType =>
      text().named('progression_type').withDefault(const Constant('linear'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('GymPlanRoutineExerciseRow')
class GymPlanRoutineExercises extends Table {
  TextColumn get id => text()();
  TextColumn get routineId => text()
      .named('routine_id')
      .references(GymPlanRoutines, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text()
      .named('exercise_id')
      .references(GymExercises, #id)();
  IntColumn get orderIndex => integer().named('order_index')();
  IntColumn get targetSets =>
      integer().named('target_sets').withDefault(const Constant(3))();
  IntColumn get targetRepsMin =>
      integer().named('target_reps_min').withDefault(const Constant(8))();
  IntColumn get targetRepsMax =>
      integer().named('target_reps_max').withDefault(const Constant(12))();
  IntColumn get targetHoldSeconds =>
      integer().named('target_hold_seconds').nullable()();
  IntColumn get restSeconds =>
      integer().named('rest_seconds').withDefault(const Constant(90))();
  TextColumn get supersetGroupId =>
      text().named('superset_group_id').nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('GymWorkoutSessionRow')
class GymWorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get routineId => text().named('routine_id').nullable()();
  TextColumn get routineName => text().named('routine_name')();
  TextColumn get startUtc => text().named('start_utc')();
  TextColumn get endUtc => text().named('end_utc').nullable()();
  RealColumn get durationSeconds =>
      real().named('duration_seconds').withDefault(const Constant(0))();
  RealColumn get totalTonnageKg =>
      real().named('total_tonnage_kg').withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  RealColumn get rpeAverage => real().named('rpe_average').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('GymSetLogRow')
class GymSetLogs extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()
      .named('session_id')
      .references(GymWorkoutSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text()
      .named('exercise_id')
      .references(GymExercises, #id)();
  IntColumn get setIndex => integer().named('set_index')();
  TextColumn get setType =>
      text().named('set_type').withDefault(const Constant('normal'))();
  RealColumn get weightKg =>
      real().named('weight_kg').withDefault(const Constant(0))();
  IntColumn get reps => integer().nullable()();
  IntColumn get holdSeconds => integer().named('hold_seconds').nullable()();
  RealColumn get rpe => real().nullable()();
  IntColumn get rir => integer().nullable()();
  BoolColumn get completed =>
      boolean().withDefault(const Constant(false))();
  TextColumn get loggedAtUtc => text().named('logged_at_utc')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('Gym1RmHistoryRow')
class Gym1RmHistories extends Table {
  TextColumn get id => text()();
  TextColumn get exerciseId => text()
      .named('exercise_id')
      .references(GymExercises, #id)();
  RealColumn get calculated1Rm => real().named('calculated_1rm')();
  RealColumn get weightKg => real().named('weight_kg')();
  IntColumn get reps => integer()();
  TextColumn get date => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Goals,
    ConsumedFoods,
    SavedMeals,
    SavedMealIngredients,
    FavoriteFoods,
    FoodUsage,
    OfflineQueue,
    LocalFoods,
    AppSettings,
    WeightEntries,
    AppDatabaseMetadata,
    HealthSources,
    HealthSyncStates,
    HealthRecords,
    DailyHealthAggregates,
    SleepSessions,
    WorkoutSessions,
    WorkoutRoutePoints,
    CycleProfiles,
    PeriodEntries,
    CycleDailyLogs,
    SymptomDefinitions,
    SymptomLogs,
    CyclePredictions,
    NotificationPreferences,
    BackupManifests,
    GymExercises,
    GymWorkoutPlans,
    GymPlanRoutines,
    GymPlanRoutineExercises,
    GymWorkoutSessions,
    GymSetLogs,
    Gym1RmHistories,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 28;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
          await _createV26Indexes();
          await _createV27Indexes();
          await _createV28Indexes();
          await _writeMetadata(isMigration: false);
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 26) {
            await migrator.createTable(appDatabaseMetadata);
            await migrator.addColumn(consumedFoods, consumedFoods.uuid);
            await migrator.addColumn(savedMeals, savedMeals.uuid);
            await migrator.addColumn(localFoods, localFoods.uuid);
            await migrator.addColumn(weightEntries, weightEntries.uuid);
            await _backfillLegacyUuids();
            await _createV26Indexes();
            await _writeMetadata(isMigration: true);
          }
          if (from < 27) {
            await migrator.createTable(healthSources);
            await migrator.createTable(healthSyncStates);
            await migrator.createTable(healthRecords);
            await migrator.createTable(dailyHealthAggregates);
            await migrator.createTable(sleepSessions);
            await migrator.createTable(workoutSessions);
            await migrator.createTable(workoutRoutePoints);
            await migrator.createTable(cycleProfiles);
            await migrator.createTable(periodEntries);
            await migrator.createTable(cycleDailyLogs);
            await migrator.createTable(symptomDefinitions);
            await migrator.createTable(symptomLogs);
            await migrator.createTable(cyclePredictions);
            await migrator.createTable(notificationPreferences);
            await migrator.createTable(backupManifests);
            await _createV27Indexes();
            await _writeMetadata(isMigration: true);
          }
          if (from < 28) {
            await migrator.createTable(gymExercises);
            await migrator.createTable(gymWorkoutPlans);
            await migrator.createTable(gymPlanRoutines);
            await migrator.createTable(gymPlanRoutineExercises);
            await migrator.createTable(gymWorkoutSessions);
            await migrator.createTable(gymSetLogs);
            await migrator.createTable(gym1RmHistories);
            await _createV28Indexes();
            await _writeMetadata(isMigration: true);
          }
        },
        beforeOpen: (_) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _createV26Indexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_consumed_foods_date_meal '
      'ON ConsumedFoods(date, meal_name)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_consumed_foods_uuid '
      'ON ConsumedFoods(uuid) WHERE uuid IS NOT NULL',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_saved_meals_uuid '
      'ON SavedMeals(uuid) WHERE uuid IS NOT NULL',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_local_foods_uuid '
      'ON LocalFoods(uuid) WHERE uuid IS NOT NULL',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_food_usage_last_used '
      'ON FoodUsage(last_used_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_offline_queue_created '
      'ON OfflineQueue(created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_weight_entries_date '
      'ON WeightEntries(date)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_weight_entries_uuid '
      'ON WeightEntries(uuid) WHERE uuid IS NOT NULL',
    );
  }

  Future<void> _backfillLegacyUuids() async {
    const uuid = Uuid();
    for (final table in const [
      'ConsumedFoods',
      'SavedMeals',
      'LocalFoods',
      'WeightEntries',
    ]) {
      final rows = await customSelect('SELECT id, uuid FROM $table').get();
      for (final row in rows) {
        final existing = row.readNullable<String>('uuid');
        if (existing != null && existing.isNotEmpty) continue;
        final id = row.read<int>('id');
        final value = uuid.v5(
          Namespace.url.value,
          'macromate://legacy/$table/$id',
        );
        await customStatement(
          "UPDATE $table SET uuid = '$value' WHERE id = $id",
        );
      }
    }
  }

  Future<void> _writeMetadata({required bool isMigration}) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await into(appDatabaseMetadata).insertOnConflictUpdate(
      AppDatabaseMetadataCompanion.insert(
        id: const Value(1),
        schemaVersion: schemaVersion,
        createdAtUtc: isMigration ? now : now,
        migratedAtUtc: now,
      ),
    );
  }

  Future<void> _createV27Indexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_health_records_local_day '
      'ON health_records(local_day, type)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_health_records_source '
      'ON health_records(source_id, start_utc)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sleep_sessions_start '
      'ON sleep_sessions(start_utc)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_workout_sessions_start '
      'ON workout_sessions(start_utc)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_cycle_daily_logs_day '
      'ON cycle_daily_logs(day)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_symptom_logs_day '
      'ON symptom_logs(day)',
    );
  }

  Future<void> _createV28Indexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_gym_plan_routines_plan '
      'ON gym_plan_routines(plan_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_gym_plan_routine_exercises_routine '
      'ON gym_plan_routine_exercises(routine_id, order_index)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_gym_workout_sessions_start '
      'ON gym_workout_sessions(start_utc)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_gym_set_logs_session '
      'ON gym_set_logs(session_id, set_index)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_gym_set_logs_exercise '
      'ON gym_set_logs(exercise_id, logged_at_utc)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_gym_1rm_history_exercise '
      'ON gym1_rm_histories(exercise_id, date)',
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documents = await getApplicationDocumentsDirectory();
    final file = File(p.join(documents.path, 'food_database.db'));
    return NativeDatabase.createInBackground(file);
  });
}
