import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:macro_mate/models/local_llm_model.dart';
import 'package:macro_mate/services/llm_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Gemma 4 E2B loads through LiteRT-LM FFI on Android', (_) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    await FlutterGemma.initialize();

    final model = LocalLlmModel.byId(LocalLlmModelId.gemma4E2b);
    final service = LlmService(selectedModel: model);
    addTearDown(service.dispose);

    var installed = await FlutterGemma.isModelInstalled(model.fileName);
    debugPrint('[Local LLM Smoke] ${model.displayName} installed: $installed');

    if (!installed) {
      await service.ensureSelectedModelAvailable(
        allowDownload: true,
        onDownloadProgress: (progress) {
          if (progress % 10 == 0) {
            debugPrint(
                '[Local LLM Smoke] ${model.displayName} download: $progress%');
          }
        },
      );
      installed = await FlutterGemma.isModelInstalled(model.fileName);
      debugPrint(
          '[Local LLM Smoke] ${model.displayName} installed after download: $installed');
      expect(installed, isTrue);
    }

    final response = await service.runDebugPrompt();
    debugPrint('[Local LLM Smoke] ${model.displayName} response: $response');
    expect(response.trim(), isNotEmpty);
  }, timeout: const Timeout(Duration(minutes: 30)));
}
