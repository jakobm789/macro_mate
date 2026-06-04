// lib/widgets/ai_food_sheet.dart
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/ai_food_analysis_state.dart';
import '../models/app_state.dart';
import '../models/food_analysis_result.dart';
import '../models/local_llm_model.dart';
import '../services/llm_service.dart';

/// BottomSheet für die KI-gestützte Lebensmittelerkennung.
///
/// Unterstützt 4 Eingabearten:
/// 1. Nur Foto (Kamera oder Galerie)
/// 2. Foto + Textbeschreibung
/// 3. Nur Text
/// 4. Sprachaufnahme → Lokale Spracherkennung → Text-Analyse
class AiFoodSheet extends StatefulWidget {
  final String mealName;

  const AiFoodSheet({Key? key, required this.mealName}) : super(key: key);

  @override
  State<AiFoodSheet> createState() => _AiFoodSheetState();
}

class _AiFoodSheetState extends State<AiFoodSheet>
    with SingleTickerProviderStateMixin {
  static final stt.SpeechToText _sharedSpeech = stt.SpeechToText();
  static _AiFoodSheetState? _activeSpeechState;

  // --- Services ---
  LlmService? _llmService;
  final ImagePicker _imagePicker = ImagePicker();
  final stt.SpeechToText _speech = _sharedSpeech;
  bool _speechInitialized = false;
  bool _finishRecordingRequested = false;
  bool _disposed = false;
  bool _modelWarmupStarted = false;
  String _speechCommittedText = '';
  String _speechCurrentPartial = '';
  int _speechListenGeneration = 0;

  /// Tracks which listen-generation triggered the current restart attempt.
  /// A restart is only allowed to proceed if this matches _speechListenGeneration
  /// at the time it was initiated. This prevents double-restarts caused by
  /// both 'notListening' and 'done' status callbacks firing for the same session.
  int _speechRestartForGeneration = -1;

  // --- State ---
  AiFoodAnalysisState _analysisState = AiFoodAnalysisState.idle();
  File? _selectedImage;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  String _partialReasoning = '';
  bool _thinkingExpanded = false;
  final Set<int> _expandedSteps = {};
  String _currentInferenceStep = '';
  String? _inferenceBackendName;

  // --- Controllers ---
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  String _selectedMeal = '';

  // --- Animation ---
  late AnimationController _pulseController;

  // --- Farben (Dynamische Theme-Zuweisung) ---
  Color get _accentColor => Theme.of(context).colorScheme.primary;
  Color get _recordingColor => const Color(0xFFFF5252);
  Color get _successColor => const Color(0xFF4CAF50);
  Color get _warningColor => const Color(0xFFFF9800);
  Color get _errorColor => const Color(0xFFFF5252);
  Color get _cardColor => Theme.of(context).colorScheme.surface;

  @override
  void initState() {
    super.initState();
    _activeSpeechState = this;
    _selectedMeal = widget.mealName;
    final appState = Provider.of<AppState>(context, listen: false);
    _llmService = LlmService(selectedModel: appState.selectedLocalLlmModel);
    _initSpeech();
    _checkAndTriggerDownload();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: _routeSpeechStatus,
        onError: _routeSpeechError,
      );
      if (mounted) {
        setState(() {
          _speechInitialized = available;
        });
      }
    } catch (e) {
      debugPrint('[Speech] Init error: $e');
    }
  }

  static void _routeSpeechStatus(String status) {
    _activeSpeechState?._handleSpeechStatus(status);
  }

  static void _routeSpeechError(dynamic error) {
    _activeSpeechState?._handleSpeechError(error);
  }

  void _handleSpeechStatus(String val) {
    if (_disposed || !mounted) return;
    debugPrint(
        '[Speech] onStatus: $val (gen=$_speechListenGeneration, restartFor=$_speechRestartForGeneration)');
    if ((val == 'done' || val == 'notListening') &&
        _analysisState.status == AiFoodAnalysisStatus.recording &&
        !_finishRecordingRequested) {
      final gen = _speechListenGeneration;
      unawaited(_restartListeningAfterPause(gen));
    }
  }

  void _handleSpeechError(dynamic val) {
    if (_disposed || !mounted) return;
    debugPrint('[Speech] onError: $val');
    if (_analysisState.status == AiFoodAnalysisStatus.recording) {
      if (val.permanent) {
        setState(() {
          _analysisState = AiFoodAnalysisState.error(
            'Spracherkennungsfehler: ${val.errorMsg}',
          );
        });
        _recordingTimer?.cancel();
        _pulseController.stop();
      } else {
        debugPrint('[Speech] Non-permanent error, attempting restart...');
        final gen = _speechListenGeneration;
        unawaited(_restartListeningAfterPause(gen));
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (_activeSpeechState == this) {
      _activeSpeechState = null;
    }
    _finishRecordingRequested = true;
    _speechListenGeneration++;
    _recordingTimer?.cancel();
    _descriptionController.dispose();
    _nameController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _sugarController.dispose();
    _pulseController.dispose();
    unawaited(_llmService?.dispose() ?? Future<void>.value());
    unawaited(_speech.cancel());
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // Foto-Aufnahme / Galerie
  // ──────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Fehler beim Bildauswahl: $e');
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // ──────────────────────────────────────────────
  // Spracherkennung (On-Device Speech-to-Text)
  // ──────────────────────────────────────────────

  Future<void> _startRecording() async {
    try {
      if (!_speechInitialized) {
        await _initSpeech();
        if (!_speechInitialized) {
          _showSnackBar(
              'Spracherkennung konnte auf diesem Gerät nicht initialisiert werden.');
          return;
        }
      }

      _recordingDuration = Duration.zero;
      _finishRecordingRequested = false;
      _speechCommittedText = _descriptionController.text.trim();
      _speechCurrentPartial = '';
      _speechRestartForGeneration = -1;

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration += const Duration(seconds: 1);
            _analysisState = AiFoodAnalysisState.recording(_recordingDuration);
          });
        }
      });

      _pulseController.repeat(reverse: true);

      setState(() {
        _analysisState = AiFoodAnalysisState.recording(Duration.zero);
      });

      await _listenForSpeech();
    } catch (e) {
      _showSnackBar('Fehler beim Starten der Spracherkennung: $e');
    }
  }

  Future<void> _listenForSpeech() async {
    _commitCurrentSpeechPartial();
    // Snapshot the committed text before starting a new listen session.
    _speechCommittedText = _descriptionController.text.trim();
    _speechCurrentPartial = '';
    final listenGeneration = ++_speechListenGeneration;
    debugPrint(
        '[Speech] listen gen=$listenGeneration, committed="$_speechCommittedText"');
    await _speech.listen(
      onResult: (result) {
        if (_disposed ||
            !mounted ||
            listenGeneration != _speechListenGeneration ||
            _finishRecordingRequested) {
          debugPrint('[Speech] ignoring stale result for gen=$listenGeneration '
              '(current=$_speechListenGeneration)');
          return;
        }
        final words = result.recognizedWords.trim();
        debugPrint(
            '[Speech] onResult: gen=$listenGeneration, words="$words", final=${result.finalResult}');

        if (words.isEmpty) return;

        final visibleBefore = _descriptionController.text.trim();
        final partialBefore = _speechCurrentPartial;
        // Store the raw partial from this session.
        _speechCurrentPartial = words;
        final committedBaseline = _bestSpeechBaseline(visibleBefore);
        var combined = _combineSpeechText(
          committedBaseline,
          _speechCurrentPartial,
        );
        if (_isStaleSpeechRegression(
              visibleBefore: visibleBefore,
              partialBefore: partialBefore,
              combined: combined,
            ) ||
            _isDuplicateSpeechRegression(
              visibleBefore: visibleBefore,
              words: words,
              combined: combined,
            )) {
          debugPrint('[Speech] ignoring stale/duplicate result: "$words"');
          _speechCurrentPartial = partialBefore;
          return;
        }

        final appState = Provider.of<AppState>(context, listen: false);
        final maxLen = _getMaxDescriptionLength(appState.selectedLocalLlmModel);
        if (combined.length > maxLen) {
          combined = combined.substring(0, maxLen);
          _showSnackBar('Spracheingabe auf $maxLen Zeichen begrenzt.');
        }

        setState(() {
          _descriptionController.text = combined;
          _descriptionController.selection = TextSelection.collapsed(
            offset: _descriptionController.text.length,
          );
        });
        if (result.finalResult) {
          // Lock in this session's final result so it becomes part of the
          // committed baseline for the next session/restart.
          _speechCommittedText = combined;
          _speechCurrentPartial = '';
          debugPrint(
              '[Speech] finalResult → committed="$_speechCommittedText"');
        }
      },
      localeId: 'de_DE',
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      listenFor: const Duration(minutes: 10),
      pauseFor: const Duration(minutes: 10),
      cancelOnError: false,
    );
  }

  void _commitCurrentSpeechPartial() {
    if (_disposed || !mounted) return;
    debugPrint(
        '[Speech] commitCurrentSpeechPartial: committed before="$_speechCommittedText", partial before="$_speechCurrentPartial"');
    final visibleBefore = _descriptionController.text.trim();
    final committedBaseline = _bestSpeechBaseline(visibleBefore);
    _speechCommittedText = _combineSpeechText(
      committedBaseline,
      _speechCurrentPartial,
    );
    _speechCurrentPartial = '';
    debugPrint(
        '[Speech] commitCurrentSpeechPartial: committed after="$_speechCommittedText"');
    if (_speechCommittedText.isNotEmpty) {
      _descriptionController.text = _speechCommittedText;
      _descriptionController.selection = TextSelection.collapsed(
        offset: _descriptionController.text.length,
      );
    }
  }

  String _combineSpeechText(String committed, String partial) {
    final base = committed.trim();
    final addition = partial.trim();
    debugPrint('[Speech] combine: base="$base", addition="$addition"');
    if (addition.isEmpty) return base;
    if (base.isEmpty) return addition;

    // Some Android speech engines deliver cumulative text across restarts,
    // meaning `addition` may start with (all or part of) `base`.
    // Detect this and strip the overlapping prefix to avoid duplication.
    final baseLower = base.toLowerCase();
    final additionLower = addition.toLowerCase();
    if (additionLower.startsWith(baseLower)) {
      // The engine re-delivered the full committed text plus new words.
      // Use the engine's version (it may have better punctuation/casing).
      debugPrint(
          '[Speech] combine: addition contains base, using addition directly');
      return addition;
    }

    // Check for partial overlap: the end of `base` matches the start of `addition`.
    // This handles cases where the engine delivers text that partially overlaps
    // with what was already committed.
    // We check from the longest possible overlap down to a minimum of 3 chars.
    final minOverlap = 3;
    final maxCheck =
        base.length < addition.length ? base.length : addition.length;
    for (var len = maxCheck; len >= minOverlap; len--) {
      if (baseLower.endsWith(additionLower.substring(0, len))) {
        final merged = base + addition.substring(len);
        debugPrint('[Speech] combine: overlap=$len chars, merged="$merged"');
        return merged;
      }
    }

    // No overlap detected – simple append.
    final result = '$base $addition';
    debugPrint('[Speech] combine: no overlap, result="$result"');
    return result;
  }

  String _bestSpeechBaseline(String visibleBefore) {
    final committed = _speechCommittedText.trim();
    final visible = visibleBefore.trim();
    if (visible.isEmpty) return committed;
    if (committed.isEmpty) return visible;
    if (visible.length <= committed.length) return committed;
    if (visible.toLowerCase().startsWith(committed.toLowerCase())) {
      return visible;
    }
    return committed;
  }

  bool _isStaleSpeechRegression({
    required String visibleBefore,
    required String partialBefore,
    required String combined,
  }) {
    if (visibleBefore.isEmpty || combined.isEmpty) return false;
    if (combined.length >= visibleBefore.length) return false;
    final visibleLower = visibleBefore.toLowerCase();
    final combinedLower = combined.toLowerCase();
    return visibleLower.startsWith(combinedLower) ||
        combinedLower.split(RegExp(r'\s+')).every(visibleLower.contains);
  }

  bool _isDuplicateSpeechRegression({
    required String visibleBefore,
    required String words,
    required String combined,
  }) {
    final visibleLower = visibleBefore.toLowerCase();
    final wordsLower = words.toLowerCase();
    final combinedLower = combined.toLowerCase();
    if (visibleLower.isEmpty || wordsLower.isEmpty) return false;
    if (!visibleLower.contains(wordsLower)) return false;
    if (visibleLower == wordsLower) return false;
    return combinedLower.startsWith(visibleLower) &&
        combinedLower.length > visibleLower.length;
  }

  Future<void> _restartListeningAfterPause(int forGeneration) async {
    if (_disposed || !mounted || _finishRecordingRequested) return;
    // Only allow one restart per listen-generation. If a restart was already
    // initiated for this generation (e.g. 'notListening' fired before 'done'),
    // skip the duplicate.
    if (_speechRestartForGeneration == forGeneration) {
      debugPrint(
          '[Speech] restart already pending for gen=$forGeneration, skipping');
      return;
    }
    _speechRestartForGeneration = forGeneration;

    // Also verify the generation hasn't already been superseded by a new
    // listen session (e.g. if the user manually stopped and restarted).
    if (forGeneration != _speechListenGeneration) {
      debugPrint(
          '[Speech] restart gen=$forGeneration stale (current=$_speechListenGeneration), skipping');
      return;
    }

    // Commit any partial text from the session that just ended, so it becomes
    // part of the baseline for the new session.
    _commitCurrentSpeechPartial();
    debugPrint(
        '[Speech] restart: gen=$forGeneration, committed="$_speechCommittedText"');

    // Wait briefly for the speech engine to fully settle before restarting.
    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted ||
        _finishRecordingRequested ||
        _analysisState.status != AiFoodAnalysisStatus.recording) {
      debugPrint(
          '[Speech] restart aborted: mounted=$mounted, finishRequested=$_finishRecordingRequested');
      return;
    }

    // Double-check generation hasn't changed during the delay.
    if (forGeneration != _speechListenGeneration) {
      debugPrint(
          '[Speech] restart gen=$forGeneration stale after delay (current=$_speechListenGeneration), skipping');
      return;
    }

    try {
      await _listenForSpeech();
      _speechRestartForGeneration = -1;
    } catch (e) {
      debugPrint('[Speech] restart failed: $e');
      _speechRestartForGeneration = -1;
    }
  }

  Future<void> _stopRecording() async {
    _finishRecordingRequested = true;
    _speechListenGeneration++;
    _speechRestartForGeneration = -1;
    _recordingTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    try {
      _commitCurrentSpeechPartial();
      setState(() {
        _analysisState = AiFoodAnalysisState.transcribing();
      });

      await _speech.stop();
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _analysisState = AiFoodAnalysisState.idle(
            transcribedText: _descriptionController.text,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analysisState = AiFoodAnalysisState.error(
            'Fehler beim Stoppen der Spracherkennung: $e',
          );
        });
      }
    }
  }

  Future<void> _cancelRecording() async {
    _finishRecordingRequested = true;
    _speechListenGeneration++;
    _speechRestartForGeneration = -1;
    _recordingTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    try {
      await _speech.cancel();
    } catch (_) {}
    _speechCommittedText = '';
    _speechCurrentPartial = '';
    _speechListenGeneration++;
    _speechRestartForGeneration = -1;

    if (mounted) {
      setState(() {
        _analysisState = AiFoodAnalysisState.idle();
      });
    }
  }

  // ──────────────────────────────────────────────
  // Analyse starten
  // ──────────────────────────────────────────────

  Future<void> _checkAndTriggerDownload() async {
    if (!mounted) return;
    final appState = Provider.of<AppState>(context, listen: false);
    final markedInstalled =
        appState.isLocalLlmModelMarkedInstalled(appState.selectedLocalLlmModel);
    bool installed = markedInstalled;
    if (!installed) {
      installed = await _llmService?.isSelectedModelInstalled() ?? false;
    }

    if (!installed) {
      if (!appState.isLocalModelDownloadRunning) {
        try {
          unawaited(appState.downloadSelectedLocalLlmModel());
        } catch (e) {
          debugPrint('[AiFoodSheet] Auto-download failed: $e');
        }
      }
    } else {
      if (!markedInstalled) {
        await appState.refreshInstalledLocalLlmModels();
      }
      _warmUpModelInBackground();
    }
  }

  Future<void> _warmUpModelInBackground() async {
    if (_modelWarmupStarted) return;
    _modelWarmupStarted = true;
    try {
      await _llmService?.warmUp(supportImage: true);
    } catch (e) {
      debugPrint('[Local LLM Warmup] skipped: $e');
    }
  }

  Future<void> _startAnalysis() async {
    final hasImage = _selectedImage != null;
    final hasText = _descriptionController.text.trim().isNotEmpty;

    if (!hasImage && !hasText) {
      _showSnackBar(
          'Bitte gib mindestens ein Foto oder eine Beschreibung ein.');
      return;
    }

    setState(() {
      _analysisState = AiFoodAnalysisState.analyzing();
      _partialReasoning = '';
      _thinkingExpanded = false;
      _expandedSteps.clear();
      _currentInferenceStep = 'Modell wird geladen...';
      _inferenceBackendName = null;
    });
    _pulseController.repeat();

    // Kurze Verzögerung, damit die UI rendern kann und "Modell wird geladen..." anzeigt
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      if (_llmService == null ||
          _llmService!.selectedModel != appState.selectedLocalLlmModel) {
        await _llmService?.dispose();
        _llmService = LlmService(
          selectedModel: appState.selectedLocalLlmModel,
        );
      }
      final llmService = _llmService!;
      final result = await llmService.analyzeFood(
        imagePath: _selectedImage?.path,
        textDescription: hasText ? _descriptionController.text.trim() : null,
        onReasoningProgress: (partial) {
          if (mounted) {
            setState(() {
              _partialReasoning = partial;
            });
          }
        },
        onInferenceStart: () {
          if (mounted) {
            setState(() {
              _currentInferenceStep = 'Inferenz wird berechnet...';
              _inferenceBackendName = llmService.loadedBackendName;
            });
          }
        },
      );

      if (!mounted) return;

      // Ergebnis-Controller befüllen
      _populateResultControllers(result);

      setState(() {
        _inferenceBackendName = llmService.loadedBackendName;
        if (result.isLowConfidence) {
          _analysisState = AiFoodAnalysisState.fallback(result);
        } else {
          _analysisState = AiFoodAnalysisState.success(result);
        }
      });
      _pulseController.stop();
    } catch (e) {
      if (!mounted) return;
      _pulseController.stop();
      setState(() {
        _analysisState = AiFoodAnalysisState.error(_humanReadableError(e));
      });
    }
  }

  void _populateResultControllers(FoodAnalysisResult result) {
    _nameController.text = result.name;
    _brandController.text = result.brand;
    _quantityController.text = result.estimatedWeightGrams.toString();
    _caloriesController.text = result.totalCalories.toString();
    _proteinController.text = result.totalProtein.toStringAsFixed(1);
    _carbsController.text = result.totalCarbs.toStringAsFixed(1);
    _fatController.text = result.totalFat.toStringAsFixed(1);
    _sugarController.text = result.totalSugar.toStringAsFixed(1);
  }

  // ──────────────────────────────────────────────
  // Zur Mahlzeit hinzufügen
  // ──────────────────────────────────────────────

  Future<void> _addToMeal() async {
    final appState = Provider.of<AppState>(context, listen: false);

    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    final quantity = int.tryParse(_quantityController.text) ?? 100;
    final calories = int.tryParse(_caloriesController.text) ?? 0;
    final protein =
        double.tryParse(_proteinController.text.replaceAll(',', '.')) ?? 0.0;
    final carbs =
        double.tryParse(_carbsController.text.replaceAll(',', '.')) ?? 0.0;
    final fat =
        double.tryParse(_fatController.text.replaceAll(',', '.')) ?? 0.0;
    final sugar =
        double.tryParse(_sugarController.text.replaceAll(',', '.')) ?? 0.0;

    if (name.isEmpty) {
      _showSnackBar('Bitte gib einen Namen ein.');
      return;
    }

    final food = FoodAnalysisResult(
      name: name,
      brand: brand.isEmpty ? 'Unbekannt' : brand,
      estimatedWeightGrams: quantity,
      totalCalories: calories,
      totalProtein: protein,
      totalCarbs: carbs,
      totalFat: fat,
      totalSugar: sugar,
      confidence: _analysisState.result?.confidence ?? 0.5,
    ).toFoodItem();

    try {
      await appState.addLocalAiFood(
        _selectedMeal,
        food,
        quantity,
        appState.currentDate,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${food.name} hinzugefügt.')),
      );
      Navigator.popUntil(context, ModalRoute.withName('/'));
    } catch (e) {
      if (mounted) {
        _showSnackBar('Fehler beim Hinzufügen: $e');
      }
    }
  }

  // ──────────────────────────────────────────────
  // Hilfsfunktionen
  // ──────────────────────────────────────────────

  String _humanReadableError(dynamic error) {
    final msg = error.toString();
    if (msg.contains('token ids are too long') ||
        msg.contains('maximum number of tokens') ||
        (msg.contains('INVALID_ARGUMENT') && msg.contains('token'))) {
      return 'Die Eingabe (Bild + Beschreibung) überschreitet das Limit des lokalen Modells. '
          'Bitte versuche es mit einer kürzeren Beschreibung oder wähle ein größeres Modell in den Einstellungen.';
    }

    if (error is LlmModelUnavailableError) {
      return error.message;
    } else if (error is LlmUnsupportedPlatformError) {
      return error.message;
    } else if (error is LlmInferenceError) {
      return error.message;
    } else if (error is LlmJsonParseError) {
      return 'Die lokale Modellantwort konnte nicht verarbeitet werden. Bitte versuche es erneut.';
    } else if (error is LlmInputValidationError) {
      return error.message;
    }
    return 'Ein unerwarteter Fehler ist aufgetreten. Bitte versuche es erneut.';
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _resetToIdle() {
    setState(() {
      _analysisState = AiFoodAnalysisState.idle();
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // ──────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    final isInstalled =
        appState.isLocalLlmModelMarkedInstalled(appState.selectedLocalLlmModel);

    if (isInstalled && !_modelWarmupStarted) {
      _warmUpModelInBackground();
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: _accentColor, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'KI Erkennung',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (_inferenceBackendName != null) _buildBackendText(theme),
                ],
              ),
              const SizedBox(height: 20),

              // ── Eingabebereich ──
              if (!_analysisState.hasResult) ...[
                if (!isInstalled) ...[
                  _buildDownloadCard(appState, theme),
                ] else ...[
                  // Foto-Bereich
                  _buildImageSection(),
                  const SizedBox(height: 16),

                  // Textbeschreibung
                  _buildDescriptionField(),
                  const SizedBox(height: 16),

                  // Sprachaufnahme
                  _buildVoiceSection(),
                  const SizedBox(height: 20),

                  // Analysieren-Button
                  if (_analysisState.status == AiFoodAnalysisStatus.idle)
                    _buildAnalyzeButton(),
                ],
              ],

              // ── Status-Bereich ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: _buildStatusWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Eingabe-Widgets
  // ──────────────────────────────────────────────

  Widget _buildDownloadCard(AppState appState, ThemeData theme) {
    final progress = appState.localModelDownloadProgress ?? 0;
    final message =
        appState.localModelDownloadMessage ?? 'Warte auf Download...';
    final isRunning = appState.isLocalModelDownloadRunning;
    final modelName = appState.selectedLocalLlmModel.displayName;

    // Modelldateigröße schätzen
    final modelSize =
        appState.selectedLocalLlmModel.id == LocalLlmModelId.fastVlm05b
            ? 'ca. 350 MB'
            : (appState.selectedLocalLlmModel.id == LocalLlmModelId.gemma4E2b
                ? 'ca. 1.4 GB'
                : 'ca. 2.6 GB');

    return Container(
      key: const ValueKey('download_card'),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.12),
            theme.colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: isRunning
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary),
                        ),
                      )
                    : Icon(
                        Icons.cloud_download_outlined,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRunning
                          ? 'KI-Modell wird geladen...'
                          : 'Download erforderlich',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$modelName ($modelSize)',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isRunning) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100.0,
                minHeight: 8,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '$progress%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Für die lokale, datenschutzfreundliche KI-Erkennung muss das Modell einmalig heruntergeladen werden. Dies geschieht vollständig im Hintergrund.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  try {
                    unawaited(appState.downloadSelectedLocalLlmModel());
                  } catch (e) {
                    _showSnackBar('Fehler beim Starten des Downloads: $e');
                  }
                },
                icon: const Icon(Icons.download, size: 20),
                label: const Text(
                  'Download starten',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_camera,
                  color: theme.colorScheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              Text(
                'Foto',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedImage != null) ...[
            // Bild-Vorschau
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _removeImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                        semanticLabel: 'Bild entfernen',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Kamera/Galerie Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.photo_library,
                    label: 'Galerie',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  int _getMaxDescriptionLength(LocalLlmModel model) {
    if (model.id == LocalLlmModelId.gemma4E4b ||
        model.id == LocalLlmModelId.gemma4E4bReasoning) {
      return 1200;
    }
    if (model.maxTokens >= 3000) {
      return 1200;
    }
    return 600;
  }

  Widget _buildDescriptionField() {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    final maxLen = _getMaxDescriptionLength(appState.selectedLocalLlmModel);

    return Semantics(
      label: 'Textbeschreibung des Lebensmittels',
      child: TextField(
        controller: _descriptionController,
        maxLines: null,
        minLines: 2,
        maxLength: maxLen,
        decoration: InputDecoration(
          labelText: 'Beschreibung (optional)',
          hintText: 'z.B. 200g Spaghetti Bolognese',
          prefixIcon: const Icon(Icons.edit_note),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceSection() {
    final isRecording = _analysisState.status == AiFoodAnalysisStatus.recording;
    final isTranscribing =
        _analysisState.status == AiFoodAnalysisStatus.transcribing;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.mic,
                  color: theme.colorScheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              Text(
                'Spracheingabe',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (isRecording) ...[
                // Pulsierender Aufnahme-Punkt
                ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.2)
                      .animate(_pulseController),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _recordingColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_recordingDuration),
                  style: TextStyle(
                    color: _recordingColor,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (isTranscribing)
            _buildProcessingIndicator('Sprache wird verarbeitet...')
          else
            Row(
              children: [
                if (!isRecording)
                  Expanded(
                    child: Semantics(
                      label: 'Sprachaufnahme starten',
                      button: true,
                      child: _buildActionButton(
                        icon: Icons.mic,
                        label: 'Aufnehmen',
                        onTap: _startRecording,
                        color: _accentColor,
                      ),
                    ),
                  ),
                if (isRecording) ...[
                  Expanded(
                    child: Semantics(
                      label: 'Aufnahme stoppen',
                      button: true,
                      child: _buildActionButton(
                        icon: Icons.stop,
                        label: 'OK',
                        onTap: _stopRecording,
                        color: _recordingColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Semantics(
                      label: 'Aufnahme abbrechen',
                      button: true,
                      child: _buildActionButton(
                        icon: Icons.close,
                        label: 'Abbruch',
                        onTap: _cancelRecording,
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    final hasInput =
        _selectedImage != null || _descriptionController.text.trim().isNotEmpty;
    final theme = Theme.of(context);

    return Semantics(
      label: 'Lebensmittel analysieren',
      button: true,
      child: AnimatedOpacity(
        opacity: hasInput ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: hasInput ? _startAnalysis : null,
            icon: const Icon(Icons.search, size: 20),
            label: const Text(
              'Analysieren',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: theme.colorScheme.onPrimary,
              disabledBackgroundColor:
                  theme.colorScheme.onSurface.withOpacity(0.12),
              disabledForegroundColor:
                  theme.colorScheme.onSurface.withOpacity(0.38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Status-Widgets
  // ──────────────────────────────────────────────

  Widget _buildStatusWidget() {
    switch (_analysisState.status) {
      case AiFoodAnalysisStatus.idle:
        return const SizedBox.shrink(key: ValueKey('idle'));

      case AiFoodAnalysisStatus.recording:
        return const SizedBox.shrink(key: ValueKey('recording'));

      case AiFoodAnalysisStatus.transcribing:
        return const SizedBox.shrink(key: ValueKey('transcribing'));

      case AiFoodAnalysisStatus.analyzing:
        return _buildAnalyzingState();

      case AiFoodAnalysisStatus.success:
        return _buildResultCard(isLowConfidence: false);

      case AiFoodAnalysisStatus.fallback:
        return _buildResultCard(isLowConfidence: true);

      case AiFoodAnalysisStatus.error:
        return _buildErrorState();
    }
  }

  Widget _buildAnalyzingState() {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      key: const ValueKey('analyzing'),
      animation: _pulseController,
      builder: (context, child) {
        return CustomPaint(
          painter: _GeminiBorderPainter(
            progress: _pulseController.value,
            colors: [
              theme.colorScheme.primary,
              const Color(0xFF00C2FF),
              const Color(0xFF7C4DFF),
              const Color(0xFFFF4FD8),
              const Color(0xFFFFB300),
            ],
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.primary,
                  size: 34,
                ),
                const SizedBox(height: 14),
                Text(
                  'Lokales Modell analysiert...',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentInferenceStep,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bild und Beschreibung bleiben auf dem Gerät',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                if (_partialReasoning.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildThinkingWidget(
                    reasoning: _partialReasoning,
                    isStillRunning: true,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('error'),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: _errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _errorColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: _errorColor, size: 36),
          const SizedBox(height: 12),
          Text(
            _analysisState.errorMessage ?? 'Ein Fehler ist aufgetreten.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetToIdle,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Erneut versuchen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _errorColor,
                side: BorderSide(color: _errorColor.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({required bool isLowConfidence}) {
    final theme = Theme.of(context);
    // Live-Vorschau berechnen
    final previewCalories = int.tryParse(_caloriesController.text) ?? 0;
    final result = _analysisState.result;
    final reasoning = _analysisState.result?.reasoning?.trim();

    return Container(
      key: ValueKey(isLowConfidence ? 'fallback' : 'success'),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLowConfidence
              ? _warningColor.withOpacity(0.4)
              : _successColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fallback-Warnung
          if (isLowConfidence) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: _warningColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Unsichere Schätzung — Werte manuell anpassen?',
                      style: TextStyle(
                        color: _warningColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Row(
              children: [
                Icon(Icons.check_circle, color: _successColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Analyse abgeschlossen',
                  style: TextStyle(
                    color: _successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          if (reasoning != null && reasoning.isNotEmpty) ...[
            _buildReasoningTile(reasoning),
            const SizedBox(height: 16),
          ],

          if (result?.totalsCorrectedFromIngredients == true) ...[
            _buildIngredientCorrectionNotice(theme),
            const SizedBox(height: 12),
          ],

          // Mahlzeit-Dropdown
          DropdownButtonFormField<String>(
            value: _selectedMeal,
            dropdownColor: theme.cardColor,
            decoration: _inputDecoration('Mahlzeit'),
            items: ['Frühstück', 'Mittagessen', 'Abendessen', 'Snacks']
                .map((meal) => DropdownMenuItem(
                      value: meal,
                      child: Text(meal),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedMeal = value);
            },
          ),
          const SizedBox(height: 12),

          // Name
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('Name'),
          ),
          const SizedBox(height: 12),

          // Marke
          TextFormField(
            controller: _brandController,
            decoration: _inputDecoration('Marke'),
          ),
          const SizedBox(height: 12),

          // Menge
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Geschätzte Menge (g)'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Gesamt-Nährwerte Header
          Text(
            'Gesamt-Nährwerte der Portion',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Nährwerte-Grid (2 Spalten)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Kalorien (kcal)'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _proteinController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('Protein (g)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _carbsController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('Kohlenhydrate (g)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _fatController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('Fett (g)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _sugarController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration('Zucker (g)'),
          ),
          const SizedBox(height: 16),

          // Vorschau
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Vorschau: $previewCalories kcal insgesamt bei ${_quantityController.text} g',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),

          // Notes
          if (result != null && result.ingredients.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildIngredientsSummary(result, theme),
          ] else if (result?.notes != null && result!.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              result.notes!,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Hinzufügen-Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _addToMeal,
              icon: const Icon(Icons.check, size: 20),
              label: const Text(
                'Zur Mahlzeit hinzufügen',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Neuer Versuch Button
          Center(
            child: TextButton(
              onPressed: _resetToIdle,
              child: Text(
                'Neuer Versuch',
                style: TextStyle(color: theme.colorScheme.secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasoningTile(String reasoning) {
    return _buildThinkingWidget(reasoning: reasoning, isStillRunning: false);
  }

  Widget _buildBackendText(ThemeData theme) {
    final backend = _inferenceBackendName ?? 'Unbekannt';

    return Text(
      backend,
      style: TextStyle(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildIngredientCorrectionNotice(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _warningColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _warningColor.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.calculate_outlined, color: _warningColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Gesamtwerte wurden aus den erkannten Zutaten neu summiert, weil die KI-Gesamtsumme widersprüchlich war.',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSummary(FoodAnalysisResult result, ThemeData theme) {
    final ingredientCalories = result.ingredients.fold<int>(
      0,
      (sum, ingredient) => sum + ingredient.calories,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zutaten-Schätzung',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          ...result.ingredients.take(6).map(
                (ingredient) => Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    '${ingredient.name}: ${ingredient.grams} g, ${ingredient.calories} kcal',
                    style: TextStyle(
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.78),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          if (result.ingredients.length > 6)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '+ ${result.ingredients.length - 6} weitere Zutaten',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.72),
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            'Summe: $ingredientCalories kcal',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingWidget(
      {required String reasoning, required bool isStillRunning}) {
    final theme = Theme.of(context);
    final steps = parseThoughtSteps(reasoning, isStillRunning);
    if (steps.isEmpty) return const SizedBox.shrink();

    final activeStep = steps.firstWhere(
      (s) => s.isActive,
      orElse: () => steps.last,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toggle-Button für gesamten Denkprozess
          InkWell(
            onTap: () {
              setState(() {
                _thinkingExpanded = !_thinkingExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _thinkingExpanded
                          ? 'Denkprozess'
                          : 'Denkprozess: ${activeStep.title}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (isStillRunning && !_thinkingExpanded) ...[
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Icon(
                    _thinkingExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Wenn ausgeklappt, zeige die ganze Kette von Gedanken-Überschriften
          if (_thinkingExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: List.generate(steps.length, (index) {
                  final step = steps[index];
                  final isExpanded = _expandedSteps.contains(index);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: step.isActive
                            ? theme.colorScheme.primary.withOpacity(0.3)
                            : theme.colorScheme.outline.withOpacity(0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Schritt-Überschrift (weiter ausklappbar für Details)
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedSteps.remove(index);
                              } else {
                                _expandedSteps.add(index);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                if (step.isActive && isStillRunning)
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue),
                                    ),
                                  )
                                else
                                  Icon(
                                    step.isCompleted
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: step.isCompleted
                                        ? Colors.green
                                        : theme.colorScheme.onSurfaceVariant,
                                    size: 16,
                                  ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    step.title,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: step.isActive
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: step.isActive
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Ausgeklappte Details für diesen Schritt
                        if (isExpanded && step.body.isNotEmpty) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                            child: _buildFormattedBody(step.body, theme),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],

          // Immer unterhalb anzeigen welcher Schritt aktuell läuft (nur während Inferenz)
          if (isStillRunning) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: theme.colorScheme.primaryContainer.withOpacity(0.04),
              child: Row(
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aktuell: ${activeStep.title}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormattedBody(String bodyText, ThemeData theme) {
    final lines = bodyText.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map((line) => _buildFormattedLine(line, theme))
          .where((w) => w is! SizedBox)
          .toList(),
    );
  }

  Widget _buildFormattedLine(String line, ThemeData theme) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    final isBullet = trimmed.startsWith('*') || trimmed.startsWith('-');
    final cleanLine =
        isBullet ? trimmed.replaceFirst(RegExp(r'^[*+\-]\s*'), '') : trimmed;

    final parts = cleanLine.split('**');
    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      final isBold = i % 2 == 1;
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: isBold
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurfaceVariant,
        ),
      ));
    }

    final textWidget = RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 13,
          height: 1.4,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        children: spans,
      ),
    );

    if (isBullet) {
      return Padding(
        padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• ',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(child: textWidget),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: textWidget,
    );
  }

  // ──────────────────────────────────────────────
  // Shared Widgets
  // ──────────────────────────────────────────────

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
                color: color?.withOpacity(0.4) ??
                    theme.colorScheme.outline.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: color ?? theme.colorScheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color ?? theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      isDense: true,
    );
  }
}

class _GeminiBorderPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  const _GeminiBorderPainter({
    required this.progress,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = BorderRadius.circular(20).toRRect(rect.deflate(2));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..shader = SweepGradient(
        colors: [...colors, colors.first],
        transform: GradientRotation(progress * math.pi * 2),
      ).createShader(rect);

    canvas.drawRRect(radius, paint);
  }

  @override
  bool shouldRepaint(covariant _GeminiBorderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.colors != colors;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reasoning & Thinking UI Helpers
// ─────────────────────────────────────────────────────────────────────────────

class ThoughtStep {
  final String title;
  final String body;
  final bool isActive;
  final bool isCompleted;

  ThoughtStep({
    required this.title,
    required this.body,
    required this.isActive,
    required this.isCompleted,
  });
}

List<ThoughtStep> parseThoughtSteps(String reasoning, bool isStillRunning) {
  final steps = <ThoughtStep>[];

  final cleanReasoning = reasoning
      .replaceAll(RegExp(r'<\|channel>thought\s*'), '')
      .replaceAll('<channel|>', '')
      .replaceAll(RegExp(r'</?think>'), '')
      .trim();

  if (cleanReasoning.isEmpty) {
    return [];
  }

  // Regex to find top-level steps like "1. **Analyze the Image:**"
  final regExp = RegExp(r'(?:^|\n\n|\n)(\d+)\.\s*\*\*(.*?)\*\*');
  final matches = regExp.allMatches(cleanReasoning).toList();

  if (matches.isEmpty) {
    steps.add(ThoughtStep(
      title: 'Überlegung...',
      body: cleanReasoning,
      isActive: isStillRunning,
      isCompleted: !isStillRunning,
    ));
    return steps;
  }

  final firstMatchIndex = matches.first.start;
  if (firstMatchIndex > 0) {
    final intro = cleanReasoning.substring(0, firstMatchIndex).trim();
    if (intro.isNotEmpty) {
      steps.add(ThoughtStep(
        title: 'Vorbereitung',
        body: intro,
        isActive: false,
        isCompleted: true,
      ));
    }
  }

  for (int i = 0; i < matches.length; i++) {
    final match = matches[i];
    final stepNum = match.group(1);
    var title = match.group(2)?.trim() ?? '';
    if (title.endsWith(':')) {
      title = title.substring(0, title.length - 1).trim();
    }

    if (stepNum != null) {
      title = '$stepNum. $title';
    }

    final startOfContent = match.end;
    final endOfContent =
        (i + 1 < matches.length) ? matches[i + 1].start : cleanReasoning.length;

    final body = cleanReasoning.substring(startOfContent, endOfContent).trim();
    final isLast = (i == matches.length - 1);

    steps.add(ThoughtStep(
      title: title,
      body: body,
      isActive: isStillRunning && isLast,
      isCompleted: !isStillRunning || !isLast,
    ));
  }

  return steps;
}
