import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:macro_mate/models/food_analysis_result.dart';
import 'package:macro_mate/models/local_llm_model.dart';
import 'package:macro_mate/services/llm_service.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('standard local LLM returns plausible structured food estimates',
      (tester) async {
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint('[FoodPromptQuality] Skipping: Android device required.');
      return;
    }

    final logs = ValueNotifier<List<String>>([]);
    final activeStep = ValueNotifier<String>('Initialisiere...');

    void log(String message, {String? step}) {
      debugPrint('[FoodPromptQuality] $message');
      logs.value = [...logs.value, message];
      if (step != null) {
        activeStep.value = step;
      }
    }

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          appBar: AppBar(title: const Text('LLM Food Prompt Quality')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ValueListenableBuilder<String>(
                  valueListenable: activeStep,
                  builder: (_, step, __) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(step)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: logs,
                    builder: (_, entries, __) => ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          entries[index],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await FlutterGemma.initialize();

    final model = LocalLlmModel.byStoredName(null);
    expect(model.id, LocalLlmModelId.gemma4E4b);
    final service = LlmService(selectedModel: model, forcedBackend: null);
    addTearDown(service.dispose);

    log('Standardmodell: ${model.displayName}', step: 'Pruefe Modell...');
    var installed = await FlutterGemma.isModelInstalled(model.fileName);
    log('Installiert: $installed');
    if (!installed) {
      log('Starte Download fuer ${model.displayName}...',
          step: 'Download ${model.displayName}');
      await service.ensureSelectedModelAvailable(
        allowDownload: true,
        onDownloadProgress: (progress) {
          if (progress % 10 == 0) {
            log('Download: $progress%');
          }
        },
      );
      installed = await FlutterGemma.isModelInstalled(model.fileName);
      log('Installiert nach Download: $installed');
      expect(installed, isTrue);
    }

    await service.warmUp(supportImage: model.supportsVision);
    log('Warmup fertig. Backend: ${service.loadedBackendName}');

    final cases = [
      _FoodPromptCase(
        label: 'Haferflocken-Porridge 420g',
        prompt: 'Haferflocken-Porridge mit Banane und Proteinpulver. Zutaten: '
            '200g Haferflocken, 120g Banane, 70g Proteinpulver, 30g Milch. '
            'Gesamtgewicht 420g. Berechne die Gesamtnaehrwerte der ganzen Portion.',
        expectedNamePart: 'hafer',
        caloriesRange: const _IntRange(1050, 1300),
        carbsRange: const _DoubleRange(135, 180),
        proteinRange: const _DoubleRange(70, 95),
        fatRange: const _DoubleRange(12, 28),
        minIngredients: 4,
        requiredIngredientParts: ['hafer', 'banane', 'protein'],
      ),
      _FoodPromptCase(
        label: 'Banane 120g',
        prompt: 'Eine Banane, exakt 120g essbarer Anteil.',
        expectedNamePart: 'banane',
        caloriesRange: const _IntRange(80, 140),
        carbsRange: const _DoubleRange(20, 35),
        proteinRange: const _DoubleRange(0.5, 2.5),
        fatRange: const _DoubleRange(0, 1.5),
        minIngredients: 1,
      ),
      _FoodPromptCase(
        label: 'Apfel 150g',
        prompt: 'Ein Apfel, exakt 150g essbarer Anteil.',
        expectedNamePart: 'apfel',
        caloriesRange: const _IntRange(65, 95),
        carbsRange: const _DoubleRange(15, 25),
        proteinRange: const _DoubleRange(0, 1.5),
        fatRange: const _DoubleRange(0, 1.5),
        minIngredients: 1,
      ),
    ];

    for (var i = 0; i < cases.length; i++) {
      final foodCase = cases[i];
      log('--- ${foodCase.label} ---',
          step: 'Prompt ${i + 1}/${cases.length}: ${foodCase.label}');
      final stopwatch = Stopwatch()..start();
      final result = await service.analyzeFood(
        textDescription: foodCase.prompt,
      );
      stopwatch.stop();

      log(_formatResult(result, stopwatch.elapsedMilliseconds));
      foodCase.expectResult(result);
    }

    activeStep.value = 'Alle Prompt-Qualitaetstests bestanden';
    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 35)));
}

String _formatResult(FoodAnalysisResult result, int durationMs) {
  final ingredients = result.ingredients
      .map((ingredient) =>
          '${ingredient.name}:${ingredient.grams}g/${ingredient.calories}kcal')
      .join(', ');
  return 'OK ${durationMs}ms | ${result.name} | '
      '${result.totalCalories}kcal, P ${result.totalProtein.toStringAsFixed(1)}, '
      'C ${result.totalCarbs.toStringAsFixed(1)}, F ${result.totalFat.toStringAsFixed(1)} | '
      'ingredients: [$ingredients] | corrected=${result.totalsCorrectedFromIngredients}';
}

class _FoodPromptCase {
  final String label;
  final String prompt;
  final String expectedNamePart;
  final _IntRange caloriesRange;
  final _DoubleRange carbsRange;
  final _DoubleRange proteinRange;
  final _DoubleRange fatRange;
  final int minIngredients;
  final List<String> requiredIngredientParts;

  const _FoodPromptCase({
    required this.label,
    required this.prompt,
    required this.expectedNamePart,
    required this.caloriesRange,
    required this.carbsRange,
    required this.proteinRange,
    required this.fatRange,
    required this.minIngredients,
    this.requiredIngredientParts = const [],
  });

  void expectResult(FoodAnalysisResult result) {
    expect(
      result.name.toLowerCase(),
      contains(expectedNamePart),
      reason: '$label should mention $expectedNamePart in name',
    );
    expect(
      caloriesRange.contains(result.totalCalories),
      isTrue,
      reason: '$label calories ${result.totalCalories} outside $caloriesRange',
    );
    expect(
      carbsRange.contains(result.totalCarbs),
      isTrue,
      reason: '$label carbs ${result.totalCarbs} outside $carbsRange',
    );
    expect(
      proteinRange.contains(result.totalProtein),
      isTrue,
      reason: '$label protein ${result.totalProtein} outside $proteinRange',
    );
    expect(
      fatRange.contains(result.totalFat),
      isTrue,
      reason: '$label fat ${result.totalFat} outside $fatRange',
    );
    expect(
      result.ingredients.length,
      greaterThanOrEqualTo(minIngredients),
      reason: '$label should return structured ingredients',
    );

    final ingredientNames =
        result.ingredients.map((ingredient) => ingredient.name.toLowerCase());
    for (final requiredPart in requiredIngredientParts) {
      expect(
        ingredientNames.any((name) => name.contains(requiredPart)),
        isTrue,
        reason: '$label should include ingredient containing "$requiredPart"',
      );
    }
  }
}

class _IntRange {
  final int min;
  final int max;

  const _IntRange(this.min, this.max);

  bool contains(int value) => value >= min && value <= max;

  @override
  String toString() => '$min-$max';
}

class _DoubleRange {
  final double min;
  final double max;

  const _DoubleRange(this.min, this.max);

  bool contains(double value) => value >= min && value <= max;

  @override
  String toString() => '$min-$max';
}
