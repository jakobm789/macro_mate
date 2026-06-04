import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:macro_mate/models/local_llm_model.dart';
import 'package:macro_mate/services/llm_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FastVLM loads through LiteRT-LM FFI on Android', (_) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    await FlutterGemma.initialize();

    final model = LocalLlmModel.byId(LocalLlmModelId.fastVlm05b);
    final service = LlmService(selectedModel: model);
    addTearDown(service.dispose);

    var installed = await FlutterGemma.isModelInstalled(model.fileName);
    debugPrint('[Local LLM Smoke] FastVLM installed: $installed');

    if (!installed) {
      await service.ensureSelectedModelAvailable(
        allowDownload: true,
        onDownloadProgress: (progress) {
          if (progress % 10 == 0) {
            debugPrint('[Local LLM Smoke] FastVLM download: $progress%');
          }
        },
      );
      installed = await FlutterGemma.isModelInstalled(model.fileName);
      debugPrint('[Local LLM Smoke] FastVLM installed after download: $installed');
      expect(installed, isTrue);
    }

    final response = await service.runDebugPrompt();
    debugPrint('[Local LLM Smoke] FastVLM response: $response');
    expect(response.trim(), isNotEmpty);
  }, timeout: const Timeout(Duration(minutes: 30)));
}
