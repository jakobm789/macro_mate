import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:macro_mate/models/local_llm_model.dart';
import 'package:macro_mate/services/llm_service.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('local LLM models fit and answer on GPU from smallest to largest',
      (tester) async {
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint('[GpuFit] Skipping: Android device required.');
      return;
    }

    final logs = ValueNotifier<List<String>>([]);
    final activeStep = ValueNotifier<String>('Initialisiere GPU-Test...');

    void log(String message, {String? step}) {
      debugPrint('[GpuFit] $message');
      logs.value = [...logs.value, message];
      if (step != null) activeStep.value = step;
    }

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          appBar: AppBar(title: const Text('LLM GPU Fit Test')),
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

    final models = LocalLlmModel.supported;

    final failures = <String>[];
    for (var i = 0; i < models.length; i++) {
      final model = models[i];
      final label = '${i + 1}/${models.length} ${model.displayName}';
      log('--- $label ---', step: 'GPU-Test $label');

      final installedBefore =
          await FlutterGemma.isModelInstalled(model.fileName);
      log('Installiert: $installedBefore');

      final service = LlmService(
        selectedModel: model,
        forcedBackend: PreferredBackend.gpu,
      );

      try {
        if (!installedBefore) {
          log('Download startet...');
          await service.ensureSelectedModelAvailable(
            allowDownload: true,
            onDownloadProgress: (progress) {
              if (progress % 10 == 0) log('Download $progress%');
            },
          );
        }

        final warmupWatch = Stopwatch()..start();
        await service.warmUp(supportImage: model.supportsVision);
        warmupWatch.stop();
        log('Warmup OK in ${warmupWatch.elapsedMilliseconds}ms, Backend=${service.loadedBackendName}');
        expect(service.loadedBackendName, 'GPU');

        final promptWatch = Stopwatch()..start();
        final response = await service.runDebugPrompt();
        promptWatch.stop();
        log('Prompt OK in ${promptWatch.elapsedMilliseconds}ms: "${response.replaceAll('\n', ' ').trim()}"');
        expect(response.trim(), isNotEmpty);
      } catch (e, st) {
        final failure = '$label GPU failed: $e';
        log(failure);
        debugPrintStack(stackTrace: st);
        failures.add(failure);
      } finally {
        await service.dispose();
      }
    }

    if (failures.isNotEmpty) {
      fail('GPU failures:\n${failures.join('\n')}');
    }

    activeStep.value = 'Alle Modelle laufen auf GPU';
    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 45)));
}
