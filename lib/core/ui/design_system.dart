import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.onTap,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                if (onTap != null) const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
    return onTap == null
        ? Semantics(container: true, label: '$title: $value', child: card)
        : Semantics(
            button: true,
            container: true,
            label: '$title: $value',
            child: InkWell(onTap: onTap, child: card),
          );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (action != null) action!,
        ],
      );
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label = 'Wird geladen …'});

  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        liveRegion: true,
        child: const Center(child: CircularProgressIndicator()),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.inbox_outlined, size: 32),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(message, textAlign: TextAlign.center),
              if (action != null) ...[
                const SizedBox(height: 12),
                action!,
              ],
            ],
          ),
        ),
      );
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: ListTile(
          leading: const Icon(Icons.error_outline),
          title: const Text('Daten konnten nicht geladen werden'),
          subtitle: Text(message),
          trailing: onRetry == null
              ? null
              : IconButton(
                  tooltip: 'Erneut versuchen',
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                ),
        ),
      );
}

class PermissionCard extends StatelessWidget {
  const PermissionCard({
    super.key,
    required this.title,
    required this.message,
    required this.onGrant,
  });

  final String title;
  final String message;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.lock_open_outlined),
          title: Text(title),
          subtitle: Text(message),
          trailing: FilledButton(
            onPressed: onGrant,
            child: const Text('Erlauben'),
          ),
        ),
      );
}

class SyncStatus extends StatelessWidget {
  const SyncStatus({super.key, this.lastSyncUtc, this.error});

  final DateTime? lastSyncUtc;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final text = error != null
        ? 'Fehler: $error'
        : lastSyncUtc == null
            ? 'Noch nicht synchronisiert'
            : 'Zuletzt ${lastSyncUtc!.toLocal()}'
                .replaceFirst(RegExp(r'\.\d+'), '');
    return ListTile(
      leading: Icon(
        error == null ? Icons.sync : Icons.sync_problem,
        color: error == null
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
      ),
      title: const Text('Synchronisationsstatus'),
      subtitle: Text(text),
    );
  }
}

class ChartCard extends StatelessWidget {
  const ChartCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      );
}
