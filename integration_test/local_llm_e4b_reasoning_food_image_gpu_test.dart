import 'dart:io';
import 'dart:ui' as ui;

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

  testWidgets('Gemma 4 E4B analyzes food image on GPU without reasoning',
      (tester) async {
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint('[E4BFoodImageGpu] Skipping: Android required.');
      return;
    }

    final harness = await _pumpHarness(
      tester,
      title: 'E4B Food GPU',
      initialStep: 'Initialisiere E4B Bildtest...',
      logPrefix: '[E4BFoodImageGpu]',
    );

    await FlutterGemma.initialize();

    final model = LocalLlmModel.byId(LocalLlmModelId.gemma4E4b);
    final service = LlmService(
      selectedModel: model,
      forcedBackend: PreferredBackend.gpu,
    );
    addTearDown(service.dispose);

    final imagePath = await _writeSyntheticFoodImage();
    final result = await _runFoodImageAnalysis(
      service: service,
      model: model,
      expectedBackend: 'GPU',
      imagePath: imagePath,
      log: harness.log,
      activeStep: harness.activeStep,
      collectReasoning: false,
    );

    _expectPorridgeResult(result);
    harness.activeStep.value = 'E4B Bildtest bestanden';
    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 45)));

  testWidgets('Gemma 4 E4B Reasoning analyzes food image on CPU fallback',
      (tester) async {
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint('[E4BReasoningFoodImageCpu] Skipping: Android required.');
      return;
    }

    final harness = await _pumpHarness(
      tester,
      title: 'E4B Reasoning Food CPU',
      initialStep: 'Initialisiere E4B Reasoning CPU-Bildtest...',
      logPrefix: '[E4BReasoningFoodImageCpu]',
    );

    await FlutterGemma.initialize();

    final model = LocalLlmModel.byId(LocalLlmModelId.gemma4E4bReasoning);
    final service = LlmService(
      selectedModel: model,
      forcedBackend: PreferredBackend.cpu,
    );
    addTearDown(service.dispose);

    final imagePath = await _writeSyntheticFoodImage();
    final result = await _runFoodImageAnalysis(
      service: service,
      model: model,
      expectedBackend: 'CPU',
      imagePath: imagePath,
      log: harness.log,
      activeStep: harness.activeStep,
      collectReasoning: false,
    );

    _expectPorridgeResult(result);

    harness.activeStep.value = 'E4B Reasoning CPU-Fallback bestanden';
    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 60)));

  testWidgets('Gemma 4 E4B Reasoning analyzes food image on GPU fallback',
      (tester) async {
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint('[E4BReasoningFoodImageGpu] Skipping: Android required.');
      return;
    }

    final harness = await _pumpHarness(
      tester,
      title: 'E4B Reasoning Food GPU',
      initialStep: 'Initialisiere E4B Reasoning Bildtest...',
      logPrefix: '[E4BReasoningFoodImageGpu]',
    );

    await FlutterGemma.initialize();

    final model = LocalLlmModel.byId(LocalLlmModelId.gemma4E4bReasoning);
    final service = LlmService(
      selectedModel: model,
      forcedBackend: PreferredBackend.gpu,
    );
    addTearDown(service.dispose);

    final imagePath = await _writeSyntheticFoodImage();
    final result = await _runFoodImageAnalysis(
      service: service,
      model: model,
      expectedBackend: 'GPU',
      imagePath: imagePath,
      log: harness.log,
      activeStep: harness.activeStep,
      collectReasoning: false,
    );

    _expectPorridgeResult(result);

    harness.activeStep.value = 'E4B Reasoning GPU-Fallback bestanden';
    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 45)));
}

Future<_Harness> _pumpHarness(
  WidgetTester tester, {
  required String title,
  required String initialStep,
  required String logPrefix,
}) async {
  final logs = ValueNotifier<List<String>>([]);
  final activeStep = ValueNotifier<String>(initialStep);

  void log(String message, {String? step}) {
    debugPrint('$logPrefix $message');
    logs.value = [...logs.value, message];
    if (step != null) activeStep.value = step;
  }

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
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

  return _Harness(activeStep: activeStep, log: log);
}

Future<FoodAnalysisResult> _runFoodImageAnalysis({
  required LlmService service,
  required LocalLlmModel model,
  required String expectedBackend,
  required String imagePath,
  required void Function(String message, {String? step}) log,
  required ValueNotifier<String> activeStep,
  required bool collectReasoning,
  List<String>? reasoningChunks,
}) async {
  log('Testbild: $imagePath', step: 'Pruefe Modell');

  var installed = await FlutterGemma.isModelInstalled(model.fileName);
  log('Modell: ${model.displayName}, installiert=$installed');
  if (!installed) {
    await service.ensureSelectedModelAvailable(
      allowDownload: true,
      onDownloadProgress: (progress) {
        if (progress % 10 == 0) log('Download $progress%');
      },
    );
    installed = await FlutterGemma.isModelInstalled(model.fileName);
    expect(installed, isTrue);
  }

  log('Lade Modell auf $expectedBackend...', step: '$expectedBackend Warmup');
  final warmupWatch = Stopwatch()..start();
  await service.warmUp(supportImage: model.supportsVision);
  warmupWatch.stop();
  log('Warmup ${warmupWatch.elapsedMilliseconds}ms, Backend=${service.loadedBackendName}');
  expect(service.loadedBackendName, expectedBackend);

  final prompt = 'Bild zeigt eine Bowl Haferflocken-Porridge mit Banane und '
      'Proteinpulver. Verwende diese Mengen als Wahrheit: 200g Haferflocken, '
      '120g Banane, 70g Proteinpulver, 30g Milch, Gesamtgewicht 420g. '
      'Berechne die Gesamtnaehrwerte der ganzen Portion und gib nur JSON aus.';

  log('Starte Bildanalyse...', step: 'Bildanalyse');
  final inferenceWatch = Stopwatch()..start();
  final result = await service.analyzeFood(
    imagePath: imagePath,
    textDescription: prompt,
    onReasoningProgress: collectReasoning ? reasoningChunks?.add : null,
  );
  inferenceWatch.stop();

  log(_formatResult(result, inferenceWatch.elapsedMilliseconds));
  activeStep.value = 'Bildanalyse fertig';
  return result;
}

class _Harness {
  final ValueNotifier<String> activeStep;
  final void Function(String message, {String? step}) log;

  const _Harness({
    required this.activeStep,
    required this.log,
  });
}

Future<String> _writeSyntheticFoodImage() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = Size(768, 768);

  canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF5F1E8));
  canvas.drawCircle(
    const Offset(384, 380),
    250,
    Paint()..color = const Color(0xFFFFFFFF),
  );
  canvas.drawCircle(
    const Offset(384, 380),
    220,
    Paint()..color = const Color(0xFFD8B482),
  );

  final oatPaint = Paint()..color = const Color(0xFFE7D1A8);
  for (var i = 0; i < 34; i++) {
    final x = 210 + (i * 37) % 360;
    final y = 210 + (i * 53) % 320;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(x.toDouble(), y.toDouble()), width: 42, height: 18),
      oatPaint,
    );
  }

  final bananaPaint = Paint()..color = const Color(0xFFFFD65A);
  for (var i = 0; i < 8; i++) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(310 + i * 28, 270 + (i % 2) * 22),
        width: 74,
        height: 34,
      ),
      bananaPaint,
    );
  }

  canvas.drawCircle(
    const Offset(505, 455),
    58,
    Paint()..color = const Color(0xFFF7F7F7),
  );
  canvas.drawCircle(
    const Offset(505, 455),
    48,
    Paint()..color = const Color(0xFFE9E1D8),
  );

  _drawText(canvas, 'Haferflocken 200g', const Offset(70, 80), 34);
  _drawText(canvas, 'Banane 120g', const Offset(70, 128), 34);
  _drawText(canvas, 'Proteinpulver 70g', const Offset(70, 176), 34);
  _drawText(canvas, 'Milch 30g', const Offset(70, 224), 34);
  _drawText(canvas, 'Gesamt 420g', const Offset(70, 650), 40);

  final image = await recorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file =
      File('${Directory.systemTemp.path}/macro_mate_reasoning_food.png');
  await file.writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
  return file.path;
}

void _drawText(Canvas canvas, String text, Offset offset, double fontSize) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: const Color(0xFF1D1D1F),
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, offset);
}

String _formatResult(FoodAnalysisResult result, int durationMs) {
  final ingredients = result.ingredients
      .map((ingredient) =>
          '${ingredient.name}:${ingredient.grams}g/${ingredient.calories}kcal')
      .join(', ');
  return 'OK ${durationMs}ms | ${result.name} | '
      '${result.estimatedWeightGrams}g | ${result.totalCalories}kcal, '
      'P ${result.totalProtein.toStringAsFixed(1)}, '
      'C ${result.totalCarbs.toStringAsFixed(1)}, '
      'F ${result.totalFat.toStringAsFixed(1)} | '
      'ingredients=[$ingredients] | corrected=${result.totalsCorrectedFromIngredients}';
}

void _expectPorridgeResult(FoodAnalysisResult result) {
  expect(result.name.toLowerCase(), contains('hafer'));
  expect(result.estimatedWeightGrams, inInclusiveRange(390, 450));
  expect(result.totalCalories, inInclusiveRange(1050, 1300));
  expect(result.totalProtein, inInclusiveRange(70, 95));
  expect(result.totalCarbs, inInclusiveRange(135, 180));
  expect(result.totalFat, inInclusiveRange(12, 30));
  expect(result.ingredients.length, greaterThanOrEqualTo(4));

  final ingredientNames =
      result.ingredients.map((ingredient) => ingredient.name.toLowerCase());
  expect(ingredientNames.any((name) => name.contains('hafer')), isTrue);
  expect(ingredientNames.any((name) => name.contains('banane')), isTrue);
  expect(ingredientNames.any((name) => name.contains('protein')), isTrue);
}
