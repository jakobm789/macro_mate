// lib/widgets/add_food_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/food_item.dart';
import '../models/consumed_food_item.dart';
import '../services/database_helper.dart';
import 'edit_food_sheet.dart';

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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _searchFoods(_searchController.text);
  }

  Future<void> _searchFoods(String query) async {
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<FoodItem> results = await DatabaseHelper().searchFoodItems(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
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

  // Entferntes Navigator.pop nach onFoodAdded in _addNewFood()
  void _addNewFood() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddNewFoodSheet(
        onFoodAdded: (ConsumedFoodItem consumedFood) {
          // Nach dem Hinzufügen navigiere zum Home-Screen
          Navigator.pop(context); // Schließt das AddNewFoodSheet
          Navigator.popUntil(context, ModalRoute.withName('/'));
        },
        barcode: widget.barcode,
      ),
    );
  }

  // Entferntes Navigator.pop nach onFoodAdded in _showAddQuantityDialog()
  void _showAddQuantityDialog(FoodItem food) {
    showDialog(
      context: context,
      builder: (context) {
        return AddQuantityDialog(
          food: food,
          mealName: widget.mealName,
          onFoodAdded: (ConsumedFoodItem consumedFood) {
            // Nach dem Hinzufügen navigiere zum Home-Screen
            Navigator.pop(context); // Schließt den Dialog
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        );
      },
    );
  }

  // Entferntes Navigator.pop nach onFoodAdded in _addNewFoodWithBarcode()
  Future<void> _addNewFoodWithBarcode(BuildContext context, String barcode) async {
    FoodItem? existingFood = await DatabaseHelper().getFoodItemByBarcode(barcode);
    if (existingFood != null) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Barcode bereits vorhanden'),
          content: Text('Der Barcode gehört bereits zu ${existingFood.name}. Möchtest du den Barcode überschreiben?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                _assignBarcodeToExistingFood(barcode);
              },
              child: Text('Überschreiben'),
            ),
          ],
        ),
      ).then((overwrite) {
        if (overwrite == true) {
          _assignBarcodeToExistingFood(barcode);
        }
      });
    } else {
      // Direktes Öffnen des AddNewFoodSheet ohne die Suchoberfläche
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => AddNewFoodSheet(
          barcode: barcode,
          onFoodAdded: (ConsumedFoodItem consumedFood) {
            // Nach dem Hinzufügen navigiere zum Home-Screen
            Navigator.pop(context); // Schließt das AddNewFoodSheet
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
      );
    }
  }

  Future<void> _assignBarcodeToExistingFood(String barcode) async {
    List<FoodItem> existingFoods = await DatabaseHelper().getAllFoodItems();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      subtitle: Text('Barcode: ${food.barcode ?? 'Nicht zugeordnet'}'),
                      trailing: food.barcode == null
                          ? IconButton(
                              icon: Icon(Icons.link, color: Colors.blue),
                              onPressed: () async {
                                FoodItem updatedFood = food.copyWith(barcode: barcode);
                                await DatabaseHelper().updateFoodItem(updatedFood);
                                await Provider.of<AppState>(context, listen: false)
                                    .addOrUpdateFood(
                                        widget.mealName, updatedFood, 100, Provider.of<AppState>(context, listen: false).currentDate);
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

  Future<void> _deleteFoodItemFromDB(BuildContext context, FoodItem food) async {
    final appState = Provider.of<AppState>(context, listen: false);
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Lebensmittel löschen'),
          content: Text('Möchtest du ${food.name} wirklich löschen? Das entfernt das Lebensmittel vollständig aus der Datenbank.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Löschen'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await appState.deleteFood(food);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${food.name} wurde gelöscht.')),
        );
        // Nach dem Löschen evtl. Suche aktualisieren:
        _searchFoods(_searchController.text);
        // Navigiere zum Home-Screen
        Navigator.popUntil(context, ModalRoute.withName('/'));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen: $e')),
        );
      }
    }
  }

  void _editMacros(BuildContext context, FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditFoodDetailsSheet(
        foodItem: food,
        onFoodEdited: () {
          Navigator.pop(context); // Schließt Makrobearbeitung
          _searchFoods(_searchController.text);
          // Navigiere zum Home-Screen
          Navigator.popUntil(context, ModalRoute.withName('/'));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final last20 = appState.last20FoodItems;

    // Wenn ein Barcode vorhanden ist, zeige direkt das AddNewFoodSheet
    if (widget.barcode != null && widget.barcode!.isNotEmpty) {
      // Direktes Öffnen des AddNewFoodSheet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Verzögertes Aufrufen, um den Build-Prozess nicht zu stören
        _addNewFoodWithBarcode(context, widget.barcode!);
      });
      // Rückgabe eines leeren Containers, da das AddNewFoodSheet bereits geöffnet wird
      return Container();
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                    subtitle: Text('${food.caloriesPer100g} kcal, ${food.carbsPer100g}g KH, ${food.proteinPer100g}g Protein, ${food.fatPer100g}g Fett'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _editMacros(context, food);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteFoodItemFromDB(context, food);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      _showAddQuantityDialog(food);
                    },
                  );
                },
              ),
            _isLoading
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )
                : _searchResults.isNotEmpty
                    ? Container(
                        height: 300,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            FoodItem food = _searchResults[index];
                            return ListTile(
                              key: ValueKey(food.id),
                              title: Text(food.name),
                              subtitle: Text('${food.caloriesPer100g} kcal, ${food.carbsPer100g}g KH, ${food.proteinPer100g}g Protein, ${food.fatPer100g}g Fett'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      _editMacros(context, food);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _deleteFoodItemFromDB(context, food);
                                    },
                                  ),
                                ],
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
                              if (widget.barcode != null && widget.barcode!.isNotEmpty) {
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  void initState() {
    super.initState();
    _gramController = TextEditingController(text: widget.food.lastUsedQuantity.toString());
  }

  @override
  void dispose() {
    _gramController.dispose();
    super.dispose();
  }

  Future<void> _addFood() async {
    final gramsText = _gramController.text;
    final grams = int.tryParse(gramsText) ?? widget.food.lastUsedQuantity;

    ConsumedFoodItem consumedFood = ConsumedFoodItem(
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
          .addOrUpdateFood(widget.mealName, widget.food, consumedFood.quantity, consumedFood.date);

      setState(() {
        _isLoading = false;
      });

      // Nur onFoodAdded aufrufen, kein zusätzliches Navigator.pop
      widget.onFoodAdded(consumedFood);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${consumedFood.food.name} hinzugefügt.')),
      );

      // Navigiere zum Home-Screen
      Navigator.popUntil(context, ModalRoute.withName('/'));

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Hinzufügen des Lebensmittels: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentMeal = widget.mealName;

    return AlertDialog(
      title: Text('Menge hinzufügen für $currentMeal'),
      content: SingleChildScrollView(
        child: TextField(
          controller: _gramController,
          decoration: InputDecoration(labelText: 'Menge in Gramm'),
          keyboardType: TextInputType.number,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Abbrechen'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _addFood,
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Hinzufügen'),
        ),
      ],
    );
  }
}

class AddNewFoodSheet extends StatefulWidget {
  final Function(ConsumedFoodItem) onFoodAdded;
  final String? barcode;

  const AddNewFoodSheet({Key? key, required this.onFoodAdded, this.barcode}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    if (widget.barcode != null) {
      _barcodeController.text = widget.barcode!.toLowerCase();
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text.trim();
      String brand = _brandController.text.trim();
      String? barcode = _barcodeController.text.trim().isNotEmpty ? _barcodeController.text.trim().toLowerCase() : null;
      int caloriesPer100g = int.parse(_caloriesController.text);
      double fatPer100g = double.parse(_fatController.text.replaceAll(',', '.'));
      double carbsPer100g = double.parse(_carbsController.text.replaceAll(',', '.'));
      double sugarPer100g = double.parse(_sugarController.text.replaceAll(',', '.'));
      double proteinPer100g = double.parse(_proteinController.text.replaceAll(',', '.'));
      int quantity = int.parse(_gramController.text);

      FoodItem newFood = FoodItem(
        name: name,
        brand: brand,
        barcode: barcode,
        caloriesPer100g: caloriesPer100g,
        fatPer100g: fatPer100g,
        carbsPer100g: carbsPer100g,
        sugarPer100g: sugarPer100g,
        proteinPer100g: proteinPer100g,
        createdAt: DateTime.now(),
      );

      ConsumedFoodItem consumedFood = ConsumedFoodItem(
        food: newFood,
        quantity: quantity,
        date: Provider.of<AppState>(context, listen: false).currentDate,
        mealName: selectedMeal,
      );

      try {
        await Provider.of<AppState>(context, listen: false)
            .addOrUpdateFood(selectedMeal, newFood, consumedFood.quantity, consumedFood.date);

        if (!mounted) return;
        // Nur onFoodAdded aufrufen, kein zusätzliches Navigator.pop
        widget.onFoodAdded(consumedFood);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${consumedFood.food.name} hinzugefügt.')),
        );

        // Navigiere zum Home-Screen
        Navigator.popUntil(context, ModalRoute.withName('/'));

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Hinzufügen des Lebensmittels: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
        EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Form(
            key: _formKey,
            child: Column(
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
                    value == null || value.isEmpty ? 'Pflichtfeld' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _brandController,
                  decoration: InputDecoration(
                    labelText: 'Marke',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                    value == null || value.isEmpty ? 'Pflichtfeld' : null,
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
                    value == null || value.isEmpty ? 'Pflichtfeld' : null,
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
                    value == null || value.isEmpty ? 'Pflichtfeld' : null,
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
                    value == null || value.isEmpty ? 'Pflichtfeld' : null,
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
                    value == null || value.isEmpty ? 'Pflichtfeld' : null,
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
                    value == null || value.isEmpty ? 'Pflichtfeld' : null,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('Hinzufügen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
