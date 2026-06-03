import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/consumed_food_item.dart';
import '../models/app_state.dart';
import 'edit_food_sheet.dart';

class MealSection extends StatelessWidget {
  final String mealName;
  final List<ConsumedFoodItem> foods;
  final VoidCallback onAdd;
  final VoidCallback? onSaveMeal;
  final VoidCallback onCopyYesterday;
  final VoidCallback onImportQr;
  final VoidCallback? onShareQr;

  const MealSection({
    Key? key,
    required this.mealName,
    required this.foods,
    required this.onAdd,
    required this.onCopyYesterday,
    required this.onImportQr,
    this.onSaveMeal,
    this.onShareQr,
  }) : super(key: key);

  double _calculateMealCalories(List<ConsumedFoodItem> items) {
    double sum = 0;
    for (var item in items) {
      sum += (item.food.caloriesPer100g * item.quantity) / 100.0;
    }
    return sum;
  }

  Widget _buildActionsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Gestern übernehmen',
            onPressed: onCopyYesterday,
          ),
          if (onShareQr != null)
            IconButton(
              icon: const Icon(Icons.qr_code_2),
              tooltip: 'Mahlzeit als QR teilen',
              onPressed: onShareQr,
            ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              iconSize: 28.0,
              tooltip: 'Lebensmittel hinzufügen',
              onPressed: onAdd,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Mahlzeit per QR importieren',
            onPressed: onImportQr,
          ),
          if (onSaveMeal != null)
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              tooltip: 'Mahlzeit speichern',
              onPressed: onSaveMeal,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double mealCalories = _calculateMealCalories(foods);

    if (foods.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: ExpansionTile(
          expansionAnimationStyle: AnimationStyle(
            duration: const Duration(milliseconds: 350),
            curve: Curves.fastOutSlowIn,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  mealName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
              padding: EdgeInsets.all(12.0),
              child: Text('Keine Lebensmittel hinzugefügt.'),
            ),
            const Divider(height: 1),
            _buildActionsRow(context),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        expansionAnimationStyle: AnimationStyle(
          duration: const Duration(milliseconds: 350),
          curve: Curves.fastOutSlowIn,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                mealName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
              final double itemCalories =
                  (consumedFood.food.caloriesPer100g * consumedFood.quantity) /
                      100.0;
              final appState = Provider.of<AppState>(context, listen: false);
              final isFav = appState.isFavoriteFood(consumedFood.food);

              return TweenAnimationBuilder<double>(
                key: ValueKey('anim_${consumedFood.id}'),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, animValue, animChild) {
                  return Opacity(
                    opacity: animValue,
                    child: Transform.translate(
                      offset: Offset(0, 15 * (1 - animValue)),
                      child: animChild,
                    ),
                  );
                },
                child: Dismissible(
                  key: ValueKey(consumedFood.id),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    color: isFav ? Colors.amber[700] : Colors.green[600],
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Icon(
                      isFav ? Icons.star_border : Icons.star,
                      color: Colors.white,
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red[600],
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Toggle favorite
                      await appState.toggleFavoriteFood(consumedFood.food);
                      if (context.mounted) {
                        final nextIsFav = appState.isFavoriteFood(consumedFood.food);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              nextIsFav
                                  ? '${consumedFood.food.name} zu Favoriten hinzugefügt.'
                                  : '${consumedFood.food.name} aus Favoriten entfernt.',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                      return false; // Do not dismiss from list
                    } else if (direction == DismissDirection.endToStart) {
                      // Delete food
                      await appState.removeFood(mealName, consumedFood);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${consumedFood.food.name} gelöscht.'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                      return true; // Dismiss from list
                    }
                    return false;
                  },
                  child: ListTile(
                    key: ValueKey('tile_${consumedFood.id}'),
                    title: Text(consumedFood.food.name),
                    subtitle: Text(
                      '${consumedFood.quantity} g, '
                      '${consumedFood.food.caloriesPer100g} kcal/100g\n'
                      'Marke: ${consumedFood.food.brand}',
                    ),
                    trailing: Text(
                      '${itemCalories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (ctx) => EditConsumedFoodItemSheet(
                          consumedFood: consumedFood,
                          onFoodEdited: () {},
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildActionsRow(context),
        ],
      ),
    );
  }
}
