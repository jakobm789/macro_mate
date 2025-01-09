// ./macro_mate/lib/widgets/edit_food_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/food_item.dart';
import '../models/consumed_food_item.dart';

/// Modus, um zwischen Mengen-Bearbeitung und Makro-Bearbeitung zu unterscheiden
enum EditingMode { quantity, macros }

/// Popup-Sheet, um entweder die Menge eines bereits hinzugefügten Lebensmittels
/// zu bearbeiten oder dessen Makros (FoodItem).
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
          right: 20,
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                mode == EditingMode.quantity ? Icons.edit_attributes : Icons.edit,
                color: mode == EditingMode.quantity ? Colors.green : Colors.orange,
              ),
              title: Text(
                mode == EditingMode.quantity
                    ? 'Menge bearbeiten'
                    : 'Makronährstoffe bearbeiten',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                if (mode == EditingMode.quantity) {
                  // Menge bearbeiten => öffnet Sheet
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => EditConsumedFoodItemSheet(
                      consumedFood: consumedFood,
                      onFoodEdited: onFoodEdited,
                    ),
                  );
                } else {
                  // Makros bearbeiten => öffnet Sheet
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
            const Divider(),
            // Optional: direkt aus diesem Menü löschen
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Lebensmittel löschen',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.pop(context);
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Lebensmittel löschen'),
                      content: const Text(
                        'Möchtest du das Lebensmittel wirklich löschen? '
                        'Diese Aktion kann nicht rückgängig gemacht werden.',
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
                    await Provider.of<AppState>(context, listen: false)
                        .removeFood(consumedFood.mealName, consumedFood);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${consumedFood.food.name} wurde gelöscht.'),
                      ),
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

/// Sheet, um die Menge eines bereits konsumierten Lebensmittels zu bearbeiten
/// (bzw. die Mahlzeit zu wechseln).
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

class _EditConsumedFoodItemSheetState extends State<EditConsumedFoodItemSheet> {
  late TextEditingController _gramController;
  String? selectedMeal;

  double _partialCalories = 0.0;
  double _partialCarbs = 0.0;
  double _partialProtein = 0.0;
  double _partialFat = 0.0;
  double _partialSugar = 0.0;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _gramController =
        TextEditingController(text: widget.consumedFood.quantity.toString());
    selectedMeal = widget.consumedFood.mealName;

    _gramController.addListener(_updateMacros);
    _updateMacros(); // Initialberechnung
  }

  @override
  void dispose() {
    _gramController.removeListener(_updateMacros);
    _gramController.dispose();
    super.dispose();
  }

  void _updateMacros() {
    final grams = int.tryParse(_gramController.text) ?? 0;
    final food = widget.consumedFood.food;

    setState(() {
      _partialCalories = (food.caloriesPer100g * grams) / 100.0;
      _partialCarbs = (food.carbsPer100g * grams) / 100.0;
      _partialProtein = (food.proteinPer100g * grams) / 100.0;
      _partialFat = (food.fatPer100g * grams) / 100.0;
      _partialSugar = (food.sugarPer100g * grams) / 100.0;
    });
  }

  Future<void> _saveChanges() async {
    final newQuantity = int.tryParse(_gramController.text);
    if (newQuantity == null || newQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gib eine gültige Menge ein.')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      await Provider.of<AppState>(context, listen: false).updateConsumedFoodItem(
        widget.consumedFood,
        newQuantity: newQuantity,
        newMealName: selectedMeal,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menge aktualisiert.')),
      );
      widget.onFoodEdited(); // Aktualisiere das UI
      Navigator.pop(context); // Schließe dieses Sheet
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Aktualisieren: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Optionales direktes Löschen
  Future<void> _deleteItem() async {
    final appState = Provider.of<AppState>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      await appState.removeFood(widget.consumedFood.mealName, widget.consumedFood);

      // Wir poppen hier direkt das BottomSheet:
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.consumedFood.food.name} wurde gelöscht.')),
      );
      widget.onFoodEdited(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Löschen: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _cancelEdit() {
    Navigator.pop(context); // Einfach Sheet schließen
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity, // So breit wie möglich
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Links ausrichten
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Menge bearbeiten',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _gramController,
                decoration: const InputDecoration(
                  labelText: 'Menge in Gramm',
                  hintText: 'z.B. 150',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMeal,
                decoration: const InputDecoration(
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
              const SizedBox(height: 16),
              // Dynamische Makro-Anzeige
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Links ausrichten
                    children: [
                      Text(
                        'Aktuelle Menge: ${_gramController.text} g',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Kalorien: ${_partialCalories.toStringAsFixed(1)} kcal',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Kohlenhydrate: ${_partialCarbs.toStringAsFixed(1)} g',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Proteine: ${_partialProtein.toStringAsFixed(1)} g',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Fette: ${_partialFat.toStringAsFixed(1)} g',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Zucker: ${_partialSugar.toStringAsFixed(1)} g',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Drei Buttons: Abbrechen, Speichern, Löschen
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _cancelEdit,
                    child: const Text('Abbrechen'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Speichern'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _isLoading ? null : _deleteItem,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Löschen'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sheet zum Bearbeiten der Makros (FoodItem selbst) – z. B. wenn sich
/// Kalorien oder Nährwerte geändert haben.
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
        await Provider.of<AppState>(context, listen: false)
            .editFood(updatedFood);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Makronährstoffe aktualisiert.')),
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
        child: Container(
          width: double.infinity, // So breit wie möglich
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Links ausrichten
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Makronährstoffe bearbeiten',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Kalorien pro 100g',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Pflichtfeld' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _carbsController,
                  decoration: const InputDecoration(
                    labelText: 'Kohlenhydrate pro 100g (g)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Pflichtfeld' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _proteinController,
                  decoration: const InputDecoration(
                    labelText: 'Proteine pro 100g (g)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Pflichtfeld' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fatController,
                  decoration: const InputDecoration(
                    labelText: 'Fette pro 100g (g)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Pflichtfeld' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sugarController,
                  decoration: const InputDecoration(
                    labelText: 'Zucker pro 100g (g)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Pflichtfeld' : null,
                ),
                const SizedBox(height: 24),
                // Hier Abbrechen- und Speichern-Buttons nebeneinander
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context), 
                      child: const Text('Abbrechen'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _saveFoodDetails,
                      child: const Text('Speichern'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
