// ./macro_mate/lib/widgets/meal_section.dart

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

  // Beim Langdruck auf ein bereits hinzugefügtes Lebensmittel => Bearbeiten-Dialog
  void _showQuantityEditDialog(BuildContext context, ConsumedFoodItem consumedFood) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditConsumedFoodItemSheet(
        consumedFood: consumedFood,
        // Der Callback ist jetzt leer, damit kein doppeltes pop auftritt.
        onFoodEdited: () {
          // KEIN Navigator.pop(context); mehr
        },
      ),
    );
  }

  double _calculateMealCalories(List<ConsumedFoodItem> items) {
    double sum = 0;
    for (var item in items) {
      sum += (item.food.caloriesPer100g * item.quantity) / 100.0;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    // Gesamt-Kalorien für diese Mahlzeit berechnen
    final double mealCalories = _calculateMealCalories(foods);

    if (foods.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: ExpansionTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  mealName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Text(
                '0 kcal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Keine Lebensmittel hinzugefügt.'),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Lebensmittel hinzufügen'),
              onTap: onAdd,
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        // Wir nutzen eine Row, um Mahlzeit-Name links und Kalorien rechts anzuzeigen
        title: Row(
          children: [
            Expanded(
              child: Text(
                mealName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '${mealCalories.toStringAsFixed(0)} kcal',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final consumedFood = foods[index];

              // Kalorien dieses Eintrags
              double itemCalories = (consumedFood.food.caloriesPer100g *
                      consumedFood.quantity) /
                  100.0;

              return ListTile(
                key: ValueKey(consumedFood.id),
                title: Text(consumedFood.food.name),
                subtitle: Text(
                  '${consumedFood.quantity} g, '
                  '${consumedFood.food.caloriesPer100g} kcal/100g\n'
                  'Marke: ${consumedFood.food.brand}',
                ),
                // Anzeige der Item-Kalorien rechts
                trailing: Text(
                  '${itemCalories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Langdruck öffnet das Bearbeiten-Dialog
                onLongPress: () {
                  _showQuantityEditDialog(context, consumedFood);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Lebensmittel hinzufügen'),
            onTap: onAdd,
          ),
        ],
      ),
    );
  }
}
