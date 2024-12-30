// lib/widgets/edit_food_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/consumed_food_item.dart';
import '../models/app_state.dart';
import '../models/food_item.dart';

enum EditingMode { quantity, macros }

class EditFoodSheet extends StatelessWidget {
  final ConsumedFoodItem consumedFood;
  final VoidCallback onFoodEdited;
  final EditingMode mode;

  const EditFoodSheet({
    Key? key,
    required this.consumedFood,
    required this.onFoodEdited,
    required this.mode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                mode == EditingMode.quantity
                    ? Icons.edit_attributes
                    : Icons.edit,
                color: mode == EditingMode.quantity
                    ? Colors.green
                    : Colors.orange,
              ),
              title: Text(
                mode == EditingMode.quantity
                    ? 'Menge bearbeiten'
                    : 'Makronährstoffe bearbeiten',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                if (mode == EditingMode.quantity) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => EditConsumedFoodItemSheet(
                      consumedFood: consumedFood,
                      onFoodEdited: onFoodEdited,
                    ),
                  );
                } else {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => EditFoodDetailsSheet(
                      foodItem: consumedFood.food,
                      onFoodEdited: onFoodEdited,
                    ),
                  );
                }
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Lebensmittel löschen',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.pop(context);
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Lebensmittel löschen'),
                      content: Text(
                          'Möchten Sie das Lebensmittel wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.'),
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

                if (confirm != null && confirm) {
                  try {
                    await Provider.of<AppState>(context, listen: false)
                        .removeFood(consumedFood.mealName, consumedFood);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              '${consumedFood.food.name} wurde gelöscht.')),
                    );
                    onFoodEdited();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fehler beim Löschen: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EditConsumedFoodItemSheet extends StatefulWidget {
  final ConsumedFoodItem consumedFood;
  final VoidCallback onFoodEdited;

  const EditConsumedFoodItemSheet({
    Key? key,
    required this.consumedFood,
    required this.onFoodEdited,
  }) : super(key: key);

  @override
  _EditConsumedFoodItemSheetState createState() =>
      _EditConsumedFoodItemSheetState();
}

class _EditConsumedFoodItemSheetState
    extends State<EditConsumedFoodItemSheet> {
  late TextEditingController _gramController;
  String? selectedMeal;

  @override
  void initState() {
    super.initState();
    _gramController =
        TextEditingController(text: widget.consumedFood.quantity.toString());
    selectedMeal = widget.consumedFood.mealName;
  }

  @override
  void dispose() {
    _gramController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    int? newQuantity = int.tryParse(_gramController.text);
    if (newQuantity == null || newQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bitte gib eine gültige Menge ein.')),
      );
      return;
    }

    try {
      await Provider.of<AppState>(context, listen: false)
          .updateConsumedFoodItem(
        widget.consumedFood,
        newQuantity: newQuantity,
        newMealName: selectedMeal,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menge aktualisiert.')),
      );
      // Hier KEIN Navigator.pop mehr aufrufen, da onFoodEdited bereits ein Pop ausführen kann.
      widget.onFoodEdited();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Aktualisieren: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Menge bearbeiten',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _gramController,
                decoration: InputDecoration(
                  labelText: 'Menge in Gramm',
                  hintText: 'z.B. 150',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditFoodDetailsSheet extends StatefulWidget {
  final FoodItem foodItem;
  final VoidCallback onFoodEdited;

  const EditFoodDetailsSheet({
    Key? key,
    required this.foodItem,
    required this.onFoodEdited,
  }) : super(key: key);

  @override
  _EditFoodDetailsSheetState createState() => _EditFoodDetailsSheetState();
}

class _EditFoodDetailsSheetState extends State<EditFoodDetailsSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _caloriesController;
  late TextEditingController _carbsController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _sugarController;

  @override
  void initState() {
    super.initState();
    _caloriesController =
        TextEditingController(text: widget.foodItem.caloriesPer100g.toString());
    _carbsController =
        TextEditingController(text: widget.foodItem.carbsPer100g.toString());
    _proteinController =
        TextEditingController(text: widget.foodItem.proteinPer100g.toString());
    _fatController =
        TextEditingController(text: widget.foodItem.fatPer100g.toString());
    _sugarController =
        TextEditingController(text: widget.foodItem.sugarPer100g.toString());
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _carbsController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _sugarController.dispose();
    super.dispose();
  }

  Future<void> _saveFoodDetails() async {
    if (_formKey.currentState!.validate()) {
      int calories = int.parse(_caloriesController.text);
      double carbs = double.parse(_carbsController.text.replaceAll(',', '.'));
      double protein =
          double.parse(_proteinController.text.replaceAll(',', '.'));
      double fat = double.parse(_fatController.text.replaceAll(',', '.'));
      double sugar = double.parse(_sugarController.text.replaceAll(',', '.'));

      FoodItem updatedFood = widget.foodItem.copyWith(
        caloriesPer100g: calories,
        carbsPer100g: carbs,
        proteinPer100g: protein,
        fatPer100g: fat,
        sugarPer100g: sugar,
      );

      try {
        await Provider.of<AppState>(context, listen: false).editFood(updatedFood);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Makronährstoffe aktualisiert.')),
        );
        widget.onFoodEdited();
        Navigator.pop(context); // Schließt den EditFoodDetailsSheet
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Aktualisieren: $e')),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Makronährstoffe bearbeiten',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  controller: _carbsController,
                  decoration: InputDecoration(
                    labelText: 'Kohlenhydrate pro 100g (g)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
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
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
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
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
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
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Pflichtfeld' : null,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveFoodDetails,
                  child: Text('Speichern'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
