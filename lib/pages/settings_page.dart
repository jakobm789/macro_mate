// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

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

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);

    int _roundToNearestFive(int value) {
      return (value / 5).round() * 5;
    }

    // Aktuelle Werte aus dem AppState holen und ggf. runden
    carbPercentage = _roundToNearestFive(
      ((appState.dailyCarbGoal * 4 / appState.dailyCalorieGoal) * 100).round(),
    );
    proteinPercentage = _roundToNearestFive(
      ((appState.dailyProteinGoal * 4 / appState.dailyCalorieGoal) * 100).round(),
    );
    fatPercentage = _roundToNearestFive(
      ((appState.dailyFatGoal * 9 / appState.dailyCalorieGoal) * 100).round(),
    );
    sugarPercentage = appState.dailySugarGoalPercentage;

    calorieController =
        TextEditingController(text: appState.dailyCalorieGoal.toString());
  }

  @override
  void dispose() {
    calorieController.dispose();
    super.dispose();
  }

  bool _validatePercentages() {
    int total = carbPercentage + proteinPercentage + fatPercentage;
    return total == 100;
  }

  void _saveSettings(AppState appState) async {
    int? newCalorieGoal = int.tryParse(calorieController.text);
    int? newSugarPerc = sugarPercentage;

    if (newCalorieGoal != null && newCalorieGoal > 0 && _validatePercentages()) {
      await appState.updateGoals(
        newCalorieGoal,
        carbPercentage,
        proteinPercentage,
        fatPercentage,
        newSugarPerc!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ziele erfolgreich gespeichert.')),
      );

      Navigator.of(context).pop();
    } else {
      String errorMessage = '';
      if (newCalorieGoal == null || newCalorieGoal <= 0) {
        errorMessage += 'Bitte gib eine gültige Kalorienzahl ein.\n';
      }
      if (!_validatePercentages()) {
        errorMessage += 'Die Prozentwerte müssen insgesamt 100% ergeben.\n';
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
    });
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
              'Möchtest du wirklich alle Daten löschen und die Datenbank neu erstellen? '
              'Dies kann nicht rückgängig gemacht werden.'),
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
      SnackBar(content: Text(value ? 'Dark Mode aktiviert.' : 'Dark Mode deaktiviert.')),
    );
  }

  // Logout
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erfolgreich ausgeloggt.')),
      );
    }
  }

  // Account löschen
  void _deleteAccount(AppState appState) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Account löschen'),
          content: const Text(
            'Möchtest du deinen Account wirklich löschen? '
            'Dies kann nicht rückgängig gemacht werden.',
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
        Navigator.of(context).pop(); // Schließt Settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account wurde gelöscht.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account konnte nicht gelöscht werden.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        int currentCalorieGoal =
            int.tryParse(calorieController.text) ?? appState.dailyCalorieGoal;
        double carbGrams = (currentCalorieGoal * carbPercentage / 100) / 4.0;
        double proteinGrams =
            (currentCalorieGoal * proteinPercentage / 100) / 4.0;
        double fatGrams =
            (currentCalorieGoal * fatPercentage / 100) / 9.0;
        double sugarGrams = carbGrams * sugarPercentage / 100;
        int totalPercentage = carbPercentage + proteinPercentage + fatPercentage;
        int percentageDifference = totalPercentage - 100;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Einstellungen'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ExpansionTile(
                  title: const Text(
                    'Ziele einstellen',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kohlenhydrate (%)'),
                        Row(
                          children: [
                            DropdownButton<int>(
                              value: carbPercentage,
                              items: List.generate(21, (index) => index * 5)
                                  .map((value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value%'),
                                );
                              }).toList(),
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
                        const Text('Zucker (% von Kohlenhydraten)'),
                        Row(
                          children: [
                            DropdownButton<int>(
                              value: sugarPercentage,
                              items: List.generate(21, (index) => index * 5)
                                  .map((value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value%'),
                                );
                              }).toList(),
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
                              items: List.generate(21, (index) => index * 5)
                                  .map((value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value%'),
                                );
                              }).toList(),
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
                              items: List.generate(21, (index) => index * 5)
                                  .map((value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value%'),
                                );
                              }).toList(),
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
                      percentageDifference > 0
                          ? 'Die Summe ist ${percentageDifference.abs()}% zu hoch.'
                          : percentageDifference < 0
                              ? 'Die Summe ist ${percentageDifference.abs()}% zu niedrig.'
                              : 'Die Summe der Makronährstoffe beträgt 100%',
                      style: TextStyle(
                        color: percentageDifference == 0
                            ? Colors.green
                            : percentageDifference > 0
                                ? Colors.red[700]
                                : Colors.orange[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => _saveSettings(appState),
                          child: const Text('Speichern'),
                        ),
                        ElevatedButton(
                          onPressed: () => _resetGoals(appState),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Zurücksetzen'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ExpansionTile(
                  title: const Text(
                    'Sonstige Einstellungen',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Dark Mode aktivieren',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                      value: appState.isDarkMode,
                      onChanged: (value) {
                        _toggleDarkMode(appState, value);
                      },
                      secondary: Icon(appState.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text(
                        'Datenbank zurücksetzen',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => _resetDatabase(appState),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.blueGrey),
                      title: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => _logout(appState),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.person_off, color: Colors.red),
                      title: const Text(
                        'Account löschen',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => _deleteAccount(appState),
                    ),
                    // Hier haben wir den Menüpunkt "Gewicht tracken" ENTFERNT
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
