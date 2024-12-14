// lib/widgets/meal_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/consumed_food_item.dart';
import 'edit_food_sheet.dart';

class MealSection extends StatelessWidget {
  final String mealName;
  final List<ConsumedFoodItem> foods;
  final VoidCallback onAdd;

  const MealSection({
    Key? key,
    required this.mealName,
    required this.foods,
    required this.onAdd,
  }) : super(key: key);

  // Beim Klick auf Bearbeiten bei bereits hinzugefügten Lebensmitteln soll direkt die Mengenbearbeitung geöffnet werden
  void _showQuantityEditDialog(BuildContext context, ConsumedFoodItem consumedFood) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditConsumedFoodItemSheet(
        consumedFood: consumedFood,
        onFoodEdited: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _deleteFood(BuildContext context, ConsumedFoodItem consumedFood) async {
    final appState = Provider.of<AppState>(context, listen: false);
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Lebensmittel löschen'),
          content: Text('Möchtest du ${consumedFood.food.name} wirklich entfernen?'),
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
        await appState.removeFood(mealName, consumedFood);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${consumedFood.food.name} wurde entfernt.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Entfernen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (foods.isEmpty) {
      return Card(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: ExpansionTile(
          title: Text(
            mealName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Keine Lebensmittel hinzugefügt.'),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Lebensmittel hinzufügen'),
              onTap: onAdd,
            ),
          ],
        ),
      );
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(
          mealName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final consumedFood = foods[index];
              return ListTile(
                key: ValueKey(consumedFood.id),
                title: Text(consumedFood.food.name),
                subtitle: Text(
                    '${consumedFood.quantity} g, ${consumedFood.food.caloriesPer100g} kcal/100g\nMarke: ${consumedFood.food.brand}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bearbeiten => direkt Menge bearbeiten
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showQuantityEditDialog(context, consumedFood);
                      },
                    ),
                    // Löschen führt zum Entfernen aus der DB
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteFood(context, consumedFood);
                      },
                    ),
                  ],
                ),
                // **Neuer Code: Beim Klicken auf das ListTile wird die Menge bearbeitet**
                onTap: () {
                  _showQuantityEditDialog(context, consumedFood);
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Lebensmittel hinzufügen'),
            onTap: onAdd,
          ),
        ],
      ),
    );
  }
}
