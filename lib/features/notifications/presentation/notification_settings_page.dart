import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/notifications/notification_controller.dart';
import '../../../core/notifications/notification_models.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<NotificationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Benachrichtigungen & Ruhezeiten'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.colorScheme.primaryContainer.withOpacity(0.4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined,
                          color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Lokale Benachrichtigungen',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Deine Erinnerungen werden direkt auf deinem Smartphone geplant. Diskrete Texte schützen deine Privatsphäre auf dem Sperrbildschirm.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Kategorien & Einstellungen',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final cat in NotificationCategory.values) ...[
            _buildCategoryCard(context, controller, cat),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    NotificationController controller,
    NotificationCategory category,
  ) {
    final theme = Theme.of(context);
    final pref = controller.getPreference(category) ??
        NotificationPreference(category: category);

    final title =
        NotificationController.categoryLabels[category] ?? category.name;
    final description =
        NotificationController.categoryDescriptions[category] ?? '';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: pref.enabled
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: ExpansionTile(
        key: ValueKey(category.name),
        initiallyExpanded: false,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description, style: theme.textTheme.bodySmall),
        trailing: Switch(
          value: pref.enabled,
          onChanged: (val) async {
            await controller.updatePreference(pref.copyWith(enabled: val));
          },
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 10),
          // Weekdays filter
          Text('Aktive Wochentage', style: theme.textTheme.labelMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: [
              for (int day = 1; day <= 7; day++)
                FilterChip(
                  label: Text(_weekdayName(day)),
                  selected: pref.weekdays.contains(day),
                  onSelected: (selected) async {
                    final updatedDays = Set<int>.from(pref.weekdays);
                    if (selected) {
                      updatedDays.add(day);
                    } else {
                      if (updatedDays.length > 1) {
                        updatedDays.remove(day);
                      }
                    }
                    await controller
                        .updatePreference(pref.copyWith(weekdays: updatedDays));
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Quiet hours
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ruhezeit Start', style: theme.textTheme.labelMedium),
                    Text(pref.quietStart ?? '22:00',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ruhezeit Ende', style: theme.textTheme.labelMedium),
                    Text(pref.quietEnd ?? '07:00',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.bedtime_outlined, size: 18),
                label: const Text('Anpassen'),
                onPressed: () async {
                  final start = await showTimePicker(
                    context: context,
                    initialTime: _parseTime(pref.quietStart ?? '22:00'),
                  );
                  if (start == null || !context.mounted) return;
                  final end = await showTimePicker(
                    context: context,
                    initialTime: _parseTime(pref.quietEnd ?? '07:00'),
                  );
                  if (end == null || !context.mounted) return;
                  await controller.updatePreference(
                    pref.copyWith(
                      quietStart:
                          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
                      quietEnd:
                          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Discrete lock screen toggle
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Diskreter Sperrbildschirm-Text'),
            subtitle: const Text(
                'Zeigt neutrale Formulierungen ohne intime Details auf dem Lock Screen an.'),
            value: pref.discreteLockScreen,
            onChanged: (val) async {
              await controller
                  .updatePreference(pref.copyWith(discreteLockScreen: val));
            },
          ),
          if (category == NotificationCategory.cycleWindow) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Vorwarnzeit:'),
                DropdownButton<int>(
                  value: (pref.leadMinutes / (24 * 60)).round().clamp(1, 7),
                  items: [
                    for (int days = 1; days <= 7; days++)
                      DropdownMenuItem(
                        value: days,
                        child: Text('$days Tage vorher'),
                      ),
                  ],
                  onChanged: (val) async {
                    if (val != null) {
                      await controller.updatePreference(
                        pref.copyWith(leadMinutes: val * 24 * 60),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _weekdayName(int day) {
    switch (day) {
      case 1:
        return 'Mo';
      case 2:
        return 'Di';
      case 3:
        return 'Mi';
      case 4:
        return 'Do';
      case 5:
        return 'Fr';
      case 6:
        return 'Sa';
      case 7:
        return 'So';
      default:
        return '$day';
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 22;
    final min = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return TimeOfDay(hour: hour, minute: min);
  }
}
