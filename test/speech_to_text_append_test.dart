import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text_platform_interface/speech_to_text_platform_interface.dart';
import 'package:speech_to_text_platform_interface/method_channel_speech_to_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:macro_mate/models/app_state.dart';
import 'package:macro_mate/models/local_llm_model.dart';
import 'package:macro_mate/widgets/ai_food_sheet.dart';
import 'package:flutter/services.dart';

/// Helper: build a JSON speech result string.
///
/// ResultType values from the speech_to_text package:
///   0 = partial
///   1 = intermediate
///   2 = finalResult
String _speechResult(String text,
    {double confidence = 0.9, bool isFinal = false}) {
  return jsonEncode({
    'alternates': [
      {'recognizedWords': text, 'confidence': confidence}
    ],
    'resultType': isFinal ? 2 : 0, // 2 = finalResult, 0 = partial
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Speech-to-Text Pause Append Test', () {
    late MethodChannelSpeechToText platform;
    late AppState appState;

    setUp(() {
      platform = SpeechToTextPlatform.instance as MethodChannelSpeechToText;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        platform.channel,
        (MethodCall methodCall) async {
          debugPrint(
              '[Mock STT] ${methodCall.method}(${methodCall.arguments})');
          if (methodCall.method == 'has_permission') return true;
          if (methodCall.method == 'initialize') return true;
          if (methodCall.method == 'listen') return true;
          if (methodCall.method == 'stop') return null;
          if (methodCall.method == 'cancel') return null;
          if (methodCall.method == 'locales') return ['de_DE:Deutsch'];
          return null;
        },
      );

      appState = AppState();
      appState.selectedLocalLlmModel =
          LocalLlmModel.byId(LocalLlmModelId.fastVlm05b);
      appState.installedLocalModelFiles = {
        appState.selectedLocalLlmModel.fileName
      };
      appState.markInitialized();
    });

    tearDown(() async {
      await stt.SpeechToText().cancel();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform.channel, null);
    });

    /// Pump the AiFoodSheet into a minimal widget tree.
    Future<void> pumpSheet(WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: Scaffold(
              body: AiFoodSheet(mealName: 'Frühstück'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    /// Cleanly tear down the sheet to avoid pending timer assertions.
    Future<void> tearDownSheet(WidgetTester tester) async {
      await stt.SpeechToText().cancel();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    }

    /// Wait for the restart delay to complete (real time in runAsync context)
    /// and pump the widget tree to process any updates.
    Future<void> waitForRestart(WidgetTester tester) async {
      // The restart delay is 350ms. Wait slightly longer to ensure it completes.
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pump();
    }

    // ──────────────────────────────────────────────────────────────
    // Test 1: Basic pause-and-resume appends correctly
    // ──────────────────────────────────────────────────────────────
    testWidgets('Speech inputs across pauses append correctly (no overwrite)',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await pumpSheet(tester);

        // Start recording
        final recordButton = find.text('Aufnehmen');
        expect(recordButton, findsOneWidget);
        await tester.tap(recordButton);
        await tester.pump();
        expect(find.text('OK'), findsOneWidget);

        // ── Session 1: user says "200 Gramm Reis" ──
        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'listening'));
        await tester.pump();

        // Partial result
        await platform.processMethodCall(
          MethodCall('textRecognition', _speechResult('200 Gramm Reis')),
        );
        await tester.pump();
        expect(find.text('200 Gramm Reis'), findsOneWidget);

        // Final result
        await platform.processMethodCall(
          MethodCall('textRecognition',
              _speechResult('200 Gramm Reis', isFinal: true)),
        );
        await tester.pump();

        // ── Pause: engine fires notListening + done ──
        await platform.processMethodCall(
            const MethodCall('notifyStatus', 'notListening'));
        await tester.pump();
        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'done'));
        await tester.pump();
        // Wait for the restart delay (real time since we're in runAsync)
        await waitForRestart(tester);

        // ── Session 2: user says "mit Soße" ──
        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'listening'));
        await tester.pump();

        await platform.processMethodCall(
          MethodCall('textRecognition', _speechResult('mit Soße')),
        );
        await tester.pump();

        // ✅ Should be appended, NOT overwritten
        expect(find.text('200 Gramm Reis mit Soße'), findsOneWidget);

        // Final result for session 2
        await platform.processMethodCall(
          MethodCall(
              'textRecognition', _speechResult('mit Soße', isFinal: true)),
        );
        await tester.pump();

        // Still correct
        expect(find.text('200 Gramm Reis mit Soße'), findsOneWidget);

        await tearDownSheet(tester);
      });
    });

    // ──────────────────────────────────────────────────────────────
    // Test 2: Engine delivers cumulative text (deduplication)
    // ──────────────────────────────────────────────────────────────
    testWidgets('Cumulative speech results are deduplicated correctly',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await pumpSheet(tester);

        final recordButton = find.text('Aufnehmen');
        await tester.tap(recordButton);
        await tester.pump();

        // ── Session 1: "Ich hatte zwei Eier" ──
        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'listening'));
        await tester.pump();
        await platform.processMethodCall(
          MethodCall('textRecognition',
              _speechResult('Ich hatte zwei Eier', isFinal: true)),
        );
        await tester.pump();
        expect(find.text('Ich hatte zwei Eier'), findsOneWidget);

        // ── Pause ──
        await platform.processMethodCall(
            const MethodCall('notifyStatus', 'notListening'));
        await tester.pump();
        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'done'));
        await tester.pump();
        await waitForRestart(tester);

        // ── Session 2: engine delivers CUMULATIVE text ──
        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'listening'));
        await tester.pump();

        // Some engines deliver the full accumulated text including previous session
        await platform.processMethodCall(
          MethodCall('textRecognition',
              _speechResult('Ich hatte zwei Eier und ein Brötchen')),
        );
        await tester.pump();

        // ✅ Should NOT be "Ich hatte zwei Eier Ich hatte zwei Eier und ein Brötchen"
        expect(
            find.text('Ich hatte zwei Eier und ein Brötchen'), findsOneWidget);

        await tearDownSheet(tester);
      });
    });

    // ──────────────────────────────────────────────────────────────
    // Test 3: Multiple pauses maintain full text
    // ──────────────────────────────────────────────────────────────
    testWidgets('Three segments across two pauses all preserved',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await pumpSheet(tester);

        final recordButton = find.text('Aufnehmen');
        await tester.tap(recordButton);
        await tester.pump();

        // ── Session 1: "Eier" ──
        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'listening'));
        await tester.pump();
        await platform.processMethodCall(
          MethodCall('textRecognition', _speechResult('Eier', isFinal: true)),
        );
        await tester.pump();

        // ── Pause 1 ──
        await platform.processMethodCall(
            const MethodCall('notifyStatus', 'notListening'));
        await tester.pump();
        await waitForRestart(tester);

        // ── Session 2: "Reis" ──
        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'listening'));
        await tester.pump();
        await platform.processMethodCall(
          MethodCall('textRecognition', _speechResult('Reis', isFinal: true)),
        );
        await tester.pump();
        expect(find.text('Eier Reis'), findsOneWidget);

        // ── Pause 2 ──
        await platform.processMethodCall(
            const MethodCall('notifyStatus', 'notListening'));
        await tester.pump();
        await waitForRestart(tester);

        // ── Session 3: "Soße" ──
        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'listening'));
        await tester.pump();
        await platform.processMethodCall(
          MethodCall('textRecognition', _speechResult('Soße', isFinal: true)),
        );
        await tester.pump();

        // ✅ All three segments preserved
        expect(find.text('Eier Reis Soße'), findsOneWidget);

        await tearDownSheet(tester);
      });
    });

    // ──────────────────────────────────────────────────────────────
    // Test 4: Double status callbacks don't cause issues
    // ──────────────────────────────────────────────────────────────
    testWidgets('Double notListening+done status does not corrupt text',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await pumpSheet(tester);

        final recordButton = find.text('Aufnehmen');
        await tester.tap(recordButton);
        await tester.pump();

        // ── Session 1 ──
        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'listening'));
        await tester.pump();
        await platform.processMethodCall(
          MethodCall(
              'textRecognition', _speechResult('Hallo Welt', isFinal: true)),
        );
        await tester.pump();

        // ── Rapid-fire status callbacks ──
        await platform.processMethodCall(
            const MethodCall('notifyStatus', 'notListening'));
        await tester.pump();
        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'done'));
        await tester.pump();
        // Wait for restart
        await waitForRestart(tester);

        // ── Session 2: new listening starts ──
        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'listening'));
        await tester.pump();

        // Now a LATE 'done' arrives — should be ignored since generation
        // has already advanced.
        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'done'));
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pump();

        // Session 2 text
        await platform.processMethodCall(
          MethodCall('textRecognition', _speechResult('und Tschüss')),
        );
        await tester.pump();

        // ✅ Text should be preserved correctly
        expect(find.text('Hallo Welt und Tschüss'), findsOneWidget);

        await tearDownSheet(tester);
      });
    });

    testWidgets('Late previous-session result does not overwrite new speech',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await pumpSheet(tester);

        final recordButton = find.text('Aufnehmen');
        await tester.tap(recordButton);
        await tester.pump();

        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'listening'));
        await tester.pump();
        await platform.processMethodCall(
          MethodCall('textRecognition',
              _speechResult('200 Gramm Reis', isFinal: true)),
        );
        await tester.pump();
        expect(find.text('200 Gramm Reis'), findsOneWidget);

        await platform.processMethodCall(
            const MethodCall('notifyStatus', 'notListening'));
        await tester.pump();
        await waitForRestart(tester);
        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'listening'));
        await tester.pump();

        await platform.processMethodCall(
          MethodCall('textRecognition', _speechResult('mit Soße')),
        );
        await tester.pump();
        expect(find.text('200 Gramm Reis mit Soße'), findsOneWidget);

        // Some engines can deliver a stale final result from the previous
        // recognition session after the next segment has already started.
        await platform.processMethodCall(
          MethodCall('textRecognition',
              _speechResult('200 Gramm Reis', isFinal: true)),
        );
        await tester.pump();

        expect(find.text('200 Gramm Reis mit Soße'), findsOneWidget);

        await tearDownSheet(tester);
      });
    });

    testWidgets('Visible recording text is used when speech baseline is stale',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await pumpSheet(tester);

        final recordButton = find.text('Aufnehmen');
        await tester.tap(recordButton);
        await tester.pump();

        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'listening'));
        await tester.pump();
        await platform.processMethodCall(
          MethodCall('textRecognition', _speechResult('200 Gramm Reis')),
        );
        await tester.pump();
        expect(find.text('200 Gramm Reis'), findsOneWidget);

        // Simulates the real-device failure mode where the TextField still
        // contains the previous words, but the next recognition callback would
        // otherwise combine from a shorter stale baseline.
        await tester.enterText(
          find.byType(EditableText).first,
          '200 Gramm Reis',
        );
        await tester.pump();

        await platform.processMethodCall(
          MethodCall('textRecognition', _speechResult('mit Soße')),
        );
        await tester.pump();

        expect(find.text('200 Gramm Reis mit Soße'), findsOneWidget);

        await tearDownSheet(tester);
      });
    });

    testWidgets('OK preserves appended text when speech baseline is stale',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await pumpSheet(tester);

        final recordButton = find.text('Aufnehmen');
        await tester.tap(recordButton);
        await tester.pump();

        await platform
            .processMethodCall(const MethodCall('notifyStatus', 'listening'));
        await tester.pump();
        await platform.processMethodCall(
          MethodCall('textRecognition', _speechResult('200 Gramm Reis')),
        );
        await tester.pump();
        await platform.processMethodCall(
          MethodCall('textRecognition', _speechResult('mit Soße')),
        );
        await tester.pump();
        expect(find.text('200 Gramm Reis mit Soße'), findsOneWidget);

        await tester.tap(find.text('OK'));
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 600));
        await tester.pump();

        expect(find.text('200 Gramm Reis mit Soße'), findsOneWidget);

        await tearDownSheet(tester);
      });
    });
  });
}
