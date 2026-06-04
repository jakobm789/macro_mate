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

  testWidgets('Comprehensive Local LLM Benchmark, Switching, and Edge Cases',
      (WidgetTester tester) async {
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint(
          '[Benchmark] Skipping benchmark: Not running on Android device');
      return;
    }

    final logNotifier = ValueNotifier<List<String>>([]);
    final stepNotifier = ValueNotifier<String>('Initialisiere Test...');

    // Pump progress UI on the device screen
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: Colors.teal,
          colorScheme: const ColorScheme.dark(
            primary: Colors.teal,
            secondary: Colors.tealAccent,
            surface: Color(0xFF1E1E1E),
          ),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('KI-Benchmark Live-Status'),
            backgroundColor: const Color(0xFF1E1E1E),
            centerTitle: true,
          ),
          body: ValueListenableBuilder<List<String>>(
            valueListenable: logNotifier,
            builder: (context, currentLogs, _) {
              return ValueListenableBuilder<String>(
                valueListenable: stepNotifier,
                builder: (context, activeStep, _) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          color: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side:
                                const BorderSide(color: Colors.teal, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.tealAccent),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    activeStep,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Test-Logs / Ergebnisse:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.tealAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: ListView.builder(
                              itemCount: currentLogs.length,
                              itemBuilder: (context, index) {
                                final text = currentLogs[index];
                                Color textColor = Colors.white70;
                                if (text.startsWith('===') ||
                                    text.startsWith('---')) {
                                  textColor = Colors.tealAccent;
                                } else if (text.contains('FEHLER') ||
                                    text.contains('fehlgeschlagen')) {
                                  textColor = Colors.redAccent;
                                } else if (text.contains('Erfolgreich') ||
                                    text.contains('Antwort:')) {
                                  textColor = Colors.greenAccent;
                                } else if (text.startsWith('Schritt') ||
                                    text.contains('[Edge Case')) {
                                  textColor = Colors.white;
                                }
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: text.startsWith('===') ||
                                              text.startsWith('Schritt')
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: textColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    void updateProgress(String msg, {String? activeStep}) {
      debugPrint(msg);
      logNotifier.value = [...logNotifier.value, msg];
      if (activeStep != null) {
        stepNotifier.value = activeStep;
      }
    }

    updateProgress('Initializing FlutterGemma...',
        activeStep: 'Initialisiere FlutterGemma...');
    await FlutterGemma.initialize();

    updateProgress(
        '============================================================');
    updateProgress(
        '           LOCAL KI-MODELL BENCHMARK & SWITCH-TEST          ');
    updateProgress(
        '============================================================');

    // 1. ZUERST ALLE MODELLE SICHERSTELLEN (Download falls nicht da)
    updateProgress('Prüfe installierte Modelle...',
        activeStep: 'Schritt 1/4: Prüfe/Downloade Modelle');
    for (final model in LocalLlmModel.supported) {
      var isInstalled = await FlutterGemma.isModelInstalled(model.fileName);
      updateProgress(
          'Prüfe ${model.displayName}... Status: ${isInstalled ? "Installiert" : "Nicht installiert"}');

      if (!isInstalled) {
        updateProgress(
            '  -> Starte automatischen Download für ${model.displayName}... Bitte warten.');
        final downloadService = LlmService(selectedModel: model);
        try {
          await downloadService.ensureSelectedModelAvailable(
            allowDownload: true,
            onDownloadProgress: (progress) {
              if (progress % 10 == 0) {
                updateProgress(
                    '     Download ${model.displayName}: $progress%');
              }
            },
          );
        } catch (e) {
          updateProgress('  -> Download fehlgeschlagen: $e');
        } finally {
          await downloadService.dispose();
        }
      }
    }

    updateProgress(
        '\n============================================================');
    updateProgress(
        '             2. MODELL-WECHSEL BENCHMARK (SEQUENCE)         ');
    updateProgress(
        '============================================================');

    // FastVLM is desktop-only in flutter_gemma 0.16.4 and produces template
    // token loops on Android, so this benchmark only covers mobile-supported models.
    final switchSequence = [
      (
        model: LocalLlmModel.byId(LocalLlmModelId.gemma4E2b),
        forcedBackend: PreferredBackend.gpu,
        label: 'Gemma 4 E2B (GPU)'
      ),
      (
        model: LocalLlmModel.byId(LocalLlmModelId.gemma4E4b),
        forcedBackend: PreferredBackend.gpu,
        label: 'Gemma 4 E4B (GPU)'
      ),
      (
        model: LocalLlmModel.byId(LocalLlmModelId.gemma4E4bReasoning),
        forcedBackend: PreferredBackend.gpu,
        label: 'Gemma 4 E4B Reasoning (GPU)'
      ),
      (
        model: LocalLlmModel.byId(LocalLlmModelId.gemma4E2b),
        forcedBackend: PreferredBackend.gpu,
        label: 'Gemma 4 E2B (GPU) (Switch Back)'
      ),
    ];

    for (int i = 0; i < switchSequence.length; i++) {
      final step = switchSequence[i];
      updateProgress(
          'Schritt ${i + 1}/${switchSequence.length}: Lade ${step.label}...',
          activeStep:
              'Schritt 2/4: Modellwechsel (${i + 1}/${switchSequence.length})');
      final service = LlmService(
          selectedModel: step.model, forcedBackend: step.forcedBackend);

      final t = Stopwatch()..start();
      await service.warmUp(supportImage: step.model.supportsVision);
      t.stop();

      updateProgress(
          '  -> Geladen in: ${t.elapsedMilliseconds} ms (${service.loadedBackendName})');
      await service.dispose();
      updateProgress(
          '------------------------------------------------------------');
    }

    updateProgress(
        '\n============================================================');
    updateProgress(
        '     3. INFERENZ & TIMINGS MIT STANDARD-BACKEND ROUTING      ');
    updateProgress(
        '============================================================');

    for (final model in LocalLlmModel.supported) {
      final isInstalled = await FlutterGemma.isModelInstalled(model.fileName);
      if (!isInstalled) {
        updateProgress(
            'Model ${model.displayName} übersprungen: Nicht installiert.');
        continue;
      }

      updateProgress(
          'Benchmark für Modell: ${model.displayName} (Standard-Backend)',
          activeStep: 'Schritt 3/4: Inferenz & Timings (${model.displayName})');
      // forcedBackend: null enables auto-routing (CPU for E4B, GPU for others)
      final service = LlmService(selectedModel: model, forcedBackend: null);

      try {
        await service.dispose(); // Kaltstart erzwingen

        // Warmup Ladezeit
        final loadWatch = Stopwatch()..start();
        await service.warmUp(supportImage: model.supportsVision);
        loadWatch.stop();
        final backend = service.loadedBackendName;
        updateProgress(
            '  - Warmup/Laden: ${loadWatch.elapsedMilliseconds} ms (Backend: $backend)');

        // Kurze Inferenz
        final shortWatch = Stopwatch()..start();
        final shortResponse = await service.runDebugPrompt();
        shortWatch.stop();
        updateProgress(
            '  - Kurze Inferenz ("OK"): ${shortWatch.elapsedMilliseconds} ms');
        updateProgress(
            '    Antwort: "${shortResponse.replaceAll("\n", " ").trim()}"');

        // Nährwert Inferenz (Simuliert)
        final foodWatch = Stopwatch()..start();
        final foodResponse = await service.runMockFoodPrompt();
        foodWatch.stop();
        updateProgress(
            '  - Nährwert Inferenz: ${foodWatch.elapsedMilliseconds} ms');
        updateProgress(
            '    Antwort: "${foodResponse.replaceAll("\n", " ").trim()}"');
      } catch (e) {
        updateProgress('  - FEHLER bei ${model.displayName}: $e');
      } finally {
        await service.dispose();
        updateProgress(
            '------------------------------------------------------------');
      }
    }

    updateProgress(
        '\n============================================================');
    updateProgress(
        '                    4. EDGE CASES TESTS                     ');
    updateProgress(
        '============================================================');

    // Erstelle ein Mock-Bild für Vision Edge-Cases (1x1 Pixel transparent PNG)
    final mockImageBytes = Uint8List.fromList([
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
    final tempFile = File('${Directory.systemTemp.path}/mock_food.png');
    await tempFile.writeAsBytes(mockImageBytes);
    final mockImagePath = tempFile.path;
    updateProgress('Mock-Bild erstellt unter: $mockImagePath',
        activeStep: 'Schritt 4/4: Edge Cases');

    final modelSmall = LocalLlmModel.byId(LocalLlmModelId.gemma4E2b);
    final modelGemma = LocalLlmModel.byId(LocalLlmModelId.gemma4E4b);

    // Edge Case A: Vision-Inferenz auf kleinstem mobile-supported Modell mit Mock-Bild
    updateProgress(
        '\n[Edge Case A] Vision-Inferenz (Bild + Prompt) auf Gemma 4 E2B (GPU)...');
    final vlmService = LlmService(
        selectedModel: modelSmall, forcedBackend: PreferredBackend.gpu);
    try {
      final watch = Stopwatch()..start();
      final result = await vlmService.analyzeFood(
        imagePath: mockImagePath,
        textDescription: 'Schätze Nährwerte für Apfel 150g',
      );
      watch.stop();
      updateProgress(
          '  -> Erfolgreich ausgeführt in: ${watch.elapsedMilliseconds} ms!');
      updateProgress('  -> Ergebnis Name: "${result.name}"');
      updateProgress(
          '  -> Nährwert-Ergebnis: ${result.totalCalories} kcal, ${result.totalProtein}g P, ${result.totalCarbs}g C, ${result.totalFat}g F');
      expect(result.name, isNotEmpty);
    } catch (e) {
      updateProgress('  -> Vision-Inferenz failed: $e');
    } finally {
      await vlmService.dispose();
    }

    // Edge Case B: Empty Input Validation
    updateProgress(
        '\n[Edge Case B] Validierungs-Edge-Case (kein Bild, kein Text)...');
    final validationService = LlmService(
        selectedModel: modelGemma, forcedBackend: PreferredBackend.cpu);
    try {
      await validationService.analyzeFood(
          imagePath: null, textDescription: null);
      fail('analyzeFood hätte werfen müssen!');
    } catch (e) {
      updateProgress('  -> Erfolgreich abgefangen (Erwarteter Fehler): $e');
      expect(e.toString(), contains('Foto oder eine Beschreibung'));
    } finally {
      await validationService.dispose();
    }

    // Edge Case C: Text-only Inferenz auf VLM - Testet den Dummy-Bild-Fallback.
    updateProgress(
        '\n[Edge Case C] Text-only Inferenz auf Gemma 4 E2B (GPU) mit Dummy-Bild-Fallback...');
    final textVlmService = LlmService(
        selectedModel: modelSmall, forcedBackend: PreferredBackend.gpu);
    try {
      final watch = Stopwatch()..start();
      final result = await textVlmService.analyzeFood(
        imagePath: null,
        textDescription: 'Schätze Nährwerte für Banane 120g',
      );
      watch.stop();
      updateProgress(
          '  -> Erfolgreich ausgeführt in: ${watch.elapsedMilliseconds} ms (Kein Infinite-Loop!)');
      updateProgress('  -> Ergebnis Name: "${result.name}"');
      updateProgress(
          '  -> Nährwerte: ${result.totalCalories} kcal, ${result.totalCarbs}g C');
      expect(result.name, isNotEmpty);
      expect(watch.elapsedMilliseconds < 30000, true,
          reason: 'Text-only Inferenz auf VLM sollte schnell beendet sein.');
    } catch (e) {
      updateProgress('  -> Text-only VLM Inferenz failed: $e');
    } finally {
      await textVlmService.dispose();
    }

    // Edge Case D: Large Text Input Truncation (3000 Zeichen -> 1200 / 600 Zeichen)
    updateProgress(
        '\n[Edge Case D] Maximaler Text-Input (>3000 Zeichen) auf Gemma 4 E4B (CPU)...');
    final largeTextService = LlmService(
        selectedModel: modelGemma, forcedBackend: PreferredBackend.cpu);
    try {
      final extraLargeText = 'Apfel ' * 600; // 600 * 6 = 3600 Zeichen
      updateProgress('  -> Sende Text-Länge: ${extraLargeText.length} Zeichen');
      final watch = Stopwatch()..start();
      final result = await largeTextService.analyzeFood(
        imagePath: null,
        textDescription: extraLargeText,
      );
      watch.stop();
      updateProgress(
          '  -> Erfolgreich ausgeführt in: ${watch.elapsedMilliseconds} ms!');
      updateProgress('  -> Ergebnis Name: "${result.name}"');
      expect(result.name, isNotEmpty);
    } catch (e) {
      updateProgress('  -> Inferenz failed: $e');
    } finally {
      await largeTextService.dispose();
    }

    // Edge Case E: Graceful handling of invalid JSON / Parsing Error
    updateProgress(
        '\n[Edge Case E] Teste Fehlerbehandlung bei unvollständigem JSON...');
    final errorParseService = LlmService(
        selectedModel: modelGemma, forcedBackend: PreferredBackend.cpu);
    try {
      try {
        await errorParseService.analyzeFood(
            imagePath: null, textDescription: null); // wirft ValidationError
      } catch (e) {
        expect(e, isA<LlmInputValidationError>());
      }

      try {
        errorParseService
            .parseFoodAnalysis('{"name": "Apfel", "total_calories": 50');
        fail('Hätte FormatException / LlmJsonParseError werfen müssen!');
      } catch (e) {
        updateProgress(
            '  -> Erfolgreich abgefangen (Erwarteter JSON Fehler): $e');
        expect(
            e.toString(),
            anyOf(
                contains('kein gültiges JSON'), contains('kein JSON-Objekt')));
      }
    } finally {
      await errorParseService.dispose();
    }

    // Edge Case F: Concurrent Requests busy lock
    updateProgress(
        '\n[Edge Case F] Teste Blockierung paralleler Analysen (Busy Lock)...');
    final concurrentService1 = LlmService(
        selectedModel: modelSmall, forcedBackend: PreferredBackend.gpu);
    final concurrentService2 = LlmService(
        selectedModel: modelSmall, forcedBackend: PreferredBackend.gpu);

    try {
      // Starte die erste Inferenz asynchron
      final future1 = concurrentService1.analyzeFood(
          imagePath: mockImagePath, textDescription: 'Apfel 150g');

      // Warte 50ms und starte die zweite Inferenz parallel
      await Future.delayed(const Duration(milliseconds: 50));
      updateProgress('  -> Starte parallele Inferenz auf zweitem Service...');

      try {
        await concurrentService2.analyzeFood(
            imagePath: mockImagePath, textDescription: 'Banane 120g');
        fail('Die zweite parallele Inferenz hätte geblockt werden müssen!');
      } catch (e) {
        updateProgress(
            '  -> Erfolgreich abgefangen (Zweite Inferenz blockiert): $e');
        expect(e.toString(), contains('bereits eine KI-Analyse'));
      }

      // Warte auf die erste Inferenz
      try {
        final res1 = await future1;
        updateProgress('  -> Erste Inferenz fertig: ${res1.name}');
      } catch (e) {
        updateProgress(
            '  -> Erste Inferenz fertig (mit Fehler/Qualitäts-Exception): $e');
      }
    } finally {
      await concurrentService1.dispose();
      await concurrentService2.dispose();
    }

    updateProgress(
        '\n============================================================');
    updateProgress(
        '                  BENCHMARK ABGESCHLOSSEN                   ');
    updateProgress(
        '============================================================');
    stepNotifier.value = 'Benchmark Erfolgreich Abgeschlossen!';
    await tester
        .pump(const Duration(seconds: 2)); // Give user time to see completion
  }, timeout: const Timeout(Duration(minutes: 40)));
}
