import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dashboard_controller.dart';

class DashboardConfigSheet extends StatelessWidget {
  const DashboardConfigSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const DashboardConfigSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<DashboardController>();
    final cardOrder = controller.cardOrder;
    final visibility = controller.cardVisibility;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dashboard anpassen',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Ziehe Karten an den Griffen, um die Reihenfolge zu ändern. Deaktiviere Schalter zum Ausblenden.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ReorderableListView.builder(
                  scrollController: scrollController,
                  itemCount: cardOrder.length,
                  onReorder: (oldIndex, newIndex) {
                    controller.reorderCards(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final cardId = cardOrder[index];
                    final title = DashboardController.cardTitles[cardId] ?? cardId;
                    final isVisible = visibility[cardId] ?? true;

                    return Card(
                      key: ValueKey(cardId),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.drag_handle),
                        title: Text(title, style: theme.textTheme.bodyLarge),
                        trailing: Switch(
                          value: isVisible,
                          onChanged: (val) {
                            controller.toggleCardVisibility(cardId, val);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.restore),
                label: const Text('Standard wiederherstellen'),
                onPressed: () {
                  controller.resetToDefaults();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
