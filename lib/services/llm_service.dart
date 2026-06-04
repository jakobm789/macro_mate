import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import '../models/food_analysis_result.dart';
import '../models/local_llm_model.dart';

class LlmModelUnavailableError implements Exception {
  final String message;
  LlmModelUnavailableError(this.message);
  @override
  String toString() => message;
}

class LlmUnsupportedPlatformError implements Exception {
  final String message;
  LlmUnsupportedPlatformError(this.message);
  @override
  String toString() => message;
}

class LlmInputValidationError implements Exception {
  final String message;
  LlmInputValidationError(this.message);
  @override
  String toString() => message;
}

class LlmInferenceError implements Exception {
  final String message;
  LlmInferenceError(this.message);
  @override
  String toString() => message;
}

class LlmJsonParseError implements Exception {
  final String message;
  LlmJsonParseError(this.message);
  @override
  String toString() => message;
}

class LlmService {
  static const Duration _timeout = Duration(minutes: 3);
  static const int _maxImageSizeBytes = 20 * 1024 * 1024;

  final LocalLlmModel selectedModel;
  InferenceModel? _loadedModel;
  bool? _loadedModelSupportsImage;

  LlmService({required this.selectedModel});

  Future<bool> isSelectedModelInstalled() async {
    _ensureSupportedPlatform();
    return FlutterGemma.isModelInstalled(selectedModel.fileName);
  }

  Future<void> ensureSelectedModelAvailable({
    bool allowDownload = false,
    void Function(int progress)? onDownloadProgress,
  }) async {
    _ensureSupportedPlatform();
    final installed = await isSelectedModelInstalled();
    if (installed) {
      return;
    }

    if (!allowDownload) {
      throw LlmModelUnavailableError(
        '${selectedModel.displayName} ist lokal noch nicht installiert. '
        'Starte den Modell-Download in den Einstellungen und versuche es danach erneut.',
      );
    }

    try {
      await FlutterGemma.installModel(
        modelType: selectedModel.modelType,
        fileType: ModelFileType.litertlm,
      )
          .fromNetwork(selectedModel.downloadUrl, foreground: true)
          .withProgress((progress) {
        onDownloadProgress?.call(_downloadProgressPercent(progress));
      }).install();
    } catch (e) {
      throw LlmModelUnavailableError(
        'Download oder Installation von ${selectedModel.displayName} ist fehlgeschlagen: $e',
      );
    }
  }

  Future<String> runDebugPrompt() async {
    await ensureSelectedModelAvailable();
    final model = await _getModel(supportImage: false);
    final chat = await model.createChat(
      temperature: 0.1,
      topK: 1,
      modelType: selectedModel.modelType,
      systemInstruction: 'Antworte kurz auf Deutsch.',
    );

    try {
      await chat.addQueryChunk(
        Message.text(text: 'Antworte nur mit: OK lokal', isUser: true),
      );
      final response = await chat.generateChatResponse().timeout(_timeout);
      return _responseToText(response).trim();
    } finally {
      await chat.close();
    }
  }

  Future<void> warmUp({required bool supportImage}) async {
    await ensureSelectedModelAvailable();
    await _getModel(supportImage: supportImage);
  }

  Future<FoodAnalysisResult> analyzeFood({
    String? imagePath,
    String? textDescription,
  }) async {
    final normalizedText = _normalizeText(textDescription);
    final hasImage = imagePath != null && imagePath.isNotEmpty;
    final hasText = normalizedText != null && normalizedText.isNotEmpty;

    if (!hasImage && !hasText) {
      throw LlmInputValidationError(
        'Bitte gib mindestens ein Foto oder eine Beschreibung ein.',
      );
    }
    if (hasImage && !selectedModel.supportsVision) {
      throw LlmInputValidationError(
        '${selectedModel.displayName} unterstützt keine Bildanalyse.',
      );
    }

    Uint8List? imageBytes;
    if (hasImage) {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw LlmInputValidationError('Bild-Datei nicht gefunden.');
      }
      final imageSize = await imageFile.length();
      if (imageSize > _maxImageSizeBytes) {
        throw LlmInputValidationError(
          'Bild ist zu groß (${(imageSize / 1024 / 1024).toStringAsFixed(1)} MB). '
          'Maximum: 20 MB.',
        );
      }
      imageBytes = await imageFile.readAsBytes();
    }

    await ensureSelectedModelAvailable();
    final stopwatch = Stopwatch()..start();
    final model = await _getModel(supportImage: hasImage);
    final chat = await model.createChat(
      temperature: 0.2,
      topK: 1,
      supportImage: hasImage,
      modelType: selectedModel.modelType,
      systemInstruction: _buildSystemPrompt(),
      isThinking: selectedModel.reasoningMode,
    );

    try {
      final prompt = _buildFoodPrompt(normalizedText, hasImage: hasImage);
      final message = imageBytes == null
          ? Message.text(text: prompt, isUser: true)
          : Message.withImage(
              text: prompt,
              imageBytes: imageBytes,
              isUser: true,
            );

      await chat.addQueryChunk(message);
      final generated = await _generateFoodResponse(chat);
      final result = _parseFoodAnalysis(generated.text).copyWith(
        reasoning: generated.reasoning,
      );
      stopwatch.stop();
      debugPrint(
        '[Local LLM Metrics] op=analyze model=${selectedModel.displayName} '
        'duration_ms=${stopwatch.elapsedMilliseconds} confidence=${result.confidence}',
      );
      return result;
    } on TimeoutException {
      throw LlmInferenceError(
        'Lokale Inferenz hat zu lange gedauert. Wähle ein kleineres Modell oder versuche es erneut.',
      );
    } on LlmJsonParseError {
      rethrow;
    } on LlmInputValidationError {
      rethrow;
    } catch (e) {
      throw LlmInferenceError(
        'Lokale Inferenz mit ${selectedModel.displayName} ist fehlgeschlagen: $e',
      );
    } finally {
      await chat.close();
    }
  }

  Future<InferenceModel> _getModel({required bool supportImage}) async {
    final loadedModel = _loadedModel;
    final loadedSupportsImage = _loadedModelSupportsImage;
    if (loadedModel != null &&
        (loadedSupportsImage == supportImage ||
            (loadedSupportsImage == true && !supportImage))) {
      return loadedModel;
    }

    await _loadedModel?.close();
    _loadedModel = null;
    _loadedModelSupportsImage = null;
    try {
      _loadedModel = await _loadModelWithBackend(
        supportImage: supportImage,
        backend: PreferredBackend.gpu,
      );
      _loadedModelSupportsImage = supportImage;
      return _loadedModel!;
    } catch (gpuError) {
      try {
        _loadedModel = await _loadModelWithBackend(
          supportImage: supportImage,
          backend: PreferredBackend.cpu,
        );
        _loadedModelSupportsImage = supportImage;
        return _loadedModel!;
      } catch (cpuError) {
        throw LlmInferenceError(
          'Modell konnte nicht geladen werden. Prüfe, ob das Gerät genug RAM '
          'hat und Android arm64-v8a nutzt. GPU: $gpuError CPU: $cpuError',
        );
      }
    }
  }

  Future<InferenceModel> _loadModelWithBackend({
    required bool supportImage,
    required PreferredBackend backend,
  }) {
    return FlutterGemmaPlugin.instance.createModel(
      modelType: selectedModel.modelType,
      fileType: ModelFileType.litertlm,
      maxTokens: selectedModel.maxTokens,
      preferredBackend: backend,
      supportImage: supportImage,
      maxNumImages: supportImage ? 1 : null,
    );
  }

  int _downloadProgressPercent(dynamic progress) {
    if (progress is int) {
      return progress;
    }
    final percentage = _readNumericProperty(progress, 'percentage');
    if (percentage != null) {
      return percentage.round().clamp(0, 100);
    }
    final overallProgress = _readNumericProperty(progress, 'overallProgress');
    if (overallProgress != null) {
      return overallProgress.round().clamp(0, 100);
    }
    return 0;
  }

  num? _readNumericProperty(dynamic object, String propertyName) {
    try {
      final value = propertyName == 'percentage'
          ? (object as dynamic).percentage
          : (object as dynamic).overallProgress;
      return value is num ? value : null;
    } catch (_) {
      return null;
    }
  }

  String _responseToText(ModelResponse response) {
    if (response is TextResponse) {
      return response.token;
    }
    return response.toString();
  }

  Future<_GeneratedFoodResponse> _generateFoodResponse(
    InferenceChat chat,
  ) async {
    if (!selectedModel.reasoningMode) {
      final response = await chat.generateChatResponse().timeout(_timeout);
      return _GeneratedFoodResponse(text: _responseToText(response));
    }

    final textBuffer = StringBuffer();
    final reasoningBuffer = StringBuffer();
    await for (final response in chat.generateChatResponseAsync().timeout(
          _timeout,
        )) {
      switch (response) {
        case TextResponse():
          textBuffer.write(response.token);
        case ThinkingResponse():
          reasoningBuffer.write(response.content);
        case FunctionCallResponse():
        case ParallelFunctionCallResponse():
          break;
      }
    }

    return _GeneratedFoodResponse(
      text: textBuffer.toString(),
      reasoning: _normalizeReasoning(reasoningBuffer.toString()),
    );
  }

  String? _normalizeReasoning(String reasoning) {
    final cleaned = reasoning
        .replaceAll(RegExp(r'<\|channel>thought\s*'), '')
        .replaceAll('<channel|>', '')
        .replaceAll(RegExp(r'</?think>'), '')
        .trim();
    if (cleaned.isEmpty) {
      return null;
    }
    return cleaned;
  }

  String? _normalizeText(String? text) {
    final trimmed = text?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  FoodAnalysisResult _parseFoodAnalysis(String rawText) {
    final jsonText = _extractJsonObject(rawText);
    try {
      final decoded = jsonDecode(jsonText) as Map<String, dynamic>;
      return FoodAnalysisResult.fromJson(decoded);
    } on FormatException catch (e) {
      throw LlmJsonParseError(
        'Die lokale Modellantwort war kein gültiges JSON: ${e.message}',
      );
    } on TypeError {
      throw LlmJsonParseError(
        'Die lokale Modellantwort hatte nicht das erwartete JSON-Format.',
      );
    }
  }

  String _extractJsonObject(String rawText) {
    final trimmed = rawText.trim();
    final fenced = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
    ).firstMatch(trimmed);
    final candidate = fenced?.group(1)?.trim() ?? trimmed;
    final start = candidate.indexOf('{');
    final end = candidate.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw LlmJsonParseError(
        'Die lokale Modellantwort enthielt kein JSON-Objekt.',
      );
    }
    return candidate.substring(start, end + 1);
  }

  String _buildFoodPrompt(String? textDescription, {required bool hasImage}) {
    final buffer = StringBuffer();
    if (hasImage) {
      buffer.writeln(
        'Analysiere das angehängte Bild eines Lebensmittels/Gerichts.',
      );
    }
    if (textDescription != null && textDescription.isNotEmpty) {
      buffer.writeln('Zusätzliche Beschreibung: $textDescription');
    }
    if (!hasImage) {
      buffer.writeln('Analysiere diese Lebensmittelbeschreibung.');
    }
    buffer.writeln('Gib ausschließlich das JSON-Objekt aus.');
    return buffer.toString();
  }

  String _buildSystemPrompt() {
    if (!selectedModel.reasoningMode) {
      return _systemPrompt;
    }
    return '$_systemPrompt\n'
        'Reasoning-Modus: Nutze den Thinking-Modus für eine sorgfältige '
        'Prüfung von Bildinhalt, Portionsgröße und Makros. Gib im finalen '
        'Antwortkanal weiterhin ausschließlich das JSON-Objekt aus.';
  }

  void _ensureSupportedPlatform() {
    if (kIsWeb) {
      throw LlmUnsupportedPlatformError(
        'Lokale Vision-Inferenz mit .litertlm ist in dieser App aktuell nur für Android aktiviert.',
      );
    }
    if (!Platform.isAndroid) {
      throw LlmUnsupportedPlatformError(
        'Lokale Vision-Inferenz ist aktuell nur für Android aktiviert.',
      );
    }
  }

  Future<void> dispose() async {
    await _loadedModel?.close();
    _loadedModel = null;
    _loadedModelSupportsImage = null;
  }
}

class _GeneratedFoodResponse {
  final String text;
  final String? reasoning;

  const _GeneratedFoodResponse({
    required this.text,
    this.reasoning,
  });
}

const String _systemPrompt = '''
Du bist ein Ernährungsexperte und Lebensmittel-Analyst.
Analysiere Bild und/oder Text und schätze die Nährwerte.

WICHTIG: Gib alle Nährwerte für die GESAMTE sichtbare Portion an.
Schätze außerdem das Gesamtgewicht der sichtbaren Portion in Gramm.

Antworte AUSSCHLIESSLICH mit einem JSON-Objekt in folgendem Format:
{
  "name": "Name des Lebensmittels/Gerichts",
  "brand": "Marke falls erkennbar, sonst 'Unbekannt'",
  "estimated_weight_grams": 350,
  "total_calories": 525,
  "total_protein": 42.0,
  "total_carbs": 64.8,
  "total_fat": 11.2,
  "total_sugar": 7.4,
  "confidence": 0.85,
  "notes": "Kurze Erklärung zur Schätzung"
}

Regeln:
- "confidence" ist ein Wert zwischen 0.0 und 1.0.
- Bei unklaren Bildern oder vagen Beschreibungen: confidence < 0.7.
- Alle Nährwerte als Zahlen, keine Strings.
- Gewicht in Gramm als ganze Zahl.
- Kalorien als ganze Zahl für die gesamte Portion.
- Makros als Dezimalzahlen mit einer Nachkommastelle für die gesamte Portion.
- Bei reiner Textbeschreibung ohne Mengenangabe: Standardportion schätzen.
- Sprache: Deutsch für name und notes.
''';
