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

  testWidgets('FastVLM loads on GPU and answers a minimal prompt',
      (tester) async {
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint('[FastVlmGpuSmoke] Skipping: Android device required.');
      return;
    }

    final logs = ValueNotifier<List<String>>([]);
    final activeStep =
        ValueNotifier<String>('Initialisiere FastVLM GPU-Test...');

    void log(String message, {String? step}) {
      debugPrint('[FastVlmGpuSmoke] $message');
      logs.value = [...logs.value, message];
      if (step != null) activeStep.value = step;
    }

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          appBar: AppBar(title: const Text('FastVLM GPU Smoke')),
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

    final model = LocalLlmModel.byId(LocalLlmModelId.fastVlm05b);
    final service = LlmService(
      selectedModel: model,
      forcedBackend: PreferredBackend.gpu,
    );
    addTearDown(service.dispose);

    log('Modell: ${model.displayName}', step: 'Pruefe Download');
    var installed = await FlutterGemma.isModelInstalled(model.fileName);
    log('Installiert: $installed');
    if (!installed) {
      await service.ensureSelectedModelAvailable(
        allowDownload: true,
        onDownloadProgress: (progress) {
          if (progress % 10 == 0) log('Download $progress%');
        },
      );
      installed = await FlutterGemma.isModelInstalled(model.fileName);
      log('Installiert nach Download: $installed');
      expect(installed, isTrue);
    }

    log('Lade Modell auf GPU...', step: 'GPU Warmup');
    final warmupWatch = Stopwatch()..start();
    await service.warmUp(supportImage: model.supportsVision);
    warmupWatch.stop();
    log('Warmup OK in ${warmupWatch.elapsedMilliseconds}ms, Backend=${service.loadedBackendName}');
    expect(service.loadedBackendName, 'GPU');

    log('Teste minimale Inferenz...', step: 'GPU Prompt');
    final responseWatch = Stopwatch()..start();
    final response = await service.runDebugPrompt();
    responseWatch.stop();
    final normalized = response.replaceAll('\n', ' ').trim();
    log('Antwort in ${responseWatch.elapsedMilliseconds}ms: $normalized');
    expect(normalized, contains('OK'));

    activeStep.value = 'FastVLM GPU-Test bestanden';
    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 20)));
}
