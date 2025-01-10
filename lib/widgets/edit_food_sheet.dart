import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/food_item.dart';
import '../models/consumed_food_item.dart';

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
          right: 20,
        ),
        child: Wrap(
          children: [
            if (mode == EditingMode.quantity)
              ListTile(
                leading: const Icon(Icons.edit_attributes, color: Colors.green),
                title: const Text(
                  'Menge bearbeiten',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => EditConsumedFoodItemSheet(
                      consumedFood: consumedFood,
                      onFoodEdited: onFoodEdited,
                    ),
                  );
                },
              ),

            if (mode == EditingMode.quantity) const Divider(),
            if (mode == EditingMode.quantity)
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
      widget.onFoodEdited(); 
      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Aktualisieren: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem() async {
    final appState = Provider.of<AppState>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      await appState.removeFood(widget.consumedFood.mealName, widget.consumedFood);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.consumedFood.food.name} wurde gelöscht.'),
        ),
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity, 
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
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
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 24),
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
