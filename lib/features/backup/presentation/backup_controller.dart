import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/logging/app_logger.dart';
import '../../../models/food_item.dart';
import '../../../models/saved_meal.dart';
import '../../../services/encrypted_backup_service.dart';
import '../../cycle/domain/cycle_models.dart';
import '../../cycle/domain/cycle_repository.dart';
import '../../health/domain/health_repository.dart';
import '../../nutrition/domain/nutrition_repository.dart';
import '../../settings/domain/settings_models.dart';
import '../../settings/domain/settings_repository.dart';
import '../../weight/domain/weight_repository.dart';

class BackupController extends ChangeNotifier {
  BackupController({
    required AppDatabase database,
    required NutritionRepository nutritionRepository,
    required WeightRepository weightRepository,
    required SettingsRepository settingsRepository,
    required CycleRepository cycleRepository,
    required HealthRepository healthRepository,
    EncryptedBackupService? backupService,
    AppLogger logger = const AppLogger(),
  })  : _database = database,
        _nutritionRepository = nutritionRepository,
        _weightRepository = weightRepository,
        _settingsRepository = settingsRepository,
        _cycleRepository = cycleRepository,
        _healthRepository = healthRepository,
        _backupService = backupService ?? EncryptedBackupService(),
        _logger = logger;

  final AppDatabase _database;
  final NutritionRepository _nutritionRepository;
  final WeightRepository _weightRepository;
  final SettingsRepository _settingsRepository;
  final CycleRepository _cycleRepository;
  final HealthRepository _healthRepository;
  final EncryptedBackupService _backupService;
  final AppLogger _logger;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  String? _lastError;
  String? get lastError => _lastError;

  static const Set<String> allCategories = {
    'nutrition',
    'weights',
    'settings',
    'cycle',
    'health',
  };

  Future<String> exportBackup({
    required String password,
    Set<String>? categories,
  }) async {
    _isProcessing = true;
    _statusMessage = 'Backup wird erstellt...';
    _lastError = null;
    notifyListeners();

    try {
      final cats = categories ?? allCategories;
      final payload = <String, dynamic>{
        'categories': cats.toList(),
        'exported_at': DateTime.now().toUtc().toIso8601String(),
      };

      if (cats.contains('nutrition')) {
        final foods = await _nutritionRepository.searchFoods('');
        payload['foods'] = foods.map((f) => f.toMap()).toList();

        final savedMeals = await _nutritionRepository.getSavedMeals();
        payload['saved_meals'] = savedMeals.map((m) => m.toMap()).toList();

        // Export last 365 days of consumed foods
        final now = DateTime.now();
        final dailyEntries = <String, dynamic>{};
        for (var i = 0; i < 365; i++) {
          final date = now.subtract(Duration(days: i));
          final dateStr = DateFormat('yyyy-MM-dd').format(date);
          final daily = await _nutritionRepository.getDailyFoods(dateStr);
          final hasItems = (daily['breakfast']?.isNotEmpty ?? false) ||
              (daily['lunch']?.isNotEmpty ?? false) ||
              (daily['dinner']?.isNotEmpty ?? false) ||
              (daily['snacks']?.isNotEmpty ?? false);
          if (hasItems) {
            dailyEntries[dateStr] = {
              'breakfast': daily['breakfast']?.map((e) => e.toMap()).toList() ?? [],
              'lunch': daily['lunch']?.map((e) => e.toMap()).toList() ?? [],
              'dinner': daily['dinner']?.map((e) => e.toMap()).toList() ?? [],
              'snacks': daily['snacks']?.map((e) => e.toMap()).toList() ?? [],
            };
          }
        }
        payload['daily_foods'] = dailyEntries;
      }

      if (cats.contains('weights')) {
        final weights = await _weightRepository.list();
        payload['weights'] = weights
            .map((w) => {
                  'day': DateFormat('yyyy-MM-dd').format(w.day),
                  'kilograms': w.kilograms,
                })
            .toList();
      }

      if (cats.contains('settings')) {
        final settings = await _settingsRepository.getSettings();
        final goals = await _settingsRepository.getGoals();
        payload['settings'] = settings.toMap();
        payload['goals'] = goals.toMap();
      }

      if (cats.contains('cycle')) {
        final periods = await _cycleRepository.periods();
        final logs = await _cycleRepository.dailyLogs();
        final profile = await _cycleRepository.profile();
        payload['cycle_profile'] = profile.toMap();
        payload['cycle_periods'] = periods.map((p) => p.toMap()).toList();
        payload['cycle_logs'] = logs.map((l) => l.toMap()).toList();
      }

      if (cats.contains('health')) {
        final summaries = await _healthRepository.summaries(
          startDay: DateTime.now().subtract(const Duration(days: 365)),
          endDay: DateTime.now(),
        );
        payload['health_summaries'] = summaries
            .map((a) => {
                  'day': DateFormat('yyyy-MM-dd').format(a.day),
                  'steps': a.steps,
                  'activeCalories': a.activeCalories,
                  'averageHeartRate': a.averageHeartRate,
                  'sleepMinutes': a.sleepMinutes,
                })
            .toList();
      }

      final encrypted = await _backupService.encrypt(
        payload,
        password: password,
      );

      _statusMessage = 'Backup erfolgreich verschlüsselt.';
      return encrypted;
    } catch (e) {
      _lastError = 'Export fehlgeschlagen: $e';
      _logger.error('export_backup', e);
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> inspectBackup({
    required String encryptedJson,
    required String password,
  }) async {
    try {
      final decrypted = await _backupService.decrypt(
        encryptedJson,
        password: password,
      );

      final preview = <String, dynamic>{
        'valid': true,
        'exported_at': decrypted['exported_at'],
        'categories': decrypted['categories'] ?? [],
        'foods_count': (decrypted['foods'] as List?)?.length ?? 0,
        'saved_meals_count': (decrypted['saved_meals'] as List?)?.length ?? 0,
        'weights_count': (decrypted['weights'] as List?)?.length ?? 0,
        'cycle_periods_count': (decrypted['cycle_periods'] as List?)?.length ?? 0,
        'cycle_logs_count': (decrypted['cycle_logs'] as List?)?.length ?? 0,
        'health_summaries_count': (decrypted['health_summaries'] as List?)?.length ?? 0,
        'has_settings': decrypted.containsKey('settings'),
        'has_goals': decrypted.containsKey('goals'),
        'raw_payload': decrypted,
      };

      return preview;
    } catch (e) {
      _lastError = 'Entschlüsselung fehlgeschlagen: $e';
      rethrow;
    }
  }

  Future<bool> restoreBackup({
    required String encryptedJson,
    required String password,
    Set<String>? selectedCategories,
  }) async {
    _isProcessing = true;
    _statusMessage = 'Backup wird wiederhergestellt...';
    _lastError = null;
    notifyListeners();

    try {
      final decrypted = await _backupService.decrypt(
        encryptedJson,
        password: password,
      );

      final cats = selectedCategories ?? allCategories;

      await _database.transaction(() async {
        // 1. Settings & Goals
        if (cats.contains('settings')) {
          if (decrypted['settings'] is Map) {
            final s = UserSettings.fromMap(Map<String, dynamic>.from(decrypted['settings']));
            await _settingsRepository.updateSettings(s);
          }
          if (decrypted['goals'] is Map) {
            final g = UserGoals.fromMap(Map<String, dynamic>.from(decrypted['goals']));
            await _settingsRepository.updateGoals(g);
          }
        }

        // 2. Nutrition
        if (cats.contains('nutrition')) {
          if (decrypted['foods'] is List) {
            for (final f in decrypted['foods']) {
              final food = FoodItem.fromMap(Map<String, dynamic>.from(f));
              await _nutritionRepository.saveFood(food);
            }
          }
          if (decrypted['saved_meals'] is List) {
            for (final m in decrypted['saved_meals']) {
              final meal = SavedMeal.fromMap(Map<String, dynamic>.from(m));
              await _nutritionRepository.saveMeal(
                name: meal.name,
                defaultMealName: meal.defaultMealName,
                ingredients: meal.ingredients
                    .map((i) => {
                          'food_id': i.food.id ?? 0,
                          'quantity': i.quantity,
                        })
                    .toList(),
                recipeTotalWeight: meal.recipeTotalWeight,
              );
            }
          }
          if (decrypted['daily_foods'] is Map) {
            final dailyMap = Map<String, dynamic>.from(decrypted['daily_foods']);
            for (final entry in dailyMap.entries) {
              final dateStr = entry.key;
              final meals = Map<String, dynamic>.from(entry.value);
              for (final mealName in ['breakfast', 'lunch', 'dinner', 'snacks']) {
                final items = meals[mealName] as List? ?? [];
                for (final item in items) {
                  final map = Map<String, dynamic>.from(item);
                  final foodMap = Map<String, dynamic>.from(map['food'] ?? {});
                  final food = await _nutritionRepository.saveFood(FoodItem.fromMap(foodMap));
                  final qty = (map['quantity'] as num?)?.toInt() ?? 100;
                  await _nutritionRepository.addConsumedFood(
                    date: dateStr,
                    mealName: mealName,
                    foodId: food.id!,
                    quantity: qty,
                  );
                }
              }
            }
          }
        }

        // 3. Weights
        if (cats.contains('weights') && decrypted['weights'] is List) {
          for (final w in decrypted['weights']) {
            final day = DateTime.parse(w['day'] as String);
            final kg = (w['kilograms'] as num).toDouble();
            await _weightRepository.add(day: day, kilograms: kg);
          }
        }

        // 4. Cycle
        if (cats.contains('cycle')) {
          if (decrypted['cycle_profile'] is Map) {
            final profile = CycleProfile.fromMap(Map<String, dynamic>.from(decrypted['cycle_profile']));
            await _cycleRepository.saveProfile(profile);
          }
          if (decrypted['cycle_periods'] is List) {
            for (final p in decrypted['cycle_periods']) {
              final period = PeriodEntry.fromMap(Map<String, dynamic>.from(p));
              await _cycleRepository.addPeriod(
                startDay: period.startDay,
                endDay: period.endDay,
                flow: period.flow,
              );
            }
          }
          if (decrypted['cycle_logs'] is List) {
            for (final l in decrypted['cycle_logs']) {
              final log = CycleDailyLog.fromMap(Map<String, dynamic>.from(l));
              await _cycleRepository.saveDailyLog(log);
            }
          }
        }

        // 5. Health
        if (cats.contains('health') && decrypted['health_summaries'] is List) {
          for (final a in decrypted['health_summaries']) {
            final day = DateTime.parse(a['day'] as String);
            final dayStr = DateFormat('yyyy-MM-dd').format(day);
            await _database.into(_database.dailyHealthAggregates).insertOnConflictUpdate(
                  DailyHealthAggregatesCompanion.insert(
                    day: dayStr,
                    steps: Value((a['steps'] as num?)?.toInt() ?? 0),
                    activeKcal: Value((a['activeCalories'] as num?)?.toDouble() ?? 0.0),
                    heartRateAvg: Value((a['averageHeartRate'] as num?)?.toDouble()),
                    sleepMinutes: Value((a['sleepMinutes'] as num?)?.toDouble()),
                    updatedAtUtc: DateTime.now().toUtc().toIso8601String(),
                  ),
                );
          }
        }
      });

      _statusMessage = 'Wiederherstellung erfolgreich abgeschlossen.';
      return true;
    } catch (e) {
      _lastError = 'Wiederherstellung fehlgeschlagen: $e';
      _logger.error('restore_backup', e);
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
