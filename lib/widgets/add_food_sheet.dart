import 'dart:async'; // <-- NEU für Timer (Debounce)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/food_item.dart';
import '../models/consumed_food_item.dart';

class AddFoodSheet extends StatefulWidget {
  final Function(ConsumedFoodItem) onFoodAdded;
  final String mealName;
  final String? barcode; // Neuer Barcode-Parameter

  const AddFoodSheet({
    Key? key,
    required this.onFoodAdded,
    required this.mealName,
    this.barcode,
  }) : super(key: key);

  @override
  _AddFoodSheetState createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<AddFoodSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _isLoading = false;

  // Ergebnisse von Open Food Facts (zusätzlich zur Remote-Suche)
  List<FoodItem> _offResults = [];

  // NEU: Debounce-Timer
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  // NEU: Debounce-Mechanismus – 2 Sekunden warten, bis zuletzt getippt wurde,
  // bevor die Suche gestartet wird.
  void _onSearchChanged() {
    // Falls schon ein Timer läuft, abbrechen
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // Nach 2 Sekunden Inaktivität erst suchen
    _debounce = Timer(const Duration(seconds: 1), () {
      _searchFoods(_searchController.text);
    });
  }

  @override
  void dispose() {
    // Debounce-Timer aufräumen
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchFoods(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _offResults = [];
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final appState = Provider.of<AppState>(context, listen: false);

      // 1) Suche in unserer eigenen (Remote) DB
      List<FoodItem> results = await appState.searchFoodItemsRemote(query);

      // 2) Zusätzlich in Open Food Facts suchen
      List<FoodItem> offResults = await appState.searchOpenFoodFacts(query);

      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _offResults = offResults;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler bei der Suche: $e')),
      );
    }
  }

  void _addNewFood() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddNewFoodSheet(
        onFoodAdded: (ConsumedFoodItem consumedFood) {
          Navigator.pop(context); // Schließt das AddNewFoodSheet
          Navigator.popUntil(context, ModalRoute.withName('/'));
        },
        barcode: widget.barcode,
      ),
    );
  }

  void _showAddQuantityDialog(FoodItem food) {
    showDialog(
      context: context,
      builder: (context) {
        return AddQuantityDialog(
          food: food,
          mealName: widget.mealName,
          onFoodAdded: (ConsumedFoodItem consumedFood) {
            Navigator.pop(context);
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final last20 = appState.last20FoodItems;

    // Wenn ein Barcode vorhanden ist, direktes Öffnen
    if (widget.barcode != null && widget.barcode!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addNewFoodWithBarcode(context, widget.barcode!);
      });
      return Container();
    }

    // Kombiniere _searchResults + _offResults in einer Liste
    final combinedList = [
      ..._searchResults,
      ..._offResults.where(
        (offItem) => !_searchResults.any(
          (r) =>
              (r.barcode ?? '').isNotEmpty &&
              r.barcode?.toLowerCase() == offItem.barcode?.toLowerCase(),
        ),
      ),
    ];

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Suchfeld
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Lebensmittel suchen',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            // Zuletzt hinzugefügt
            if (_searchController.text.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Zuletzt hinzugefügte Lebensmittel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (_searchController.text.isEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: last20.length,
                itemBuilder: (context, index) {
                  final food = last20[index];
                  return ListTile(
                    key: ValueKey(food.id),
                    title: Text(food.name),
                    subtitle: Text(
                      '${food.caloriesPer100g} kcal, '
                      '${food.carbsPer100g}g KH, '
                      '${food.proteinPer100g}g Protein, '
                      '${food.fatPer100g}g Fett',
                    ),
                    onTap: () {
                      _showAddQuantityDialog(food);
                    },
                  );
                },
              ),
            // Suchergebnisse
            _isLoading
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )
                : combinedList.isNotEmpty
                    ? Container(
                        height: 300,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: combinedList.length,
                          itemBuilder: (context, index) {
                            FoodItem food = combinedList[index];
                            return ListTile(
                              key: ValueKey('${food.barcode}-${food.name}'),
                              title: Text(food.name),
                              subtitle: Text(
                                '${food.caloriesPer100g} kcal, '
                                '${food.carbsPer100g}g KH, '
                                '${food.proteinPer100g}g Protein, '
                                '${food.fatPer100g}g Fett',
                              ),
                              onTap: () {
                                _showAddQuantityDialog(food);
                              },
                            );
                          },
                        ),
                      )
                    : _searchController.text.isEmpty
                        ? Container()
                        : ListTile(
                            leading: Icon(Icons.add),
                            title: Text('Neues Lebensmittel hinzufügen'),
                            onTap: () {
                              Navigator.pop(context);
                              if (widget.barcode != null &&
                                  widget.barcode!.isNotEmpty) {
                                _addNewFoodWithBarcode(context, widget.barcode!);
                              } else {
                                _addNewFood();
                              }
                            },
                          ),
          ],
        ),
      ),
    );
  }

  Future<void> _addNewFoodWithBarcode(BuildContext context, String barcode) async {
    final appState = Provider.of<AppState>(context, listen: false);
    FoodItem? existingFood = await appState.loadFoodItemByBarcode(barcode);

    if (existingFood != null) {
      // Barcode bereits verknüpft => ggf. überschreiben
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Barcode bereits vorhanden'),
          content: Text(
            'Der Barcode gehört bereits zu ${existingFood.name}. '
            'Möchtest du den Barcode überschreiben?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Überschreiben'),
            ),
          ],
        ),
      ).then((overwrite) async {
        if (overwrite == true) {
          await appState.updateBarcodeForFood(existingFood, barcode);
          // Menge hinzufügen
          await appState.addOrUpdateFood(
            widget.mealName,
            existingFood,
            100,
            appState.currentDate,
          );
          Navigator.popUntil(context, ModalRoute.withName('/'));
        }
      });
    } else {
      // Direktes Öffnen des AddNewFoodSheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => AddNewFoodSheet(
          barcode: barcode,
          onFoodAdded: (ConsumedFoodItem consumedFood) {
            Navigator.pop(context); // Schließt
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
      );
    }
  }
}

class AddQuantityDialog extends StatefulWidget {
  final FoodItem food;
  final String mealName;
  final Function(ConsumedFoodItem) onFoodAdded;

  const AddQuantityDialog({
    Key? key,
    required this.food,
    required this.mealName,
    required this.onFoodAdded,
  }) : super(key: key);

  @override
  _AddQuantityDialogState createState() => _AddQuantityDialogState();
}

class _AddQuantityDialogState extends State<AddQuantityDialog> {
  late TextEditingController _gramController;
  bool _isLoading = false;

  double _partialCalories = 0.0;
  double _partialCarbs = 0.0;
  double _partialProtein = 0.0;
  double _partialFat = 0.0;
  double _partialSugar = 0.0;

  @override
  void initState() {
    super.initState();
    _gramController =
        TextEditingController(text: widget.food.lastUsedQuantity.toString());

    _gramController.addListener(_updateMacros);
    _updateMacros();
  }

  void _updateMacros() {
    final grams = int.tryParse(_gramController.text) ?? 0;
    setState(() {
      _partialCalories = (widget.food.caloriesPer100g * grams) / 100.0;
      _partialCarbs = (widget.food.carbsPer100g * grams) / 100.0;
      _partialProtein = (widget.food.proteinPer100g * grams) / 100.0;
      _partialFat = (widget.food.fatPer100g * grams) / 100.0;
      _partialSugar = (widget.food.sugarPer100g * grams) / 100.0;
    });
  }

  Future<void> _addFood() async {
    final gramsText = _gramController.text;
    final grams = int.tryParse(gramsText) ?? widget.food.lastUsedQuantity;

    final consumedFood = ConsumedFoodItem(
      food: widget.food,
      quantity: grams,
      date: Provider.of<AppState>(context, listen: false).currentDate,
      mealName: widget.mealName,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AppState>(context, listen: false)
          .addOrUpdateFood(widget.mealName, widget.food, grams, consumedFood.date);

      setState(() {
        _isLoading = false;
      });

      widget.onFoodAdded(consumedFood);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${consumedFood.food.name} hinzugefügt.')),
      );

      Navigator.popUntil(context, ModalRoute.withName('/'));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Hinzufügen: $e')),
      );
    }
  }

  @override
  void dispose() {
    _gramController.removeListener(_updateMacros);
    _gramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Menge hinzufügen für ${widget.mealName}'),
      content: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _gramController,
                decoration: const InputDecoration(
                  labelText: 'Menge in Gramm',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Container(
                // Keine Card mehr bzw. kein Hintergrund
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktuelle Menge: ${_gramController.text} g',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Kalorien: ${_partialCalories.toStringAsFixed(1)} kcal'),
                      Text('Kohlenhydrate: ${_partialCarbs.toStringAsFixed(1)} g'),
                      Text('Proteine: ${_partialProtein.toStringAsFixed(1)} g'),
                      Text('Fette: ${_partialFat.toStringAsFixed(1)} g'),
                      Text('Zucker: ${_partialSugar.toStringAsFixed(1)} g'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _addFood,
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Hinzufügen'),
        ),
      ],
    );
  }
}

class AddNewFoodSheet extends StatefulWidget {
  final Function(ConsumedFoodItem) onFoodAdded;
  final String? barcode;

  const AddNewFoodSheet({Key? key, required this.onFoodAdded, this.barcode})
      : super(key: key);

  @override
  _AddNewFoodSheetState createState() => _AddNewFoodSheetState();
}

class _AddNewFoodSheetState extends State<AddNewFoodSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _gramController = TextEditingController(text: '100');
  final TextEditingController _barcodeController = TextEditingController();
  String selectedMeal = 'Frühstück';

  double _partialCalories = 0.0;
  double _partialCarbs = 0.0;
  double _partialProtein = 0.0;
  double _partialFat = 0.0;
  double _partialSugar = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.barcode != null) {
      _barcodeController.text = widget.barcode!.toLowerCase();
    }
    _gramController.addListener(_updateMacros);
  }

  @override
  void dispose() {
    _gramController.removeListener(_updateMacros);
    _nameController.dispose();
    _brandController.dispose();
    _caloriesController.dispose();
    _carbsController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _sugarController.dispose();
    _gramController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _updateMacros() {
    final grams = int.tryParse(_gramController.text) ?? 0;
    final calPer100 = int.tryParse(_caloriesController.text) ?? 0;
    final carbsPer100 =
        double.tryParse(_carbsController.text.replaceAll(',', '.')) ?? 0.0;
    final proteinPer100 =
        double.tryParse(_proteinController.text.replaceAll(',', '.')) ?? 0.0;
    final fatPer100 =
        double.tryParse(_fatController.text.replaceAll(',', '.')) ?? 0.0;
    final sugarPer100 =
        double.tryParse(_sugarController.text.replaceAll(',', '.')) ?? 0.0;

    setState(() {
      _partialCalories = (calPer100 * grams) / 100.0;
      _partialCarbs = (carbsPer100 * grams) / 100.0;
      _partialProtein = (proteinPer100 * grams) / 100.0;
      _partialFat = (fatPer100 * grams) / 100.0;
      _partialSugar = (sugarPer100 * grams) / 100.0;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final brand = _brandController.text.trim();
      final barcodeValue = _barcodeController.text.trim().isNotEmpty
          ? _barcodeController.text.trim().toLowerCase()
          : null;
      final caloriesPer100g = int.parse(_caloriesController.text);
      final fatPer100g =
          double.parse(_fatController.text.replaceAll(',', '.'));
      final carbsPer100g =
          double.parse(_carbsController.text.replaceAll(',', '.'));
      final sugarPer100g =
          double.parse(_sugarController.text.replaceAll(',', '.'));
      final proteinPer100g =
          double.parse(_proteinController.text.replaceAll(',', '.'));
      final quantity = int.parse(_gramController.text);

      final newFood = FoodItem(
        name: name,
        brand: brand,
        barcode: barcodeValue,
        caloriesPer100g: caloriesPer100g,
        fatPer100g: fatPer100g,
        carbsPer100g: carbsPer100g,
        sugarPer100g: sugarPer100g,
        proteinPer100g: proteinPer100g,
      );

      final consumedFood = ConsumedFoodItem(
        food: newFood,
        quantity: quantity,
        date: Provider.of<AppState>(context, listen: false).currentDate,
        mealName: selectedMeal,
      );

      try {
        await Provider.of<AppState>(context, listen: false).addOrUpdateFood(
          selectedMeal,
          newFood,
          consumedFood.quantity,
          consumedFood.date,
        );

        if (!mounted) return;
        widget.onFoodAdded(consumedFood);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${consumedFood.food.name} hinzugefügt.')),
        );

        Navigator.popUntil(context, ModalRoute.withName('/'));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Hinzufügen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity, 
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Neues Lebensmittel hinzufügen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMeal,
                  decoration: InputDecoration(
                    labelText: 'Mahlzeit',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Frühstück', 'Mittagessen', 'Abendessen', 'Snacks']
                      .map((meal) => DropdownMenuItem<String>(
                            value: meal,
                            child: Text(meal),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedMeal = value;
                      });
                    }
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Pflichtfeld' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _brandController,
                  decoration: InputDecoration(
                    labelText: 'Marke',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Pflichtfeld' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    labelText: 'Barcode (optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _caloriesController,
                  decoration: InputDecoration(
                    labelText: 'Kalorien pro 100g',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Pflichtfeld' : null,
                  onChanged: (_) => _updateMacros(),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _fatController,
                  decoration: InputDecoration(
                    labelText: 'Fette pro 100g (g)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Pflichtfeld' : null,
                  onChanged: (_) => _updateMacros(),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _carbsController,
                  decoration: InputDecoration(
                    labelText: 'Kohlenhydrate pro 100g (g)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Pflichtfeld' : null,
                  onChanged: (_) => _updateMacros(),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _sugarController,
                  decoration: InputDecoration(
                    labelText: 'Zucker pro 100g (g)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Pflichtfeld' : null,
                  onChanged: (_) => _updateMacros(),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _proteinController,
                  decoration: InputDecoration(
                    labelText: 'Proteine pro 100g (g)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Pflichtfeld' : null,
                  onChanged: (_) => _updateMacros(),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _gramController,
                  decoration: InputDecoration(
                    labelText: 'Menge (g)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Pflichtfeld' : null,
                ),
                SizedBox(height: 16),
                // Hintergrund entfernt (transparent), nur Schrift
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktuelle Menge: ${_gramController.text} g',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Kalorien: ${_partialCalories.toStringAsFixed(1)} kcal'),
                      Text('Kohlenhydrate: ${_partialCarbs.toStringAsFixed(1)} g'),
                      Text('Proteine: ${_partialProtein.toStringAsFixed(1)} g'),
                      Text('Fette: ${_partialFat.toStringAsFixed(1)} g'),
                      Text('Zucker: ${_partialSugar.toStringAsFixed(1)} g'),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Hinzufügen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
