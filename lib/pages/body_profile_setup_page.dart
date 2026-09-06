import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../features/settings/domain/settings_models.dart';
import '../models/app_state.dart';

/// Mandatory first-run setup for the inputs required by the BMR calculation.
class BodyProfileSetupPage extends StatefulWidget {
  const BodyProfileSetupPage({super.key});

  @override
  State<BodyProfileSetupPage> createState() => _BodyProfileSetupPageState();
}

class _BodyProfileSetupPageState extends State<BodyProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  Gender? _gender;
  bool _isSaving = false;

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _gender == null) {
      setState(() {});
      return;
    }

    setState(() => _isSaving = true);
    try {
      await context.read<AppState>().saveBodyProfileSettings(
            userAge: int.parse(_ageController.text.trim()),
            userHeight: double.parse(_heightController.text.trim()),
            gender: _gender,
            bodyProfileConfigured: true,
          );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Dein Körperprofil')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Grundumsatz richtig berechnen',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bitte hinterlege diese Angaben einmalig. Ohne sie werden keine geschätzten BMR- oder Gesamtumsatzwerte angezeigt.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Alter',
                        suffixText: 'Jahre',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final age = int.tryParse(value?.trim() ?? '');
                        if (age == null || age < 13 || age > 120) {
                          return 'Bitte gib ein Alter zwischen 13 und 120 Jahren ein.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Körpergröße',
                        suffixText: 'cm',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final height = double.tryParse(
                          (value ?? '').trim().replaceAll(',', '.'),
                        );
                        if (height == null || height < 100 || height > 250) {
                          return 'Bitte gib eine Größe zwischen 100 und 250 cm ein.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Geschlecht für die BMR-Formel',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<Gender>(
                      segments: const [
                        ButtonSegment(
                          value: Gender.female,
                          label: Text('Weiblich'),
                          icon: Icon(Icons.female),
                        ),
                        ButtonSegment(
                          value: Gender.male,
                          label: Text('Männlich'),
                          icon: Icon(Icons.male),
                        ),
                      ],
                      selected: _gender == null ? const {} : {_gender!},
                      onSelectionChanged: (selection) {
                        setState(() => _gender = selection.first);
                      },
                    ),
                    if (_gender == null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Bitte wähle eine Option aus.',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _isSaving ? null : _save,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Profil speichern'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
