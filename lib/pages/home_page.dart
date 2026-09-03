import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/app_state.dart';
import '../models/food_item.dart';
import '../models/consumed_food_item.dart';
import '../widgets/add_food_sheet.dart';
import '../widgets/ai_food_sheet.dart';
import '../widgets/meal_section.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  final VoidCallback? onBackToHome;
  const MyHomePage({super.key, required this.title, this.onBackToHome});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _fabExpanded = false;
  bool _hasShownMondayPopup = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMondayPopupIfNeeded();
    });
  }

  double _calorieProgress(AppState state) =>
      state.consumedCalories / state.dailyCalorieGoal;
  double _carbProgress(AppState state) =>
      state.consumedCarbs / state.dailyCarbGoal;
  double _proteinProgress(AppState state) =>
      state.consumedProtein / state.dailyProteinGoal;
  double _fatProgress(AppState state) => state.consumedFat / state.dailyFatGoal;
  double _sugarProgress(AppState state) =>
      state.consumedSugar / state.dailySugarGoalGrams;
  void _scanBarcode(
    AppState state,
    String mealName,
  ) async {
    try {
      var result = await BarcodeScanner.scan();
      if (!mounted) return;
      if (result.type == ResultType.Barcode) {
        String barcode = result.rawContent.trim().toLowerCase();
        if (barcode.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Kein Barcode gefunden.')));
          return;
        }
        FoodItem? food = await state.loadFoodItemByBarcode(barcode);
        if (!mounted) return;
        if (food != null) {
          _showAddQuantityDialog(mealName, food);
        } else {
          FoodItem? offItem = await state.searchOpenFoodFactsByBarcode(barcode);
          if (!mounted) return;
          if (offItem != null) {
            _showAddQuantityDialog(mealName, offItem);
          } else {
            final similar = await state.searchOpenFoodFacts(barcode);
            if (!mounted) return;
            if (similar.isNotEmpty) {
              await _showSimilarBarcodeProducts(
                mealName,
                barcode,
                similar,
              );
              return;
            }
            await showDialog(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: Text('Lebensmittel nicht gefunden'),
                  content: Text(
                    'Der gescannte Barcode wurde weder in der eigenen noch in der Open Food Facts Datenbank gefunden. Möchtest du ein neues Lebensmittel erstellen oder den Barcode einem bestehenden Lebensmittel zuordnen?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _addNewFoodWithBarcode(
                          state,
                          mealName,
                          barcode,
                        );
                      },
                      child: Text('Neues Lebensmittel erstellen'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _assignBarcodeToExistingFood(
                          state,
                          mealName,
                          barcode,
                        );
                      },
                      child: Text('Barcode zuordnen'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: Text('Abbrechen'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Scannen des Barcodes: $e')),
      );
    }
  }

  Future<void> _showSimilarBarcodeProducts(
    String mealName,
    String barcode,
    List<FoodItem> products,
  ) async {
    await showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Aehnliche Produkte zu $barcode'),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final food = products[index];
                  return ListTile(
                    title: Text(food.name),
                    subtitle: Text(
                      '${food.brand} · ${food.caloriesPer100g} kcal',
                    ),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _showAddQuantityDialog(mealName, food);
                    },
                  );
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Trotzdem neu anlegen'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _addNewFoodWithBarcode(
                  Provider.of<AppState>(context, listen: false),
                  mealName,
                  barcode,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddQuantityDialog(
    String mealName,
    FoodItem foundFood,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AddQuantityDialog(
          food: foundFood,
          mealName: mealName,
          onFoodAdded: (ConsumedFoodItem consumedFood) {
            Navigator.popUntil(dialogContext, ModalRoute.withName('/'));
          },
        );
      },
    );
  }

  Future<void> _addNewFoodWithBarcode(
    AppState state,
    String mealName,
    String barcode,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) => AddNewFoodSheet(
        barcode: barcode,
        onFoodAdded: (ConsumedFoodItem consumedFood) {
          Navigator.pop(bottomSheetContext);
        },
      ),
    );
  }

  Future<void> _assignBarcodeToExistingFood(
    AppState state,
    String mealName,
    String barcode,
  ) async {
    List<FoodItem> existingFoods = await state.loadAllFoodItems();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Barcode einem bestehenden Lebensmittel zuordnen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: existingFoods.length,
                  itemBuilder: (itemContext, index) {
                    final food = existingFoods[index];
                    return ListTile(
                      title: Text(food.name),
                      subtitle: Text(
                        'Barcode: ${food.barcode ?? 'Nicht zugeordnet'}',
                      ),
                      trailing: food.barcode == null
                          ? IconButton(
                              icon: Icon(Icons.link, color: Colors.blue),
                              onPressed: () async {
                                FoodItem updatedFood = await state
                                    .updateBarcodeForFood(food, barcode);
                                if (!mounted) return;
                                await Provider.of<AppState>(
                                  context,
                                  listen: false,
                                ).addOrUpdateFood(
                                  mealName,
                                  updatedFood,
                                  100,
                                  state.currentDate,
                                );
                                if (bottomSheetContext.mounted) {
                                  Navigator.pop(bottomSheetContext);
                                }
                                if (!mounted) return;
                                Navigator.popUntil(
                                  context,
                                  ModalRoute.withName('/'),
                                );
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
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAddFoodOptions(
    AppState state,
    String mealName,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.search),
                title: Text('Lebensmittel suchen'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _searchFood(state, mealName);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Barcode scannen'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _scanBarcode(state, mealName);
                },
              ),
              ListTile(
                leading: Icon(Icons.restaurant_menu),
                title: Text('Gespeicherte Mahlzeit'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showSavedMeals(state, mealName);
                },
              ),
              ListTile(
                leading: Icon(Icons.auto_awesome, color: Color(0xFF64FFDA)),
                title: Text('KI Erkennung'),
                subtitle: Text('Foto, Text oder Sprache'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showAiFoodSheet(mealName);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _searchFood(AppState state, String mealName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return AddFoodSheet(
          onFoodAdded: (ConsumedFoodItem consumedFood) {
            Navigator.pop(sheetContext);
          },
          mealName: mealName,
          barcode: null,
        );
      },
    );
  }

  void _showAiFoodSheet(String mealName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return AiFoodSheet(mealName: mealName);
      },
    );
  }

  void _showSavedMeals(AppState state, String mealName) {
    state.loadSavedMeals();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Consumer<AppState>(
          builder: (consumerContext, appState, _) {
            final meals = appState.savedMeals;
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: SizedBox(
                  height: 420,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Gespeicherte Mahlzeiten',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(height: 1),
                      Expanded(
                        child: meals.isEmpty
                            ? Center(
                                child: Text(
                                  'Noch keine Mahlzeiten gespeichert.',
                                ),
                              )
                            : ListView.builder(
                                itemCount: meals.length,
                                itemBuilder: (itemContext, index) {
                                  final savedMeal = meals[index];
                                  return ListTile(
                                    leading: Icon(Icons.restaurant),
                                    title: Text(savedMeal.name),
                                    subtitle: Text(
                                      '${savedMeal.ingredients.length} Zutaten, '
                                      '${savedMeal.totalQuantity} g, '
                                      '${savedMeal.calories.toStringAsFixed(0)} kcal'
                                      '${savedMeal.isRecipe ? ', Rezept ${savedMeal.recipeTotalWeight} g' : ''}',
                                    ),
                                    trailing: Wrap(
                                      spacing: 4,
                                      children: [
                                        PopupMenuButton<double>(
                                          icon: Icon(Icons.scale),
                                          onSelected: (factor) async {
                                            await appState.addSavedMealToDay(
                                              savedMeal,
                                              mealName,
                                              factor: factor,
                                            );
                                            if (sheetContext.mounted) {
                                              Navigator.pop(sheetContext);
                                            }
                                          },
                                          itemBuilder: (itemCtx) =>
                                              [0.5, 1.0, 1.5, 2.0]
                                                  .map(
                                                    (factor) =>
                                                        PopupMenuItem<double>(
                                                      value: factor,
                                                      child: Text(
                                                        '${factor}x',
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                        if (savedMeal.isRecipe)
                                          IconButton(
                                            icon: Icon(Icons.restaurant_menu),
                                            onPressed: () async {
                                              final controller =
                                                  TextEditingController();
                                              final grams =
                                                  await showDialog<int>(
                                                context: context,
                                                builder: (dialogContext) =>
                                                    AlertDialog(
                                                  title: Text(
                                                    'Portion tracken',
                                                  ),
                                                  content: TextField(
                                                    controller: controller,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                      labelText: 'Portion',
                                                      suffixText: 'g',
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                        dialogContext,
                                                      ),
                                                      child: Text(
                                                        'Abbrechen',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                        dialogContext,
                                                        int.tryParse(
                                                          controller.text,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Hinzufuegen',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              controller.dispose();
                                              if (grams == null || grams <= 0) {
                                                return;
                                              }
                                              await appState
                                                  .addRecipePortionToDay(
                                                savedMeal,
                                                mealName,
                                                grams,
                                              );
                                              if (sheetContext.mounted) {
                                                Navigator.pop(sheetContext);
                                              }
                                            },
                                          ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline),
                                          onPressed: savedMeal.id == null
                                              ? null
                                              : () => appState.deleteSavedMeal(
                                                    savedMeal.id!,
                                                  ),
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      await appState.addSavedMealToDay(
                                        savedMeal,
                                        mealName,
                                      );
                                      if (sheetContext.mounted) {
                                        Navigator.pop(sheetContext);
                                      }
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${savedMeal.name} hinzugefügt.',
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveMealTemplate(
    AppState state,
    String mealName,
    List<ConsumedFoodItem> foods,
  ) async {
    String templateName = '';
    String recipeWeightText = '';
    final result = await showDialog<({String name, int? recipeWeight})>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$mealName als Mahlzeit / Rezept speichern'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                onChanged: (value) => templateName = value,
                decoration: InputDecoration(labelText: 'Name'),
                autofocus: true,
              ),
              SizedBox(height: 12),
              TextFormField(
                onChanged: (value) => recipeWeightText = value,
                decoration: InputDecoration(
                  labelText: 'Gesamtgewicht Rezept/Meal Prep (optional)',
                  suffixText: 'g',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, (
                  name: templateName.trim(),
                  recipeWeight: int.tryParse(recipeWeightText),
                ));
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
    final name = result?.name;
    if (name == null || name.isEmpty) {
      return;
    }
    try {
      await state.saveMealTemplate(name, mealName, foods, result?.recipeWeight);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$name gespeichert.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler beim Speichern: $e')));
    }
  }

  Future<void> _copyMealFromYesterday(
    AppState state,
    String mealName,
  ) async {
    final snapshot = state.getCurrentDaySnapshot();
    try {
      final copiedCount = await state.copyMealFromYesterday(mealName);
      if (!mounted) return;
      final message = copiedCount == 0
          ? 'Gestern wurden keine Einträge für $mealName gefunden.'
          : '$mealName von gestern übernommen.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: copiedCount == 0
              ? null
              : SnackBarAction(
                  label: 'Undo',
                  onPressed: () => state.restoreCurrentDaySnapshot(snapshot),
                ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Übernehmen von gestern: $e')),
      );
    }
  }

  Future<void> _showMealQr(
    AppState state,
    String mealName,
  ) async {
    final payload = state.buildMealSharePayload(mealName);
    final decoded = jsonDecode(payload) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$mealName enthält keine teilbaren Einträge.')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$mealName teilen'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: payload,
                version: QrVersions.auto,
                size: 240,
                backgroundColor: Colors.white,
              ),
              SizedBox(height: 12),
              Text(
                '${items.length} Einträge. Auf dem anderen Gerät QR importieren.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Schließen'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanMealQr(
    AppState state,
    String mealName,
  ) async {
    try {
      final result = await BarcodeScanner.scan();
      if (!mounted || result.rawContent.trim().isEmpty) return;
      final count = await state.importMealSharePayload(
        result.rawContent,
        mealName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count Einträge in $mealName importiert.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('QR-Import fehlgeschlagen: $e')));
    }
  }

  Future<void> _copyDayFromYesterday(
    AppState state,
  ) async {
    final snapshot = state.getCurrentDaySnapshot();
    try {
      final copiedCount = await state.copyDayFromYesterday();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copiedCount == 0
                ? 'Gestern wurden keine Eintraege gefunden.'
                : 'Kompletter Tag von gestern uebernommen.',
          ),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => state.restoreCurrentDaySnapshot(snapshot),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler beim Kopieren: $e')));
    }
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
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _showMondayPopupIfNeeded() {
    final state = Provider.of<AppState>(context, listen: false);
    if (!_hasShownMondayPopup &&
        state.mondayPopupMessage != null &&
        state.mondayPopupMessage!.isNotEmpty) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(state.mondayPopupMessage!),
          leading: Icon(Icons.info_outline),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: Text('Ok'),
            ),
          ],
        ),
      );
      _hasShownMondayPopup = true;
      state.mondayPopupMessage = null;
    }
  }

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
            leading: widget.onBackToHome != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Zurück zur Hauptseite',
                    onPressed: widget.onBackToHome,
                  )
                : null,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Vorheriger Tag',
                  onPressed: () => _goToPreviousDay(state),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formattedDate,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Nächster Tag',
                  onPressed: () => _goToNextDay(state),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            centerTitle: true,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
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
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
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
                          SizedBox(width: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\nGrundziel:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${state.dailyCalorieGoal.toStringAsFixed(0)} kcal',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gegessen:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${state.consumedCalories.toStringAsFixed(0)} kcal',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kohlenhydrate (g)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Zucker (g)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Proteine (g)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fette (g)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MealSection(
                          mealName: 'Frühstück',
                          foods: state.breakfast,
                          onAdd: () {
                            _showAddFoodOptions(state, 'Frühstück');
                          },
                          onCopyYesterday: () =>
                              _copyMealFromYesterday(state, 'Frühstück'),
                          onImportQr: () => _scanMealQr(
                            state,
                            'Frühstück',
                          ),
                          onShareQr: state.breakfast.isEmpty
                              ? null
                              : () => _showMealQr(state, 'Frühstück'),
                          onSaveMeal: state.breakfast.isEmpty
                              ? null
                              : () => _saveMealTemplate(
                                    state,
                                    'Frühstück',
                                    state.breakfast,
                                  ),
                        ),
                        SizedBox(height: 8),
                        MealSection(
                          mealName: 'Mittagessen',
                          foods: state.lunch,
                          onAdd: () {
                            _showAddFoodOptions(state, 'Mittagessen');
                          },
                          onCopyYesterday: () =>
                              _copyMealFromYesterday(state, 'Mittagessen'),
                          onImportQr: () => _scanMealQr(
                            state,
                            'Mittagessen',
                          ),
                          onShareQr: state.lunch.isEmpty
                              ? null
                              : () => _showMealQr(state, 'Mittagessen'),
                          onSaveMeal: state.lunch.isEmpty
                              ? null
                              : () => _saveMealTemplate(
                                    state,
                                    'Mittagessen',
                                    state.lunch,
                                  ),
                        ),
                        SizedBox(height: 8),
                        MealSection(
                          mealName: 'Abendessen',
                          foods: state.dinner,
                          onAdd: () {
                            _showAddFoodOptions(state, 'Abendessen');
                          },
                          onCopyYesterday: () =>
                              _copyMealFromYesterday(state, 'Abendessen'),
                          onImportQr: () => _scanMealQr(
                            state,
                            'Abendessen',
                          ),
                          onShareQr: state.dinner.isEmpty
                              ? null
                              : () => _showMealQr(state, 'Abendessen'),
                          onSaveMeal: state.dinner.isEmpty
                              ? null
                              : () => _saveMealTemplate(
                                    state,
                                    'Abendessen',
                                    state.dinner,
                                  ),
                        ),
                        SizedBox(height: 8),
                        MealSection(
                          mealName: 'Snacks',
                          foods: state.snacks,
                          onAdd: () {
                            _showAddFoodOptions(state, 'Snacks');
                          },
                          onCopyYesterday: () =>
                              _copyMealFromYesterday(state, 'Snacks'),
                          onImportQr: () => _scanMealQr(state, 'Snacks'),
                          onShareQr: state.snacks.isEmpty
                              ? null
                              : () => _showMealQr(state, 'Snacks'),
                          onSaveMeal: state.snacks.isEmpty
                              ? null
                              : () => _saveMealTemplate(
                                    state,
                                    'Snacks',
                                    state.snacks,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 8,
                child: _buildFabMenu(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFabMenu(BuildContext context, AppState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: _fabExpanded ? 380.0 : 0.0,
          curve: Curves.fastOutSlowIn,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildMiniFab(
                  visible: _fabExpanded,
                  heroTag: 'yesterdayFab',
                  tooltip: 'Gestern übernehmen',
                  icon: Icons.restore,
                  onPressed: () {
                    setState(() => _fabExpanded = false);
                    _copyDayFromYesterday(state);
                  },
                ),
                _buildMiniFab(
                  visible: _fabExpanded,
                  heroTag: 'dashboardFab',
                  tooltip: 'Wochen-Dashboard',
                  icon: Icons.analytics,
                  onPressed: () {
                    setState(() => _fabExpanded = false);
                    Navigator.pushNamed(context, '/weekly_dashboard');
                  },
                ),
                _buildMiniFab(
                  visible: _fabExpanded,
                  heroTag: 'weightFab',
                  tooltip: 'Gewicht tracken',
                  icon: Icons.monitor_weight,
                  onPressed: () {
                    setState(() => _fabExpanded = false);
                    Navigator.pushNamed(context, '/weight');
                  },
                ),
                _buildMiniFab(
                  visible: _fabExpanded,
                  heroTag: 'healthFab',
                  tooltip: 'Health & Aktivität',
                  icon: Icons.favorite,
                  onPressed: () {
                    setState(() => _fabExpanded = false);
                    Navigator.pushNamed(context, '/health');
                  },
                ),
                _buildMiniFab(
                  visible: _fabExpanded,
                  heroTag: 'cycleFab',
                  tooltip: 'Zyklus & Wohlbefinden',
                  icon: Icons.water_drop,
                  onPressed: () {
                    setState(() => _fabExpanded = false);
                    Navigator.pushNamed(context, '/cycle');
                  },
                ),
                _buildMiniFab(
                  visible: _fabExpanded,
                  heroTag: 'backupFab',
                  tooltip: 'Backup & Wiederherstellung',
                  icon: Icons.backup,
                  onPressed: () {
                    setState(() => _fabExpanded = false);
                    Navigator.pushNamed(context, '/backup');
                  },
                ),
                _buildMiniFab(
                  visible: _fabExpanded,
                  heroTag: 'settingsFab',
                  tooltip: 'Einstellungen',
                  icon: Icons.settings,
                  onPressed: () {
                    setState(() => _fabExpanded = false);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: _fabExpanded ? 20.0 : 0.0,
          curve: Curves.fastOutSlowIn,
        ),
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
    );
  }

  Widget _buildMiniFab({
    required bool visible,
    required String heroTag,
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: AnimatedScale(
          scale: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FloatingActionButton(
              heroTag: heroTag,
              mini: true,
              onPressed: onPressed,
              tooltip: tooltip,
              child: Icon(icon),
            ),
          ),
        ),
      ),
    );
  }
}
