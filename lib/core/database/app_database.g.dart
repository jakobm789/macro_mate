// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dailyCaloriesMeta =
      const VerificationMeta('dailyCalories');
  @override
  late final GeneratedColumn<int> dailyCalories = GeneratedColumn<int>(
      'daily_calories', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _carbPercentageMeta =
      const VerificationMeta('carbPercentage');
  @override
  late final GeneratedColumn<int> carbPercentage = GeneratedColumn<int>(
      'carb_percentage', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _proteinPercentageMeta =
      const VerificationMeta('proteinPercentage');
  @override
  late final GeneratedColumn<int> proteinPercentage = GeneratedColumn<int>(
      'protein_percentage', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fatPercentageMeta =
      const VerificationMeta('fatPercentage');
  @override
  late final GeneratedColumn<int> fatPercentage = GeneratedColumn<int>(
      'fat_percentage', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sugarPercentageMeta =
      const VerificationMeta('sugarPercentage');
  @override
  late final GeneratedColumn<int> sugarPercentage = GeneratedColumn<int>(
      'sugar_percentage', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _autoCalorieModeMeta =
      const VerificationMeta('autoCalorieMode');
  @override
  late final GeneratedColumn<int> autoCalorieMode = GeneratedColumn<int>(
      'auto_calorie_mode', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _customPercentPerMonthMeta =
      const VerificationMeta('customPercentPerMonth');
  @override
  late final GeneratedColumn<double> customPercentPerMonth =
      GeneratedColumn<double>('custom_percent_per_month', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(1.0));
  static const VerificationMeta _useCustomStartCaloriesMeta =
      const VerificationMeta('useCustomStartCalories');
  @override
  late final GeneratedColumn<int> useCustomStartCalories = GeneratedColumn<int>(
      'use_custom_start_calories', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _userStartCaloriesMeta =
      const VerificationMeta('userStartCalories');
  @override
  late final GeneratedColumn<int> userStartCalories = GeneratedColumn<int>(
      'user_start_calories', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2000));
  static const VerificationMeta _userAgeMeta =
      const VerificationMeta('userAge');
  @override
  late final GeneratedColumn<int> userAge = GeneratedColumn<int>(
      'user_age', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(30));
  static const VerificationMeta _userActivityLevelMeta =
      const VerificationMeta('userActivityLevel');
  @override
  late final GeneratedColumn<double> userActivityLevel =
      GeneratedColumn<double>('user_activity_level', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(1.3));
  static const VerificationMeta _lastMondayCheckMeta =
      const VerificationMeta('lastMondayCheck');
  @override
  late final GeneratedColumn<String> lastMondayCheck = GeneratedColumn<String>(
      'last_monday_check', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _firstWeekInitializedMeta =
      const VerificationMeta('firstWeekInitialized');
  @override
  late final GeneratedColumn<int> firstWeekInitialized = GeneratedColumn<int>(
      'first_week_initialized', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _userHeightMeta =
      const VerificationMeta('userHeight');
  @override
  late final GeneratedColumn<double> userHeight = GeneratedColumn<double>(
      'user_height', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(170));
  static const VerificationMeta _useProteinPerKgMeta =
      const VerificationMeta('useProteinPerKg');
  @override
  late final GeneratedColumn<int> useProteinPerKg = GeneratedColumn<int>(
      'use_protein_per_kg', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _proteinPerKgMeta =
      const VerificationMeta('proteinPerKg');
  @override
  late final GeneratedColumn<double> proteinPerKg = GeneratedColumn<double>(
      'protein_per_kg', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2.0));
  static const VerificationMeta _targetWeightMeta =
      const VerificationMeta('targetWeight');
  @override
  late final GeneratedColumn<double> targetWeight = GeneratedColumn<double>(
      'target_weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _targetDateMeta =
      const VerificationMeta('targetDate');
  @override
  late final GeneratedColumn<String> targetDate = GeneratedColumn<String>(
      'target_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _targetWeeklyChangeMeta =
      const VerificationMeta('targetWeeklyChange');
  @override
  late final GeneratedColumn<double> targetWeeklyChange =
      GeneratedColumn<double>('target_weekly_change', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dailyCalories,
        carbPercentage,
        proteinPercentage,
        fatPercentage,
        sugarPercentage,
        autoCalorieMode,
        customPercentPerMonth,
        useCustomStartCalories,
        userStartCalories,
        userAge,
        userActivityLevel,
        lastMondayCheck,
        firstWeekInitialized,
        userHeight,
        useProteinPerKg,
        proteinPerKg,
        targetWeight,
        targetDate,
        targetWeeklyChange
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Goals';
  @override
  VerificationContext validateIntegrity(Insertable<GoalRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('daily_calories')) {
      context.handle(
          _dailyCaloriesMeta,
          dailyCalories.isAcceptableOrUnknown(
              data['daily_calories']!, _dailyCaloriesMeta));
    } else if (isInserting) {
      context.missing(_dailyCaloriesMeta);
    }
    if (data.containsKey('carb_percentage')) {
      context.handle(
          _carbPercentageMeta,
          carbPercentage.isAcceptableOrUnknown(
              data['carb_percentage']!, _carbPercentageMeta));
    } else if (isInserting) {
      context.missing(_carbPercentageMeta);
    }
    if (data.containsKey('protein_percentage')) {
      context.handle(
          _proteinPercentageMeta,
          proteinPercentage.isAcceptableOrUnknown(
              data['protein_percentage']!, _proteinPercentageMeta));
    } else if (isInserting) {
      context.missing(_proteinPercentageMeta);
    }
    if (data.containsKey('fat_percentage')) {
      context.handle(
          _fatPercentageMeta,
          fatPercentage.isAcceptableOrUnknown(
              data['fat_percentage']!, _fatPercentageMeta));
    } else if (isInserting) {
      context.missing(_fatPercentageMeta);
    }
    if (data.containsKey('sugar_percentage')) {
      context.handle(
          _sugarPercentageMeta,
          sugarPercentage.isAcceptableOrUnknown(
              data['sugar_percentage']!, _sugarPercentageMeta));
    } else if (isInserting) {
      context.missing(_sugarPercentageMeta);
    }
    if (data.containsKey('auto_calorie_mode')) {
      context.handle(
          _autoCalorieModeMeta,
          autoCalorieMode.isAcceptableOrUnknown(
              data['auto_calorie_mode']!, _autoCalorieModeMeta));
    }
    if (data.containsKey('custom_percent_per_month')) {
      context.handle(
          _customPercentPerMonthMeta,
          customPercentPerMonth.isAcceptableOrUnknown(
              data['custom_percent_per_month']!, _customPercentPerMonthMeta));
    }
    if (data.containsKey('use_custom_start_calories')) {
      context.handle(
          _useCustomStartCaloriesMeta,
          useCustomStartCalories.isAcceptableOrUnknown(
              data['use_custom_start_calories']!, _useCustomStartCaloriesMeta));
    }
    if (data.containsKey('user_start_calories')) {
      context.handle(
          _userStartCaloriesMeta,
          userStartCalories.isAcceptableOrUnknown(
              data['user_start_calories']!, _userStartCaloriesMeta));
    }
    if (data.containsKey('user_age')) {
      context.handle(_userAgeMeta,
          userAge.isAcceptableOrUnknown(data['user_age']!, _userAgeMeta));
    }
    if (data.containsKey('user_activity_level')) {
      context.handle(
          _userActivityLevelMeta,
          userActivityLevel.isAcceptableOrUnknown(
              data['user_activity_level']!, _userActivityLevelMeta));
    }
    if (data.containsKey('last_monday_check')) {
      context.handle(
          _lastMondayCheckMeta,
          lastMondayCheck.isAcceptableOrUnknown(
              data['last_monday_check']!, _lastMondayCheckMeta));
    }
    if (data.containsKey('first_week_initialized')) {
      context.handle(
          _firstWeekInitializedMeta,
          firstWeekInitialized.isAcceptableOrUnknown(
              data['first_week_initialized']!, _firstWeekInitializedMeta));
    }
    if (data.containsKey('user_height')) {
      context.handle(
          _userHeightMeta,
          userHeight.isAcceptableOrUnknown(
              data['user_height']!, _userHeightMeta));
    }
    if (data.containsKey('use_protein_per_kg')) {
      context.handle(
          _useProteinPerKgMeta,
          useProteinPerKg.isAcceptableOrUnknown(
              data['use_protein_per_kg']!, _useProteinPerKgMeta));
    }
    if (data.containsKey('protein_per_kg')) {
      context.handle(
          _proteinPerKgMeta,
          proteinPerKg.isAcceptableOrUnknown(
              data['protein_per_kg']!, _proteinPerKgMeta));
    }
    if (data.containsKey('target_weight')) {
      context.handle(
          _targetWeightMeta,
          targetWeight.isAcceptableOrUnknown(
              data['target_weight']!, _targetWeightMeta));
    }
    if (data.containsKey('target_date')) {
      context.handle(
          _targetDateMeta,
          targetDate.isAcceptableOrUnknown(
              data['target_date']!, _targetDateMeta));
    }
    if (data.containsKey('target_weekly_change')) {
      context.handle(
          _targetWeeklyChangeMeta,
          targetWeeklyChange.isAcceptableOrUnknown(
              data['target_weekly_change']!, _targetWeeklyChangeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dailyCalories: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}daily_calories'])!,
      carbPercentage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}carb_percentage'])!,
      proteinPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}protein_percentage'])!,
      fatPercentage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fat_percentage'])!,
      sugarPercentage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sugar_percentage'])!,
      autoCalorieMode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}auto_calorie_mode'])!,
      customPercentPerMonth: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}custom_percent_per_month'])!,
      useCustomStartCalories: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}use_custom_start_calories'])!,
      userStartCalories: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}user_start_calories'])!,
      userAge: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_age'])!,
      userActivityLevel: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}user_activity_level'])!,
      lastMondayCheck: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_monday_check']),
      firstWeekInitialized: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}first_week_initialized'])!,
      userHeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}user_height'])!,
      useProteinPerKg: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}use_protein_per_kg'])!,
      proteinPerKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}protein_per_kg'])!,
      targetWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_weight']),
      targetDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_date']),
      targetWeeklyChange: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}target_weekly_change']),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class GoalRow extends DataClass implements Insertable<GoalRow> {
  final int id;
  final int dailyCalories;
  final int carbPercentage;
  final int proteinPercentage;
  final int fatPercentage;
  final int sugarPercentage;
  final int autoCalorieMode;
  final double customPercentPerMonth;
  final int useCustomStartCalories;
  final int userStartCalories;
  final int userAge;
  final double userActivityLevel;
  final String? lastMondayCheck;
  final int firstWeekInitialized;
  final double userHeight;
  final int useProteinPerKg;
  final double proteinPerKg;
  final double? targetWeight;
  final String? targetDate;
  final double? targetWeeklyChange;
  const GoalRow(
      {required this.id,
      required this.dailyCalories,
      required this.carbPercentage,
      required this.proteinPercentage,
      required this.fatPercentage,
      required this.sugarPercentage,
      required this.autoCalorieMode,
      required this.customPercentPerMonth,
      required this.useCustomStartCalories,
      required this.userStartCalories,
      required this.userAge,
      required this.userActivityLevel,
      this.lastMondayCheck,
      required this.firstWeekInitialized,
      required this.userHeight,
      required this.useProteinPerKg,
      required this.proteinPerKg,
      this.targetWeight,
      this.targetDate,
      this.targetWeeklyChange});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daily_calories'] = Variable<int>(dailyCalories);
    map['carb_percentage'] = Variable<int>(carbPercentage);
    map['protein_percentage'] = Variable<int>(proteinPercentage);
    map['fat_percentage'] = Variable<int>(fatPercentage);
    map['sugar_percentage'] = Variable<int>(sugarPercentage);
    map['auto_calorie_mode'] = Variable<int>(autoCalorieMode);
    map['custom_percent_per_month'] = Variable<double>(customPercentPerMonth);
    map['use_custom_start_calories'] = Variable<int>(useCustomStartCalories);
    map['user_start_calories'] = Variable<int>(userStartCalories);
    map['user_age'] = Variable<int>(userAge);
    map['user_activity_level'] = Variable<double>(userActivityLevel);
    if (!nullToAbsent || lastMondayCheck != null) {
      map['last_monday_check'] = Variable<String>(lastMondayCheck);
    }
    map['first_week_initialized'] = Variable<int>(firstWeekInitialized);
    map['user_height'] = Variable<double>(userHeight);
    map['use_protein_per_kg'] = Variable<int>(useProteinPerKg);
    map['protein_per_kg'] = Variable<double>(proteinPerKg);
    if (!nullToAbsent || targetWeight != null) {
      map['target_weight'] = Variable<double>(targetWeight);
    }
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<String>(targetDate);
    }
    if (!nullToAbsent || targetWeeklyChange != null) {
      map['target_weekly_change'] = Variable<double>(targetWeeklyChange);
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      dailyCalories: Value(dailyCalories),
      carbPercentage: Value(carbPercentage),
      proteinPercentage: Value(proteinPercentage),
      fatPercentage: Value(fatPercentage),
      sugarPercentage: Value(sugarPercentage),
      autoCalorieMode: Value(autoCalorieMode),
      customPercentPerMonth: Value(customPercentPerMonth),
      useCustomStartCalories: Value(useCustomStartCalories),
      userStartCalories: Value(userStartCalories),
      userAge: Value(userAge),
      userActivityLevel: Value(userActivityLevel),
      lastMondayCheck: lastMondayCheck == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMondayCheck),
      firstWeekInitialized: Value(firstWeekInitialized),
      userHeight: Value(userHeight),
      useProteinPerKg: Value(useProteinPerKg),
      proteinPerKg: Value(proteinPerKg),
      targetWeight: targetWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeight),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      targetWeeklyChange: targetWeeklyChange == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeeklyChange),
    );
  }

  factory GoalRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalRow(
      id: serializer.fromJson<int>(json['id']),
      dailyCalories: serializer.fromJson<int>(json['dailyCalories']),
      carbPercentage: serializer.fromJson<int>(json['carbPercentage']),
      proteinPercentage: serializer.fromJson<int>(json['proteinPercentage']),
      fatPercentage: serializer.fromJson<int>(json['fatPercentage']),
      sugarPercentage: serializer.fromJson<int>(json['sugarPercentage']),
      autoCalorieMode: serializer.fromJson<int>(json['autoCalorieMode']),
      customPercentPerMonth:
          serializer.fromJson<double>(json['customPercentPerMonth']),
      useCustomStartCalories:
          serializer.fromJson<int>(json['useCustomStartCalories']),
      userStartCalories: serializer.fromJson<int>(json['userStartCalories']),
      userAge: serializer.fromJson<int>(json['userAge']),
      userActivityLevel: serializer.fromJson<double>(json['userActivityLevel']),
      lastMondayCheck: serializer.fromJson<String?>(json['lastMondayCheck']),
      firstWeekInitialized:
          serializer.fromJson<int>(json['firstWeekInitialized']),
      userHeight: serializer.fromJson<double>(json['userHeight']),
      useProteinPerKg: serializer.fromJson<int>(json['useProteinPerKg']),
      proteinPerKg: serializer.fromJson<double>(json['proteinPerKg']),
      targetWeight: serializer.fromJson<double?>(json['targetWeight']),
      targetDate: serializer.fromJson<String?>(json['targetDate']),
      targetWeeklyChange:
          serializer.fromJson<double?>(json['targetWeeklyChange']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dailyCalories': serializer.toJson<int>(dailyCalories),
      'carbPercentage': serializer.toJson<int>(carbPercentage),
      'proteinPercentage': serializer.toJson<int>(proteinPercentage),
      'fatPercentage': serializer.toJson<int>(fatPercentage),
      'sugarPercentage': serializer.toJson<int>(sugarPercentage),
      'autoCalorieMode': serializer.toJson<int>(autoCalorieMode),
      'customPercentPerMonth': serializer.toJson<double>(customPercentPerMonth),
      'useCustomStartCalories': serializer.toJson<int>(useCustomStartCalories),
      'userStartCalories': serializer.toJson<int>(userStartCalories),
      'userAge': serializer.toJson<int>(userAge),
      'userActivityLevel': serializer.toJson<double>(userActivityLevel),
      'lastMondayCheck': serializer.toJson<String?>(lastMondayCheck),
      'firstWeekInitialized': serializer.toJson<int>(firstWeekInitialized),
      'userHeight': serializer.toJson<double>(userHeight),
      'useProteinPerKg': serializer.toJson<int>(useProteinPerKg),
      'proteinPerKg': serializer.toJson<double>(proteinPerKg),
      'targetWeight': serializer.toJson<double?>(targetWeight),
      'targetDate': serializer.toJson<String?>(targetDate),
      'targetWeeklyChange': serializer.toJson<double?>(targetWeeklyChange),
    };
  }

  GoalRow copyWith(
          {int? id,
          int? dailyCalories,
          int? carbPercentage,
          int? proteinPercentage,
          int? fatPercentage,
          int? sugarPercentage,
          int? autoCalorieMode,
          double? customPercentPerMonth,
          int? useCustomStartCalories,
          int? userStartCalories,
          int? userAge,
          double? userActivityLevel,
          Value<String?> lastMondayCheck = const Value.absent(),
          int? firstWeekInitialized,
          double? userHeight,
          int? useProteinPerKg,
          double? proteinPerKg,
          Value<double?> targetWeight = const Value.absent(),
          Value<String?> targetDate = const Value.absent(),
          Value<double?> targetWeeklyChange = const Value.absent()}) =>
      GoalRow(
        id: id ?? this.id,
        dailyCalories: dailyCalories ?? this.dailyCalories,
        carbPercentage: carbPercentage ?? this.carbPercentage,
        proteinPercentage: proteinPercentage ?? this.proteinPercentage,
        fatPercentage: fatPercentage ?? this.fatPercentage,
        sugarPercentage: sugarPercentage ?? this.sugarPercentage,
        autoCalorieMode: autoCalorieMode ?? this.autoCalorieMode,
        customPercentPerMonth:
            customPercentPerMonth ?? this.customPercentPerMonth,
        useCustomStartCalories:
            useCustomStartCalories ?? this.useCustomStartCalories,
        userStartCalories: userStartCalories ?? this.userStartCalories,
        userAge: userAge ?? this.userAge,
        userActivityLevel: userActivityLevel ?? this.userActivityLevel,
        lastMondayCheck: lastMondayCheck.present
            ? lastMondayCheck.value
            : this.lastMondayCheck,
        firstWeekInitialized: firstWeekInitialized ?? this.firstWeekInitialized,
        userHeight: userHeight ?? this.userHeight,
        useProteinPerKg: useProteinPerKg ?? this.useProteinPerKg,
        proteinPerKg: proteinPerKg ?? this.proteinPerKg,
        targetWeight:
            targetWeight.present ? targetWeight.value : this.targetWeight,
        targetDate: targetDate.present ? targetDate.value : this.targetDate,
        targetWeeklyChange: targetWeeklyChange.present
            ? targetWeeklyChange.value
            : this.targetWeeklyChange,
      );
  GoalRow copyWithCompanion(GoalsCompanion data) {
    return GoalRow(
      id: data.id.present ? data.id.value : this.id,
      dailyCalories: data.dailyCalories.present
          ? data.dailyCalories.value
          : this.dailyCalories,
      carbPercentage: data.carbPercentage.present
          ? data.carbPercentage.value
          : this.carbPercentage,
      proteinPercentage: data.proteinPercentage.present
          ? data.proteinPercentage.value
          : this.proteinPercentage,
      fatPercentage: data.fatPercentage.present
          ? data.fatPercentage.value
          : this.fatPercentage,
      sugarPercentage: data.sugarPercentage.present
          ? data.sugarPercentage.value
          : this.sugarPercentage,
      autoCalorieMode: data.autoCalorieMode.present
          ? data.autoCalorieMode.value
          : this.autoCalorieMode,
      customPercentPerMonth: data.customPercentPerMonth.present
          ? data.customPercentPerMonth.value
          : this.customPercentPerMonth,
      useCustomStartCalories: data.useCustomStartCalories.present
          ? data.useCustomStartCalories.value
          : this.useCustomStartCalories,
      userStartCalories: data.userStartCalories.present
          ? data.userStartCalories.value
          : this.userStartCalories,
      userAge: data.userAge.present ? data.userAge.value : this.userAge,
      userActivityLevel: data.userActivityLevel.present
          ? data.userActivityLevel.value
          : this.userActivityLevel,
      lastMondayCheck: data.lastMondayCheck.present
          ? data.lastMondayCheck.value
          : this.lastMondayCheck,
      firstWeekInitialized: data.firstWeekInitialized.present
          ? data.firstWeekInitialized.value
          : this.firstWeekInitialized,
      userHeight:
          data.userHeight.present ? data.userHeight.value : this.userHeight,
      useProteinPerKg: data.useProteinPerKg.present
          ? data.useProteinPerKg.value
          : this.useProteinPerKg,
      proteinPerKg: data.proteinPerKg.present
          ? data.proteinPerKg.value
          : this.proteinPerKg,
      targetWeight: data.targetWeight.present
          ? data.targetWeight.value
          : this.targetWeight,
      targetDate:
          data.targetDate.present ? data.targetDate.value : this.targetDate,
      targetWeeklyChange: data.targetWeeklyChange.present
          ? data.targetWeeklyChange.value
          : this.targetWeeklyChange,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalRow(')
          ..write('id: $id, ')
          ..write('dailyCalories: $dailyCalories, ')
          ..write('carbPercentage: $carbPercentage, ')
          ..write('proteinPercentage: $proteinPercentage, ')
          ..write('fatPercentage: $fatPercentage, ')
          ..write('sugarPercentage: $sugarPercentage, ')
          ..write('autoCalorieMode: $autoCalorieMode, ')
          ..write('customPercentPerMonth: $customPercentPerMonth, ')
          ..write('useCustomStartCalories: $useCustomStartCalories, ')
          ..write('userStartCalories: $userStartCalories, ')
          ..write('userAge: $userAge, ')
          ..write('userActivityLevel: $userActivityLevel, ')
          ..write('lastMondayCheck: $lastMondayCheck, ')
          ..write('firstWeekInitialized: $firstWeekInitialized, ')
          ..write('userHeight: $userHeight, ')
          ..write('useProteinPerKg: $useProteinPerKg, ')
          ..write('proteinPerKg: $proteinPerKg, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('targetDate: $targetDate, ')
          ..write('targetWeeklyChange: $targetWeeklyChange')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      dailyCalories,
      carbPercentage,
      proteinPercentage,
      fatPercentage,
      sugarPercentage,
      autoCalorieMode,
      customPercentPerMonth,
      useCustomStartCalories,
      userStartCalories,
      userAge,
      userActivityLevel,
      lastMondayCheck,
      firstWeekInitialized,
      userHeight,
      useProteinPerKg,
      proteinPerKg,
      targetWeight,
      targetDate,
      targetWeeklyChange);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalRow &&
          other.id == this.id &&
          other.dailyCalories == this.dailyCalories &&
          other.carbPercentage == this.carbPercentage &&
          other.proteinPercentage == this.proteinPercentage &&
          other.fatPercentage == this.fatPercentage &&
          other.sugarPercentage == this.sugarPercentage &&
          other.autoCalorieMode == this.autoCalorieMode &&
          other.customPercentPerMonth == this.customPercentPerMonth &&
          other.useCustomStartCalories == this.useCustomStartCalories &&
          other.userStartCalories == this.userStartCalories &&
          other.userAge == this.userAge &&
          other.userActivityLevel == this.userActivityLevel &&
          other.lastMondayCheck == this.lastMondayCheck &&
          other.firstWeekInitialized == this.firstWeekInitialized &&
          other.userHeight == this.userHeight &&
          other.useProteinPerKg == this.useProteinPerKg &&
          other.proteinPerKg == this.proteinPerKg &&
          other.targetWeight == this.targetWeight &&
          other.targetDate == this.targetDate &&
          other.targetWeeklyChange == this.targetWeeklyChange);
}

class GoalsCompanion extends UpdateCompanion<GoalRow> {
  final Value<int> id;
  final Value<int> dailyCalories;
  final Value<int> carbPercentage;
  final Value<int> proteinPercentage;
  final Value<int> fatPercentage;
  final Value<int> sugarPercentage;
  final Value<int> autoCalorieMode;
  final Value<double> customPercentPerMonth;
  final Value<int> useCustomStartCalories;
  final Value<int> userStartCalories;
  final Value<int> userAge;
  final Value<double> userActivityLevel;
  final Value<String?> lastMondayCheck;
  final Value<int> firstWeekInitialized;
  final Value<double> userHeight;
  final Value<int> useProteinPerKg;
  final Value<double> proteinPerKg;
  final Value<double?> targetWeight;
  final Value<String?> targetDate;
  final Value<double?> targetWeeklyChange;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.dailyCalories = const Value.absent(),
    this.carbPercentage = const Value.absent(),
    this.proteinPercentage = const Value.absent(),
    this.fatPercentage = const Value.absent(),
    this.sugarPercentage = const Value.absent(),
    this.autoCalorieMode = const Value.absent(),
    this.customPercentPerMonth = const Value.absent(),
    this.useCustomStartCalories = const Value.absent(),
    this.userStartCalories = const Value.absent(),
    this.userAge = const Value.absent(),
    this.userActivityLevel = const Value.absent(),
    this.lastMondayCheck = const Value.absent(),
    this.firstWeekInitialized = const Value.absent(),
    this.userHeight = const Value.absent(),
    this.useProteinPerKg = const Value.absent(),
    this.proteinPerKg = const Value.absent(),
    this.targetWeight = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.targetWeeklyChange = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required int dailyCalories,
    required int carbPercentage,
    required int proteinPercentage,
    required int fatPercentage,
    required int sugarPercentage,
    this.autoCalorieMode = const Value.absent(),
    this.customPercentPerMonth = const Value.absent(),
    this.useCustomStartCalories = const Value.absent(),
    this.userStartCalories = const Value.absent(),
    this.userAge = const Value.absent(),
    this.userActivityLevel = const Value.absent(),
    this.lastMondayCheck = const Value.absent(),
    this.firstWeekInitialized = const Value.absent(),
    this.userHeight = const Value.absent(),
    this.useProteinPerKg = const Value.absent(),
    this.proteinPerKg = const Value.absent(),
    this.targetWeight = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.targetWeeklyChange = const Value.absent(),
  })  : dailyCalories = Value(dailyCalories),
        carbPercentage = Value(carbPercentage),
        proteinPercentage = Value(proteinPercentage),
        fatPercentage = Value(fatPercentage),
        sugarPercentage = Value(sugarPercentage);
  static Insertable<GoalRow> custom({
    Expression<int>? id,
    Expression<int>? dailyCalories,
    Expression<int>? carbPercentage,
    Expression<int>? proteinPercentage,
    Expression<int>? fatPercentage,
    Expression<int>? sugarPercentage,
    Expression<int>? autoCalorieMode,
    Expression<double>? customPercentPerMonth,
    Expression<int>? useCustomStartCalories,
    Expression<int>? userStartCalories,
    Expression<int>? userAge,
    Expression<double>? userActivityLevel,
    Expression<String>? lastMondayCheck,
    Expression<int>? firstWeekInitialized,
    Expression<double>? userHeight,
    Expression<int>? useProteinPerKg,
    Expression<double>? proteinPerKg,
    Expression<double>? targetWeight,
    Expression<String>? targetDate,
    Expression<double>? targetWeeklyChange,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyCalories != null) 'daily_calories': dailyCalories,
      if (carbPercentage != null) 'carb_percentage': carbPercentage,
      if (proteinPercentage != null) 'protein_percentage': proteinPercentage,
      if (fatPercentage != null) 'fat_percentage': fatPercentage,
      if (sugarPercentage != null) 'sugar_percentage': sugarPercentage,
      if (autoCalorieMode != null) 'auto_calorie_mode': autoCalorieMode,
      if (customPercentPerMonth != null)
        'custom_percent_per_month': customPercentPerMonth,
      if (useCustomStartCalories != null)
        'use_custom_start_calories': useCustomStartCalories,
      if (userStartCalories != null) 'user_start_calories': userStartCalories,
      if (userAge != null) 'user_age': userAge,
      if (userActivityLevel != null) 'user_activity_level': userActivityLevel,
      if (lastMondayCheck != null) 'last_monday_check': lastMondayCheck,
      if (firstWeekInitialized != null)
        'first_week_initialized': firstWeekInitialized,
      if (userHeight != null) 'user_height': userHeight,
      if (useProteinPerKg != null) 'use_protein_per_kg': useProteinPerKg,
      if (proteinPerKg != null) 'protein_per_kg': proteinPerKg,
      if (targetWeight != null) 'target_weight': targetWeight,
      if (targetDate != null) 'target_date': targetDate,
      if (targetWeeklyChange != null)
        'target_weekly_change': targetWeeklyChange,
    });
  }

  GoalsCompanion copyWith(
      {Value<int>? id,
      Value<int>? dailyCalories,
      Value<int>? carbPercentage,
      Value<int>? proteinPercentage,
      Value<int>? fatPercentage,
      Value<int>? sugarPercentage,
      Value<int>? autoCalorieMode,
      Value<double>? customPercentPerMonth,
      Value<int>? useCustomStartCalories,
      Value<int>? userStartCalories,
      Value<int>? userAge,
      Value<double>? userActivityLevel,
      Value<String?>? lastMondayCheck,
      Value<int>? firstWeekInitialized,
      Value<double>? userHeight,
      Value<int>? useProteinPerKg,
      Value<double>? proteinPerKg,
      Value<double?>? targetWeight,
      Value<String?>? targetDate,
      Value<double?>? targetWeeklyChange}) {
    return GoalsCompanion(
      id: id ?? this.id,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      carbPercentage: carbPercentage ?? this.carbPercentage,
      proteinPercentage: proteinPercentage ?? this.proteinPercentage,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      sugarPercentage: sugarPercentage ?? this.sugarPercentage,
      autoCalorieMode: autoCalorieMode ?? this.autoCalorieMode,
      customPercentPerMonth:
          customPercentPerMonth ?? this.customPercentPerMonth,
      useCustomStartCalories:
          useCustomStartCalories ?? this.useCustomStartCalories,
      userStartCalories: userStartCalories ?? this.userStartCalories,
      userAge: userAge ?? this.userAge,
      userActivityLevel: userActivityLevel ?? this.userActivityLevel,
      lastMondayCheck: lastMondayCheck ?? this.lastMondayCheck,
      firstWeekInitialized: firstWeekInitialized ?? this.firstWeekInitialized,
      userHeight: userHeight ?? this.userHeight,
      useProteinPerKg: useProteinPerKg ?? this.useProteinPerKg,
      proteinPerKg: proteinPerKg ?? this.proteinPerKg,
      targetWeight: targetWeight ?? this.targetWeight,
      targetDate: targetDate ?? this.targetDate,
      targetWeeklyChange: targetWeeklyChange ?? this.targetWeeklyChange,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dailyCalories.present) {
      map['daily_calories'] = Variable<int>(dailyCalories.value);
    }
    if (carbPercentage.present) {
      map['carb_percentage'] = Variable<int>(carbPercentage.value);
    }
    if (proteinPercentage.present) {
      map['protein_percentage'] = Variable<int>(proteinPercentage.value);
    }
    if (fatPercentage.present) {
      map['fat_percentage'] = Variable<int>(fatPercentage.value);
    }
    if (sugarPercentage.present) {
      map['sugar_percentage'] = Variable<int>(sugarPercentage.value);
    }
    if (autoCalorieMode.present) {
      map['auto_calorie_mode'] = Variable<int>(autoCalorieMode.value);
    }
    if (customPercentPerMonth.present) {
      map['custom_percent_per_month'] =
          Variable<double>(customPercentPerMonth.value);
    }
    if (useCustomStartCalories.present) {
      map['use_custom_start_calories'] =
          Variable<int>(useCustomStartCalories.value);
    }
    if (userStartCalories.present) {
      map['user_start_calories'] = Variable<int>(userStartCalories.value);
    }
    if (userAge.present) {
      map['user_age'] = Variable<int>(userAge.value);
    }
    if (userActivityLevel.present) {
      map['user_activity_level'] = Variable<double>(userActivityLevel.value);
    }
    if (lastMondayCheck.present) {
      map['last_monday_check'] = Variable<String>(lastMondayCheck.value);
    }
    if (firstWeekInitialized.present) {
      map['first_week_initialized'] = Variable<int>(firstWeekInitialized.value);
    }
    if (userHeight.present) {
      map['user_height'] = Variable<double>(userHeight.value);
    }
    if (useProteinPerKg.present) {
      map['use_protein_per_kg'] = Variable<int>(useProteinPerKg.value);
    }
    if (proteinPerKg.present) {
      map['protein_per_kg'] = Variable<double>(proteinPerKg.value);
    }
    if (targetWeight.present) {
      map['target_weight'] = Variable<double>(targetWeight.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<String>(targetDate.value);
    }
    if (targetWeeklyChange.present) {
      map['target_weekly_change'] = Variable<double>(targetWeeklyChange.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('dailyCalories: $dailyCalories, ')
          ..write('carbPercentage: $carbPercentage, ')
          ..write('proteinPercentage: $proteinPercentage, ')
          ..write('fatPercentage: $fatPercentage, ')
          ..write('sugarPercentage: $sugarPercentage, ')
          ..write('autoCalorieMode: $autoCalorieMode, ')
          ..write('customPercentPerMonth: $customPercentPerMonth, ')
          ..write('useCustomStartCalories: $useCustomStartCalories, ')
          ..write('userStartCalories: $userStartCalories, ')
          ..write('userAge: $userAge, ')
          ..write('userActivityLevel: $userActivityLevel, ')
          ..write('lastMondayCheck: $lastMondayCheck, ')
          ..write('firstWeekInitialized: $firstWeekInitialized, ')
          ..write('userHeight: $userHeight, ')
          ..write('useProteinPerKg: $useProteinPerKg, ')
          ..write('proteinPerKg: $proteinPerKg, ')
          ..write('targetWeight: $targetWeight, ')
          ..write('targetDate: $targetDate, ')
          ..write('targetWeeklyChange: $targetWeeklyChange')
          ..write(')'))
        .toString();
  }
}

class $ConsumedFoodsTable extends ConsumedFoods
    with TableInfo<$ConsumedFoodsTable, ConsumedFoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsumedFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mealNameMeta =
      const VerificationMeta('mealName');
  @override
  late final GeneratedColumn<String> mealName = GeneratedColumn<String>(
      'meal_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
      'food_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, mealName, foodId, quantity, uuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ConsumedFoods';
  @override
  VerificationContext validateIntegrity(Insertable<ConsumedFoodRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('meal_name')) {
      context.handle(_mealNameMeta,
          mealName.isAcceptableOrUnknown(data['meal_name']!, _mealNameMeta));
    } else if (isInserting) {
      context.missing(_mealNameMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(_foodIdMeta,
          foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta));
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConsumedFoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConsumedFoodRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      mealName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal_name'])!,
      foodId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}food_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid']),
    );
  }

  @override
  $ConsumedFoodsTable createAlias(String alias) {
    return $ConsumedFoodsTable(attachedDatabase, alias);
  }
}

class ConsumedFoodRow extends DataClass implements Insertable<ConsumedFoodRow> {
  final int id;
  final String date;
  final String mealName;
  final int foodId;
  final int quantity;
  final String? uuid;
  const ConsumedFoodRow(
      {required this.id,
      required this.date,
      required this.mealName,
      required this.foodId,
      required this.quantity,
      this.uuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['meal_name'] = Variable<String>(mealName);
    map['food_id'] = Variable<int>(foodId);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || uuid != null) {
      map['uuid'] = Variable<String>(uuid);
    }
    return map;
  }

  ConsumedFoodsCompanion toCompanion(bool nullToAbsent) {
    return ConsumedFoodsCompanion(
      id: Value(id),
      date: Value(date),
      mealName: Value(mealName),
      foodId: Value(foodId),
      quantity: Value(quantity),
      uuid: uuid == null && nullToAbsent ? const Value.absent() : Value(uuid),
    );
  }

  factory ConsumedFoodRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConsumedFoodRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      mealName: serializer.fromJson<String>(json['mealName']),
      foodId: serializer.fromJson<int>(json['foodId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      uuid: serializer.fromJson<String?>(json['uuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'mealName': serializer.toJson<String>(mealName),
      'foodId': serializer.toJson<int>(foodId),
      'quantity': serializer.toJson<int>(quantity),
      'uuid': serializer.toJson<String?>(uuid),
    };
  }

  ConsumedFoodRow copyWith(
          {int? id,
          String? date,
          String? mealName,
          int? foodId,
          int? quantity,
          Value<String?> uuid = const Value.absent()}) =>
      ConsumedFoodRow(
        id: id ?? this.id,
        date: date ?? this.date,
        mealName: mealName ?? this.mealName,
        foodId: foodId ?? this.foodId,
        quantity: quantity ?? this.quantity,
        uuid: uuid.present ? uuid.value : this.uuid,
      );
  ConsumedFoodRow copyWithCompanion(ConsumedFoodsCompanion data) {
    return ConsumedFoodRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      mealName: data.mealName.present ? data.mealName.value : this.mealName,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConsumedFoodRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('mealName: $mealName, ')
          ..write('foodId: $foodId, ')
          ..write('quantity: $quantity, ')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, mealName, foodId, quantity, uuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsumedFoodRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.mealName == this.mealName &&
          other.foodId == this.foodId &&
          other.quantity == this.quantity &&
          other.uuid == this.uuid);
}

class ConsumedFoodsCompanion extends UpdateCompanion<ConsumedFoodRow> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> mealName;
  final Value<int> foodId;
  final Value<int> quantity;
  final Value<String?> uuid;
  const ConsumedFoodsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.mealName = const Value.absent(),
    this.foodId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.uuid = const Value.absent(),
  });
  ConsumedFoodsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String mealName,
    required int foodId,
    required int quantity,
    this.uuid = const Value.absent(),
  })  : date = Value(date),
        mealName = Value(mealName),
        foodId = Value(foodId),
        quantity = Value(quantity);
  static Insertable<ConsumedFoodRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? mealName,
    Expression<int>? foodId,
    Expression<int>? quantity,
    Expression<String>? uuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (mealName != null) 'meal_name': mealName,
      if (foodId != null) 'food_id': foodId,
      if (quantity != null) 'quantity': quantity,
      if (uuid != null) 'uuid': uuid,
    });
  }

  ConsumedFoodsCompanion copyWith(
      {Value<int>? id,
      Value<String>? date,
      Value<String>? mealName,
      Value<int>? foodId,
      Value<int>? quantity,
      Value<String?>? uuid}) {
    return ConsumedFoodsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      mealName: mealName ?? this.mealName,
      foodId: foodId ?? this.foodId,
      quantity: quantity ?? this.quantity,
      uuid: uuid ?? this.uuid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (mealName.present) {
      map['meal_name'] = Variable<String>(mealName.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<int>(foodId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsumedFoodsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('mealName: $mealName, ')
          ..write('foodId: $foodId, ')
          ..write('quantity: $quantity, ')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }
}

class $SavedMealsTable extends SavedMeals
    with TableInfo<$SavedMealsTable, SavedMealRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedMealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultMealNameMeta =
      const VerificationMeta('defaultMealName');
  @override
  late final GeneratedColumn<String> defaultMealName = GeneratedColumn<String>(
      'default_meal_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recipeTotalWeightMeta =
      const VerificationMeta('recipeTotalWeight');
  @override
  late final GeneratedColumn<int> recipeTotalWeight = GeneratedColumn<int>(
      'recipe_total_weight', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, defaultMealName, createdAt, recipeTotalWeight, uuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'SavedMeals';
  @override
  VerificationContext validateIntegrity(Insertable<SavedMealRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('default_meal_name')) {
      context.handle(
          _defaultMealNameMeta,
          defaultMealName.isAcceptableOrUnknown(
              data['default_meal_name']!, _defaultMealNameMeta));
    } else if (isInserting) {
      context.missing(_defaultMealNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('recipe_total_weight')) {
      context.handle(
          _recipeTotalWeightMeta,
          recipeTotalWeight.isAcceptableOrUnknown(
              data['recipe_total_weight']!, _recipeTotalWeightMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedMealRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedMealRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      defaultMealName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}default_meal_name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      recipeTotalWeight: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}recipe_total_weight']),
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid']),
    );
  }

  @override
  $SavedMealsTable createAlias(String alias) {
    return $SavedMealsTable(attachedDatabase, alias);
  }
}

class SavedMealRow extends DataClass implements Insertable<SavedMealRow> {
  final int id;
  final String name;
  final String defaultMealName;
  final String createdAt;
  final int? recipeTotalWeight;
  final String? uuid;
  const SavedMealRow(
      {required this.id,
      required this.name,
      required this.defaultMealName,
      required this.createdAt,
      this.recipeTotalWeight,
      this.uuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['default_meal_name'] = Variable<String>(defaultMealName);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || recipeTotalWeight != null) {
      map['recipe_total_weight'] = Variable<int>(recipeTotalWeight);
    }
    if (!nullToAbsent || uuid != null) {
      map['uuid'] = Variable<String>(uuid);
    }
    return map;
  }

  SavedMealsCompanion toCompanion(bool nullToAbsent) {
    return SavedMealsCompanion(
      id: Value(id),
      name: Value(name),
      defaultMealName: Value(defaultMealName),
      createdAt: Value(createdAt),
      recipeTotalWeight: recipeTotalWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeTotalWeight),
      uuid: uuid == null && nullToAbsent ? const Value.absent() : Value(uuid),
    );
  }

  factory SavedMealRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedMealRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      defaultMealName: serializer.fromJson<String>(json['defaultMealName']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      recipeTotalWeight: serializer.fromJson<int?>(json['recipeTotalWeight']),
      uuid: serializer.fromJson<String?>(json['uuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'defaultMealName': serializer.toJson<String>(defaultMealName),
      'createdAt': serializer.toJson<String>(createdAt),
      'recipeTotalWeight': serializer.toJson<int?>(recipeTotalWeight),
      'uuid': serializer.toJson<String?>(uuid),
    };
  }

  SavedMealRow copyWith(
          {int? id,
          String? name,
          String? defaultMealName,
          String? createdAt,
          Value<int?> recipeTotalWeight = const Value.absent(),
          Value<String?> uuid = const Value.absent()}) =>
      SavedMealRow(
        id: id ?? this.id,
        name: name ?? this.name,
        defaultMealName: defaultMealName ?? this.defaultMealName,
        createdAt: createdAt ?? this.createdAt,
        recipeTotalWeight: recipeTotalWeight.present
            ? recipeTotalWeight.value
            : this.recipeTotalWeight,
        uuid: uuid.present ? uuid.value : this.uuid,
      );
  SavedMealRow copyWithCompanion(SavedMealsCompanion data) {
    return SavedMealRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      defaultMealName: data.defaultMealName.present
          ? data.defaultMealName.value
          : this.defaultMealName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      recipeTotalWeight: data.recipeTotalWeight.present
          ? data.recipeTotalWeight.value
          : this.recipeTotalWeight,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedMealRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultMealName: $defaultMealName, ')
          ..write('createdAt: $createdAt, ')
          ..write('recipeTotalWeight: $recipeTotalWeight, ')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, defaultMealName, createdAt, recipeTotalWeight, uuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedMealRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.defaultMealName == this.defaultMealName &&
          other.createdAt == this.createdAt &&
          other.recipeTotalWeight == this.recipeTotalWeight &&
          other.uuid == this.uuid);
}

class SavedMealsCompanion extends UpdateCompanion<SavedMealRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> defaultMealName;
  final Value<String> createdAt;
  final Value<int?> recipeTotalWeight;
  final Value<String?> uuid;
  const SavedMealsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.defaultMealName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.recipeTotalWeight = const Value.absent(),
    this.uuid = const Value.absent(),
  });
  SavedMealsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String defaultMealName,
    required String createdAt,
    this.recipeTotalWeight = const Value.absent(),
    this.uuid = const Value.absent(),
  })  : name = Value(name),
        defaultMealName = Value(defaultMealName),
        createdAt = Value(createdAt);
  static Insertable<SavedMealRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? defaultMealName,
    Expression<String>? createdAt,
    Expression<int>? recipeTotalWeight,
    Expression<String>? uuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (defaultMealName != null) 'default_meal_name': defaultMealName,
      if (createdAt != null) 'created_at': createdAt,
      if (recipeTotalWeight != null) 'recipe_total_weight': recipeTotalWeight,
      if (uuid != null) 'uuid': uuid,
    });
  }

  SavedMealsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? defaultMealName,
      Value<String>? createdAt,
      Value<int?>? recipeTotalWeight,
      Value<String?>? uuid}) {
    return SavedMealsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultMealName: defaultMealName ?? this.defaultMealName,
      createdAt: createdAt ?? this.createdAt,
      recipeTotalWeight: recipeTotalWeight ?? this.recipeTotalWeight,
      uuid: uuid ?? this.uuid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (defaultMealName.present) {
      map['default_meal_name'] = Variable<String>(defaultMealName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (recipeTotalWeight.present) {
      map['recipe_total_weight'] = Variable<int>(recipeTotalWeight.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedMealsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultMealName: $defaultMealName, ')
          ..write('createdAt: $createdAt, ')
          ..write('recipeTotalWeight: $recipeTotalWeight, ')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }
}

class $SavedMealIngredientsTable extends SavedMealIngredients
    with TableInfo<$SavedMealIngredientsTable, SavedMealIngredientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedMealIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _savedMealIdMeta =
      const VerificationMeta('savedMealId');
  @override
  late final GeneratedColumn<int> savedMealId = GeneratedColumn<int>(
      'saved_meal_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES SavedMeals (id) ON DELETE CASCADE'));
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
      'food_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, savedMealId, foodId, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'SavedMealIngredients';
  @override
  VerificationContext validateIntegrity(
      Insertable<SavedMealIngredientRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('saved_meal_id')) {
      context.handle(
          _savedMealIdMeta,
          savedMealId.isAcceptableOrUnknown(
              data['saved_meal_id']!, _savedMealIdMeta));
    } else if (isInserting) {
      context.missing(_savedMealIdMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(_foodIdMeta,
          foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta));
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedMealIngredientRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedMealIngredientRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      savedMealId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}saved_meal_id'])!,
      foodId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}food_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
    );
  }

  @override
  $SavedMealIngredientsTable createAlias(String alias) {
    return $SavedMealIngredientsTable(attachedDatabase, alias);
  }
}

class SavedMealIngredientRow extends DataClass
    implements Insertable<SavedMealIngredientRow> {
  final int id;
  final int savedMealId;
  final int foodId;
  final int quantity;
  const SavedMealIngredientRow(
      {required this.id,
      required this.savedMealId,
      required this.foodId,
      required this.quantity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['saved_meal_id'] = Variable<int>(savedMealId);
    map['food_id'] = Variable<int>(foodId);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  SavedMealIngredientsCompanion toCompanion(bool nullToAbsent) {
    return SavedMealIngredientsCompanion(
      id: Value(id),
      savedMealId: Value(savedMealId),
      foodId: Value(foodId),
      quantity: Value(quantity),
    );
  }

  factory SavedMealIngredientRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedMealIngredientRow(
      id: serializer.fromJson<int>(json['id']),
      savedMealId: serializer.fromJson<int>(json['savedMealId']),
      foodId: serializer.fromJson<int>(json['foodId']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'savedMealId': serializer.toJson<int>(savedMealId),
      'foodId': serializer.toJson<int>(foodId),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  SavedMealIngredientRow copyWith(
          {int? id, int? savedMealId, int? foodId, int? quantity}) =>
      SavedMealIngredientRow(
        id: id ?? this.id,
        savedMealId: savedMealId ?? this.savedMealId,
        foodId: foodId ?? this.foodId,
        quantity: quantity ?? this.quantity,
      );
  SavedMealIngredientRow copyWithCompanion(SavedMealIngredientsCompanion data) {
    return SavedMealIngredientRow(
      id: data.id.present ? data.id.value : this.id,
      savedMealId:
          data.savedMealId.present ? data.savedMealId.value : this.savedMealId,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedMealIngredientRow(')
          ..write('id: $id, ')
          ..write('savedMealId: $savedMealId, ')
          ..write('foodId: $foodId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, savedMealId, foodId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedMealIngredientRow &&
          other.id == this.id &&
          other.savedMealId == this.savedMealId &&
          other.foodId == this.foodId &&
          other.quantity == this.quantity);
}

class SavedMealIngredientsCompanion
    extends UpdateCompanion<SavedMealIngredientRow> {
  final Value<int> id;
  final Value<int> savedMealId;
  final Value<int> foodId;
  final Value<int> quantity;
  const SavedMealIngredientsCompanion({
    this.id = const Value.absent(),
    this.savedMealId = const Value.absent(),
    this.foodId = const Value.absent(),
    this.quantity = const Value.absent(),
  });
  SavedMealIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required int savedMealId,
    required int foodId,
    required int quantity,
  })  : savedMealId = Value(savedMealId),
        foodId = Value(foodId),
        quantity = Value(quantity);
  static Insertable<SavedMealIngredientRow> custom({
    Expression<int>? id,
    Expression<int>? savedMealId,
    Expression<int>? foodId,
    Expression<int>? quantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (savedMealId != null) 'saved_meal_id': savedMealId,
      if (foodId != null) 'food_id': foodId,
      if (quantity != null) 'quantity': quantity,
    });
  }

  SavedMealIngredientsCompanion copyWith(
      {Value<int>? id,
      Value<int>? savedMealId,
      Value<int>? foodId,
      Value<int>? quantity}) {
    return SavedMealIngredientsCompanion(
      id: id ?? this.id,
      savedMealId: savedMealId ?? this.savedMealId,
      foodId: foodId ?? this.foodId,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (savedMealId.present) {
      map['saved_meal_id'] = Variable<int>(savedMealId.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<int>(foodId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedMealIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('savedMealId: $savedMealId, ')
          ..write('foodId: $foodId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }
}

class $FavoriteFoodsTable extends FavoriteFoods
    with TableInfo<$FavoriteFoodsTable, FavoriteFoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
      'food_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [foodId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'FavoriteFoods';
  @override
  VerificationContext validateIntegrity(Insertable<FavoriteFoodRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('food_id')) {
      context.handle(_foodIdMeta,
          foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {foodId};
  @override
  FavoriteFoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteFoodRow(
      foodId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}food_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FavoriteFoodsTable createAlias(String alias) {
    return $FavoriteFoodsTable(attachedDatabase, alias);
  }
}

class FavoriteFoodRow extends DataClass implements Insertable<FavoriteFoodRow> {
  final int foodId;
  final String createdAt;
  const FavoriteFoodRow({required this.foodId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['food_id'] = Variable<int>(foodId);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  FavoriteFoodsCompanion toCompanion(bool nullToAbsent) {
    return FavoriteFoodsCompanion(
      foodId: Value(foodId),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteFoodRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteFoodRow(
      foodId: serializer.fromJson<int>(json['foodId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'foodId': serializer.toJson<int>(foodId),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  FavoriteFoodRow copyWith({int? foodId, String? createdAt}) => FavoriteFoodRow(
        foodId: foodId ?? this.foodId,
        createdAt: createdAt ?? this.createdAt,
      );
  FavoriteFoodRow copyWithCompanion(FavoriteFoodsCompanion data) {
    return FavoriteFoodRow(
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteFoodRow(')
          ..write('foodId: $foodId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(foodId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteFoodRow &&
          other.foodId == this.foodId &&
          other.createdAt == this.createdAt);
}

class FavoriteFoodsCompanion extends UpdateCompanion<FavoriteFoodRow> {
  final Value<int> foodId;
  final Value<String> createdAt;
  const FavoriteFoodsCompanion({
    this.foodId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FavoriteFoodsCompanion.insert({
    this.foodId = const Value.absent(),
    required String createdAt,
  }) : createdAt = Value(createdAt);
  static Insertable<FavoriteFoodRow> custom({
    Expression<int>? foodId,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (foodId != null) 'food_id': foodId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FavoriteFoodsCompanion copyWith(
      {Value<int>? foodId, Value<String>? createdAt}) {
    return FavoriteFoodsCompanion(
      foodId: foodId ?? this.foodId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (foodId.present) {
      map['food_id'] = Variable<int>(foodId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteFoodsCompanion(')
          ..write('foodId: $foodId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FoodUsageTable extends FoodUsage
    with TableInfo<$FoodUsageTable, FoodUsageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodUsageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
      'food_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastUsedQuantityMeta =
      const VerificationMeta('lastUsedQuantity');
  @override
  late final GeneratedColumn<int> lastUsedQuantity = GeneratedColumn<int>(
      'last_used_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastUsedAtMeta =
      const VerificationMeta('lastUsedAt');
  @override
  late final GeneratedColumn<String> lastUsedAt = GeneratedColumn<String>(
      'last_used_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _useCountMeta =
      const VerificationMeta('useCount');
  @override
  late final GeneratedColumn<int> useCount = GeneratedColumn<int>(
      'use_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [foodId, lastUsedQuantity, lastUsedAt, useCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'FoodUsage';
  @override
  VerificationContext validateIntegrity(Insertable<FoodUsageRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('food_id')) {
      context.handle(_foodIdMeta,
          foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta));
    }
    if (data.containsKey('last_used_quantity')) {
      context.handle(
          _lastUsedQuantityMeta,
          lastUsedQuantity.isAcceptableOrUnknown(
              data['last_used_quantity']!, _lastUsedQuantityMeta));
    } else if (isInserting) {
      context.missing(_lastUsedQuantityMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
          _lastUsedAtMeta,
          lastUsedAt.isAcceptableOrUnknown(
              data['last_used_at']!, _lastUsedAtMeta));
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    if (data.containsKey('use_count')) {
      context.handle(_useCountMeta,
          useCount.isAcceptableOrUnknown(data['use_count']!, _useCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {foodId};
  @override
  FoodUsageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodUsageRow(
      foodId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}food_id'])!,
      lastUsedQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}last_used_quantity'])!,
      lastUsedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_used_at'])!,
      useCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}use_count'])!,
    );
  }

  @override
  $FoodUsageTable createAlias(String alias) {
    return $FoodUsageTable(attachedDatabase, alias);
  }
}

class FoodUsageRow extends DataClass implements Insertable<FoodUsageRow> {
  final int foodId;
  final int lastUsedQuantity;
  final String lastUsedAt;
  final int useCount;
  const FoodUsageRow(
      {required this.foodId,
      required this.lastUsedQuantity,
      required this.lastUsedAt,
      required this.useCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['food_id'] = Variable<int>(foodId);
    map['last_used_quantity'] = Variable<int>(lastUsedQuantity);
    map['last_used_at'] = Variable<String>(lastUsedAt);
    map['use_count'] = Variable<int>(useCount);
    return map;
  }

  FoodUsageCompanion toCompanion(bool nullToAbsent) {
    return FoodUsageCompanion(
      foodId: Value(foodId),
      lastUsedQuantity: Value(lastUsedQuantity),
      lastUsedAt: Value(lastUsedAt),
      useCount: Value(useCount),
    );
  }

  factory FoodUsageRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodUsageRow(
      foodId: serializer.fromJson<int>(json['foodId']),
      lastUsedQuantity: serializer.fromJson<int>(json['lastUsedQuantity']),
      lastUsedAt: serializer.fromJson<String>(json['lastUsedAt']),
      useCount: serializer.fromJson<int>(json['useCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'foodId': serializer.toJson<int>(foodId),
      'lastUsedQuantity': serializer.toJson<int>(lastUsedQuantity),
      'lastUsedAt': serializer.toJson<String>(lastUsedAt),
      'useCount': serializer.toJson<int>(useCount),
    };
  }

  FoodUsageRow copyWith(
          {int? foodId,
          int? lastUsedQuantity,
          String? lastUsedAt,
          int? useCount}) =>
      FoodUsageRow(
        foodId: foodId ?? this.foodId,
        lastUsedQuantity: lastUsedQuantity ?? this.lastUsedQuantity,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
        useCount: useCount ?? this.useCount,
      );
  FoodUsageRow copyWithCompanion(FoodUsageCompanion data) {
    return FoodUsageRow(
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      lastUsedQuantity: data.lastUsedQuantity.present
          ? data.lastUsedQuantity.value
          : this.lastUsedQuantity,
      lastUsedAt:
          data.lastUsedAt.present ? data.lastUsedAt.value : this.lastUsedAt,
      useCount: data.useCount.present ? data.useCount.value : this.useCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodUsageRow(')
          ..write('foodId: $foodId, ')
          ..write('lastUsedQuantity: $lastUsedQuantity, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('useCount: $useCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(foodId, lastUsedQuantity, lastUsedAt, useCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodUsageRow &&
          other.foodId == this.foodId &&
          other.lastUsedQuantity == this.lastUsedQuantity &&
          other.lastUsedAt == this.lastUsedAt &&
          other.useCount == this.useCount);
}

class FoodUsageCompanion extends UpdateCompanion<FoodUsageRow> {
  final Value<int> foodId;
  final Value<int> lastUsedQuantity;
  final Value<String> lastUsedAt;
  final Value<int> useCount;
  const FoodUsageCompanion({
    this.foodId = const Value.absent(),
    this.lastUsedQuantity = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.useCount = const Value.absent(),
  });
  FoodUsageCompanion.insert({
    this.foodId = const Value.absent(),
    required int lastUsedQuantity,
    required String lastUsedAt,
    this.useCount = const Value.absent(),
  })  : lastUsedQuantity = Value(lastUsedQuantity),
        lastUsedAt = Value(lastUsedAt);
  static Insertable<FoodUsageRow> custom({
    Expression<int>? foodId,
    Expression<int>? lastUsedQuantity,
    Expression<String>? lastUsedAt,
    Expression<int>? useCount,
  }) {
    return RawValuesInsertable({
      if (foodId != null) 'food_id': foodId,
      if (lastUsedQuantity != null) 'last_used_quantity': lastUsedQuantity,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (useCount != null) 'use_count': useCount,
    });
  }

  FoodUsageCompanion copyWith(
      {Value<int>? foodId,
      Value<int>? lastUsedQuantity,
      Value<String>? lastUsedAt,
      Value<int>? useCount}) {
    return FoodUsageCompanion(
      foodId: foodId ?? this.foodId,
      lastUsedQuantity: lastUsedQuantity ?? this.lastUsedQuantity,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      useCount: useCount ?? this.useCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (foodId.present) {
      map['food_id'] = Variable<int>(foodId.value);
    }
    if (lastUsedQuantity.present) {
      map['last_used_quantity'] = Variable<int>(lastUsedQuantity.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<String>(lastUsedAt.value);
    }
    if (useCount.present) {
      map['use_count'] = Variable<int>(useCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodUsageCompanion(')
          ..write('foodId: $foodId, ')
          ..write('lastUsedQuantity: $lastUsedQuantity, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('useCount: $useCount')
          ..write(')'))
        .toString();
  }
}

class $OfflineQueueTable extends OfflineQueue
    with TableInfo<$OfflineQueueTable, OfflineQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _actionTypeMeta =
      const VerificationMeta('actionType');
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
      'action_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, actionType, payload, createdAt, lastError];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'OfflineQueue';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineQueueRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
          _actionTypeMeta,
          actionType.isAcceptableOrUnknown(
              data['action_type']!, _actionTypeMeta));
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineQueueRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      actionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_type'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $OfflineQueueTable createAlias(String alias) {
    return $OfflineQueueTable(attachedDatabase, alias);
  }
}

class OfflineQueueRow extends DataClass implements Insertable<OfflineQueueRow> {
  final int id;
  final String actionType;
  final String payload;
  final String createdAt;
  final String? lastError;
  const OfflineQueueRow(
      {required this.id,
      required this.actionType,
      required this.payload,
      required this.createdAt,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action_type'] = Variable<String>(actionType);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OfflineQueueCompanion toCompanion(bool nullToAbsent) {
    return OfflineQueueCompanion(
      id: Value(id),
      actionType: Value(actionType),
      payload: Value(payload),
      createdAt: Value(createdAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OfflineQueueRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineQueueRow(
      id: serializer.fromJson<int>(json['id']),
      actionType: serializer.fromJson<String>(json['actionType']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'actionType': serializer.toJson<String>(actionType),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<String>(createdAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OfflineQueueRow copyWith(
          {int? id,
          String? actionType,
          String? payload,
          String? createdAt,
          Value<String?> lastError = const Value.absent()}) =>
      OfflineQueueRow(
        id: id ?? this.id,
        actionType: actionType ?? this.actionType,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  OfflineQueueRow copyWithCompanion(OfflineQueueCompanion data) {
    return OfflineQueueRow(
      id: data.id.present ? data.id.value : this.id,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineQueueRow(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, actionType, payload, createdAt, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineQueueRow &&
          other.id == this.id &&
          other.actionType == this.actionType &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.lastError == this.lastError);
}

class OfflineQueueCompanion extends UpdateCompanion<OfflineQueueRow> {
  final Value<int> id;
  final Value<String> actionType;
  final Value<String> payload;
  final Value<String> createdAt;
  final Value<String?> lastError;
  const OfflineQueueCompanion({
    this.id = const Value.absent(),
    this.actionType = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  OfflineQueueCompanion.insert({
    this.id = const Value.absent(),
    required String actionType,
    required String payload,
    required String createdAt,
    this.lastError = const Value.absent(),
  })  : actionType = Value(actionType),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<OfflineQueueRow> custom({
    Expression<int>? id,
    Expression<String>? actionType,
    Expression<String>? payload,
    Expression<String>? createdAt,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionType != null) 'action_type': actionType,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (lastError != null) 'last_error': lastError,
    });
  }

  OfflineQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? actionType,
      Value<String>? payload,
      Value<String>? createdAt,
      Value<String?>? lastError}) {
    return OfflineQueueCompanion(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineQueueCompanion(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $LocalFoodsTable extends LocalFoods
    with TableInfo<$LocalFoodsTable, LocalFoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _caloriesPer100gMeta =
      const VerificationMeta('caloriesPer100g');
  @override
  late final GeneratedColumn<int> caloriesPer100g = GeneratedColumn<int>(
      'calories_per_100g', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fatPer100gMeta =
      const VerificationMeta('fatPer100g');
  @override
  late final GeneratedColumn<double> fatPer100g = GeneratedColumn<double>(
      'fat_per_100g', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carbsPer100gMeta =
      const VerificationMeta('carbsPer100g');
  @override
  late final GeneratedColumn<double> carbsPer100g = GeneratedColumn<double>(
      'carbs_per_100g', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sugarPer100gMeta =
      const VerificationMeta('sugarPer100g');
  @override
  late final GeneratedColumn<double> sugarPer100g = GeneratedColumn<double>(
      'sugar_per_100g', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _proteinPer100gMeta =
      const VerificationMeta('proteinPer100g');
  @override
  late final GeneratedColumn<double> proteinPer100g = GeneratedColumn<double>(
      'protein_per_100g', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastUsedQuantityMeta =
      const VerificationMeta('lastUsedQuantity');
  @override
  late final GeneratedColumn<int> lastUsedQuantity = GeneratedColumn<int>(
      'last_used_quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ai'));
  static const VerificationMeta _isVerifiedMeta =
      const VerificationMeta('isVerified');
  @override
  late final GeneratedColumn<int> isVerified = GeneratedColumn<int>(
      'is_verified', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        brand,
        barcode,
        caloriesPer100g,
        fatPer100g,
        carbsPer100g,
        sugarPer100g,
        proteinPer100g,
        createdAt,
        lastUsedQuantity,
        source,
        isVerified,
        uuid
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'LocalFoods';
  @override
  VerificationContext validateIntegrity(Insertable<LocalFoodRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('calories_per_100g')) {
      context.handle(
          _caloriesPer100gMeta,
          caloriesPer100g.isAcceptableOrUnknown(
              data['calories_per_100g']!, _caloriesPer100gMeta));
    } else if (isInserting) {
      context.missing(_caloriesPer100gMeta);
    }
    if (data.containsKey('fat_per_100g')) {
      context.handle(
          _fatPer100gMeta,
          fatPer100g.isAcceptableOrUnknown(
              data['fat_per_100g']!, _fatPer100gMeta));
    } else if (isInserting) {
      context.missing(_fatPer100gMeta);
    }
    if (data.containsKey('carbs_per_100g')) {
      context.handle(
          _carbsPer100gMeta,
          carbsPer100g.isAcceptableOrUnknown(
              data['carbs_per_100g']!, _carbsPer100gMeta));
    } else if (isInserting) {
      context.missing(_carbsPer100gMeta);
    }
    if (data.containsKey('sugar_per_100g')) {
      context.handle(
          _sugarPer100gMeta,
          sugarPer100g.isAcceptableOrUnknown(
              data['sugar_per_100g']!, _sugarPer100gMeta));
    } else if (isInserting) {
      context.missing(_sugarPer100gMeta);
    }
    if (data.containsKey('protein_per_100g')) {
      context.handle(
          _proteinPer100gMeta,
          proteinPer100g.isAcceptableOrUnknown(
              data['protein_per_100g']!, _proteinPer100gMeta));
    } else if (isInserting) {
      context.missing(_proteinPer100gMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_used_quantity')) {
      context.handle(
          _lastUsedQuantityMeta,
          lastUsedQuantity.isAcceptableOrUnknown(
              data['last_used_quantity']!, _lastUsedQuantityMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('is_verified')) {
      context.handle(
          _isVerifiedMeta,
          isVerified.isAcceptableOrUnknown(
              data['is_verified']!, _isVerifiedMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFoodRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      caloriesPer100g: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}calories_per_100g'])!,
      fatPer100g: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat_per_100g'])!,
      carbsPer100g: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs_per_100g'])!,
      sugarPer100g: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sugar_per_100g'])!,
      proteinPer100g: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}protein_per_100g'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      lastUsedQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}last_used_quantity'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      isVerified: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_verified'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid']),
    );
  }

  @override
  $LocalFoodsTable createAlias(String alias) {
    return $LocalFoodsTable(attachedDatabase, alias);
  }
}

class LocalFoodRow extends DataClass implements Insertable<LocalFoodRow> {
  final int id;
  final String name;
  final String brand;
  final String? barcode;
  final int caloriesPer100g;
  final double fatPer100g;
  final double carbsPer100g;
  final double sugarPer100g;
  final double proteinPer100g;
  final String createdAt;
  final int lastUsedQuantity;
  final String source;
  final int isVerified;
  final String? uuid;
  const LocalFoodRow(
      {required this.id,
      required this.name,
      required this.brand,
      this.barcode,
      required this.caloriesPer100g,
      required this.fatPer100g,
      required this.carbsPer100g,
      required this.sugarPer100g,
      required this.proteinPer100g,
      required this.createdAt,
      required this.lastUsedQuantity,
      required this.source,
      required this.isVerified,
      this.uuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['brand'] = Variable<String>(brand);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['calories_per_100g'] = Variable<int>(caloriesPer100g);
    map['fat_per_100g'] = Variable<double>(fatPer100g);
    map['carbs_per_100g'] = Variable<double>(carbsPer100g);
    map['sugar_per_100g'] = Variable<double>(sugarPer100g);
    map['protein_per_100g'] = Variable<double>(proteinPer100g);
    map['created_at'] = Variable<String>(createdAt);
    map['last_used_quantity'] = Variable<int>(lastUsedQuantity);
    map['source'] = Variable<String>(source);
    map['is_verified'] = Variable<int>(isVerified);
    if (!nullToAbsent || uuid != null) {
      map['uuid'] = Variable<String>(uuid);
    }
    return map;
  }

  LocalFoodsCompanion toCompanion(bool nullToAbsent) {
    return LocalFoodsCompanion(
      id: Value(id),
      name: Value(name),
      brand: Value(brand),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      caloriesPer100g: Value(caloriesPer100g),
      fatPer100g: Value(fatPer100g),
      carbsPer100g: Value(carbsPer100g),
      sugarPer100g: Value(sugarPer100g),
      proteinPer100g: Value(proteinPer100g),
      createdAt: Value(createdAt),
      lastUsedQuantity: Value(lastUsedQuantity),
      source: Value(source),
      isVerified: Value(isVerified),
      uuid: uuid == null && nullToAbsent ? const Value.absent() : Value(uuid),
    );
  }

  factory LocalFoodRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFoodRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String>(json['brand']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      caloriesPer100g: serializer.fromJson<int>(json['caloriesPer100g']),
      fatPer100g: serializer.fromJson<double>(json['fatPer100g']),
      carbsPer100g: serializer.fromJson<double>(json['carbsPer100g']),
      sugarPer100g: serializer.fromJson<double>(json['sugarPer100g']),
      proteinPer100g: serializer.fromJson<double>(json['proteinPer100g']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      lastUsedQuantity: serializer.fromJson<int>(json['lastUsedQuantity']),
      source: serializer.fromJson<String>(json['source']),
      isVerified: serializer.fromJson<int>(json['isVerified']),
      uuid: serializer.fromJson<String?>(json['uuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String>(brand),
      'barcode': serializer.toJson<String?>(barcode),
      'caloriesPer100g': serializer.toJson<int>(caloriesPer100g),
      'fatPer100g': serializer.toJson<double>(fatPer100g),
      'carbsPer100g': serializer.toJson<double>(carbsPer100g),
      'sugarPer100g': serializer.toJson<double>(sugarPer100g),
      'proteinPer100g': serializer.toJson<double>(proteinPer100g),
      'createdAt': serializer.toJson<String>(createdAt),
      'lastUsedQuantity': serializer.toJson<int>(lastUsedQuantity),
      'source': serializer.toJson<String>(source),
      'isVerified': serializer.toJson<int>(isVerified),
      'uuid': serializer.toJson<String?>(uuid),
    };
  }

  LocalFoodRow copyWith(
          {int? id,
          String? name,
          String? brand,
          Value<String?> barcode = const Value.absent(),
          int? caloriesPer100g,
          double? fatPer100g,
          double? carbsPer100g,
          double? sugarPer100g,
          double? proteinPer100g,
          String? createdAt,
          int? lastUsedQuantity,
          String? source,
          int? isVerified,
          Value<String?> uuid = const Value.absent()}) =>
      LocalFoodRow(
        id: id ?? this.id,
        name: name ?? this.name,
        brand: brand ?? this.brand,
        barcode: barcode.present ? barcode.value : this.barcode,
        caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
        fatPer100g: fatPer100g ?? this.fatPer100g,
        carbsPer100g: carbsPer100g ?? this.carbsPer100g,
        sugarPer100g: sugarPer100g ?? this.sugarPer100g,
        proteinPer100g: proteinPer100g ?? this.proteinPer100g,
        createdAt: createdAt ?? this.createdAt,
        lastUsedQuantity: lastUsedQuantity ?? this.lastUsedQuantity,
        source: source ?? this.source,
        isVerified: isVerified ?? this.isVerified,
        uuid: uuid.present ? uuid.value : this.uuid,
      );
  LocalFoodRow copyWithCompanion(LocalFoodsCompanion data) {
    return LocalFoodRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      caloriesPer100g: data.caloriesPer100g.present
          ? data.caloriesPer100g.value
          : this.caloriesPer100g,
      fatPer100g:
          data.fatPer100g.present ? data.fatPer100g.value : this.fatPer100g,
      carbsPer100g: data.carbsPer100g.present
          ? data.carbsPer100g.value
          : this.carbsPer100g,
      sugarPer100g: data.sugarPer100g.present
          ? data.sugarPer100g.value
          : this.sugarPer100g,
      proteinPer100g: data.proteinPer100g.present
          ? data.proteinPer100g.value
          : this.proteinPer100g,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedQuantity: data.lastUsedQuantity.present
          ? data.lastUsedQuantity.value
          : this.lastUsedQuantity,
      source: data.source.present ? data.source.value : this.source,
      isVerified:
          data.isVerified.present ? data.isVerified.value : this.isVerified,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFoodRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('barcode: $barcode, ')
          ..write('caloriesPer100g: $caloriesPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('sugarPer100g: $sugarPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedQuantity: $lastUsedQuantity, ')
          ..write('source: $source, ')
          ..write('isVerified: $isVerified, ')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      brand,
      barcode,
      caloriesPer100g,
      fatPer100g,
      carbsPer100g,
      sugarPer100g,
      proteinPer100g,
      createdAt,
      lastUsedQuantity,
      source,
      isVerified,
      uuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFoodRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.barcode == this.barcode &&
          other.caloriesPer100g == this.caloriesPer100g &&
          other.fatPer100g == this.fatPer100g &&
          other.carbsPer100g == this.carbsPer100g &&
          other.sugarPer100g == this.sugarPer100g &&
          other.proteinPer100g == this.proteinPer100g &&
          other.createdAt == this.createdAt &&
          other.lastUsedQuantity == this.lastUsedQuantity &&
          other.source == this.source &&
          other.isVerified == this.isVerified &&
          other.uuid == this.uuid);
}

class LocalFoodsCompanion extends UpdateCompanion<LocalFoodRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> brand;
  final Value<String?> barcode;
  final Value<int> caloriesPer100g;
  final Value<double> fatPer100g;
  final Value<double> carbsPer100g;
  final Value<double> sugarPer100g;
  final Value<double> proteinPer100g;
  final Value<String> createdAt;
  final Value<int> lastUsedQuantity;
  final Value<String> source;
  final Value<int> isVerified;
  final Value<String?> uuid;
  const LocalFoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.barcode = const Value.absent(),
    this.caloriesPer100g = const Value.absent(),
    this.fatPer100g = const Value.absent(),
    this.carbsPer100g = const Value.absent(),
    this.sugarPer100g = const Value.absent(),
    this.proteinPer100g = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedQuantity = const Value.absent(),
    this.source = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.uuid = const Value.absent(),
  });
  LocalFoodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String brand,
    this.barcode = const Value.absent(),
    required int caloriesPer100g,
    required double fatPer100g,
    required double carbsPer100g,
    required double sugarPer100g,
    required double proteinPer100g,
    required String createdAt,
    this.lastUsedQuantity = const Value.absent(),
    this.source = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.uuid = const Value.absent(),
  })  : name = Value(name),
        brand = Value(brand),
        caloriesPer100g = Value(caloriesPer100g),
        fatPer100g = Value(fatPer100g),
        carbsPer100g = Value(carbsPer100g),
        sugarPer100g = Value(sugarPer100g),
        proteinPer100g = Value(proteinPer100g),
        createdAt = Value(createdAt);
  static Insertable<LocalFoodRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? barcode,
    Expression<int>? caloriesPer100g,
    Expression<double>? fatPer100g,
    Expression<double>? carbsPer100g,
    Expression<double>? sugarPer100g,
    Expression<double>? proteinPer100g,
    Expression<String>? createdAt,
    Expression<int>? lastUsedQuantity,
    Expression<String>? source,
    Expression<int>? isVerified,
    Expression<String>? uuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (barcode != null) 'barcode': barcode,
      if (caloriesPer100g != null) 'calories_per_100g': caloriesPer100g,
      if (fatPer100g != null) 'fat_per_100g': fatPer100g,
      if (carbsPer100g != null) 'carbs_per_100g': carbsPer100g,
      if (sugarPer100g != null) 'sugar_per_100g': sugarPer100g,
      if (proteinPer100g != null) 'protein_per_100g': proteinPer100g,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedQuantity != null) 'last_used_quantity': lastUsedQuantity,
      if (source != null) 'source': source,
      if (isVerified != null) 'is_verified': isVerified,
      if (uuid != null) 'uuid': uuid,
    });
  }

  LocalFoodsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? brand,
      Value<String?>? barcode,
      Value<int>? caloriesPer100g,
      Value<double>? fatPer100g,
      Value<double>? carbsPer100g,
      Value<double>? sugarPer100g,
      Value<double>? proteinPer100g,
      Value<String>? createdAt,
      Value<int>? lastUsedQuantity,
      Value<String>? source,
      Value<int>? isVerified,
      Value<String?>? uuid}) {
    return LocalFoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      sugarPer100g: sugarPer100g ?? this.sugarPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      createdAt: createdAt ?? this.createdAt,
      lastUsedQuantity: lastUsedQuantity ?? this.lastUsedQuantity,
      source: source ?? this.source,
      isVerified: isVerified ?? this.isVerified,
      uuid: uuid ?? this.uuid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (caloriesPer100g.present) {
      map['calories_per_100g'] = Variable<int>(caloriesPer100g.value);
    }
    if (fatPer100g.present) {
      map['fat_per_100g'] = Variable<double>(fatPer100g.value);
    }
    if (carbsPer100g.present) {
      map['carbs_per_100g'] = Variable<double>(carbsPer100g.value);
    }
    if (sugarPer100g.present) {
      map['sugar_per_100g'] = Variable<double>(sugarPer100g.value);
    }
    if (proteinPer100g.present) {
      map['protein_per_100g'] = Variable<double>(proteinPer100g.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (lastUsedQuantity.present) {
      map['last_used_quantity'] = Variable<int>(lastUsedQuantity.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<int>(isVerified.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('barcode: $barcode, ')
          ..write('caloriesPer100g: $caloriesPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('sugarPer100g: $sugarPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedQuantity: $lastUsedQuantity, ')
          ..write('source: $source, ')
          ..write('isVerified: $isVerified, ')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _darkModeMeta =
      const VerificationMeta('darkMode');
  @override
  late final GeneratedColumn<int> darkMode = GeneratedColumn<int>(
      'dark_mode', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _reminderWeighEnabledMeta =
      const VerificationMeta('reminderWeighEnabled');
  @override
  late final GeneratedColumn<int> reminderWeighEnabled = GeneratedColumn<int>(
      'reminder_weigh_enabled', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _reminderWeighTimeMeta =
      const VerificationMeta('reminderWeighTime');
  @override
  late final GeneratedColumn<String> reminderWeighTime =
      GeneratedColumn<String>('reminder_weigh_time', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('08:00'));
  static const VerificationMeta _reminderWeighTime2Meta =
      const VerificationMeta('reminderWeighTime2');
  @override
  late final GeneratedColumn<String> reminderWeighTime2 =
      GeneratedColumn<String>('reminder_weigh_time2', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('09:00'));
  static const VerificationMeta _reminderSupplementEnabledMeta =
      const VerificationMeta('reminderSupplementEnabled');
  @override
  late final GeneratedColumn<int> reminderSupplementEnabled =
      GeneratedColumn<int>('reminder_supplement_enabled', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(0));
  static const VerificationMeta _reminderSupplementTimeMeta =
      const VerificationMeta('reminderSupplementTime');
  @override
  late final GeneratedColumn<String> reminderSupplementTime =
      GeneratedColumn<String>('reminder_supplement_time', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('10:00'));
  static const VerificationMeta _reminderSupplementTime2Meta =
      const VerificationMeta('reminderSupplementTime2');
  @override
  late final GeneratedColumn<String> reminderSupplementTime2 =
      GeneratedColumn<String>('reminder_supplement_time2', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('11:00'));
  static const VerificationMeta _reminderMealsEnabledMeta =
      const VerificationMeta('reminderMealsEnabled');
  @override
  late final GeneratedColumn<int> reminderMealsEnabled = GeneratedColumn<int>(
      'reminder_meals_enabled', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _reminderBreakfastMeta =
      const VerificationMeta('reminderBreakfast');
  @override
  late final GeneratedColumn<String> reminderBreakfast =
      GeneratedColumn<String>('reminder_breakfast', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('07:00'));
  static const VerificationMeta _reminderLunchMeta =
      const VerificationMeta('reminderLunch');
  @override
  late final GeneratedColumn<String> reminderLunch = GeneratedColumn<String>(
      'reminder_lunch', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('12:30'));
  static const VerificationMeta _reminderDinnerMeta =
      const VerificationMeta('reminderDinner');
  @override
  late final GeneratedColumn<String> reminderDinner = GeneratedColumn<String>(
      'reminder_dinner', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('19:00'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        darkMode,
        reminderWeighEnabled,
        reminderWeighTime,
        reminderWeighTime2,
        reminderSupplementEnabled,
        reminderSupplementTime,
        reminderSupplementTime2,
        reminderMealsEnabled,
        reminderBreakfast,
        reminderLunch,
        reminderDinner
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSettingsRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dark_mode')) {
      context.handle(_darkModeMeta,
          darkMode.isAcceptableOrUnknown(data['dark_mode']!, _darkModeMeta));
    }
    if (data.containsKey('reminder_weigh_enabled')) {
      context.handle(
          _reminderWeighEnabledMeta,
          reminderWeighEnabled.isAcceptableOrUnknown(
              data['reminder_weigh_enabled']!, _reminderWeighEnabledMeta));
    }
    if (data.containsKey('reminder_weigh_time')) {
      context.handle(
          _reminderWeighTimeMeta,
          reminderWeighTime.isAcceptableOrUnknown(
              data['reminder_weigh_time']!, _reminderWeighTimeMeta));
    }
    if (data.containsKey('reminder_weigh_time2')) {
      context.handle(
          _reminderWeighTime2Meta,
          reminderWeighTime2.isAcceptableOrUnknown(
              data['reminder_weigh_time2']!, _reminderWeighTime2Meta));
    }
    if (data.containsKey('reminder_supplement_enabled')) {
      context.handle(
          _reminderSupplementEnabledMeta,
          reminderSupplementEnabled.isAcceptableOrUnknown(
              data['reminder_supplement_enabled']!,
              _reminderSupplementEnabledMeta));
    }
    if (data.containsKey('reminder_supplement_time')) {
      context.handle(
          _reminderSupplementTimeMeta,
          reminderSupplementTime.isAcceptableOrUnknown(
              data['reminder_supplement_time']!, _reminderSupplementTimeMeta));
    }
    if (data.containsKey('reminder_supplement_time2')) {
      context.handle(
          _reminderSupplementTime2Meta,
          reminderSupplementTime2.isAcceptableOrUnknown(
              data['reminder_supplement_time2']!,
              _reminderSupplementTime2Meta));
    }
    if (data.containsKey('reminder_meals_enabled')) {
      context.handle(
          _reminderMealsEnabledMeta,
          reminderMealsEnabled.isAcceptableOrUnknown(
              data['reminder_meals_enabled']!, _reminderMealsEnabledMeta));
    }
    if (data.containsKey('reminder_breakfast')) {
      context.handle(
          _reminderBreakfastMeta,
          reminderBreakfast.isAcceptableOrUnknown(
              data['reminder_breakfast']!, _reminderBreakfastMeta));
    }
    if (data.containsKey('reminder_lunch')) {
      context.handle(
          _reminderLunchMeta,
          reminderLunch.isAcceptableOrUnknown(
              data['reminder_lunch']!, _reminderLunchMeta));
    }
    if (data.containsKey('reminder_dinner')) {
      context.handle(
          _reminderDinnerMeta,
          reminderDinner.isAcceptableOrUnknown(
              data['reminder_dinner']!, _reminderDinnerMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      darkMode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dark_mode'])!,
      reminderWeighEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}reminder_weigh_enabled'])!,
      reminderWeighTime: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reminder_weigh_time'])!,
      reminderWeighTime2: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reminder_weigh_time2'])!,
      reminderSupplementEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}reminder_supplement_enabled'])!,
      reminderSupplementTime: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reminder_supplement_time'])!,
      reminderSupplementTime2: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reminder_supplement_time2'])!,
      reminderMealsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}reminder_meals_enabled'])!,
      reminderBreakfast: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reminder_breakfast'])!,
      reminderLunch: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reminder_lunch'])!,
      reminderDinner: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reminder_dinner'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final int id;
  final int darkMode;
  final int reminderWeighEnabled;
  final String reminderWeighTime;
  final String reminderWeighTime2;
  final int reminderSupplementEnabled;
  final String reminderSupplementTime;
  final String reminderSupplementTime2;
  final int reminderMealsEnabled;
  final String reminderBreakfast;
  final String reminderLunch;
  final String reminderDinner;
  const AppSettingsRow(
      {required this.id,
      required this.darkMode,
      required this.reminderWeighEnabled,
      required this.reminderWeighTime,
      required this.reminderWeighTime2,
      required this.reminderSupplementEnabled,
      required this.reminderSupplementTime,
      required this.reminderSupplementTime2,
      required this.reminderMealsEnabled,
      required this.reminderBreakfast,
      required this.reminderLunch,
      required this.reminderDinner});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dark_mode'] = Variable<int>(darkMode);
    map['reminder_weigh_enabled'] = Variable<int>(reminderWeighEnabled);
    map['reminder_weigh_time'] = Variable<String>(reminderWeighTime);
    map['reminder_weigh_time2'] = Variable<String>(reminderWeighTime2);
    map['reminder_supplement_enabled'] =
        Variable<int>(reminderSupplementEnabled);
    map['reminder_supplement_time'] = Variable<String>(reminderSupplementTime);
    map['reminder_supplement_time2'] =
        Variable<String>(reminderSupplementTime2);
    map['reminder_meals_enabled'] = Variable<int>(reminderMealsEnabled);
    map['reminder_breakfast'] = Variable<String>(reminderBreakfast);
    map['reminder_lunch'] = Variable<String>(reminderLunch);
    map['reminder_dinner'] = Variable<String>(reminderDinner);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      darkMode: Value(darkMode),
      reminderWeighEnabled: Value(reminderWeighEnabled),
      reminderWeighTime: Value(reminderWeighTime),
      reminderWeighTime2: Value(reminderWeighTime2),
      reminderSupplementEnabled: Value(reminderSupplementEnabled),
      reminderSupplementTime: Value(reminderSupplementTime),
      reminderSupplementTime2: Value(reminderSupplementTime2),
      reminderMealsEnabled: Value(reminderMealsEnabled),
      reminderBreakfast: Value(reminderBreakfast),
      reminderLunch: Value(reminderLunch),
      reminderDinner: Value(reminderDinner),
    );
  }

  factory AppSettingsRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      darkMode: serializer.fromJson<int>(json['darkMode']),
      reminderWeighEnabled:
          serializer.fromJson<int>(json['reminderWeighEnabled']),
      reminderWeighTime: serializer.fromJson<String>(json['reminderWeighTime']),
      reminderWeighTime2:
          serializer.fromJson<String>(json['reminderWeighTime2']),
      reminderSupplementEnabled:
          serializer.fromJson<int>(json['reminderSupplementEnabled']),
      reminderSupplementTime:
          serializer.fromJson<String>(json['reminderSupplementTime']),
      reminderSupplementTime2:
          serializer.fromJson<String>(json['reminderSupplementTime2']),
      reminderMealsEnabled:
          serializer.fromJson<int>(json['reminderMealsEnabled']),
      reminderBreakfast: serializer.fromJson<String>(json['reminderBreakfast']),
      reminderLunch: serializer.fromJson<String>(json['reminderLunch']),
      reminderDinner: serializer.fromJson<String>(json['reminderDinner']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'darkMode': serializer.toJson<int>(darkMode),
      'reminderWeighEnabled': serializer.toJson<int>(reminderWeighEnabled),
      'reminderWeighTime': serializer.toJson<String>(reminderWeighTime),
      'reminderWeighTime2': serializer.toJson<String>(reminderWeighTime2),
      'reminderSupplementEnabled':
          serializer.toJson<int>(reminderSupplementEnabled),
      'reminderSupplementTime':
          serializer.toJson<String>(reminderSupplementTime),
      'reminderSupplementTime2':
          serializer.toJson<String>(reminderSupplementTime2),
      'reminderMealsEnabled': serializer.toJson<int>(reminderMealsEnabled),
      'reminderBreakfast': serializer.toJson<String>(reminderBreakfast),
      'reminderLunch': serializer.toJson<String>(reminderLunch),
      'reminderDinner': serializer.toJson<String>(reminderDinner),
    };
  }

  AppSettingsRow copyWith(
          {int? id,
          int? darkMode,
          int? reminderWeighEnabled,
          String? reminderWeighTime,
          String? reminderWeighTime2,
          int? reminderSupplementEnabled,
          String? reminderSupplementTime,
          String? reminderSupplementTime2,
          int? reminderMealsEnabled,
          String? reminderBreakfast,
          String? reminderLunch,
          String? reminderDinner}) =>
      AppSettingsRow(
        id: id ?? this.id,
        darkMode: darkMode ?? this.darkMode,
        reminderWeighEnabled: reminderWeighEnabled ?? this.reminderWeighEnabled,
        reminderWeighTime: reminderWeighTime ?? this.reminderWeighTime,
        reminderWeighTime2: reminderWeighTime2 ?? this.reminderWeighTime2,
        reminderSupplementEnabled:
            reminderSupplementEnabled ?? this.reminderSupplementEnabled,
        reminderSupplementTime:
            reminderSupplementTime ?? this.reminderSupplementTime,
        reminderSupplementTime2:
            reminderSupplementTime2 ?? this.reminderSupplementTime2,
        reminderMealsEnabled: reminderMealsEnabled ?? this.reminderMealsEnabled,
        reminderBreakfast: reminderBreakfast ?? this.reminderBreakfast,
        reminderLunch: reminderLunch ?? this.reminderLunch,
        reminderDinner: reminderDinner ?? this.reminderDinner,
      );
  AppSettingsRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      darkMode: data.darkMode.present ? data.darkMode.value : this.darkMode,
      reminderWeighEnabled: data.reminderWeighEnabled.present
          ? data.reminderWeighEnabled.value
          : this.reminderWeighEnabled,
      reminderWeighTime: data.reminderWeighTime.present
          ? data.reminderWeighTime.value
          : this.reminderWeighTime,
      reminderWeighTime2: data.reminderWeighTime2.present
          ? data.reminderWeighTime2.value
          : this.reminderWeighTime2,
      reminderSupplementEnabled: data.reminderSupplementEnabled.present
          ? data.reminderSupplementEnabled.value
          : this.reminderSupplementEnabled,
      reminderSupplementTime: data.reminderSupplementTime.present
          ? data.reminderSupplementTime.value
          : this.reminderSupplementTime,
      reminderSupplementTime2: data.reminderSupplementTime2.present
          ? data.reminderSupplementTime2.value
          : this.reminderSupplementTime2,
      reminderMealsEnabled: data.reminderMealsEnabled.present
          ? data.reminderMealsEnabled.value
          : this.reminderMealsEnabled,
      reminderBreakfast: data.reminderBreakfast.present
          ? data.reminderBreakfast.value
          : this.reminderBreakfast,
      reminderLunch: data.reminderLunch.present
          ? data.reminderLunch.value
          : this.reminderLunch,
      reminderDinner: data.reminderDinner.present
          ? data.reminderDinner.value
          : this.reminderDinner,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('darkMode: $darkMode, ')
          ..write('reminderWeighEnabled: $reminderWeighEnabled, ')
          ..write('reminderWeighTime: $reminderWeighTime, ')
          ..write('reminderWeighTime2: $reminderWeighTime2, ')
          ..write('reminderSupplementEnabled: $reminderSupplementEnabled, ')
          ..write('reminderSupplementTime: $reminderSupplementTime, ')
          ..write('reminderSupplementTime2: $reminderSupplementTime2, ')
          ..write('reminderMealsEnabled: $reminderMealsEnabled, ')
          ..write('reminderBreakfast: $reminderBreakfast, ')
          ..write('reminderLunch: $reminderLunch, ')
          ..write('reminderDinner: $reminderDinner')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      darkMode,
      reminderWeighEnabled,
      reminderWeighTime,
      reminderWeighTime2,
      reminderSupplementEnabled,
      reminderSupplementTime,
      reminderSupplementTime2,
      reminderMealsEnabled,
      reminderBreakfast,
      reminderLunch,
      reminderDinner);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.darkMode == this.darkMode &&
          other.reminderWeighEnabled == this.reminderWeighEnabled &&
          other.reminderWeighTime == this.reminderWeighTime &&
          other.reminderWeighTime2 == this.reminderWeighTime2 &&
          other.reminderSupplementEnabled == this.reminderSupplementEnabled &&
          other.reminderSupplementTime == this.reminderSupplementTime &&
          other.reminderSupplementTime2 == this.reminderSupplementTime2 &&
          other.reminderMealsEnabled == this.reminderMealsEnabled &&
          other.reminderBreakfast == this.reminderBreakfast &&
          other.reminderLunch == this.reminderLunch &&
          other.reminderDinner == this.reminderDinner);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<int> id;
  final Value<int> darkMode;
  final Value<int> reminderWeighEnabled;
  final Value<String> reminderWeighTime;
  final Value<String> reminderWeighTime2;
  final Value<int> reminderSupplementEnabled;
  final Value<String> reminderSupplementTime;
  final Value<String> reminderSupplementTime2;
  final Value<int> reminderMealsEnabled;
  final Value<String> reminderBreakfast;
  final Value<String> reminderLunch;
  final Value<String> reminderDinner;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.reminderWeighEnabled = const Value.absent(),
    this.reminderWeighTime = const Value.absent(),
    this.reminderWeighTime2 = const Value.absent(),
    this.reminderSupplementEnabled = const Value.absent(),
    this.reminderSupplementTime = const Value.absent(),
    this.reminderSupplementTime2 = const Value.absent(),
    this.reminderMealsEnabled = const Value.absent(),
    this.reminderBreakfast = const Value.absent(),
    this.reminderLunch = const Value.absent(),
    this.reminderDinner = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.reminderWeighEnabled = const Value.absent(),
    this.reminderWeighTime = const Value.absent(),
    this.reminderWeighTime2 = const Value.absent(),
    this.reminderSupplementEnabled = const Value.absent(),
    this.reminderSupplementTime = const Value.absent(),
    this.reminderSupplementTime2 = const Value.absent(),
    this.reminderMealsEnabled = const Value.absent(),
    this.reminderBreakfast = const Value.absent(),
    this.reminderLunch = const Value.absent(),
    this.reminderDinner = const Value.absent(),
  });
  static Insertable<AppSettingsRow> custom({
    Expression<int>? id,
    Expression<int>? darkMode,
    Expression<int>? reminderWeighEnabled,
    Expression<String>? reminderWeighTime,
    Expression<String>? reminderWeighTime2,
    Expression<int>? reminderSupplementEnabled,
    Expression<String>? reminderSupplementTime,
    Expression<String>? reminderSupplementTime2,
    Expression<int>? reminderMealsEnabled,
    Expression<String>? reminderBreakfast,
    Expression<String>? reminderLunch,
    Expression<String>? reminderDinner,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (darkMode != null) 'dark_mode': darkMode,
      if (reminderWeighEnabled != null)
        'reminder_weigh_enabled': reminderWeighEnabled,
      if (reminderWeighTime != null) 'reminder_weigh_time': reminderWeighTime,
      if (reminderWeighTime2 != null)
        'reminder_weigh_time2': reminderWeighTime2,
      if (reminderSupplementEnabled != null)
        'reminder_supplement_enabled': reminderSupplementEnabled,
      if (reminderSupplementTime != null)
        'reminder_supplement_time': reminderSupplementTime,
      if (reminderSupplementTime2 != null)
        'reminder_supplement_time2': reminderSupplementTime2,
      if (reminderMealsEnabled != null)
        'reminder_meals_enabled': reminderMealsEnabled,
      if (reminderBreakfast != null) 'reminder_breakfast': reminderBreakfast,
      if (reminderLunch != null) 'reminder_lunch': reminderLunch,
      if (reminderDinner != null) 'reminder_dinner': reminderDinner,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? darkMode,
      Value<int>? reminderWeighEnabled,
      Value<String>? reminderWeighTime,
      Value<String>? reminderWeighTime2,
      Value<int>? reminderSupplementEnabled,
      Value<String>? reminderSupplementTime,
      Value<String>? reminderSupplementTime2,
      Value<int>? reminderMealsEnabled,
      Value<String>? reminderBreakfast,
      Value<String>? reminderLunch,
      Value<String>? reminderDinner}) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      darkMode: darkMode ?? this.darkMode,
      reminderWeighEnabled: reminderWeighEnabled ?? this.reminderWeighEnabled,
      reminderWeighTime: reminderWeighTime ?? this.reminderWeighTime,
      reminderWeighTime2: reminderWeighTime2 ?? this.reminderWeighTime2,
      reminderSupplementEnabled:
          reminderSupplementEnabled ?? this.reminderSupplementEnabled,
      reminderSupplementTime:
          reminderSupplementTime ?? this.reminderSupplementTime,
      reminderSupplementTime2:
          reminderSupplementTime2 ?? this.reminderSupplementTime2,
      reminderMealsEnabled: reminderMealsEnabled ?? this.reminderMealsEnabled,
      reminderBreakfast: reminderBreakfast ?? this.reminderBreakfast,
      reminderLunch: reminderLunch ?? this.reminderLunch,
      reminderDinner: reminderDinner ?? this.reminderDinner,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (darkMode.present) {
      map['dark_mode'] = Variable<int>(darkMode.value);
    }
    if (reminderWeighEnabled.present) {
      map['reminder_weigh_enabled'] = Variable<int>(reminderWeighEnabled.value);
    }
    if (reminderWeighTime.present) {
      map['reminder_weigh_time'] = Variable<String>(reminderWeighTime.value);
    }
    if (reminderWeighTime2.present) {
      map['reminder_weigh_time2'] = Variable<String>(reminderWeighTime2.value);
    }
    if (reminderSupplementEnabled.present) {
      map['reminder_supplement_enabled'] =
          Variable<int>(reminderSupplementEnabled.value);
    }
    if (reminderSupplementTime.present) {
      map['reminder_supplement_time'] =
          Variable<String>(reminderSupplementTime.value);
    }
    if (reminderSupplementTime2.present) {
      map['reminder_supplement_time2'] =
          Variable<String>(reminderSupplementTime2.value);
    }
    if (reminderMealsEnabled.present) {
      map['reminder_meals_enabled'] = Variable<int>(reminderMealsEnabled.value);
    }
    if (reminderBreakfast.present) {
      map['reminder_breakfast'] = Variable<String>(reminderBreakfast.value);
    }
    if (reminderLunch.present) {
      map['reminder_lunch'] = Variable<String>(reminderLunch.value);
    }
    if (reminderDinner.present) {
      map['reminder_dinner'] = Variable<String>(reminderDinner.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('darkMode: $darkMode, ')
          ..write('reminderWeighEnabled: $reminderWeighEnabled, ')
          ..write('reminderWeighTime: $reminderWeighTime, ')
          ..write('reminderWeighTime2: $reminderWeighTime2, ')
          ..write('reminderSupplementEnabled: $reminderSupplementEnabled, ')
          ..write('reminderSupplementTime: $reminderSupplementTime, ')
          ..write('reminderSupplementTime2: $reminderSupplementTime2, ')
          ..write('reminderMealsEnabled: $reminderMealsEnabled, ')
          ..write('reminderBreakfast: $reminderBreakfast, ')
          ..write('reminderLunch: $reminderLunch, ')
          ..write('reminderDinner: $reminderDinner')
          ..write(')'))
        .toString();
  }
}

class $WeightEntriesTable extends WeightEntries
    with TableInfo<$WeightEntriesTable, WeightEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, date, weight, uuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'WeightEntries';
  @override
  VerificationContext validateIntegrity(Insertable<WeightEntryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightEntryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid']),
    );
  }

  @override
  $WeightEntriesTable createAlias(String alias) {
    return $WeightEntriesTable(attachedDatabase, alias);
  }
}

class WeightEntryRow extends DataClass implements Insertable<WeightEntryRow> {
  final int id;
  final String date;
  final double weight;
  final String? uuid;
  const WeightEntryRow(
      {required this.id, required this.date, required this.weight, this.uuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['weight'] = Variable<double>(weight);
    if (!nullToAbsent || uuid != null) {
      map['uuid'] = Variable<String>(uuid);
    }
    return map;
  }

  WeightEntriesCompanion toCompanion(bool nullToAbsent) {
    return WeightEntriesCompanion(
      id: Value(id),
      date: Value(date),
      weight: Value(weight),
      uuid: uuid == null && nullToAbsent ? const Value.absent() : Value(uuid),
    );
  }

  factory WeightEntryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightEntryRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      weight: serializer.fromJson<double>(json['weight']),
      uuid: serializer.fromJson<String?>(json['uuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'weight': serializer.toJson<double>(weight),
      'uuid': serializer.toJson<String?>(uuid),
    };
  }

  WeightEntryRow copyWith(
          {int? id,
          String? date,
          double? weight,
          Value<String?> uuid = const Value.absent()}) =>
      WeightEntryRow(
        id: id ?? this.id,
        date: date ?? this.date,
        weight: weight ?? this.weight,
        uuid: uuid.present ? uuid.value : this.uuid,
      );
  WeightEntryRow copyWithCompanion(WeightEntriesCompanion data) {
    return WeightEntryRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      weight: data.weight.present ? data.weight.value : this.weight,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntryRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weight: $weight, ')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, weight, uuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightEntryRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.weight == this.weight &&
          other.uuid == this.uuid);
}

class WeightEntriesCompanion extends UpdateCompanion<WeightEntryRow> {
  final Value<int> id;
  final Value<String> date;
  final Value<double> weight;
  final Value<String?> uuid;
  const WeightEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.weight = const Value.absent(),
    this.uuid = const Value.absent(),
  });
  WeightEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required double weight,
    this.uuid = const Value.absent(),
  })  : date = Value(date),
        weight = Value(weight);
  static Insertable<WeightEntryRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<double>? weight,
    Expression<String>? uuid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (weight != null) 'weight': weight,
      if (uuid != null) 'uuid': uuid,
    });
  }

  WeightEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? date,
      Value<double>? weight,
      Value<String?>? uuid}) {
    return WeightEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      uuid: uuid ?? this.uuid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weight: $weight, ')
          ..write('uuid: $uuid')
          ..write(')'))
        .toString();
  }
}

class $AppDatabaseMetadataTable extends AppDatabaseMetadata
    with TableInfo<$AppDatabaseMetadataTable, AppDatabaseMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppDatabaseMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _schemaVersionMeta =
      const VerificationMeta('schemaVersion');
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
      'schema_version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtUtcMeta =
      const VerificationMeta('createdAtUtc');
  @override
  late final GeneratedColumn<String> createdAtUtc = GeneratedColumn<String>(
      'created_at_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _migratedAtUtcMeta =
      const VerificationMeta('migratedAtUtc');
  @override
  late final GeneratedColumn<String> migratedAtUtc = GeneratedColumn<String>(
      'migrated_at_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, schemaVersion, createdAtUtc, migratedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_database_metadata';
  @override
  VerificationContext validateIntegrity(
      Insertable<AppDatabaseMetadataRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schema_version')) {
      context.handle(
          _schemaVersionMeta,
          schemaVersion.isAcceptableOrUnknown(
              data['schema_version']!, _schemaVersionMeta));
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
          _createdAtUtcMeta,
          createdAtUtc.isAcceptableOrUnknown(
              data['created_at_utc']!, _createdAtUtcMeta));
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('migrated_at_utc')) {
      context.handle(
          _migratedAtUtcMeta,
          migratedAtUtc.isAcceptableOrUnknown(
              data['migrated_at_utc']!, _migratedAtUtcMeta));
    } else if (isInserting) {
      context.missing(_migratedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppDatabaseMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppDatabaseMetadataRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      schemaVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schema_version'])!,
      createdAtUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at_utc'])!,
      migratedAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}migrated_at_utc'])!,
    );
  }

  @override
  $AppDatabaseMetadataTable createAlias(String alias) {
    return $AppDatabaseMetadataTable(attachedDatabase, alias);
  }
}

class AppDatabaseMetadataRow extends DataClass
    implements Insertable<AppDatabaseMetadataRow> {
  final int id;
  final int schemaVersion;
  final String createdAtUtc;
  final String migratedAtUtc;
  const AppDatabaseMetadataRow(
      {required this.id,
      required this.schemaVersion,
      required this.createdAtUtc,
      required this.migratedAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    map['migrated_at_utc'] = Variable<String>(migratedAtUtc);
    return map;
  }

  AppDatabaseMetadataCompanion toCompanion(bool nullToAbsent) {
    return AppDatabaseMetadataCompanion(
      id: Value(id),
      schemaVersion: Value(schemaVersion),
      createdAtUtc: Value(createdAtUtc),
      migratedAtUtc: Value(migratedAtUtc),
    );
  }

  factory AppDatabaseMetadataRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppDatabaseMetadataRow(
      id: serializer.fromJson<int>(json['id']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
      migratedAtUtc: serializer.fromJson<String>(json['migratedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
      'migratedAtUtc': serializer.toJson<String>(migratedAtUtc),
    };
  }

  AppDatabaseMetadataRow copyWith(
          {int? id,
          int? schemaVersion,
          String? createdAtUtc,
          String? migratedAtUtc}) =>
      AppDatabaseMetadataRow(
        id: id ?? this.id,
        schemaVersion: schemaVersion ?? this.schemaVersion,
        createdAtUtc: createdAtUtc ?? this.createdAtUtc,
        migratedAtUtc: migratedAtUtc ?? this.migratedAtUtc,
      );
  AppDatabaseMetadataRow copyWithCompanion(AppDatabaseMetadataCompanion data) {
    return AppDatabaseMetadataRow(
      id: data.id.present ? data.id.value : this.id,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      migratedAtUtc: data.migratedAtUtc.present
          ? data.migratedAtUtc.value
          : this.migratedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppDatabaseMetadataRow(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('migratedAtUtc: $migratedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, schemaVersion, createdAtUtc, migratedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppDatabaseMetadataRow &&
          other.id == this.id &&
          other.schemaVersion == this.schemaVersion &&
          other.createdAtUtc == this.createdAtUtc &&
          other.migratedAtUtc == this.migratedAtUtc);
}

class AppDatabaseMetadataCompanion
    extends UpdateCompanion<AppDatabaseMetadataRow> {
  final Value<int> id;
  final Value<int> schemaVersion;
  final Value<String> createdAtUtc;
  final Value<String> migratedAtUtc;
  const AppDatabaseMetadataCompanion({
    this.id = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.migratedAtUtc = const Value.absent(),
  });
  AppDatabaseMetadataCompanion.insert({
    this.id = const Value.absent(),
    required int schemaVersion,
    required String createdAtUtc,
    required String migratedAtUtc,
  })  : schemaVersion = Value(schemaVersion),
        createdAtUtc = Value(createdAtUtc),
        migratedAtUtc = Value(migratedAtUtc);
  static Insertable<AppDatabaseMetadataRow> custom({
    Expression<int>? id,
    Expression<int>? schemaVersion,
    Expression<String>? createdAtUtc,
    Expression<String>? migratedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (migratedAtUtc != null) 'migrated_at_utc': migratedAtUtc,
    });
  }

  AppDatabaseMetadataCompanion copyWith(
      {Value<int>? id,
      Value<int>? schemaVersion,
      Value<String>? createdAtUtc,
      Value<String>? migratedAtUtc}) {
    return AppDatabaseMetadataCompanion(
      id: id ?? this.id,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      migratedAtUtc: migratedAtUtc ?? this.migratedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (migratedAtUtc.present) {
      map['migrated_at_utc'] = Variable<String>(migratedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppDatabaseMetadataCompanion(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('migratedAtUtc: $migratedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $HealthSourcesTable extends HealthSources
    with TableInfo<$HealthSourcesTable, HealthSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceNameMeta =
      const VerificationMeta('sourceName');
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
      'source_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceDeviceIdMeta =
      const VerificationMeta('sourceDeviceId');
  @override
  late final GeneratedColumn<String> sourceDeviceId = GeneratedColumn<String>(
      'source_device_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _discoveredAtUtcMeta =
      const VerificationMeta('discoveredAtUtc');
  @override
  late final GeneratedColumn<String> discoveredAtUtc = GeneratedColumn<String>(
      'discovered_at_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sourceName,
        sourceDeviceId,
        platform,
        priority,
        enabled,
        discoveredAtUtc
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_sources';
  @override
  VerificationContext validateIntegrity(Insertable<HealthSourceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_name')) {
      context.handle(
          _sourceNameMeta,
          sourceName.isAcceptableOrUnknown(
              data['source_name']!, _sourceNameMeta));
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('source_device_id')) {
      context.handle(
          _sourceDeviceIdMeta,
          sourceDeviceId.isAcceptableOrUnknown(
              data['source_device_id']!, _sourceDeviceIdMeta));
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    if (data.containsKey('discovered_at_utc')) {
      context.handle(
          _discoveredAtUtcMeta,
          discoveredAtUtc.isAcceptableOrUnknown(
              data['discovered_at_utc']!, _discoveredAtUtcMeta));
    } else if (isInserting) {
      context.missing(_discoveredAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthSourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthSourceRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sourceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_name'])!,
      sourceDeviceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_device_id']),
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      discoveredAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}discovered_at_utc'])!,
    );
  }

  @override
  $HealthSourcesTable createAlias(String alias) {
    return $HealthSourcesTable(attachedDatabase, alias);
  }
}

class HealthSourceRow extends DataClass implements Insertable<HealthSourceRow> {
  final String id;
  final String sourceName;
  final String? sourceDeviceId;
  final String platform;
  final int priority;
  final bool enabled;
  final String discoveredAtUtc;
  const HealthSourceRow(
      {required this.id,
      required this.sourceName,
      this.sourceDeviceId,
      required this.platform,
      required this.priority,
      required this.enabled,
      required this.discoveredAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_name'] = Variable<String>(sourceName);
    if (!nullToAbsent || sourceDeviceId != null) {
      map['source_device_id'] = Variable<String>(sourceDeviceId);
    }
    map['platform'] = Variable<String>(platform);
    map['priority'] = Variable<int>(priority);
    map['enabled'] = Variable<bool>(enabled);
    map['discovered_at_utc'] = Variable<String>(discoveredAtUtc);
    return map;
  }

  HealthSourcesCompanion toCompanion(bool nullToAbsent) {
    return HealthSourcesCompanion(
      id: Value(id),
      sourceName: Value(sourceName),
      sourceDeviceId: sourceDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDeviceId),
      platform: Value(platform),
      priority: Value(priority),
      enabled: Value(enabled),
      discoveredAtUtc: Value(discoveredAtUtc),
    );
  }

  factory HealthSourceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthSourceRow(
      id: serializer.fromJson<String>(json['id']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      sourceDeviceId: serializer.fromJson<String?>(json['sourceDeviceId']),
      platform: serializer.fromJson<String>(json['platform']),
      priority: serializer.fromJson<int>(json['priority']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      discoveredAtUtc: serializer.fromJson<String>(json['discoveredAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceName': serializer.toJson<String>(sourceName),
      'sourceDeviceId': serializer.toJson<String?>(sourceDeviceId),
      'platform': serializer.toJson<String>(platform),
      'priority': serializer.toJson<int>(priority),
      'enabled': serializer.toJson<bool>(enabled),
      'discoveredAtUtc': serializer.toJson<String>(discoveredAtUtc),
    };
  }

  HealthSourceRow copyWith(
          {String? id,
          String? sourceName,
          Value<String?> sourceDeviceId = const Value.absent(),
          String? platform,
          int? priority,
          bool? enabled,
          String? discoveredAtUtc}) =>
      HealthSourceRow(
        id: id ?? this.id,
        sourceName: sourceName ?? this.sourceName,
        sourceDeviceId:
            sourceDeviceId.present ? sourceDeviceId.value : this.sourceDeviceId,
        platform: platform ?? this.platform,
        priority: priority ?? this.priority,
        enabled: enabled ?? this.enabled,
        discoveredAtUtc: discoveredAtUtc ?? this.discoveredAtUtc,
      );
  HealthSourceRow copyWithCompanion(HealthSourcesCompanion data) {
    return HealthSourceRow(
      id: data.id.present ? data.id.value : this.id,
      sourceName:
          data.sourceName.present ? data.sourceName.value : this.sourceName,
      sourceDeviceId: data.sourceDeviceId.present
          ? data.sourceDeviceId.value
          : this.sourceDeviceId,
      platform: data.platform.present ? data.platform.value : this.platform,
      priority: data.priority.present ? data.priority.value : this.priority,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      discoveredAtUtc: data.discoveredAtUtc.present
          ? data.discoveredAtUtc.value
          : this.discoveredAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthSourceRow(')
          ..write('id: $id, ')
          ..write('sourceName: $sourceName, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('platform: $platform, ')
          ..write('priority: $priority, ')
          ..write('enabled: $enabled, ')
          ..write('discoveredAtUtc: $discoveredAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sourceName, sourceDeviceId, platform,
      priority, enabled, discoveredAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthSourceRow &&
          other.id == this.id &&
          other.sourceName == this.sourceName &&
          other.sourceDeviceId == this.sourceDeviceId &&
          other.platform == this.platform &&
          other.priority == this.priority &&
          other.enabled == this.enabled &&
          other.discoveredAtUtc == this.discoveredAtUtc);
}

class HealthSourcesCompanion extends UpdateCompanion<HealthSourceRow> {
  final Value<String> id;
  final Value<String> sourceName;
  final Value<String?> sourceDeviceId;
  final Value<String> platform;
  final Value<int> priority;
  final Value<bool> enabled;
  final Value<String> discoveredAtUtc;
  final Value<int> rowid;
  const HealthSourcesCompanion({
    this.id = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.sourceDeviceId = const Value.absent(),
    this.platform = const Value.absent(),
    this.priority = const Value.absent(),
    this.enabled = const Value.absent(),
    this.discoveredAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthSourcesCompanion.insert({
    required String id,
    required String sourceName,
    this.sourceDeviceId = const Value.absent(),
    required String platform,
    this.priority = const Value.absent(),
    this.enabled = const Value.absent(),
    required String discoveredAtUtc,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sourceName = Value(sourceName),
        platform = Value(platform),
        discoveredAtUtc = Value(discoveredAtUtc);
  static Insertable<HealthSourceRow> custom({
    Expression<String>? id,
    Expression<String>? sourceName,
    Expression<String>? sourceDeviceId,
    Expression<String>? platform,
    Expression<int>? priority,
    Expression<bool>? enabled,
    Expression<String>? discoveredAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceName != null) 'source_name': sourceName,
      if (sourceDeviceId != null) 'source_device_id': sourceDeviceId,
      if (platform != null) 'platform': platform,
      if (priority != null) 'priority': priority,
      if (enabled != null) 'enabled': enabled,
      if (discoveredAtUtc != null) 'discovered_at_utc': discoveredAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthSourcesCompanion copyWith(
      {Value<String>? id,
      Value<String>? sourceName,
      Value<String?>? sourceDeviceId,
      Value<String>? platform,
      Value<int>? priority,
      Value<bool>? enabled,
      Value<String>? discoveredAtUtc,
      Value<int>? rowid}) {
    return HealthSourcesCompanion(
      id: id ?? this.id,
      sourceName: sourceName ?? this.sourceName,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      platform: platform ?? this.platform,
      priority: priority ?? this.priority,
      enabled: enabled ?? this.enabled,
      discoveredAtUtc: discoveredAtUtc ?? this.discoveredAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (sourceDeviceId.present) {
      map['source_device_id'] = Variable<String>(sourceDeviceId.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (discoveredAtUtc.present) {
      map['discovered_at_utc'] = Variable<String>(discoveredAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthSourcesCompanion(')
          ..write('id: $id, ')
          ..write('sourceName: $sourceName, ')
          ..write('sourceDeviceId: $sourceDeviceId, ')
          ..write('platform: $platform, ')
          ..write('priority: $priority, ')
          ..write('enabled: $enabled, ')
          ..write('discoveredAtUtc: $discoveredAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HealthSyncStatesTable extends HealthSyncStates
    with TableInfo<$HealthSyncStatesTable, HealthSyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthSyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cursorUtcMeta =
      const VerificationMeta('cursorUtc');
  @override
  late final GeneratedColumn<String> cursorUtc = GeneratedColumn<String>(
      'cursor_utc', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSuccessUtcMeta =
      const VerificationMeta('lastSuccessUtc');
  @override
  late final GeneratedColumn<String> lastSuccessUtc = GeneratedColumn<String>(
      'last_success_utc', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('never'));
  @override
  List<GeneratedColumn> get $columns =>
      [sourceId, cursorUtc, lastSuccessUtc, lastError, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_sync_states';
  @override
  VerificationContext validateIntegrity(Insertable<HealthSyncStateRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('cursor_utc')) {
      context.handle(_cursorUtcMeta,
          cursorUtc.isAcceptableOrUnknown(data['cursor_utc']!, _cursorUtcMeta));
    }
    if (data.containsKey('last_success_utc')) {
      context.handle(
          _lastSuccessUtcMeta,
          lastSuccessUtc.isAcceptableOrUnknown(
              data['last_success_utc']!, _lastSuccessUtcMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId};
  @override
  HealthSyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthSyncStateRow(
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      cursorUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cursor_utc']),
      lastSuccessUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_success_utc']),
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $HealthSyncStatesTable createAlias(String alias) {
    return $HealthSyncStatesTable(attachedDatabase, alias);
  }
}

class HealthSyncStateRow extends DataClass
    implements Insertable<HealthSyncStateRow> {
  final String sourceId;
  final String? cursorUtc;
  final String? lastSuccessUtc;
  final String? lastError;
  final String status;
  const HealthSyncStateRow(
      {required this.sourceId,
      this.cursorUtc,
      this.lastSuccessUtc,
      this.lastError,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    if (!nullToAbsent || cursorUtc != null) {
      map['cursor_utc'] = Variable<String>(cursorUtc);
    }
    if (!nullToAbsent || lastSuccessUtc != null) {
      map['last_success_utc'] = Variable<String>(lastSuccessUtc);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  HealthSyncStatesCompanion toCompanion(bool nullToAbsent) {
    return HealthSyncStatesCompanion(
      sourceId: Value(sourceId),
      cursorUtc: cursorUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(cursorUtc),
      lastSuccessUtc: lastSuccessUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessUtc),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      status: Value(status),
    );
  }

  factory HealthSyncStateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthSyncStateRow(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      cursorUtc: serializer.fromJson<String?>(json['cursorUtc']),
      lastSuccessUtc: serializer.fromJson<String?>(json['lastSuccessUtc']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'cursorUtc': serializer.toJson<String?>(cursorUtc),
      'lastSuccessUtc': serializer.toJson<String?>(lastSuccessUtc),
      'lastError': serializer.toJson<String?>(lastError),
      'status': serializer.toJson<String>(status),
    };
  }

  HealthSyncStateRow copyWith(
          {String? sourceId,
          Value<String?> cursorUtc = const Value.absent(),
          Value<String?> lastSuccessUtc = const Value.absent(),
          Value<String?> lastError = const Value.absent(),
          String? status}) =>
      HealthSyncStateRow(
        sourceId: sourceId ?? this.sourceId,
        cursorUtc: cursorUtc.present ? cursorUtc.value : this.cursorUtc,
        lastSuccessUtc:
            lastSuccessUtc.present ? lastSuccessUtc.value : this.lastSuccessUtc,
        lastError: lastError.present ? lastError.value : this.lastError,
        status: status ?? this.status,
      );
  HealthSyncStateRow copyWithCompanion(HealthSyncStatesCompanion data) {
    return HealthSyncStateRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      cursorUtc: data.cursorUtc.present ? data.cursorUtc.value : this.cursorUtc,
      lastSuccessUtc: data.lastSuccessUtc.present
          ? data.lastSuccessUtc.value
          : this.lastSuccessUtc,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthSyncStateRow(')
          ..write('sourceId: $sourceId, ')
          ..write('cursorUtc: $cursorUtc, ')
          ..write('lastSuccessUtc: $lastSuccessUtc, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sourceId, cursorUtc, lastSuccessUtc, lastError, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthSyncStateRow &&
          other.sourceId == this.sourceId &&
          other.cursorUtc == this.cursorUtc &&
          other.lastSuccessUtc == this.lastSuccessUtc &&
          other.lastError == this.lastError &&
          other.status == this.status);
}

class HealthSyncStatesCompanion extends UpdateCompanion<HealthSyncStateRow> {
  final Value<String> sourceId;
  final Value<String?> cursorUtc;
  final Value<String?> lastSuccessUtc;
  final Value<String?> lastError;
  final Value<String> status;
  final Value<int> rowid;
  const HealthSyncStatesCompanion({
    this.sourceId = const Value.absent(),
    this.cursorUtc = const Value.absent(),
    this.lastSuccessUtc = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthSyncStatesCompanion.insert({
    required String sourceId,
    this.cursorUtc = const Value.absent(),
    this.lastSuccessUtc = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId);
  static Insertable<HealthSyncStateRow> custom({
    Expression<String>? sourceId,
    Expression<String>? cursorUtc,
    Expression<String>? lastSuccessUtc,
    Expression<String>? lastError,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (cursorUtc != null) 'cursor_utc': cursorUtc,
      if (lastSuccessUtc != null) 'last_success_utc': lastSuccessUtc,
      if (lastError != null) 'last_error': lastError,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthSyncStatesCompanion copyWith(
      {Value<String>? sourceId,
      Value<String?>? cursorUtc,
      Value<String?>? lastSuccessUtc,
      Value<String?>? lastError,
      Value<String>? status,
      Value<int>? rowid}) {
    return HealthSyncStatesCompanion(
      sourceId: sourceId ?? this.sourceId,
      cursorUtc: cursorUtc ?? this.cursorUtc,
      lastSuccessUtc: lastSuccessUtc ?? this.lastSuccessUtc,
      lastError: lastError ?? this.lastError,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (cursorUtc.present) {
      map['cursor_utc'] = Variable<String>(cursorUtc.value);
    }
    if (lastSuccessUtc.present) {
      map['last_success_utc'] = Variable<String>(lastSuccessUtc.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthSyncStatesCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('cursorUtc: $cursorUtc, ')
          ..write('lastSuccessUtc: $lastSuccessUtc, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HealthRecordsTable extends HealthRecords
    with TableInfo<$HealthRecordsTable, HealthRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startUtcMeta =
      const VerificationMeta('startUtc');
  @override
  late final GeneratedColumn<String> startUtc = GeneratedColumn<String>(
      'start_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endUtcMeta = const VerificationMeta('endUtc');
  @override
  late final GeneratedColumn<String> endUtc = GeneratedColumn<String>(
      'end_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localDayMeta =
      const VerificationMeta('localDay');
  @override
  late final GeneratedColumn<String> localDay = GeneratedColumn<String>(
      'local_day', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        sourceId,
        startUtc,
        endUtc,
        value,
        unit,
        localDay,
        payloadJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_records';
  @override
  VerificationContext validateIntegrity(Insertable<HealthRecordRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('start_utc')) {
      context.handle(_startUtcMeta,
          startUtc.isAcceptableOrUnknown(data['start_utc']!, _startUtcMeta));
    } else if (isInserting) {
      context.missing(_startUtcMeta);
    }
    if (data.containsKey('end_utc')) {
      context.handle(_endUtcMeta,
          endUtc.isAcceptableOrUnknown(data['end_utc']!, _endUtcMeta));
    } else if (isInserting) {
      context.missing(_endUtcMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('local_day')) {
      context.handle(_localDayMeta,
          localDay.isAcceptableOrUnknown(data['local_day']!, _localDayMeta));
    } else if (isInserting) {
      context.missing(_localDayMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthRecordRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      startUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_utc'])!,
      endUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_utc'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      localDay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_day'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json']),
    );
  }

  @override
  $HealthRecordsTable createAlias(String alias) {
    return $HealthRecordsTable(attachedDatabase, alias);
  }
}

class HealthRecordRow extends DataClass implements Insertable<HealthRecordRow> {
  final String id;
  final String type;
  final String sourceId;
  final String startUtc;
  final String endUtc;
  final double value;
  final String unit;
  final String localDay;
  final String? payloadJson;
  const HealthRecordRow(
      {required this.id,
      required this.type,
      required this.sourceId,
      required this.startUtc,
      required this.endUtc,
      required this.value,
      required this.unit,
      required this.localDay,
      this.payloadJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['source_id'] = Variable<String>(sourceId);
    map['start_utc'] = Variable<String>(startUtc);
    map['end_utc'] = Variable<String>(endUtc);
    map['value'] = Variable<double>(value);
    map['unit'] = Variable<String>(unit);
    map['local_day'] = Variable<String>(localDay);
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    return map;
  }

  HealthRecordsCompanion toCompanion(bool nullToAbsent) {
    return HealthRecordsCompanion(
      id: Value(id),
      type: Value(type),
      sourceId: Value(sourceId),
      startUtc: Value(startUtc),
      endUtc: Value(endUtc),
      value: Value(value),
      unit: Value(unit),
      localDay: Value(localDay),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
    );
  }

  factory HealthRecordRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthRecordRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      startUtc: serializer.fromJson<String>(json['startUtc']),
      endUtc: serializer.fromJson<String>(json['endUtc']),
      value: serializer.fromJson<double>(json['value']),
      unit: serializer.fromJson<String>(json['unit']),
      localDay: serializer.fromJson<String>(json['localDay']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'sourceId': serializer.toJson<String>(sourceId),
      'startUtc': serializer.toJson<String>(startUtc),
      'endUtc': serializer.toJson<String>(endUtc),
      'value': serializer.toJson<double>(value),
      'unit': serializer.toJson<String>(unit),
      'localDay': serializer.toJson<String>(localDay),
      'payloadJson': serializer.toJson<String?>(payloadJson),
    };
  }

  HealthRecordRow copyWith(
          {String? id,
          String? type,
          String? sourceId,
          String? startUtc,
          String? endUtc,
          double? value,
          String? unit,
          String? localDay,
          Value<String?> payloadJson = const Value.absent()}) =>
      HealthRecordRow(
        id: id ?? this.id,
        type: type ?? this.type,
        sourceId: sourceId ?? this.sourceId,
        startUtc: startUtc ?? this.startUtc,
        endUtc: endUtc ?? this.endUtc,
        value: value ?? this.value,
        unit: unit ?? this.unit,
        localDay: localDay ?? this.localDay,
        payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
      );
  HealthRecordRow copyWithCompanion(HealthRecordsCompanion data) {
    return HealthRecordRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      startUtc: data.startUtc.present ? data.startUtc.value : this.startUtc,
      endUtc: data.endUtc.present ? data.endUtc.value : this.endUtc,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      localDay: data.localDay.present ? data.localDay.value : this.localDay,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthRecordRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('sourceId: $sourceId, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('localDay: $localDay, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, type, sourceId, startUtc, endUtc, value, unit, localDay, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthRecordRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.sourceId == this.sourceId &&
          other.startUtc == this.startUtc &&
          other.endUtc == this.endUtc &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.localDay == this.localDay &&
          other.payloadJson == this.payloadJson);
}

class HealthRecordsCompanion extends UpdateCompanion<HealthRecordRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> sourceId;
  final Value<String> startUtc;
  final Value<String> endUtc;
  final Value<double> value;
  final Value<String> unit;
  final Value<String> localDay;
  final Value<String?> payloadJson;
  final Value<int> rowid;
  const HealthRecordsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.endUtc = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.localDay = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthRecordsCompanion.insert({
    required String id,
    required String type,
    required String sourceId,
    required String startUtc,
    required String endUtc,
    required double value,
    required String unit,
    required String localDay,
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        sourceId = Value(sourceId),
        startUtc = Value(startUtc),
        endUtc = Value(endUtc),
        value = Value(value),
        unit = Value(unit),
        localDay = Value(localDay);
  static Insertable<HealthRecordRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? sourceId,
    Expression<String>? startUtc,
    Expression<String>? endUtc,
    Expression<double>? value,
    Expression<String>? unit,
    Expression<String>? localDay,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (sourceId != null) 'source_id': sourceId,
      if (startUtc != null) 'start_utc': startUtc,
      if (endUtc != null) 'end_utc': endUtc,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (localDay != null) 'local_day': localDay,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? sourceId,
      Value<String>? startUtc,
      Value<String>? endUtc,
      Value<double>? value,
      Value<String>? unit,
      Value<String>? localDay,
      Value<String?>? payloadJson,
      Value<int>? rowid}) {
    return HealthRecordsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      sourceId: sourceId ?? this.sourceId,
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      localDay: localDay ?? this.localDay,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (startUtc.present) {
      map['start_utc'] = Variable<String>(startUtc.value);
    }
    if (endUtc.present) {
      map['end_utc'] = Variable<String>(endUtc.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (localDay.present) {
      map['local_day'] = Variable<String>(localDay.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthRecordsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('sourceId: $sourceId, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('localDay: $localDay, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyHealthAggregatesTable extends DailyHealthAggregates
    with TableInfo<$DailyHealthAggregatesTable, DailyHealthAggregateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyHealthAggregatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
      'day', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
      'steps', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _activeKcalMeta =
      const VerificationMeta('activeKcal');
  @override
  late final GeneratedColumn<double> activeKcal = GeneratedColumn<double>(
      'active_kcal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalKcalMeta =
      const VerificationMeta('totalKcal');
  @override
  late final GeneratedColumn<double> totalKcal = GeneratedColumn<double>(
      'total_kcal', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _distanceMMeta =
      const VerificationMeta('distanceM');
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
      'distance_m', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _heartRateAvgMeta =
      const VerificationMeta('heartRateAvg');
  @override
  late final GeneratedColumn<double> heartRateAvg = GeneratedColumn<double>(
      'heart_rate_avg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _restingHrMeta =
      const VerificationMeta('restingHr');
  @override
  late final GeneratedColumn<double> restingHr = GeneratedColumn<double>(
      'resting_hr', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sleepMinutesMeta =
      const VerificationMeta('sleepMinutes');
  @override
  late final GeneratedColumn<double> sleepMinutes = GeneratedColumn<double>(
      'sleep_minutes', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sourceIdsMeta =
      const VerificationMeta('sourceIds');
  @override
  late final GeneratedColumn<String> sourceIds = GeneratedColumn<String>(
      'source_ids', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _updatedAtUtcMeta =
      const VerificationMeta('updatedAtUtc');
  @override
  late final GeneratedColumn<String> updatedAtUtc = GeneratedColumn<String>(
      'updated_at_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        day,
        steps,
        activeKcal,
        totalKcal,
        distanceM,
        heartRateAvg,
        restingHr,
        sleepMinutes,
        sourceIds,
        updatedAtUtc
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_health_aggregates';
  @override
  VerificationContext validateIntegrity(
      Insertable<DailyHealthAggregateRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('steps')) {
      context.handle(
          _stepsMeta, steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta));
    }
    if (data.containsKey('active_kcal')) {
      context.handle(
          _activeKcalMeta,
          activeKcal.isAcceptableOrUnknown(
              data['active_kcal']!, _activeKcalMeta));
    }
    if (data.containsKey('total_kcal')) {
      context.handle(_totalKcalMeta,
          totalKcal.isAcceptableOrUnknown(data['total_kcal']!, _totalKcalMeta));
    }
    if (data.containsKey('distance_m')) {
      context.handle(_distanceMMeta,
          distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta));
    }
    if (data.containsKey('heart_rate_avg')) {
      context.handle(
          _heartRateAvgMeta,
          heartRateAvg.isAcceptableOrUnknown(
              data['heart_rate_avg']!, _heartRateAvgMeta));
    }
    if (data.containsKey('resting_hr')) {
      context.handle(_restingHrMeta,
          restingHr.isAcceptableOrUnknown(data['resting_hr']!, _restingHrMeta));
    }
    if (data.containsKey('sleep_minutes')) {
      context.handle(
          _sleepMinutesMeta,
          sleepMinutes.isAcceptableOrUnknown(
              data['sleep_minutes']!, _sleepMinutesMeta));
    }
    if (data.containsKey('source_ids')) {
      context.handle(_sourceIdsMeta,
          sourceIds.isAcceptableOrUnknown(data['source_ids']!, _sourceIdsMeta));
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
          _updatedAtUtcMeta,
          updatedAtUtc.isAcceptableOrUnknown(
              data['updated_at_utc']!, _updatedAtUtcMeta));
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  DailyHealthAggregateRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyHealthAggregateRow(
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      steps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}steps'])!,
      activeKcal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}active_kcal'])!,
      totalKcal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_kcal']),
      distanceM: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance_m'])!,
      heartRateAvg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}heart_rate_avg']),
      restingHr: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}resting_hr']),
      sleepMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sleep_minutes']),
      sourceIds: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_ids'])!,
      updatedAtUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at_utc'])!,
    );
  }

  @override
  $DailyHealthAggregatesTable createAlias(String alias) {
    return $DailyHealthAggregatesTable(attachedDatabase, alias);
  }
}

class DailyHealthAggregateRow extends DataClass
    implements Insertable<DailyHealthAggregateRow> {
  final String day;
  final int steps;
  final double activeKcal;
  final double? totalKcal;
  final double distanceM;
  final double? heartRateAvg;
  final double? restingHr;
  final double? sleepMinutes;
  final String sourceIds;
  final String updatedAtUtc;
  const DailyHealthAggregateRow(
      {required this.day,
      required this.steps,
      required this.activeKcal,
      this.totalKcal,
      required this.distanceM,
      this.heartRateAvg,
      this.restingHr,
      this.sleepMinutes,
      required this.sourceIds,
      required this.updatedAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['steps'] = Variable<int>(steps);
    map['active_kcal'] = Variable<double>(activeKcal);
    if (!nullToAbsent || totalKcal != null) {
      map['total_kcal'] = Variable<double>(totalKcal);
    }
    map['distance_m'] = Variable<double>(distanceM);
    if (!nullToAbsent || heartRateAvg != null) {
      map['heart_rate_avg'] = Variable<double>(heartRateAvg);
    }
    if (!nullToAbsent || restingHr != null) {
      map['resting_hr'] = Variable<double>(restingHr);
    }
    if (!nullToAbsent || sleepMinutes != null) {
      map['sleep_minutes'] = Variable<double>(sleepMinutes);
    }
    map['source_ids'] = Variable<String>(sourceIds);
    map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    return map;
  }

  DailyHealthAggregatesCompanion toCompanion(bool nullToAbsent) {
    return DailyHealthAggregatesCompanion(
      day: Value(day),
      steps: Value(steps),
      activeKcal: Value(activeKcal),
      totalKcal: totalKcal == null && nullToAbsent
          ? const Value.absent()
          : Value(totalKcal),
      distanceM: Value(distanceM),
      heartRateAvg: heartRateAvg == null && nullToAbsent
          ? const Value.absent()
          : Value(heartRateAvg),
      restingHr: restingHr == null && nullToAbsent
          ? const Value.absent()
          : Value(restingHr),
      sleepMinutes: sleepMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepMinutes),
      sourceIds: Value(sourceIds),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory DailyHealthAggregateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyHealthAggregateRow(
      day: serializer.fromJson<String>(json['day']),
      steps: serializer.fromJson<int>(json['steps']),
      activeKcal: serializer.fromJson<double>(json['activeKcal']),
      totalKcal: serializer.fromJson<double?>(json['totalKcal']),
      distanceM: serializer.fromJson<double>(json['distanceM']),
      heartRateAvg: serializer.fromJson<double?>(json['heartRateAvg']),
      restingHr: serializer.fromJson<double?>(json['restingHr']),
      sleepMinutes: serializer.fromJson<double?>(json['sleepMinutes']),
      sourceIds: serializer.fromJson<String>(json['sourceIds']),
      updatedAtUtc: serializer.fromJson<String>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'steps': serializer.toJson<int>(steps),
      'activeKcal': serializer.toJson<double>(activeKcal),
      'totalKcal': serializer.toJson<double?>(totalKcal),
      'distanceM': serializer.toJson<double>(distanceM),
      'heartRateAvg': serializer.toJson<double?>(heartRateAvg),
      'restingHr': serializer.toJson<double?>(restingHr),
      'sleepMinutes': serializer.toJson<double?>(sleepMinutes),
      'sourceIds': serializer.toJson<String>(sourceIds),
      'updatedAtUtc': serializer.toJson<String>(updatedAtUtc),
    };
  }

  DailyHealthAggregateRow copyWith(
          {String? day,
          int? steps,
          double? activeKcal,
          Value<double?> totalKcal = const Value.absent(),
          double? distanceM,
          Value<double?> heartRateAvg = const Value.absent(),
          Value<double?> restingHr = const Value.absent(),
          Value<double?> sleepMinutes = const Value.absent(),
          String? sourceIds,
          String? updatedAtUtc}) =>
      DailyHealthAggregateRow(
        day: day ?? this.day,
        steps: steps ?? this.steps,
        activeKcal: activeKcal ?? this.activeKcal,
        totalKcal: totalKcal.present ? totalKcal.value : this.totalKcal,
        distanceM: distanceM ?? this.distanceM,
        heartRateAvg:
            heartRateAvg.present ? heartRateAvg.value : this.heartRateAvg,
        restingHr: restingHr.present ? restingHr.value : this.restingHr,
        sleepMinutes:
            sleepMinutes.present ? sleepMinutes.value : this.sleepMinutes,
        sourceIds: sourceIds ?? this.sourceIds,
        updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      );
  DailyHealthAggregateRow copyWithCompanion(
      DailyHealthAggregatesCompanion data) {
    return DailyHealthAggregateRow(
      day: data.day.present ? data.day.value : this.day,
      steps: data.steps.present ? data.steps.value : this.steps,
      activeKcal:
          data.activeKcal.present ? data.activeKcal.value : this.activeKcal,
      totalKcal: data.totalKcal.present ? data.totalKcal.value : this.totalKcal,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      heartRateAvg: data.heartRateAvg.present
          ? data.heartRateAvg.value
          : this.heartRateAvg,
      restingHr: data.restingHr.present ? data.restingHr.value : this.restingHr,
      sleepMinutes: data.sleepMinutes.present
          ? data.sleepMinutes.value
          : this.sleepMinutes,
      sourceIds: data.sourceIds.present ? data.sourceIds.value : this.sourceIds,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyHealthAggregateRow(')
          ..write('day: $day, ')
          ..write('steps: $steps, ')
          ..write('activeKcal: $activeKcal, ')
          ..write('totalKcal: $totalKcal, ')
          ..write('distanceM: $distanceM, ')
          ..write('heartRateAvg: $heartRateAvg, ')
          ..write('restingHr: $restingHr, ')
          ..write('sleepMinutes: $sleepMinutes, ')
          ..write('sourceIds: $sourceIds, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, steps, activeKcal, totalKcal, distanceM,
      heartRateAvg, restingHr, sleepMinutes, sourceIds, updatedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyHealthAggregateRow &&
          other.day == this.day &&
          other.steps == this.steps &&
          other.activeKcal == this.activeKcal &&
          other.totalKcal == this.totalKcal &&
          other.distanceM == this.distanceM &&
          other.heartRateAvg == this.heartRateAvg &&
          other.restingHr == this.restingHr &&
          other.sleepMinutes == this.sleepMinutes &&
          other.sourceIds == this.sourceIds &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class DailyHealthAggregatesCompanion
    extends UpdateCompanion<DailyHealthAggregateRow> {
  final Value<String> day;
  final Value<int> steps;
  final Value<double> activeKcal;
  final Value<double?> totalKcal;
  final Value<double> distanceM;
  final Value<double?> heartRateAvg;
  final Value<double?> restingHr;
  final Value<double?> sleepMinutes;
  final Value<String> sourceIds;
  final Value<String> updatedAtUtc;
  final Value<int> rowid;
  const DailyHealthAggregatesCompanion({
    this.day = const Value.absent(),
    this.steps = const Value.absent(),
    this.activeKcal = const Value.absent(),
    this.totalKcal = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.heartRateAvg = const Value.absent(),
    this.restingHr = const Value.absent(),
    this.sleepMinutes = const Value.absent(),
    this.sourceIds = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyHealthAggregatesCompanion.insert({
    required String day,
    this.steps = const Value.absent(),
    this.activeKcal = const Value.absent(),
    this.totalKcal = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.heartRateAvg = const Value.absent(),
    this.restingHr = const Value.absent(),
    this.sleepMinutes = const Value.absent(),
    this.sourceIds = const Value.absent(),
    required String updatedAtUtc,
    this.rowid = const Value.absent(),
  })  : day = Value(day),
        updatedAtUtc = Value(updatedAtUtc);
  static Insertable<DailyHealthAggregateRow> custom({
    Expression<String>? day,
    Expression<int>? steps,
    Expression<double>? activeKcal,
    Expression<double>? totalKcal,
    Expression<double>? distanceM,
    Expression<double>? heartRateAvg,
    Expression<double>? restingHr,
    Expression<double>? sleepMinutes,
    Expression<String>? sourceIds,
    Expression<String>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (steps != null) 'steps': steps,
      if (activeKcal != null) 'active_kcal': activeKcal,
      if (totalKcal != null) 'total_kcal': totalKcal,
      if (distanceM != null) 'distance_m': distanceM,
      if (heartRateAvg != null) 'heart_rate_avg': heartRateAvg,
      if (restingHr != null) 'resting_hr': restingHr,
      if (sleepMinutes != null) 'sleep_minutes': sleepMinutes,
      if (sourceIds != null) 'source_ids': sourceIds,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyHealthAggregatesCompanion copyWith(
      {Value<String>? day,
      Value<int>? steps,
      Value<double>? activeKcal,
      Value<double?>? totalKcal,
      Value<double>? distanceM,
      Value<double?>? heartRateAvg,
      Value<double?>? restingHr,
      Value<double?>? sleepMinutes,
      Value<String>? sourceIds,
      Value<String>? updatedAtUtc,
      Value<int>? rowid}) {
    return DailyHealthAggregatesCompanion(
      day: day ?? this.day,
      steps: steps ?? this.steps,
      activeKcal: activeKcal ?? this.activeKcal,
      totalKcal: totalKcal ?? this.totalKcal,
      distanceM: distanceM ?? this.distanceM,
      heartRateAvg: heartRateAvg ?? this.heartRateAvg,
      restingHr: restingHr ?? this.restingHr,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      sourceIds: sourceIds ?? this.sourceIds,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (activeKcal.present) {
      map['active_kcal'] = Variable<double>(activeKcal.value);
    }
    if (totalKcal.present) {
      map['total_kcal'] = Variable<double>(totalKcal.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (heartRateAvg.present) {
      map['heart_rate_avg'] = Variable<double>(heartRateAvg.value);
    }
    if (restingHr.present) {
      map['resting_hr'] = Variable<double>(restingHr.value);
    }
    if (sleepMinutes.present) {
      map['sleep_minutes'] = Variable<double>(sleepMinutes.value);
    }
    if (sourceIds.present) {
      map['source_ids'] = Variable<String>(sourceIds.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyHealthAggregatesCompanion(')
          ..write('day: $day, ')
          ..write('steps: $steps, ')
          ..write('activeKcal: $activeKcal, ')
          ..write('totalKcal: $totalKcal, ')
          ..write('distanceM: $distanceM, ')
          ..write('heartRateAvg: $heartRateAvg, ')
          ..write('restingHr: $restingHr, ')
          ..write('sleepMinutes: $sleepMinutes, ')
          ..write('sourceIds: $sourceIds, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SleepSessionsTable extends SleepSessions
    with TableInfo<$SleepSessionsTable, SleepSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startUtcMeta =
      const VerificationMeta('startUtc');
  @override
  late final GeneratedColumn<String> startUtc = GeneratedColumn<String>(
      'start_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endUtcMeta = const VerificationMeta('endUtc');
  @override
  late final GeneratedColumn<String> endUtc = GeneratedColumn<String>(
      'end_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stagesJsonMeta =
      const VerificationMeta('stagesJson');
  @override
  late final GeneratedColumn<String> stagesJson = GeneratedColumn<String>(
      'stages_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, startUtc, endUtc, durationMinutes, sourceId, stagesJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<SleepSessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_utc')) {
      context.handle(_startUtcMeta,
          startUtc.isAcceptableOrUnknown(data['start_utc']!, _startUtcMeta));
    } else if (isInserting) {
      context.missing(_startUtcMeta);
    }
    if (data.containsKey('end_utc')) {
      context.handle(_endUtcMeta,
          endUtc.isAcceptableOrUnknown(data['end_utc']!, _endUtcMeta));
    } else if (isInserting) {
      context.missing(_endUtcMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('stages_json')) {
      context.handle(
          _stagesJsonMeta,
          stagesJson.isAcceptableOrUnknown(
              data['stages_json']!, _stagesJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepSessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      startUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_utc'])!,
      endUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_utc'])!,
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      stagesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stages_json']),
    );
  }

  @override
  $SleepSessionsTable createAlias(String alias) {
    return $SleepSessionsTable(attachedDatabase, alias);
  }
}

class SleepSessionRow extends DataClass implements Insertable<SleepSessionRow> {
  final String id;
  final String startUtc;
  final String endUtc;
  final int durationMinutes;
  final String sourceId;
  final String? stagesJson;
  const SleepSessionRow(
      {required this.id,
      required this.startUtc,
      required this.endUtc,
      required this.durationMinutes,
      required this.sourceId,
      this.stagesJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_utc'] = Variable<String>(startUtc);
    map['end_utc'] = Variable<String>(endUtc);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['source_id'] = Variable<String>(sourceId);
    if (!nullToAbsent || stagesJson != null) {
      map['stages_json'] = Variable<String>(stagesJson);
    }
    return map;
  }

  SleepSessionsCompanion toCompanion(bool nullToAbsent) {
    return SleepSessionsCompanion(
      id: Value(id),
      startUtc: Value(startUtc),
      endUtc: Value(endUtc),
      durationMinutes: Value(durationMinutes),
      sourceId: Value(sourceId),
      stagesJson: stagesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(stagesJson),
    );
  }

  factory SleepSessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepSessionRow(
      id: serializer.fromJson<String>(json['id']),
      startUtc: serializer.fromJson<String>(json['startUtc']),
      endUtc: serializer.fromJson<String>(json['endUtc']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      stagesJson: serializer.fromJson<String?>(json['stagesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startUtc': serializer.toJson<String>(startUtc),
      'endUtc': serializer.toJson<String>(endUtc),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'sourceId': serializer.toJson<String>(sourceId),
      'stagesJson': serializer.toJson<String?>(stagesJson),
    };
  }

  SleepSessionRow copyWith(
          {String? id,
          String? startUtc,
          String? endUtc,
          int? durationMinutes,
          String? sourceId,
          Value<String?> stagesJson = const Value.absent()}) =>
      SleepSessionRow(
        id: id ?? this.id,
        startUtc: startUtc ?? this.startUtc,
        endUtc: endUtc ?? this.endUtc,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        sourceId: sourceId ?? this.sourceId,
        stagesJson: stagesJson.present ? stagesJson.value : this.stagesJson,
      );
  SleepSessionRow copyWithCompanion(SleepSessionsCompanion data) {
    return SleepSessionRow(
      id: data.id.present ? data.id.value : this.id,
      startUtc: data.startUtc.present ? data.startUtc.value : this.startUtc,
      endUtc: data.endUtc.present ? data.endUtc.value : this.endUtc,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      stagesJson:
          data.stagesJson.present ? data.stagesJson.value : this.stagesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepSessionRow(')
          ..write('id: $id, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('sourceId: $sourceId, ')
          ..write('stagesJson: $stagesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startUtc, endUtc, durationMinutes, sourceId, stagesJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepSessionRow &&
          other.id == this.id &&
          other.startUtc == this.startUtc &&
          other.endUtc == this.endUtc &&
          other.durationMinutes == this.durationMinutes &&
          other.sourceId == this.sourceId &&
          other.stagesJson == this.stagesJson);
}

class SleepSessionsCompanion extends UpdateCompanion<SleepSessionRow> {
  final Value<String> id;
  final Value<String> startUtc;
  final Value<String> endUtc;
  final Value<int> durationMinutes;
  final Value<String> sourceId;
  final Value<String?> stagesJson;
  final Value<int> rowid;
  const SleepSessionsCompanion({
    this.id = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.endUtc = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.stagesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SleepSessionsCompanion.insert({
    required String id,
    required String startUtc,
    required String endUtc,
    required int durationMinutes,
    required String sourceId,
    this.stagesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        startUtc = Value(startUtc),
        endUtc = Value(endUtc),
        durationMinutes = Value(durationMinutes),
        sourceId = Value(sourceId);
  static Insertable<SleepSessionRow> custom({
    Expression<String>? id,
    Expression<String>? startUtc,
    Expression<String>? endUtc,
    Expression<int>? durationMinutes,
    Expression<String>? sourceId,
    Expression<String>? stagesJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startUtc != null) 'start_utc': startUtc,
      if (endUtc != null) 'end_utc': endUtc,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (sourceId != null) 'source_id': sourceId,
      if (stagesJson != null) 'stages_json': stagesJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SleepSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? startUtc,
      Value<String>? endUtc,
      Value<int>? durationMinutes,
      Value<String>? sourceId,
      Value<String?>? stagesJson,
      Value<int>? rowid}) {
    return SleepSessionsCompanion(
      id: id ?? this.id,
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      sourceId: sourceId ?? this.sourceId,
      stagesJson: stagesJson ?? this.stagesJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startUtc.present) {
      map['start_utc'] = Variable<String>(startUtc.value);
    }
    if (endUtc.present) {
      map['end_utc'] = Variable<String>(endUtc.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (stagesJson.present) {
      map['stages_json'] = Variable<String>(stagesJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('sourceId: $sourceId, ')
          ..write('stagesJson: $stagesJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startUtcMeta =
      const VerificationMeta('startUtc');
  @override
  late final GeneratedColumn<String> startUtc = GeneratedColumn<String>(
      'start_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endUtcMeta = const VerificationMeta('endUtc');
  @override
  late final GeneratedColumn<String> endUtc = GeneratedColumn<String>(
      'end_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<double> durationSeconds = GeneratedColumn<double>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _distanceMMeta =
      const VerificationMeta('distanceM');
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
      'distance_m', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _energyKcalMeta =
      const VerificationMeta('energyKcal');
  @override
  late final GeneratedColumn<double> energyKcal = GeneratedColumn<double>(
      'energy_kcal', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _routeStatusMeta =
      const VerificationMeta('routeStatus');
  @override
  late final GeneratedColumn<String> routeStatus = GeneratedColumn<String>(
      'route_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unavailable'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        startUtc,
        endUtc,
        durationSeconds,
        distanceM,
        energyKcal,
        sourceId,
        routeStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutSessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('start_utc')) {
      context.handle(_startUtcMeta,
          startUtc.isAcceptableOrUnknown(data['start_utc']!, _startUtcMeta));
    } else if (isInserting) {
      context.missing(_startUtcMeta);
    }
    if (data.containsKey('end_utc')) {
      context.handle(_endUtcMeta,
          endUtc.isAcceptableOrUnknown(data['end_utc']!, _endUtcMeta));
    } else if (isInserting) {
      context.missing(_endUtcMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('distance_m')) {
      context.handle(_distanceMMeta,
          distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta));
    }
    if (data.containsKey('energy_kcal')) {
      context.handle(
          _energyKcalMeta,
          energyKcal.isAcceptableOrUnknown(
              data['energy_kcal']!, _energyKcalMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('route_status')) {
      context.handle(
          _routeStatusMeta,
          routeStatus.isAcceptableOrUnknown(
              data['route_status']!, _routeStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      startUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_utc'])!,
      endUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_utc'])!,
      durationSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}duration_seconds'])!,
      distanceM: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance_m']),
      energyKcal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}energy_kcal']),
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      routeStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}route_status'])!,
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSessionRow extends DataClass
    implements Insertable<WorkoutSessionRow> {
  final String id;
  final String type;
  final String startUtc;
  final String endUtc;
  final double durationSeconds;
  final double? distanceM;
  final double? energyKcal;
  final String sourceId;
  final String routeStatus;
  const WorkoutSessionRow(
      {required this.id,
      required this.type,
      required this.startUtc,
      required this.endUtc,
      required this.durationSeconds,
      this.distanceM,
      this.energyKcal,
      required this.sourceId,
      required this.routeStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['start_utc'] = Variable<String>(startUtc);
    map['end_utc'] = Variable<String>(endUtc);
    map['duration_seconds'] = Variable<double>(durationSeconds);
    if (!nullToAbsent || distanceM != null) {
      map['distance_m'] = Variable<double>(distanceM);
    }
    if (!nullToAbsent || energyKcal != null) {
      map['energy_kcal'] = Variable<double>(energyKcal);
    }
    map['source_id'] = Variable<String>(sourceId);
    map['route_status'] = Variable<String>(routeStatus);
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      type: Value(type),
      startUtc: Value(startUtc),
      endUtc: Value(endUtc),
      durationSeconds: Value(durationSeconds),
      distanceM: distanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceM),
      energyKcal: energyKcal == null && nullToAbsent
          ? const Value.absent()
          : Value(energyKcal),
      sourceId: Value(sourceId),
      routeStatus: Value(routeStatus),
    );
  }

  factory WorkoutSessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSessionRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      startUtc: serializer.fromJson<String>(json['startUtc']),
      endUtc: serializer.fromJson<String>(json['endUtc']),
      durationSeconds: serializer.fromJson<double>(json['durationSeconds']),
      distanceM: serializer.fromJson<double?>(json['distanceM']),
      energyKcal: serializer.fromJson<double?>(json['energyKcal']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      routeStatus: serializer.fromJson<String>(json['routeStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'startUtc': serializer.toJson<String>(startUtc),
      'endUtc': serializer.toJson<String>(endUtc),
      'durationSeconds': serializer.toJson<double>(durationSeconds),
      'distanceM': serializer.toJson<double?>(distanceM),
      'energyKcal': serializer.toJson<double?>(energyKcal),
      'sourceId': serializer.toJson<String>(sourceId),
      'routeStatus': serializer.toJson<String>(routeStatus),
    };
  }

  WorkoutSessionRow copyWith(
          {String? id,
          String? type,
          String? startUtc,
          String? endUtc,
          double? durationSeconds,
          Value<double?> distanceM = const Value.absent(),
          Value<double?> energyKcal = const Value.absent(),
          String? sourceId,
          String? routeStatus}) =>
      WorkoutSessionRow(
        id: id ?? this.id,
        type: type ?? this.type,
        startUtc: startUtc ?? this.startUtc,
        endUtc: endUtc ?? this.endUtc,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        distanceM: distanceM.present ? distanceM.value : this.distanceM,
        energyKcal: energyKcal.present ? energyKcal.value : this.energyKcal,
        sourceId: sourceId ?? this.sourceId,
        routeStatus: routeStatus ?? this.routeStatus,
      );
  WorkoutSessionRow copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSessionRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      startUtc: data.startUtc.present ? data.startUtc.value : this.startUtc,
      endUtc: data.endUtc.present ? data.endUtc.value : this.endUtc,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      energyKcal:
          data.energyKcal.present ? data.energyKcal.value : this.energyKcal,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      routeStatus:
          data.routeStatus.present ? data.routeStatus.value : this.routeStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceM: $distanceM, ')
          ..write('energyKcal: $energyKcal, ')
          ..write('sourceId: $sourceId, ')
          ..write('routeStatus: $routeStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, startUtc, endUtc, durationSeconds,
      distanceM, energyKcal, sourceId, routeStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSessionRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.startUtc == this.startUtc &&
          other.endUtc == this.endUtc &&
          other.durationSeconds == this.durationSeconds &&
          other.distanceM == this.distanceM &&
          other.energyKcal == this.energyKcal &&
          other.sourceId == this.sourceId &&
          other.routeStatus == this.routeStatus);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSessionRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> startUtc;
  final Value<String> endUtc;
  final Value<double> durationSeconds;
  final Value<double?> distanceM;
  final Value<double?> energyKcal;
  final Value<String> sourceId;
  final Value<String> routeStatus;
  final Value<int> rowid;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.endUtc = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.energyKcal = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.routeStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    required String id,
    required String type,
    required String startUtc,
    required String endUtc,
    required double durationSeconds,
    this.distanceM = const Value.absent(),
    this.energyKcal = const Value.absent(),
    required String sourceId,
    this.routeStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        startUtc = Value(startUtc),
        endUtc = Value(endUtc),
        durationSeconds = Value(durationSeconds),
        sourceId = Value(sourceId);
  static Insertable<WorkoutSessionRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? startUtc,
    Expression<String>? endUtc,
    Expression<double>? durationSeconds,
    Expression<double>? distanceM,
    Expression<double>? energyKcal,
    Expression<String>? sourceId,
    Expression<String>? routeStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (startUtc != null) 'start_utc': startUtc,
      if (endUtc != null) 'end_utc': endUtc,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (distanceM != null) 'distance_m': distanceM,
      if (energyKcal != null) 'energy_kcal': energyKcal,
      if (sourceId != null) 'source_id': sourceId,
      if (routeStatus != null) 'route_status': routeStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? startUtc,
      Value<String>? endUtc,
      Value<double>? durationSeconds,
      Value<double?>? distanceM,
      Value<double?>? energyKcal,
      Value<String>? sourceId,
      Value<String>? routeStatus,
      Value<int>? rowid}) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceM: distanceM ?? this.distanceM,
      energyKcal: energyKcal ?? this.energyKcal,
      sourceId: sourceId ?? this.sourceId,
      routeStatus: routeStatus ?? this.routeStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (startUtc.present) {
      map['start_utc'] = Variable<String>(startUtc.value);
    }
    if (endUtc.present) {
      map['end_utc'] = Variable<String>(endUtc.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<double>(durationSeconds.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (energyKcal.present) {
      map['energy_kcal'] = Variable<double>(energyKcal.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (routeStatus.present) {
      map['route_status'] = Variable<String>(routeStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceM: $distanceM, ')
          ..write('energyKcal: $energyKcal, ')
          ..write('sourceId: $sourceId, ')
          ..write('routeStatus: $routeStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutRoutePointsTable extends WorkoutRoutePoints
    with TableInfo<$WorkoutRoutePointsTable, WorkoutRoutePointRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutRoutePointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workoutIdMeta =
      const VerificationMeta('workoutId');
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
      'workout_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sequenceMeta =
      const VerificationMeta('sequence');
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
      'sequence', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _timestampUtcMeta =
      const VerificationMeta('timestampUtc');
  @override
  late final GeneratedColumn<String> timestampUtc = GeneratedColumn<String>(
      'timestamp_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [workoutId, sequence, latitude, longitude, timestampUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_route_points';
  @override
  VerificationContext validateIntegrity(
      Insertable<WorkoutRoutePointRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workout_id')) {
      context.handle(_workoutIdMeta,
          workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta));
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(_sequenceMeta,
          sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta));
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('timestamp_utc')) {
      context.handle(
          _timestampUtcMeta,
          timestampUtc.isAcceptableOrUnknown(
              data['timestamp_utc']!, _timestampUtcMeta));
    } else if (isInserting) {
      context.missing(_timestampUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workoutId, sequence};
  @override
  WorkoutRoutePointRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutRoutePointRow(
      workoutId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}workout_id'])!,
      sequence: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      timestampUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timestamp_utc'])!,
    );
  }

  @override
  $WorkoutRoutePointsTable createAlias(String alias) {
    return $WorkoutRoutePointsTable(attachedDatabase, alias);
  }
}

class WorkoutRoutePointRow extends DataClass
    implements Insertable<WorkoutRoutePointRow> {
  final String workoutId;
  final int sequence;
  final double latitude;
  final double longitude;
  final String timestampUtc;
  const WorkoutRoutePointRow(
      {required this.workoutId,
      required this.sequence,
      required this.latitude,
      required this.longitude,
      required this.timestampUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workout_id'] = Variable<String>(workoutId);
    map['sequence'] = Variable<int>(sequence);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['timestamp_utc'] = Variable<String>(timestampUtc);
    return map;
  }

  WorkoutRoutePointsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutRoutePointsCompanion(
      workoutId: Value(workoutId),
      sequence: Value(sequence),
      latitude: Value(latitude),
      longitude: Value(longitude),
      timestampUtc: Value(timestampUtc),
    );
  }

  factory WorkoutRoutePointRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutRoutePointRow(
      workoutId: serializer.fromJson<String>(json['workoutId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      timestampUtc: serializer.fromJson<String>(json['timestampUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workoutId': serializer.toJson<String>(workoutId),
      'sequence': serializer.toJson<int>(sequence),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'timestampUtc': serializer.toJson<String>(timestampUtc),
    };
  }

  WorkoutRoutePointRow copyWith(
          {String? workoutId,
          int? sequence,
          double? latitude,
          double? longitude,
          String? timestampUtc}) =>
      WorkoutRoutePointRow(
        workoutId: workoutId ?? this.workoutId,
        sequence: sequence ?? this.sequence,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        timestampUtc: timestampUtc ?? this.timestampUtc,
      );
  WorkoutRoutePointRow copyWithCompanion(WorkoutRoutePointsCompanion data) {
    return WorkoutRoutePointRow(
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      timestampUtc: data.timestampUtc.present
          ? data.timestampUtc.value
          : this.timestampUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutRoutePointRow(')
          ..write('workoutId: $workoutId, ')
          ..write('sequence: $sequence, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestampUtc: $timestampUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(workoutId, sequence, latitude, longitude, timestampUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutRoutePointRow &&
          other.workoutId == this.workoutId &&
          other.sequence == this.sequence &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.timestampUtc == this.timestampUtc);
}

class WorkoutRoutePointsCompanion
    extends UpdateCompanion<WorkoutRoutePointRow> {
  final Value<String> workoutId;
  final Value<int> sequence;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> timestampUtc;
  final Value<int> rowid;
  const WorkoutRoutePointsCompanion({
    this.workoutId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.timestampUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutRoutePointsCompanion.insert({
    required String workoutId,
    required int sequence,
    required double latitude,
    required double longitude,
    required String timestampUtc,
    this.rowid = const Value.absent(),
  })  : workoutId = Value(workoutId),
        sequence = Value(sequence),
        latitude = Value(latitude),
        longitude = Value(longitude),
        timestampUtc = Value(timestampUtc);
  static Insertable<WorkoutRoutePointRow> custom({
    Expression<String>? workoutId,
    Expression<int>? sequence,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? timestampUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workoutId != null) 'workout_id': workoutId,
      if (sequence != null) 'sequence': sequence,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (timestampUtc != null) 'timestamp_utc': timestampUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutRoutePointsCompanion copyWith(
      {Value<String>? workoutId,
      Value<int>? sequence,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<String>? timestampUtc,
      Value<int>? rowid}) {
    return WorkoutRoutePointsCompanion(
      workoutId: workoutId ?? this.workoutId,
      sequence: sequence ?? this.sequence,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestampUtc: timestampUtc ?? this.timestampUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (timestampUtc.present) {
      map['timestamp_utc'] = Variable<String>(timestampUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutRoutePointsCompanion(')
          ..write('workoutId: $workoutId, ')
          ..write('sequence: $sequence, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CycleProfilesTable extends CycleProfiles
    with TableInfo<$CycleProfilesTable, CycleProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CycleProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _typicalCycleLengthMeta =
      const VerificationMeta('typicalCycleLength');
  @override
  late final GeneratedColumn<int> typicalCycleLength = GeneratedColumn<int>(
      'typical_cycle_length', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(28));
  static const VerificationMeta _typicalPeriodLengthMeta =
      const VerificationMeta('typicalPeriodLength');
  @override
  late final GeneratedColumn<int> typicalPeriodLength = GeneratedColumn<int>(
      'typical_period_length', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _predictionsEnabledMeta =
      const VerificationMeta('predictionsEnabled');
  @override
  late final GeneratedColumn<bool> predictionsEnabled = GeneratedColumn<bool>(
      'predictions_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("predictions_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _healthImportEnabledMeta =
      const VerificationMeta('healthImportEnabled');
  @override
  late final GeneratedColumn<bool> healthImportEnabled = GeneratedColumn<bool>(
      'health_import_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("health_import_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _timezoneMeta =
      const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
      'timezone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('UTC'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        typicalCycleLength,
        typicalPeriodLength,
        predictionsEnabled,
        healthImportEnabled,
        timezone
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<CycleProfileRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('typical_cycle_length')) {
      context.handle(
          _typicalCycleLengthMeta,
          typicalCycleLength.isAcceptableOrUnknown(
              data['typical_cycle_length']!, _typicalCycleLengthMeta));
    }
    if (data.containsKey('typical_period_length')) {
      context.handle(
          _typicalPeriodLengthMeta,
          typicalPeriodLength.isAcceptableOrUnknown(
              data['typical_period_length']!, _typicalPeriodLengthMeta));
    }
    if (data.containsKey('predictions_enabled')) {
      context.handle(
          _predictionsEnabledMeta,
          predictionsEnabled.isAcceptableOrUnknown(
              data['predictions_enabled']!, _predictionsEnabledMeta));
    }
    if (data.containsKey('health_import_enabled')) {
      context.handle(
          _healthImportEnabledMeta,
          healthImportEnabled.isAcceptableOrUnknown(
              data['health_import_enabled']!, _healthImportEnabledMeta));
    }
    if (data.containsKey('timezone')) {
      context.handle(_timezoneMeta,
          timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CycleProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CycleProfileRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      typicalCycleLength: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}typical_cycle_length'])!,
      typicalPeriodLength: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}typical_period_length'])!,
      predictionsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}predictions_enabled'])!,
      healthImportEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}health_import_enabled'])!,
      timezone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timezone'])!,
    );
  }

  @override
  $CycleProfilesTable createAlias(String alias) {
    return $CycleProfilesTable(attachedDatabase, alias);
  }
}

class CycleProfileRow extends DataClass implements Insertable<CycleProfileRow> {
  final int id;
  final int typicalCycleLength;
  final int typicalPeriodLength;
  final bool predictionsEnabled;
  final bool healthImportEnabled;
  final String timezone;
  const CycleProfileRow(
      {required this.id,
      required this.typicalCycleLength,
      required this.typicalPeriodLength,
      required this.predictionsEnabled,
      required this.healthImportEnabled,
      required this.timezone});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['typical_cycle_length'] = Variable<int>(typicalCycleLength);
    map['typical_period_length'] = Variable<int>(typicalPeriodLength);
    map['predictions_enabled'] = Variable<bool>(predictionsEnabled);
    map['health_import_enabled'] = Variable<bool>(healthImportEnabled);
    map['timezone'] = Variable<String>(timezone);
    return map;
  }

  CycleProfilesCompanion toCompanion(bool nullToAbsent) {
    return CycleProfilesCompanion(
      id: Value(id),
      typicalCycleLength: Value(typicalCycleLength),
      typicalPeriodLength: Value(typicalPeriodLength),
      predictionsEnabled: Value(predictionsEnabled),
      healthImportEnabled: Value(healthImportEnabled),
      timezone: Value(timezone),
    );
  }

  factory CycleProfileRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CycleProfileRow(
      id: serializer.fromJson<int>(json['id']),
      typicalCycleLength: serializer.fromJson<int>(json['typicalCycleLength']),
      typicalPeriodLength:
          serializer.fromJson<int>(json['typicalPeriodLength']),
      predictionsEnabled: serializer.fromJson<bool>(json['predictionsEnabled']),
      healthImportEnabled:
          serializer.fromJson<bool>(json['healthImportEnabled']),
      timezone: serializer.fromJson<String>(json['timezone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'typicalCycleLength': serializer.toJson<int>(typicalCycleLength),
      'typicalPeriodLength': serializer.toJson<int>(typicalPeriodLength),
      'predictionsEnabled': serializer.toJson<bool>(predictionsEnabled),
      'healthImportEnabled': serializer.toJson<bool>(healthImportEnabled),
      'timezone': serializer.toJson<String>(timezone),
    };
  }

  CycleProfileRow copyWith(
          {int? id,
          int? typicalCycleLength,
          int? typicalPeriodLength,
          bool? predictionsEnabled,
          bool? healthImportEnabled,
          String? timezone}) =>
      CycleProfileRow(
        id: id ?? this.id,
        typicalCycleLength: typicalCycleLength ?? this.typicalCycleLength,
        typicalPeriodLength: typicalPeriodLength ?? this.typicalPeriodLength,
        predictionsEnabled: predictionsEnabled ?? this.predictionsEnabled,
        healthImportEnabled: healthImportEnabled ?? this.healthImportEnabled,
        timezone: timezone ?? this.timezone,
      );
  CycleProfileRow copyWithCompanion(CycleProfilesCompanion data) {
    return CycleProfileRow(
      id: data.id.present ? data.id.value : this.id,
      typicalCycleLength: data.typicalCycleLength.present
          ? data.typicalCycleLength.value
          : this.typicalCycleLength,
      typicalPeriodLength: data.typicalPeriodLength.present
          ? data.typicalPeriodLength.value
          : this.typicalPeriodLength,
      predictionsEnabled: data.predictionsEnabled.present
          ? data.predictionsEnabled.value
          : this.predictionsEnabled,
      healthImportEnabled: data.healthImportEnabled.present
          ? data.healthImportEnabled.value
          : this.healthImportEnabled,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CycleProfileRow(')
          ..write('id: $id, ')
          ..write('typicalCycleLength: $typicalCycleLength, ')
          ..write('typicalPeriodLength: $typicalPeriodLength, ')
          ..write('predictionsEnabled: $predictionsEnabled, ')
          ..write('healthImportEnabled: $healthImportEnabled, ')
          ..write('timezone: $timezone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, typicalCycleLength, typicalPeriodLength,
      predictionsEnabled, healthImportEnabled, timezone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CycleProfileRow &&
          other.id == this.id &&
          other.typicalCycleLength == this.typicalCycleLength &&
          other.typicalPeriodLength == this.typicalPeriodLength &&
          other.predictionsEnabled == this.predictionsEnabled &&
          other.healthImportEnabled == this.healthImportEnabled &&
          other.timezone == this.timezone);
}

class CycleProfilesCompanion extends UpdateCompanion<CycleProfileRow> {
  final Value<int> id;
  final Value<int> typicalCycleLength;
  final Value<int> typicalPeriodLength;
  final Value<bool> predictionsEnabled;
  final Value<bool> healthImportEnabled;
  final Value<String> timezone;
  const CycleProfilesCompanion({
    this.id = const Value.absent(),
    this.typicalCycleLength = const Value.absent(),
    this.typicalPeriodLength = const Value.absent(),
    this.predictionsEnabled = const Value.absent(),
    this.healthImportEnabled = const Value.absent(),
    this.timezone = const Value.absent(),
  });
  CycleProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.typicalCycleLength = const Value.absent(),
    this.typicalPeriodLength = const Value.absent(),
    this.predictionsEnabled = const Value.absent(),
    this.healthImportEnabled = const Value.absent(),
    this.timezone = const Value.absent(),
  });
  static Insertable<CycleProfileRow> custom({
    Expression<int>? id,
    Expression<int>? typicalCycleLength,
    Expression<int>? typicalPeriodLength,
    Expression<bool>? predictionsEnabled,
    Expression<bool>? healthImportEnabled,
    Expression<String>? timezone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (typicalCycleLength != null)
        'typical_cycle_length': typicalCycleLength,
      if (typicalPeriodLength != null)
        'typical_period_length': typicalPeriodLength,
      if (predictionsEnabled != null) 'predictions_enabled': predictionsEnabled,
      if (healthImportEnabled != null)
        'health_import_enabled': healthImportEnabled,
      if (timezone != null) 'timezone': timezone,
    });
  }

  CycleProfilesCompanion copyWith(
      {Value<int>? id,
      Value<int>? typicalCycleLength,
      Value<int>? typicalPeriodLength,
      Value<bool>? predictionsEnabled,
      Value<bool>? healthImportEnabled,
      Value<String>? timezone}) {
    return CycleProfilesCompanion(
      id: id ?? this.id,
      typicalCycleLength: typicalCycleLength ?? this.typicalCycleLength,
      typicalPeriodLength: typicalPeriodLength ?? this.typicalPeriodLength,
      predictionsEnabled: predictionsEnabled ?? this.predictionsEnabled,
      healthImportEnabled: healthImportEnabled ?? this.healthImportEnabled,
      timezone: timezone ?? this.timezone,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (typicalCycleLength.present) {
      map['typical_cycle_length'] = Variable<int>(typicalCycleLength.value);
    }
    if (typicalPeriodLength.present) {
      map['typical_period_length'] = Variable<int>(typicalPeriodLength.value);
    }
    if (predictionsEnabled.present) {
      map['predictions_enabled'] = Variable<bool>(predictionsEnabled.value);
    }
    if (healthImportEnabled.present) {
      map['health_import_enabled'] = Variable<bool>(healthImportEnabled.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CycleProfilesCompanion(')
          ..write('id: $id, ')
          ..write('typicalCycleLength: $typicalCycleLength, ')
          ..write('typicalPeriodLength: $typicalPeriodLength, ')
          ..write('predictionsEnabled: $predictionsEnabled, ')
          ..write('healthImportEnabled: $healthImportEnabled, ')
          ..write('timezone: $timezone')
          ..write(')'))
        .toString();
  }
}

class $PeriodEntriesTable extends PeriodEntries
    with TableInfo<$PeriodEntriesTable, PeriodEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeriodEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDayMeta =
      const VerificationMeta('startDay');
  @override
  late final GeneratedColumn<String> startDay = GeneratedColumn<String>(
      'start_day', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endDayMeta = const VerificationMeta('endDay');
  @override
  late final GeneratedColumn<String> endDay = GeneratedColumn<String>(
      'end_day', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _flowJsonMeta =
      const VerificationMeta('flowJson');
  @override
  late final GeneratedColumn<String> flowJson = GeneratedColumn<String>(
      'flow_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _createdAtUtcMeta =
      const VerificationMeta('createdAtUtc');
  @override
  late final GeneratedColumn<String> createdAtUtc = GeneratedColumn<String>(
      'created_at_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, startDay, endDay, flowJson, source, createdAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'period_entries';
  @override
  VerificationContext validateIntegrity(Insertable<PeriodEntryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_day')) {
      context.handle(_startDayMeta,
          startDay.isAcceptableOrUnknown(data['start_day']!, _startDayMeta));
    } else if (isInserting) {
      context.missing(_startDayMeta);
    }
    if (data.containsKey('end_day')) {
      context.handle(_endDayMeta,
          endDay.isAcceptableOrUnknown(data['end_day']!, _endDayMeta));
    }
    if (data.containsKey('flow_json')) {
      context.handle(_flowJsonMeta,
          flowJson.isAcceptableOrUnknown(data['flow_json']!, _flowJsonMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
          _createdAtUtcMeta,
          createdAtUtc.isAcceptableOrUnknown(
              data['created_at_utc']!, _createdAtUtcMeta));
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeriodEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeriodEntryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      startDay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_day'])!,
      endDay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_day']),
      flowJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}flow_json']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      createdAtUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at_utc'])!,
    );
  }

  @override
  $PeriodEntriesTable createAlias(String alias) {
    return $PeriodEntriesTable(attachedDatabase, alias);
  }
}

class PeriodEntryRow extends DataClass implements Insertable<PeriodEntryRow> {
  final String id;
  final String startDay;
  final String? endDay;
  final String? flowJson;
  final String source;
  final String createdAtUtc;
  const PeriodEntryRow(
      {required this.id,
      required this.startDay,
      this.endDay,
      this.flowJson,
      required this.source,
      required this.createdAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_day'] = Variable<String>(startDay);
    if (!nullToAbsent || endDay != null) {
      map['end_day'] = Variable<String>(endDay);
    }
    if (!nullToAbsent || flowJson != null) {
      map['flow_json'] = Variable<String>(flowJson);
    }
    map['source'] = Variable<String>(source);
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    return map;
  }

  PeriodEntriesCompanion toCompanion(bool nullToAbsent) {
    return PeriodEntriesCompanion(
      id: Value(id),
      startDay: Value(startDay),
      endDay:
          endDay == null && nullToAbsent ? const Value.absent() : Value(endDay),
      flowJson: flowJson == null && nullToAbsent
          ? const Value.absent()
          : Value(flowJson),
      source: Value(source),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory PeriodEntryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeriodEntryRow(
      id: serializer.fromJson<String>(json['id']),
      startDay: serializer.fromJson<String>(json['startDay']),
      endDay: serializer.fromJson<String?>(json['endDay']),
      flowJson: serializer.fromJson<String?>(json['flowJson']),
      source: serializer.fromJson<String>(json['source']),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startDay': serializer.toJson<String>(startDay),
      'endDay': serializer.toJson<String?>(endDay),
      'flowJson': serializer.toJson<String?>(flowJson),
      'source': serializer.toJson<String>(source),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
    };
  }

  PeriodEntryRow copyWith(
          {String? id,
          String? startDay,
          Value<String?> endDay = const Value.absent(),
          Value<String?> flowJson = const Value.absent(),
          String? source,
          String? createdAtUtc}) =>
      PeriodEntryRow(
        id: id ?? this.id,
        startDay: startDay ?? this.startDay,
        endDay: endDay.present ? endDay.value : this.endDay,
        flowJson: flowJson.present ? flowJson.value : this.flowJson,
        source: source ?? this.source,
        createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      );
  PeriodEntryRow copyWithCompanion(PeriodEntriesCompanion data) {
    return PeriodEntryRow(
      id: data.id.present ? data.id.value : this.id,
      startDay: data.startDay.present ? data.startDay.value : this.startDay,
      endDay: data.endDay.present ? data.endDay.value : this.endDay,
      flowJson: data.flowJson.present ? data.flowJson.value : this.flowJson,
      source: data.source.present ? data.source.value : this.source,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeriodEntryRow(')
          ..write('id: $id, ')
          ..write('startDay: $startDay, ')
          ..write('endDay: $endDay, ')
          ..write('flowJson: $flowJson, ')
          ..write('source: $source, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startDay, endDay, flowJson, source, createdAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodEntryRow &&
          other.id == this.id &&
          other.startDay == this.startDay &&
          other.endDay == this.endDay &&
          other.flowJson == this.flowJson &&
          other.source == this.source &&
          other.createdAtUtc == this.createdAtUtc);
}

class PeriodEntriesCompanion extends UpdateCompanion<PeriodEntryRow> {
  final Value<String> id;
  final Value<String> startDay;
  final Value<String?> endDay;
  final Value<String?> flowJson;
  final Value<String> source;
  final Value<String> createdAtUtc;
  final Value<int> rowid;
  const PeriodEntriesCompanion({
    this.id = const Value.absent(),
    this.startDay = const Value.absent(),
    this.endDay = const Value.absent(),
    this.flowJson = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeriodEntriesCompanion.insert({
    required String id,
    required String startDay,
    this.endDay = const Value.absent(),
    this.flowJson = const Value.absent(),
    this.source = const Value.absent(),
    required String createdAtUtc,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        startDay = Value(startDay),
        createdAtUtc = Value(createdAtUtc);
  static Insertable<PeriodEntryRow> custom({
    Expression<String>? id,
    Expression<String>? startDay,
    Expression<String>? endDay,
    Expression<String>? flowJson,
    Expression<String>? source,
    Expression<String>? createdAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startDay != null) 'start_day': startDay,
      if (endDay != null) 'end_day': endDay,
      if (flowJson != null) 'flow_json': flowJson,
      if (source != null) 'source': source,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeriodEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? startDay,
      Value<String?>? endDay,
      Value<String?>? flowJson,
      Value<String>? source,
      Value<String>? createdAtUtc,
      Value<int>? rowid}) {
    return PeriodEntriesCompanion(
      id: id ?? this.id,
      startDay: startDay ?? this.startDay,
      endDay: endDay ?? this.endDay,
      flowJson: flowJson ?? this.flowJson,
      source: source ?? this.source,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startDay.present) {
      map['start_day'] = Variable<String>(startDay.value);
    }
    if (endDay.present) {
      map['end_day'] = Variable<String>(endDay.value);
    }
    if (flowJson.present) {
      map['flow_json'] = Variable<String>(flowJson.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeriodEntriesCompanion(')
          ..write('id: $id, ')
          ..write('startDay: $startDay, ')
          ..write('endDay: $endDay, ')
          ..write('flowJson: $flowJson, ')
          ..write('source: $source, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CycleDailyLogsTable extends CycleDailyLogs
    with TableInfo<$CycleDailyLogsTable, CycleDailyLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CycleDailyLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
      'day', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bleedingMeta =
      const VerificationMeta('bleeding');
  @override
  late final GeneratedColumn<String> bleeding = GeneratedColumn<String>(
      'bleeding', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
      'mood', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _painMeta = const VerificationMeta('pain');
  @override
  late final GeneratedColumn<int> pain = GeneratedColumn<int>(
      'pain', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
      'energy', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sleepQualityMeta =
      const VerificationMeta('sleepQuality');
  @override
  late final GeneratedColumn<int> sleepQuality = GeneratedColumn<int>(
      'sleep_quality', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _updatedAtUtcMeta =
      const VerificationMeta('updatedAtUtc');
  @override
  late final GeneratedColumn<String> updatedAtUtc = GeneratedColumn<String>(
      'updated_at_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        day,
        bleeding,
        mood,
        pain,
        energy,
        sleepQuality,
        notes,
        tagsJson,
        source,
        updatedAtUtc
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_daily_logs';
  @override
  VerificationContext validateIntegrity(Insertable<CycleDailyLogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('bleeding')) {
      context.handle(_bleedingMeta,
          bleeding.isAcceptableOrUnknown(data['bleeding']!, _bleedingMeta));
    }
    if (data.containsKey('mood')) {
      context.handle(
          _moodMeta, mood.isAcceptableOrUnknown(data['mood']!, _moodMeta));
    }
    if (data.containsKey('pain')) {
      context.handle(
          _painMeta, pain.isAcceptableOrUnknown(data['pain']!, _painMeta));
    }
    if (data.containsKey('energy')) {
      context.handle(_energyMeta,
          energy.isAcceptableOrUnknown(data['energy']!, _energyMeta));
    }
    if (data.containsKey('sleep_quality')) {
      context.handle(
          _sleepQualityMeta,
          sleepQuality.isAcceptableOrUnknown(
              data['sleep_quality']!, _sleepQualityMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
          _updatedAtUtcMeta,
          updatedAtUtc.isAcceptableOrUnknown(
              data['updated_at_utc']!, _updatedAtUtcMeta));
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  CycleDailyLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CycleDailyLogRow(
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      bleeding: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bleeding']),
      mood: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mood']),
      pain: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pain']),
      energy: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}energy']),
      sleepQuality: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sleep_quality']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      updatedAtUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at_utc'])!,
    );
  }

  @override
  $CycleDailyLogsTable createAlias(String alias) {
    return $CycleDailyLogsTable(attachedDatabase, alias);
  }
}

class CycleDailyLogRow extends DataClass
    implements Insertable<CycleDailyLogRow> {
  final String day;
  final String? bleeding;
  final String? mood;
  final int? pain;
  final int? energy;
  final int? sleepQuality;
  final String? notes;
  final String tagsJson;
  final String source;
  final String updatedAtUtc;
  const CycleDailyLogRow(
      {required this.day,
      this.bleeding,
      this.mood,
      this.pain,
      this.energy,
      this.sleepQuality,
      this.notes,
      required this.tagsJson,
      required this.source,
      required this.updatedAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    if (!nullToAbsent || bleeding != null) {
      map['bleeding'] = Variable<String>(bleeding);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    if (!nullToAbsent || pain != null) {
      map['pain'] = Variable<int>(pain);
    }
    if (!nullToAbsent || energy != null) {
      map['energy'] = Variable<int>(energy);
    }
    if (!nullToAbsent || sleepQuality != null) {
      map['sleep_quality'] = Variable<int>(sleepQuality);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['tags_json'] = Variable<String>(tagsJson);
    map['source'] = Variable<String>(source);
    map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    return map;
  }

  CycleDailyLogsCompanion toCompanion(bool nullToAbsent) {
    return CycleDailyLogsCompanion(
      day: Value(day),
      bleeding: bleeding == null && nullToAbsent
          ? const Value.absent()
          : Value(bleeding),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      pain: pain == null && nullToAbsent ? const Value.absent() : Value(pain),
      energy:
          energy == null && nullToAbsent ? const Value.absent() : Value(energy),
      sleepQuality: sleepQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepQuality),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      tagsJson: Value(tagsJson),
      source: Value(source),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory CycleDailyLogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CycleDailyLogRow(
      day: serializer.fromJson<String>(json['day']),
      bleeding: serializer.fromJson<String?>(json['bleeding']),
      mood: serializer.fromJson<String?>(json['mood']),
      pain: serializer.fromJson<int?>(json['pain']),
      energy: serializer.fromJson<int?>(json['energy']),
      sleepQuality: serializer.fromJson<int?>(json['sleepQuality']),
      notes: serializer.fromJson<String?>(json['notes']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      source: serializer.fromJson<String>(json['source']),
      updatedAtUtc: serializer.fromJson<String>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'bleeding': serializer.toJson<String?>(bleeding),
      'mood': serializer.toJson<String?>(mood),
      'pain': serializer.toJson<int?>(pain),
      'energy': serializer.toJson<int?>(energy),
      'sleepQuality': serializer.toJson<int?>(sleepQuality),
      'notes': serializer.toJson<String?>(notes),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'source': serializer.toJson<String>(source),
      'updatedAtUtc': serializer.toJson<String>(updatedAtUtc),
    };
  }

  CycleDailyLogRow copyWith(
          {String? day,
          Value<String?> bleeding = const Value.absent(),
          Value<String?> mood = const Value.absent(),
          Value<int?> pain = const Value.absent(),
          Value<int?> energy = const Value.absent(),
          Value<int?> sleepQuality = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? tagsJson,
          String? source,
          String? updatedAtUtc}) =>
      CycleDailyLogRow(
        day: day ?? this.day,
        bleeding: bleeding.present ? bleeding.value : this.bleeding,
        mood: mood.present ? mood.value : this.mood,
        pain: pain.present ? pain.value : this.pain,
        energy: energy.present ? energy.value : this.energy,
        sleepQuality:
            sleepQuality.present ? sleepQuality.value : this.sleepQuality,
        notes: notes.present ? notes.value : this.notes,
        tagsJson: tagsJson ?? this.tagsJson,
        source: source ?? this.source,
        updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      );
  CycleDailyLogRow copyWithCompanion(CycleDailyLogsCompanion data) {
    return CycleDailyLogRow(
      day: data.day.present ? data.day.value : this.day,
      bleeding: data.bleeding.present ? data.bleeding.value : this.bleeding,
      mood: data.mood.present ? data.mood.value : this.mood,
      pain: data.pain.present ? data.pain.value : this.pain,
      energy: data.energy.present ? data.energy.value : this.energy,
      sleepQuality: data.sleepQuality.present
          ? data.sleepQuality.value
          : this.sleepQuality,
      notes: data.notes.present ? data.notes.value : this.notes,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      source: data.source.present ? data.source.value : this.source,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CycleDailyLogRow(')
          ..write('day: $day, ')
          ..write('bleeding: $bleeding, ')
          ..write('mood: $mood, ')
          ..write('pain: $pain, ')
          ..write('energy: $energy, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('notes: $notes, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('source: $source, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, bleeding, mood, pain, energy,
      sleepQuality, notes, tagsJson, source, updatedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CycleDailyLogRow &&
          other.day == this.day &&
          other.bleeding == this.bleeding &&
          other.mood == this.mood &&
          other.pain == this.pain &&
          other.energy == this.energy &&
          other.sleepQuality == this.sleepQuality &&
          other.notes == this.notes &&
          other.tagsJson == this.tagsJson &&
          other.source == this.source &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class CycleDailyLogsCompanion extends UpdateCompanion<CycleDailyLogRow> {
  final Value<String> day;
  final Value<String?> bleeding;
  final Value<String?> mood;
  final Value<int?> pain;
  final Value<int?> energy;
  final Value<int?> sleepQuality;
  final Value<String?> notes;
  final Value<String> tagsJson;
  final Value<String> source;
  final Value<String> updatedAtUtc;
  final Value<int> rowid;
  const CycleDailyLogsCompanion({
    this.day = const Value.absent(),
    this.bleeding = const Value.absent(),
    this.mood = const Value.absent(),
    this.pain = const Value.absent(),
    this.energy = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.notes = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.source = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CycleDailyLogsCompanion.insert({
    required String day,
    this.bleeding = const Value.absent(),
    this.mood = const Value.absent(),
    this.pain = const Value.absent(),
    this.energy = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.notes = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.source = const Value.absent(),
    required String updatedAtUtc,
    this.rowid = const Value.absent(),
  })  : day = Value(day),
        updatedAtUtc = Value(updatedAtUtc);
  static Insertable<CycleDailyLogRow> custom({
    Expression<String>? day,
    Expression<String>? bleeding,
    Expression<String>? mood,
    Expression<int>? pain,
    Expression<int>? energy,
    Expression<int>? sleepQuality,
    Expression<String>? notes,
    Expression<String>? tagsJson,
    Expression<String>? source,
    Expression<String>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (bleeding != null) 'bleeding': bleeding,
      if (mood != null) 'mood': mood,
      if (pain != null) 'pain': pain,
      if (energy != null) 'energy': energy,
      if (sleepQuality != null) 'sleep_quality': sleepQuality,
      if (notes != null) 'notes': notes,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (source != null) 'source': source,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CycleDailyLogsCompanion copyWith(
      {Value<String>? day,
      Value<String?>? bleeding,
      Value<String?>? mood,
      Value<int?>? pain,
      Value<int?>? energy,
      Value<int?>? sleepQuality,
      Value<String?>? notes,
      Value<String>? tagsJson,
      Value<String>? source,
      Value<String>? updatedAtUtc,
      Value<int>? rowid}) {
    return CycleDailyLogsCompanion(
      day: day ?? this.day,
      bleeding: bleeding ?? this.bleeding,
      mood: mood ?? this.mood,
      pain: pain ?? this.pain,
      energy: energy ?? this.energy,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      notes: notes ?? this.notes,
      tagsJson: tagsJson ?? this.tagsJson,
      source: source ?? this.source,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (bleeding.present) {
      map['bleeding'] = Variable<String>(bleeding.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (pain.present) {
      map['pain'] = Variable<int>(pain.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (sleepQuality.present) {
      map['sleep_quality'] = Variable<int>(sleepQuality.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CycleDailyLogsCompanion(')
          ..write('day: $day, ')
          ..write('bleeding: $bleeding, ')
          ..write('mood: $mood, ')
          ..write('pain: $pain, ')
          ..write('energy: $energy, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('notes: $notes, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('source: $source, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SymptomDefinitionsTable extends SymptomDefinitions
    with TableInfo<$SymptomDefinitionsTable, SymptomDefinitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SymptomDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [id, name, enabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'symptom_definitions';
  @override
  VerificationContext validateIntegrity(
      Insertable<SymptomDefinitionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SymptomDefinitionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SymptomDefinitionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
    );
  }

  @override
  $SymptomDefinitionsTable createAlias(String alias) {
    return $SymptomDefinitionsTable(attachedDatabase, alias);
  }
}

class SymptomDefinitionRow extends DataClass
    implements Insertable<SymptomDefinitionRow> {
  final String id;
  final String name;
  final bool enabled;
  const SymptomDefinitionRow(
      {required this.id, required this.name, required this.enabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  SymptomDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return SymptomDefinitionsCompanion(
      id: Value(id),
      name: Value(name),
      enabled: Value(enabled),
    );
  }

  factory SymptomDefinitionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SymptomDefinitionRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  SymptomDefinitionRow copyWith({String? id, String? name, bool? enabled}) =>
      SymptomDefinitionRow(
        id: id ?? this.id,
        name: name ?? this.name,
        enabled: enabled ?? this.enabled,
      );
  SymptomDefinitionRow copyWithCompanion(SymptomDefinitionsCompanion data) {
    return SymptomDefinitionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SymptomDefinitionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SymptomDefinitionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.enabled == this.enabled);
}

class SymptomDefinitionsCompanion
    extends UpdateCompanion<SymptomDefinitionRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> enabled;
  final Value<int> rowid;
  const SymptomDefinitionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SymptomDefinitionsCompanion.insert({
    required String id,
    required String name,
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<SymptomDefinitionRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SymptomDefinitionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<bool>? enabled,
      Value<int>? rowid}) {
    return SymptomDefinitionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SymptomDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SymptomLogsTable extends SymptomLogs
    with TableInfo<$SymptomLogsTable, SymptomLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SymptomLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
      'day', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symptomIdMeta =
      const VerificationMeta('symptomId');
  @override
  late final GeneratedColumn<String> symptomId = GeneratedColumn<String>(
      'symptom_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _intensityMeta =
      const VerificationMeta('intensity');
  @override
  late final GeneratedColumn<int> intensity = GeneratedColumn<int>(
      'intensity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [id, day, symptomId, intensity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'symptom_logs';
  @override
  VerificationContext validateIntegrity(Insertable<SymptomLogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('symptom_id')) {
      context.handle(_symptomIdMeta,
          symptomId.isAcceptableOrUnknown(data['symptom_id']!, _symptomIdMeta));
    } else if (isInserting) {
      context.missing(_symptomIdMeta);
    }
    if (data.containsKey('intensity')) {
      context.handle(_intensityMeta,
          intensity.isAcceptableOrUnknown(data['intensity']!, _intensityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SymptomLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SymptomLogRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      symptomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symptom_id'])!,
      intensity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}intensity'])!,
    );
  }

  @override
  $SymptomLogsTable createAlias(String alias) {
    return $SymptomLogsTable(attachedDatabase, alias);
  }
}

class SymptomLogRow extends DataClass implements Insertable<SymptomLogRow> {
  final String id;
  final String day;
  final String symptomId;
  final int intensity;
  const SymptomLogRow(
      {required this.id,
      required this.day,
      required this.symptomId,
      required this.intensity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['symptom_id'] = Variable<String>(symptomId);
    map['intensity'] = Variable<int>(intensity);
    return map;
  }

  SymptomLogsCompanion toCompanion(bool nullToAbsent) {
    return SymptomLogsCompanion(
      id: Value(id),
      day: Value(day),
      symptomId: Value(symptomId),
      intensity: Value(intensity),
    );
  }

  factory SymptomLogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SymptomLogRow(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      symptomId: serializer.fromJson<String>(json['symptomId']),
      intensity: serializer.fromJson<int>(json['intensity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'symptomId': serializer.toJson<String>(symptomId),
      'intensity': serializer.toJson<int>(intensity),
    };
  }

  SymptomLogRow copyWith(
          {String? id, String? day, String? symptomId, int? intensity}) =>
      SymptomLogRow(
        id: id ?? this.id,
        day: day ?? this.day,
        symptomId: symptomId ?? this.symptomId,
        intensity: intensity ?? this.intensity,
      );
  SymptomLogRow copyWithCompanion(SymptomLogsCompanion data) {
    return SymptomLogRow(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      symptomId: data.symptomId.present ? data.symptomId.value : this.symptomId,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SymptomLogRow(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('symptomId: $symptomId, ')
          ..write('intensity: $intensity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, symptomId, intensity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SymptomLogRow &&
          other.id == this.id &&
          other.day == this.day &&
          other.symptomId == this.symptomId &&
          other.intensity == this.intensity);
}

class SymptomLogsCompanion extends UpdateCompanion<SymptomLogRow> {
  final Value<String> id;
  final Value<String> day;
  final Value<String> symptomId;
  final Value<int> intensity;
  final Value<int> rowid;
  const SymptomLogsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.symptomId = const Value.absent(),
    this.intensity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SymptomLogsCompanion.insert({
    required String id,
    required String day,
    required String symptomId,
    this.intensity = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        day = Value(day),
        symptomId = Value(symptomId);
  static Insertable<SymptomLogRow> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<String>? symptomId,
    Expression<int>? intensity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (symptomId != null) 'symptom_id': symptomId,
      if (intensity != null) 'intensity': intensity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SymptomLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? day,
      Value<String>? symptomId,
      Value<int>? intensity,
      Value<int>? rowid}) {
    return SymptomLogsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      symptomId: symptomId ?? this.symptomId,
      intensity: intensity ?? this.intensity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (symptomId.present) {
      map['symptom_id'] = Variable<String>(symptomId.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<int>(intensity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SymptomLogsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('symptomId: $symptomId, ')
          ..write('intensity: $intensity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CyclePredictionsTable extends CyclePredictions
    with TableInfo<$CyclePredictionsTable, CyclePredictionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CyclePredictionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _windowStartMeta =
      const VerificationMeta('windowStart');
  @override
  late final GeneratedColumn<String> windowStart = GeneratedColumn<String>(
      'window_start', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _windowEndMeta =
      const VerificationMeta('windowEnd');
  @override
  late final GeneratedColumn<String> windowEnd = GeneratedColumn<String>(
      'window_end', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _rationaleMeta =
      const VerificationMeta('rationale');
  @override
  late final GeneratedColumn<String> rationale = GeneratedColumn<String>(
      'rationale', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _calculatedAtUtcMeta =
      const VerificationMeta('calculatedAtUtc');
  @override
  late final GeneratedColumn<String> calculatedAtUtc = GeneratedColumn<String>(
      'calculated_at_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        kind,
        windowStart,
        windowEnd,
        confidence,
        rationale,
        calculatedAtUtc
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_predictions';
  @override
  VerificationContext validateIntegrity(Insertable<CyclePredictionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('window_start')) {
      context.handle(
          _windowStartMeta,
          windowStart.isAcceptableOrUnknown(
              data['window_start']!, _windowStartMeta));
    } else if (isInserting) {
      context.missing(_windowStartMeta);
    }
    if (data.containsKey('window_end')) {
      context.handle(_windowEndMeta,
          windowEnd.isAcceptableOrUnknown(data['window_end']!, _windowEndMeta));
    } else if (isInserting) {
      context.missing(_windowEndMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('rationale')) {
      context.handle(_rationaleMeta,
          rationale.isAcceptableOrUnknown(data['rationale']!, _rationaleMeta));
    } else if (isInserting) {
      context.missing(_rationaleMeta);
    }
    if (data.containsKey('calculated_at_utc')) {
      context.handle(
          _calculatedAtUtcMeta,
          calculatedAtUtc.isAcceptableOrUnknown(
              data['calculated_at_utc']!, _calculatedAtUtcMeta));
    } else if (isInserting) {
      context.missing(_calculatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CyclePredictionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CyclePredictionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      windowStart: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}window_start'])!,
      windowEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}window_end'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      rationale: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rationale'])!,
      calculatedAtUtc: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}calculated_at_utc'])!,
    );
  }

  @override
  $CyclePredictionsTable createAlias(String alias) {
    return $CyclePredictionsTable(attachedDatabase, alias);
  }
}

class CyclePredictionRow extends DataClass
    implements Insertable<CyclePredictionRow> {
  final String id;
  final String kind;
  final String windowStart;
  final String windowEnd;
  final double confidence;
  final String rationale;
  final String calculatedAtUtc;
  const CyclePredictionRow(
      {required this.id,
      required this.kind,
      required this.windowStart,
      required this.windowEnd,
      required this.confidence,
      required this.rationale,
      required this.calculatedAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['window_start'] = Variable<String>(windowStart);
    map['window_end'] = Variable<String>(windowEnd);
    map['confidence'] = Variable<double>(confidence);
    map['rationale'] = Variable<String>(rationale);
    map['calculated_at_utc'] = Variable<String>(calculatedAtUtc);
    return map;
  }

  CyclePredictionsCompanion toCompanion(bool nullToAbsent) {
    return CyclePredictionsCompanion(
      id: Value(id),
      kind: Value(kind),
      windowStart: Value(windowStart),
      windowEnd: Value(windowEnd),
      confidence: Value(confidence),
      rationale: Value(rationale),
      calculatedAtUtc: Value(calculatedAtUtc),
    );
  }

  factory CyclePredictionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CyclePredictionRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      windowStart: serializer.fromJson<String>(json['windowStart']),
      windowEnd: serializer.fromJson<String>(json['windowEnd']),
      confidence: serializer.fromJson<double>(json['confidence']),
      rationale: serializer.fromJson<String>(json['rationale']),
      calculatedAtUtc: serializer.fromJson<String>(json['calculatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'windowStart': serializer.toJson<String>(windowStart),
      'windowEnd': serializer.toJson<String>(windowEnd),
      'confidence': serializer.toJson<double>(confidence),
      'rationale': serializer.toJson<String>(rationale),
      'calculatedAtUtc': serializer.toJson<String>(calculatedAtUtc),
    };
  }

  CyclePredictionRow copyWith(
          {String? id,
          String? kind,
          String? windowStart,
          String? windowEnd,
          double? confidence,
          String? rationale,
          String? calculatedAtUtc}) =>
      CyclePredictionRow(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        windowStart: windowStart ?? this.windowStart,
        windowEnd: windowEnd ?? this.windowEnd,
        confidence: confidence ?? this.confidence,
        rationale: rationale ?? this.rationale,
        calculatedAtUtc: calculatedAtUtc ?? this.calculatedAtUtc,
      );
  CyclePredictionRow copyWithCompanion(CyclePredictionsCompanion data) {
    return CyclePredictionRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      windowStart:
          data.windowStart.present ? data.windowStart.value : this.windowStart,
      windowEnd: data.windowEnd.present ? data.windowEnd.value : this.windowEnd,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      rationale: data.rationale.present ? data.rationale.value : this.rationale,
      calculatedAtUtc: data.calculatedAtUtc.present
          ? data.calculatedAtUtc.value
          : this.calculatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CyclePredictionRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('windowStart: $windowStart, ')
          ..write('windowEnd: $windowEnd, ')
          ..write('confidence: $confidence, ')
          ..write('rationale: $rationale, ')
          ..write('calculatedAtUtc: $calculatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, kind, windowStart, windowEnd, confidence, rationale, calculatedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CyclePredictionRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.windowStart == this.windowStart &&
          other.windowEnd == this.windowEnd &&
          other.confidence == this.confidence &&
          other.rationale == this.rationale &&
          other.calculatedAtUtc == this.calculatedAtUtc);
}

class CyclePredictionsCompanion extends UpdateCompanion<CyclePredictionRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> windowStart;
  final Value<String> windowEnd;
  final Value<double> confidence;
  final Value<String> rationale;
  final Value<String> calculatedAtUtc;
  final Value<int> rowid;
  const CyclePredictionsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.windowStart = const Value.absent(),
    this.windowEnd = const Value.absent(),
    this.confidence = const Value.absent(),
    this.rationale = const Value.absent(),
    this.calculatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CyclePredictionsCompanion.insert({
    required String id,
    required String kind,
    required String windowStart,
    required String windowEnd,
    required double confidence,
    required String rationale,
    required String calculatedAtUtc,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        kind = Value(kind),
        windowStart = Value(windowStart),
        windowEnd = Value(windowEnd),
        confidence = Value(confidence),
        rationale = Value(rationale),
        calculatedAtUtc = Value(calculatedAtUtc);
  static Insertable<CyclePredictionRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? windowStart,
    Expression<String>? windowEnd,
    Expression<double>? confidence,
    Expression<String>? rationale,
    Expression<String>? calculatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (windowStart != null) 'window_start': windowStart,
      if (windowEnd != null) 'window_end': windowEnd,
      if (confidence != null) 'confidence': confidence,
      if (rationale != null) 'rationale': rationale,
      if (calculatedAtUtc != null) 'calculated_at_utc': calculatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CyclePredictionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? kind,
      Value<String>? windowStart,
      Value<String>? windowEnd,
      Value<double>? confidence,
      Value<String>? rationale,
      Value<String>? calculatedAtUtc,
      Value<int>? rowid}) {
    return CyclePredictionsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      windowStart: windowStart ?? this.windowStart,
      windowEnd: windowEnd ?? this.windowEnd,
      confidence: confidence ?? this.confidence,
      rationale: rationale ?? this.rationale,
      calculatedAtUtc: calculatedAtUtc ?? this.calculatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (windowStart.present) {
      map['window_start'] = Variable<String>(windowStart.value);
    }
    if (windowEnd.present) {
      map['window_end'] = Variable<String>(windowEnd.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (rationale.present) {
      map['rationale'] = Variable<String>(rationale.value);
    }
    if (calculatedAtUtc.present) {
      map['calculated_at_utc'] = Variable<String>(calculatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CyclePredictionsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('windowStart: $windowStart, ')
          ..write('windowEnd: $windowEnd, ')
          ..write('confidence: $confidence, ')
          ..write('rationale: $rationale, ')
          ..write('calculatedAtUtc: $calculatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationPreferencesTable extends NotificationPreferences
    with TableInfo<$NotificationPreferencesTable, NotificationPreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _leadMinutesMeta =
      const VerificationMeta('leadMinutes');
  @override
  late final GeneratedColumn<int> leadMinutes = GeneratedColumn<int>(
      'lead_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _quietStartMeta =
      const VerificationMeta('quietStart');
  @override
  late final GeneratedColumn<String> quietStart = GeneratedColumn<String>(
      'quiet_start', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quietEndMeta =
      const VerificationMeta('quietEnd');
  @override
  late final GeneratedColumn<String> quietEnd = GeneratedColumn<String>(
      'quiet_end', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _weekdaysJsonMeta =
      const VerificationMeta('weekdaysJson');
  @override
  late final GeneratedColumn<String> weekdaysJson = GeneratedColumn<String>(
      'weekdays_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[1,2,3,4,5,6,7]'));
  static const VerificationMeta _discreteLockScreenMeta =
      const VerificationMeta('discreteLockScreen');
  @override
  late final GeneratedColumn<bool> discreteLockScreen = GeneratedColumn<bool>(
      'discrete_lock_screen', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("discrete_lock_screen" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        enabled,
        leadMinutes,
        quietStart,
        quietEnd,
        weekdaysJson,
        discreteLockScreen
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_preferences';
  @override
  VerificationContext validateIntegrity(
      Insertable<NotificationPreferenceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    if (data.containsKey('lead_minutes')) {
      context.handle(
          _leadMinutesMeta,
          leadMinutes.isAcceptableOrUnknown(
              data['lead_minutes']!, _leadMinutesMeta));
    }
    if (data.containsKey('quiet_start')) {
      context.handle(
          _quietStartMeta,
          quietStart.isAcceptableOrUnknown(
              data['quiet_start']!, _quietStartMeta));
    }
    if (data.containsKey('quiet_end')) {
      context.handle(_quietEndMeta,
          quietEnd.isAcceptableOrUnknown(data['quiet_end']!, _quietEndMeta));
    }
    if (data.containsKey('weekdays_json')) {
      context.handle(
          _weekdaysJsonMeta,
          weekdaysJson.isAcceptableOrUnknown(
              data['weekdays_json']!, _weekdaysJsonMeta));
    }
    if (data.containsKey('discrete_lock_screen')) {
      context.handle(
          _discreteLockScreenMeta,
          discreteLockScreen.isAcceptableOrUnknown(
              data['discrete_lock_screen']!, _discreteLockScreenMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationPreferenceRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationPreferenceRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      leadMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lead_minutes'])!,
      quietStart: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quiet_start']),
      quietEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quiet_end']),
      weekdaysJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weekdays_json'])!,
      discreteLockScreen: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}discrete_lock_screen'])!,
    );
  }

  @override
  $NotificationPreferencesTable createAlias(String alias) {
    return $NotificationPreferencesTable(attachedDatabase, alias);
  }
}

class NotificationPreferenceRow extends DataClass
    implements Insertable<NotificationPreferenceRow> {
  final String id;
  final bool enabled;
  final int leadMinutes;
  final String? quietStart;
  final String? quietEnd;
  final String weekdaysJson;
  final bool discreteLockScreen;
  const NotificationPreferenceRow(
      {required this.id,
      required this.enabled,
      required this.leadMinutes,
      this.quietStart,
      this.quietEnd,
      required this.weekdaysJson,
      required this.discreteLockScreen});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['enabled'] = Variable<bool>(enabled);
    map['lead_minutes'] = Variable<int>(leadMinutes);
    if (!nullToAbsent || quietStart != null) {
      map['quiet_start'] = Variable<String>(quietStart);
    }
    if (!nullToAbsent || quietEnd != null) {
      map['quiet_end'] = Variable<String>(quietEnd);
    }
    map['weekdays_json'] = Variable<String>(weekdaysJson);
    map['discrete_lock_screen'] = Variable<bool>(discreteLockScreen);
    return map;
  }

  NotificationPreferencesCompanion toCompanion(bool nullToAbsent) {
    return NotificationPreferencesCompanion(
      id: Value(id),
      enabled: Value(enabled),
      leadMinutes: Value(leadMinutes),
      quietStart: quietStart == null && nullToAbsent
          ? const Value.absent()
          : Value(quietStart),
      quietEnd: quietEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(quietEnd),
      weekdaysJson: Value(weekdaysJson),
      discreteLockScreen: Value(discreteLockScreen),
    );
  }

  factory NotificationPreferenceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationPreferenceRow(
      id: serializer.fromJson<String>(json['id']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      leadMinutes: serializer.fromJson<int>(json['leadMinutes']),
      quietStart: serializer.fromJson<String?>(json['quietStart']),
      quietEnd: serializer.fromJson<String?>(json['quietEnd']),
      weekdaysJson: serializer.fromJson<String>(json['weekdaysJson']),
      discreteLockScreen: serializer.fromJson<bool>(json['discreteLockScreen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'enabled': serializer.toJson<bool>(enabled),
      'leadMinutes': serializer.toJson<int>(leadMinutes),
      'quietStart': serializer.toJson<String?>(quietStart),
      'quietEnd': serializer.toJson<String?>(quietEnd),
      'weekdaysJson': serializer.toJson<String>(weekdaysJson),
      'discreteLockScreen': serializer.toJson<bool>(discreteLockScreen),
    };
  }

  NotificationPreferenceRow copyWith(
          {String? id,
          bool? enabled,
          int? leadMinutes,
          Value<String?> quietStart = const Value.absent(),
          Value<String?> quietEnd = const Value.absent(),
          String? weekdaysJson,
          bool? discreteLockScreen}) =>
      NotificationPreferenceRow(
        id: id ?? this.id,
        enabled: enabled ?? this.enabled,
        leadMinutes: leadMinutes ?? this.leadMinutes,
        quietStart: quietStart.present ? quietStart.value : this.quietStart,
        quietEnd: quietEnd.present ? quietEnd.value : this.quietEnd,
        weekdaysJson: weekdaysJson ?? this.weekdaysJson,
        discreteLockScreen: discreteLockScreen ?? this.discreteLockScreen,
      );
  NotificationPreferenceRow copyWithCompanion(
      NotificationPreferencesCompanion data) {
    return NotificationPreferenceRow(
      id: data.id.present ? data.id.value : this.id,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      leadMinutes:
          data.leadMinutes.present ? data.leadMinutes.value : this.leadMinutes,
      quietStart:
          data.quietStart.present ? data.quietStart.value : this.quietStart,
      quietEnd: data.quietEnd.present ? data.quietEnd.value : this.quietEnd,
      weekdaysJson: data.weekdaysJson.present
          ? data.weekdaysJson.value
          : this.weekdaysJson,
      discreteLockScreen: data.discreteLockScreen.present
          ? data.discreteLockScreen.value
          : this.discreteLockScreen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationPreferenceRow(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('leadMinutes: $leadMinutes, ')
          ..write('quietStart: $quietStart, ')
          ..write('quietEnd: $quietEnd, ')
          ..write('weekdaysJson: $weekdaysJson, ')
          ..write('discreteLockScreen: $discreteLockScreen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, enabled, leadMinutes, quietStart,
      quietEnd, weekdaysJson, discreteLockScreen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationPreferenceRow &&
          other.id == this.id &&
          other.enabled == this.enabled &&
          other.leadMinutes == this.leadMinutes &&
          other.quietStart == this.quietStart &&
          other.quietEnd == this.quietEnd &&
          other.weekdaysJson == this.weekdaysJson &&
          other.discreteLockScreen == this.discreteLockScreen);
}

class NotificationPreferencesCompanion
    extends UpdateCompanion<NotificationPreferenceRow> {
  final Value<String> id;
  final Value<bool> enabled;
  final Value<int> leadMinutes;
  final Value<String?> quietStart;
  final Value<String?> quietEnd;
  final Value<String> weekdaysJson;
  final Value<bool> discreteLockScreen;
  final Value<int> rowid;
  const NotificationPreferencesCompanion({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
    this.leadMinutes = const Value.absent(),
    this.quietStart = const Value.absent(),
    this.quietEnd = const Value.absent(),
    this.weekdaysJson = const Value.absent(),
    this.discreteLockScreen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationPreferencesCompanion.insert({
    required String id,
    this.enabled = const Value.absent(),
    this.leadMinutes = const Value.absent(),
    this.quietStart = const Value.absent(),
    this.quietEnd = const Value.absent(),
    this.weekdaysJson = const Value.absent(),
    this.discreteLockScreen = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<NotificationPreferenceRow> custom({
    Expression<String>? id,
    Expression<bool>? enabled,
    Expression<int>? leadMinutes,
    Expression<String>? quietStart,
    Expression<String>? quietEnd,
    Expression<String>? weekdaysJson,
    Expression<bool>? discreteLockScreen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (enabled != null) 'enabled': enabled,
      if (leadMinutes != null) 'lead_minutes': leadMinutes,
      if (quietStart != null) 'quiet_start': quietStart,
      if (quietEnd != null) 'quiet_end': quietEnd,
      if (weekdaysJson != null) 'weekdays_json': weekdaysJson,
      if (discreteLockScreen != null)
        'discrete_lock_screen': discreteLockScreen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationPreferencesCompanion copyWith(
      {Value<String>? id,
      Value<bool>? enabled,
      Value<int>? leadMinutes,
      Value<String?>? quietStart,
      Value<String?>? quietEnd,
      Value<String>? weekdaysJson,
      Value<bool>? discreteLockScreen,
      Value<int>? rowid}) {
    return NotificationPreferencesCompanion(
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
      leadMinutes: leadMinutes ?? this.leadMinutes,
      quietStart: quietStart ?? this.quietStart,
      quietEnd: quietEnd ?? this.quietEnd,
      weekdaysJson: weekdaysJson ?? this.weekdaysJson,
      discreteLockScreen: discreteLockScreen ?? this.discreteLockScreen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (leadMinutes.present) {
      map['lead_minutes'] = Variable<int>(leadMinutes.value);
    }
    if (quietStart.present) {
      map['quiet_start'] = Variable<String>(quietStart.value);
    }
    if (quietEnd.present) {
      map['quiet_end'] = Variable<String>(quietEnd.value);
    }
    if (weekdaysJson.present) {
      map['weekdays_json'] = Variable<String>(weekdaysJson.value);
    }
    if (discreteLockScreen.present) {
      map['discrete_lock_screen'] = Variable<bool>(discreteLockScreen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('leadMinutes: $leadMinutes, ')
          ..write('quietStart: $quietStart, ')
          ..write('quietEnd: $quietEnd, ')
          ..write('weekdaysJson: $weekdaysJson, ')
          ..write('discreteLockScreen: $discreteLockScreen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupManifestsTable extends BackupManifests
    with TableInfo<$BackupManifestsTable, BackupManifestRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupManifestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _schemaVersionMeta =
      const VerificationMeta('schemaVersion');
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
      'schema_version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _appVersionMeta =
      const VerificationMeta('appVersion');
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
      'app_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtUtcMeta =
      const VerificationMeta('createdAtUtc');
  @override
  late final GeneratedColumn<String> createdAtUtc = GeneratedColumn<String>(
      'created_at_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoriesJsonMeta =
      const VerificationMeta('categoriesJson');
  @override
  late final GeneratedColumn<String> categoriesJson = GeneratedColumn<String>(
      'categories_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordCountMeta =
      const VerificationMeta('recordCount');
  @override
  late final GeneratedColumn<int> recordCount = GeneratedColumn<int>(
      'record_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        schemaVersion,
        appVersion,
        createdAtUtc,
        categoriesJson,
        recordCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_manifests';
  @override
  VerificationContext validateIntegrity(Insertable<BackupManifestRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
          _schemaVersionMeta,
          schemaVersion.isAcceptableOrUnknown(
              data['schema_version']!, _schemaVersionMeta));
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('app_version')) {
      context.handle(
          _appVersionMeta,
          appVersion.isAcceptableOrUnknown(
              data['app_version']!, _appVersionMeta));
    } else if (isInserting) {
      context.missing(_appVersionMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
          _createdAtUtcMeta,
          createdAtUtc.isAcceptableOrUnknown(
              data['created_at_utc']!, _createdAtUtcMeta));
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('categories_json')) {
      context.handle(
          _categoriesJsonMeta,
          categoriesJson.isAcceptableOrUnknown(
              data['categories_json']!, _categoriesJsonMeta));
    } else if (isInserting) {
      context.missing(_categoriesJsonMeta);
    }
    if (data.containsKey('record_count')) {
      context.handle(
          _recordCountMeta,
          recordCount.isAcceptableOrUnknown(
              data['record_count']!, _recordCountMeta));
    } else if (isInserting) {
      context.missing(_recordCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupManifestRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupManifestRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      schemaVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schema_version'])!,
      appVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_version'])!,
      createdAtUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at_utc'])!,
      categoriesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}categories_json'])!,
      recordCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}record_count'])!,
    );
  }

  @override
  $BackupManifestsTable createAlias(String alias) {
    return $BackupManifestsTable(attachedDatabase, alias);
  }
}

class BackupManifestRow extends DataClass
    implements Insertable<BackupManifestRow> {
  final String id;
  final int schemaVersion;
  final String appVersion;
  final String createdAtUtc;
  final String categoriesJson;
  final int recordCount;
  const BackupManifestRow(
      {required this.id,
      required this.schemaVersion,
      required this.appVersion,
      required this.createdAtUtc,
      required this.categoriesJson,
      required this.recordCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['app_version'] = Variable<String>(appVersion);
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    map['categories_json'] = Variable<String>(categoriesJson);
    map['record_count'] = Variable<int>(recordCount);
    return map;
  }

  BackupManifestsCompanion toCompanion(bool nullToAbsent) {
    return BackupManifestsCompanion(
      id: Value(id),
      schemaVersion: Value(schemaVersion),
      appVersion: Value(appVersion),
      createdAtUtc: Value(createdAtUtc),
      categoriesJson: Value(categoriesJson),
      recordCount: Value(recordCount),
    );
  }

  factory BackupManifestRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupManifestRow(
      id: serializer.fromJson<String>(json['id']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
      categoriesJson: serializer.fromJson<String>(json['categoriesJson']),
      recordCount: serializer.fromJson<int>(json['recordCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'appVersion': serializer.toJson<String>(appVersion),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
      'categoriesJson': serializer.toJson<String>(categoriesJson),
      'recordCount': serializer.toJson<int>(recordCount),
    };
  }

  BackupManifestRow copyWith(
          {String? id,
          int? schemaVersion,
          String? appVersion,
          String? createdAtUtc,
          String? categoriesJson,
          int? recordCount}) =>
      BackupManifestRow(
        id: id ?? this.id,
        schemaVersion: schemaVersion ?? this.schemaVersion,
        appVersion: appVersion ?? this.appVersion,
        createdAtUtc: createdAtUtc ?? this.createdAtUtc,
        categoriesJson: categoriesJson ?? this.categoriesJson,
        recordCount: recordCount ?? this.recordCount,
      );
  BackupManifestRow copyWithCompanion(BackupManifestsCompanion data) {
    return BackupManifestRow(
      id: data.id.present ? data.id.value : this.id,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      appVersion:
          data.appVersion.present ? data.appVersion.value : this.appVersion,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      categoriesJson: data.categoriesJson.present
          ? data.categoriesJson.value
          : this.categoriesJson,
      recordCount:
          data.recordCount.present ? data.recordCount.value : this.recordCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupManifestRow(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('appVersion: $appVersion, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('categoriesJson: $categoriesJson, ')
          ..write('recordCount: $recordCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, schemaVersion, appVersion, createdAtUtc, categoriesJson, recordCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupManifestRow &&
          other.id == this.id &&
          other.schemaVersion == this.schemaVersion &&
          other.appVersion == this.appVersion &&
          other.createdAtUtc == this.createdAtUtc &&
          other.categoriesJson == this.categoriesJson &&
          other.recordCount == this.recordCount);
}

class BackupManifestsCompanion extends UpdateCompanion<BackupManifestRow> {
  final Value<String> id;
  final Value<int> schemaVersion;
  final Value<String> appVersion;
  final Value<String> createdAtUtc;
  final Value<String> categoriesJson;
  final Value<int> recordCount;
  final Value<int> rowid;
  const BackupManifestsCompanion({
    this.id = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.categoriesJson = const Value.absent(),
    this.recordCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupManifestsCompanion.insert({
    required String id,
    required int schemaVersion,
    required String appVersion,
    required String createdAtUtc,
    required String categoriesJson,
    required int recordCount,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        schemaVersion = Value(schemaVersion),
        appVersion = Value(appVersion),
        createdAtUtc = Value(createdAtUtc),
        categoriesJson = Value(categoriesJson),
        recordCount = Value(recordCount);
  static Insertable<BackupManifestRow> custom({
    Expression<String>? id,
    Expression<int>? schemaVersion,
    Expression<String>? appVersion,
    Expression<String>? createdAtUtc,
    Expression<String>? categoriesJson,
    Expression<int>? recordCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (appVersion != null) 'app_version': appVersion,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (categoriesJson != null) 'categories_json': categoriesJson,
      if (recordCount != null) 'record_count': recordCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupManifestsCompanion copyWith(
      {Value<String>? id,
      Value<int>? schemaVersion,
      Value<String>? appVersion,
      Value<String>? createdAtUtc,
      Value<String>? categoriesJson,
      Value<int>? recordCount,
      Value<int>? rowid}) {
    return BackupManifestsCompanion(
      id: id ?? this.id,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      appVersion: appVersion ?? this.appVersion,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      categoriesJson: categoriesJson ?? this.categoriesJson,
      recordCount: recordCount ?? this.recordCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (categoriesJson.present) {
      map['categories_json'] = Variable<String>(categoriesJson.value);
    }
    if (recordCount.present) {
      map['record_count'] = Variable<int>(recordCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupManifestsCompanion(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('appVersion: $appVersion, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('categoriesJson: $categoriesJson, ')
          ..write('recordCount: $recordCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GymExercisesTable extends GymExercises
    with TableInfo<$GymExercisesTable, GymExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GymExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _primaryMuscleMeta =
      const VerificationMeta('primaryMuscle');
  @override
  late final GeneratedColumn<String> primaryMuscle = GeneratedColumn<String>(
      'primary_muscle', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _secondaryMusclesJsonMeta =
      const VerificationMeta('secondaryMusclesJson');
  @override
  late final GeneratedColumn<String> secondaryMusclesJson =
      GeneratedColumn<String>('secondary_muscles_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _equipmentMeta =
      const VerificationMeta('equipment');
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
      'equipment', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _instructionsMeta =
      const VerificationMeta('instructions');
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
      'instructions', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gifUrlMeta = const VerificationMeta('gifUrl');
  @override
  late final GeneratedColumn<String> gifUrl = GeneratedColumn<String>(
      'gif_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isTimedMeta =
      const VerificationMeta('isTimed');
  @override
  late final GeneratedColumn<bool> isTimed = GeneratedColumn<bool>(
      'is_timed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_timed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        primaryMuscle,
        secondaryMusclesJson,
        equipment,
        instructions,
        gifUrl,
        isCustom,
        isTimed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gym_exercises';
  @override
  VerificationContext validateIntegrity(Insertable<GymExerciseRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('primary_muscle')) {
      context.handle(
          _primaryMuscleMeta,
          primaryMuscle.isAcceptableOrUnknown(
              data['primary_muscle']!, _primaryMuscleMeta));
    } else if (isInserting) {
      context.missing(_primaryMuscleMeta);
    }
    if (data.containsKey('secondary_muscles_json')) {
      context.handle(
          _secondaryMusclesJsonMeta,
          secondaryMusclesJson.isAcceptableOrUnknown(
              data['secondary_muscles_json']!, _secondaryMusclesJsonMeta));
    }
    if (data.containsKey('equipment')) {
      context.handle(_equipmentMeta,
          equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta));
    } else if (isInserting) {
      context.missing(_equipmentMeta);
    }
    if (data.containsKey('instructions')) {
      context.handle(
          _instructionsMeta,
          instructions.isAcceptableOrUnknown(
              data['instructions']!, _instructionsMeta));
    }
    if (data.containsKey('gif_url')) {
      context.handle(_gifUrlMeta,
          gifUrl.isAcceptableOrUnknown(data['gif_url']!, _gifUrlMeta));
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    if (data.containsKey('is_timed')) {
      context.handle(_isTimedMeta,
          isTimed.isAcceptableOrUnknown(data['is_timed']!, _isTimedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GymExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GymExerciseRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      primaryMuscle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}primary_muscle'])!,
      secondaryMusclesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}secondary_muscles_json'])!,
      equipment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}equipment'])!,
      instructions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instructions']),
      gifUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gif_url']),
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
      isTimed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_timed'])!,
    );
  }

  @override
  $GymExercisesTable createAlias(String alias) {
    return $GymExercisesTable(attachedDatabase, alias);
  }
}

class GymExerciseRow extends DataClass implements Insertable<GymExerciseRow> {
  final String id;
  final String name;
  final String primaryMuscle;
  final String secondaryMusclesJson;
  final String equipment;
  final String? instructions;
  final String? gifUrl;
  final bool isCustom;
  final bool isTimed;
  const GymExerciseRow(
      {required this.id,
      required this.name,
      required this.primaryMuscle,
      required this.secondaryMusclesJson,
      required this.equipment,
      this.instructions,
      this.gifUrl,
      required this.isCustom,
      required this.isTimed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['primary_muscle'] = Variable<String>(primaryMuscle);
    map['secondary_muscles_json'] = Variable<String>(secondaryMusclesJson);
    map['equipment'] = Variable<String>(equipment);
    if (!nullToAbsent || instructions != null) {
      map['instructions'] = Variable<String>(instructions);
    }
    if (!nullToAbsent || gifUrl != null) {
      map['gif_url'] = Variable<String>(gifUrl);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    map['is_timed'] = Variable<bool>(isTimed);
    return map;
  }

  GymExercisesCompanion toCompanion(bool nullToAbsent) {
    return GymExercisesCompanion(
      id: Value(id),
      name: Value(name),
      primaryMuscle: Value(primaryMuscle),
      secondaryMusclesJson: Value(secondaryMusclesJson),
      equipment: Value(equipment),
      instructions: instructions == null && nullToAbsent
          ? const Value.absent()
          : Value(instructions),
      gifUrl:
          gifUrl == null && nullToAbsent ? const Value.absent() : Value(gifUrl),
      isCustom: Value(isCustom),
      isTimed: Value(isTimed),
    );
  }

  factory GymExerciseRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GymExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      primaryMuscle: serializer.fromJson<String>(json['primaryMuscle']),
      secondaryMusclesJson:
          serializer.fromJson<String>(json['secondaryMusclesJson']),
      equipment: serializer.fromJson<String>(json['equipment']),
      instructions: serializer.fromJson<String?>(json['instructions']),
      gifUrl: serializer.fromJson<String?>(json['gifUrl']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      isTimed: serializer.fromJson<bool>(json['isTimed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'primaryMuscle': serializer.toJson<String>(primaryMuscle),
      'secondaryMusclesJson': serializer.toJson<String>(secondaryMusclesJson),
      'equipment': serializer.toJson<String>(equipment),
      'instructions': serializer.toJson<String?>(instructions),
      'gifUrl': serializer.toJson<String?>(gifUrl),
      'isCustom': serializer.toJson<bool>(isCustom),
      'isTimed': serializer.toJson<bool>(isTimed),
    };
  }

  GymExerciseRow copyWith(
          {String? id,
          String? name,
          String? primaryMuscle,
          String? secondaryMusclesJson,
          String? equipment,
          Value<String?> instructions = const Value.absent(),
          Value<String?> gifUrl = const Value.absent(),
          bool? isCustom,
          bool? isTimed}) =>
      GymExerciseRow(
        id: id ?? this.id,
        name: name ?? this.name,
        primaryMuscle: primaryMuscle ?? this.primaryMuscle,
        secondaryMusclesJson: secondaryMusclesJson ?? this.secondaryMusclesJson,
        equipment: equipment ?? this.equipment,
        instructions:
            instructions.present ? instructions.value : this.instructions,
        gifUrl: gifUrl.present ? gifUrl.value : this.gifUrl,
        isCustom: isCustom ?? this.isCustom,
        isTimed: isTimed ?? this.isTimed,
      );
  GymExerciseRow copyWithCompanion(GymExercisesCompanion data) {
    return GymExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      primaryMuscle: data.primaryMuscle.present
          ? data.primaryMuscle.value
          : this.primaryMuscle,
      secondaryMusclesJson: data.secondaryMusclesJson.present
          ? data.secondaryMusclesJson.value
          : this.secondaryMusclesJson,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      gifUrl: data.gifUrl.present ? data.gifUrl.value : this.gifUrl,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      isTimed: data.isTimed.present ? data.isTimed.value : this.isTimed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GymExerciseRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('primaryMuscle: $primaryMuscle, ')
          ..write('secondaryMusclesJson: $secondaryMusclesJson, ')
          ..write('equipment: $equipment, ')
          ..write('instructions: $instructions, ')
          ..write('gifUrl: $gifUrl, ')
          ..write('isCustom: $isCustom, ')
          ..write('isTimed: $isTimed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, primaryMuscle, secondaryMusclesJson,
      equipment, instructions, gifUrl, isCustom, isTimed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GymExerciseRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.primaryMuscle == this.primaryMuscle &&
          other.secondaryMusclesJson == this.secondaryMusclesJson &&
          other.equipment == this.equipment &&
          other.instructions == this.instructions &&
          other.gifUrl == this.gifUrl &&
          other.isCustom == this.isCustom &&
          other.isTimed == this.isTimed);
}

class GymExercisesCompanion extends UpdateCompanion<GymExerciseRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> primaryMuscle;
  final Value<String> secondaryMusclesJson;
  final Value<String> equipment;
  final Value<String?> instructions;
  final Value<String?> gifUrl;
  final Value<bool> isCustom;
  final Value<bool> isTimed;
  final Value<int> rowid;
  const GymExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.primaryMuscle = const Value.absent(),
    this.secondaryMusclesJson = const Value.absent(),
    this.equipment = const Value.absent(),
    this.instructions = const Value.absent(),
    this.gifUrl = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.isTimed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GymExercisesCompanion.insert({
    required String id,
    required String name,
    required String primaryMuscle,
    this.secondaryMusclesJson = const Value.absent(),
    required String equipment,
    this.instructions = const Value.absent(),
    this.gifUrl = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.isTimed = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        primaryMuscle = Value(primaryMuscle),
        equipment = Value(equipment);
  static Insertable<GymExerciseRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? primaryMuscle,
    Expression<String>? secondaryMusclesJson,
    Expression<String>? equipment,
    Expression<String>? instructions,
    Expression<String>? gifUrl,
    Expression<bool>? isCustom,
    Expression<bool>? isTimed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (primaryMuscle != null) 'primary_muscle': primaryMuscle,
      if (secondaryMusclesJson != null)
        'secondary_muscles_json': secondaryMusclesJson,
      if (equipment != null) 'equipment': equipment,
      if (instructions != null) 'instructions': instructions,
      if (gifUrl != null) 'gif_url': gifUrl,
      if (isCustom != null) 'is_custom': isCustom,
      if (isTimed != null) 'is_timed': isTimed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GymExercisesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? primaryMuscle,
      Value<String>? secondaryMusclesJson,
      Value<String>? equipment,
      Value<String?>? instructions,
      Value<String?>? gifUrl,
      Value<bool>? isCustom,
      Value<bool>? isTimed,
      Value<int>? rowid}) {
    return GymExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      secondaryMusclesJson: secondaryMusclesJson ?? this.secondaryMusclesJson,
      equipment: equipment ?? this.equipment,
      instructions: instructions ?? this.instructions,
      gifUrl: gifUrl ?? this.gifUrl,
      isCustom: isCustom ?? this.isCustom,
      isTimed: isTimed ?? this.isTimed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (primaryMuscle.present) {
      map['primary_muscle'] = Variable<String>(primaryMuscle.value);
    }
    if (secondaryMusclesJson.present) {
      map['secondary_muscles_json'] =
          Variable<String>(secondaryMusclesJson.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (gifUrl.present) {
      map['gif_url'] = Variable<String>(gifUrl.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (isTimed.present) {
      map['is_timed'] = Variable<bool>(isTimed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GymExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('primaryMuscle: $primaryMuscle, ')
          ..write('secondaryMusclesJson: $secondaryMusclesJson, ')
          ..write('equipment: $equipment, ')
          ..write('instructions: $instructions, ')
          ..write('gifUrl: $gifUrl, ')
          ..write('isCustom: $isCustom, ')
          ..write('isTimed: $isTimed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GymWorkoutPlansTable extends GymWorkoutPlans
    with TableInfo<$GymWorkoutPlansTable, GymWorkoutPlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GymWorkoutPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _daysPerWeekMeta =
      const VerificationMeta('daysPerWeek');
  @override
  late final GeneratedColumn<int> daysPerWeek = GeneratedColumn<int>(
      'days_per_week', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtUtcMeta =
      const VerificationMeta('createdAtUtc');
  @override
  late final GeneratedColumn<String> createdAtUtc = GeneratedColumn<String>(
      'created_at_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, daysPerWeek, isActive, createdAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gym_workout_plans';
  @override
  VerificationContext validateIntegrity(Insertable<GymWorkoutPlanRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('days_per_week')) {
      context.handle(
          _daysPerWeekMeta,
          daysPerWeek.isAcceptableOrUnknown(
              data['days_per_week']!, _daysPerWeekMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
          _createdAtUtcMeta,
          createdAtUtc.isAcceptableOrUnknown(
              data['created_at_utc']!, _createdAtUtcMeta));
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GymWorkoutPlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GymWorkoutPlanRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      daysPerWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}days_per_week'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAtUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at_utc'])!,
    );
  }

  @override
  $GymWorkoutPlansTable createAlias(String alias) {
    return $GymWorkoutPlansTable(attachedDatabase, alias);
  }
}

class GymWorkoutPlanRow extends DataClass
    implements Insertable<GymWorkoutPlanRow> {
  final String id;
  final String name;
  final String? description;
  final int daysPerWeek;
  final bool isActive;
  final String createdAtUtc;
  const GymWorkoutPlanRow(
      {required this.id,
      required this.name,
      this.description,
      required this.daysPerWeek,
      required this.isActive,
      required this.createdAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['days_per_week'] = Variable<int>(daysPerWeek);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    return map;
  }

  GymWorkoutPlansCompanion toCompanion(bool nullToAbsent) {
    return GymWorkoutPlansCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      daysPerWeek: Value(daysPerWeek),
      isActive: Value(isActive),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory GymWorkoutPlanRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GymWorkoutPlanRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      daysPerWeek: serializer.fromJson<int>(json['daysPerWeek']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'daysPerWeek': serializer.toJson<int>(daysPerWeek),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
    };
  }

  GymWorkoutPlanRow copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          int? daysPerWeek,
          bool? isActive,
          String? createdAtUtc}) =>
      GymWorkoutPlanRow(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        daysPerWeek: daysPerWeek ?? this.daysPerWeek,
        isActive: isActive ?? this.isActive,
        createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      );
  GymWorkoutPlanRow copyWithCompanion(GymWorkoutPlansCompanion data) {
    return GymWorkoutPlanRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      daysPerWeek:
          data.daysPerWeek.present ? data.daysPerWeek.value : this.daysPerWeek,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GymWorkoutPlanRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('daysPerWeek: $daysPerWeek, ')
          ..write('isActive: $isActive, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, daysPerWeek, isActive, createdAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GymWorkoutPlanRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.daysPerWeek == this.daysPerWeek &&
          other.isActive == this.isActive &&
          other.createdAtUtc == this.createdAtUtc);
}

class GymWorkoutPlansCompanion extends UpdateCompanion<GymWorkoutPlanRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> daysPerWeek;
  final Value<bool> isActive;
  final Value<String> createdAtUtc;
  final Value<int> rowid;
  const GymWorkoutPlansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.daysPerWeek = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GymWorkoutPlansCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.daysPerWeek = const Value.absent(),
    this.isActive = const Value.absent(),
    required String createdAtUtc,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAtUtc = Value(createdAtUtc);
  static Insertable<GymWorkoutPlanRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? daysPerWeek,
    Expression<bool>? isActive,
    Expression<String>? createdAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (daysPerWeek != null) 'days_per_week': daysPerWeek,
      if (isActive != null) 'is_active': isActive,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GymWorkoutPlansCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<int>? daysPerWeek,
      Value<bool>? isActive,
      Value<String>? createdAtUtc,
      Value<int>? rowid}) {
    return GymWorkoutPlansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      isActive: isActive ?? this.isActive,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (daysPerWeek.present) {
      map['days_per_week'] = Variable<int>(daysPerWeek.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GymWorkoutPlansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('daysPerWeek: $daysPerWeek, ')
          ..write('isActive: $isActive, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GymPlanRoutinesTable extends GymPlanRoutines
    with TableInfo<$GymPlanRoutinesTable, GymPlanRoutineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GymPlanRoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
      'plan_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES gym_workout_plans (id) ON DELETE CASCADE'));
  static const VerificationMeta _dayOfWeekMeta =
      const VerificationMeta('dayOfWeek');
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
      'day_of_week', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _progressionTypeMeta =
      const VerificationMeta('progressionType');
  @override
  late final GeneratedColumn<String> progressionType = GeneratedColumn<String>(
      'progression_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('linear'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, planId, dayOfWeek, name, progressionType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gym_plan_routines';
  @override
  VerificationContext validateIntegrity(Insertable<GymPlanRoutineRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(_planIdMeta,
          planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta));
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
          _dayOfWeekMeta,
          dayOfWeek.isAcceptableOrUnknown(
              data['day_of_week']!, _dayOfWeekMeta));
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('progression_type')) {
      context.handle(
          _progressionTypeMeta,
          progressionType.isAcceptableOrUnknown(
              data['progression_type']!, _progressionTypeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GymPlanRoutineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GymPlanRoutineRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      planId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan_id'])!,
      dayOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_week'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      progressionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}progression_type'])!,
    );
  }

  @override
  $GymPlanRoutinesTable createAlias(String alias) {
    return $GymPlanRoutinesTable(attachedDatabase, alias);
  }
}

class GymPlanRoutineRow extends DataClass
    implements Insertable<GymPlanRoutineRow> {
  final String id;
  final String planId;
  final int dayOfWeek;
  final String name;
  final String progressionType;
  const GymPlanRoutineRow(
      {required this.id,
      required this.planId,
      required this.dayOfWeek,
      required this.name,
      required this.progressionType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['name'] = Variable<String>(name);
    map['progression_type'] = Variable<String>(progressionType);
    return map;
  }

  GymPlanRoutinesCompanion toCompanion(bool nullToAbsent) {
    return GymPlanRoutinesCompanion(
      id: Value(id),
      planId: Value(planId),
      dayOfWeek: Value(dayOfWeek),
      name: Value(name),
      progressionType: Value(progressionType),
    );
  }

  factory GymPlanRoutineRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GymPlanRoutineRow(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      name: serializer.fromJson<String>(json['name']),
      progressionType: serializer.fromJson<String>(json['progressionType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'name': serializer.toJson<String>(name),
      'progressionType': serializer.toJson<String>(progressionType),
    };
  }

  GymPlanRoutineRow copyWith(
          {String? id,
          String? planId,
          int? dayOfWeek,
          String? name,
          String? progressionType}) =>
      GymPlanRoutineRow(
        id: id ?? this.id,
        planId: planId ?? this.planId,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        name: name ?? this.name,
        progressionType: progressionType ?? this.progressionType,
      );
  GymPlanRoutineRow copyWithCompanion(GymPlanRoutinesCompanion data) {
    return GymPlanRoutineRow(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      name: data.name.present ? data.name.value : this.name,
      progressionType: data.progressionType.present
          ? data.progressionType.value
          : this.progressionType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GymPlanRoutineRow(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('name: $name, ')
          ..write('progressionType: $progressionType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planId, dayOfWeek, name, progressionType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GymPlanRoutineRow &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.dayOfWeek == this.dayOfWeek &&
          other.name == this.name &&
          other.progressionType == this.progressionType);
}

class GymPlanRoutinesCompanion extends UpdateCompanion<GymPlanRoutineRow> {
  final Value<String> id;
  final Value<String> planId;
  final Value<int> dayOfWeek;
  final Value<String> name;
  final Value<String> progressionType;
  final Value<int> rowid;
  const GymPlanRoutinesCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.name = const Value.absent(),
    this.progressionType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GymPlanRoutinesCompanion.insert({
    required String id,
    required String planId,
    required int dayOfWeek,
    required String name,
    this.progressionType = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        planId = Value(planId),
        dayOfWeek = Value(dayOfWeek),
        name = Value(name);
  static Insertable<GymPlanRoutineRow> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<int>? dayOfWeek,
    Expression<String>? name,
    Expression<String>? progressionType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (name != null) 'name': name,
      if (progressionType != null) 'progression_type': progressionType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GymPlanRoutinesCompanion copyWith(
      {Value<String>? id,
      Value<String>? planId,
      Value<int>? dayOfWeek,
      Value<String>? name,
      Value<String>? progressionType,
      Value<int>? rowid}) {
    return GymPlanRoutinesCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      name: name ?? this.name,
      progressionType: progressionType ?? this.progressionType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (progressionType.present) {
      map['progression_type'] = Variable<String>(progressionType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GymPlanRoutinesCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('name: $name, ')
          ..write('progressionType: $progressionType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GymPlanRoutineExercisesTable extends GymPlanRoutineExercises
    with TableInfo<$GymPlanRoutineExercisesTable, GymPlanRoutineExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GymPlanRoutineExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _routineIdMeta =
      const VerificationMeta('routineId');
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
      'routine_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES gym_plan_routines (id) ON DELETE CASCADE'));
  static const VerificationMeta _exerciseIdMeta =
      const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
      'exercise_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES gym_exercises (id)'));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _targetSetsMeta =
      const VerificationMeta('targetSets');
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
      'target_sets', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _targetRepsMinMeta =
      const VerificationMeta('targetRepsMin');
  @override
  late final GeneratedColumn<int> targetRepsMin = GeneratedColumn<int>(
      'target_reps_min', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(8));
  static const VerificationMeta _targetRepsMaxMeta =
      const VerificationMeta('targetRepsMax');
  @override
  late final GeneratedColumn<int> targetRepsMax = GeneratedColumn<int>(
      'target_reps_max', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(12));
  static const VerificationMeta _targetHoldSecondsMeta =
      const VerificationMeta('targetHoldSeconds');
  @override
  late final GeneratedColumn<int> targetHoldSeconds = GeneratedColumn<int>(
      'target_hold_seconds', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _restSecondsMeta =
      const VerificationMeta('restSeconds');
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
      'rest_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(90));
  static const VerificationMeta _supersetGroupIdMeta =
      const VerificationMeta('supersetGroupId');
  @override
  late final GeneratedColumn<String> supersetGroupId = GeneratedColumn<String>(
      'superset_group_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        routineId,
        exerciseId,
        orderIndex,
        targetSets,
        targetRepsMin,
        targetRepsMax,
        targetHoldSeconds,
        restSeconds,
        supersetGroupId,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gym_plan_routine_exercises';
  @override
  VerificationContext validateIntegrity(
      Insertable<GymPlanRoutineExerciseRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(_routineIdMeta,
          routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta));
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
          _exerciseIdMeta,
          exerciseId.isAcceptableOrUnknown(
              data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('target_sets')) {
      context.handle(
          _targetSetsMeta,
          targetSets.isAcceptableOrUnknown(
              data['target_sets']!, _targetSetsMeta));
    }
    if (data.containsKey('target_reps_min')) {
      context.handle(
          _targetRepsMinMeta,
          targetRepsMin.isAcceptableOrUnknown(
              data['target_reps_min']!, _targetRepsMinMeta));
    }
    if (data.containsKey('target_reps_max')) {
      context.handle(
          _targetRepsMaxMeta,
          targetRepsMax.isAcceptableOrUnknown(
              data['target_reps_max']!, _targetRepsMaxMeta));
    }
    if (data.containsKey('target_hold_seconds')) {
      context.handle(
          _targetHoldSecondsMeta,
          targetHoldSeconds.isAcceptableOrUnknown(
              data['target_hold_seconds']!, _targetHoldSecondsMeta));
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
          _restSecondsMeta,
          restSeconds.isAcceptableOrUnknown(
              data['rest_seconds']!, _restSecondsMeta));
    }
    if (data.containsKey('superset_group_id')) {
      context.handle(
          _supersetGroupIdMeta,
          supersetGroupId.isAcceptableOrUnknown(
              data['superset_group_id']!, _supersetGroupIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GymPlanRoutineExerciseRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GymPlanRoutineExerciseRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      routineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}routine_id'])!,
      exerciseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exercise_id'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      targetSets: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_sets'])!,
      targetRepsMin: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_reps_min'])!,
      targetRepsMax: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_reps_max'])!,
      targetHoldSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}target_hold_seconds']),
      restSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rest_seconds'])!,
      supersetGroupId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}superset_group_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $GymPlanRoutineExercisesTable createAlias(String alias) {
    return $GymPlanRoutineExercisesTable(attachedDatabase, alias);
  }
}

class GymPlanRoutineExerciseRow extends DataClass
    implements Insertable<GymPlanRoutineExerciseRow> {
  final String id;
  final String routineId;
  final String exerciseId;
  final int orderIndex;
  final int targetSets;
  final int targetRepsMin;
  final int targetRepsMax;
  final int? targetHoldSeconds;
  final int restSeconds;
  final String? supersetGroupId;
  final String? notes;
  const GymPlanRoutineExerciseRow(
      {required this.id,
      required this.routineId,
      required this.exerciseId,
      required this.orderIndex,
      required this.targetSets,
      required this.targetRepsMin,
      required this.targetRepsMax,
      this.targetHoldSeconds,
      required this.restSeconds,
      this.supersetGroupId,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['routine_id'] = Variable<String>(routineId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['order_index'] = Variable<int>(orderIndex);
    map['target_sets'] = Variable<int>(targetSets);
    map['target_reps_min'] = Variable<int>(targetRepsMin);
    map['target_reps_max'] = Variable<int>(targetRepsMax);
    if (!nullToAbsent || targetHoldSeconds != null) {
      map['target_hold_seconds'] = Variable<int>(targetHoldSeconds);
    }
    map['rest_seconds'] = Variable<int>(restSeconds);
    if (!nullToAbsent || supersetGroupId != null) {
      map['superset_group_id'] = Variable<String>(supersetGroupId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  GymPlanRoutineExercisesCompanion toCompanion(bool nullToAbsent) {
    return GymPlanRoutineExercisesCompanion(
      id: Value(id),
      routineId: Value(routineId),
      exerciseId: Value(exerciseId),
      orderIndex: Value(orderIndex),
      targetSets: Value(targetSets),
      targetRepsMin: Value(targetRepsMin),
      targetRepsMax: Value(targetRepsMax),
      targetHoldSeconds: targetHoldSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(targetHoldSeconds),
      restSeconds: Value(restSeconds),
      supersetGroupId: supersetGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersetGroupId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory GymPlanRoutineExerciseRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GymPlanRoutineExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      routineId: serializer.fromJson<String>(json['routineId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      targetSets: serializer.fromJson<int>(json['targetSets']),
      targetRepsMin: serializer.fromJson<int>(json['targetRepsMin']),
      targetRepsMax: serializer.fromJson<int>(json['targetRepsMax']),
      targetHoldSeconds: serializer.fromJson<int?>(json['targetHoldSeconds']),
      restSeconds: serializer.fromJson<int>(json['restSeconds']),
      supersetGroupId: serializer.fromJson<String?>(json['supersetGroupId']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routineId': serializer.toJson<String>(routineId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'targetSets': serializer.toJson<int>(targetSets),
      'targetRepsMin': serializer.toJson<int>(targetRepsMin),
      'targetRepsMax': serializer.toJson<int>(targetRepsMax),
      'targetHoldSeconds': serializer.toJson<int?>(targetHoldSeconds),
      'restSeconds': serializer.toJson<int>(restSeconds),
      'supersetGroupId': serializer.toJson<String?>(supersetGroupId),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  GymPlanRoutineExerciseRow copyWith(
          {String? id,
          String? routineId,
          String? exerciseId,
          int? orderIndex,
          int? targetSets,
          int? targetRepsMin,
          int? targetRepsMax,
          Value<int?> targetHoldSeconds = const Value.absent(),
          int? restSeconds,
          Value<String?> supersetGroupId = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      GymPlanRoutineExerciseRow(
        id: id ?? this.id,
        routineId: routineId ?? this.routineId,
        exerciseId: exerciseId ?? this.exerciseId,
        orderIndex: orderIndex ?? this.orderIndex,
        targetSets: targetSets ?? this.targetSets,
        targetRepsMin: targetRepsMin ?? this.targetRepsMin,
        targetRepsMax: targetRepsMax ?? this.targetRepsMax,
        targetHoldSeconds: targetHoldSeconds.present
            ? targetHoldSeconds.value
            : this.targetHoldSeconds,
        restSeconds: restSeconds ?? this.restSeconds,
        supersetGroupId: supersetGroupId.present
            ? supersetGroupId.value
            : this.supersetGroupId,
        notes: notes.present ? notes.value : this.notes,
      );
  GymPlanRoutineExerciseRow copyWithCompanion(
      GymPlanRoutineExercisesCompanion data) {
    return GymPlanRoutineExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      targetSets:
          data.targetSets.present ? data.targetSets.value : this.targetSets,
      targetRepsMin: data.targetRepsMin.present
          ? data.targetRepsMin.value
          : this.targetRepsMin,
      targetRepsMax: data.targetRepsMax.present
          ? data.targetRepsMax.value
          : this.targetRepsMax,
      targetHoldSeconds: data.targetHoldSeconds.present
          ? data.targetHoldSeconds.value
          : this.targetHoldSeconds,
      restSeconds:
          data.restSeconds.present ? data.restSeconds.value : this.restSeconds,
      supersetGroupId: data.supersetGroupId.present
          ? data.supersetGroupId.value
          : this.supersetGroupId,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GymPlanRoutineExerciseRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetRepsMin: $targetRepsMin, ')
          ..write('targetRepsMax: $targetRepsMax, ')
          ..write('targetHoldSeconds: $targetHoldSeconds, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('supersetGroupId: $supersetGroupId, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      routineId,
      exerciseId,
      orderIndex,
      targetSets,
      targetRepsMin,
      targetRepsMax,
      targetHoldSeconds,
      restSeconds,
      supersetGroupId,
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GymPlanRoutineExerciseRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.exerciseId == this.exerciseId &&
          other.orderIndex == this.orderIndex &&
          other.targetSets == this.targetSets &&
          other.targetRepsMin == this.targetRepsMin &&
          other.targetRepsMax == this.targetRepsMax &&
          other.targetHoldSeconds == this.targetHoldSeconds &&
          other.restSeconds == this.restSeconds &&
          other.supersetGroupId == this.supersetGroupId &&
          other.notes == this.notes);
}

class GymPlanRoutineExercisesCompanion
    extends UpdateCompanion<GymPlanRoutineExerciseRow> {
  final Value<String> id;
  final Value<String> routineId;
  final Value<String> exerciseId;
  final Value<int> orderIndex;
  final Value<int> targetSets;
  final Value<int> targetRepsMin;
  final Value<int> targetRepsMax;
  final Value<int?> targetHoldSeconds;
  final Value<int> restSeconds;
  final Value<String?> supersetGroupId;
  final Value<String?> notes;
  final Value<int> rowid;
  const GymPlanRoutineExercisesCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetRepsMin = const Value.absent(),
    this.targetRepsMax = const Value.absent(),
    this.targetHoldSeconds = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.supersetGroupId = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GymPlanRoutineExercisesCompanion.insert({
    required String id,
    required String routineId,
    required String exerciseId,
    required int orderIndex,
    this.targetSets = const Value.absent(),
    this.targetRepsMin = const Value.absent(),
    this.targetRepsMax = const Value.absent(),
    this.targetHoldSeconds = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.supersetGroupId = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        routineId = Value(routineId),
        exerciseId = Value(exerciseId),
        orderIndex = Value(orderIndex);
  static Insertable<GymPlanRoutineExerciseRow> custom({
    Expression<String>? id,
    Expression<String>? routineId,
    Expression<String>? exerciseId,
    Expression<int>? orderIndex,
    Expression<int>? targetSets,
    Expression<int>? targetRepsMin,
    Expression<int>? targetRepsMax,
    Expression<int>? targetHoldSeconds,
    Expression<int>? restSeconds,
    Expression<String>? supersetGroupId,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (targetSets != null) 'target_sets': targetSets,
      if (targetRepsMin != null) 'target_reps_min': targetRepsMin,
      if (targetRepsMax != null) 'target_reps_max': targetRepsMax,
      if (targetHoldSeconds != null) 'target_hold_seconds': targetHoldSeconds,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (supersetGroupId != null) 'superset_group_id': supersetGroupId,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GymPlanRoutineExercisesCompanion copyWith(
      {Value<String>? id,
      Value<String>? routineId,
      Value<String>? exerciseId,
      Value<int>? orderIndex,
      Value<int>? targetSets,
      Value<int>? targetRepsMin,
      Value<int>? targetRepsMax,
      Value<int?>? targetHoldSeconds,
      Value<int>? restSeconds,
      Value<String?>? supersetGroupId,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return GymPlanRoutineExercisesCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      targetSets: targetSets ?? this.targetSets,
      targetRepsMin: targetRepsMin ?? this.targetRepsMin,
      targetRepsMax: targetRepsMax ?? this.targetRepsMax,
      targetHoldSeconds: targetHoldSeconds ?? this.targetHoldSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      supersetGroupId: supersetGroupId ?? this.supersetGroupId,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (targetRepsMin.present) {
      map['target_reps_min'] = Variable<int>(targetRepsMin.value);
    }
    if (targetRepsMax.present) {
      map['target_reps_max'] = Variable<int>(targetRepsMax.value);
    }
    if (targetHoldSeconds.present) {
      map['target_hold_seconds'] = Variable<int>(targetHoldSeconds.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (supersetGroupId.present) {
      map['superset_group_id'] = Variable<String>(supersetGroupId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GymPlanRoutineExercisesCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetRepsMin: $targetRepsMin, ')
          ..write('targetRepsMax: $targetRepsMax, ')
          ..write('targetHoldSeconds: $targetHoldSeconds, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('supersetGroupId: $supersetGroupId, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GymWorkoutSessionsTable extends GymWorkoutSessions
    with TableInfo<$GymWorkoutSessionsTable, GymWorkoutSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GymWorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _routineIdMeta =
      const VerificationMeta('routineId');
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
      'routine_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _routineNameMeta =
      const VerificationMeta('routineName');
  @override
  late final GeneratedColumn<String> routineName = GeneratedColumn<String>(
      'routine_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startUtcMeta =
      const VerificationMeta('startUtc');
  @override
  late final GeneratedColumn<String> startUtc = GeneratedColumn<String>(
      'start_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endUtcMeta = const VerificationMeta('endUtc');
  @override
  late final GeneratedColumn<String> endUtc = GeneratedColumn<String>(
      'end_utc', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<double> durationSeconds = GeneratedColumn<double>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalTonnageKgMeta =
      const VerificationMeta('totalTonnageKg');
  @override
  late final GeneratedColumn<double> totalTonnageKg = GeneratedColumn<double>(
      'total_tonnage_kg', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rpeAverageMeta =
      const VerificationMeta('rpeAverage');
  @override
  late final GeneratedColumn<double> rpeAverage = GeneratedColumn<double>(
      'rpe_average', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        routineId,
        routineName,
        startUtc,
        endUtc,
        durationSeconds,
        totalTonnageKg,
        notes,
        rpeAverage
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gym_workout_sessions';
  @override
  VerificationContext validateIntegrity(
      Insertable<GymWorkoutSessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(_routineIdMeta,
          routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta));
    }
    if (data.containsKey('routine_name')) {
      context.handle(
          _routineNameMeta,
          routineName.isAcceptableOrUnknown(
              data['routine_name']!, _routineNameMeta));
    } else if (isInserting) {
      context.missing(_routineNameMeta);
    }
    if (data.containsKey('start_utc')) {
      context.handle(_startUtcMeta,
          startUtc.isAcceptableOrUnknown(data['start_utc']!, _startUtcMeta));
    } else if (isInserting) {
      context.missing(_startUtcMeta);
    }
    if (data.containsKey('end_utc')) {
      context.handle(_endUtcMeta,
          endUtc.isAcceptableOrUnknown(data['end_utc']!, _endUtcMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    }
    if (data.containsKey('total_tonnage_kg')) {
      context.handle(
          _totalTonnageKgMeta,
          totalTonnageKg.isAcceptableOrUnknown(
              data['total_tonnage_kg']!, _totalTonnageKgMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('rpe_average')) {
      context.handle(
          _rpeAverageMeta,
          rpeAverage.isAcceptableOrUnknown(
              data['rpe_average']!, _rpeAverageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GymWorkoutSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GymWorkoutSessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      routineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}routine_id']),
      routineName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}routine_name'])!,
      startUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_utc'])!,
      endUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_utc']),
      durationSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}duration_seconds'])!,
      totalTonnageKg: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_tonnage_kg'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      rpeAverage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rpe_average']),
    );
  }

  @override
  $GymWorkoutSessionsTable createAlias(String alias) {
    return $GymWorkoutSessionsTable(attachedDatabase, alias);
  }
}

class GymWorkoutSessionRow extends DataClass
    implements Insertable<GymWorkoutSessionRow> {
  final String id;
  final String? routineId;
  final String routineName;
  final String startUtc;
  final String? endUtc;
  final double durationSeconds;
  final double totalTonnageKg;
  final String? notes;
  final double? rpeAverage;
  const GymWorkoutSessionRow(
      {required this.id,
      this.routineId,
      required this.routineName,
      required this.startUtc,
      this.endUtc,
      required this.durationSeconds,
      required this.totalTonnageKg,
      this.notes,
      this.rpeAverage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || routineId != null) {
      map['routine_id'] = Variable<String>(routineId);
    }
    map['routine_name'] = Variable<String>(routineName);
    map['start_utc'] = Variable<String>(startUtc);
    if (!nullToAbsent || endUtc != null) {
      map['end_utc'] = Variable<String>(endUtc);
    }
    map['duration_seconds'] = Variable<double>(durationSeconds);
    map['total_tonnage_kg'] = Variable<double>(totalTonnageKg);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || rpeAverage != null) {
      map['rpe_average'] = Variable<double>(rpeAverage);
    }
    return map;
  }

  GymWorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return GymWorkoutSessionsCompanion(
      id: Value(id),
      routineId: routineId == null && nullToAbsent
          ? const Value.absent()
          : Value(routineId),
      routineName: Value(routineName),
      startUtc: Value(startUtc),
      endUtc:
          endUtc == null && nullToAbsent ? const Value.absent() : Value(endUtc),
      durationSeconds: Value(durationSeconds),
      totalTonnageKg: Value(totalTonnageKg),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      rpeAverage: rpeAverage == null && nullToAbsent
          ? const Value.absent()
          : Value(rpeAverage),
    );
  }

  factory GymWorkoutSessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GymWorkoutSessionRow(
      id: serializer.fromJson<String>(json['id']),
      routineId: serializer.fromJson<String?>(json['routineId']),
      routineName: serializer.fromJson<String>(json['routineName']),
      startUtc: serializer.fromJson<String>(json['startUtc']),
      endUtc: serializer.fromJson<String?>(json['endUtc']),
      durationSeconds: serializer.fromJson<double>(json['durationSeconds']),
      totalTonnageKg: serializer.fromJson<double>(json['totalTonnageKg']),
      notes: serializer.fromJson<String?>(json['notes']),
      rpeAverage: serializer.fromJson<double?>(json['rpeAverage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routineId': serializer.toJson<String?>(routineId),
      'routineName': serializer.toJson<String>(routineName),
      'startUtc': serializer.toJson<String>(startUtc),
      'endUtc': serializer.toJson<String?>(endUtc),
      'durationSeconds': serializer.toJson<double>(durationSeconds),
      'totalTonnageKg': serializer.toJson<double>(totalTonnageKg),
      'notes': serializer.toJson<String?>(notes),
      'rpeAverage': serializer.toJson<double?>(rpeAverage),
    };
  }

  GymWorkoutSessionRow copyWith(
          {String? id,
          Value<String?> routineId = const Value.absent(),
          String? routineName,
          String? startUtc,
          Value<String?> endUtc = const Value.absent(),
          double? durationSeconds,
          double? totalTonnageKg,
          Value<String?> notes = const Value.absent(),
          Value<double?> rpeAverage = const Value.absent()}) =>
      GymWorkoutSessionRow(
        id: id ?? this.id,
        routineId: routineId.present ? routineId.value : this.routineId,
        routineName: routineName ?? this.routineName,
        startUtc: startUtc ?? this.startUtc,
        endUtc: endUtc.present ? endUtc.value : this.endUtc,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        totalTonnageKg: totalTonnageKg ?? this.totalTonnageKg,
        notes: notes.present ? notes.value : this.notes,
        rpeAverage: rpeAverage.present ? rpeAverage.value : this.rpeAverage,
      );
  GymWorkoutSessionRow copyWithCompanion(GymWorkoutSessionsCompanion data) {
    return GymWorkoutSessionRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      routineName:
          data.routineName.present ? data.routineName.value : this.routineName,
      startUtc: data.startUtc.present ? data.startUtc.value : this.startUtc,
      endUtc: data.endUtc.present ? data.endUtc.value : this.endUtc,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      totalTonnageKg: data.totalTonnageKg.present
          ? data.totalTonnageKg.value
          : this.totalTonnageKg,
      notes: data.notes.present ? data.notes.value : this.notes,
      rpeAverage:
          data.rpeAverage.present ? data.rpeAverage.value : this.rpeAverage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GymWorkoutSessionRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('routineName: $routineName, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('totalTonnageKg: $totalTonnageKg, ')
          ..write('notes: $notes, ')
          ..write('rpeAverage: $rpeAverage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, routineId, routineName, startUtc, endUtc,
      durationSeconds, totalTonnageKg, notes, rpeAverage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GymWorkoutSessionRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.routineName == this.routineName &&
          other.startUtc == this.startUtc &&
          other.endUtc == this.endUtc &&
          other.durationSeconds == this.durationSeconds &&
          other.totalTonnageKg == this.totalTonnageKg &&
          other.notes == this.notes &&
          other.rpeAverage == this.rpeAverage);
}

class GymWorkoutSessionsCompanion
    extends UpdateCompanion<GymWorkoutSessionRow> {
  final Value<String> id;
  final Value<String?> routineId;
  final Value<String> routineName;
  final Value<String> startUtc;
  final Value<String?> endUtc;
  final Value<double> durationSeconds;
  final Value<double> totalTonnageKg;
  final Value<String?> notes;
  final Value<double?> rpeAverage;
  final Value<int> rowid;
  const GymWorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.routineName = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.endUtc = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.totalTonnageKg = const Value.absent(),
    this.notes = const Value.absent(),
    this.rpeAverage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GymWorkoutSessionsCompanion.insert({
    required String id,
    this.routineId = const Value.absent(),
    required String routineName,
    required String startUtc,
    this.endUtc = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.totalTonnageKg = const Value.absent(),
    this.notes = const Value.absent(),
    this.rpeAverage = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        routineName = Value(routineName),
        startUtc = Value(startUtc);
  static Insertable<GymWorkoutSessionRow> custom({
    Expression<String>? id,
    Expression<String>? routineId,
    Expression<String>? routineName,
    Expression<String>? startUtc,
    Expression<String>? endUtc,
    Expression<double>? durationSeconds,
    Expression<double>? totalTonnageKg,
    Expression<String>? notes,
    Expression<double>? rpeAverage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (routineName != null) 'routine_name': routineName,
      if (startUtc != null) 'start_utc': startUtc,
      if (endUtc != null) 'end_utc': endUtc,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (totalTonnageKg != null) 'total_tonnage_kg': totalTonnageKg,
      if (notes != null) 'notes': notes,
      if (rpeAverage != null) 'rpe_average': rpeAverage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GymWorkoutSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? routineId,
      Value<String>? routineName,
      Value<String>? startUtc,
      Value<String?>? endUtc,
      Value<double>? durationSeconds,
      Value<double>? totalTonnageKg,
      Value<String?>? notes,
      Value<double?>? rpeAverage,
      Value<int>? rowid}) {
    return GymWorkoutSessionsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      routineName: routineName ?? this.routineName,
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      totalTonnageKg: totalTonnageKg ?? this.totalTonnageKg,
      notes: notes ?? this.notes,
      rpeAverage: rpeAverage ?? this.rpeAverage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (routineName.present) {
      map['routine_name'] = Variable<String>(routineName.value);
    }
    if (startUtc.present) {
      map['start_utc'] = Variable<String>(startUtc.value);
    }
    if (endUtc.present) {
      map['end_utc'] = Variable<String>(endUtc.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<double>(durationSeconds.value);
    }
    if (totalTonnageKg.present) {
      map['total_tonnage_kg'] = Variable<double>(totalTonnageKg.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rpeAverage.present) {
      map['rpe_average'] = Variable<double>(rpeAverage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GymWorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('routineName: $routineName, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('totalTonnageKg: $totalTonnageKg, ')
          ..write('notes: $notes, ')
          ..write('rpeAverage: $rpeAverage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GymSetLogsTable extends GymSetLogs
    with TableInfo<$GymSetLogsTable, GymSetLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GymSetLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES gym_workout_sessions (id) ON DELETE CASCADE'));
  static const VerificationMeta _exerciseIdMeta =
      const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
      'exercise_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES gym_exercises (id)'));
  static const VerificationMeta _setIndexMeta =
      const VerificationMeta('setIndex');
  @override
  late final GeneratedColumn<int> setIndex = GeneratedColumn<int>(
      'set_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _setTypeMeta =
      const VerificationMeta('setType');
  @override
  late final GeneratedColumn<String> setType = GeneratedColumn<String>(
      'set_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('normal'));
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _holdSecondsMeta =
      const VerificationMeta('holdSeconds');
  @override
  late final GeneratedColumn<int> holdSeconds = GeneratedColumn<int>(
      'hold_seconds', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<double> rpe = GeneratedColumn<double>(
      'rpe', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _rirMeta = const VerificationMeta('rir');
  @override
  late final GeneratedColumn<int> rir = GeneratedColumn<int>(
      'rir', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _loggedAtUtcMeta =
      const VerificationMeta('loggedAtUtc');
  @override
  late final GeneratedColumn<String> loggedAtUtc = GeneratedColumn<String>(
      'logged_at_utc', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        exerciseId,
        setIndex,
        setType,
        weightKg,
        reps,
        holdSeconds,
        rpe,
        rir,
        completed,
        loggedAtUtc
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gym_set_logs';
  @override
  VerificationContext validateIntegrity(Insertable<GymSetLogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
          _exerciseIdMeta,
          exerciseId.isAcceptableOrUnknown(
              data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('set_index')) {
      context.handle(_setIndexMeta,
          setIndex.isAcceptableOrUnknown(data['set_index']!, _setIndexMeta));
    } else if (isInserting) {
      context.missing(_setIndexMeta);
    }
    if (data.containsKey('set_type')) {
      context.handle(_setTypeMeta,
          setType.isAcceptableOrUnknown(data['set_type']!, _setTypeMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('hold_seconds')) {
      context.handle(
          _holdSecondsMeta,
          holdSeconds.isAcceptableOrUnknown(
              data['hold_seconds']!, _holdSecondsMeta));
    }
    if (data.containsKey('rpe')) {
      context.handle(
          _rpeMeta, rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta));
    }
    if (data.containsKey('rir')) {
      context.handle(
          _rirMeta, rir.isAcceptableOrUnknown(data['rir']!, _rirMeta));
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    if (data.containsKey('logged_at_utc')) {
      context.handle(
          _loggedAtUtcMeta,
          loggedAtUtc.isAcceptableOrUnknown(
              data['logged_at_utc']!, _loggedAtUtcMeta));
    } else if (isInserting) {
      context.missing(_loggedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GymSetLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GymSetLogRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      exerciseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exercise_id'])!,
      setIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}set_index'])!,
      setType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}set_type'])!,
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg'])!,
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps']),
      holdSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hold_seconds']),
      rpe: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rpe']),
      rir: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rir']),
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      loggedAtUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logged_at_utc'])!,
    );
  }

  @override
  $GymSetLogsTable createAlias(String alias) {
    return $GymSetLogsTable(attachedDatabase, alias);
  }
}

class GymSetLogRow extends DataClass implements Insertable<GymSetLogRow> {
  final String id;
  final String sessionId;
  final String exerciseId;
  final int setIndex;
  final String setType;
  final double weightKg;
  final int? reps;
  final int? holdSeconds;
  final double? rpe;
  final int? rir;
  final bool completed;
  final String loggedAtUtc;
  const GymSetLogRow(
      {required this.id,
      required this.sessionId,
      required this.exerciseId,
      required this.setIndex,
      required this.setType,
      required this.weightKg,
      this.reps,
      this.holdSeconds,
      this.rpe,
      this.rir,
      required this.completed,
      required this.loggedAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['set_index'] = Variable<int>(setIndex);
    map['set_type'] = Variable<String>(setType);
    map['weight_kg'] = Variable<double>(weightKg);
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || holdSeconds != null) {
      map['hold_seconds'] = Variable<int>(holdSeconds);
    }
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<double>(rpe);
    }
    if (!nullToAbsent || rir != null) {
      map['rir'] = Variable<int>(rir);
    }
    map['completed'] = Variable<bool>(completed);
    map['logged_at_utc'] = Variable<String>(loggedAtUtc);
    return map;
  }

  GymSetLogsCompanion toCompanion(bool nullToAbsent) {
    return GymSetLogsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      setIndex: Value(setIndex),
      setType: Value(setType),
      weightKg: Value(weightKg),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      holdSeconds: holdSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(holdSeconds),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      rir: rir == null && nullToAbsent ? const Value.absent() : Value(rir),
      completed: Value(completed),
      loggedAtUtc: Value(loggedAtUtc),
    );
  }

  factory GymSetLogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GymSetLogRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      setIndex: serializer.fromJson<int>(json['setIndex']),
      setType: serializer.fromJson<String>(json['setType']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      reps: serializer.fromJson<int?>(json['reps']),
      holdSeconds: serializer.fromJson<int?>(json['holdSeconds']),
      rpe: serializer.fromJson<double?>(json['rpe']),
      rir: serializer.fromJson<int?>(json['rir']),
      completed: serializer.fromJson<bool>(json['completed']),
      loggedAtUtc: serializer.fromJson<String>(json['loggedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'setIndex': serializer.toJson<int>(setIndex),
      'setType': serializer.toJson<String>(setType),
      'weightKg': serializer.toJson<double>(weightKg),
      'reps': serializer.toJson<int?>(reps),
      'holdSeconds': serializer.toJson<int?>(holdSeconds),
      'rpe': serializer.toJson<double?>(rpe),
      'rir': serializer.toJson<int?>(rir),
      'completed': serializer.toJson<bool>(completed),
      'loggedAtUtc': serializer.toJson<String>(loggedAtUtc),
    };
  }

  GymSetLogRow copyWith(
          {String? id,
          String? sessionId,
          String? exerciseId,
          int? setIndex,
          String? setType,
          double? weightKg,
          Value<int?> reps = const Value.absent(),
          Value<int?> holdSeconds = const Value.absent(),
          Value<double?> rpe = const Value.absent(),
          Value<int?> rir = const Value.absent(),
          bool? completed,
          String? loggedAtUtc}) =>
      GymSetLogRow(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        exerciseId: exerciseId ?? this.exerciseId,
        setIndex: setIndex ?? this.setIndex,
        setType: setType ?? this.setType,
        weightKg: weightKg ?? this.weightKg,
        reps: reps.present ? reps.value : this.reps,
        holdSeconds: holdSeconds.present ? holdSeconds.value : this.holdSeconds,
        rpe: rpe.present ? rpe.value : this.rpe,
        rir: rir.present ? rir.value : this.rir,
        completed: completed ?? this.completed,
        loggedAtUtc: loggedAtUtc ?? this.loggedAtUtc,
      );
  GymSetLogRow copyWithCompanion(GymSetLogsCompanion data) {
    return GymSetLogRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      setIndex: data.setIndex.present ? data.setIndex.value : this.setIndex,
      setType: data.setType.present ? data.setType.value : this.setType,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      reps: data.reps.present ? data.reps.value : this.reps,
      holdSeconds:
          data.holdSeconds.present ? data.holdSeconds.value : this.holdSeconds,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      rir: data.rir.present ? data.rir.value : this.rir,
      completed: data.completed.present ? data.completed.value : this.completed,
      loggedAtUtc:
          data.loggedAtUtc.present ? data.loggedAtUtc.value : this.loggedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GymSetLogRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('setIndex: $setIndex, ')
          ..write('setType: $setType, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('holdSeconds: $holdSeconds, ')
          ..write('rpe: $rpe, ')
          ..write('rir: $rir, ')
          ..write('completed: $completed, ')
          ..write('loggedAtUtc: $loggedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, exerciseId, setIndex, setType,
      weightKg, reps, holdSeconds, rpe, rir, completed, loggedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GymSetLogRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.setIndex == this.setIndex &&
          other.setType == this.setType &&
          other.weightKg == this.weightKg &&
          other.reps == this.reps &&
          other.holdSeconds == this.holdSeconds &&
          other.rpe == this.rpe &&
          other.rir == this.rir &&
          other.completed == this.completed &&
          other.loggedAtUtc == this.loggedAtUtc);
}

class GymSetLogsCompanion extends UpdateCompanion<GymSetLogRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> exerciseId;
  final Value<int> setIndex;
  final Value<String> setType;
  final Value<double> weightKg;
  final Value<int?> reps;
  final Value<int?> holdSeconds;
  final Value<double?> rpe;
  final Value<int?> rir;
  final Value<bool> completed;
  final Value<String> loggedAtUtc;
  final Value<int> rowid;
  const GymSetLogsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.setType = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.holdSeconds = const Value.absent(),
    this.rpe = const Value.absent(),
    this.rir = const Value.absent(),
    this.completed = const Value.absent(),
    this.loggedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GymSetLogsCompanion.insert({
    required String id,
    required String sessionId,
    required String exerciseId,
    required int setIndex,
    this.setType = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.holdSeconds = const Value.absent(),
    this.rpe = const Value.absent(),
    this.rir = const Value.absent(),
    this.completed = const Value.absent(),
    required String loggedAtUtc,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        exerciseId = Value(exerciseId),
        setIndex = Value(setIndex),
        loggedAtUtc = Value(loggedAtUtc);
  static Insertable<GymSetLogRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? exerciseId,
    Expression<int>? setIndex,
    Expression<String>? setType,
    Expression<double>? weightKg,
    Expression<int>? reps,
    Expression<int>? holdSeconds,
    Expression<double>? rpe,
    Expression<int>? rir,
    Expression<bool>? completed,
    Expression<String>? loggedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (setIndex != null) 'set_index': setIndex,
      if (setType != null) 'set_type': setType,
      if (weightKg != null) 'weight_kg': weightKg,
      if (reps != null) 'reps': reps,
      if (holdSeconds != null) 'hold_seconds': holdSeconds,
      if (rpe != null) 'rpe': rpe,
      if (rir != null) 'rir': rir,
      if (completed != null) 'completed': completed,
      if (loggedAtUtc != null) 'logged_at_utc': loggedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GymSetLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? exerciseId,
      Value<int>? setIndex,
      Value<String>? setType,
      Value<double>? weightKg,
      Value<int?>? reps,
      Value<int?>? holdSeconds,
      Value<double?>? rpe,
      Value<int?>? rir,
      Value<bool>? completed,
      Value<String>? loggedAtUtc,
      Value<int>? rowid}) {
    return GymSetLogsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      setIndex: setIndex ?? this.setIndex,
      setType: setType ?? this.setType,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      rpe: rpe ?? this.rpe,
      rir: rir ?? this.rir,
      completed: completed ?? this.completed,
      loggedAtUtc: loggedAtUtc ?? this.loggedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (setIndex.present) {
      map['set_index'] = Variable<int>(setIndex.value);
    }
    if (setType.present) {
      map['set_type'] = Variable<String>(setType.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (holdSeconds.present) {
      map['hold_seconds'] = Variable<int>(holdSeconds.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<double>(rpe.value);
    }
    if (rir.present) {
      map['rir'] = Variable<int>(rir.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (loggedAtUtc.present) {
      map['logged_at_utc'] = Variable<String>(loggedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GymSetLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('setIndex: $setIndex, ')
          ..write('setType: $setType, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('holdSeconds: $holdSeconds, ')
          ..write('rpe: $rpe, ')
          ..write('rir: $rir, ')
          ..write('completed: $completed, ')
          ..write('loggedAtUtc: $loggedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $Gym1RmHistoriesTable extends Gym1RmHistories
    with TableInfo<$Gym1RmHistoriesTable, Gym1RmHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $Gym1RmHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exerciseIdMeta =
      const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
      'exercise_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES gym_exercises (id)'));
  static const VerificationMeta _calculated1RmMeta =
      const VerificationMeta('calculated1Rm');
  @override
  late final GeneratedColumn<double> calculated1Rm = GeneratedColumn<double>(
      'calculated_1rm', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, exerciseId, calculated1Rm, weightKg, reps, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gym1_rm_histories';
  @override
  VerificationContext validateIntegrity(Insertable<Gym1RmHistoryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
          _exerciseIdMeta,
          exerciseId.isAcceptableOrUnknown(
              data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('calculated_1rm')) {
      context.handle(
          _calculated1RmMeta,
          calculated1Rm.isAcceptableOrUnknown(
              data['calculated_1rm']!, _calculated1RmMeta));
    } else if (isInserting) {
      context.missing(_calculated1RmMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Gym1RmHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Gym1RmHistoryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      exerciseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exercise_id'])!,
      calculated1Rm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calculated_1rm'])!,
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg'])!,
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
    );
  }

  @override
  $Gym1RmHistoriesTable createAlias(String alias) {
    return $Gym1RmHistoriesTable(attachedDatabase, alias);
  }
}

class Gym1RmHistoryRow extends DataClass
    implements Insertable<Gym1RmHistoryRow> {
  final String id;
  final String exerciseId;
  final double calculated1Rm;
  final double weightKg;
  final int reps;
  final String date;
  const Gym1RmHistoryRow(
      {required this.id,
      required this.exerciseId,
      required this.calculated1Rm,
      required this.weightKg,
      required this.reps,
      required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['calculated_1rm'] = Variable<double>(calculated1Rm);
    map['weight_kg'] = Variable<double>(weightKg);
    map['reps'] = Variable<int>(reps);
    map['date'] = Variable<String>(date);
    return map;
  }

  Gym1RmHistoriesCompanion toCompanion(bool nullToAbsent) {
    return Gym1RmHistoriesCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      calculated1Rm: Value(calculated1Rm),
      weightKg: Value(weightKg),
      reps: Value(reps),
      date: Value(date),
    );
  }

  factory Gym1RmHistoryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Gym1RmHistoryRow(
      id: serializer.fromJson<String>(json['id']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      calculated1Rm: serializer.fromJson<double>(json['calculated1Rm']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      reps: serializer.fromJson<int>(json['reps']),
      date: serializer.fromJson<String>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'calculated1Rm': serializer.toJson<double>(calculated1Rm),
      'weightKg': serializer.toJson<double>(weightKg),
      'reps': serializer.toJson<int>(reps),
      'date': serializer.toJson<String>(date),
    };
  }

  Gym1RmHistoryRow copyWith(
          {String? id,
          String? exerciseId,
          double? calculated1Rm,
          double? weightKg,
          int? reps,
          String? date}) =>
      Gym1RmHistoryRow(
        id: id ?? this.id,
        exerciseId: exerciseId ?? this.exerciseId,
        calculated1Rm: calculated1Rm ?? this.calculated1Rm,
        weightKg: weightKg ?? this.weightKg,
        reps: reps ?? this.reps,
        date: date ?? this.date,
      );
  Gym1RmHistoryRow copyWithCompanion(Gym1RmHistoriesCompanion data) {
    return Gym1RmHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      calculated1Rm: data.calculated1Rm.present
          ? data.calculated1Rm.value
          : this.calculated1Rm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      reps: data.reps.present ? data.reps.value : this.reps,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Gym1RmHistoryRow(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('calculated1Rm: $calculated1Rm, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, exerciseId, calculated1Rm, weightKg, reps, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Gym1RmHistoryRow &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.calculated1Rm == this.calculated1Rm &&
          other.weightKg == this.weightKg &&
          other.reps == this.reps &&
          other.date == this.date);
}

class Gym1RmHistoriesCompanion extends UpdateCompanion<Gym1RmHistoryRow> {
  final Value<String> id;
  final Value<String> exerciseId;
  final Value<double> calculated1Rm;
  final Value<double> weightKg;
  final Value<int> reps;
  final Value<String> date;
  final Value<int> rowid;
  const Gym1RmHistoriesCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.calculated1Rm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.date = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  Gym1RmHistoriesCompanion.insert({
    required String id,
    required String exerciseId,
    required double calculated1Rm,
    required double weightKg,
    required int reps,
    required String date,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        exerciseId = Value(exerciseId),
        calculated1Rm = Value(calculated1Rm),
        weightKg = Value(weightKg),
        reps = Value(reps),
        date = Value(date);
  static Insertable<Gym1RmHistoryRow> custom({
    Expression<String>? id,
    Expression<String>? exerciseId,
    Expression<double>? calculated1Rm,
    Expression<double>? weightKg,
    Expression<int>? reps,
    Expression<String>? date,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (calculated1Rm != null) 'calculated_1rm': calculated1Rm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (reps != null) 'reps': reps,
      if (date != null) 'date': date,
      if (rowid != null) 'rowid': rowid,
    });
  }

  Gym1RmHistoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? exerciseId,
      Value<double>? calculated1Rm,
      Value<double>? weightKg,
      Value<int>? reps,
      Value<String>? date,
      Value<int>? rowid}) {
    return Gym1RmHistoriesCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      calculated1Rm: calculated1Rm ?? this.calculated1Rm,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      date: date ?? this.date,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (calculated1Rm.present) {
      map['calculated_1rm'] = Variable<double>(calculated1Rm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('Gym1RmHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('calculated1Rm: $calculated1Rm, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('date: $date, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $ConsumedFoodsTable consumedFoods = $ConsumedFoodsTable(this);
  late final $SavedMealsTable savedMeals = $SavedMealsTable(this);
  late final $SavedMealIngredientsTable savedMealIngredients =
      $SavedMealIngredientsTable(this);
  late final $FavoriteFoodsTable favoriteFoods = $FavoriteFoodsTable(this);
  late final $FoodUsageTable foodUsage = $FoodUsageTable(this);
  late final $OfflineQueueTable offlineQueue = $OfflineQueueTable(this);
  late final $LocalFoodsTable localFoods = $LocalFoodsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $WeightEntriesTable weightEntries = $WeightEntriesTable(this);
  late final $AppDatabaseMetadataTable appDatabaseMetadata =
      $AppDatabaseMetadataTable(this);
  late final $HealthSourcesTable healthSources = $HealthSourcesTable(this);
  late final $HealthSyncStatesTable healthSyncStates =
      $HealthSyncStatesTable(this);
  late final $HealthRecordsTable healthRecords = $HealthRecordsTable(this);
  late final $DailyHealthAggregatesTable dailyHealthAggregates =
      $DailyHealthAggregatesTable(this);
  late final $SleepSessionsTable sleepSessions = $SleepSessionsTable(this);
  late final $WorkoutSessionsTable workoutSessions =
      $WorkoutSessionsTable(this);
  late final $WorkoutRoutePointsTable workoutRoutePoints =
      $WorkoutRoutePointsTable(this);
  late final $CycleProfilesTable cycleProfiles = $CycleProfilesTable(this);
  late final $PeriodEntriesTable periodEntries = $PeriodEntriesTable(this);
  late final $CycleDailyLogsTable cycleDailyLogs = $CycleDailyLogsTable(this);
  late final $SymptomDefinitionsTable symptomDefinitions =
      $SymptomDefinitionsTable(this);
  late final $SymptomLogsTable symptomLogs = $SymptomLogsTable(this);
  late final $CyclePredictionsTable cyclePredictions =
      $CyclePredictionsTable(this);
  late final $NotificationPreferencesTable notificationPreferences =
      $NotificationPreferencesTable(this);
  late final $BackupManifestsTable backupManifests =
      $BackupManifestsTable(this);
  late final $GymExercisesTable gymExercises = $GymExercisesTable(this);
  late final $GymWorkoutPlansTable gymWorkoutPlans =
      $GymWorkoutPlansTable(this);
  late final $GymPlanRoutinesTable gymPlanRoutines =
      $GymPlanRoutinesTable(this);
  late final $GymPlanRoutineExercisesTable gymPlanRoutineExercises =
      $GymPlanRoutineExercisesTable(this);
  late final $GymWorkoutSessionsTable gymWorkoutSessions =
      $GymWorkoutSessionsTable(this);
  late final $GymSetLogsTable gymSetLogs = $GymSetLogsTable(this);
  late final $Gym1RmHistoriesTable gym1RmHistories =
      $Gym1RmHistoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        goals,
        consumedFoods,
        savedMeals,
        savedMealIngredients,
        favoriteFoods,
        foodUsage,
        offlineQueue,
        localFoods,
        appSettings,
        weightEntries,
        appDatabaseMetadata,
        healthSources,
        healthSyncStates,
        healthRecords,
        dailyHealthAggregates,
        sleepSessions,
        workoutSessions,
        workoutRoutePoints,
        cycleProfiles,
        periodEntries,
        cycleDailyLogs,
        symptomDefinitions,
        symptomLogs,
        cyclePredictions,
        notificationPreferences,
        backupManifests,
        gymExercises,
        gymWorkoutPlans,
        gymPlanRoutines,
        gymPlanRoutineExercises,
        gymWorkoutSessions,
        gymSetLogs,
        gym1RmHistories
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('SavedMeals',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('SavedMealIngredients', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('gym_workout_plans',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('gym_plan_routines', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('gym_plan_routines',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('gym_plan_routine_exercises',
                  kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('gym_workout_sessions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('gym_set_logs', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  Value<int> id,
  required int dailyCalories,
  required int carbPercentage,
  required int proteinPercentage,
  required int fatPercentage,
  required int sugarPercentage,
  Value<int> autoCalorieMode,
  Value<double> customPercentPerMonth,
  Value<int> useCustomStartCalories,
  Value<int> userStartCalories,
  Value<int> userAge,
  Value<double> userActivityLevel,
  Value<String?> lastMondayCheck,
  Value<int> firstWeekInitialized,
  Value<double> userHeight,
  Value<int> useProteinPerKg,
  Value<double> proteinPerKg,
  Value<double?> targetWeight,
  Value<String?> targetDate,
  Value<double?> targetWeeklyChange,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<int> id,
  Value<int> dailyCalories,
  Value<int> carbPercentage,
  Value<int> proteinPercentage,
  Value<int> fatPercentage,
  Value<int> sugarPercentage,
  Value<int> autoCalorieMode,
  Value<double> customPercentPerMonth,
  Value<int> useCustomStartCalories,
  Value<int> userStartCalories,
  Value<int> userAge,
  Value<double> userActivityLevel,
  Value<String?> lastMondayCheck,
  Value<int> firstWeekInitialized,
  Value<double> userHeight,
  Value<int> useProteinPerKg,
  Value<double> proteinPerKg,
  Value<double?> targetWeight,
  Value<String?> targetDate,
  Value<double?> targetWeeklyChange,
});

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dailyCalories => $composableBuilder(
      column: $table.dailyCalories, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get carbPercentage => $composableBuilder(
      column: $table.carbPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get proteinPercentage => $composableBuilder(
      column: $table.proteinPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fatPercentage => $composableBuilder(
      column: $table.fatPercentage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sugarPercentage => $composableBuilder(
      column: $table.sugarPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get autoCalorieMode => $composableBuilder(
      column: $table.autoCalorieMode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get customPercentPerMonth => $composableBuilder(
      column: $table.customPercentPerMonth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get useCustomStartCalories => $composableBuilder(
      column: $table.useCustomStartCalories,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userStartCalories => $composableBuilder(
      column: $table.userStartCalories,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userAge => $composableBuilder(
      column: $table.userAge, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get userActivityLevel => $composableBuilder(
      column: $table.userActivityLevel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastMondayCheck => $composableBuilder(
      column: $table.lastMondayCheck,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get firstWeekInitialized => $composableBuilder(
      column: $table.firstWeekInitialized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get userHeight => $composableBuilder(
      column: $table.userHeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get useProteinPerKg => $composableBuilder(
      column: $table.useProteinPerKg,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteinPerKg => $composableBuilder(
      column: $table.proteinPerKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetWeight => $composableBuilder(
      column: $table.targetWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetWeeklyChange => $composableBuilder(
      column: $table.targetWeeklyChange,
      builder: (column) => ColumnFilters(column));
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dailyCalories => $composableBuilder(
      column: $table.dailyCalories,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get carbPercentage => $composableBuilder(
      column: $table.carbPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get proteinPercentage => $composableBuilder(
      column: $table.proteinPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fatPercentage => $composableBuilder(
      column: $table.fatPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sugarPercentage => $composableBuilder(
      column: $table.sugarPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get autoCalorieMode => $composableBuilder(
      column: $table.autoCalorieMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get customPercentPerMonth => $composableBuilder(
      column: $table.customPercentPerMonth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get useCustomStartCalories => $composableBuilder(
      column: $table.useCustomStartCalories,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userStartCalories => $composableBuilder(
      column: $table.userStartCalories,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userAge => $composableBuilder(
      column: $table.userAge, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get userActivityLevel => $composableBuilder(
      column: $table.userActivityLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastMondayCheck => $composableBuilder(
      column: $table.lastMondayCheck,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get firstWeekInitialized => $composableBuilder(
      column: $table.firstWeekInitialized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get userHeight => $composableBuilder(
      column: $table.userHeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get useProteinPerKg => $composableBuilder(
      column: $table.useProteinPerKg,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteinPerKg => $composableBuilder(
      column: $table.proteinPerKg,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetWeight => $composableBuilder(
      column: $table.targetWeight,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetWeeklyChange => $composableBuilder(
      column: $table.targetWeeklyChange,
      builder: (column) => ColumnOrderings(column));
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dailyCalories => $composableBuilder(
      column: $table.dailyCalories, builder: (column) => column);

  GeneratedColumn<int> get carbPercentage => $composableBuilder(
      column: $table.carbPercentage, builder: (column) => column);

  GeneratedColumn<int> get proteinPercentage => $composableBuilder(
      column: $table.proteinPercentage, builder: (column) => column);

  GeneratedColumn<int> get fatPercentage => $composableBuilder(
      column: $table.fatPercentage, builder: (column) => column);

  GeneratedColumn<int> get sugarPercentage => $composableBuilder(
      column: $table.sugarPercentage, builder: (column) => column);

  GeneratedColumn<int> get autoCalorieMode => $composableBuilder(
      column: $table.autoCalorieMode, builder: (column) => column);

  GeneratedColumn<double> get customPercentPerMonth => $composableBuilder(
      column: $table.customPercentPerMonth, builder: (column) => column);

  GeneratedColumn<int> get useCustomStartCalories => $composableBuilder(
      column: $table.useCustomStartCalories, builder: (column) => column);

  GeneratedColumn<int> get userStartCalories => $composableBuilder(
      column: $table.userStartCalories, builder: (column) => column);

  GeneratedColumn<int> get userAge =>
      $composableBuilder(column: $table.userAge, builder: (column) => column);

  GeneratedColumn<double> get userActivityLevel => $composableBuilder(
      column: $table.userActivityLevel, builder: (column) => column);

  GeneratedColumn<String> get lastMondayCheck => $composableBuilder(
      column: $table.lastMondayCheck, builder: (column) => column);

  GeneratedColumn<int> get firstWeekInitialized => $composableBuilder(
      column: $table.firstWeekInitialized, builder: (column) => column);

  GeneratedColumn<double> get userHeight => $composableBuilder(
      column: $table.userHeight, builder: (column) => column);

  GeneratedColumn<int> get useProteinPerKg => $composableBuilder(
      column: $table.useProteinPerKg, builder: (column) => column);

  GeneratedColumn<double> get proteinPerKg => $composableBuilder(
      column: $table.proteinPerKg, builder: (column) => column);

  GeneratedColumn<double> get targetWeight => $composableBuilder(
      column: $table.targetWeight, builder: (column) => column);

  GeneratedColumn<String> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => column);

  GeneratedColumn<double> get targetWeeklyChange => $composableBuilder(
      column: $table.targetWeeklyChange, builder: (column) => column);
}

class $$GoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalsTable,
    GoalRow,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (GoalRow, BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>),
    GoalRow,
    PrefetchHooks Function()> {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> dailyCalories = const Value.absent(),
            Value<int> carbPercentage = const Value.absent(),
            Value<int> proteinPercentage = const Value.absent(),
            Value<int> fatPercentage = const Value.absent(),
            Value<int> sugarPercentage = const Value.absent(),
            Value<int> autoCalorieMode = const Value.absent(),
            Value<double> customPercentPerMonth = const Value.absent(),
            Value<int> useCustomStartCalories = const Value.absent(),
            Value<int> userStartCalories = const Value.absent(),
            Value<int> userAge = const Value.absent(),
            Value<double> userActivityLevel = const Value.absent(),
            Value<String?> lastMondayCheck = const Value.absent(),
            Value<int> firstWeekInitialized = const Value.absent(),
            Value<double> userHeight = const Value.absent(),
            Value<int> useProteinPerKg = const Value.absent(),
            Value<double> proteinPerKg = const Value.absent(),
            Value<double?> targetWeight = const Value.absent(),
            Value<String?> targetDate = const Value.absent(),
            Value<double?> targetWeeklyChange = const Value.absent(),
          }) =>
              GoalsCompanion(
            id: id,
            dailyCalories: dailyCalories,
            carbPercentage: carbPercentage,
            proteinPercentage: proteinPercentage,
            fatPercentage: fatPercentage,
            sugarPercentage: sugarPercentage,
            autoCalorieMode: autoCalorieMode,
            customPercentPerMonth: customPercentPerMonth,
            useCustomStartCalories: useCustomStartCalories,
            userStartCalories: userStartCalories,
            userAge: userAge,
            userActivityLevel: userActivityLevel,
            lastMondayCheck: lastMondayCheck,
            firstWeekInitialized: firstWeekInitialized,
            userHeight: userHeight,
            useProteinPerKg: useProteinPerKg,
            proteinPerKg: proteinPerKg,
            targetWeight: targetWeight,
            targetDate: targetDate,
            targetWeeklyChange: targetWeeklyChange,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int dailyCalories,
            required int carbPercentage,
            required int proteinPercentage,
            required int fatPercentage,
            required int sugarPercentage,
            Value<int> autoCalorieMode = const Value.absent(),
            Value<double> customPercentPerMonth = const Value.absent(),
            Value<int> useCustomStartCalories = const Value.absent(),
            Value<int> userStartCalories = const Value.absent(),
            Value<int> userAge = const Value.absent(),
            Value<double> userActivityLevel = const Value.absent(),
            Value<String?> lastMondayCheck = const Value.absent(),
            Value<int> firstWeekInitialized = const Value.absent(),
            Value<double> userHeight = const Value.absent(),
            Value<int> useProteinPerKg = const Value.absent(),
            Value<double> proteinPerKg = const Value.absent(),
            Value<double?> targetWeight = const Value.absent(),
            Value<String?> targetDate = const Value.absent(),
            Value<double?> targetWeeklyChange = const Value.absent(),
          }) =>
              GoalsCompanion.insert(
            id: id,
            dailyCalories: dailyCalories,
            carbPercentage: carbPercentage,
            proteinPercentage: proteinPercentage,
            fatPercentage: fatPercentage,
            sugarPercentage: sugarPercentage,
            autoCalorieMode: autoCalorieMode,
            customPercentPerMonth: customPercentPerMonth,
            useCustomStartCalories: useCustomStartCalories,
            userStartCalories: userStartCalories,
            userAge: userAge,
            userActivityLevel: userActivityLevel,
            lastMondayCheck: lastMondayCheck,
            firstWeekInitialized: firstWeekInitialized,
            userHeight: userHeight,
            useProteinPerKg: useProteinPerKg,
            proteinPerKg: proteinPerKg,
            targetWeight: targetWeight,
            targetDate: targetDate,
            targetWeeklyChange: targetWeeklyChange,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$GoalsTable, GoalRow>(table),
                    BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GoalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalsTable,
    GoalRow,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (GoalRow, BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>),
    GoalRow,
    PrefetchHooks Function()>;
typedef $$ConsumedFoodsTableCreateCompanionBuilder = ConsumedFoodsCompanion
    Function({
  Value<int> id,
  required String date,
  required String mealName,
  required int foodId,
  required int quantity,
  Value<String?> uuid,
});
typedef $$ConsumedFoodsTableUpdateCompanionBuilder = ConsumedFoodsCompanion
    Function({
  Value<int> id,
  Value<String> date,
  Value<String> mealName,
  Value<int> foodId,
  Value<int> quantity,
  Value<String?> uuid,
});

class $$ConsumedFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $ConsumedFoodsTable> {
  $$ConsumedFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mealName => $composableBuilder(
      column: $table.mealName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get foodId => $composableBuilder(
      column: $table.foodId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));
}

class $$ConsumedFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConsumedFoodsTable> {
  $$ConsumedFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mealName => $composableBuilder(
      column: $table.mealName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get foodId => $composableBuilder(
      column: $table.foodId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));
}

class $$ConsumedFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConsumedFoodsTable> {
  $$ConsumedFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get mealName =>
      $composableBuilder(column: $table.mealName, builder: (column) => column);

  GeneratedColumn<int> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);
}

class $$ConsumedFoodsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConsumedFoodsTable,
    ConsumedFoodRow,
    $$ConsumedFoodsTableFilterComposer,
    $$ConsumedFoodsTableOrderingComposer,
    $$ConsumedFoodsTableAnnotationComposer,
    $$ConsumedFoodsTableCreateCompanionBuilder,
    $$ConsumedFoodsTableUpdateCompanionBuilder,
    (
      ConsumedFoodRow,
      BaseReferences<_$AppDatabase, $ConsumedFoodsTable, ConsumedFoodRow>
    ),
    ConsumedFoodRow,
    PrefetchHooks Function()> {
  $$ConsumedFoodsTableTableManager(_$AppDatabase db, $ConsumedFoodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsumedFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsumedFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConsumedFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> mealName = const Value.absent(),
            Value<int> foodId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String?> uuid = const Value.absent(),
          }) =>
              ConsumedFoodsCompanion(
            id: id,
            date: date,
            mealName: mealName,
            foodId: foodId,
            quantity: quantity,
            uuid: uuid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String date,
            required String mealName,
            required int foodId,
            required int quantity,
            Value<String?> uuid = const Value.absent(),
          }) =>
              ConsumedFoodsCompanion.insert(
            id: id,
            date: date,
            mealName: mealName,
            foodId: foodId,
            quantity: quantity,
            uuid: uuid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ConsumedFoodsTable, ConsumedFoodRow>(table),
                    BaseReferences<_$AppDatabase, $ConsumedFoodsTable,
                        ConsumedFoodRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConsumedFoodsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConsumedFoodsTable,
    ConsumedFoodRow,
    $$ConsumedFoodsTableFilterComposer,
    $$ConsumedFoodsTableOrderingComposer,
    $$ConsumedFoodsTableAnnotationComposer,
    $$ConsumedFoodsTableCreateCompanionBuilder,
    $$ConsumedFoodsTableUpdateCompanionBuilder,
    (
      ConsumedFoodRow,
      BaseReferences<_$AppDatabase, $ConsumedFoodsTable, ConsumedFoodRow>
    ),
    ConsumedFoodRow,
    PrefetchHooks Function()>;
typedef $$SavedMealsTableCreateCompanionBuilder = SavedMealsCompanion Function({
  Value<int> id,
  required String name,
  required String defaultMealName,
  required String createdAt,
  Value<int?> recipeTotalWeight,
  Value<String?> uuid,
});
typedef $$SavedMealsTableUpdateCompanionBuilder = SavedMealsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> defaultMealName,
  Value<String> createdAt,
  Value<int?> recipeTotalWeight,
  Value<String?> uuid,
});

final class $$SavedMealsTableReferences
    extends BaseReferences<_$AppDatabase, $SavedMealsTable, SavedMealRow> {
  $$SavedMealsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SavedMealIngredientsTable,
      List<SavedMealIngredientRow>> _savedMealIngredientsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.savedMealIngredients,
          aliasName: 'SavedMeals__id__SavedMealIngredients__saved_meal_id');

  $$SavedMealIngredientsTableProcessedTableManager
      get savedMealIngredientsRefs {
    final manager = $$SavedMealIngredientsTableTableManager(
            $_db, $_db.savedMealIngredients)
        .filter((f) => f.savedMealId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_savedMealIngredientsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SavedMealsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedMealsTable> {
  $$SavedMealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultMealName => $composableBuilder(
      column: $table.defaultMealName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recipeTotalWeight => $composableBuilder(
      column: $table.recipeTotalWeight,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  Expression<bool> savedMealIngredientsRefs(
      Expression<bool> Function($$SavedMealIngredientsTableFilterComposer f)
          f) {
    final $$SavedMealIngredientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.savedMealIngredients,
        getReferencedColumn: (t) => t.savedMealId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavedMealIngredientsTableFilterComposer(
              $db: $db,
              $table: $db.savedMealIngredients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SavedMealsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedMealsTable> {
  $$SavedMealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultMealName => $composableBuilder(
      column: $table.defaultMealName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recipeTotalWeight => $composableBuilder(
      column: $table.recipeTotalWeight,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));
}

class $$SavedMealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedMealsTable> {
  $$SavedMealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get defaultMealName => $composableBuilder(
      column: $table.defaultMealName, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get recipeTotalWeight => $composableBuilder(
      column: $table.recipeTotalWeight, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  Expression<T> savedMealIngredientsRefs<T extends Object>(
      Expression<T> Function($$SavedMealIngredientsTableAnnotationComposer a)
          f) {
    final $$SavedMealIngredientsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.savedMealIngredients,
            getReferencedColumn: (t) => t.savedMealId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SavedMealIngredientsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.savedMealIngredients,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SavedMealsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SavedMealsTable,
    SavedMealRow,
    $$SavedMealsTableFilterComposer,
    $$SavedMealsTableOrderingComposer,
    $$SavedMealsTableAnnotationComposer,
    $$SavedMealsTableCreateCompanionBuilder,
    $$SavedMealsTableUpdateCompanionBuilder,
    (SavedMealRow, $$SavedMealsTableReferences),
    SavedMealRow,
    PrefetchHooks Function({bool savedMealIngredientsRefs})> {
  $$SavedMealsTableTableManager(_$AppDatabase db, $SavedMealsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedMealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedMealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedMealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> defaultMealName = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int?> recipeTotalWeight = const Value.absent(),
            Value<String?> uuid = const Value.absent(),
          }) =>
              SavedMealsCompanion(
            id: id,
            name: name,
            defaultMealName: defaultMealName,
            createdAt: createdAt,
            recipeTotalWeight: recipeTotalWeight,
            uuid: uuid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String defaultMealName,
            required String createdAt,
            Value<int?> recipeTotalWeight = const Value.absent(),
            Value<String?> uuid = const Value.absent(),
          }) =>
              SavedMealsCompanion.insert(
            id: id,
            name: name,
            defaultMealName: defaultMealName,
            createdAt: createdAt,
            recipeTotalWeight: recipeTotalWeight,
            uuid: uuid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SavedMealsTable, SavedMealRow>(table),
                    $$SavedMealsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({savedMealIngredientsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (savedMealIngredientsRefs) db.savedMealIngredients
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (savedMealIngredientsRefs)
                    await $_getPrefetchedData<SavedMealRow, $SavedMealsTable,
                            SavedMealIngredientRow>(
                        currentTable: table,
                        referencedTable: $$SavedMealsTableReferences
                            ._savedMealIngredientsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SavedMealsTableReferences(db, table, p0)
                                .savedMealIngredientsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.savedMealId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SavedMealsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SavedMealsTable,
    SavedMealRow,
    $$SavedMealsTableFilterComposer,
    $$SavedMealsTableOrderingComposer,
    $$SavedMealsTableAnnotationComposer,
    $$SavedMealsTableCreateCompanionBuilder,
    $$SavedMealsTableUpdateCompanionBuilder,
    (SavedMealRow, $$SavedMealsTableReferences),
    SavedMealRow,
    PrefetchHooks Function({bool savedMealIngredientsRefs})>;
typedef $$SavedMealIngredientsTableCreateCompanionBuilder
    = SavedMealIngredientsCompanion Function({
  Value<int> id,
  required int savedMealId,
  required int foodId,
  required int quantity,
});
typedef $$SavedMealIngredientsTableUpdateCompanionBuilder
    = SavedMealIngredientsCompanion Function({
  Value<int> id,
  Value<int> savedMealId,
  Value<int> foodId,
  Value<int> quantity,
});

final class $$SavedMealIngredientsTableReferences extends BaseReferences<
    _$AppDatabase, $SavedMealIngredientsTable, SavedMealIngredientRow> {
  $$SavedMealIngredientsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SavedMealsTable _savedMealIdTable(_$AppDatabase db) => db.savedMeals
      .createAlias('SavedMealIngredients__saved_meal_id__SavedMeals__id');

  $$SavedMealsTableProcessedTableManager get savedMealId {
    final $_column = $_itemColumn<int>('saved_meal_id')!;

    final manager = $$SavedMealsTableTableManager($_db, $_db.savedMeals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_savedMealIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SavedMealIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedMealIngredientsTable> {
  $$SavedMealIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get foodId => $composableBuilder(
      column: $table.foodId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  $$SavedMealsTableFilterComposer get savedMealId {
    final $$SavedMealsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.savedMealId,
        referencedTable: $db.savedMeals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavedMealsTableFilterComposer(
              $db: $db,
              $table: $db.savedMeals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SavedMealIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedMealIngredientsTable> {
  $$SavedMealIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get foodId => $composableBuilder(
      column: $table.foodId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  $$SavedMealsTableOrderingComposer get savedMealId {
    final $$SavedMealsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.savedMealId,
        referencedTable: $db.savedMeals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavedMealsTableOrderingComposer(
              $db: $db,
              $table: $db.savedMeals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SavedMealIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedMealIngredientsTable> {
  $$SavedMealIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  $$SavedMealsTableAnnotationComposer get savedMealId {
    final $$SavedMealsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.savedMealId,
        referencedTable: $db.savedMeals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavedMealsTableAnnotationComposer(
              $db: $db,
              $table: $db.savedMeals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SavedMealIngredientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SavedMealIngredientsTable,
    SavedMealIngredientRow,
    $$SavedMealIngredientsTableFilterComposer,
    $$SavedMealIngredientsTableOrderingComposer,
    $$SavedMealIngredientsTableAnnotationComposer,
    $$SavedMealIngredientsTableCreateCompanionBuilder,
    $$SavedMealIngredientsTableUpdateCompanionBuilder,
    (SavedMealIngredientRow, $$SavedMealIngredientsTableReferences),
    SavedMealIngredientRow,
    PrefetchHooks Function({bool savedMealId})> {
  $$SavedMealIngredientsTableTableManager(
      _$AppDatabase db, $SavedMealIngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedMealIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedMealIngredientsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedMealIngredientsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> savedMealId = const Value.absent(),
            Value<int> foodId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
          }) =>
              SavedMealIngredientsCompanion(
            id: id,
            savedMealId: savedMealId,
            foodId: foodId,
            quantity: quantity,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int savedMealId,
            required int foodId,
            required int quantity,
          }) =>
              SavedMealIngredientsCompanion.insert(
            id: id,
            savedMealId: savedMealId,
            foodId: foodId,
            quantity: quantity,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SavedMealIngredientsTable,
                        SavedMealIngredientRow>(table),
                    $$SavedMealIngredientsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({savedMealId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (savedMealId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.savedMealId,
                    referencedTable: $$SavedMealIngredientsTableReferences
                        ._savedMealIdTable(db),
                    referencedColumn: $$SavedMealIngredientsTableReferences
                        ._savedMealIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SavedMealIngredientsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SavedMealIngredientsTable,
        SavedMealIngredientRow,
        $$SavedMealIngredientsTableFilterComposer,
        $$SavedMealIngredientsTableOrderingComposer,
        $$SavedMealIngredientsTableAnnotationComposer,
        $$SavedMealIngredientsTableCreateCompanionBuilder,
        $$SavedMealIngredientsTableUpdateCompanionBuilder,
        (SavedMealIngredientRow, $$SavedMealIngredientsTableReferences),
        SavedMealIngredientRow,
        PrefetchHooks Function({bool savedMealId})>;
typedef $$FavoriteFoodsTableCreateCompanionBuilder = FavoriteFoodsCompanion
    Function({
  Value<int> foodId,
  required String createdAt,
});
typedef $$FavoriteFoodsTableUpdateCompanionBuilder = FavoriteFoodsCompanion
    Function({
  Value<int> foodId,
  Value<String> createdAt,
});

class $$FavoriteFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get foodId => $composableBuilder(
      column: $table.foodId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FavoriteFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get foodId => $composableBuilder(
      column: $table.foodId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FavoriteFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FavoriteFoodsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FavoriteFoodsTable,
    FavoriteFoodRow,
    $$FavoriteFoodsTableFilterComposer,
    $$FavoriteFoodsTableOrderingComposer,
    $$FavoriteFoodsTableAnnotationComposer,
    $$FavoriteFoodsTableCreateCompanionBuilder,
    $$FavoriteFoodsTableUpdateCompanionBuilder,
    (
      FavoriteFoodRow,
      BaseReferences<_$AppDatabase, $FavoriteFoodsTable, FavoriteFoodRow>
    ),
    FavoriteFoodRow,
    PrefetchHooks Function()> {
  $$FavoriteFoodsTableTableManager(_$AppDatabase db, $FavoriteFoodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> foodId = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
          }) =>
              FavoriteFoodsCompanion(
            foodId: foodId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> foodId = const Value.absent(),
            required String createdAt,
          }) =>
              FavoriteFoodsCompanion.insert(
            foodId: foodId,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FavoriteFoodsTable, FavoriteFoodRow>(table),
                    BaseReferences<_$AppDatabase, $FavoriteFoodsTable,
                        FavoriteFoodRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FavoriteFoodsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FavoriteFoodsTable,
    FavoriteFoodRow,
    $$FavoriteFoodsTableFilterComposer,
    $$FavoriteFoodsTableOrderingComposer,
    $$FavoriteFoodsTableAnnotationComposer,
    $$FavoriteFoodsTableCreateCompanionBuilder,
    $$FavoriteFoodsTableUpdateCompanionBuilder,
    (
      FavoriteFoodRow,
      BaseReferences<_$AppDatabase, $FavoriteFoodsTable, FavoriteFoodRow>
    ),
    FavoriteFoodRow,
    PrefetchHooks Function()>;
typedef $$FoodUsageTableCreateCompanionBuilder = FoodUsageCompanion Function({
  Value<int> foodId,
  required int lastUsedQuantity,
  required String lastUsedAt,
  Value<int> useCount,
});
typedef $$FoodUsageTableUpdateCompanionBuilder = FoodUsageCompanion Function({
  Value<int> foodId,
  Value<int> lastUsedQuantity,
  Value<String> lastUsedAt,
  Value<int> useCount,
});

class $$FoodUsageTableFilterComposer
    extends Composer<_$AppDatabase, $FoodUsageTable> {
  $$FoodUsageTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get foodId => $composableBuilder(
      column: $table.foodId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUsedQuantity => $composableBuilder(
      column: $table.lastUsedQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get useCount => $composableBuilder(
      column: $table.useCount, builder: (column) => ColumnFilters(column));
}

class $$FoodUsageTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodUsageTable> {
  $$FoodUsageTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get foodId => $composableBuilder(
      column: $table.foodId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUsedQuantity => $composableBuilder(
      column: $table.lastUsedQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get useCount => $composableBuilder(
      column: $table.useCount, builder: (column) => ColumnOrderings(column));
}

class $$FoodUsageTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodUsageTable> {
  $$FoodUsageTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<int> get lastUsedQuantity => $composableBuilder(
      column: $table.lastUsedQuantity, builder: (column) => column);

  GeneratedColumn<String> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => column);

  GeneratedColumn<int> get useCount =>
      $composableBuilder(column: $table.useCount, builder: (column) => column);
}

class $$FoodUsageTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FoodUsageTable,
    FoodUsageRow,
    $$FoodUsageTableFilterComposer,
    $$FoodUsageTableOrderingComposer,
    $$FoodUsageTableAnnotationComposer,
    $$FoodUsageTableCreateCompanionBuilder,
    $$FoodUsageTableUpdateCompanionBuilder,
    (
      FoodUsageRow,
      BaseReferences<_$AppDatabase, $FoodUsageTable, FoodUsageRow>
    ),
    FoodUsageRow,
    PrefetchHooks Function()> {
  $$FoodUsageTableTableManager(_$AppDatabase db, $FoodUsageTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodUsageTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodUsageTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodUsageTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> foodId = const Value.absent(),
            Value<int> lastUsedQuantity = const Value.absent(),
            Value<String> lastUsedAt = const Value.absent(),
            Value<int> useCount = const Value.absent(),
          }) =>
              FoodUsageCompanion(
            foodId: foodId,
            lastUsedQuantity: lastUsedQuantity,
            lastUsedAt: lastUsedAt,
            useCount: useCount,
          ),
          createCompanionCallback: ({
            Value<int> foodId = const Value.absent(),
            required int lastUsedQuantity,
            required String lastUsedAt,
            Value<int> useCount = const Value.absent(),
          }) =>
              FoodUsageCompanion.insert(
            foodId: foodId,
            lastUsedQuantity: lastUsedQuantity,
            lastUsedAt: lastUsedAt,
            useCount: useCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FoodUsageTable, FoodUsageRow>(table),
                    BaseReferences<_$AppDatabase, $FoodUsageTable,
                        FoodUsageRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FoodUsageTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FoodUsageTable,
    FoodUsageRow,
    $$FoodUsageTableFilterComposer,
    $$FoodUsageTableOrderingComposer,
    $$FoodUsageTableAnnotationComposer,
    $$FoodUsageTableCreateCompanionBuilder,
    $$FoodUsageTableUpdateCompanionBuilder,
    (
      FoodUsageRow,
      BaseReferences<_$AppDatabase, $FoodUsageTable, FoodUsageRow>
    ),
    FoodUsageRow,
    PrefetchHooks Function()>;
typedef $$OfflineQueueTableCreateCompanionBuilder = OfflineQueueCompanion
    Function({
  Value<int> id,
  required String actionType,
  required String payload,
  required String createdAt,
  Value<String?> lastError,
});
typedef $$OfflineQueueTableUpdateCompanionBuilder = OfflineQueueCompanion
    Function({
  Value<int> id,
  Value<String> actionType,
  Value<String> payload,
  Value<String> createdAt,
  Value<String?> lastError,
});

class $$OfflineQueueTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineQueueTable> {
  $$OfflineQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$OfflineQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineQueueTable> {
  $$OfflineQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$OfflineQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineQueueTable> {
  $$OfflineQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OfflineQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OfflineQueueTable,
    OfflineQueueRow,
    $$OfflineQueueTableFilterComposer,
    $$OfflineQueueTableOrderingComposer,
    $$OfflineQueueTableAnnotationComposer,
    $$OfflineQueueTableCreateCompanionBuilder,
    $$OfflineQueueTableUpdateCompanionBuilder,
    (
      OfflineQueueRow,
      BaseReferences<_$AppDatabase, $OfflineQueueTable, OfflineQueueRow>
    ),
    OfflineQueueRow,
    PrefetchHooks Function()> {
  $$OfflineQueueTableTableManager(_$AppDatabase db, $OfflineQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> actionType = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              OfflineQueueCompanion(
            id: id,
            actionType: actionType,
            payload: payload,
            createdAt: createdAt,
            lastError: lastError,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String actionType,
            required String payload,
            required String createdAt,
            Value<String?> lastError = const Value.absent(),
          }) =>
              OfflineQueueCompanion.insert(
            id: id,
            actionType: actionType,
            payload: payload,
            createdAt: createdAt,
            lastError: lastError,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$OfflineQueueTable, OfflineQueueRow>(table),
                    BaseReferences<_$AppDatabase, $OfflineQueueTable,
                        OfflineQueueRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OfflineQueueTable,
    OfflineQueueRow,
    $$OfflineQueueTableFilterComposer,
    $$OfflineQueueTableOrderingComposer,
    $$OfflineQueueTableAnnotationComposer,
    $$OfflineQueueTableCreateCompanionBuilder,
    $$OfflineQueueTableUpdateCompanionBuilder,
    (
      OfflineQueueRow,
      BaseReferences<_$AppDatabase, $OfflineQueueTable, OfflineQueueRow>
    ),
    OfflineQueueRow,
    PrefetchHooks Function()>;
typedef $$LocalFoodsTableCreateCompanionBuilder = LocalFoodsCompanion Function({
  Value<int> id,
  required String name,
  required String brand,
  Value<String?> barcode,
  required int caloriesPer100g,
  required double fatPer100g,
  required double carbsPer100g,
  required double sugarPer100g,
  required double proteinPer100g,
  required String createdAt,
  Value<int> lastUsedQuantity,
  Value<String> source,
  Value<int> isVerified,
  Value<String?> uuid,
});
typedef $$LocalFoodsTableUpdateCompanionBuilder = LocalFoodsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> brand,
  Value<String?> barcode,
  Value<int> caloriesPer100g,
  Value<double> fatPer100g,
  Value<double> carbsPer100g,
  Value<double> sugarPer100g,
  Value<double> proteinPer100g,
  Value<String> createdAt,
  Value<int> lastUsedQuantity,
  Value<String> source,
  Value<int> isVerified,
  Value<String?> uuid,
});

class $$LocalFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalFoodsTable> {
  $$LocalFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get caloriesPer100g => $composableBuilder(
      column: $table.caloriesPer100g,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fatPer100g => $composableBuilder(
      column: $table.fatPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbsPer100g => $composableBuilder(
      column: $table.carbsPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sugarPer100g => $composableBuilder(
      column: $table.sugarPer100g, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteinPer100g => $composableBuilder(
      column: $table.proteinPer100g,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUsedQuantity => $composableBuilder(
      column: $table.lastUsedQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));
}

class $$LocalFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalFoodsTable> {
  $$LocalFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get caloriesPer100g => $composableBuilder(
      column: $table.caloriesPer100g,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fatPer100g => $composableBuilder(
      column: $table.fatPer100g, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbsPer100g => $composableBuilder(
      column: $table.carbsPer100g,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sugarPer100g => $composableBuilder(
      column: $table.sugarPer100g,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteinPer100g => $composableBuilder(
      column: $table.proteinPer100g,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUsedQuantity => $composableBuilder(
      column: $table.lastUsedQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));
}

class $$LocalFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalFoodsTable> {
  $$LocalFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<int> get caloriesPer100g => $composableBuilder(
      column: $table.caloriesPer100g, builder: (column) => column);

  GeneratedColumn<double> get fatPer100g => $composableBuilder(
      column: $table.fatPer100g, builder: (column) => column);

  GeneratedColumn<double> get carbsPer100g => $composableBuilder(
      column: $table.carbsPer100g, builder: (column) => column);

  GeneratedColumn<double> get sugarPer100g => $composableBuilder(
      column: $table.sugarPer100g, builder: (column) => column);

  GeneratedColumn<double> get proteinPer100g => $composableBuilder(
      column: $table.proteinPer100g, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastUsedQuantity => $composableBuilder(
      column: $table.lastUsedQuantity, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);
}

class $$LocalFoodsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalFoodsTable,
    LocalFoodRow,
    $$LocalFoodsTableFilterComposer,
    $$LocalFoodsTableOrderingComposer,
    $$LocalFoodsTableAnnotationComposer,
    $$LocalFoodsTableCreateCompanionBuilder,
    $$LocalFoodsTableUpdateCompanionBuilder,
    (
      LocalFoodRow,
      BaseReferences<_$AppDatabase, $LocalFoodsTable, LocalFoodRow>
    ),
    LocalFoodRow,
    PrefetchHooks Function()> {
  $$LocalFoodsTableTableManager(_$AppDatabase db, $LocalFoodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> brand = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<int> caloriesPer100g = const Value.absent(),
            Value<double> fatPer100g = const Value.absent(),
            Value<double> carbsPer100g = const Value.absent(),
            Value<double> sugarPer100g = const Value.absent(),
            Value<double> proteinPer100g = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> lastUsedQuantity = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<int> isVerified = const Value.absent(),
            Value<String?> uuid = const Value.absent(),
          }) =>
              LocalFoodsCompanion(
            id: id,
            name: name,
            brand: brand,
            barcode: barcode,
            caloriesPer100g: caloriesPer100g,
            fatPer100g: fatPer100g,
            carbsPer100g: carbsPer100g,
            sugarPer100g: sugarPer100g,
            proteinPer100g: proteinPer100g,
            createdAt: createdAt,
            lastUsedQuantity: lastUsedQuantity,
            source: source,
            isVerified: isVerified,
            uuid: uuid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String brand,
            Value<String?> barcode = const Value.absent(),
            required int caloriesPer100g,
            required double fatPer100g,
            required double carbsPer100g,
            required double sugarPer100g,
            required double proteinPer100g,
            required String createdAt,
            Value<int> lastUsedQuantity = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<int> isVerified = const Value.absent(),
            Value<String?> uuid = const Value.absent(),
          }) =>
              LocalFoodsCompanion.insert(
            id: id,
            name: name,
            brand: brand,
            barcode: barcode,
            caloriesPer100g: caloriesPer100g,
            fatPer100g: fatPer100g,
            carbsPer100g: carbsPer100g,
            sugarPer100g: sugarPer100g,
            proteinPer100g: proteinPer100g,
            createdAt: createdAt,
            lastUsedQuantity: lastUsedQuantity,
            source: source,
            isVerified: isVerified,
            uuid: uuid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LocalFoodsTable, LocalFoodRow>(table),
                    BaseReferences<_$AppDatabase, $LocalFoodsTable,
                        LocalFoodRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalFoodsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalFoodsTable,
    LocalFoodRow,
    $$LocalFoodsTableFilterComposer,
    $$LocalFoodsTableOrderingComposer,
    $$LocalFoodsTableAnnotationComposer,
    $$LocalFoodsTableCreateCompanionBuilder,
    $$LocalFoodsTableUpdateCompanionBuilder,
    (
      LocalFoodRow,
      BaseReferences<_$AppDatabase, $LocalFoodsTable, LocalFoodRow>
    ),
    LocalFoodRow,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<int> id,
  Value<int> darkMode,
  Value<int> reminderWeighEnabled,
  Value<String> reminderWeighTime,
  Value<String> reminderWeighTime2,
  Value<int> reminderSupplementEnabled,
  Value<String> reminderSupplementTime,
  Value<String> reminderSupplementTime2,
  Value<int> reminderMealsEnabled,
  Value<String> reminderBreakfast,
  Value<String> reminderLunch,
  Value<String> reminderDinner,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<int> id,
  Value<int> darkMode,
  Value<int> reminderWeighEnabled,
  Value<String> reminderWeighTime,
  Value<String> reminderWeighTime2,
  Value<int> reminderSupplementEnabled,
  Value<String> reminderSupplementTime,
  Value<String> reminderSupplementTime2,
  Value<int> reminderMealsEnabled,
  Value<String> reminderBreakfast,
  Value<String> reminderLunch,
  Value<String> reminderDinner,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get darkMode => $composableBuilder(
      column: $table.darkMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderWeighEnabled => $composableBuilder(
      column: $table.reminderWeighEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderWeighTime => $composableBuilder(
      column: $table.reminderWeighTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderWeighTime2 => $composableBuilder(
      column: $table.reminderWeighTime2,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderSupplementEnabled => $composableBuilder(
      column: $table.reminderSupplementEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderSupplementTime => $composableBuilder(
      column: $table.reminderSupplementTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderSupplementTime2 => $composableBuilder(
      column: $table.reminderSupplementTime2,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderMealsEnabled => $composableBuilder(
      column: $table.reminderMealsEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderBreakfast => $composableBuilder(
      column: $table.reminderBreakfast,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderLunch => $composableBuilder(
      column: $table.reminderLunch, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderDinner => $composableBuilder(
      column: $table.reminderDinner,
      builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get darkMode => $composableBuilder(
      column: $table.darkMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderWeighEnabled => $composableBuilder(
      column: $table.reminderWeighEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderWeighTime => $composableBuilder(
      column: $table.reminderWeighTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderWeighTime2 => $composableBuilder(
      column: $table.reminderWeighTime2,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderSupplementEnabled => $composableBuilder(
      column: $table.reminderSupplementEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderSupplementTime => $composableBuilder(
      column: $table.reminderSupplementTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderSupplementTime2 => $composableBuilder(
      column: $table.reminderSupplementTime2,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderMealsEnabled => $composableBuilder(
      column: $table.reminderMealsEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderBreakfast => $composableBuilder(
      column: $table.reminderBreakfast,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderLunch => $composableBuilder(
      column: $table.reminderLunch,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderDinner => $composableBuilder(
      column: $table.reminderDinner,
      builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get darkMode =>
      $composableBuilder(column: $table.darkMode, builder: (column) => column);

  GeneratedColumn<int> get reminderWeighEnabled => $composableBuilder(
      column: $table.reminderWeighEnabled, builder: (column) => column);

  GeneratedColumn<String> get reminderWeighTime => $composableBuilder(
      column: $table.reminderWeighTime, builder: (column) => column);

  GeneratedColumn<String> get reminderWeighTime2 => $composableBuilder(
      column: $table.reminderWeighTime2, builder: (column) => column);

  GeneratedColumn<int> get reminderSupplementEnabled => $composableBuilder(
      column: $table.reminderSupplementEnabled, builder: (column) => column);

  GeneratedColumn<String> get reminderSupplementTime => $composableBuilder(
      column: $table.reminderSupplementTime, builder: (column) => column);

  GeneratedColumn<String> get reminderSupplementTime2 => $composableBuilder(
      column: $table.reminderSupplementTime2, builder: (column) => column);

  GeneratedColumn<int> get reminderMealsEnabled => $composableBuilder(
      column: $table.reminderMealsEnabled, builder: (column) => column);

  GeneratedColumn<String> get reminderBreakfast => $composableBuilder(
      column: $table.reminderBreakfast, builder: (column) => column);

  GeneratedColumn<String> get reminderLunch => $composableBuilder(
      column: $table.reminderLunch, builder: (column) => column);

  GeneratedColumn<String> get reminderDinner => $composableBuilder(
      column: $table.reminderDinner, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSettingsRow,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (
      AppSettingsRow,
      BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>
    ),
    AppSettingsRow,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> darkMode = const Value.absent(),
            Value<int> reminderWeighEnabled = const Value.absent(),
            Value<String> reminderWeighTime = const Value.absent(),
            Value<String> reminderWeighTime2 = const Value.absent(),
            Value<int> reminderSupplementEnabled = const Value.absent(),
            Value<String> reminderSupplementTime = const Value.absent(),
            Value<String> reminderSupplementTime2 = const Value.absent(),
            Value<int> reminderMealsEnabled = const Value.absent(),
            Value<String> reminderBreakfast = const Value.absent(),
            Value<String> reminderLunch = const Value.absent(),
            Value<String> reminderDinner = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            id: id,
            darkMode: darkMode,
            reminderWeighEnabled: reminderWeighEnabled,
            reminderWeighTime: reminderWeighTime,
            reminderWeighTime2: reminderWeighTime2,
            reminderSupplementEnabled: reminderSupplementEnabled,
            reminderSupplementTime: reminderSupplementTime,
            reminderSupplementTime2: reminderSupplementTime2,
            reminderMealsEnabled: reminderMealsEnabled,
            reminderBreakfast: reminderBreakfast,
            reminderLunch: reminderLunch,
            reminderDinner: reminderDinner,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> darkMode = const Value.absent(),
            Value<int> reminderWeighEnabled = const Value.absent(),
            Value<String> reminderWeighTime = const Value.absent(),
            Value<String> reminderWeighTime2 = const Value.absent(),
            Value<int> reminderSupplementEnabled = const Value.absent(),
            Value<String> reminderSupplementTime = const Value.absent(),
            Value<String> reminderSupplementTime2 = const Value.absent(),
            Value<int> reminderMealsEnabled = const Value.absent(),
            Value<String> reminderBreakfast = const Value.absent(),
            Value<String> reminderLunch = const Value.absent(),
            Value<String> reminderDinner = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            id: id,
            darkMode: darkMode,
            reminderWeighEnabled: reminderWeighEnabled,
            reminderWeighTime: reminderWeighTime,
            reminderWeighTime2: reminderWeighTime2,
            reminderSupplementEnabled: reminderSupplementEnabled,
            reminderSupplementTime: reminderSupplementTime,
            reminderSupplementTime2: reminderSupplementTime2,
            reminderMealsEnabled: reminderMealsEnabled,
            reminderBreakfast: reminderBreakfast,
            reminderLunch: reminderLunch,
            reminderDinner: reminderDinner,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AppSettingsTable, AppSettingsRow>(table),
                    BaseReferences<_$AppDatabase, $AppSettingsTable,
                        AppSettingsRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSettingsRow,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (
      AppSettingsRow,
      BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>
    ),
    AppSettingsRow,
    PrefetchHooks Function()>;
typedef $$WeightEntriesTableCreateCompanionBuilder = WeightEntriesCompanion
    Function({
  Value<int> id,
  required String date,
  required double weight,
  Value<String?> uuid,
});
typedef $$WeightEntriesTableUpdateCompanionBuilder = WeightEntriesCompanion
    Function({
  Value<int> id,
  Value<String> date,
  Value<double> weight,
  Value<String?> uuid,
});

class $$WeightEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));
}

class $$WeightEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));
}

class $$WeightEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);
}

class $$WeightEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WeightEntriesTable,
    WeightEntryRow,
    $$WeightEntriesTableFilterComposer,
    $$WeightEntriesTableOrderingComposer,
    $$WeightEntriesTableAnnotationComposer,
    $$WeightEntriesTableCreateCompanionBuilder,
    $$WeightEntriesTableUpdateCompanionBuilder,
    (
      WeightEntryRow,
      BaseReferences<_$AppDatabase, $WeightEntriesTable, WeightEntryRow>
    ),
    WeightEntryRow,
    PrefetchHooks Function()> {
  $$WeightEntriesTableTableManager(_$AppDatabase db, $WeightEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<String?> uuid = const Value.absent(),
          }) =>
              WeightEntriesCompanion(
            id: id,
            date: date,
            weight: weight,
            uuid: uuid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String date,
            required double weight,
            Value<String?> uuid = const Value.absent(),
          }) =>
              WeightEntriesCompanion.insert(
            id: id,
            date: date,
            weight: weight,
            uuid: uuid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$WeightEntriesTable, WeightEntryRow>(table),
                    BaseReferences<_$AppDatabase, $WeightEntriesTable,
                        WeightEntryRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WeightEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WeightEntriesTable,
    WeightEntryRow,
    $$WeightEntriesTableFilterComposer,
    $$WeightEntriesTableOrderingComposer,
    $$WeightEntriesTableAnnotationComposer,
    $$WeightEntriesTableCreateCompanionBuilder,
    $$WeightEntriesTableUpdateCompanionBuilder,
    (
      WeightEntryRow,
      BaseReferences<_$AppDatabase, $WeightEntriesTable, WeightEntryRow>
    ),
    WeightEntryRow,
    PrefetchHooks Function()>;
typedef $$AppDatabaseMetadataTableCreateCompanionBuilder
    = AppDatabaseMetadataCompanion Function({
  Value<int> id,
  required int schemaVersion,
  required String createdAtUtc,
  required String migratedAtUtc,
});
typedef $$AppDatabaseMetadataTableUpdateCompanionBuilder
    = AppDatabaseMetadataCompanion Function({
  Value<int> id,
  Value<int> schemaVersion,
  Value<String> createdAtUtc,
  Value<String> migratedAtUtc,
});

class $$AppDatabaseMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $AppDatabaseMetadataTable> {
  $$AppDatabaseMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get migratedAtUtc => $composableBuilder(
      column: $table.migratedAtUtc, builder: (column) => ColumnFilters(column));
}

class $$AppDatabaseMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $AppDatabaseMetadataTable> {
  $$AppDatabaseMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get migratedAtUtc => $composableBuilder(
      column: $table.migratedAtUtc,
      builder: (column) => ColumnOrderings(column));
}

class $$AppDatabaseMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppDatabaseMetadataTable> {
  $$AppDatabaseMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => column);

  GeneratedColumn<String> get migratedAtUtc => $composableBuilder(
      column: $table.migratedAtUtc, builder: (column) => column);
}

class $$AppDatabaseMetadataTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppDatabaseMetadataTable,
    AppDatabaseMetadataRow,
    $$AppDatabaseMetadataTableFilterComposer,
    $$AppDatabaseMetadataTableOrderingComposer,
    $$AppDatabaseMetadataTableAnnotationComposer,
    $$AppDatabaseMetadataTableCreateCompanionBuilder,
    $$AppDatabaseMetadataTableUpdateCompanionBuilder,
    (
      AppDatabaseMetadataRow,
      BaseReferences<_$AppDatabase, $AppDatabaseMetadataTable,
          AppDatabaseMetadataRow>
    ),
    AppDatabaseMetadataRow,
    PrefetchHooks Function()> {
  $$AppDatabaseMetadataTableTableManager(
      _$AppDatabase db, $AppDatabaseMetadataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppDatabaseMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppDatabaseMetadataTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppDatabaseMetadataTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> schemaVersion = const Value.absent(),
            Value<String> createdAtUtc = const Value.absent(),
            Value<String> migratedAtUtc = const Value.absent(),
          }) =>
              AppDatabaseMetadataCompanion(
            id: id,
            schemaVersion: schemaVersion,
            createdAtUtc: createdAtUtc,
            migratedAtUtc: migratedAtUtc,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int schemaVersion,
            required String createdAtUtc,
            required String migratedAtUtc,
          }) =>
              AppDatabaseMetadataCompanion.insert(
            id: id,
            schemaVersion: schemaVersion,
            createdAtUtc: createdAtUtc,
            migratedAtUtc: migratedAtUtc,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AppDatabaseMetadataTable,
                        AppDatabaseMetadataRow>(table),
                    BaseReferences<_$AppDatabase, $AppDatabaseMetadataTable,
                        AppDatabaseMetadataRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppDatabaseMetadataTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppDatabaseMetadataTable,
    AppDatabaseMetadataRow,
    $$AppDatabaseMetadataTableFilterComposer,
    $$AppDatabaseMetadataTableOrderingComposer,
    $$AppDatabaseMetadataTableAnnotationComposer,
    $$AppDatabaseMetadataTableCreateCompanionBuilder,
    $$AppDatabaseMetadataTableUpdateCompanionBuilder,
    (
      AppDatabaseMetadataRow,
      BaseReferences<_$AppDatabase, $AppDatabaseMetadataTable,
          AppDatabaseMetadataRow>
    ),
    AppDatabaseMetadataRow,
    PrefetchHooks Function()>;
typedef $$HealthSourcesTableCreateCompanionBuilder = HealthSourcesCompanion
    Function({
  required String id,
  required String sourceName,
  Value<String?> sourceDeviceId,
  required String platform,
  Value<int> priority,
  Value<bool> enabled,
  required String discoveredAtUtc,
  Value<int> rowid,
});
typedef $$HealthSourcesTableUpdateCompanionBuilder = HealthSourcesCompanion
    Function({
  Value<String> id,
  Value<String> sourceName,
  Value<String?> sourceDeviceId,
  Value<String> platform,
  Value<int> priority,
  Value<bool> enabled,
  Value<String> discoveredAtUtc,
  Value<int> rowid,
});

class $$HealthSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $HealthSourcesTable> {
  $$HealthSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceDeviceId => $composableBuilder(
      column: $table.sourceDeviceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get discoveredAtUtc => $composableBuilder(
      column: $table.discoveredAtUtc,
      builder: (column) => ColumnFilters(column));
}

class $$HealthSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthSourcesTable> {
  $$HealthSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceDeviceId => $composableBuilder(
      column: $table.sourceDeviceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get discoveredAtUtc => $composableBuilder(
      column: $table.discoveredAtUtc,
      builder: (column) => ColumnOrderings(column));
}

class $$HealthSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthSourcesTable> {
  $$HealthSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => column);

  GeneratedColumn<String> get sourceDeviceId => $composableBuilder(
      column: $table.sourceDeviceId, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get discoveredAtUtc => $composableBuilder(
      column: $table.discoveredAtUtc, builder: (column) => column);
}

class $$HealthSourcesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HealthSourcesTable,
    HealthSourceRow,
    $$HealthSourcesTableFilterComposer,
    $$HealthSourcesTableOrderingComposer,
    $$HealthSourcesTableAnnotationComposer,
    $$HealthSourcesTableCreateCompanionBuilder,
    $$HealthSourcesTableUpdateCompanionBuilder,
    (
      HealthSourceRow,
      BaseReferences<_$AppDatabase, $HealthSourcesTable, HealthSourceRow>
    ),
    HealthSourceRow,
    PrefetchHooks Function()> {
  $$HealthSourcesTableTableManager(_$AppDatabase db, $HealthSourcesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sourceName = const Value.absent(),
            Value<String?> sourceDeviceId = const Value.absent(),
            Value<String> platform = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<String> discoveredAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HealthSourcesCompanion(
            id: id,
            sourceName: sourceName,
            sourceDeviceId: sourceDeviceId,
            platform: platform,
            priority: priority,
            enabled: enabled,
            discoveredAtUtc: discoveredAtUtc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sourceName,
            Value<String?> sourceDeviceId = const Value.absent(),
            required String platform,
            Value<int> priority = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            required String discoveredAtUtc,
            Value<int> rowid = const Value.absent(),
          }) =>
              HealthSourcesCompanion.insert(
            id: id,
            sourceName: sourceName,
            sourceDeviceId: sourceDeviceId,
            platform: platform,
            priority: priority,
            enabled: enabled,
            discoveredAtUtc: discoveredAtUtc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$HealthSourcesTable, HealthSourceRow>(table),
                    BaseReferences<_$AppDatabase, $HealthSourcesTable,
                        HealthSourceRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HealthSourcesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HealthSourcesTable,
    HealthSourceRow,
    $$HealthSourcesTableFilterComposer,
    $$HealthSourcesTableOrderingComposer,
    $$HealthSourcesTableAnnotationComposer,
    $$HealthSourcesTableCreateCompanionBuilder,
    $$HealthSourcesTableUpdateCompanionBuilder,
    (
      HealthSourceRow,
      BaseReferences<_$AppDatabase, $HealthSourcesTable, HealthSourceRow>
    ),
    HealthSourceRow,
    PrefetchHooks Function()>;
typedef $$HealthSyncStatesTableCreateCompanionBuilder
    = HealthSyncStatesCompanion Function({
  required String sourceId,
  Value<String?> cursorUtc,
  Value<String?> lastSuccessUtc,
  Value<String?> lastError,
  Value<String> status,
  Value<int> rowid,
});
typedef $$HealthSyncStatesTableUpdateCompanionBuilder
    = HealthSyncStatesCompanion Function({
  Value<String> sourceId,
  Value<String?> cursorUtc,
  Value<String?> lastSuccessUtc,
  Value<String?> lastError,
  Value<String> status,
  Value<int> rowid,
});

class $$HealthSyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $HealthSyncStatesTable> {
  $$HealthSyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cursorUtc => $composableBuilder(
      column: $table.cursorUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastSuccessUtc => $composableBuilder(
      column: $table.lastSuccessUtc,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$HealthSyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthSyncStatesTable> {
  $$HealthSyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cursorUtc => $composableBuilder(
      column: $table.cursorUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastSuccessUtc => $composableBuilder(
      column: $table.lastSuccessUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$HealthSyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthSyncStatesTable> {
  $$HealthSyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get cursorUtc =>
      $composableBuilder(column: $table.cursorUtc, builder: (column) => column);

  GeneratedColumn<String> get lastSuccessUtc => $composableBuilder(
      column: $table.lastSuccessUtc, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$HealthSyncStatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HealthSyncStatesTable,
    HealthSyncStateRow,
    $$HealthSyncStatesTableFilterComposer,
    $$HealthSyncStatesTableOrderingComposer,
    $$HealthSyncStatesTableAnnotationComposer,
    $$HealthSyncStatesTableCreateCompanionBuilder,
    $$HealthSyncStatesTableUpdateCompanionBuilder,
    (
      HealthSyncStateRow,
      BaseReferences<_$AppDatabase, $HealthSyncStatesTable, HealthSyncStateRow>
    ),
    HealthSyncStateRow,
    PrefetchHooks Function()> {
  $$HealthSyncStatesTableTableManager(
      _$AppDatabase db, $HealthSyncStatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthSyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthSyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthSyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> sourceId = const Value.absent(),
            Value<String?> cursorUtc = const Value.absent(),
            Value<String?> lastSuccessUtc = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HealthSyncStatesCompanion(
            sourceId: sourceId,
            cursorUtc: cursorUtc,
            lastSuccessUtc: lastSuccessUtc,
            lastError: lastError,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String sourceId,
            Value<String?> cursorUtc = const Value.absent(),
            Value<String?> lastSuccessUtc = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HealthSyncStatesCompanion.insert(
            sourceId: sourceId,
            cursorUtc: cursorUtc,
            lastSuccessUtc: lastSuccessUtc,
            lastError: lastError,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$HealthSyncStatesTable, HealthSyncStateRow>(
                        table),
                    BaseReferences<_$AppDatabase, $HealthSyncStatesTable,
                        HealthSyncStateRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HealthSyncStatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HealthSyncStatesTable,
    HealthSyncStateRow,
    $$HealthSyncStatesTableFilterComposer,
    $$HealthSyncStatesTableOrderingComposer,
    $$HealthSyncStatesTableAnnotationComposer,
    $$HealthSyncStatesTableCreateCompanionBuilder,
    $$HealthSyncStatesTableUpdateCompanionBuilder,
    (
      HealthSyncStateRow,
      BaseReferences<_$AppDatabase, $HealthSyncStatesTable, HealthSyncStateRow>
    ),
    HealthSyncStateRow,
    PrefetchHooks Function()>;
typedef $$HealthRecordsTableCreateCompanionBuilder = HealthRecordsCompanion
    Function({
  required String id,
  required String type,
  required String sourceId,
  required String startUtc,
  required String endUtc,
  required double value,
  required String unit,
  required String localDay,
  Value<String?> payloadJson,
  Value<int> rowid,
});
typedef $$HealthRecordsTableUpdateCompanionBuilder = HealthRecordsCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<String> sourceId,
  Value<String> startUtc,
  Value<String> endUtc,
  Value<double> value,
  Value<String> unit,
  Value<String> localDay,
  Value<String?> payloadJson,
  Value<int> rowid,
});

class $$HealthRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $HealthRecordsTable> {
  $$HealthRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endUtc => $composableBuilder(
      column: $table.endUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localDay => $composableBuilder(
      column: $table.localDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));
}

class $$HealthRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthRecordsTable> {
  $$HealthRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endUtc => $composableBuilder(
      column: $table.endUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localDay => $composableBuilder(
      column: $table.localDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));
}

class $$HealthRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthRecordsTable> {
  $$HealthRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => column);

  GeneratedColumn<String> get endUtc =>
      $composableBuilder(column: $table.endUtc, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get localDay =>
      $composableBuilder(column: $table.localDay, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);
}

class $$HealthRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HealthRecordsTable,
    HealthRecordRow,
    $$HealthRecordsTableFilterComposer,
    $$HealthRecordsTableOrderingComposer,
    $$HealthRecordsTableAnnotationComposer,
    $$HealthRecordsTableCreateCompanionBuilder,
    $$HealthRecordsTableUpdateCompanionBuilder,
    (
      HealthRecordRow,
      BaseReferences<_$AppDatabase, $HealthRecordsTable, HealthRecordRow>
    ),
    HealthRecordRow,
    PrefetchHooks Function()> {
  $$HealthRecordsTableTableManager(_$AppDatabase db, $HealthRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> sourceId = const Value.absent(),
            Value<String> startUtc = const Value.absent(),
            Value<String> endUtc = const Value.absent(),
            Value<double> value = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<String> localDay = const Value.absent(),
            Value<String?> payloadJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HealthRecordsCompanion(
            id: id,
            type: type,
            sourceId: sourceId,
            startUtc: startUtc,
            endUtc: endUtc,
            value: value,
            unit: unit,
            localDay: localDay,
            payloadJson: payloadJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String sourceId,
            required String startUtc,
            required String endUtc,
            required double value,
            required String unit,
            required String localDay,
            Value<String?> payloadJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HealthRecordsCompanion.insert(
            id: id,
            type: type,
            sourceId: sourceId,
            startUtc: startUtc,
            endUtc: endUtc,
            value: value,
            unit: unit,
            localDay: localDay,
            payloadJson: payloadJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$HealthRecordsTable, HealthRecordRow>(table),
                    BaseReferences<_$AppDatabase, $HealthRecordsTable,
                        HealthRecordRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HealthRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HealthRecordsTable,
    HealthRecordRow,
    $$HealthRecordsTableFilterComposer,
    $$HealthRecordsTableOrderingComposer,
    $$HealthRecordsTableAnnotationComposer,
    $$HealthRecordsTableCreateCompanionBuilder,
    $$HealthRecordsTableUpdateCompanionBuilder,
    (
      HealthRecordRow,
      BaseReferences<_$AppDatabase, $HealthRecordsTable, HealthRecordRow>
    ),
    HealthRecordRow,
    PrefetchHooks Function()>;
typedef $$DailyHealthAggregatesTableCreateCompanionBuilder
    = DailyHealthAggregatesCompanion Function({
  required String day,
  Value<int> steps,
  Value<double> activeKcal,
  Value<double?> totalKcal,
  Value<double> distanceM,
  Value<double?> heartRateAvg,
  Value<double?> restingHr,
  Value<double?> sleepMinutes,
  Value<String> sourceIds,
  required String updatedAtUtc,
  Value<int> rowid,
});
typedef $$DailyHealthAggregatesTableUpdateCompanionBuilder
    = DailyHealthAggregatesCompanion Function({
  Value<String> day,
  Value<int> steps,
  Value<double> activeKcal,
  Value<double?> totalKcal,
  Value<double> distanceM,
  Value<double?> heartRateAvg,
  Value<double?> restingHr,
  Value<double?> sleepMinutes,
  Value<String> sourceIds,
  Value<String> updatedAtUtc,
  Value<int> rowid,
});

class $$DailyHealthAggregatesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyHealthAggregatesTable> {
  $$DailyHealthAggregatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get steps => $composableBuilder(
      column: $table.steps, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get activeKcal => $composableBuilder(
      column: $table.activeKcal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalKcal => $composableBuilder(
      column: $table.totalKcal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get distanceM => $composableBuilder(
      column: $table.distanceM, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heartRateAvg => $composableBuilder(
      column: $table.heartRateAvg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get restingHr => $composableBuilder(
      column: $table.restingHr, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sleepMinutes => $composableBuilder(
      column: $table.sleepMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceIds => $composableBuilder(
      column: $table.sourceIds, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAtUtc => $composableBuilder(
      column: $table.updatedAtUtc, builder: (column) => ColumnFilters(column));
}

class $$DailyHealthAggregatesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyHealthAggregatesTable> {
  $$DailyHealthAggregatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get steps => $composableBuilder(
      column: $table.steps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get activeKcal => $composableBuilder(
      column: $table.activeKcal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalKcal => $composableBuilder(
      column: $table.totalKcal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distanceM => $composableBuilder(
      column: $table.distanceM, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heartRateAvg => $composableBuilder(
      column: $table.heartRateAvg,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get restingHr => $composableBuilder(
      column: $table.restingHr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sleepMinutes => $composableBuilder(
      column: $table.sleepMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceIds => $composableBuilder(
      column: $table.sourceIds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAtUtc => $composableBuilder(
      column: $table.updatedAtUtc,
      builder: (column) => ColumnOrderings(column));
}

class $$DailyHealthAggregatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyHealthAggregatesTable> {
  $$DailyHealthAggregatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<double> get activeKcal => $composableBuilder(
      column: $table.activeKcal, builder: (column) => column);

  GeneratedColumn<double> get totalKcal =>
      $composableBuilder(column: $table.totalKcal, builder: (column) => column);

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<double> get heartRateAvg => $composableBuilder(
      column: $table.heartRateAvg, builder: (column) => column);

  GeneratedColumn<double> get restingHr =>
      $composableBuilder(column: $table.restingHr, builder: (column) => column);

  GeneratedColumn<double> get sleepMinutes => $composableBuilder(
      column: $table.sleepMinutes, builder: (column) => column);

  GeneratedColumn<String> get sourceIds =>
      $composableBuilder(column: $table.sourceIds, builder: (column) => column);

  GeneratedColumn<String> get updatedAtUtc => $composableBuilder(
      column: $table.updatedAtUtc, builder: (column) => column);
}

class $$DailyHealthAggregatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyHealthAggregatesTable,
    DailyHealthAggregateRow,
    $$DailyHealthAggregatesTableFilterComposer,
    $$DailyHealthAggregatesTableOrderingComposer,
    $$DailyHealthAggregatesTableAnnotationComposer,
    $$DailyHealthAggregatesTableCreateCompanionBuilder,
    $$DailyHealthAggregatesTableUpdateCompanionBuilder,
    (
      DailyHealthAggregateRow,
      BaseReferences<_$AppDatabase, $DailyHealthAggregatesTable,
          DailyHealthAggregateRow>
    ),
    DailyHealthAggregateRow,
    PrefetchHooks Function()> {
  $$DailyHealthAggregatesTableTableManager(
      _$AppDatabase db, $DailyHealthAggregatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyHealthAggregatesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyHealthAggregatesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyHealthAggregatesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> day = const Value.absent(),
            Value<int> steps = const Value.absent(),
            Value<double> activeKcal = const Value.absent(),
            Value<double?> totalKcal = const Value.absent(),
            Value<double> distanceM = const Value.absent(),
            Value<double?> heartRateAvg = const Value.absent(),
            Value<double?> restingHr = const Value.absent(),
            Value<double?> sleepMinutes = const Value.absent(),
            Value<String> sourceIds = const Value.absent(),
            Value<String> updatedAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyHealthAggregatesCompanion(
            day: day,
            steps: steps,
            activeKcal: activeKcal,
            totalKcal: totalKcal,
            distanceM: distanceM,
            heartRateAvg: heartRateAvg,
            restingHr: restingHr,
            sleepMinutes: sleepMinutes,
            sourceIds: sourceIds,
            updatedAtUtc: updatedAtUtc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String day,
            Value<int> steps = const Value.absent(),
            Value<double> activeKcal = const Value.absent(),
            Value<double?> totalKcal = const Value.absent(),
            Value<double> distanceM = const Value.absent(),
            Value<double?> heartRateAvg = const Value.absent(),
            Value<double?> restingHr = const Value.absent(),
            Value<double?> sleepMinutes = const Value.absent(),
            Value<String> sourceIds = const Value.absent(),
            required String updatedAtUtc,
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyHealthAggregatesCompanion.insert(
            day: day,
            steps: steps,
            activeKcal: activeKcal,
            totalKcal: totalKcal,
            distanceM: distanceM,
            heartRateAvg: heartRateAvg,
            restingHr: restingHr,
            sleepMinutes: sleepMinutes,
            sourceIds: sourceIds,
            updatedAtUtc: updatedAtUtc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DailyHealthAggregatesTable,
                        DailyHealthAggregateRow>(table),
                    BaseReferences<_$AppDatabase, $DailyHealthAggregatesTable,
                        DailyHealthAggregateRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailyHealthAggregatesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DailyHealthAggregatesTable,
        DailyHealthAggregateRow,
        $$DailyHealthAggregatesTableFilterComposer,
        $$DailyHealthAggregatesTableOrderingComposer,
        $$DailyHealthAggregatesTableAnnotationComposer,
        $$DailyHealthAggregatesTableCreateCompanionBuilder,
        $$DailyHealthAggregatesTableUpdateCompanionBuilder,
        (
          DailyHealthAggregateRow,
          BaseReferences<_$AppDatabase, $DailyHealthAggregatesTable,
              DailyHealthAggregateRow>
        ),
        DailyHealthAggregateRow,
        PrefetchHooks Function()>;
typedef $$SleepSessionsTableCreateCompanionBuilder = SleepSessionsCompanion
    Function({
  required String id,
  required String startUtc,
  required String endUtc,
  required int durationMinutes,
  required String sourceId,
  Value<String?> stagesJson,
  Value<int> rowid,
});
typedef $$SleepSessionsTableUpdateCompanionBuilder = SleepSessionsCompanion
    Function({
  Value<String> id,
  Value<String> startUtc,
  Value<String> endUtc,
  Value<int> durationMinutes,
  Value<String> sourceId,
  Value<String?> stagesJson,
  Value<int> rowid,
});

class $$SleepSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SleepSessionsTable> {
  $$SleepSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endUtc => $composableBuilder(
      column: $table.endUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stagesJson => $composableBuilder(
      column: $table.stagesJson, builder: (column) => ColumnFilters(column));
}

class $$SleepSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepSessionsTable> {
  $$SleepSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endUtc => $composableBuilder(
      column: $table.endUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stagesJson => $composableBuilder(
      column: $table.stagesJson, builder: (column) => ColumnOrderings(column));
}

class $$SleepSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepSessionsTable> {
  $$SleepSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => column);

  GeneratedColumn<String> get endUtc =>
      $composableBuilder(column: $table.endUtc, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get stagesJson => $composableBuilder(
      column: $table.stagesJson, builder: (column) => column);
}

class $$SleepSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SleepSessionsTable,
    SleepSessionRow,
    $$SleepSessionsTableFilterComposer,
    $$SleepSessionsTableOrderingComposer,
    $$SleepSessionsTableAnnotationComposer,
    $$SleepSessionsTableCreateCompanionBuilder,
    $$SleepSessionsTableUpdateCompanionBuilder,
    (
      SleepSessionRow,
      BaseReferences<_$AppDatabase, $SleepSessionsTable, SleepSessionRow>
    ),
    SleepSessionRow,
    PrefetchHooks Function()> {
  $$SleepSessionsTableTableManager(_$AppDatabase db, $SleepSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> startUtc = const Value.absent(),
            Value<String> endUtc = const Value.absent(),
            Value<int> durationMinutes = const Value.absent(),
            Value<String> sourceId = const Value.absent(),
            Value<String?> stagesJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SleepSessionsCompanion(
            id: id,
            startUtc: startUtc,
            endUtc: endUtc,
            durationMinutes: durationMinutes,
            sourceId: sourceId,
            stagesJson: stagesJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String startUtc,
            required String endUtc,
            required int durationMinutes,
            required String sourceId,
            Value<String?> stagesJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SleepSessionsCompanion.insert(
            id: id,
            startUtc: startUtc,
            endUtc: endUtc,
            durationMinutes: durationMinutes,
            sourceId: sourceId,
            stagesJson: stagesJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SleepSessionsTable, SleepSessionRow>(table),
                    BaseReferences<_$AppDatabase, $SleepSessionsTable,
                        SleepSessionRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SleepSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SleepSessionsTable,
    SleepSessionRow,
    $$SleepSessionsTableFilterComposer,
    $$SleepSessionsTableOrderingComposer,
    $$SleepSessionsTableAnnotationComposer,
    $$SleepSessionsTableCreateCompanionBuilder,
    $$SleepSessionsTableUpdateCompanionBuilder,
    (
      SleepSessionRow,
      BaseReferences<_$AppDatabase, $SleepSessionsTable, SleepSessionRow>
    ),
    SleepSessionRow,
    PrefetchHooks Function()>;
typedef $$WorkoutSessionsTableCreateCompanionBuilder = WorkoutSessionsCompanion
    Function({
  required String id,
  required String type,
  required String startUtc,
  required String endUtc,
  required double durationSeconds,
  Value<double?> distanceM,
  Value<double?> energyKcal,
  required String sourceId,
  Value<String> routeStatus,
  Value<int> rowid,
});
typedef $$WorkoutSessionsTableUpdateCompanionBuilder = WorkoutSessionsCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<String> startUtc,
  Value<String> endUtc,
  Value<double> durationSeconds,
  Value<double?> distanceM,
  Value<double?> energyKcal,
  Value<String> sourceId,
  Value<String> routeStatus,
  Value<int> rowid,
});

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endUtc => $composableBuilder(
      column: $table.endUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get distanceM => $composableBuilder(
      column: $table.distanceM, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get energyKcal => $composableBuilder(
      column: $table.energyKcal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routeStatus => $composableBuilder(
      column: $table.routeStatus, builder: (column) => ColumnFilters(column));
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endUtc => $composableBuilder(
      column: $table.endUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distanceM => $composableBuilder(
      column: $table.distanceM, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get energyKcal => $composableBuilder(
      column: $table.energyKcal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routeStatus => $composableBuilder(
      column: $table.routeStatus, builder: (column) => ColumnOrderings(column));
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => column);

  GeneratedColumn<String> get endUtc =>
      $composableBuilder(column: $table.endUtc, builder: (column) => column);

  GeneratedColumn<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<double> get energyKcal => $composableBuilder(
      column: $table.energyKcal, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get routeStatus => $composableBuilder(
      column: $table.routeStatus, builder: (column) => column);
}

class $$WorkoutSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutSessionsTable,
    WorkoutSessionRow,
    $$WorkoutSessionsTableFilterComposer,
    $$WorkoutSessionsTableOrderingComposer,
    $$WorkoutSessionsTableAnnotationComposer,
    $$WorkoutSessionsTableCreateCompanionBuilder,
    $$WorkoutSessionsTableUpdateCompanionBuilder,
    (
      WorkoutSessionRow,
      BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSessionRow>
    ),
    WorkoutSessionRow,
    PrefetchHooks Function()> {
  $$WorkoutSessionsTableTableManager(
      _$AppDatabase db, $WorkoutSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> startUtc = const Value.absent(),
            Value<String> endUtc = const Value.absent(),
            Value<double> durationSeconds = const Value.absent(),
            Value<double?> distanceM = const Value.absent(),
            Value<double?> energyKcal = const Value.absent(),
            Value<String> sourceId = const Value.absent(),
            Value<String> routeStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkoutSessionsCompanion(
            id: id,
            type: type,
            startUtc: startUtc,
            endUtc: endUtc,
            durationSeconds: durationSeconds,
            distanceM: distanceM,
            energyKcal: energyKcal,
            sourceId: sourceId,
            routeStatus: routeStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String startUtc,
            required String endUtc,
            required double durationSeconds,
            Value<double?> distanceM = const Value.absent(),
            Value<double?> energyKcal = const Value.absent(),
            required String sourceId,
            Value<String> routeStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkoutSessionsCompanion.insert(
            id: id,
            type: type,
            startUtc: startUtc,
            endUtc: endUtc,
            durationSeconds: durationSeconds,
            distanceM: distanceM,
            energyKcal: energyKcal,
            sourceId: sourceId,
            routeStatus: routeStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$WorkoutSessionsTable, WorkoutSessionRow>(
                        table),
                    BaseReferences<_$AppDatabase, $WorkoutSessionsTable,
                        WorkoutSessionRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WorkoutSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutSessionsTable,
    WorkoutSessionRow,
    $$WorkoutSessionsTableFilterComposer,
    $$WorkoutSessionsTableOrderingComposer,
    $$WorkoutSessionsTableAnnotationComposer,
    $$WorkoutSessionsTableCreateCompanionBuilder,
    $$WorkoutSessionsTableUpdateCompanionBuilder,
    (
      WorkoutSessionRow,
      BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSessionRow>
    ),
    WorkoutSessionRow,
    PrefetchHooks Function()>;
typedef $$WorkoutRoutePointsTableCreateCompanionBuilder
    = WorkoutRoutePointsCompanion Function({
  required String workoutId,
  required int sequence,
  required double latitude,
  required double longitude,
  required String timestampUtc,
  Value<int> rowid,
});
typedef $$WorkoutRoutePointsTableUpdateCompanionBuilder
    = WorkoutRoutePointsCompanion Function({
  Value<String> workoutId,
  Value<int> sequence,
  Value<double> latitude,
  Value<double> longitude,
  Value<String> timestampUtc,
  Value<int> rowid,
});

class $$WorkoutRoutePointsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutRoutePointsTable> {
  $$WorkoutRoutePointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get workoutId => $composableBuilder(
      column: $table.workoutId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sequence => $composableBuilder(
      column: $table.sequence, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timestampUtc => $composableBuilder(
      column: $table.timestampUtc, builder: (column) => ColumnFilters(column));
}

class $$WorkoutRoutePointsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutRoutePointsTable> {
  $$WorkoutRoutePointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get workoutId => $composableBuilder(
      column: $table.workoutId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sequence => $composableBuilder(
      column: $table.sequence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timestampUtc => $composableBuilder(
      column: $table.timestampUtc,
      builder: (column) => ColumnOrderings(column));
}

class $$WorkoutRoutePointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutRoutePointsTable> {
  $$WorkoutRoutePointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get workoutId =>
      $composableBuilder(column: $table.workoutId, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get timestampUtc => $composableBuilder(
      column: $table.timestampUtc, builder: (column) => column);
}

class $$WorkoutRoutePointsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutRoutePointsTable,
    WorkoutRoutePointRow,
    $$WorkoutRoutePointsTableFilterComposer,
    $$WorkoutRoutePointsTableOrderingComposer,
    $$WorkoutRoutePointsTableAnnotationComposer,
    $$WorkoutRoutePointsTableCreateCompanionBuilder,
    $$WorkoutRoutePointsTableUpdateCompanionBuilder,
    (
      WorkoutRoutePointRow,
      BaseReferences<_$AppDatabase, $WorkoutRoutePointsTable,
          WorkoutRoutePointRow>
    ),
    WorkoutRoutePointRow,
    PrefetchHooks Function()> {
  $$WorkoutRoutePointsTableTableManager(
      _$AppDatabase db, $WorkoutRoutePointsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutRoutePointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutRoutePointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutRoutePointsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> workoutId = const Value.absent(),
            Value<int> sequence = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<String> timestampUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkoutRoutePointsCompanion(
            workoutId: workoutId,
            sequence: sequence,
            latitude: latitude,
            longitude: longitude,
            timestampUtc: timestampUtc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String workoutId,
            required int sequence,
            required double latitude,
            required double longitude,
            required String timestampUtc,
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkoutRoutePointsCompanion.insert(
            workoutId: workoutId,
            sequence: sequence,
            latitude: latitude,
            longitude: longitude,
            timestampUtc: timestampUtc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$WorkoutRoutePointsTable, WorkoutRoutePointRow>(
                        table),
                    BaseReferences<_$AppDatabase, $WorkoutRoutePointsTable,
                        WorkoutRoutePointRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WorkoutRoutePointsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutRoutePointsTable,
    WorkoutRoutePointRow,
    $$WorkoutRoutePointsTableFilterComposer,
    $$WorkoutRoutePointsTableOrderingComposer,
    $$WorkoutRoutePointsTableAnnotationComposer,
    $$WorkoutRoutePointsTableCreateCompanionBuilder,
    $$WorkoutRoutePointsTableUpdateCompanionBuilder,
    (
      WorkoutRoutePointRow,
      BaseReferences<_$AppDatabase, $WorkoutRoutePointsTable,
          WorkoutRoutePointRow>
    ),
    WorkoutRoutePointRow,
    PrefetchHooks Function()>;
typedef $$CycleProfilesTableCreateCompanionBuilder = CycleProfilesCompanion
    Function({
  Value<int> id,
  Value<int> typicalCycleLength,
  Value<int> typicalPeriodLength,
  Value<bool> predictionsEnabled,
  Value<bool> healthImportEnabled,
  Value<String> timezone,
});
typedef $$CycleProfilesTableUpdateCompanionBuilder = CycleProfilesCompanion
    Function({
  Value<int> id,
  Value<int> typicalCycleLength,
  Value<int> typicalPeriodLength,
  Value<bool> predictionsEnabled,
  Value<bool> healthImportEnabled,
  Value<String> timezone,
});

class $$CycleProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $CycleProfilesTable> {
  $$CycleProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get typicalCycleLength => $composableBuilder(
      column: $table.typicalCycleLength,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get typicalPeriodLength => $composableBuilder(
      column: $table.typicalPeriodLength,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get predictionsEnabled => $composableBuilder(
      column: $table.predictionsEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get healthImportEnabled => $composableBuilder(
      column: $table.healthImportEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnFilters(column));
}

class $$CycleProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $CycleProfilesTable> {
  $$CycleProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get typicalCycleLength => $composableBuilder(
      column: $table.typicalCycleLength,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get typicalPeriodLength => $composableBuilder(
      column: $table.typicalPeriodLength,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get predictionsEnabled => $composableBuilder(
      column: $table.predictionsEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get healthImportEnabled => $composableBuilder(
      column: $table.healthImportEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnOrderings(column));
}

class $$CycleProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CycleProfilesTable> {
  $$CycleProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get typicalCycleLength => $composableBuilder(
      column: $table.typicalCycleLength, builder: (column) => column);

  GeneratedColumn<int> get typicalPeriodLength => $composableBuilder(
      column: $table.typicalPeriodLength, builder: (column) => column);

  GeneratedColumn<bool> get predictionsEnabled => $composableBuilder(
      column: $table.predictionsEnabled, builder: (column) => column);

  GeneratedColumn<bool> get healthImportEnabled => $composableBuilder(
      column: $table.healthImportEnabled, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);
}

class $$CycleProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CycleProfilesTable,
    CycleProfileRow,
    $$CycleProfilesTableFilterComposer,
    $$CycleProfilesTableOrderingComposer,
    $$CycleProfilesTableAnnotationComposer,
    $$CycleProfilesTableCreateCompanionBuilder,
    $$CycleProfilesTableUpdateCompanionBuilder,
    (
      CycleProfileRow,
      BaseReferences<_$AppDatabase, $CycleProfilesTable, CycleProfileRow>
    ),
    CycleProfileRow,
    PrefetchHooks Function()> {
  $$CycleProfilesTableTableManager(_$AppDatabase db, $CycleProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CycleProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CycleProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CycleProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> typicalCycleLength = const Value.absent(),
            Value<int> typicalPeriodLength = const Value.absent(),
            Value<bool> predictionsEnabled = const Value.absent(),
            Value<bool> healthImportEnabled = const Value.absent(),
            Value<String> timezone = const Value.absent(),
          }) =>
              CycleProfilesCompanion(
            id: id,
            typicalCycleLength: typicalCycleLength,
            typicalPeriodLength: typicalPeriodLength,
            predictionsEnabled: predictionsEnabled,
            healthImportEnabled: healthImportEnabled,
            timezone: timezone,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> typicalCycleLength = const Value.absent(),
            Value<int> typicalPeriodLength = const Value.absent(),
            Value<bool> predictionsEnabled = const Value.absent(),
            Value<bool> healthImportEnabled = const Value.absent(),
            Value<String> timezone = const Value.absent(),
          }) =>
              CycleProfilesCompanion.insert(
            id: id,
            typicalCycleLength: typicalCycleLength,
            typicalPeriodLength: typicalPeriodLength,
            predictionsEnabled: predictionsEnabled,
            healthImportEnabled: healthImportEnabled,
            timezone: timezone,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CycleProfilesTable, CycleProfileRow>(table),
                    BaseReferences<_$AppDatabase, $CycleProfilesTable,
                        CycleProfileRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CycleProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CycleProfilesTable,
    CycleProfileRow,
    $$CycleProfilesTableFilterComposer,
    $$CycleProfilesTableOrderingComposer,
    $$CycleProfilesTableAnnotationComposer,
    $$CycleProfilesTableCreateCompanionBuilder,
    $$CycleProfilesTableUpdateCompanionBuilder,
    (
      CycleProfileRow,
      BaseReferences<_$AppDatabase, $CycleProfilesTable, CycleProfileRow>
    ),
    CycleProfileRow,
    PrefetchHooks Function()>;
typedef $$PeriodEntriesTableCreateCompanionBuilder = PeriodEntriesCompanion
    Function({
  required String id,
  required String startDay,
  Value<String?> endDay,
  Value<String?> flowJson,
  Value<String> source,
  required String createdAtUtc,
  Value<int> rowid,
});
typedef $$PeriodEntriesTableUpdateCompanionBuilder = PeriodEntriesCompanion
    Function({
  Value<String> id,
  Value<String> startDay,
  Value<String?> endDay,
  Value<String?> flowJson,
  Value<String> source,
  Value<String> createdAtUtc,
  Value<int> rowid,
});

class $$PeriodEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PeriodEntriesTable> {
  $$PeriodEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDay => $composableBuilder(
      column: $table.startDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endDay => $composableBuilder(
      column: $table.endDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get flowJson => $composableBuilder(
      column: $table.flowJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => ColumnFilters(column));
}

class $$PeriodEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PeriodEntriesTable> {
  $$PeriodEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDay => $composableBuilder(
      column: $table.startDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endDay => $composableBuilder(
      column: $table.endDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get flowJson => $composableBuilder(
      column: $table.flowJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc,
      builder: (column) => ColumnOrderings(column));
}

class $$PeriodEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeriodEntriesTable> {
  $$PeriodEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startDay =>
      $composableBuilder(column: $table.startDay, builder: (column) => column);

  GeneratedColumn<String> get endDay =>
      $composableBuilder(column: $table.endDay, builder: (column) => column);

  GeneratedColumn<String> get flowJson =>
      $composableBuilder(column: $table.flowJson, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => column);
}

class $$PeriodEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PeriodEntriesTable,
    PeriodEntryRow,
    $$PeriodEntriesTableFilterComposer,
    $$PeriodEntriesTableOrderingComposer,
    $$PeriodEntriesTableAnnotationComposer,
    $$PeriodEntriesTableCreateCompanionBuilder,
    $$PeriodEntriesTableUpdateCompanionBuilder,
    (
      PeriodEntryRow,
      BaseReferences<_$AppDatabase, $PeriodEntriesTable, PeriodEntryRow>
    ),
    PeriodEntryRow,
    PrefetchHooks Function()> {
  $$PeriodEntriesTableTableManager(_$AppDatabase db, $PeriodEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeriodEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeriodEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeriodEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> startDay = const Value.absent(),
            Value<String?> endDay = const Value.absent(),
            Value<String?> flowJson = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> createdAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PeriodEntriesCompanion(
            id: id,
            startDay: startDay,
            endDay: endDay,
            flowJson: flowJson,
            source: source,
            createdAtUtc: createdAtUtc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String startDay,
            Value<String?> endDay = const Value.absent(),
            Value<String?> flowJson = const Value.absent(),
            Value<String> source = const Value.absent(),
            required String createdAtUtc,
            Value<int> rowid = const Value.absent(),
          }) =>
              PeriodEntriesCompanion.insert(
            id: id,
            startDay: startDay,
            endDay: endDay,
            flowJson: flowJson,
            source: source,
            createdAtUtc: createdAtUtc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PeriodEntriesTable, PeriodEntryRow>(table),
                    BaseReferences<_$AppDatabase, $PeriodEntriesTable,
                        PeriodEntryRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PeriodEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PeriodEntriesTable,
    PeriodEntryRow,
    $$PeriodEntriesTableFilterComposer,
    $$PeriodEntriesTableOrderingComposer,
    $$PeriodEntriesTableAnnotationComposer,
    $$PeriodEntriesTableCreateCompanionBuilder,
    $$PeriodEntriesTableUpdateCompanionBuilder,
    (
      PeriodEntryRow,
      BaseReferences<_$AppDatabase, $PeriodEntriesTable, PeriodEntryRow>
    ),
    PeriodEntryRow,
    PrefetchHooks Function()>;
typedef $$CycleDailyLogsTableCreateCompanionBuilder = CycleDailyLogsCompanion
    Function({
  required String day,
  Value<String?> bleeding,
  Value<String?> mood,
  Value<int?> pain,
  Value<int?> energy,
  Value<int?> sleepQuality,
  Value<String?> notes,
  Value<String> tagsJson,
  Value<String> source,
  required String updatedAtUtc,
  Value<int> rowid,
});
typedef $$CycleDailyLogsTableUpdateCompanionBuilder = CycleDailyLogsCompanion
    Function({
  Value<String> day,
  Value<String?> bleeding,
  Value<String?> mood,
  Value<int?> pain,
  Value<int?> energy,
  Value<int?> sleepQuality,
  Value<String?> notes,
  Value<String> tagsJson,
  Value<String> source,
  Value<String> updatedAtUtc,
  Value<int> rowid,
});

class $$CycleDailyLogsTableFilterComposer
    extends Composer<_$AppDatabase, $CycleDailyLogsTable> {
  $$CycleDailyLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bleeding => $composableBuilder(
      column: $table.bleeding, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pain => $composableBuilder(
      column: $table.pain, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get energy => $composableBuilder(
      column: $table.energy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sleepQuality => $composableBuilder(
      column: $table.sleepQuality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAtUtc => $composableBuilder(
      column: $table.updatedAtUtc, builder: (column) => ColumnFilters(column));
}

class $$CycleDailyLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $CycleDailyLogsTable> {
  $$CycleDailyLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bleeding => $composableBuilder(
      column: $table.bleeding, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pain => $composableBuilder(
      column: $table.pain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get energy => $composableBuilder(
      column: $table.energy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sleepQuality => $composableBuilder(
      column: $table.sleepQuality,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAtUtc => $composableBuilder(
      column: $table.updatedAtUtc,
      builder: (column) => ColumnOrderings(column));
}

class $$CycleDailyLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CycleDailyLogsTable> {
  $$CycleDailyLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get bleeding =>
      $composableBuilder(column: $table.bleeding, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<int> get pain =>
      $composableBuilder(column: $table.pain, builder: (column) => column);

  GeneratedColumn<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<int> get sleepQuality => $composableBuilder(
      column: $table.sleepQuality, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get updatedAtUtc => $composableBuilder(
      column: $table.updatedAtUtc, builder: (column) => column);
}

class $$CycleDailyLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CycleDailyLogsTable,
    CycleDailyLogRow,
    $$CycleDailyLogsTableFilterComposer,
    $$CycleDailyLogsTableOrderingComposer,
    $$CycleDailyLogsTableAnnotationComposer,
    $$CycleDailyLogsTableCreateCompanionBuilder,
    $$CycleDailyLogsTableUpdateCompanionBuilder,
    (
      CycleDailyLogRow,
      BaseReferences<_$AppDatabase, $CycleDailyLogsTable, CycleDailyLogRow>
    ),
    CycleDailyLogRow,
    PrefetchHooks Function()> {
  $$CycleDailyLogsTableTableManager(
      _$AppDatabase db, $CycleDailyLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CycleDailyLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CycleDailyLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CycleDailyLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> day = const Value.absent(),
            Value<String?> bleeding = const Value.absent(),
            Value<String?> mood = const Value.absent(),
            Value<int?> pain = const Value.absent(),
            Value<int?> energy = const Value.absent(),
            Value<int?> sleepQuality = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> updatedAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CycleDailyLogsCompanion(
            day: day,
            bleeding: bleeding,
            mood: mood,
            pain: pain,
            energy: energy,
            sleepQuality: sleepQuality,
            notes: notes,
            tagsJson: tagsJson,
            source: source,
            updatedAtUtc: updatedAtUtc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String day,
            Value<String?> bleeding = const Value.absent(),
            Value<String?> mood = const Value.absent(),
            Value<int?> pain = const Value.absent(),
            Value<int?> energy = const Value.absent(),
            Value<int?> sleepQuality = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<String> source = const Value.absent(),
            required String updatedAtUtc,
            Value<int> rowid = const Value.absent(),
          }) =>
              CycleDailyLogsCompanion.insert(
            day: day,
            bleeding: bleeding,
            mood: mood,
            pain: pain,
            energy: energy,
            sleepQuality: sleepQuality,
            notes: notes,
            tagsJson: tagsJson,
            source: source,
            updatedAtUtc: updatedAtUtc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CycleDailyLogsTable, CycleDailyLogRow>(table),
                    BaseReferences<_$AppDatabase, $CycleDailyLogsTable,
                        CycleDailyLogRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CycleDailyLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CycleDailyLogsTable,
    CycleDailyLogRow,
    $$CycleDailyLogsTableFilterComposer,
    $$CycleDailyLogsTableOrderingComposer,
    $$CycleDailyLogsTableAnnotationComposer,
    $$CycleDailyLogsTableCreateCompanionBuilder,
    $$CycleDailyLogsTableUpdateCompanionBuilder,
    (
      CycleDailyLogRow,
      BaseReferences<_$AppDatabase, $CycleDailyLogsTable, CycleDailyLogRow>
    ),
    CycleDailyLogRow,
    PrefetchHooks Function()>;
typedef $$SymptomDefinitionsTableCreateCompanionBuilder
    = SymptomDefinitionsCompanion Function({
  required String id,
  required String name,
  Value<bool> enabled,
  Value<int> rowid,
});
typedef $$SymptomDefinitionsTableUpdateCompanionBuilder
    = SymptomDefinitionsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<bool> enabled,
  Value<int> rowid,
});

class $$SymptomDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $SymptomDefinitionsTable> {
  $$SymptomDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));
}

class $$SymptomDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SymptomDefinitionsTable> {
  $$SymptomDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));
}

class $$SymptomDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SymptomDefinitionsTable> {
  $$SymptomDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$SymptomDefinitionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SymptomDefinitionsTable,
    SymptomDefinitionRow,
    $$SymptomDefinitionsTableFilterComposer,
    $$SymptomDefinitionsTableOrderingComposer,
    $$SymptomDefinitionsTableAnnotationComposer,
    $$SymptomDefinitionsTableCreateCompanionBuilder,
    $$SymptomDefinitionsTableUpdateCompanionBuilder,
    (
      SymptomDefinitionRow,
      BaseReferences<_$AppDatabase, $SymptomDefinitionsTable,
          SymptomDefinitionRow>
    ),
    SymptomDefinitionRow,
    PrefetchHooks Function()> {
  $$SymptomDefinitionsTableTableManager(
      _$AppDatabase db, $SymptomDefinitionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SymptomDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SymptomDefinitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SymptomDefinitionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SymptomDefinitionsCompanion(
            id: id,
            name: name,
            enabled: enabled,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<bool> enabled = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SymptomDefinitionsCompanion.insert(
            id: id,
            name: name,
            enabled: enabled,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SymptomDefinitionsTable, SymptomDefinitionRow>(
                        table),
                    BaseReferences<_$AppDatabase, $SymptomDefinitionsTable,
                        SymptomDefinitionRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SymptomDefinitionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SymptomDefinitionsTable,
    SymptomDefinitionRow,
    $$SymptomDefinitionsTableFilterComposer,
    $$SymptomDefinitionsTableOrderingComposer,
    $$SymptomDefinitionsTableAnnotationComposer,
    $$SymptomDefinitionsTableCreateCompanionBuilder,
    $$SymptomDefinitionsTableUpdateCompanionBuilder,
    (
      SymptomDefinitionRow,
      BaseReferences<_$AppDatabase, $SymptomDefinitionsTable,
          SymptomDefinitionRow>
    ),
    SymptomDefinitionRow,
    PrefetchHooks Function()>;
typedef $$SymptomLogsTableCreateCompanionBuilder = SymptomLogsCompanion
    Function({
  required String id,
  required String day,
  required String symptomId,
  Value<int> intensity,
  Value<int> rowid,
});
typedef $$SymptomLogsTableUpdateCompanionBuilder = SymptomLogsCompanion
    Function({
  Value<String> id,
  Value<String> day,
  Value<String> symptomId,
  Value<int> intensity,
  Value<int> rowid,
});

class $$SymptomLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SymptomLogsTable> {
  $$SymptomLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symptomId => $composableBuilder(
      column: $table.symptomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get intensity => $composableBuilder(
      column: $table.intensity, builder: (column) => ColumnFilters(column));
}

class $$SymptomLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SymptomLogsTable> {
  $$SymptomLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symptomId => $composableBuilder(
      column: $table.symptomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get intensity => $composableBuilder(
      column: $table.intensity, builder: (column) => ColumnOrderings(column));
}

class $$SymptomLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SymptomLogsTable> {
  $$SymptomLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get symptomId =>
      $composableBuilder(column: $table.symptomId, builder: (column) => column);

  GeneratedColumn<int> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);
}

class $$SymptomLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SymptomLogsTable,
    SymptomLogRow,
    $$SymptomLogsTableFilterComposer,
    $$SymptomLogsTableOrderingComposer,
    $$SymptomLogsTableAnnotationComposer,
    $$SymptomLogsTableCreateCompanionBuilder,
    $$SymptomLogsTableUpdateCompanionBuilder,
    (
      SymptomLogRow,
      BaseReferences<_$AppDatabase, $SymptomLogsTable, SymptomLogRow>
    ),
    SymptomLogRow,
    PrefetchHooks Function()> {
  $$SymptomLogsTableTableManager(_$AppDatabase db, $SymptomLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SymptomLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SymptomLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SymptomLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> day = const Value.absent(),
            Value<String> symptomId = const Value.absent(),
            Value<int> intensity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SymptomLogsCompanion(
            id: id,
            day: day,
            symptomId: symptomId,
            intensity: intensity,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String day,
            required String symptomId,
            Value<int> intensity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SymptomLogsCompanion.insert(
            id: id,
            day: day,
            symptomId: symptomId,
            intensity: intensity,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SymptomLogsTable, SymptomLogRow>(table),
                    BaseReferences<_$AppDatabase, $SymptomLogsTable,
                        SymptomLogRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SymptomLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SymptomLogsTable,
    SymptomLogRow,
    $$SymptomLogsTableFilterComposer,
    $$SymptomLogsTableOrderingComposer,
    $$SymptomLogsTableAnnotationComposer,
    $$SymptomLogsTableCreateCompanionBuilder,
    $$SymptomLogsTableUpdateCompanionBuilder,
    (
      SymptomLogRow,
      BaseReferences<_$AppDatabase, $SymptomLogsTable, SymptomLogRow>
    ),
    SymptomLogRow,
    PrefetchHooks Function()>;
typedef $$CyclePredictionsTableCreateCompanionBuilder
    = CyclePredictionsCompanion Function({
  required String id,
  required String kind,
  required String windowStart,
  required String windowEnd,
  required double confidence,
  required String rationale,
  required String calculatedAtUtc,
  Value<int> rowid,
});
typedef $$CyclePredictionsTableUpdateCompanionBuilder
    = CyclePredictionsCompanion Function({
  Value<String> id,
  Value<String> kind,
  Value<String> windowStart,
  Value<String> windowEnd,
  Value<double> confidence,
  Value<String> rationale,
  Value<String> calculatedAtUtc,
  Value<int> rowid,
});

class $$CyclePredictionsTableFilterComposer
    extends Composer<_$AppDatabase, $CyclePredictionsTable> {
  $$CyclePredictionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get windowStart => $composableBuilder(
      column: $table.windowStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get windowEnd => $composableBuilder(
      column: $table.windowEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rationale => $composableBuilder(
      column: $table.rationale, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get calculatedAtUtc => $composableBuilder(
      column: $table.calculatedAtUtc,
      builder: (column) => ColumnFilters(column));
}

class $$CyclePredictionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CyclePredictionsTable> {
  $$CyclePredictionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get windowStart => $composableBuilder(
      column: $table.windowStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get windowEnd => $composableBuilder(
      column: $table.windowEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rationale => $composableBuilder(
      column: $table.rationale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get calculatedAtUtc => $composableBuilder(
      column: $table.calculatedAtUtc,
      builder: (column) => ColumnOrderings(column));
}

class $$CyclePredictionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CyclePredictionsTable> {
  $$CyclePredictionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get windowStart => $composableBuilder(
      column: $table.windowStart, builder: (column) => column);

  GeneratedColumn<String> get windowEnd =>
      $composableBuilder(column: $table.windowEnd, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get rationale =>
      $composableBuilder(column: $table.rationale, builder: (column) => column);

  GeneratedColumn<String> get calculatedAtUtc => $composableBuilder(
      column: $table.calculatedAtUtc, builder: (column) => column);
}

class $$CyclePredictionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CyclePredictionsTable,
    CyclePredictionRow,
    $$CyclePredictionsTableFilterComposer,
    $$CyclePredictionsTableOrderingComposer,
    $$CyclePredictionsTableAnnotationComposer,
    $$CyclePredictionsTableCreateCompanionBuilder,
    $$CyclePredictionsTableUpdateCompanionBuilder,
    (
      CyclePredictionRow,
      BaseReferences<_$AppDatabase, $CyclePredictionsTable, CyclePredictionRow>
    ),
    CyclePredictionRow,
    PrefetchHooks Function()> {
  $$CyclePredictionsTableTableManager(
      _$AppDatabase db, $CyclePredictionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CyclePredictionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CyclePredictionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CyclePredictionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> windowStart = const Value.absent(),
            Value<String> windowEnd = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<String> rationale = const Value.absent(),
            Value<String> calculatedAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CyclePredictionsCompanion(
            id: id,
            kind: kind,
            windowStart: windowStart,
            windowEnd: windowEnd,
            confidence: confidence,
            rationale: rationale,
            calculatedAtUtc: calculatedAtUtc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String kind,
            required String windowStart,
            required String windowEnd,
            required double confidence,
            required String rationale,
            required String calculatedAtUtc,
            Value<int> rowid = const Value.absent(),
          }) =>
              CyclePredictionsCompanion.insert(
            id: id,
            kind: kind,
            windowStart: windowStart,
            windowEnd: windowEnd,
            confidence: confidence,
            rationale: rationale,
            calculatedAtUtc: calculatedAtUtc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CyclePredictionsTable, CyclePredictionRow>(
                        table),
                    BaseReferences<_$AppDatabase, $CyclePredictionsTable,
                        CyclePredictionRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CyclePredictionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CyclePredictionsTable,
    CyclePredictionRow,
    $$CyclePredictionsTableFilterComposer,
    $$CyclePredictionsTableOrderingComposer,
    $$CyclePredictionsTableAnnotationComposer,
    $$CyclePredictionsTableCreateCompanionBuilder,
    $$CyclePredictionsTableUpdateCompanionBuilder,
    (
      CyclePredictionRow,
      BaseReferences<_$AppDatabase, $CyclePredictionsTable, CyclePredictionRow>
    ),
    CyclePredictionRow,
    PrefetchHooks Function()>;
typedef $$NotificationPreferencesTableCreateCompanionBuilder
    = NotificationPreferencesCompanion Function({
  required String id,
  Value<bool> enabled,
  Value<int> leadMinutes,
  Value<String?> quietStart,
  Value<String?> quietEnd,
  Value<String> weekdaysJson,
  Value<bool> discreteLockScreen,
  Value<int> rowid,
});
typedef $$NotificationPreferencesTableUpdateCompanionBuilder
    = NotificationPreferencesCompanion Function({
  Value<String> id,
  Value<bool> enabled,
  Value<int> leadMinutes,
  Value<String?> quietStart,
  Value<String?> quietEnd,
  Value<String> weekdaysJson,
  Value<bool> discreteLockScreen,
  Value<int> rowid,
});

class $$NotificationPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationPreferencesTable> {
  $$NotificationPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get leadMinutes => $composableBuilder(
      column: $table.leadMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quietStart => $composableBuilder(
      column: $table.quietStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quietEnd => $composableBuilder(
      column: $table.quietEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weekdaysJson => $composableBuilder(
      column: $table.weekdaysJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get discreteLockScreen => $composableBuilder(
      column: $table.discreteLockScreen,
      builder: (column) => ColumnFilters(column));
}

class $$NotificationPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationPreferencesTable> {
  $$NotificationPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get leadMinutes => $composableBuilder(
      column: $table.leadMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quietStart => $composableBuilder(
      column: $table.quietStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quietEnd => $composableBuilder(
      column: $table.quietEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weekdaysJson => $composableBuilder(
      column: $table.weekdaysJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get discreteLockScreen => $composableBuilder(
      column: $table.discreteLockScreen,
      builder: (column) => ColumnOrderings(column));
}

class $$NotificationPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationPreferencesTable> {
  $$NotificationPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get leadMinutes => $composableBuilder(
      column: $table.leadMinutes, builder: (column) => column);

  GeneratedColumn<String> get quietStart => $composableBuilder(
      column: $table.quietStart, builder: (column) => column);

  GeneratedColumn<String> get quietEnd =>
      $composableBuilder(column: $table.quietEnd, builder: (column) => column);

  GeneratedColumn<String> get weekdaysJson => $composableBuilder(
      column: $table.weekdaysJson, builder: (column) => column);

  GeneratedColumn<bool> get discreteLockScreen => $composableBuilder(
      column: $table.discreteLockScreen, builder: (column) => column);
}

class $$NotificationPreferencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationPreferencesTable,
    NotificationPreferenceRow,
    $$NotificationPreferencesTableFilterComposer,
    $$NotificationPreferencesTableOrderingComposer,
    $$NotificationPreferencesTableAnnotationComposer,
    $$NotificationPreferencesTableCreateCompanionBuilder,
    $$NotificationPreferencesTableUpdateCompanionBuilder,
    (
      NotificationPreferenceRow,
      BaseReferences<_$AppDatabase, $NotificationPreferencesTable,
          NotificationPreferenceRow>
    ),
    NotificationPreferenceRow,
    PrefetchHooks Function()> {
  $$NotificationPreferencesTableTableManager(
      _$AppDatabase db, $NotificationPreferencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationPreferencesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationPreferencesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationPreferencesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<int> leadMinutes = const Value.absent(),
            Value<String?> quietStart = const Value.absent(),
            Value<String?> quietEnd = const Value.absent(),
            Value<String> weekdaysJson = const Value.absent(),
            Value<bool> discreteLockScreen = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationPreferencesCompanion(
            id: id,
            enabled: enabled,
            leadMinutes: leadMinutes,
            quietStart: quietStart,
            quietEnd: quietEnd,
            weekdaysJson: weekdaysJson,
            discreteLockScreen: discreteLockScreen,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<bool> enabled = const Value.absent(),
            Value<int> leadMinutes = const Value.absent(),
            Value<String?> quietStart = const Value.absent(),
            Value<String?> quietEnd = const Value.absent(),
            Value<String> weekdaysJson = const Value.absent(),
            Value<bool> discreteLockScreen = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationPreferencesCompanion.insert(
            id: id,
            enabled: enabled,
            leadMinutes: leadMinutes,
            quietStart: quietStart,
            quietEnd: quietEnd,
            weekdaysJson: weekdaysJson,
            discreteLockScreen: discreteLockScreen,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$NotificationPreferencesTable,
                        NotificationPreferenceRow>(table),
                    BaseReferences<_$AppDatabase, $NotificationPreferencesTable,
                        NotificationPreferenceRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotificationPreferencesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $NotificationPreferencesTable,
        NotificationPreferenceRow,
        $$NotificationPreferencesTableFilterComposer,
        $$NotificationPreferencesTableOrderingComposer,
        $$NotificationPreferencesTableAnnotationComposer,
        $$NotificationPreferencesTableCreateCompanionBuilder,
        $$NotificationPreferencesTableUpdateCompanionBuilder,
        (
          NotificationPreferenceRow,
          BaseReferences<_$AppDatabase, $NotificationPreferencesTable,
              NotificationPreferenceRow>
        ),
        NotificationPreferenceRow,
        PrefetchHooks Function()>;
typedef $$BackupManifestsTableCreateCompanionBuilder = BackupManifestsCompanion
    Function({
  required String id,
  required int schemaVersion,
  required String appVersion,
  required String createdAtUtc,
  required String categoriesJson,
  required int recordCount,
  Value<int> rowid,
});
typedef $$BackupManifestsTableUpdateCompanionBuilder = BackupManifestsCompanion
    Function({
  Value<String> id,
  Value<int> schemaVersion,
  Value<String> appVersion,
  Value<String> createdAtUtc,
  Value<String> categoriesJson,
  Value<int> recordCount,
  Value<int> rowid,
});

class $$BackupManifestsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupManifestsTable> {
  $$BackupManifestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appVersion => $composableBuilder(
      column: $table.appVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoriesJson => $composableBuilder(
      column: $table.categoriesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recordCount => $composableBuilder(
      column: $table.recordCount, builder: (column) => ColumnFilters(column));
}

class $$BackupManifestsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupManifestsTable> {
  $$BackupManifestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appVersion => $composableBuilder(
      column: $table.appVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoriesJson => $composableBuilder(
      column: $table.categoriesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recordCount => $composableBuilder(
      column: $table.recordCount, builder: (column) => ColumnOrderings(column));
}

class $$BackupManifestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupManifestsTable> {
  $$BackupManifestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
      column: $table.schemaVersion, builder: (column) => column);

  GeneratedColumn<String> get appVersion => $composableBuilder(
      column: $table.appVersion, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => column);

  GeneratedColumn<String> get categoriesJson => $composableBuilder(
      column: $table.categoriesJson, builder: (column) => column);

  GeneratedColumn<int> get recordCount => $composableBuilder(
      column: $table.recordCount, builder: (column) => column);
}

class $$BackupManifestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BackupManifestsTable,
    BackupManifestRow,
    $$BackupManifestsTableFilterComposer,
    $$BackupManifestsTableOrderingComposer,
    $$BackupManifestsTableAnnotationComposer,
    $$BackupManifestsTableCreateCompanionBuilder,
    $$BackupManifestsTableUpdateCompanionBuilder,
    (
      BackupManifestRow,
      BaseReferences<_$AppDatabase, $BackupManifestsTable, BackupManifestRow>
    ),
    BackupManifestRow,
    PrefetchHooks Function()> {
  $$BackupManifestsTableTableManager(
      _$AppDatabase db, $BackupManifestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupManifestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupManifestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupManifestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> schemaVersion = const Value.absent(),
            Value<String> appVersion = const Value.absent(),
            Value<String> createdAtUtc = const Value.absent(),
            Value<String> categoriesJson = const Value.absent(),
            Value<int> recordCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BackupManifestsCompanion(
            id: id,
            schemaVersion: schemaVersion,
            appVersion: appVersion,
            createdAtUtc: createdAtUtc,
            categoriesJson: categoriesJson,
            recordCount: recordCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int schemaVersion,
            required String appVersion,
            required String createdAtUtc,
            required String categoriesJson,
            required int recordCount,
            Value<int> rowid = const Value.absent(),
          }) =>
              BackupManifestsCompanion.insert(
            id: id,
            schemaVersion: schemaVersion,
            appVersion: appVersion,
            createdAtUtc: createdAtUtc,
            categoriesJson: categoriesJson,
            recordCount: recordCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$BackupManifestsTable, BackupManifestRow>(
                        table),
                    BaseReferences<_$AppDatabase, $BackupManifestsTable,
                        BackupManifestRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BackupManifestsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BackupManifestsTable,
    BackupManifestRow,
    $$BackupManifestsTableFilterComposer,
    $$BackupManifestsTableOrderingComposer,
    $$BackupManifestsTableAnnotationComposer,
    $$BackupManifestsTableCreateCompanionBuilder,
    $$BackupManifestsTableUpdateCompanionBuilder,
    (
      BackupManifestRow,
      BaseReferences<_$AppDatabase, $BackupManifestsTable, BackupManifestRow>
    ),
    BackupManifestRow,
    PrefetchHooks Function()>;
typedef $$GymExercisesTableCreateCompanionBuilder = GymExercisesCompanion
    Function({
  required String id,
  required String name,
  required String primaryMuscle,
  Value<String> secondaryMusclesJson,
  required String equipment,
  Value<String?> instructions,
  Value<String?> gifUrl,
  Value<bool> isCustom,
  Value<bool> isTimed,
  Value<int> rowid,
});
typedef $$GymExercisesTableUpdateCompanionBuilder = GymExercisesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> primaryMuscle,
  Value<String> secondaryMusclesJson,
  Value<String> equipment,
  Value<String?> instructions,
  Value<String?> gifUrl,
  Value<bool> isCustom,
  Value<bool> isTimed,
  Value<int> rowid,
});

final class $$GymExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $GymExercisesTable, GymExerciseRow> {
  $$GymExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GymPlanRoutineExercisesTable,
      List<GymPlanRoutineExerciseRow>> _gymPlanRoutineExercisesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.gymPlanRoutineExercises,
          aliasName:
              'gym_exercises__id__gym_plan_routine_exercises__exercise_id');

  $$GymPlanRoutineExercisesTableProcessedTableManager
      get gymPlanRoutineExercisesRefs {
    final manager = $$GymPlanRoutineExercisesTableTableManager(
            $_db, $_db.gymPlanRoutineExercises)
        .filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_gymPlanRoutineExercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GymSetLogsTable, List<GymSetLogRow>>
      _gymSetLogsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.gymSetLogs,
              aliasName: 'gym_exercises__id__gym_set_logs__exercise_id');

  $$GymSetLogsTableProcessedTableManager get gymSetLogsRefs {
    final manager = $$GymSetLogsTableTableManager($_db, $_db.gymSetLogs)
        .filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gymSetLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$Gym1RmHistoriesTable, List<Gym1RmHistoryRow>>
      _gym1RmHistoriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.gym1RmHistories,
              aliasName: 'gym_exercises__id__gym1_rm_histories__exercise_id');

  $$Gym1RmHistoriesTableProcessedTableManager get gym1RmHistoriesRefs {
    final manager = $$Gym1RmHistoriesTableTableManager(
            $_db, $_db.gym1RmHistories)
        .filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_gym1RmHistoriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GymExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $GymExercisesTable> {
  $$GymExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get primaryMuscle => $composableBuilder(
      column: $table.primaryMuscle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get secondaryMusclesJson => $composableBuilder(
      column: $table.secondaryMusclesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get equipment => $composableBuilder(
      column: $table.equipment, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instructions => $composableBuilder(
      column: $table.instructions, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gifUrl => $composableBuilder(
      column: $table.gifUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isTimed => $composableBuilder(
      column: $table.isTimed, builder: (column) => ColumnFilters(column));

  Expression<bool> gymPlanRoutineExercisesRefs(
      Expression<bool> Function($$GymPlanRoutineExercisesTableFilterComposer f)
          f) {
    final $$GymPlanRoutineExercisesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.gymPlanRoutineExercises,
            getReferencedColumn: (t) => t.exerciseId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$GymPlanRoutineExercisesTableFilterComposer(
                  $db: $db,
                  $table: $db.gymPlanRoutineExercises,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> gymSetLogsRefs(
      Expression<bool> Function($$GymSetLogsTableFilterComposer f) f) {
    final $$GymSetLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gymSetLogs,
        getReferencedColumn: (t) => t.exerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymSetLogsTableFilterComposer(
              $db: $db,
              $table: $db.gymSetLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> gym1RmHistoriesRefs(
      Expression<bool> Function($$Gym1RmHistoriesTableFilterComposer f) f) {
    final $$Gym1RmHistoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gym1RmHistories,
        getReferencedColumn: (t) => t.exerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$Gym1RmHistoriesTableFilterComposer(
              $db: $db,
              $table: $db.gym1RmHistories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GymExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $GymExercisesTable> {
  $$GymExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get primaryMuscle => $composableBuilder(
      column: $table.primaryMuscle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get secondaryMusclesJson => $composableBuilder(
      column: $table.secondaryMusclesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get equipment => $composableBuilder(
      column: $table.equipment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instructions => $composableBuilder(
      column: $table.instructions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gifUrl => $composableBuilder(
      column: $table.gifUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isTimed => $composableBuilder(
      column: $table.isTimed, builder: (column) => ColumnOrderings(column));
}

class $$GymExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GymExercisesTable> {
  $$GymExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get primaryMuscle => $composableBuilder(
      column: $table.primaryMuscle, builder: (column) => column);

  GeneratedColumn<String> get secondaryMusclesJson => $composableBuilder(
      column: $table.secondaryMusclesJson, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get instructions => $composableBuilder(
      column: $table.instructions, builder: (column) => column);

  GeneratedColumn<String> get gifUrl =>
      $composableBuilder(column: $table.gifUrl, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<bool> get isTimed =>
      $composableBuilder(column: $table.isTimed, builder: (column) => column);

  Expression<T> gymPlanRoutineExercisesRefs<T extends Object>(
      Expression<T> Function($$GymPlanRoutineExercisesTableAnnotationComposer a)
          f) {
    final $$GymPlanRoutineExercisesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.gymPlanRoutineExercises,
            getReferencedColumn: (t) => t.exerciseId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$GymPlanRoutineExercisesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.gymPlanRoutineExercises,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> gymSetLogsRefs<T extends Object>(
      Expression<T> Function($$GymSetLogsTableAnnotationComposer a) f) {
    final $$GymSetLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gymSetLogs,
        getReferencedColumn: (t) => t.exerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymSetLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.gymSetLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> gym1RmHistoriesRefs<T extends Object>(
      Expression<T> Function($$Gym1RmHistoriesTableAnnotationComposer a) f) {
    final $$Gym1RmHistoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gym1RmHistories,
        getReferencedColumn: (t) => t.exerciseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$Gym1RmHistoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.gym1RmHistories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GymExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GymExercisesTable,
    GymExerciseRow,
    $$GymExercisesTableFilterComposer,
    $$GymExercisesTableOrderingComposer,
    $$GymExercisesTableAnnotationComposer,
    $$GymExercisesTableCreateCompanionBuilder,
    $$GymExercisesTableUpdateCompanionBuilder,
    (GymExerciseRow, $$GymExercisesTableReferences),
    GymExerciseRow,
    PrefetchHooks Function(
        {bool gymPlanRoutineExercisesRefs,
        bool gymSetLogsRefs,
        bool gym1RmHistoriesRefs})> {
  $$GymExercisesTableTableManager(_$AppDatabase db, $GymExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GymExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GymExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GymExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> primaryMuscle = const Value.absent(),
            Value<String> secondaryMusclesJson = const Value.absent(),
            Value<String> equipment = const Value.absent(),
            Value<String?> instructions = const Value.absent(),
            Value<String?> gifUrl = const Value.absent(),
            Value<bool> isCustom = const Value.absent(),
            Value<bool> isTimed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GymExercisesCompanion(
            id: id,
            name: name,
            primaryMuscle: primaryMuscle,
            secondaryMusclesJson: secondaryMusclesJson,
            equipment: equipment,
            instructions: instructions,
            gifUrl: gifUrl,
            isCustom: isCustom,
            isTimed: isTimed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String primaryMuscle,
            Value<String> secondaryMusclesJson = const Value.absent(),
            required String equipment,
            Value<String?> instructions = const Value.absent(),
            Value<String?> gifUrl = const Value.absent(),
            Value<bool> isCustom = const Value.absent(),
            Value<bool> isTimed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GymExercisesCompanion.insert(
            id: id,
            name: name,
            primaryMuscle: primaryMuscle,
            secondaryMusclesJson: secondaryMusclesJson,
            equipment: equipment,
            instructions: instructions,
            gifUrl: gifUrl,
            isCustom: isCustom,
            isTimed: isTimed,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$GymExercisesTable, GymExerciseRow>(table),
                    $$GymExercisesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {gymPlanRoutineExercisesRefs = false,
              gymSetLogsRefs = false,
              gym1RmHistoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (gymPlanRoutineExercisesRefs) db.gymPlanRoutineExercises,
                if (gymSetLogsRefs) db.gymSetLogs,
                if (gym1RmHistoriesRefs) db.gym1RmHistories
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gymPlanRoutineExercisesRefs)
                    await $_getPrefetchedData<GymExerciseRow,
                            $GymExercisesTable, GymPlanRoutineExerciseRow>(
                        currentTable: table,
                        referencedTable: $$GymExercisesTableReferences
                            ._gymPlanRoutineExercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GymExercisesTableReferences(db, table, p0)
                                .gymPlanRoutineExercisesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.exerciseId == item.id),
                        typedResults: items),
                  if (gymSetLogsRefs)
                    await $_getPrefetchedData<GymExerciseRow, $GymExercisesTable,
                            GymSetLogRow>(
                        currentTable: table,
                        referencedTable: $$GymExercisesTableReferences
                            ._gymSetLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GymExercisesTableReferences(db, table, p0)
                                .gymSetLogsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.exerciseId == item.id),
                        typedResults: items),
                  if (gym1RmHistoriesRefs)
                    await $_getPrefetchedData<GymExerciseRow,
                            $GymExercisesTable, Gym1RmHistoryRow>(
                        currentTable: table,
                        referencedTable: $$GymExercisesTableReferences
                            ._gym1RmHistoriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GymExercisesTableReferences(db, table, p0)
                                .gym1RmHistoriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.exerciseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GymExercisesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GymExercisesTable,
    GymExerciseRow,
    $$GymExercisesTableFilterComposer,
    $$GymExercisesTableOrderingComposer,
    $$GymExercisesTableAnnotationComposer,
    $$GymExercisesTableCreateCompanionBuilder,
    $$GymExercisesTableUpdateCompanionBuilder,
    (GymExerciseRow, $$GymExercisesTableReferences),
    GymExerciseRow,
    PrefetchHooks Function(
        {bool gymPlanRoutineExercisesRefs,
        bool gymSetLogsRefs,
        bool gym1RmHistoriesRefs})>;
typedef $$GymWorkoutPlansTableCreateCompanionBuilder = GymWorkoutPlansCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<int> daysPerWeek,
  Value<bool> isActive,
  required String createdAtUtc,
  Value<int> rowid,
});
typedef $$GymWorkoutPlansTableUpdateCompanionBuilder = GymWorkoutPlansCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<int> daysPerWeek,
  Value<bool> isActive,
  Value<String> createdAtUtc,
  Value<int> rowid,
});

final class $$GymWorkoutPlansTableReferences extends BaseReferences<
    _$AppDatabase, $GymWorkoutPlansTable, GymWorkoutPlanRow> {
  $$GymWorkoutPlansTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GymPlanRoutinesTable, List<GymPlanRoutineRow>>
      _gymPlanRoutinesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.gymPlanRoutines,
              aliasName: 'gym_workout_plans__id__gym_plan_routines__plan_id');

  $$GymPlanRoutinesTableProcessedTableManager get gymPlanRoutinesRefs {
    final manager =
        $$GymPlanRoutinesTableTableManager($_db, $_db.gymPlanRoutines)
            .filter((f) => f.planId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_gymPlanRoutinesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GymWorkoutPlansTableFilterComposer
    extends Composer<_$AppDatabase, $GymWorkoutPlansTable> {
  $$GymWorkoutPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get daysPerWeek => $composableBuilder(
      column: $table.daysPerWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => ColumnFilters(column));

  Expression<bool> gymPlanRoutinesRefs(
      Expression<bool> Function($$GymPlanRoutinesTableFilterComposer f) f) {
    final $$GymPlanRoutinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gymPlanRoutines,
        getReferencedColumn: (t) => t.planId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymPlanRoutinesTableFilterComposer(
              $db: $db,
              $table: $db.gymPlanRoutines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GymWorkoutPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $GymWorkoutPlansTable> {
  $$GymWorkoutPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get daysPerWeek => $composableBuilder(
      column: $table.daysPerWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc,
      builder: (column) => ColumnOrderings(column));
}

class $$GymWorkoutPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $GymWorkoutPlansTable> {
  $$GymWorkoutPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get daysPerWeek => $composableBuilder(
      column: $table.daysPerWeek, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
      column: $table.createdAtUtc, builder: (column) => column);

  Expression<T> gymPlanRoutinesRefs<T extends Object>(
      Expression<T> Function($$GymPlanRoutinesTableAnnotationComposer a) f) {
    final $$GymPlanRoutinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gymPlanRoutines,
        getReferencedColumn: (t) => t.planId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymPlanRoutinesTableAnnotationComposer(
              $db: $db,
              $table: $db.gymPlanRoutines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GymWorkoutPlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GymWorkoutPlansTable,
    GymWorkoutPlanRow,
    $$GymWorkoutPlansTableFilterComposer,
    $$GymWorkoutPlansTableOrderingComposer,
    $$GymWorkoutPlansTableAnnotationComposer,
    $$GymWorkoutPlansTableCreateCompanionBuilder,
    $$GymWorkoutPlansTableUpdateCompanionBuilder,
    (GymWorkoutPlanRow, $$GymWorkoutPlansTableReferences),
    GymWorkoutPlanRow,
    PrefetchHooks Function({bool gymPlanRoutinesRefs})> {
  $$GymWorkoutPlansTableTableManager(
      _$AppDatabase db, $GymWorkoutPlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GymWorkoutPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GymWorkoutPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GymWorkoutPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> daysPerWeek = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> createdAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GymWorkoutPlansCompanion(
            id: id,
            name: name,
            description: description,
            daysPerWeek: daysPerWeek,
            isActive: isActive,
            createdAtUtc: createdAtUtc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<int> daysPerWeek = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required String createdAtUtc,
            Value<int> rowid = const Value.absent(),
          }) =>
              GymWorkoutPlansCompanion.insert(
            id: id,
            name: name,
            description: description,
            daysPerWeek: daysPerWeek,
            isActive: isActive,
            createdAtUtc: createdAtUtc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$GymWorkoutPlansTable, GymWorkoutPlanRow>(
                        table),
                    $$GymWorkoutPlansTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({gymPlanRoutinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (gymPlanRoutinesRefs) db.gymPlanRoutines
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gymPlanRoutinesRefs)
                    await $_getPrefetchedData<GymWorkoutPlanRow,
                            $GymWorkoutPlansTable, GymPlanRoutineRow>(
                        currentTable: table,
                        referencedTable: $$GymWorkoutPlansTableReferences
                            ._gymPlanRoutinesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GymWorkoutPlansTableReferences(db, table, p0)
                                .gymPlanRoutinesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.planId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GymWorkoutPlansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GymWorkoutPlansTable,
    GymWorkoutPlanRow,
    $$GymWorkoutPlansTableFilterComposer,
    $$GymWorkoutPlansTableOrderingComposer,
    $$GymWorkoutPlansTableAnnotationComposer,
    $$GymWorkoutPlansTableCreateCompanionBuilder,
    $$GymWorkoutPlansTableUpdateCompanionBuilder,
    (GymWorkoutPlanRow, $$GymWorkoutPlansTableReferences),
    GymWorkoutPlanRow,
    PrefetchHooks Function({bool gymPlanRoutinesRefs})>;
typedef $$GymPlanRoutinesTableCreateCompanionBuilder = GymPlanRoutinesCompanion
    Function({
  required String id,
  required String planId,
  required int dayOfWeek,
  required String name,
  Value<String> progressionType,
  Value<int> rowid,
});
typedef $$GymPlanRoutinesTableUpdateCompanionBuilder = GymPlanRoutinesCompanion
    Function({
  Value<String> id,
  Value<String> planId,
  Value<int> dayOfWeek,
  Value<String> name,
  Value<String> progressionType,
  Value<int> rowid,
});

final class $$GymPlanRoutinesTableReferences extends BaseReferences<
    _$AppDatabase, $GymPlanRoutinesTable, GymPlanRoutineRow> {
  $$GymPlanRoutinesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $GymWorkoutPlansTable _planIdTable(_$AppDatabase db) =>
      db.gymWorkoutPlans
          .createAlias('gym_plan_routines__plan_id__gym_workout_plans__id');

  $$GymWorkoutPlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<String>('plan_id')!;

    final manager =
        $$GymWorkoutPlansTableTableManager($_db, $_db.gymWorkoutPlans)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$GymPlanRoutineExercisesTable,
      List<GymPlanRoutineExerciseRow>> _gymPlanRoutineExercisesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.gymPlanRoutineExercises,
          aliasName:
              'gym_plan_routines__id__gym_plan_routine_exercises__routine_id');

  $$GymPlanRoutineExercisesTableProcessedTableManager
      get gymPlanRoutineExercisesRefs {
    final manager = $$GymPlanRoutineExercisesTableTableManager(
            $_db, $_db.gymPlanRoutineExercises)
        .filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_gymPlanRoutineExercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GymPlanRoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $GymPlanRoutinesTable> {
  $$GymPlanRoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get progressionType => $composableBuilder(
      column: $table.progressionType,
      builder: (column) => ColumnFilters(column));

  $$GymWorkoutPlansTableFilterComposer get planId {
    final $$GymWorkoutPlansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.gymWorkoutPlans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymWorkoutPlansTableFilterComposer(
              $db: $db,
              $table: $db.gymWorkoutPlans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> gymPlanRoutineExercisesRefs(
      Expression<bool> Function($$GymPlanRoutineExercisesTableFilterComposer f)
          f) {
    final $$GymPlanRoutineExercisesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.gymPlanRoutineExercises,
            getReferencedColumn: (t) => t.routineId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$GymPlanRoutineExercisesTableFilterComposer(
                  $db: $db,
                  $table: $db.gymPlanRoutineExercises,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$GymPlanRoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $GymPlanRoutinesTable> {
  $$GymPlanRoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get progressionType => $composableBuilder(
      column: $table.progressionType,
      builder: (column) => ColumnOrderings(column));

  $$GymWorkoutPlansTableOrderingComposer get planId {
    final $$GymWorkoutPlansTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.gymWorkoutPlans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymWorkoutPlansTableOrderingComposer(
              $db: $db,
              $table: $db.gymWorkoutPlans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GymPlanRoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GymPlanRoutinesTable> {
  $$GymPlanRoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get progressionType => $composableBuilder(
      column: $table.progressionType, builder: (column) => column);

  $$GymWorkoutPlansTableAnnotationComposer get planId {
    final $$GymWorkoutPlansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.gymWorkoutPlans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymWorkoutPlansTableAnnotationComposer(
              $db: $db,
              $table: $db.gymWorkoutPlans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> gymPlanRoutineExercisesRefs<T extends Object>(
      Expression<T> Function($$GymPlanRoutineExercisesTableAnnotationComposer a)
          f) {
    final $$GymPlanRoutineExercisesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.gymPlanRoutineExercises,
            getReferencedColumn: (t) => t.routineId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$GymPlanRoutineExercisesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.gymPlanRoutineExercises,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$GymPlanRoutinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GymPlanRoutinesTable,
    GymPlanRoutineRow,
    $$GymPlanRoutinesTableFilterComposer,
    $$GymPlanRoutinesTableOrderingComposer,
    $$GymPlanRoutinesTableAnnotationComposer,
    $$GymPlanRoutinesTableCreateCompanionBuilder,
    $$GymPlanRoutinesTableUpdateCompanionBuilder,
    (GymPlanRoutineRow, $$GymPlanRoutinesTableReferences),
    GymPlanRoutineRow,
    PrefetchHooks Function({bool planId, bool gymPlanRoutineExercisesRefs})> {
  $$GymPlanRoutinesTableTableManager(
      _$AppDatabase db, $GymPlanRoutinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GymPlanRoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GymPlanRoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GymPlanRoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> planId = const Value.absent(),
            Value<int> dayOfWeek = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> progressionType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GymPlanRoutinesCompanion(
            id: id,
            planId: planId,
            dayOfWeek: dayOfWeek,
            name: name,
            progressionType: progressionType,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String planId,
            required int dayOfWeek,
            required String name,
            Value<String> progressionType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GymPlanRoutinesCompanion.insert(
            id: id,
            planId: planId,
            dayOfWeek: dayOfWeek,
            name: name,
            progressionType: progressionType,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$GymPlanRoutinesTable, GymPlanRoutineRow>(
                        table),
                    $$GymPlanRoutinesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {planId = false, gymPlanRoutineExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (gymPlanRoutineExercisesRefs) db.gymPlanRoutineExercises
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (planId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.planId,
                    referencedTable:
                        $$GymPlanRoutinesTableReferences._planIdTable(db),
                    referencedColumn:
                        $$GymPlanRoutinesTableReferences._planIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gymPlanRoutineExercisesRefs)
                    await $_getPrefetchedData<GymPlanRoutineRow,
                            $GymPlanRoutinesTable, GymPlanRoutineExerciseRow>(
                        currentTable: table,
                        referencedTable: $$GymPlanRoutinesTableReferences
                            ._gymPlanRoutineExercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GymPlanRoutinesTableReferences(db, table, p0)
                                .gymPlanRoutineExercisesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.routineId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GymPlanRoutinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GymPlanRoutinesTable,
    GymPlanRoutineRow,
    $$GymPlanRoutinesTableFilterComposer,
    $$GymPlanRoutinesTableOrderingComposer,
    $$GymPlanRoutinesTableAnnotationComposer,
    $$GymPlanRoutinesTableCreateCompanionBuilder,
    $$GymPlanRoutinesTableUpdateCompanionBuilder,
    (GymPlanRoutineRow, $$GymPlanRoutinesTableReferences),
    GymPlanRoutineRow,
    PrefetchHooks Function({bool planId, bool gymPlanRoutineExercisesRefs})>;
typedef $$GymPlanRoutineExercisesTableCreateCompanionBuilder
    = GymPlanRoutineExercisesCompanion Function({
  required String id,
  required String routineId,
  required String exerciseId,
  required int orderIndex,
  Value<int> targetSets,
  Value<int> targetRepsMin,
  Value<int> targetRepsMax,
  Value<int?> targetHoldSeconds,
  Value<int> restSeconds,
  Value<String?> supersetGroupId,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$GymPlanRoutineExercisesTableUpdateCompanionBuilder
    = GymPlanRoutineExercisesCompanion Function({
  Value<String> id,
  Value<String> routineId,
  Value<String> exerciseId,
  Value<int> orderIndex,
  Value<int> targetSets,
  Value<int> targetRepsMin,
  Value<int> targetRepsMax,
  Value<int?> targetHoldSeconds,
  Value<int> restSeconds,
  Value<String?> supersetGroupId,
  Value<String?> notes,
  Value<int> rowid,
});

final class $$GymPlanRoutineExercisesTableReferences extends BaseReferences<
    _$AppDatabase, $GymPlanRoutineExercisesTable, GymPlanRoutineExerciseRow> {
  $$GymPlanRoutineExercisesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $GymPlanRoutinesTable _routineIdTable(_$AppDatabase db) =>
      db.gymPlanRoutines.createAlias(
          'gym_plan_routine_exercises__routine_id__gym_plan_routines__id');

  $$GymPlanRoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager =
        $$GymPlanRoutinesTableTableManager($_db, $_db.gymPlanRoutines)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $GymExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.gymExercises.createAlias(
          'gym_plan_routine_exercises__exercise_id__gym_exercises__id');

  $$GymExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$GymExercisesTableTableManager($_db, $_db.gymExercises)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GymPlanRoutineExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $GymPlanRoutineExercisesTable> {
  $$GymPlanRoutineExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetRepsMin => $composableBuilder(
      column: $table.targetRepsMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetRepsMax => $composableBuilder(
      column: $table.targetRepsMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetHoldSeconds => $composableBuilder(
      column: $table.targetHoldSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get restSeconds => $composableBuilder(
      column: $table.restSeconds, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supersetGroupId => $composableBuilder(
      column: $table.supersetGroupId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  $$GymPlanRoutinesTableFilterComposer get routineId {
    final $$GymPlanRoutinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.gymPlanRoutines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymPlanRoutinesTableFilterComposer(
              $db: $db,
              $table: $db.gymPlanRoutines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GymExercisesTableFilterComposer get exerciseId {
    final $$GymExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.gymExercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymExercisesTableFilterComposer(
              $db: $db,
              $table: $db.gymExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GymPlanRoutineExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $GymPlanRoutineExercisesTable> {
  $$GymPlanRoutineExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetRepsMin => $composableBuilder(
      column: $table.targetRepsMin,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetRepsMax => $composableBuilder(
      column: $table.targetRepsMax,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetHoldSeconds => $composableBuilder(
      column: $table.targetHoldSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get restSeconds => $composableBuilder(
      column: $table.restSeconds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supersetGroupId => $composableBuilder(
      column: $table.supersetGroupId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$GymPlanRoutinesTableOrderingComposer get routineId {
    final $$GymPlanRoutinesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.gymPlanRoutines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymPlanRoutinesTableOrderingComposer(
              $db: $db,
              $table: $db.gymPlanRoutines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GymExercisesTableOrderingComposer get exerciseId {
    final $$GymExercisesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.gymExercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymExercisesTableOrderingComposer(
              $db: $db,
              $table: $db.gymExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GymPlanRoutineExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GymPlanRoutineExercisesTable> {
  $$GymPlanRoutineExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => column);

  GeneratedColumn<int> get targetRepsMin => $composableBuilder(
      column: $table.targetRepsMin, builder: (column) => column);

  GeneratedColumn<int> get targetRepsMax => $composableBuilder(
      column: $table.targetRepsMax, builder: (column) => column);

  GeneratedColumn<int> get targetHoldSeconds => $composableBuilder(
      column: $table.targetHoldSeconds, builder: (column) => column);

  GeneratedColumn<int> get restSeconds => $composableBuilder(
      column: $table.restSeconds, builder: (column) => column);

  GeneratedColumn<String> get supersetGroupId => $composableBuilder(
      column: $table.supersetGroupId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$GymPlanRoutinesTableAnnotationComposer get routineId {
    final $$GymPlanRoutinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.gymPlanRoutines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymPlanRoutinesTableAnnotationComposer(
              $db: $db,
              $table: $db.gymPlanRoutines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GymExercisesTableAnnotationComposer get exerciseId {
    final $$GymExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.gymExercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.gymExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GymPlanRoutineExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GymPlanRoutineExercisesTable,
    GymPlanRoutineExerciseRow,
    $$GymPlanRoutineExercisesTableFilterComposer,
    $$GymPlanRoutineExercisesTableOrderingComposer,
    $$GymPlanRoutineExercisesTableAnnotationComposer,
    $$GymPlanRoutineExercisesTableCreateCompanionBuilder,
    $$GymPlanRoutineExercisesTableUpdateCompanionBuilder,
    (GymPlanRoutineExerciseRow, $$GymPlanRoutineExercisesTableReferences),
    GymPlanRoutineExerciseRow,
    PrefetchHooks Function({bool routineId, bool exerciseId})> {
  $$GymPlanRoutineExercisesTableTableManager(
      _$AppDatabase db, $GymPlanRoutineExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GymPlanRoutineExercisesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$GymPlanRoutineExercisesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GymPlanRoutineExercisesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> routineId = const Value.absent(),
            Value<String> exerciseId = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<int> targetSets = const Value.absent(),
            Value<int> targetRepsMin = const Value.absent(),
            Value<int> targetRepsMax = const Value.absent(),
            Value<int?> targetHoldSeconds = const Value.absent(),
            Value<int> restSeconds = const Value.absent(),
            Value<String?> supersetGroupId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GymPlanRoutineExercisesCompanion(
            id: id,
            routineId: routineId,
            exerciseId: exerciseId,
            orderIndex: orderIndex,
            targetSets: targetSets,
            targetRepsMin: targetRepsMin,
            targetRepsMax: targetRepsMax,
            targetHoldSeconds: targetHoldSeconds,
            restSeconds: restSeconds,
            supersetGroupId: supersetGroupId,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String routineId,
            required String exerciseId,
            required int orderIndex,
            Value<int> targetSets = const Value.absent(),
            Value<int> targetRepsMin = const Value.absent(),
            Value<int> targetRepsMax = const Value.absent(),
            Value<int?> targetHoldSeconds = const Value.absent(),
            Value<int> restSeconds = const Value.absent(),
            Value<String?> supersetGroupId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GymPlanRoutineExercisesCompanion.insert(
            id: id,
            routineId: routineId,
            exerciseId: exerciseId,
            orderIndex: orderIndex,
            targetSets: targetSets,
            targetRepsMin: targetRepsMin,
            targetRepsMax: targetRepsMax,
            targetHoldSeconds: targetHoldSeconds,
            restSeconds: restSeconds,
            supersetGroupId: supersetGroupId,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$GymPlanRoutineExercisesTable,
                        GymPlanRoutineExerciseRow>(table),
                    $$GymPlanRoutineExercisesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({routineId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (routineId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.routineId,
                    referencedTable: $$GymPlanRoutineExercisesTableReferences
                        ._routineIdTable(db),
                    referencedColumn: $$GymPlanRoutineExercisesTableReferences
                        ._routineIdTable(db)
                        .id,
                  ) as T;
                }
                if (exerciseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.exerciseId,
                    referencedTable: $$GymPlanRoutineExercisesTableReferences
                        ._exerciseIdTable(db),
                    referencedColumn: $$GymPlanRoutineExercisesTableReferences
                        ._exerciseIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GymPlanRoutineExercisesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $GymPlanRoutineExercisesTable,
        GymPlanRoutineExerciseRow,
        $$GymPlanRoutineExercisesTableFilterComposer,
        $$GymPlanRoutineExercisesTableOrderingComposer,
        $$GymPlanRoutineExercisesTableAnnotationComposer,
        $$GymPlanRoutineExercisesTableCreateCompanionBuilder,
        $$GymPlanRoutineExercisesTableUpdateCompanionBuilder,
        (GymPlanRoutineExerciseRow, $$GymPlanRoutineExercisesTableReferences),
        GymPlanRoutineExerciseRow,
        PrefetchHooks Function({bool routineId, bool exerciseId})>;
typedef $$GymWorkoutSessionsTableCreateCompanionBuilder
    = GymWorkoutSessionsCompanion Function({
  required String id,
  Value<String?> routineId,
  required String routineName,
  required String startUtc,
  Value<String?> endUtc,
  Value<double> durationSeconds,
  Value<double> totalTonnageKg,
  Value<String?> notes,
  Value<double?> rpeAverage,
  Value<int> rowid,
});
typedef $$GymWorkoutSessionsTableUpdateCompanionBuilder
    = GymWorkoutSessionsCompanion Function({
  Value<String> id,
  Value<String?> routineId,
  Value<String> routineName,
  Value<String> startUtc,
  Value<String?> endUtc,
  Value<double> durationSeconds,
  Value<double> totalTonnageKg,
  Value<String?> notes,
  Value<double?> rpeAverage,
  Value<int> rowid,
});

final class $$GymWorkoutSessionsTableReferences extends BaseReferences<
    _$AppDatabase, $GymWorkoutSessionsTable, GymWorkoutSessionRow> {
  $$GymWorkoutSessionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GymSetLogsTable, List<GymSetLogRow>>
      _gymSetLogsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.gymSetLogs,
              aliasName: 'gym_workout_sessions__id__gym_set_logs__session_id');

  $$GymSetLogsTableProcessedTableManager get gymSetLogsRefs {
    final manager = $$GymSetLogsTableTableManager($_db, $_db.gymSetLogs)
        .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gymSetLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GymWorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $GymWorkoutSessionsTable> {
  $$GymWorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routineId => $composableBuilder(
      column: $table.routineId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routineName => $composableBuilder(
      column: $table.routineName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endUtc => $composableBuilder(
      column: $table.endUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalTonnageKg => $composableBuilder(
      column: $table.totalTonnageKg,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rpeAverage => $composableBuilder(
      column: $table.rpeAverage, builder: (column) => ColumnFilters(column));

  Expression<bool> gymSetLogsRefs(
      Expression<bool> Function($$GymSetLogsTableFilterComposer f) f) {
    final $$GymSetLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gymSetLogs,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymSetLogsTableFilterComposer(
              $db: $db,
              $table: $db.gymSetLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GymWorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GymWorkoutSessionsTable> {
  $$GymWorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routineId => $composableBuilder(
      column: $table.routineId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routineName => $composableBuilder(
      column: $table.routineName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endUtc => $composableBuilder(
      column: $table.endUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalTonnageKg => $composableBuilder(
      column: $table.totalTonnageKg,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rpeAverage => $composableBuilder(
      column: $table.rpeAverage, builder: (column) => ColumnOrderings(column));
}

class $$GymWorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GymWorkoutSessionsTable> {
  $$GymWorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumn<String> get routineName => $composableBuilder(
      column: $table.routineName, builder: (column) => column);

  GeneratedColumn<String> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => column);

  GeneratedColumn<String> get endUtc =>
      $composableBuilder(column: $table.endUtc, builder: (column) => column);

  GeneratedColumn<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<double> get totalTonnageKg => $composableBuilder(
      column: $table.totalTonnageKg, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get rpeAverage => $composableBuilder(
      column: $table.rpeAverage, builder: (column) => column);

  Expression<T> gymSetLogsRefs<T extends Object>(
      Expression<T> Function($$GymSetLogsTableAnnotationComposer a) f) {
    final $$GymSetLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gymSetLogs,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymSetLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.gymSetLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GymWorkoutSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GymWorkoutSessionsTable,
    GymWorkoutSessionRow,
    $$GymWorkoutSessionsTableFilterComposer,
    $$GymWorkoutSessionsTableOrderingComposer,
    $$GymWorkoutSessionsTableAnnotationComposer,
    $$GymWorkoutSessionsTableCreateCompanionBuilder,
    $$GymWorkoutSessionsTableUpdateCompanionBuilder,
    (GymWorkoutSessionRow, $$GymWorkoutSessionsTableReferences),
    GymWorkoutSessionRow,
    PrefetchHooks Function({bool gymSetLogsRefs})> {
  $$GymWorkoutSessionsTableTableManager(
      _$AppDatabase db, $GymWorkoutSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GymWorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GymWorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GymWorkoutSessionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> routineId = const Value.absent(),
            Value<String> routineName = const Value.absent(),
            Value<String> startUtc = const Value.absent(),
            Value<String?> endUtc = const Value.absent(),
            Value<double> durationSeconds = const Value.absent(),
            Value<double> totalTonnageKg = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<double?> rpeAverage = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GymWorkoutSessionsCompanion(
            id: id,
            routineId: routineId,
            routineName: routineName,
            startUtc: startUtc,
            endUtc: endUtc,
            durationSeconds: durationSeconds,
            totalTonnageKg: totalTonnageKg,
            notes: notes,
            rpeAverage: rpeAverage,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> routineId = const Value.absent(),
            required String routineName,
            required String startUtc,
            Value<String?> endUtc = const Value.absent(),
            Value<double> durationSeconds = const Value.absent(),
            Value<double> totalTonnageKg = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<double?> rpeAverage = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GymWorkoutSessionsCompanion.insert(
            id: id,
            routineId: routineId,
            routineName: routineName,
            startUtc: startUtc,
            endUtc: endUtc,
            durationSeconds: durationSeconds,
            totalTonnageKg: totalTonnageKg,
            notes: notes,
            rpeAverage: rpeAverage,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$GymWorkoutSessionsTable, GymWorkoutSessionRow>(
                        table),
                    $$GymWorkoutSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({gymSetLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gymSetLogsRefs) db.gymSetLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gymSetLogsRefs)
                    await $_getPrefetchedData<GymWorkoutSessionRow,
                            $GymWorkoutSessionsTable, GymSetLogRow>(
                        currentTable: table,
                        referencedTable: $$GymWorkoutSessionsTableReferences
                            ._gymSetLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GymWorkoutSessionsTableReferences(db, table, p0)
                                .gymSetLogsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GymWorkoutSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GymWorkoutSessionsTable,
    GymWorkoutSessionRow,
    $$GymWorkoutSessionsTableFilterComposer,
    $$GymWorkoutSessionsTableOrderingComposer,
    $$GymWorkoutSessionsTableAnnotationComposer,
    $$GymWorkoutSessionsTableCreateCompanionBuilder,
    $$GymWorkoutSessionsTableUpdateCompanionBuilder,
    (GymWorkoutSessionRow, $$GymWorkoutSessionsTableReferences),
    GymWorkoutSessionRow,
    PrefetchHooks Function({bool gymSetLogsRefs})>;
typedef $$GymSetLogsTableCreateCompanionBuilder = GymSetLogsCompanion Function({
  required String id,
  required String sessionId,
  required String exerciseId,
  required int setIndex,
  Value<String> setType,
  Value<double> weightKg,
  Value<int?> reps,
  Value<int?> holdSeconds,
  Value<double?> rpe,
  Value<int?> rir,
  Value<bool> completed,
  required String loggedAtUtc,
  Value<int> rowid,
});
typedef $$GymSetLogsTableUpdateCompanionBuilder = GymSetLogsCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> exerciseId,
  Value<int> setIndex,
  Value<String> setType,
  Value<double> weightKg,
  Value<int?> reps,
  Value<int?> holdSeconds,
  Value<double?> rpe,
  Value<int?> rir,
  Value<bool> completed,
  Value<String> loggedAtUtc,
  Value<int> rowid,
});

final class $$GymSetLogsTableReferences
    extends BaseReferences<_$AppDatabase, $GymSetLogsTable, GymSetLogRow> {
  $$GymSetLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GymWorkoutSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.gymWorkoutSessions
          .createAlias('gym_set_logs__session_id__gym_workout_sessions__id');

  $$GymWorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager =
        $$GymWorkoutSessionsTableTableManager($_db, $_db.gymWorkoutSessions)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $GymExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.gymExercises
          .createAlias('gym_set_logs__exercise_id__gym_exercises__id');

  $$GymExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$GymExercisesTableTableManager($_db, $_db.gymExercises)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GymSetLogsTableFilterComposer
    extends Composer<_$AppDatabase, $GymSetLogsTable> {
  $$GymSetLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get setIndex => $composableBuilder(
      column: $table.setIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get setType => $composableBuilder(
      column: $table.setType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get holdSeconds => $composableBuilder(
      column: $table.holdSeconds, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rpe => $composableBuilder(
      column: $table.rpe, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rir => $composableBuilder(
      column: $table.rir, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loggedAtUtc => $composableBuilder(
      column: $table.loggedAtUtc, builder: (column) => ColumnFilters(column));

  $$GymWorkoutSessionsTableFilterComposer get sessionId {
    final $$GymWorkoutSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.gymWorkoutSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymWorkoutSessionsTableFilterComposer(
              $db: $db,
              $table: $db.gymWorkoutSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GymExercisesTableFilterComposer get exerciseId {
    final $$GymExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.gymExercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymExercisesTableFilterComposer(
              $db: $db,
              $table: $db.gymExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GymSetLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $GymSetLogsTable> {
  $$GymSetLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get setIndex => $composableBuilder(
      column: $table.setIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get setType => $composableBuilder(
      column: $table.setType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get holdSeconds => $composableBuilder(
      column: $table.holdSeconds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rpe => $composableBuilder(
      column: $table.rpe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rir => $composableBuilder(
      column: $table.rir, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loggedAtUtc => $composableBuilder(
      column: $table.loggedAtUtc, builder: (column) => ColumnOrderings(column));

  $$GymWorkoutSessionsTableOrderingComposer get sessionId {
    final $$GymWorkoutSessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.gymWorkoutSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymWorkoutSessionsTableOrderingComposer(
              $db: $db,
              $table: $db.gymWorkoutSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GymExercisesTableOrderingComposer get exerciseId {
    final $$GymExercisesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.gymExercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymExercisesTableOrderingComposer(
              $db: $db,
              $table: $db.gymExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GymSetLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GymSetLogsTable> {
  $$GymSetLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => column);

  GeneratedColumn<String> get setType =>
      $composableBuilder(column: $table.setType, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get holdSeconds => $composableBuilder(
      column: $table.holdSeconds, builder: (column) => column);

  GeneratedColumn<double> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<int> get rir =>
      $composableBuilder(column: $table.rir, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<String> get loggedAtUtc => $composableBuilder(
      column: $table.loggedAtUtc, builder: (column) => column);

  $$GymWorkoutSessionsTableAnnotationComposer get sessionId {
    final $$GymWorkoutSessionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sessionId,
            referencedTable: $db.gymWorkoutSessions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$GymWorkoutSessionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.gymWorkoutSessions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$GymExercisesTableAnnotationComposer get exerciseId {
    final $$GymExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.gymExercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.gymExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GymSetLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GymSetLogsTable,
    GymSetLogRow,
    $$GymSetLogsTableFilterComposer,
    $$GymSetLogsTableOrderingComposer,
    $$GymSetLogsTableAnnotationComposer,
    $$GymSetLogsTableCreateCompanionBuilder,
    $$GymSetLogsTableUpdateCompanionBuilder,
    (GymSetLogRow, $$GymSetLogsTableReferences),
    GymSetLogRow,
    PrefetchHooks Function({bool sessionId, bool exerciseId})> {
  $$GymSetLogsTableTableManager(_$AppDatabase db, $GymSetLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GymSetLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GymSetLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GymSetLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> exerciseId = const Value.absent(),
            Value<int> setIndex = const Value.absent(),
            Value<String> setType = const Value.absent(),
            Value<double> weightKg = const Value.absent(),
            Value<int?> reps = const Value.absent(),
            Value<int?> holdSeconds = const Value.absent(),
            Value<double?> rpe = const Value.absent(),
            Value<int?> rir = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<String> loggedAtUtc = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GymSetLogsCompanion(
            id: id,
            sessionId: sessionId,
            exerciseId: exerciseId,
            setIndex: setIndex,
            setType: setType,
            weightKg: weightKg,
            reps: reps,
            holdSeconds: holdSeconds,
            rpe: rpe,
            rir: rir,
            completed: completed,
            loggedAtUtc: loggedAtUtc,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String exerciseId,
            required int setIndex,
            Value<String> setType = const Value.absent(),
            Value<double> weightKg = const Value.absent(),
            Value<int?> reps = const Value.absent(),
            Value<int?> holdSeconds = const Value.absent(),
            Value<double?> rpe = const Value.absent(),
            Value<int?> rir = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            required String loggedAtUtc,
            Value<int> rowid = const Value.absent(),
          }) =>
              GymSetLogsCompanion.insert(
            id: id,
            sessionId: sessionId,
            exerciseId: exerciseId,
            setIndex: setIndex,
            setType: setType,
            weightKg: weightKg,
            reps: reps,
            holdSeconds: holdSeconds,
            rpe: rpe,
            rir: rir,
            completed: completed,
            loggedAtUtc: loggedAtUtc,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$GymSetLogsTable, GymSetLogRow>(table),
                    $$GymSetLogsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$GymSetLogsTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$GymSetLogsTableReferences._sessionIdTable(db).id,
                  ) as T;
                }
                if (exerciseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.exerciseId,
                    referencedTable:
                        $$GymSetLogsTableReferences._exerciseIdTable(db),
                    referencedColumn:
                        $$GymSetLogsTableReferences._exerciseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GymSetLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GymSetLogsTable,
    GymSetLogRow,
    $$GymSetLogsTableFilterComposer,
    $$GymSetLogsTableOrderingComposer,
    $$GymSetLogsTableAnnotationComposer,
    $$GymSetLogsTableCreateCompanionBuilder,
    $$GymSetLogsTableUpdateCompanionBuilder,
    (GymSetLogRow, $$GymSetLogsTableReferences),
    GymSetLogRow,
    PrefetchHooks Function({bool sessionId, bool exerciseId})>;
typedef $$Gym1RmHistoriesTableCreateCompanionBuilder = Gym1RmHistoriesCompanion
    Function({
  required String id,
  required String exerciseId,
  required double calculated1Rm,
  required double weightKg,
  required int reps,
  required String date,
  Value<int> rowid,
});
typedef $$Gym1RmHistoriesTableUpdateCompanionBuilder = Gym1RmHistoriesCompanion
    Function({
  Value<String> id,
  Value<String> exerciseId,
  Value<double> calculated1Rm,
  Value<double> weightKg,
  Value<int> reps,
  Value<String> date,
  Value<int> rowid,
});

final class $$Gym1RmHistoriesTableReferences extends BaseReferences<
    _$AppDatabase, $Gym1RmHistoriesTable, Gym1RmHistoryRow> {
  $$Gym1RmHistoriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $GymExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.gymExercises
          .createAlias('gym1_rm_histories__exercise_id__gym_exercises__id');

  $$GymExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$GymExercisesTableTableManager($_db, $_db.gymExercises)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$Gym1RmHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $Gym1RmHistoriesTable> {
  $$Gym1RmHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calculated1Rm => $composableBuilder(
      column: $table.calculated1Rm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  $$GymExercisesTableFilterComposer get exerciseId {
    final $$GymExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.gymExercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymExercisesTableFilterComposer(
              $db: $db,
              $table: $db.gymExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$Gym1RmHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $Gym1RmHistoriesTable> {
  $$Gym1RmHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calculated1Rm => $composableBuilder(
      column: $table.calculated1Rm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  $$GymExercisesTableOrderingComposer get exerciseId {
    final $$GymExercisesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.gymExercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymExercisesTableOrderingComposer(
              $db: $db,
              $table: $db.gymExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$Gym1RmHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $Gym1RmHistoriesTable> {
  $$Gym1RmHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get calculated1Rm => $composableBuilder(
      column: $table.calculated1Rm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  $$GymExercisesTableAnnotationComposer get exerciseId {
    final $$GymExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.exerciseId,
        referencedTable: $db.gymExercises,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GymExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.gymExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$Gym1RmHistoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $Gym1RmHistoriesTable,
    Gym1RmHistoryRow,
    $$Gym1RmHistoriesTableFilterComposer,
    $$Gym1RmHistoriesTableOrderingComposer,
    $$Gym1RmHistoriesTableAnnotationComposer,
    $$Gym1RmHistoriesTableCreateCompanionBuilder,
    $$Gym1RmHistoriesTableUpdateCompanionBuilder,
    (Gym1RmHistoryRow, $$Gym1RmHistoriesTableReferences),
    Gym1RmHistoryRow,
    PrefetchHooks Function({bool exerciseId})> {
  $$Gym1RmHistoriesTableTableManager(
      _$AppDatabase db, $Gym1RmHistoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$Gym1RmHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$Gym1RmHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$Gym1RmHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> exerciseId = const Value.absent(),
            Value<double> calculated1Rm = const Value.absent(),
            Value<double> weightKg = const Value.absent(),
            Value<int> reps = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              Gym1RmHistoriesCompanion(
            id: id,
            exerciseId: exerciseId,
            calculated1Rm: calculated1Rm,
            weightKg: weightKg,
            reps: reps,
            date: date,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String exerciseId,
            required double calculated1Rm,
            required double weightKg,
            required int reps,
            required String date,
            Value<int> rowid = const Value.absent(),
          }) =>
              Gym1RmHistoriesCompanion.insert(
            id: id,
            exerciseId: exerciseId,
            calculated1Rm: calculated1Rm,
            weightKg: weightKg,
            reps: reps,
            date: date,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$Gym1RmHistoriesTable, Gym1RmHistoryRow>(table),
                    $$Gym1RmHistoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (exerciseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.exerciseId,
                    referencedTable:
                        $$Gym1RmHistoriesTableReferences._exerciseIdTable(db),
                    referencedColumn: $$Gym1RmHistoriesTableReferences
                        ._exerciseIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$Gym1RmHistoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $Gym1RmHistoriesTable,
    Gym1RmHistoryRow,
    $$Gym1RmHistoriesTableFilterComposer,
    $$Gym1RmHistoriesTableOrderingComposer,
    $$Gym1RmHistoriesTableAnnotationComposer,
    $$Gym1RmHistoriesTableCreateCompanionBuilder,
    $$Gym1RmHistoriesTableUpdateCompanionBuilder,
    (Gym1RmHistoryRow, $$Gym1RmHistoriesTableReferences),
    Gym1RmHistoryRow,
    PrefetchHooks Function({bool exerciseId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$ConsumedFoodsTableTableManager get consumedFoods =>
      $$ConsumedFoodsTableTableManager(_db, _db.consumedFoods);
  $$SavedMealsTableTableManager get savedMeals =>
      $$SavedMealsTableTableManager(_db, _db.savedMeals);
  $$SavedMealIngredientsTableTableManager get savedMealIngredients =>
      $$SavedMealIngredientsTableTableManager(_db, _db.savedMealIngredients);
  $$FavoriteFoodsTableTableManager get favoriteFoods =>
      $$FavoriteFoodsTableTableManager(_db, _db.favoriteFoods);
  $$FoodUsageTableTableManager get foodUsage =>
      $$FoodUsageTableTableManager(_db, _db.foodUsage);
  $$OfflineQueueTableTableManager get offlineQueue =>
      $$OfflineQueueTableTableManager(_db, _db.offlineQueue);
  $$LocalFoodsTableTableManager get localFoods =>
      $$LocalFoodsTableTableManager(_db, _db.localFoods);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$WeightEntriesTableTableManager get weightEntries =>
      $$WeightEntriesTableTableManager(_db, _db.weightEntries);
  $$AppDatabaseMetadataTableTableManager get appDatabaseMetadata =>
      $$AppDatabaseMetadataTableTableManager(_db, _db.appDatabaseMetadata);
  $$HealthSourcesTableTableManager get healthSources =>
      $$HealthSourcesTableTableManager(_db, _db.healthSources);
  $$HealthSyncStatesTableTableManager get healthSyncStates =>
      $$HealthSyncStatesTableTableManager(_db, _db.healthSyncStates);
  $$HealthRecordsTableTableManager get healthRecords =>
      $$HealthRecordsTableTableManager(_db, _db.healthRecords);
  $$DailyHealthAggregatesTableTableManager get dailyHealthAggregates =>
      $$DailyHealthAggregatesTableTableManager(_db, _db.dailyHealthAggregates);
  $$SleepSessionsTableTableManager get sleepSessions =>
      $$SleepSessionsTableTableManager(_db, _db.sleepSessions);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$WorkoutRoutePointsTableTableManager get workoutRoutePoints =>
      $$WorkoutRoutePointsTableTableManager(_db, _db.workoutRoutePoints);
  $$CycleProfilesTableTableManager get cycleProfiles =>
      $$CycleProfilesTableTableManager(_db, _db.cycleProfiles);
  $$PeriodEntriesTableTableManager get periodEntries =>
      $$PeriodEntriesTableTableManager(_db, _db.periodEntries);
  $$CycleDailyLogsTableTableManager get cycleDailyLogs =>
      $$CycleDailyLogsTableTableManager(_db, _db.cycleDailyLogs);
  $$SymptomDefinitionsTableTableManager get symptomDefinitions =>
      $$SymptomDefinitionsTableTableManager(_db, _db.symptomDefinitions);
  $$SymptomLogsTableTableManager get symptomLogs =>
      $$SymptomLogsTableTableManager(_db, _db.symptomLogs);
  $$CyclePredictionsTableTableManager get cyclePredictions =>
      $$CyclePredictionsTableTableManager(_db, _db.cyclePredictions);
  $$NotificationPreferencesTableTableManager get notificationPreferences =>
      $$NotificationPreferencesTableTableManager(
          _db, _db.notificationPreferences);
  $$BackupManifestsTableTableManager get backupManifests =>
      $$BackupManifestsTableTableManager(_db, _db.backupManifests);
  $$GymExercisesTableTableManager get gymExercises =>
      $$GymExercisesTableTableManager(_db, _db.gymExercises);
  $$GymWorkoutPlansTableTableManager get gymWorkoutPlans =>
      $$GymWorkoutPlansTableTableManager(_db, _db.gymWorkoutPlans);
  $$GymPlanRoutinesTableTableManager get gymPlanRoutines =>
      $$GymPlanRoutinesTableTableManager(_db, _db.gymPlanRoutines);
  $$GymPlanRoutineExercisesTableTableManager get gymPlanRoutineExercises =>
      $$GymPlanRoutineExercisesTableTableManager(
          _db, _db.gymPlanRoutineExercises);
  $$GymWorkoutSessionsTableTableManager get gymWorkoutSessions =>
      $$GymWorkoutSessionsTableTableManager(_db, _db.gymWorkoutSessions);
  $$GymSetLogsTableTableManager get gymSetLogs =>
      $$GymSetLogsTableTableManager(_db, _db.gymSetLogs);
  $$Gym1RmHistoriesTableTableManager get gym1RmHistories =>
      $$Gym1RmHistoriesTableTableManager(_db, _db.gym1RmHistories);
}
