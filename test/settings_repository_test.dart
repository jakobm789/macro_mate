import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/core/database/app_database.dart';
import 'package:macro_mate/features/settings/data/drift_settings_repository.dart';
import 'package:macro_mate/features/settings/domain/settings_models.dart';
import 'package:macro_mate/features/settings/presentation/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late DriftSettingsRepository repo;
  late SettingsController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftSettingsRepository(database: db);
    controller = SettingsController(repository: repo);
    await controller.initialize();
  });

  tearDown(() async {
    await db.close();
  });

  test('loads and updates settings and goals', () async {
    expect(controller.settings.darkMode, isFalse);
    expect(controller.goals.dailyCalories, 2000);

    await controller.toggleDarkMode(true);
    expect(controller.isDarkMode, isTrue);

    await controller.updateGoals(
      controller.goals.copyWith(
        dailyCalories: 2400,
        carbPercentage: 45,
        proteinPercentage: 35,
        fatPercentage: 20,
      ),
    );

    expect(controller.goals.dailyCalories, 2400);
    expect(controller.dailyCarbGoal, (2400 * 0.45) / 4.0);
    expect(controller.dailyProteinGoal, (2400 * 0.35) / 4.0);
    expect(controller.dailyFatGoal, (2400 * 0.20) / 9.0);
  });

  test('calculates BMR and TDEE correctly for Mifflin and Harris formulas',
      () async {
    // Male, 80kg, 180cm, 30 years old, activity level 1.5
    await controller.updateGoals(
      controller.goals.copyWith(
        userHeight: 180,
        userAge: 30,
        userActivityLevel: 1.5,
        gender: Gender.male,
        bmrFormula: BmrFormula.mifflin,
      ),
    );

    // Mifflin Male: 10*80 + 6.25*180 - 5*30 + 5 = 800 + 1125 - 150 + 5 = 1780
    final mifflinBmr = controller.calculateBmr(weightKg: 80);
    expect(mifflinBmr, 1780.0);
    expect(controller.calculateTdee(weightKg: 80), 1780.0 * 1.5);

    // Harris-Benedict Male: 66.5 + 13.75*80 + 5.003*180 - 6.75*30 = 66.5 + 1100 + 900.54 - 202.5 = 1864.54
    await controller.updateGoals(
      controller.goals.copyWith(bmrFormula: BmrFormula.harris),
    );
    final harrisBmr = controller.calculateBmr(weightKg: 80);
    expect(harrisBmr, closeTo(1864.54, 0.1));
  });

  test('calculates auto calorie goals with diet, bulk, and safety bounds',
      () async {
    await controller.updateGoals(
      controller.goals.copyWith(
        userHeight: 180,
        userAge: 30,
        userActivityLevel: 1.2,
        gender: Gender.male,
        bmrFormula: BmrFormula.mifflin,
      ),
    );

    // TDEE = 1780 * 1.2 = 2136
    // Diet: 1% weight loss / week = 0.8 kg/wk -> 0.8 * 7700 / 7 = 880 deficit -> 2136 - 880 = 1256
    await controller.updateGoals(
      controller.goals.copyWith(autoCalorieMode: AutoCalorieMode.diet),
    );
    final dietGoal = controller.calculateAutoCalorieGoal(currentWeightKg: 80);
    expect(dietGoal, 1256);

    // Bulk: surplus of ~350 kcal -> 2136 + 350 = 2486
    await controller.updateGoals(
      controller.goals.copyWith(autoCalorieMode: AutoCalorieMode.bulk),
    );
    final bulkGoal = controller.calculateAutoCalorieGoal(currentWeightKg: 80);
    expect(bulkGoal, 2486);

    // Minimum safety bound is 1200 kcal
    await controller.updateGoals(
      controller.goals.copyWith(
        userHeight: 150,
        userAge: 60,
        userActivityLevel: 1.0,
        gender: Gender.female,
        autoCalorieMode: AutoCalorieMode.diet,
      ),
    );
    final lowWeightGoal =
        controller.calculateAutoCalorieGoal(currentWeightKg: 45);
    expect(lowWeightGoal, greaterThanOrEqualTo(1200));
  });

  test('resets goals and database', () async {
    await controller.updateGoals(
      controller.goals.copyWith(dailyCalories: 3500),
    );
    expect(controller.goals.dailyCalories, 3500);

    await controller.resetGoals();
    expect(controller.goals.dailyCalories, 2000);
  });
}
