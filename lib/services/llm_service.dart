import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/core/domain/model_source.dart';

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

  static final Uint8List _dummyPngBytes = Uint8List.fromList([
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    0,
    0,
    0,
    13,
    73,
    72,
    68,
    82,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    1,
    8,
    6,
    0,
    0,
    0,
    31,
    21,
    196,
    137,
    0,
    0,
    0,
    11,
    73,
    68,
    65,
    84,
    120,
    1,
    99,
    96,
    0,
    2,
    0,
    0,
    5,
    0,
    1,
    26,
    10,
    43,
    66,
    0,
    0,
    0,
    0,
    73,
    69,
    78,
    68,
    174,
    66,
    96,
    130
  ]);

  static bool _isProcessing = false;

  final LocalLlmModel selectedModel;
  PreferredBackend? forcedBackend;
  InferenceModel? _loadedModel;
  bool? _loadedModelSupportsImage;
  PreferredBackend? loadedBackend;

  String get loadedBackendName {
    if (loadedBackend == PreferredBackend.gpu) return 'GPU';
    if (loadedBackend == PreferredBackend.cpu) return 'CPU';
    return 'Unbekannt';
  }

  LlmService({required this.selectedModel, this.forcedBackend});

  Future<bool> isSelectedModelInstalled() async {
    _ensureSupportedPlatform();
    return FlutterGemma.isModelInstalled(selectedModel.fileName);
  }

  void _setActiveModel() {
    final manager = FlutterGemmaPlugin.instance.modelManager;
    final spec = InferenceModelSpec(
      name: selectedModel.fileName,
      modelSource: ModelSource.network(selectedModel.downloadUrl),
      modelType: selectedModel.modelType,
      fileType: ModelFileType.litertlm,
    );
    manager.setActiveModel(spec);
  }

  Future<void> ensureSelectedModelAvailable({
    bool allowDownload = false,
    void Function(int progress)? onDownloadProgress,
  }) async {
    _ensureSupportedPlatform();
    final installed = await isSelectedModelInstalled();
    if (installed) {
      _setActiveModel();
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
    final runWithImage = selectedModel.supportsVision;
    final model = await _getModel(supportImage: runWithImage);
    final chat = await model.createChat(
      temperature: 0.1,
      topK: 1,
      supportImage: runWithImage,
      modelType: selectedModel.modelType,
      systemInstruction: 'Antworte kurz auf Deutsch.',
    );

    try {
      final message = runWithImage
          ? Message.withImage(
              text: 'Antworte nur mit: OK lokal',
              imageBytes: _dummyPngBytes,
              isUser: true)
          : Message.text(text: 'Antworte nur mit: OK lokal', isUser: true);
      await chat.addQueryChunk(message);
      final response = await chat.generateChatResponse().timeout(_timeout);
      return _responseToText(response).trim();
    } finally {
      await chat.close();
    }
  }

  Future<String> runMockFoodPrompt() async {
    await ensureSelectedModelAvailable();
    final runWithImage = selectedModel.supportsVision;
    final model = await _getModel(supportImage: runWithImage);
    final chat = await model.createChat(
      temperature: 0.1,
      topK: 1,
      supportImage: runWithImage,
      modelType: selectedModel.modelType,
      systemInstruction: 'Antworte kurz und präzise.',
    );

    try {
      final message = runWithImage
          ? Message.withImage(
              text: 'Nährwerte für Apfel 150g. Protein, Kohlenhydrate, Fett.',
              imageBytes: _dummyPngBytes,
              isUser: true)
          : Message.text(
              text: 'Nährwerte für Apfel 150g. Protein, Kohlenhydrate, Fett.',
              isUser: true);
      await chat.addQueryChunk(message);
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
    void Function(String partialReasoning)? onReasoningProgress,
    VoidCallback? onInferenceStart,
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

    if (_isProcessing) {
      throw LlmInferenceError(
        'Es läuft bereits eine KI-Analyse. Bitte warte, bis diese abgeschlossen ist.',
      );
    }
    _isProcessing = true;

    try {
      Uint8List? imageBytes;
      bool runWithImage = hasImage;

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
      } else if (selectedModel.supportsVision) {
        // Fallback for VLM models to prevent infinite loops on text-only inputs
        imageBytes = _dummyPngBytes;
        runWithImage = true;
      }

      await ensureSelectedModelAvailable();
      final stopwatch = Stopwatch()..start();
      final model = await _getModel(supportImage: runWithImage);
      final enableThinking = selectedModel.reasoningMode && !runWithImage;
      if (selectedModel.reasoningMode && runWithImage) {
        debugPrint(
          '[Local LLM] Thinking disabled for image analysis because '
          'Gemma 4 LiteRTLM thinking streams do not reliably emit complete '
          'final text for multimodal prompts.',
        );
      }
      onInferenceStart?.call();
      final chat = await model.createChat(
        temperature: 0.2,
        topK: 1,
        supportImage: runWithImage,
        modelType: selectedModel.modelType,
        systemInstruction: _buildSystemPrompt(),
        isThinking: enableThinking,
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
        final generated = await _generateFoodResponse(
          chat,
          onReasoningProgress,
          enableThinking: enableThinking,
        );
        final result = parseFoodAnalysis(generated.text).copyWith(
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
    } finally {
      _isProcessing = false;
    }
  }

  PreferredBackend _getDefaultBackendForModel(LocalLlmModel model) {
    if (model.id == LocalLlmModelId.gemma4E4b ||
        model.id == LocalLlmModelId.gemma4E4bReasoning) {
      return PreferredBackend.cpu;
    }
    return PreferredBackend.gpu;
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
    _setActiveModel();

    final targetBackend = forcedBackend;
    if (targetBackend != null) {
      try {
        _loadedModel = await _loadModelWithBackend(
          supportImage: supportImage,
          backend: targetBackend,
        );
        _loadedModelSupportsImage = supportImage;
        loadedBackend = targetBackend;
        return _loadedModel!;
      } catch (e) {
        throw LlmInferenceError(
          'Erzwungenes Backend $targetBackend fehlgeschlagen: $e',
        );
      }
    }

    final defaultBackend = _getDefaultBackendForModel(selectedModel);
    if (defaultBackend == PreferredBackend.cpu) {
      try {
        _loadedModel = await _loadModelWithBackend(
          supportImage: supportImage,
          backend: PreferredBackend.cpu,
        );
        _loadedModelSupportsImage = supportImage;
        loadedBackend = PreferredBackend.cpu;
        return _loadedModel!;
      } catch (cpuError) {
        throw LlmInferenceError(
          'Modell konnte auf CPU nicht geladen werden: $cpuError',
        );
      }
    } else {
      try {
        _loadedModel = await _loadModelWithBackend(
          supportImage: supportImage,
          backend: PreferredBackend.gpu,
        );
        _loadedModelSupportsImage = supportImage;
        loadedBackend = PreferredBackend.gpu;
        return _loadedModel!;
      } catch (gpuError) {
        try {
          _loadedModel = await _loadModelWithBackend(
            supportImage: supportImage,
            backend: PreferredBackend.cpu,
          );
          _loadedModelSupportsImage = supportImage;
          loadedBackend = PreferredBackend.cpu;
          return _loadedModel!;
        } catch (cpuError) {
          throw LlmInferenceError(
            'Modell konnte nicht geladen werden. GPU: $gpuError CPU: $cpuError',
          );
        }
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

  Future<_GeneratedFoodResponse> _generateFoodResponse(InferenceChat chat,
      void Function(String partialReasoning)? onReasoningProgress,
      {required bool enableThinking}) async {
    if (!enableThinking) {
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
          if (onReasoningProgress != null) {
            onReasoningProgress(
                _normalizeReasoning(reasoningBuffer.toString()) ?? '');
          }
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
    final maxLen = (selectedModel.id == LocalLlmModelId.gemma4E4b ||
            selectedModel.id == LocalLlmModelId.gemma4E4bReasoning)
        ? 1200
        : 600;
    if (trimmed.length > maxLen) {
      return trimmed.substring(0, maxLen);
    }
    return trimmed;
  }

  FoodAnalysisResult parseFoodAnalysis(String rawText) {
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

    buffer.writeln(
      'Gib ausschließlich ein kompaktes JSON-Objekt aus: keine Markdown-Codefences, '
      'keine Erklärungen, keine Zeilen vor oder nach JSON. Halte notes leer oder sehr kurz.',
    );
    return buffer.toString();
  }

  String _buildSystemPrompt() {
    return '$_systemPrompt\n'
        'WICHTIG: Gib im finalen Antwortkanal ausschließlich ein kompaktes JSON-Objekt aus. '
        'Keine Markdown-Codefences, kein Fließtext, keine Erklärungen vor oder nach JSON.';
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
Du bist ein hochpräziser digitaler Ernährungsberater und Experte für visuelle Lebensmittel-Analysen.
Deine Aufgabe ist es, Fotos und Beschreibungen von Mahlzeiten zu analysieren, die Zutaten zu identifizieren und das Gesamtgewicht sowie die Nährwerte (Kalorien, Eiweiß, Kohlenhydrate, Fett, Zucker) der GESAMTEN abgebildeten Portion zu schätzen.

### ANALYSE-SCHRITTE (Nutze diese Struktur für dein Denken/deinen Text)
1. **Zutaten-Identifikation**: Welche sichtbaren und impliziten Zutaten (z. B. Butter, Öl) enthält die Mahlzeit?
2. **Maßstab & Volumen**: Nutze sichtbare Referenzobjekte (Gabel, Tellergröße, Gläser) zur Volumenbestimmung.
3. **Gewichtsschätzung (in Gramm)**: Schätze das Gewicht jeder Zutat einzeln basierend auf Dichte und Größe und summiere sie auf.
4. **Nährwert-Zuweisung & Versteckte Fette**: Weise Nährwerte/100g zu. Addiere standardmäßig +5-10g Fett für gebratene/sautierte Speisen wegen Bratölen.
5. **Verzerrungskorrektur**: LLMs unterschätzen große Portionen oft systematisch. Sei bei großen Portionen eher konservativ und passe die Werte nach oben an.

### FORMAT DER ANTWORT
Am Ende deiner Antwort (bzw. als alleiniges Ergebnis im finalen Textkanal bei aktivem Reasoning) musst du das Ergebnis als gültiges JSON-Objekt ausgeben:
```json
{
  "name": "Name des Lebensmittels/Gerichts (Deutsch)",
  "brand": "Marke falls erkennbar, sonst 'Unbekannt'",
  "estimated_weight_grams": 350,
  "total_calories": 525,
  "total_protein": 42.0,
  "total_carbs": 64.8,
  "total_fat": 11.2,
  "total_sugar": 7.4,
  "confidence": 0.85,
  "ingredients": [
    {
      "name": "Zutat",
      "grams": 100,
      "calories": 150,
      "protein": 8.0,
      "carbs": 20.0,
      "fat": 3.0,
      "sugar": 2.0
    }
  ],
  "notes": "Kurze Zusammenfassung der Annahmen, keine zweite Kalorienrechnung (Deutsch)."
}
```

### REGELN:
- **Zahlenformate**: Alle Nährwerte als Zahlen. Gewicht und Kalorien als ganze Zahlen. Makronährstoffe als Dezimalzahlen (double) mit einer Nachkommastelle.
- **Konfidenz (confidence)**:
  - 0.85 - 1.00: Sehr deutliches Bild, flacher Teller, keine überlappenden Schichten, einfache Zutaten.
  - 0.70 - 0.84: Standardbild, leichte Überlappung, oder eine detaillierte Textbeschreibung mit Mengenangaben.
  - 0.50 - 0.69: Versteckte Zutaten (z. B. Auflauf, Suppe, Sandwich, Soßen), ungünstiger Kamerawinkel, oder vage Textbeschreibung.
  - < 0.50: Sehr unklares Bild, starke Überlappung, schlechte Belichtung, oder sehr vage Textbeschreibung.
- **Textbeschreibungen**: Wenn kein Bild vorhanden ist, schätze eine Standardportion basierend auf der Textbeschreibung und passe das Gewicht entsprechend an.
- **Sprache**: name, notes und alle Texte müssen auf Deutsch verfasst sein.
- **Zutaten-Summe**: ingredients muss alle wesentlichen Zutaten enthalten. total_calories, total_protein, total_carbs, total_fat und total_sugar müssen exakt der Summe der ingredients-Werte entsprechen. Wenn du z. B. 200g Haferflocken mit ca. 750 kcal annimmst, darf total_calories nicht darunter liegen.
- **Kompakte Ausgabe**: Schreibe minifiziertes oder sehr kompaktes JSON ohne Markdown-Codefence. Keine langen Sätze. Keine Erklärung außerhalb von JSON.
- **Notes**: Wiederhole in notes keine Zahlenrechnung. Verwende notes nur für kurze Unsicherheiten/Annahmen, maximal 80 Zeichen, sonst leerer String.
- **Explizite Mengenangaben**: Wenn die Beschreibung konkrete Grammangaben enthält, musst du diese Mengen übernehmen und jede explizit genannte Zutat einzeln in ingredients ausgeben. Ignoriere diese Angaben nicht zugunsten einer kleineren Standardportion.
- **Plausibilitätsanker**: Nutze typische Richtwerte: Haferflocken ca. 370-390 kcal/100g, 12-14g Protein/100g, 58-68g Kohlenhydrate/100g und 6-8g Fett/100g; Proteinpulver ca. 360-400 kcal/100g und 70-85g Protein/100g; Banane ca. 85-95 kcal/100g; Apfel ca. 50-55 kcal/100g. Gesamtwerte dürfen diese bekannten Größenordnungen nicht massiv unterschreiten.
- **Makro-Konsistenz**: Wenn du ingredients angibst, muss jedes ingredient auch bei Protein, Kohlenhydraten und Fett zur Grammmenge passen. Beispiel: 200g Haferflocken haben nicht 13g Protein, sondern etwa 24-28g Protein.
''';
