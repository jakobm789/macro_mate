import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/app_state.dart';
import '../models/food_item.dart';
import '../models/consumed_food_item.dart';
import '../widgets/add_food_sheet.dart';
import '../widgets/meal_section.dart';

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
  bool _fabExpanded = false;

  double _calorieProgress(AppState state) =>
      state.consumedCalories / state.dailyCalorieGoal;
  double _carbProgress(AppState state) =>
      state.consumedCarbs / state.dailyCarbGoal;
  double _proteinProgress(AppState state) =>
      state.consumedProtein / state.dailyProteinGoal;
  double _fatProgress(AppState state) => state.consumedFat / state.dailyFatGoal;
  double _sugarProgress(AppState state) =>
      state.consumedSugar / state.dailySugarGoalGrams;

  void _scanBarcode(BuildContext parentContext, AppState state, String mealName) async {
    try {
      var result = await BarcodeScanner.scan();
      if (!mounted) return;

      if (result.type == ResultType.Barcode) {
        String barcode = result.rawContent.trim().toLowerCase();
        if (barcode.isEmpty) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            const SnackBar(content: Text('Kein Barcode gefunden.')),
          );
          return;
        }

        FoodItem? food = await state.loadFoodItemByBarcode(barcode);
        if (!mounted) return;

        if (food != null) {
          _showAddQuantityDialog(parentContext, mealName, food);
        } else {
          FoodItem? offItem = await state.searchOpenFoodFactsByBarcode(barcode);
          if (!mounted) return;

          if (offItem != null) {
            _showAddQuantityDialog(parentContext, mealName, offItem);
          } else {
            await showDialog(
              context: parentContext,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Lebensmittel nicht gefunden'),
                  content: const Text(
                    'Der gescannte Barcode wurde weder in der eigenen noch '
                    'in der Open Food Facts Datenbank gefunden. '
                    'Möchtest du ein neues Lebensmittel erstellen oder '
                    'den Barcode einem bestehenden Lebensmittel zuordnen?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _addNewFoodWithBarcode(parentContext, state, mealName, barcode);
                      },
                      child: const Text('Neues Lebensmittel erstellen'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _assignBarcodeToExistingFood(parentContext, state, mealName, barcode);
                      },
                      child: const Text('Barcode zuordnen'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Abbrechen'),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text('Fehler beim Scannen des Barcodes: $e')),
      );
    }
  }

  void _showAddQuantityDialog(
      BuildContext parentContext, String mealName, FoodItem foundFood) {
    showDialog(
      context: parentContext,
      builder: (context) {
        return AddQuantityDialog(
          food: foundFood,
          mealName: mealName,
          onFoodAdded: (ConsumedFoodItem consumedFood) {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        );
      },
    );
  }

  Future<void> _addNewFoodWithBarcode(
    BuildContext parentContext,
    AppState state,
    String mealName,
    String barcode,
  ) async {
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

  Future<void> _assignBarcodeToExistingFood(
    BuildContext parentContext,
    AppState state,
    String mealName,
    String barcode,
  ) async {
    List<FoodItem> existingFoods = await state.loadAllFoodItems();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Barcode einem bestehenden Lebensmittel zuordnen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: existingFoods.length,
                  itemBuilder: (context, index) {
                    final food = existingFoods[index];
                    return ListTile(
                      title: Text(food.name),
                      subtitle: Text(
                        'Barcode: ${food.barcode ?? 'Nicht zugeordnet'}',
                      ),
                      trailing: food.barcode == null
                          ? IconButton(
                              icon: const Icon(Icons.link, color: Colors.blue),
                              onPressed: () async {
                                await state.updateBarcodeForFood(food, barcode);
                                await Provider.of<AppState>(context, listen: false)
                                    .addOrUpdateFood(
                                  mealName,
                                  food.copyWith(barcode: barcode),
                                  100,
                                  state.currentDate,
                                );
                                if (!mounted) return;
                                Navigator.pop(context);
                                Navigator.popUntil(context, ModalRoute.withName('/'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Barcode zu ${food.name} zugeordnet und hinzugefügt.',
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
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

  void _searchFood(BuildContext context, AppState state, String mealName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddFoodSheet(
          onFoodAdded: (ConsumedFoodItem consumedFood) {
            Navigator.pop(context);
          },
          mealName: mealName,
          barcode: null,
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
        DateTime yesterday = today.subtract(const Duration(days: 1));
        DateTime tomorrow = today.add(const Duration(days: 1));

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
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _goToPreviousDay(state),
                ),
                const SizedBox(width: 8),
                Text('MacroMate - $formattedDate'),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
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
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            const Text(
                              'Verbleibend',
                              textAlign: TextAlign.center,
                              style: TextStyle(
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
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '\nGrundziel:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${state.dailyCalorieGoal.toStringAsFixed(0)} kcal',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gegessen:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${state.consumedCalories.toStringAsFixed(0)} kcal',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kohlenhydrate (g)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${state.consumedCarbs.toStringAsFixed(0)} / '
                          '${state.dailyCarbGoal.toStringAsFixed(0)} g',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearPercentIndicator(
                      lineHeight: 7.0,
                      percent: _carbProgress(state).clamp(0.0, 1.0),
                      progressColor: carbProgressColor,
                      backgroundColor: Colors.grey[300]!,
                      barRadius: const Radius.circular(3.5),
                      animation: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Zucker (g)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${state.consumedSugar.toStringAsFixed(0)} / '
                          '${state.dailySugarGoalGrams.toStringAsFixed(0)} g',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearPercentIndicator(
                      lineHeight: 7.0,
                      percent: _sugarProgress(state).clamp(0.0, 1.0),
                      progressColor: sugarProgressColor,
                      backgroundColor: Colors.grey[300]!,
                      barRadius: const Radius.circular(3.5),
                      animation: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Proteine (g)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${state.consumedProtein.toStringAsFixed(0)} / '
                          '${state.dailyProteinGoal.toStringAsFixed(0)} g',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearPercentIndicator(
                      lineHeight: 7.0,
                      percent: _proteinProgress(state).clamp(0.0, 1.0),
                      progressColor: proteinProgressColor,
                      backgroundColor: Colors.grey[300]!,
                      barRadius: const Radius.circular(3.5),
                      animation: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fette (g)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${state.consumedFat.toStringAsFixed(0)} / '
                          '${state.dailyFatGoal.toStringAsFixed(0)} g',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearPercentIndicator(
                      lineHeight: 7.0,
                      percent: _fatProgress(state).clamp(0.0, 1.0),
                      progressColor: fatProgressColor,
                      backgroundColor: Colors.grey[300]!,
                      barRadius: const Radius.circular(3.5),
                      animation: true,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
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
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_fabExpanded) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: FloatingActionButton(
                    heroTag: 'weightFab',
                    mini: true,
                    onPressed: () {
                      setState(() => _fabExpanded = false);
                      Navigator.pushNamed(context, '/weight');
                    },
                    tooltip: 'Gewicht tracken',
                    child: const Icon(Icons.monitor_weight),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: FloatingActionButton(
                    heroTag: 'settingsFab',
                    mini: true,
                    onPressed: () {
                      setState(() => _fabExpanded = false);
                      Navigator.pushNamed(context, '/settings');
                    },
                    tooltip: 'Einstellungen',
                    child: const Icon(Icons.settings),
                  ),
                ),
              ],
              FloatingActionButton(
                heroTag: 'mainFab',
                onPressed: () {
                  setState(() {
                    _fabExpanded = !_fabExpanded;
                  });
                },
                tooltip: _fabExpanded ? 'Schließen' : 'Optionen anzeigen',
                child: Icon(_fabExpanded ? Icons.close : Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }
}
