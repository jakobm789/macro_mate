// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
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

    calorieController = TextEditingController(text: appState.dailyCalorieGoal.toString());
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

    if (newCalorieGoal != null &&
        newCalorieGoal > 0 &&
        _validatePercentages()) {
      await appState.updateGoals(
        newCalorieGoal,
        carbPercentage,
        proteinPercentage,
        fatPercentage,
        newSugarPerc,
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
    appState.updateGoals(2000, 50, 30, 20, 0);
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
          content: const Text('Möchtest du wirklich alle Daten löschen und die Datenbank neu erstellen? Dies kann nicht rückgängig gemacht werden.'),
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

  Future<void> _exportDatabase(AppState appState) async {
    try {
      // Exportiere die Datenbank als JSON-String
      String jsonData = await appState.exportDatabase();

      // Erstelle temporäre Datei
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/macro_mate_export.json');
      await tempFile.writeAsString(jsonData);

      // Erstelle ein XFile-Objekt aus der Datei
      final xFile = XFile(tempFile.path);

      // Teile die Datei
      await Share.shareXFiles(
        [xFile],
        text: 'Hier sind meine MacroMate Daten.',
      );
    } catch (e) {
      // Zeige Fehlermeldung an
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Exportieren: $e')),
      );
    }
  }

  // Import aus Datei: JSON-Datei auswählen und dann importieren (Mergen)
  Future<void> _importDatabase(AppState appState) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Datenbank importieren'),
          content: Text('Möchtest du eine JSON-Datei laden und deine Daten damit ergänzen? Bestehende Einträge bleiben bestehen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Datei wählen'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        try {
          String fileContent = await File(filePath).readAsString();
          await appState.importDatabase(fileContent);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Datenbank erfolgreich importiert und gemergt.')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Import: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Keine Datei ausgewählt.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        int currentCalorieGoal = int.tryParse(calorieController.text) ?? appState.dailyCalorieGoal;
        double carbGrams = (currentCalorieGoal * carbPercentage / 100) / 4.0;
        double proteinGrams = (currentCalorieGoal * proteinPercentage / 100) / 4.0;
        double fatGrams = (currentCalorieGoal * fatPercentage / 100) / 9.0;
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
                              items: List.generate(21, (index) => index * 5).map((value) {
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
                              items: List.generate(21, (index) => index * 5).map((value) {
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
                              items: List.generate(21, (index) => index * 5).map((value) {
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
                              items: List.generate(21, (index) => index * 5).map((value) {
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                      value: appState.isDarkMode,
                      onChanged: (value) {
                        _toggleDarkMode(appState, value);
                      },
                      secondary: Icon(appState.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                    ),

                    const SizedBox(height: 20),

                    ListTile(
                      leading: Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text(
                        'Datenbank zurücksetzen',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () => _resetDatabase(appState),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Daten teilen (Export/Import) mit Datei
                ExpansionTile(
                  title: const Text(
                    'Daten teilen',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    ListTile(
                      leading: Icon(Icons.file_upload, color: Colors.blue),
                      title: Text('Datenbank exportieren und teilen'),
                      subtitle: Text('Exportiert deine Daten als JSON-Datei zum Teilen.'),
                      onTap: () => _exportDatabase(appState),
                    ),
                    ListTile(
                      leading: Icon(Icons.file_download, color: Colors.green),
                      title: Text('Datenbank aus Datei importieren'),
                      subtitle: Text('Wähle eine JSON-Datei und merge sie mit deinen Daten.'),
                      onTap: () => _importDatabase(appState),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
    }
}
