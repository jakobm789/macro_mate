import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';

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
  final List<PalOption> _palOptions = [
    PalOption(1.2, 'Sehr niedrig (1.2)', 'Du verbringst den Großteil des Tages sitzend oder liegend. Beispiele: Bettlägerig oder reine Sitzarbeit.'),
    PalOption(1.375, 'Niedrig (1.375)', 'Sitzende Tätigkeit mit wenig Bewegung. Beispiele: Büroarbeit mit kurzen Wegen, kaum Sport.'),
    PalOption(1.55, 'Mäßig aktiv (1.55)', 'Überwiegend sitzend, aber regelmäßige leichte Aktivitäten. Beispiele: Büro mit Freizeitaktivitäten, 1–3 Sporteinheiten pro Woche.'),
    PalOption(1.725, 'Aktiv (1.725)', 'Überwiegend körperliche Tätigkeit oder regelmäßiger Sport. Beispiele: Handwerker, Pfleger, 4–6 Sporteinheiten pro Woche.'),
    PalOption(1.9, 'Sehr aktiv (1.9)', 'Überwiegend schwere körperliche Arbeit oder intensiver Sport. Beispiele: Bauarbeiter, Leistungssportler, täglich intensives Training.'),
    PalOption(2.2, 'Extrem aktiv (2.2)', 'Sehr hohe körperliche Belastung. Beispiele: Berufssportler (Marathon).'),
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

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    int f(int value) {
      return (value / 5).round() * 5;
    }
    carbPercentage = f(((appState.dailyCarbGoal * 4 / appState.dailyCalorieGoal) * 100).round());
    proteinPercentage = f(((appState.dailyProteinGoal * 4 / appState.dailyCalorieGoal) * 100).round());
    fatPercentage = f(((appState.dailyFatGoal * 9 / appState.dailyCalorieGoal) * 100).round());
    sugarPercentage = appState.dailySugarGoalPercentage;
    calorieController = TextEditingController(text: appState.dailyCalorieGoal.toString());
    _selectedMode = appState.autoMode;
    _customPercentController = TextEditingController(text: appState.customPercentPerMonth.toStringAsFixed(1));
    _useCustomStartCals = appState.useCustomStartCalories;
    _startCaloriesController = TextEditingController(text: appState.userStartCalories.toString());
    _ageController = TextEditingController(text: appState.userAge.toString());
    double storedPal = appState.userActivityLevel;
    final palCandidates = _palOptions.map((p) => p.value).toList();
    double closest = palCandidates.reduce((a, b) => (storedPal - a).abs() < (storedPal - b).abs() ? a : b);
    _selectedPalValue = closest;
    reminderWeighEnabled = appState.reminderWeighEnabled;
    reminderWeighTime = appState.reminderWeighTime;
    reminderWeighTime2 = appState.reminderWeighTimeSecond;
    reminderSupplementEnabled = appState.reminderSupplementEnabled;
    reminderSupplementTime = appState.reminderSupplementTime;
    reminderSupplementTime2 = appState.reminderSupplementTimeSecond;
    reminderMealsEnabled = appState.reminderMealsEnabled;
    reminderBreakfast = appState.reminderBreakfast;
    reminderLunch = appState.reminderLunch;
    reminderDinner = appState.reminderDinner;
  }

  @override
  void dispose() {
    calorieController.dispose();
    _customPercentController.dispose();
    _startCaloriesController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  bool _validatePercentages() {
    int total = carbPercentage + proteinPercentage + fatPercentage;
    return total == 100;
  }

  void _saveSettings(AppState appState) async {
    int? newCalorieGoal = int.tryParse(calorieController.text);
    int? newSugarPerc = sugarPercentage;
    int? newAge = int.tryParse(_ageController.text);
    double newActivity = _selectedPalValue;
    if (newCalorieGoal != null && newCalorieGoal > 0 && _validatePercentages() && newAge != null && newAge > 0 && newActivity > 0.0) {
      appState.dailyCalorieGoal = newCalorieGoal;
      appState.userAge = newAge;
      appState.userActivityLevel = newActivity;
      await appState.updateGoals(newCalorieGoal, carbPercentage, proteinPercentage, fatPercentage, newSugarPerc!);
      appState.autoMode = _selectedMode;
      double? customVal = double.tryParse(_customPercentController.text.replaceAll(',', '.'));
      if (customVal == null) {
        customVal = 1.0;
      }
      appState.customPercentPerMonth = customVal;
      appState.useCustomStartCalories = _useCustomStartCals;
      int? startCals = int.tryParse(_startCaloriesController.text);
      if (startCals == null || startCals < 500) {
        startCals = 2000;
      }
      appState.userStartCalories = startCals;
      appState.reminderWeighEnabled = reminderWeighEnabled;
      appState.reminderWeighTime = reminderWeighTime;
      appState.reminderWeighTimeSecond = reminderWeighTime2;
      appState.reminderSupplementEnabled = reminderSupplementEnabled;
      appState.reminderSupplementTime = reminderSupplementTime;
      appState.reminderSupplementTimeSecond = reminderSupplementTime2;
      appState.reminderMealsEnabled = reminderMealsEnabled;
      appState.reminderBreakfast = reminderBreakfast;
      appState.reminderLunch = reminderLunch;
      appState.reminderDinner = reminderDinner;
      await appState.updateGoals(appState.dailyCalorieGoal, carbPercentage, proteinPercentage, fatPercentage, sugarPercentage);
      appState.scheduleAllNotifications();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Einstellungen gespeichert.')));
      Navigator.of(context).pop();
    } else {
      String errorMessage = '';
      if (newCalorieGoal == null || newCalorieGoal <= 0) {
        errorMessage += 'Bitte gib eine gültige Kalorienzahl ein.\n';
      }
      if (!_validatePercentages()) {
        errorMessage += 'Die Makro-Prozentwerte müssen insgesamt 100% ergeben.\n';
      }
      if (newAge == null || newAge <= 0) {
        errorMessage += 'Bitte ein gültiges Alter eingeben.\n';
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
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
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
    });
    appState.updateGoals(2000, 50, 30, 20, 20);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ziele wurden zurückgesetzt.')));
  }

  void _resetDatabase(AppState appState) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Datenbank zurücksetzen'),
          content: const Text('Möchtest du wirklich alle Daten löschen und die Datenbank neu erstellen? Dies kann nicht rückgängig gemacht werden.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Abbrechen')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Löschen')),
          ],
        );
      },
    );
    if (confirm == true) {
      try {
        await appState.resetDatabase();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Datenbank erfolgreich zurückgesetzt.')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim Zurücksetzen der Datenbank: $e')));
      }
    }
  }

  void _toggleDarkMode(AppState appState, bool value) async {
    await appState.toggleDarkMode(value);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value ? 'Dark Mode aktiviert.' : 'Dark Mode deaktiviert.')));
  }

  void _logout(AppState appState, ) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Möchtest du dich wirklich abmelden?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Abbrechen')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Logout')),
          ],
        );
      },
    );
    if (confirm == true) {
      await appState.logout();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erfolgreich ausgeloggt.')));
    }
  }

  void _deleteAccount(AppState appState) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Account löschen'),
          content: const Text('Möchtest du deinen Account wirklich löschen? Dies kann nicht rückgängig gemacht werden.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Abbrechen')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Löschen')),
          ],
        );
      },
    );
    if (confirm == true) {
      final ok = await appState.deleteAccount();
      if (ok) {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account wurde gelöscht.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account konnte nicht gelöscht werden.')));
      }
    }
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay initial) async {
    return await showTimePicker(context: context, initialTime: initial);
  }

  Widget _timeTile(String title, TimeOfDay time, Function(TimeOfDay) onPicked) {
    return ListTile(
      title: Text(title),
      trailing: Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'),
      onTap: () async {
        final picked = await _pickTime(time);
        if (picked != null) {
          onPicked(picked);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    int currentCalorieGoal = int.tryParse(calorieController.text) ?? appState.dailyCalorieGoal;
    double carbGrams = (currentCalorieGoal * carbPercentage / 100) / 4.0;
    double proteinGrams = (currentCalorieGoal * proteinPercentage / 100) / 4.0;
    double fatGrams = (currentCalorieGoal * fatPercentage / 100) / 9.0;
    double sugarGrams = carbGrams * sugarPercentage / 100;
    int totalPercentage = carbPercentage + proteinPercentage + fatPercentage;
    int difference = totalPercentage - 100;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Einstellungen'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ExpansionTile(
              title: const Text('Ziele einstellen (manuell)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                TextField(
                  controller: calorieController,
                  decoration: const InputDecoration(labelText: 'Kalorien (kcal)', hintText: 'z.B. 2000'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kohlenhydrate (%)'),
                    Row(
                      children: [
                        DropdownButton<int>(
                          value: carbPercentage,
                          items: List.generate(21, (index) => index * 5).map((value) => DropdownMenuItem<int>(value: value, child: Text('$value%'))).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                carbPercentage = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(': ${carbGrams.toStringAsFixed(0)} g'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Zucker (% von KH)'),
                    Row(
                      children: [
                        DropdownButton<int>(
                          value: sugarPercentage,
                          items: List.generate(21, (index) => index * 5).map((value) => DropdownMenuItem<int>(value: value, child: Text('$value%'))).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                sugarPercentage = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(': ${sugarGrams.toStringAsFixed(0)} g'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Proteine (%)'),
                    Row(
                      children: [
                        DropdownButton<int>(
                          value: proteinPercentage,
                          items: List.generate(21, (index) => index * 5).map((value) => DropdownMenuItem<int>(value: value, child: Text('$value%'))).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                proteinPercentage = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(': ${proteinGrams.toStringAsFixed(0)} g'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Fette (%)'),
                    Row(
                      children: [
                        DropdownButton<int>(
                          value: fatPercentage,
                          items: List.generate(21, (index) => index * 5).map((value) => DropdownMenuItem<int>(value: value, child: Text('$value%'))).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                fatPercentage = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(': ${fatGrams.toStringAsFixed(0)} g'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  difference > 0 ? 'Die Summe ist ${difference.abs()}% zu hoch.' : difference < 0 ? 'Die Summe ist ${difference.abs()}% zu niedrig.' : 'Die Summe der Makronährstoffe beträgt 100%',
                  style: TextStyle(
                    color: difference == 0 ? Colors.green : difference > 0 ? Colors.red[700] : Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(onPressed: () => _saveSettings(appState), child: const Text('Speichern')),
                    ElevatedButton(onPressed: () => _resetGoals(appState), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Zurücksetzen')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ExpansionTile(
              title: const Text('Automatische Kaloriensteuerung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                RadioListTile<AutoCalorieMode>(
                  title: const Text('Aus (manuell)'),
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
                  title: const Text('Diät-Modus (ca. -1% pro Woche)'),
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
                  title: const Text('Aufbau-Modus (ca. +1% pro Monat)'),
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
                  title: const Text('Eigenen Prozentsatz einstellen (Monat)'),
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
                if (_selectedMode == AutoCalorieMode.custom) ...[
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      const Text('Prozentsatz pro Monat:'),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _customPercentController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: '%'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                const Divider(),
                CheckboxListTile(
                  title: const Text('Eigene Startkalorien verwenden'),
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
                    padding: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      controller: _startCaloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Start-Kalorien (z.B. 2000)'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Alter (Jahre)'),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<double>(
                          value: _selectedPalValue,
                          decoration: const InputDecoration(labelText: 'Aktivitätsfaktor', border: OutlineInputBorder()),
                          items: _palOptions.map((pal) => DropdownMenuItem<double>(value: pal.value, child: Text(pal.title))).toList(),
                          onChanged: (newVal) {
                            if (newVal != null) {
                              setState(() {
                                _selectedPalValue = newVal;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: () {
                          final selected = _palOptions.firstWhere((p) => p.value == _selectedPalValue, orElse: () => _palOptions.first);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(selected.title),
                              content: Text(selected.description),
                              actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: () => _saveSettings(appState), child: const Text('Speichern (Auto-Modus)')),
                    IconButton(
                      icon: const Icon(Icons.help_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Formel Info'),
                            content: const Text('Formel: \n\n Umsatz = \n 66 + (13.7 * KG) + (5 * 170) - (6.8 * Alter). \n\n Danach multipliziert mit Aktivitätsfaktor. \n KG: Körpergewicht'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ExpansionTile(
              title: const Text('Benachrichtigungen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                SwitchListTile(
                  title: const Text('Wiegen-Erinnerung'),
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
                const Divider(),
                SwitchListTile(
                  title: const Text('Supplement-Erinnerung'),
                  value: reminderSupplementEnabled,
                  onChanged: (v) {
                    setState(() {
                      reminderSupplementEnabled = v;
                    });
                  },
                ),
                if (reminderSupplementEnabled)
                  _timeTile('Erste Erinnerung', reminderSupplementTime, (picked) {
                    setState(() {
                      reminderSupplementTime = picked;
                    });
                  }),
                if (reminderSupplementEnabled)
                  _timeTile('Zweite Erinnerung', reminderSupplementTime2, (picked) {
                    setState(() {
                      reminderSupplementTime2 = picked;
                    });
                  }),
                const Divider(),
                SwitchListTile(
                  title: const Text('Mahlzeiten-Erinnerungen'),
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
              ],
            ),
            const SizedBox(height: 20),
            ExpansionTile(
              title: const Text('Sonstige Einstellungen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode aktivieren', style: TextStyle(fontSize: 16)),
                  value: appState.isDarkMode,
                  onChanged: (value) {
                    _toggleDarkMode(appState, value);
                  },
                  secondary: Icon(appState.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Datenbank zurücksetzen', style: TextStyle(fontSize: 16)),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => _resetDatabase(appState),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.blueGrey),
                  title: const Text('Logout', style: TextStyle(fontSize: 16)),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => _logout(appState),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_off, color: Colors.red),
                  title: const Text('Account löschen', style: TextStyle(fontSize: 16)),
                  trailing: const Icon(Icons.arrow_forward),
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
