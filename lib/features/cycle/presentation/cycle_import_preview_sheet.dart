import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../domain/cycle_models.dart';
import 'cycle_controller.dart';

class CycleImportPreviewSheet extends StatelessWidget {
  const CycleImportPreviewSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const CycleImportPreviewSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<CycleController>();
    final items = controller.pendingImportConflicts;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
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
                    'Health Connect Periodenimport',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Überprüfe die gefundenen Periodeneinträge und wähle im Konfliktfall die passende Option.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('Keine neuen Menstruationsdaten gefunden.'),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final rec = item.importedRecord;
                      final startStr = DateFormat('dd.MM.yyyy').format(rec.startDay);
                      final endStr = rec.endDay != null
                          ? DateFormat('dd.MM.yyyy').format(rec.endDay!)
                          : 'offen';

                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: item.conflictType != MenstruationConflictType.none
                                ? theme.colorScheme.error.withOpacity(0.5)
                                : theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$startStr – $endStr',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  _buildConflictBadge(context, item.conflictType),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quelle: ${rec.sourceName}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (item.conflictingLocalPeriod != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Lokaler Eintrag: ${DateFormat('dd.MM.yyyy').format(item.conflictingLocalPeriod!.startDay)}'
                                  ' – ${item.conflictingLocalPeriod!.endDay != null ? DateFormat('dd.MM.yyyy').format(item.conflictingLocalPeriod!.endDay!) : 'offen'}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text('Aktion: ', style: theme.textTheme.bodyMedium),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonFormField<MenstruationConflictResolution>(
                                      value: item.chosenResolution,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: MenstruationConflictResolution.acceptImported,
                                          child: Text('Übernehmen'),
                                        ),
                                        DropdownMenuItem(
                                          value: MenstruationConflictResolution.merge,
                                          child: Text('Zusammenführen'),
                                        ),
                                        DropdownMenuItem(
                                          value: MenstruationConflictResolution.keepLocal,
                                          child: Text('Lokal behalten'),
                                        ),
                                        DropdownMenuItem(
                                          value: MenstruationConflictResolution.skip,
                                          child: Text('Überspringen'),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          controller.updateConflictResolution(index, val);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Import ausführen'),
                onPressed: items.isEmpty
                    ? null
                    : () async {
                        final count = await controller.applyStagedImport();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$count Periodeneinträge erfolgreich importiert.'),
                            ),
                          );
                        }
                      },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConflictBadge(BuildContext context, MenstruationConflictType type) {
    final theme = Theme.of(context);
    switch (type) {
      case MenstruationConflictType.none:
        return Chip(
          label: const Text('Neu', style: TextStyle(fontSize: 11)),
          backgroundColor: theme.colorScheme.primaryContainer,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
      case MenstruationConflictType.exactDuplicate:
        return Chip(
          label: const Text('Duplikat', style: TextStyle(fontSize: 11)),
          backgroundColor: theme.colorScheme.surfaceVariant,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
      case MenstruationConflictType.overlap:
      case MenstruationConflictType.contains:
        return Chip(
          label: const Text('Konflikt / Überlappung', style: TextStyle(fontSize: 11)),
          backgroundColor: theme.colorScheme.errorContainer,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
    }
  }
}
