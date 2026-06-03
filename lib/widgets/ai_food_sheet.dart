// lib/widgets/ai_food_sheet.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/ai_food_analysis_state.dart';
import '../models/app_state.dart';
import '../models/food_analysis_result.dart';
import '../services/openai_service.dart';

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
  // --- Services ---
  OpenAIService? _openAiService;
  final ImagePicker _imagePicker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;

  // --- State ---
  AiFoodAnalysisState _analysisState = AiFoodAnalysisState.idle();
  File? _selectedImage;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

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
  Color get _cardColor => Theme.of(context).colorScheme.surfaceContainerHighest;

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.mealName;
    try {
      _openAiService = OpenAIService();
    } catch (e) {
      _analysisState = AiFoodAnalysisState.error(_humanReadableError(e));
    }
    _initSpeech();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (val) {
          debugPrint('[Speech] onStatus: $val');
          if (val == 'done' || val == 'notListening') {
            if (_analysisState.status == AiFoodAnalysisStatus.recording) {
              _stopRecording();
            }
          }
        },
        onError: (val) {
          debugPrint('[Speech] onError: $val');
          if (_analysisState.status == AiFoodAnalysisStatus.recording) {
            setState(() {
              _analysisState = AiFoodAnalysisState.error(
                'Spracherkennungsfehler: ${val.errorMsg} (permanent: ${val.permanent})',
              );
            });
            _recordingTimer?.cancel();
            _pulseController.stop();
          }
        },
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

  @override
  void dispose() {
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
    _openAiService?.dispose();
    _speech.stop();
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
          _showSnackBar('Spracherkennung konnte auf diesem Gerät nicht initialisiert werden.');
          return;
        }
      }

      _recordingDuration = Duration.zero;

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

      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _descriptionController.text = result.recognizedWords;
            });
          }
        },
        localeId: 'de_DE',
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
      );
    } catch (e) {
      _showSnackBar('Fehler beim Starten der Spracherkennung: $e');
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    try {
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
    _recordingTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    try {
      await _speech.cancel();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _analysisState = AiFoodAnalysisState.idle();
      });
    }
  }

  // ──────────────────────────────────────────────
  // Analyse starten
  // ──────────────────────────────────────────────

  Future<void> _startAnalysis() async {
    final hasImage = _selectedImage != null;
    final hasText = _descriptionController.text.trim().isNotEmpty;

    if (!hasImage && !hasText) {
      _showSnackBar('Bitte gib mindestens ein Foto oder eine Beschreibung ein.');
      return;
    }

    setState(() {
      _analysisState = AiFoodAnalysisState.analyzing();
    });

    try {
      if (_openAiService == null) {
        throw OpenAIAuthenticationError(
          'OPENAI_API_KEY ist nicht gesetzt. Bitte als --dart-define übergeben.',
        );
      }
      final result = await _openAiService!.analyzeFood(
        imagePath: _selectedImage?.path,
        textDescription:
            hasText ? _descriptionController.text.trim() : null,
      );

      if (!mounted) return;

      // Ergebnis-Controller befüllen
      _populateResultControllers(result);

      setState(() {
        if (result.isLowConfidence) {
          _analysisState = AiFoodAnalysisState.fallback(result);
        } else {
          _analysisState = AiFoodAnalysisState.success(result);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _analysisState = AiFoodAnalysisState.error(_humanReadableError(e));
      });
    }
  }

  void _populateResultControllers(FoodAnalysisResult result) {
    _nameController.text = result.name;
    _brandController.text = result.brand;
    _quantityController.text = result.estimatedWeightGrams.toString();
    _caloriesController.text = result.caloriesPer100g.toString();
    _proteinController.text = result.proteinPer100g.toStringAsFixed(1);
    _carbsController.text = result.carbsPer100g.toStringAsFixed(1);
    _fatController.text = result.fatPer100g.toStringAsFixed(1);
    _sugarController.text = result.sugarPer100g.toStringAsFixed(1);
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
      caloriesPer100g: calories,
      proteinPer100g: protein,
      carbsPer100g: carbs,
      fatPer100g: fat,
      sugarPer100g: sugar,
      confidence: _analysisState.result?.confidence ?? 0.5,
    ).toFoodItem();

    try {
      await appState.addOrUpdateFood(
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
    if (error is OpenAIAuthenticationError) {
      return 'API-Key ungültig. Bitte überprüfe deine Konfiguration.';
    } else if (error is OpenAIRateLimitError) {
      return 'Zu viele Anfragen. Bitte warte einen Moment.';
    } else if (error is OpenAIServerError) {
      return 'API-Fehler (${error.statusCode}): ${error.message}';
    } else if (error is OpenAIJsonParseError) {
      return 'Die Antwort konnte nicht verarbeitet werden. Bitte versuche es erneut.';
    } else if (error is OpenAIInputValidationError) {
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
                  Text(
                    'AI Erkennung',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Eingabebereich ──
              if (!_analysisState.hasResult) ...[
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

  Widget _buildImageSection() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_camera, color: theme.colorScheme.onSurfaceVariant, size: 20),
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

  Widget _buildDescriptionField() {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Textbeschreibung des Lebensmittels',
      child: TextField(
        controller: _descriptionController,
        maxLines: 2,
        maxLength: 1000,
        decoration: InputDecoration(
          labelText: 'Beschreibung (optional)',
          hintText: 'z.B. 200g Spaghetti Bolognese',
          prefixIcon: const Icon(Icons.edit_note),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceSection() {
    final isRecording =
        _analysisState.status == AiFoodAnalysisStatus.recording;
    final isTranscribing =
        _analysisState.status == AiFoodAnalysisStatus.transcribing;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.mic, color: theme.colorScheme.onSurfaceVariant, size: 20),
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
                        label: 'Stop',
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
    final hasInput = _selectedImage != null ||
        _descriptionController.text.trim().isNotEmpty;
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
              disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.12),
              disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.38),
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
    return Container(
      key: const ValueKey('analyzing'),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bild/Text wird analysiert...',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dies kann einige Sekunden dauern',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
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
    final grams = int.tryParse(_quantityController.text) ?? 0;
    final calPer100 = int.tryParse(_caloriesController.text) ?? 0;
    final previewCalories = (calPer100 * grams) / 100.0;

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

          // Nährwerte pro 100g Header
          Text(
            'Nährwerte pro 100g',
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
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
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
              'Vorschau: ${previewCalories.toStringAsFixed(0)} kcal bei ${_quantityController.text} g',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),

          // Notes
          if (_analysisState.result?.notes != null &&
              _analysisState.result!.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _analysisState.result!.notes!,
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
            border: Border.all(color: color?.withOpacity(0.4) ?? theme.colorScheme.outline.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color ?? theme.colorScheme.onSurfaceVariant, size: 20),
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
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
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
