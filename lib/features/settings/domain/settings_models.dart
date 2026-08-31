enum Gender { male, female }

enum BmrFormula { mifflin, harris }

enum AutoCalorieMode { off, diet, bulk, custom, maintain }

class UserGoals {
  final int dailyCalories;
  final int carbPercentage;
  final int proteinPercentage;
  final int fatPercentage;
  final int sugarPercentage;
  final AutoCalorieMode autoCalorieMode;
  final double customPercentPerMonth;
  final bool useCustomStartCalories;
  final int userStartCalories;
  final int userAge;
  final double userActivityLevel;
  final double userHeight;
  final bool useProteinPerKg;
  final double proteinPerKg;
  final double? targetWeight;
  final String? targetDate;
  final double? targetWeeklyChange;
  final Gender gender;
  final BmrFormula bmrFormula;

  const UserGoals({
    this.dailyCalories = 2000,
    this.carbPercentage = 50,
    this.proteinPercentage = 30,
    this.fatPercentage = 20,
    this.sugarPercentage = 20,
    this.autoCalorieMode = AutoCalorieMode.off,
    this.customPercentPerMonth = 1.0,
    this.useCustomStartCalories = false,
    this.userStartCalories = 2000,
    this.userAge = 30,
    this.userActivityLevel = 1.3,
    this.userHeight = 170.0,
    this.useProteinPerKg = false,
    this.proteinPerKg = 2.0,
    this.targetWeight,
    this.targetDate,
    this.targetWeeklyChange,
    this.gender = Gender.male,
    this.bmrFormula = BmrFormula.mifflin,
  });

  UserGoals copyWith({
    int? dailyCalories,
    int? carbPercentage,
    int? proteinPercentage,
    int? fatPercentage,
    int? sugarPercentage,
    AutoCalorieMode? autoCalorieMode,
    double? customPercentPerMonth,
    bool? useCustomStartCalories,
    int? userStartCalories,
    int? userAge,
    double? userActivityLevel,
    double? userHeight,
    bool? useProteinPerKg,
    double? proteinPerKg,
    double? targetWeight,
    String? targetDate,
    double? targetWeeklyChange,
    Gender? gender,
    BmrFormula? bmrFormula,
  }) {
    return UserGoals(
      dailyCalories: dailyCalories ?? this.dailyCalories,
      carbPercentage: carbPercentage ?? this.carbPercentage,
      proteinPercentage: proteinPercentage ?? this.proteinPercentage,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      sugarPercentage: sugarPercentage ?? this.sugarPercentage,
      autoCalorieMode: autoCalorieMode ?? this.autoCalorieMode,
      customPercentPerMonth: customPercentPerMonth ?? this.customPercentPerMonth,
      useCustomStartCalories: useCustomStartCalories ?? this.useCustomStartCalories,
      userStartCalories: userStartCalories ?? this.userStartCalories,
      userAge: userAge ?? this.userAge,
      userActivityLevel: userActivityLevel ?? this.userActivityLevel,
      userHeight: userHeight ?? this.userHeight,
      useProteinPerKg: useProteinPerKg ?? this.useProteinPerKg,
      proteinPerKg: proteinPerKg ?? this.proteinPerKg,
      targetWeight: targetWeight ?? this.targetWeight,
      targetDate: targetDate ?? this.targetDate,
      targetWeeklyChange: targetWeeklyChange ?? this.targetWeeklyChange,
      gender: gender ?? this.gender,
      bmrFormula: bmrFormula ?? this.bmrFormula,
    );
  }

  Map<String, dynamic> toMap() => {
        'dailyCalories': dailyCalories,
        'carbPercentage': carbPercentage,
        'proteinPercentage': proteinPercentage,
        'fatPercentage': fatPercentage,
        'sugarPercentage': sugarPercentage,
        'autoCalorieMode': autoCalorieMode.name,
        'customPercentPerMonth': customPercentPerMonth,
        'useCustomStartCalories': useCustomStartCalories,
        'userStartCalories': userStartCalories,
        'userAge': userAge,
        'userActivityLevel': userActivityLevel,
        'userHeight': userHeight,
        'useProteinPerKg': useProteinPerKg,
        'proteinPerKg': proteinPerKg,
        'targetWeight': targetWeight,
        'targetDate': targetDate,
        'targetWeeklyChange': targetWeeklyChange,
        'gender': gender.name,
        'bmrFormula': bmrFormula.name,
      };

  factory UserGoals.fromMap(Map<String, dynamic> map) => UserGoals(
        dailyCalories: (map['dailyCalories'] as num?)?.toInt() ?? 2000,
        carbPercentage: (map['carbPercentage'] as num?)?.toInt() ?? 50,
        proteinPercentage: (map['proteinPercentage'] as num?)?.toInt() ?? 30,
        fatPercentage: (map['fatPercentage'] as num?)?.toInt() ?? 20,
        sugarPercentage: (map['sugarPercentage'] as num?)?.toInt() ?? 20,
        autoCalorieMode: AutoCalorieMode.values.firstWhere(
          (m) => m.name == map['autoCalorieMode'],
          orElse: () => AutoCalorieMode.off,
        ),
        customPercentPerMonth:
            (map['customPercentPerMonth'] as num?)?.toDouble() ?? 1.0,
        useCustomStartCalories: map['useCustomStartCalories'] == true,
        userStartCalories: (map['userStartCalories'] as num?)?.toInt() ?? 2000,
        userAge: (map['userAge'] as num?)?.toInt() ?? 30,
        userActivityLevel:
            (map['userActivityLevel'] as num?)?.toDouble() ?? 1.3,
        userHeight: (map['userHeight'] as num?)?.toDouble() ?? 170.0,
        useProteinPerKg: map['useProteinPerKg'] == true,
        proteinPerKg: (map['proteinPerKg'] as num?)?.toDouble() ?? 2.0,
        targetWeight: (map['targetWeight'] as num?)?.toDouble(),
        targetDate: map['targetDate'] as String?,
        targetWeeklyChange: (map['targetWeeklyChange'] as num?)?.toDouble(),
        gender: Gender.values.firstWhere(
          (g) => g.name == map['gender'],
          orElse: () => Gender.male,
        ),
        bmrFormula: BmrFormula.values.firstWhere(
          (b) => b.name == map['bmrFormula'],
          orElse: () => BmrFormula.mifflin,
        ),
      );
}

class UserSettings {
  final bool darkMode;
  final bool reminderWeighEnabled;
  final String reminderWeighTime;
  final String reminderWeighTime2;
  final bool reminderSupplementEnabled;
  final String reminderSupplementTime;
  final String reminderSupplementTime2;
  final bool reminderMealsEnabled;
  final String reminderBreakfast;
  final String reminderLunch;
  final String reminderDinner;

  const UserSettings({
    this.darkMode = false,
    this.reminderWeighEnabled = false,
    this.reminderWeighTime = '08:00',
    this.reminderWeighTime2 = '09:00',
    this.reminderSupplementEnabled = false,
    this.reminderSupplementTime = '10:00',
    this.reminderSupplementTime2 = '11:00',
    this.reminderMealsEnabled = false,
    this.reminderBreakfast = '07:00',
    this.reminderLunch = '12:30',
    this.reminderDinner = '19:00',
  });

  UserSettings copyWith({
    bool? darkMode,
    bool? reminderWeighEnabled,
    String? reminderWeighTime,
    String? reminderWeighTime2,
    bool? reminderSupplementEnabled,
    String? reminderSupplementTime,
    String? reminderSupplementTime2,
    bool? reminderMealsEnabled,
    String? reminderBreakfast,
    String? reminderLunch,
    String? reminderDinner,
  }) {
    return UserSettings(
      darkMode: darkMode ?? this.darkMode,
      reminderWeighEnabled: reminderWeighEnabled ?? this.reminderWeighEnabled,
      reminderWeighTime: reminderWeighTime ?? this.reminderWeighTime,
      reminderWeighTime2: reminderWeighTime2 ?? this.reminderWeighTime2,
      reminderSupplementEnabled: reminderSupplementEnabled ?? this.reminderSupplementEnabled,
      reminderSupplementTime: reminderSupplementTime ?? this.reminderSupplementTime,
      reminderSupplementTime2: reminderSupplementTime2 ?? this.reminderSupplementTime2,
      reminderMealsEnabled: reminderMealsEnabled ?? this.reminderMealsEnabled,
      reminderBreakfast: reminderBreakfast ?? this.reminderBreakfast,
      reminderLunch: reminderLunch ?? this.reminderLunch,
      reminderDinner: reminderDinner ?? this.reminderDinner,
    );
  }

  Map<String, dynamic> toMap() => {
        'darkMode': darkMode,
        'reminderWeighEnabled': reminderWeighEnabled,
        'reminderWeighTime': reminderWeighTime,
        'reminderWeighTime2': reminderWeighTime2,
        'reminderSupplementEnabled': reminderSupplementEnabled,
        'reminderSupplementTime': reminderSupplementTime,
        'reminderSupplementTime2': reminderSupplementTime2,
        'reminderMealsEnabled': reminderMealsEnabled,
        'reminderBreakfast': reminderBreakfast,
        'reminderLunch': reminderLunch,
        'reminderDinner': reminderDinner,
      };

  factory UserSettings.fromMap(Map<String, dynamic> map) => UserSettings(
        darkMode: map['darkMode'] == true,
        reminderWeighEnabled: map['reminderWeighEnabled'] == true,
        reminderWeighTime: map['reminderWeighTime'] as String? ?? '08:00',
        reminderWeighTime2: map['reminderWeighTime2'] as String? ?? '09:00',
        reminderSupplementEnabled: map['reminderSupplementEnabled'] == true,
        reminderSupplementTime:
            map['reminderSupplementTime'] as String? ?? '10:00',
        reminderSupplementTime2:
            map['reminderSupplementTime2'] as String? ?? '11:00',
        reminderMealsEnabled: map['reminderMealsEnabled'] == true,
        reminderBreakfast: map['reminderBreakfast'] as String? ?? '07:00',
        reminderLunch: map['reminderLunch'] as String? ?? '12:30',
        reminderDinner: map['reminderDinner'] as String? ?? '19:00',
      );
}
