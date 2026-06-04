import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../models/local_llm_model.dart';
import '../services/llm_service.dart';

class PalOption {
  final double value;
  final String title;
  final String description;
  PalOption(this.value, this.title, this.description);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController calorieController;
  late int carbPercentage;
  late int proteinPercentage;
  late int fatPercentage;
  late int sugarPercentage;
  late AutoCalorieMode _selectedMode;
  late TextEditingController _customPercentController;
  bool _useCustomStartCals = false;
  late TextEditingController _startCaloriesController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _proteinPerKgController;
  late TextEditingController _targetWeightController;
  late TextEditingController _targetWeeklyController;
  DateTime? _targetDate;
  bool _useProteinPerKg = false;
  final List<PalOption> _palOptions = [
    PalOption(
      1.2,
      'Sehr niedrig (1.2)',
      'Du verbringst den Großteil des Tages sitzend oder liegend. Beispiele: Bettlägerig oder reine Sitzarbeit.',
    ),
    PalOption(
      1.375,
      'Niedrig (1.375)',
      'Sitzende Tätigkeit mit wenig Bewegung. Beispiele: Büroarbeit mit kurzen Wegen, kaum Sport.',
    ),
    PalOption(
      1.55,
      'Mäßig aktiv (1.55)',
      'Überwiegend sitzend, aber regelmäßige leichte Aktivitäten. Beispiele: Büro mit Freizeitaktivitäten, 1–3 Sporteinheiten pro Woche.',
    ),
    PalOption(
      1.725,
      'Aktiv (1.725)',
      'Überwiegend körperliche Tätigkeit oder regelmäßiger Sport. Beispiele: Handwerker, Pfleger, 4–6 Sporteinheiten pro Woche.',
    ),
    PalOption(
      1.9,
      'Sehr aktiv (1.9)',
      'Überwiegend schwere körperliche Arbeit oder intensiver Sport. Beispiele: Bauarbeiter, Leistungssportler, täglich intensives Training.',
    ),
    PalOption(
      2.2,
      'Extrem aktiv (2.2)',
      'Sehr hohe körperliche Belastung. Beispiele: Berufssportler (Marathon).',
    ),
  ];
  late double _selectedPalValue;
  bool reminderWeighEnabled = false;
  TimeOfDay reminderWeighTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay reminderWeighTime2 = const TimeOfDay(hour: 9, minute: 0);
  bool reminderSupplementEnabled = false;
  TimeOfDay reminderSupplementTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay reminderSupplementTime2 = const TimeOfDay(hour: 11, minute: 0);
  bool reminderMealsEnabled = false;
  TimeOfDay reminderBreakfast = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay reminderLunch = const TimeOfDay(hour: 12, minute: 30);
  TimeOfDay reminderDinner = const TimeOfDay(hour: 19, minute: 0);
  Gender _selectedGender = Gender.male;
  BmrFormula _selectedFormula = BmrFormula.mifflin;
  bool _llmBusy = false;
  String? _llmStatusMessage;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    int f(int value) {
      return (value / 5).round() * 5;
    }

    carbPercentage = f(
      ((appState.dailyCarbGoal * 4 / appState.dailyCalorieGoal) * 100).round(),
    );
    proteinPercentage = f(
      ((appState.dailyProteinGoal * 4 / appState.dailyCalorieGoal) * 100)
          .round(),
    );
    fatPercentage = f(
      ((appState.dailyFatGoal * 9 / appState.dailyCalorieGoal) * 100).round(),
    );
    int sum = carbPercentage + proteinPercentage + fatPercentage;
    int diff = 100 - sum;
    if (diff != 0) {
      carbPercentage += diff;
      if (carbPercentage < 0) carbPercentage = 0;
      if (carbPercentage > 100) carbPercentage = 100;
    }
    sugarPercentage = appState.dailySugarGoalPercentage;
    calorieController = TextEditingController(
      text: appState.dailyCalorieGoal.toString(),
    );
    _selectedMode = appState.autoMode;
    _customPercentController = TextEditingController(
      text: appState.customPercentPerMonth.toStringAsFixed(1),
    );
    _useCustomStartCals = appState.useCustomStartCalories;
    _startCaloriesController = TextEditingController(
      text: appState.userStartCalories.toString(),
    );
    _ageController = TextEditingController(text: appState.userAge.toString());
    _heightController = TextEditingController(
      text: appState.userHeight.toStringAsFixed(0),
    );
    _useProteinPerKg = appState.useProteinPerKg;
    _proteinPerKgController = TextEditingController(
      text: appState.proteinPerKg.toStringAsFixed(1),
    );
    _targetWeightController = TextEditingController(
      text: appState.targetWeight?.toStringAsFixed(1) ?? '',
    );
    _targetWeeklyController = TextEditingController(
      text: appState.targetWeeklyChange?.toStringAsFixed(2) ?? '',
    );
    _targetDate = appState.targetDate;
    double storedPal = appState.userActivityLevel;
    final palCandidates = _palOptions.map((p) => p.value).toList();
    double closest = palCandidates.reduce(
      (a, b) => (storedPal - a).abs() < (storedPal - b).abs() ? a : b,
    );
    _selectedPalValue = closest;
    reminderWeighEnabled = appState.reminderWeighEnabled;
    reminderWeighTime = appState.reminderWeighTime;
    reminderWeighTime2 = appState.reminderWeighTimeSecond;
    reminderSupplementEnabled = appState.reminderSupplementEnabled;
    reminderSupplementTime = appState.reminderSupplementTime;
    reminderSupplementTime2 = appState.reminderSupplementTimeSecond;
    reminderMealsEnabled = appState.reminderMealsEnabled;
    unawaited(appState.refreshInstalledLocalLlmModels());
    reminderBreakfast = appState.reminderBreakfast;
    reminderLunch = appState.reminderLunch;
    reminderDinner = appState.reminderDinner;
    _selectedGender = appState.userGender;
    _selectedFormula = appState.bmrFormula;
  }

  @override
  void dispose() {
    calorieController.dispose();
    _customPercentController.dispose();
    _startCaloriesController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _proteinPerKgController.dispose();
    _targetWeightController.dispose();
    _targetWeeklyController.dispose();
    super.dispose();
  }

  bool _validatePercentages() {
    int total = carbPercentage + proteinPercentage + fatPercentage;
    return total == 100;
  }

  void _saveSettings(AppState appState, {bool forceManualMode = false}) async {
    int? newCalorieGoal = int.tryParse(calorieController.text);
    int? newSugarPerc = sugarPercentage;
    int? newAge = int.tryParse(_ageController.text);
    double? newHeight = double.tryParse(_heightController.text);
    double newActivity = _selectedPalValue;
    if (newCalorieGoal != null &&
        newCalorieGoal > 0 &&
        _validatePercentages() &&
        newAge != null &&
        newAge > 0 &&
        newActivity > 0.0 &&
        newHeight != null &&
        newHeight > 0) {
      final oldMode = appState.autoMode;
      final oldCustomPercent = appState.customPercentPerMonth;
      final oldUseCustomStartCalories = appState.useCustomStartCalories;
      final oldStartCalories = appState.userStartCalories;
      final oldAge = appState.userAge;
      final oldHeight = appState.userHeight;
      final oldActivity = appState.userActivityLevel;
      final oldGender = appState.userGender;
      final oldFormula = appState.bmrFormula;

      double? customVal = double.tryParse(
        _customPercentController.text.replaceAll(',', '.'),
      );
      if (customVal == null) {
        customVal = 1.0;
      }
      int? startCals = int.tryParse(_startCaloriesController.text);
      if (startCals == null || startCals < 500) {
        startCals = 2000;
      }

      appState.customPercentPerMonth = customVal;
      appState.useCustomStartCalories = _useCustomStartCals;
      appState.userStartCalories = startCals;
      appState.autoMode = forceManualMode ? AutoCalorieMode.off : _selectedMode;
      appState.dailyCalorieGoal = newCalorieGoal;
      appState.userAge = newAge;
      appState.userActivityLevel = newActivity;
      appState.userHeight = newHeight;
      appState.useProteinPerKg = _useProteinPerKg;
      appState.proteinPerKg =
          double.tryParse(_proteinPerKgController.text.replaceAll(',', '.')) ??
              appState.proteinPerKg;
      appState.targetWeight = _targetWeightController.text.trim().isEmpty
          ? null
          : double.tryParse(_targetWeightController.text.replaceAll(',', '.'));
      appState.targetWeeklyChange = _targetWeeklyController.text.trim().isEmpty
          ? null
          : double.tryParse(_targetWeeklyController.text.replaceAll(',', '.'));
      appState.targetDate = _targetDate;
      await appState.saveBodyProfileSettings(
        gender: _selectedGender,
        formula: _selectedFormula,
      );
      final autoInputsChanged =
          oldUseCustomStartCalories != appState.useCustomStartCalories ||
              oldStartCalories != appState.userStartCalories ||
              oldAge != appState.userAge ||
              oldHeight != appState.userHeight ||
              oldActivity != appState.userActivityLevel ||
              oldGender != appState.userGender ||
              oldFormula != appState.bmrFormula;
      final autoModeChanged = oldMode != appState.autoMode;
      final autoTargetChanged =
          oldCustomPercent != appState.customPercentPerMonth;
      if (oldMode == AutoCalorieMode.off &&
          appState.autoMode != AutoCalorieMode.off) {
        appState.firstWeekInitialized = false;
      }
      if (appState.autoMode != AutoCalorieMode.off &&
          (autoInputsChanged || autoModeChanged || autoTargetChanged)) {
        appState.firstWeekInitialized = false;
      }
      await appState.updateGoals(
        newCalorieGoal,
        carbPercentage,
        proteinPercentage,
        fatPercentage,
        newSugarPerc!,
      );
      if (appState.autoMode != AutoCalorieMode.off &&
          !appState.firstWeekInitialized) {
        await appState.recalculateGoals(fromBmr: true);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Einstellungen gespeichert.')),
      );
      Navigator.of(context).pop();
    } else {
      String errorMessage = '';
      if (newCalorieGoal == null || newCalorieGoal <= 0) {
        errorMessage += 'Bitte gib eine gültige Kalorienzahl ein.\n';
      }
      if (!_validatePercentages()) {
        errorMessage +=
            'Die Makro-Prozentwerte müssen insgesamt 100% ergeben.\n';
      }
      if (newAge == null || newAge <= 0) {
        errorMessage += 'Bitte ein gültiges Alter eingeben.\n';
      }
      if (newHeight == null || newHeight <= 0) {
        errorMessage += 'Bitte eine gültige Körpergröße eingeben.\n';
      }
      if (newActivity <= 0.0) {
        errorMessage += 'Bitte einen gültigen Aktivitätsfaktor auswählen.\n';
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Ungültige Eingaben'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _resetGoals(AppState appState) {
    setState(() {
      calorieController.text = '2000';
      carbPercentage = 50;
      proteinPercentage = 30;
      fatPercentage = 20;
      sugarPercentage = 20;
      _selectedMode = AutoCalorieMode.off;
    });
    appState.autoMode = AutoCalorieMode.off;
    appState.updateGoals(2000, 50, 30, 20, 20);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ziele wurden zurückgesetzt.')),
    );
  }

  void _resetDatabase(AppState appState) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Datenbank zurücksetzen'),
          content: const Text(
            'Möchtest du wirklich alle Daten löschen und die Datenbank neu erstellen? Dies kann nicht rückgängig gemacht werden.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      try {
        await appState.resetDatabase();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datenbank erfolgreich zurückgesetzt.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Zurücksetzen der Datenbank: $e')),
        );
      }
    }
  }

  void _toggleDarkMode(AppState appState, bool value) async {
    await appState.toggleDarkMode(value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Dark Mode aktiviert.' : 'Dark Mode deaktiviert.',
        ),
      ),
    );
  }

  void _logout(AppState appState) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Möchtest du dich wirklich abmelden?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      await appState.logout();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erfolgreich ausgeloggt.')));
    }
  }

  void _deleteAccount(AppState appState) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Account löschen'),
          content: const Text(
            'Möchtest du deinen Account wirklich löschen? Dies kann nicht rückgängig gemacht werden.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      final ok = await appState.deleteAccount();
      if (ok) {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account wurde gelöscht.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account konnte nicht gelöscht werden.'),
          ),
        );
      }
    }
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay initial) async {
    return await showTimePicker(context: context, initialTime: initial);
  }

  Future<void> _checkLocalModel(AppState appState) async {
    setState(() {
      _llmBusy = true;
      _llmStatusMessage = null;
    });
    try {
      final service = LlmService(selectedModel: appState.selectedLocalLlmModel);
      final installed = await service.isSelectedModelInstalled();
      await service.dispose();
      setState(() {
        _llmStatusMessage = installed
            ? '${appState.selectedLocalLlmModel.displayName} ist lokal installiert.'
            : '${appState.selectedLocalLlmModel.displayName} ist noch nicht lokal installiert.';
      });
      if (installed) {
        unawaited(appState.refreshInstalledLocalLlmModels());
      }
    } catch (e) {
      setState(() {
        _llmStatusMessage = _llmErrorText(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _llmBusy = false;
        });
      }
    }
  }

  Future<void> _downloadLocalModel(AppState appState) async {
    setState(() => _llmStatusMessage = null);
    try {
      await appState.downloadSelectedLocalLlmModel();
    } catch (e) {
      setState(() {
        _llmStatusMessage = _llmErrorText(e);
      });
    }
  }

  Future<void> _testLocalModel(AppState appState) async {
    setState(() {
      _llmBusy = true;
      _llmStatusMessage = 'Debug-Inferenz läuft...';
    });
    try {
      final service = LlmService(selectedModel: appState.selectedLocalLlmModel);
      final response = await service.runDebugPrompt();
      await service.dispose();
      setState(() {
        _llmStatusMessage = 'Debug-Antwort: $response';
      });
    } catch (e) {
      setState(() {
        _llmStatusMessage = _llmErrorText(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _llmBusy = false;
        });
      }
    }
  }

  Future<void> _runLlmBenchmark(AppState appState) async {
    final results = <String>[];
    
    void updateProgress(String msg) {
      results.add(msg);
      if (mounted) {
        setState(() {
          _llmStatusMessage = results.join('\n');
        });
      }
    }

    setState(() {
      _llmBusy = true;
    });

    try {
      final model = appState.selectedLocalLlmModel;
      updateProgress('=== Performance-Benchmark ===');
      updateProgress('Modell: ${model.displayName}');
      updateProgress('---------------------------');

      // 1/4. Entladen
      updateProgress('[Schritt 1/4] Entlade eventuell geladenes Modell...');
      final service = LlmService(selectedModel: model);
      await service.dispose();
      updateProgress('   -> Modell entladen.');

      // 2/4. Kaltstart-Ladezeit messen
      updateProgress('[Schritt 2/4] Messe Ladezeit (Kaltstart / Warmup)...');
      final loadWatch = Stopwatch()..start();
      await service.warmUp(supportImage: model.supportsVision);
      loadWatch.stop();

      final backend = service.loadedBackendName;
      updateProgress('   -> Geladen in: ${loadWatch.elapsedMilliseconds} ms (${backend})');

      // 3/4. Inferenzzeit messen (Kurzer Prompt)
      updateProgress('[Schritt 3/4] Führe Inferenz durch (Kurzantwort)...');
      final infWatch = Stopwatch()..start();
      final response = await service.runDebugPrompt();
      infWatch.stop();
      updateProgress('   -> Inferenzzeit: ${infWatch.elapsedMilliseconds} ms');
      updateProgress('   -> Antwort: "$response"');

      // 4/4. Inferenzzeit messen (Nährwert Prompt)
      updateProgress('[Schritt 4/4] Führe Nährwert-Prompt aus...');
      final foodWatch = Stopwatch()..start();
      final foodResponse = await service.runMockFoodPrompt();
      foodWatch.stop();
      updateProgress('   -> Nährwert-Inferenzzeit: ${foodWatch.elapsedMilliseconds} ms');
      updateProgress('   -> Antwort: "$foodResponse"');

      updateProgress('---------------------------');
      updateProgress('Zusammenfassung:');
      updateProgress('  - Modell-Laden: ${loadWatch.elapsedMilliseconds} ms');
      updateProgress('  - Kurze Inferenz: ${infWatch.elapsedMilliseconds} ms');
      updateProgress('  - Nährwert Inferenz: ${foodWatch.elapsedMilliseconds} ms');
      final total = loadWatch.elapsedMilliseconds + infWatch.elapsedMilliseconds + foodWatch.elapsedMilliseconds;
      updateProgress('  - Gesamtzeit: $total ms');

      await service.dispose();
    } catch (e) {
      if (mounted) {
        setState(() {
          _llmStatusMessage = 'Benchmark fehlgeschlagen:\n$e\n\nBisherige Logs:\n${results.join("\n")}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _llmBusy = false;
        });
      }
    }
  }

  String _llmErrorText(Object error) {
    if (error is LlmModelUnavailableError ||
        error is LlmUnsupportedPlatformError ||
        error is LlmInputValidationError ||
        error is LlmInferenceError ||
        error is LlmJsonParseError) {
      return error.toString();
    }
    return 'Lokaler Modelltest fehlgeschlagen: $error';
  }

  Widget _timeTile(String title, TimeOfDay time, Function(TimeOfDay) onPicked) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      ),
      onTap: () async {
        final picked = await _pickTime(time);
        if (picked != null) {
          onPicked(picked);
        }
      },
    );
  }

  Widget _settingsSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 22),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _localModelStatusIcon({
    required bool installed,
    required bool downloading,
  }) {
    if (downloading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      );
    }
    if (installed) {
      return Tooltip(
        message: 'Installiert',
        child: Icon(
          Icons.check_circle,
          color: Colors.green.shade700,
        ),
      );
    }
    return Tooltip(
      message: 'Nicht installiert',
      child: Icon(
        Icons.download_for_offline_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    int currentCalorieGoal =
        int.tryParse(calorieController.text) ?? appState.dailyCalorieGoal;
    double carbGrams = (currentCalorieGoal * carbPercentage / 100) / 4.0;
    double proteinGrams = (currentCalorieGoal * proteinPercentage / 100) / 4.0;
    double fatGrams = (currentCalorieGoal * fatPercentage / 100) / 9.0;
    double sugarGrams = carbGrams * sugarPercentage / 100;
    int totalPercentage = carbPercentage + proteinPercentage + fatPercentage;
    int difference = totalPercentage - 100;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [const Text('Einstellungen')]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ExpansionTile(
              title: _settingsSectionTitle(
                Icons.flag_outlined,
                'Ziele einstellen (manuell)',
              ),
              children: [
                TextField(
                  controller: calorieController,
                  decoration: const InputDecoration(
                    labelText: 'Kalorien (kcal)',
                    hintText: 'z.B. 2000',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kohlenhydrate (%)'),
                    Row(
                      children: [
                        DropdownButton<int>(
                          value: carbPercentage,
                          items: List.generate(21, (index) => index * 5)
                              .map(
                                (value) => DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value%'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                carbPercentage = value;
                              });
                            }
                          },
                        ),
                        SizedBox(width: 10),
                        Text(': ${carbGrams.toStringAsFixed(0)} g'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Zucker (% von KH)'),
                    Row(
                      children: [
                        DropdownButton<int>(
                          value: sugarPercentage,
                          items: List.generate(21, (index) => index * 5)
                              .map(
                                (value) => DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value%'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                sugarPercentage = value;
                              });
                            }
                          },
                        ),
                        SizedBox(width: 10),
                        Text(': ${sugarGrams.toStringAsFixed(0)} g'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Proteine (%)'),
                    Row(
                      children: [
                        DropdownButton<int>(
                          value: proteinPercentage,
                          items: List.generate(21, (index) => index * 5)
                              .map(
                                (value) => DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value%'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                proteinPercentage = value;
                              });
                            }
                          },
                        ),
                        SizedBox(width: 10),
                        Text(': ${proteinGrams.toStringAsFixed(0)} g'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fette (%)'),
                    Row(
                      children: [
                        DropdownButton<int>(
                          value: fatPercentage,
                          items: List.generate(21, (index) => index * 5)
                              .map(
                                (value) => DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value%'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                fatPercentage = value;
                              });
                            }
                          },
                        ),
                        SizedBox(width: 10),
                        Text(': ${fatGrams.toStringAsFixed(0)} g'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  difference > 0
                      ? 'Die Summe ist ${difference.abs()}% zu hoch.'
                      : difference < 0
                          ? 'Die Summe ist ${difference.abs()}% zu niedrig.'
                          : 'Die Summe der Makronährstoffe beträgt 100%',
                  style: TextStyle(
                    color: difference == 0
                        ? Colors.green
                        : difference > 0
                            ? Colors.red[700]
                            : Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _saveSettings(appState, forceManualMode: true),
                      child: Text('Speichern'),
                    ),
                    ElevatedButton(
                      onPressed: () => _resetGoals(appState),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text('Zurücksetzen'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ExpansionTile(
              title: _settingsSectionTitle(
                Icons.trending_up,
                'Automatische Kaloriensteuerung',
              ),
              children: [
                RadioListTile<AutoCalorieMode>(
                  title: Text('Aus (manuell)'),
                  value: AutoCalorieMode.off,
                  groupValue: _selectedMode,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMode = val;
                      });
                    }
                  },
                ),
                RadioListTile<AutoCalorieMode>(
                  title: Text('Diät-Modus (ca. -1% pro Woche)'),
                  value: AutoCalorieMode.diet,
                  groupValue: _selectedMode,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMode = val;
                      });
                    }
                  },
                ),
                RadioListTile<AutoCalorieMode>(
                  title: Text('Aufbau-Modus (ca. +1% pro Monat)'),
                  value: AutoCalorieMode.bulk,
                  groupValue: _selectedMode,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMode = val;
                      });
                    }
                  },
                ),
                RadioListTile<AutoCalorieMode>(
                  title: Text('Eigenen Prozentsatz einstellen (Monat)'),
                  value: AutoCalorieMode.custom,
                  groupValue: _selectedMode,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMode = val;
                      });
                    }
                  },
                ),
                RadioListTile<AutoCalorieMode>(
                  title: const Text('Erhalt (Gewicht halten)'),
                  subtitle: const Text('±0 % pro Monat'),
                  value: AutoCalorieMode.maintain,
                  groupValue: _selectedMode,
                  onChanged: (val) => setState(() => _selectedMode = val!),
                ),
                if (_selectedMode == AutoCalorieMode.custom) ...[
                  Row(
                    children: [
                      SizedBox(width: 16),
                      Text('Prozentsatz pro Monat:'),
                      SizedBox(width: 16),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _customPercentController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(labelText: '%'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
                Divider(),
                CheckboxListTile(
                  title: Text('Eigene Startkalorien verwenden'),
                  value: _useCustomStartCals,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _useCustomStartCals = val;
                      });
                    }
                  },
                ),
                if (_useCustomStartCals) ...[
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: TextField(
                      controller: _startCaloriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Start-Kalorien (z.B. 2000)',
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 16),
                Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Alter (Jahre)'),
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Körpergröße (cm)'),
                  ),
                ),
                SizedBox(height: 16),
                // ----- Geschlecht -------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Geschlecht',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RadioListTile<Gender>(
                        title: const Text('Männlich'),
                        value: Gender.male,
                        groupValue: _selectedGender,
                        onChanged: (val) =>
                            setState(() => _selectedGender = val!),
                      ),
                      RadioListTile<Gender>(
                        title: const Text('Weiblich'),
                        value: Gender.female,
                        groupValue: _selectedGender,
                        onChanged: (val) =>
                            setState(() => _selectedGender = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ----- Formelwahl --------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButtonFormField<BmrFormula>(
                    value: _selectedFormula,
                    decoration: const InputDecoration(
                      labelText: 'BMR-Formel',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: BmrFormula.mifflin,
                        child: Text('Mifflin-St Jeor'),
                      ),
                      DropdownMenuItem(
                        value: BmrFormula.harris,
                        child: Text('Harris-Benedict'),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedFormula = val!),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<double>(
                          value: _selectedPalValue,
                          decoration: InputDecoration(
                            labelText: 'Aktivitätsfaktor',
                            border: OutlineInputBorder(),
                          ),
                          items: _palOptions
                              .map(
                                (pal) => DropdownMenuItem<double>(
                                  value: pal.value,
                                  child: Text(pal.title),
                                ),
                              )
                              .toList(),
                          onChanged: (newVal) {
                            if (newVal != null) {
                              setState(() {
                                _selectedPalValue = newVal;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.help_outline),
                        onPressed: () {
                          final selected = _palOptions.firstWhere(
                            (p) => p.value == _selectedPalValue,
                            orElse: () => _palOptions.first,
                          );
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(selected.title),
                              content: Text(selected.description),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text('Protein nach kg Koerpergewicht'),
                  subtitle: Text(
                    'Setzt das Proteinziel direkt aus Gewicht x g/kg.',
                  ),
                  value: _useProteinPerKg,
                  onChanged: (value) {
                    setState(() {
                      _useProteinPerKg = value;
                    });
                  },
                ),
                if (_useProteinPerKg)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _proteinPerKgController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(labelText: 'Protein g/kg'),
                    ),
                  ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _targetWeightController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Zielgewicht (optional)',
                          suffixText: 'kg',
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _targetDate == null
                                  ? 'Kein Zieldatum'
                                  : 'Bis ${DateFormat('dd.MM.yyyy').format(_targetDate!)}',
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _targetDate ?? now,
                                firstDate: now.subtract(Duration(days: 1)),
                                lastDate: DateTime(now.year + 5),
                              );
                              if (picked != null) {
                                setState(() => _targetDate = picked);
                              }
                            },
                            child: Text('Datum'),
                          ),
                        ],
                      ),
                      TextField(
                        controller: _targetWeeklyController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Zielrate alternativ',
                          suffixText: 'kg/Woche',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _saveSettings(appState),
                      child: Text('Speichern (Auto-Modus)'),
                    ),
                    IconButton(
                      icon: Icon(Icons.help_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Formel Info'),
                            content: const Text(
                              'Mifflin-St Jeor:\n'
                              ' 10 × Gewicht + 6.25 × Größe – 5 × Alter + s\n'
                              '   s = +5 (männlich) / −161 (weiblich)\n\n'
                              'Harris-Benedict:\n'
                              '  Männer: 66.5 + 13.7 × Gewicht + 5 × Größe – 6.8 × Alter\n'
                              '  Frauen: 655 + 9.6 × Gewicht + 1.8 × Größe – 4.7 × Alter\n\n'
                              '→ Ergebnis danach mit Aktivitätsfaktor multiplizieren.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ExpansionTile(
              title: _settingsSectionTitle(
                Icons.memory,
                'Lokales Vision-Modell',
              ),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: LocalLlmModel.supported.map((model) {
                      final installed =
                          appState.isLocalLlmModelMarkedInstalled(model);
                      final downloading =
                          appState.downloadingLocalLlmModel?.fileName ==
                              model.fileName;
                      return RadioListTile<LocalLlmModelId>(
                        title: Text(model.displayName),
                        subtitle: Text(model.recommendation),
                        secondary: _localModelStatusIcon(
                          installed: installed,
                          downloading: downloading,
                        ),
                        value: model.id,
                        groupValue: appState.selectedLocalLlmModel.id,
                        onChanged:
                            _llmBusy || appState.isLocalModelDownloadRunning
                                ? null
                                : (value) async {
                                    if (value == null) return;
                                    await appState.setSelectedLocalLlmModel(
                                      LocalLlmModel.byId(value),
                                    );
                                    if (mounted) {
                                      setState(() {
                                        _llmStatusMessage = null;
                                      });
                                    }
                                  },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 12),
                if (appState.localModelDownloadProgress != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: LinearProgressIndicator(
                      value: appState.localModelDownloadProgress! / 100.0,
                    ),
                  ),
                if (_llmStatusMessage != null ||
                    appState.localModelDownloadMessage != null)
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _llmStatusMessage ??
                            appState.localModelDownloadMessage!,
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed:
                            _llmBusy || appState.isLocalModelDownloadRunning
                                ? null
                                : () => _checkLocalModel(appState),
                        icon: Icon(Icons.inventory_2_outlined),
                        label: Text('Prüfen'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _llmBusy ||
                                appState.isLocalModelDownloadRunning ||
                                appState.isLocalLlmModelMarkedInstalled(
                                  appState.selectedLocalLlmModel,
                                )
                            ? null
                            : () => _downloadLocalModel(appState),
                        icon: Icon(
                          appState.isLocalLlmModelMarkedInstalled(
                            appState.selectedLocalLlmModel,
                          )
                              ? Icons.check_circle_outline
                              : Icons.download,
                        ),
                        label: Text(
                          appState.isLocalLlmModelMarkedInstalled(
                            appState.selectedLocalLlmModel,
                          )
                              ? 'Installiert'
                              : 'Installieren',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            _llmBusy || appState.isLocalModelDownloadRunning
                                ? null
                                : () => _testLocalModel(appState),
                        icon: Icon(Icons.bug_report_outlined),
                        label: Text('Debug-Test'),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            _llmBusy || appState.isLocalModelDownloadRunning
                                ? null
                                : () => _runLlmBenchmark(appState),
                        icon: Icon(Icons.speed_outlined),
                        label: Text('Performance-Benchmark'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
            SizedBox(height: 20),
            ExpansionTile(
              title: _settingsSectionTitle(
                Icons.notifications_active_outlined,
                'Benachrichtigungen',
              ),
              children: [
                SwitchListTile(
                  title: Text('Wiegen-Erinnerung'),
                  value: reminderWeighEnabled,
                  onChanged: (v) {
                    setState(() {
                      reminderWeighEnabled = v;
                    });
                  },
                ),
                if (reminderWeighEnabled)
                  _timeTile('Erste Erinnerung', reminderWeighTime, (picked) {
                    setState(() {
                      reminderWeighTime = picked;
                    });
                  }),
                if (reminderWeighEnabled)
                  _timeTile('Zweite Erinnerung', reminderWeighTime2, (picked) {
                    setState(() {
                      reminderWeighTime2 = picked;
                    });
                  }),
                Divider(),
                SwitchListTile(
                  title: Text('Supplement-Erinnerung'),
                  value: reminderSupplementEnabled,
                  onChanged: (v) {
                    setState(() {
                      reminderSupplementEnabled = v;
                    });
                  },
                ),
                if (reminderSupplementEnabled)
                  _timeTile('Erste Erinnerung', reminderSupplementTime, (
                    picked,
                  ) {
                    setState(() {
                      reminderSupplementTime = picked;
                    });
                  }),
                if (reminderSupplementEnabled)
                  _timeTile('Zweite Erinnerung', reminderSupplementTime2, (
                    picked,
                  ) {
                    setState(() {
                      reminderSupplementTime2 = picked;
                    });
                  }),
                Divider(),
                SwitchListTile(
                  title: Text('Mahlzeiten-Erinnerungen'),
                  value: reminderMealsEnabled,
                  onChanged: (v) {
                    setState(() {
                      reminderMealsEnabled = v;
                    });
                  },
                ),
                if (reminderMealsEnabled)
                  _timeTile('Frühstück', reminderBreakfast, (picked) {
                    setState(() {
                      reminderBreakfast = picked;
                    });
                  }),
                if (reminderMealsEnabled)
                  _timeTile('Mittagessen', reminderLunch, (picked) {
                    setState(() {
                      reminderLunch = picked;
                    });
                  }),
                if (reminderMealsEnabled)
                  _timeTile('Abendessen', reminderDinner, (picked) {
                    setState(() {
                      reminderDinner = picked;
                    });
                  }),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    appState.reminderWeighEnabled = reminderWeighEnabled;
                    appState.reminderWeighTime = reminderWeighTime;
                    appState.reminderWeighTimeSecond = reminderWeighTime2;
                    appState.reminderSupplementEnabled =
                        reminderSupplementEnabled;
                    appState.reminderSupplementTime = reminderSupplementTime;
                    appState.reminderSupplementTimeSecond =
                        reminderSupplementTime2;
                    appState.reminderMealsEnabled = reminderMealsEnabled;
                    appState.reminderBreakfast = reminderBreakfast;
                    appState.reminderLunch = reminderLunch;
                    appState.reminderDinner = reminderDinner;
                    await appState.saveNotificationSettings();
                    await appState.scheduleAllNotifications();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Benachrichtigungseinstellungen gespeichert.',
                        ),
                      ),
                    );
                  },
                  child: Text('Benachrichtigungen speichern'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ExpansionTile(
              title: _settingsSectionTitle(
                Icons.tune,
                'Sonstige Einstellungen',
              ),
              children: [
                SwitchListTile(
                  title: Text(
                    'Dark Mode aktivieren',
                    style: TextStyle(fontSize: 16),
                  ),
                  value: appState.isDarkMode,
                  onChanged: (value) {
                    _toggleDarkMode(appState, value);
                  },
                  secondary: Icon(
                    appState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(
                    'Datenbank zurücksetzen',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () => _resetDatabase(appState),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.blueGrey),
                  title: Text('Logout', style: TextStyle(fontSize: 16)),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () => _logout(appState),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.person_off, color: Colors.red),
                  title: Text(
                    'Account löschen',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () => _deleteAccount(appState),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
