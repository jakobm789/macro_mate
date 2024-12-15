// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/food_item.dart';
import '../models/consumed_food_item.dart';
import '../widgets/add_food_sheet.dart';
import '../widgets/meal_section.dart';
import '../services/database_helper.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _calorieProgress(AppState state) =>
      state.consumedCalories / state.dailyCalorieGoal;
  double _carbProgress(AppState state) =>
      state.consumedCarbs / state.dailyCarbGoal;
  double _proteinProgress(AppState state) =>
      state.consumedProtein / state.dailyProteinGoal;
  double _fatProgress(AppState state) =>
      state.consumedFat / state.dailyFatGoal;
  double _sugarProgress(AppState state) =>
      state.consumedSugar / state.dailySugarGoalGrams; // Aktualisiert auf sugarGoalGrams

  void _scanBarcode(BuildContext parentContext, AppState state, String mealName) async {
    try {
      print('Barcode-Scan gestartet...');
      var result = await BarcodeScanner.scan();
      print('Barcode-Scan abgeschlossen. Ergebnis: $result');

      if (!mounted) return;

      if (result.type == ResultType.Barcode) {
        String barcode = result.rawContent.trim().toLowerCase();
        print('Gescanntes Barcode: $barcode');
        if (barcode.isEmpty) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            SnackBar(content: Text('Kein Barcode gefunden.')),
          );
          return;
        }

        FoodItem? food = await DatabaseHelper().getFoodItemByBarcode(barcode);
        print('FoodItem gefunden: ${food != null ? food.name : 'Nicht gefunden'}');

        if (!mounted) return;

        if (food != null) {
          await showDialog<int>(
            context: parentContext,
            builder: (context) {
              final TextEditingController _gramController = TextEditingController(text: '100');
              return AlertDialog(
                title: Text('Menge für ${food.name} eingeben'),
                content: TextField(
                  controller: _gramController,
                  decoration: InputDecoration(
                    labelText: 'Menge in Gramm',
                    hintText: 'z.B. 150',
                  ),
                  keyboardType: TextInputType.number,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Abbrechen'),
                  ),
                  TextButton(
                    onPressed: () {
                      final grams = int.tryParse(_gramController.text.trim());
                      if (grams != null && grams > 0) {
                        Navigator.pop(context, grams);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Bitte gib eine gültige Menge ein.')),
                        );
                      }
                    },
                    child: Text('Hinzufügen'),
                  ),
                ],
              );
            },
          ).then((grams) async {
            if (grams != null) {
              await Provider.of<AppState>(parentContext, listen: false)
                  .addOrUpdateFood(mealName, food, grams, state.currentDate);
              if (!mounted) return;
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(content: Text('Barcode für ${food.name} mit $grams g hinzugefügt.')),
              );
              // Navigiere zum Home-Screen
              Navigator.popUntil(parentContext, ModalRoute.withName('/'));
            }
          });
        } else {
          print('FoodItem mit Barcode $barcode nicht gefunden.');
          await showDialog(
            context: parentContext,
            builder: (context) {
              return AlertDialog(
                title: Text('Lebensmittel nicht gefunden'),
                content: Text('Der gescannte Barcode wurde keinem Lebensmittel zugeordnet. Möchtest du ein neues Lebensmittel erstellen oder den Barcode einem bestehenden Lebensmittel zuordnen?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      print('Option ausgewählt: Neues Lebensmittel erstellen');
                      Navigator.pop(context);
                      _addNewFoodWithBarcode(parentContext, state, mealName, barcode);
                    },
                    child: Text('Neues Lebensmittel erstellen'),
                  ),
                  TextButton(
                    onPressed: () {
                      print('Option ausgewählt: Barcode zuordnen');
                      Navigator.pop(context);
                      _assignBarcodeToExistingFood(parentContext, state, mealName, barcode);
                    },
                    child: Text('Barcode zuordnen'),
                  ),
                  TextButton(
                    onPressed: () {
                      print('Option ausgewählt: Abbrechen');
                      Navigator.pop(context);
                    },
                    child: Text('Abbrechen'),
                  ),
                ],
              );
            },
          ).then((_) {
            // Optional: Könnte hier ebenfalls zum Home-Screen navigieren, falls gewünscht
          });
        }
      }
    } catch (e) {
      print('Fehler beim Scannen des Barcodes: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text('Fehler beim Scannen des Barcodes: $e')),
      );
    }
  }

  Future<void> _addNewFoodWithBarcode(BuildContext parentContext, AppState state, String mealName, String barcode) async {
    await showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      builder: (context) => AddNewFoodSheet(
        barcode: barcode,
        onFoodAdded: (ConsumedFoodItem consumedFood) {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _assignBarcodeToExistingFood(BuildContext parentContext, AppState state, String mealName, String barcode) async {
    List<FoodItem> existingFoods = await DatabaseHelper().getAllFoodItems();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Barcode einem bestehenden Lebensmittel zuordnen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(),
              Container(
                height: 300,
                child: ListView.builder(
                  itemCount: existingFoods.length,
                  itemBuilder: (context, index) {
                    final food = existingFoods[index];
                    return ListTile(
                      title: Text(food.name),
                      subtitle: Text(
                          'Barcode: ${food.barcode ?? 'Nicht zugeordnet'}'),
                      trailing: food.barcode == null
                          ? IconButton(
                              icon: Icon(Icons.link, color: Colors.blue),
                              onPressed: () async {
                                FoodItem updatedFood = food.copyWith(barcode: barcode);
                                await DatabaseHelper().updateFoodItem(updatedFood);
                                await Provider.of<AppState>(context, listen: false)
                                    .addOrUpdateFood(
                                        mealName, updatedFood, 100, state.currentDate);
                                if (!mounted) return;
                                Navigator.pop(context); // Schließt Barcode-Zuordnung

                                // Navigiere zum Home-Screen
                                Navigator.popUntil(context, ModalRoute.withName('/'));

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Barcode zu ${food.name} zugeordnet und hinzugefügt.')),
                                );
                              },
                            )
                          : null,
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAddFoodOptions(BuildContext context, AppState state, String mealName) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Lebensmittel suchen'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _searchFood(context, state, mealName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Barcode scannen'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _scanBarcode(context, state, mealName);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Beim Aufruf von AddFoodSheet ohne Barcode
  _searchFood(BuildContext context, AppState state, String mealName) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddFoodSheet(
          onFoodAdded: (ConsumedFoodItem consumedFood) {
            Navigator.pop(context);
          },
          mealName: mealName,
          // Entferne oder setze den Barcode auf null, da hier kein Barcode vorhanden ist
          barcode: null, // Optional: Du kannst diese Zeile auch komplett entfernen
        );
      },
    );
  }

  void _goToPreviousDay(AppState state) {
    state.previousDay();
  }

  void _goToNextDay(AppState state) {
    state.nextDay();
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final Color carbProgressColor = Colors.purple;
        final Color proteinProgressColor = Colors.green;
        final Color fatProgressColor = Colors.blue;
        final Color sugarProgressColor = Colors.orange;

        DateTime today = DateTime.now();
        DateTime yesterday = today.subtract(Duration(days: 1));
        DateTime tomorrow = today.add(Duration(days: 1));

        String formattedDate;
        if (_isSameDate(state.currentDate, today)) {
          formattedDate = 'Heute';
        } else if (_isSameDate(state.currentDate, yesterday)) {
          formattedDate = 'Gestern';
        } else if (_isSameDate(state.currentDate, tomorrow)) {
          formattedDate = 'Morgen';
        } else {
          formattedDate = DateFormat('dd.MM.yyyy').format(state.currentDate);
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => _goToPreviousDay(state),
                ),
                SizedBox(width: 8),
                Text('MacroMate - $formattedDate'),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () => _goToNextDay(state),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Kalorien-Fortschrittsbalken
                CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 12.0,
                  percent: _calorieProgress(state).clamp(0.0, 1.0),
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(state.dailyCalorieGoal - state.consumedCalories).toStringAsFixed(0)} kcal',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Verbleibend',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: Colors.grey[300]!,
                  progressColor: Colors.lightBlueAccent,
                  animation: true,
                  animateFromLastPercent: true,
                ),
                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Grundziel:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${state.dailyCalorieGoal.toStringAsFixed(0)} kcal',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Bereits gegessen:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${state.consumedCalories.toStringAsFixed(0)} kcal',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),

                // Makronährstoffe-Fortschrittsbalken als lineare Balken
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kohlenhydrate
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kohlenhydrate (g)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${state.consumedCarbs.toStringAsFixed(0)} / ${state.dailyCarbGoal.toStringAsFixed(0)} g',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    LinearPercentIndicator(
                      lineHeight: 7.0,
                      percent: _carbProgress(state).clamp(0.0, 1.0),
                      progressColor: carbProgressColor,
                      backgroundColor: Colors.grey[300]!,
                      barRadius: Radius.circular(3.5),
                      animation: true,
                    ),
                    SizedBox(height: 16),

                    // Zucker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Zucker (g)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${state.consumedSugar.toStringAsFixed(0)} / ${state.dailySugarGoalGrams.toStringAsFixed(0)} g',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    LinearPercentIndicator(
                      lineHeight: 7.0,
                      percent: _sugarProgress(state).clamp(0.0, 1.0),
                      progressColor: sugarProgressColor,
                      backgroundColor: Colors.grey[300]!,
                      barRadius: Radius.circular(3.5),
                      animation: true,
                    ),
                    SizedBox(height: 16),

                    // Proteine
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Proteine (g)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${state.consumedProtein.toStringAsFixed(0)} / ${state.dailyProteinGoal.toStringAsFixed(0)} g',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    LinearPercentIndicator(
                      lineHeight: 7.0,
                      percent: _proteinProgress(state).clamp(0.0, 1.0),
                      progressColor: proteinProgressColor,
                      backgroundColor: Colors.grey[300]!,
                      barRadius: Radius.circular(3.5),
                      animation: true,
                    ),
                    SizedBox(height: 16),

                    // Fette
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fette (g)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${state.consumedFat.toStringAsFixed(0)} / ${state.dailyFatGoal.toStringAsFixed(0)} g',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    LinearPercentIndicator(
                      lineHeight: 7.0,
                      percent: _fatProgress(state).clamp(0.0, 1.0),
                      progressColor: fatProgressColor,
                      backgroundColor: Colors.grey[300]!,
                      barRadius: Radius.circular(3.5),
                      animation: true,
                    ),
                    SizedBox(height: 24),
                  ],
                ),

                // Mahlzeitenabschnitte
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MealSection(
                      mealName: 'Frühstück',
                      foods: state.breakfast,
                      onAdd: () {
                        _showAddFoodOptions(context, state, 'Frühstück');
                      },
                    ),
                    const SizedBox(height: 8),
                    MealSection(
                      mealName: 'Mittagessen',
                      foods: state.lunch,
                      onAdd: () {
                        _showAddFoodOptions(context, state, 'Mittagessen');
                      },
                    ),
                    const SizedBox(height: 8),
                    MealSection(
                      mealName: 'Abendessen',
                      foods: state.dinner,
                      onAdd: () {
                        _showAddFoodOptions(context, state, 'Abendessen');
                      },
                    ),
                    const SizedBox(height: 8),
                    MealSection(
                      mealName: 'Snacks',
                      foods: state.snacks,
                      onAdd: () {
                        _showAddFoodOptions(context, state, 'Snacks');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: 'Einstellungen',
            child: const Icon(Icons.settings),
          ),
        );
      },
    );
  }
}
