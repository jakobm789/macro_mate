// lib/widgets/ai_food_sheet.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

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
/// 4. Sprachaufnahme → Whisper-Transkription → Text-Analyse
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
  final AudioRecorder _audioRecorder = AudioRecorder();

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

  // --- Farben ---
  static const _accentColor = Color(0xFF64FFDA);
  static const _recordingColor = Color(0xFFFF5252);
  static const _successColor = Color(0xFF69F0AE);
  static const _warningColor = Color(0xFFFFD740);
  static const _errorColor = Color(0xFFFF5252);
  static const _cardColor = Color(0xFF2A2A2A);

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.mealName;
    try {
      _openAiService = OpenAIService();
    } catch (e) {
      _analysisState = AiFoodAnalysisState.error(_humanReadableError(e));
    }
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
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
    _audioRecorder.dispose();
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
  // Audio-Aufnahme
  // ──────────────────────────────────────────────

  Future<void> _startRecording() async {
    try {
      if (!await _audioRecorder.hasPermission()) {
        _showSnackBar('Mikrofon-Berechtigung nicht erteilt.');
        return;
      }

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/ai_food_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

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
    } catch (e) {
      _showSnackBar('Fehler beim Starten der Aufnahme: $e');
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    try {
      final path = await _audioRecorder.stop();
      if (path == null || !mounted) return;

      // Automatisch transkribieren
      setState(() {
        _analysisState = AiFoodAnalysisState.transcribing();
      });

      try {
        if (_openAiService == null) {
          throw OpenAIAuthenticationError(
            'OPENAI_API_KEY ist nicht gesetzt. Bitte als --dart-define übergeben.',
          );
        }
        final text = await _openAiService!.transcribeAudio(path);
        if (!mounted) return;

        setState(() {
          _descriptionController.text = text;
          _analysisState = AiFoodAnalysisState.idle(transcribedText: text);
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _analysisState = AiFoodAnalysisState.error(
            _humanReadableError(e),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analysisState = AiFoodAnalysisState.error(
            'Fehler beim Stoppen der Aufnahme: $e',
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
      await _audioRecorder.stop();
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
      return 'Server nicht erreichbar. Bitte prüfe deine Internetverbindung.';
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
                    color: Colors.white24,
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
                      color: Colors.white,
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
              Icon(Icons.photo_camera, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                'Foto',
                style: TextStyle(
                  color: Colors.white70,
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
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
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
    return Semantics(
      label: 'Textbeschreibung des Lebensmittels',
      child: TextField(
        controller: _descriptionController,
        maxLines: 2,
        maxLength: 1000,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Beschreibung (optional)',
          hintText: 'z.B. 200g Spaghetti Bolognese',
          hintStyle: TextStyle(color: Colors.white30),
          labelStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.edit_note, color: Colors.white54),
          filled: true,
          fillColor: _cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _accentColor, width: 1.5),
          ),
          counterStyle: TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  Widget _buildVoiceSection() {
    final isRecording =
        _analysisState.status == AiFoodAnalysisStatus.recording;
    final isTranscribing =
        _analysisState.status == AiFoodAnalysisStatus.transcribing;

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
              Icon(Icons.mic, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                'Spracheingabe',
                style: TextStyle(
                  color: Colors.white70,
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
                    fontFeatures: [FontFeature.tabularFigures()],
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
            icon: Icon(Icons.search, size: 20),
            label: Text(
              'Analysieren',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.white12,
              disabledForegroundColor: Colors.white38,
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
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dies kann einige Sekunden dauern',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
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
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetToIdle,
              icon: Icon(Icons.refresh, size: 18),
              label: Text('Erneut versuchen'),
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
    // Live-Vorschau berechnen
    final grams = int.tryParse(_quantityController.text) ?? 0;
    final calPer100 = int.tryParse(_caloriesController.text) ?? 0;
    final previewCalories = (calPer100 * grams) / 100.0;

    return Container(
      key: ValueKey(isLowConfidence ? 'fallback' : 'success'),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: _cardColor,
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
            dropdownColor: const Color(0xFF3A3A3A),
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
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),

          // Name
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: Colors.white),
            decoration: _inputDecoration('Name'),
          ),
          const SizedBox(height: 12),

          // Marke
          TextFormField(
            controller: _brandController,
            style: TextStyle(color: Colors.white),
            decoration: _inputDecoration('Marke'),
          ),
          const SizedBox(height: 12),

          // Menge
          TextFormField(
            controller: _quantityController,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Geschätzte Menge (g)'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Nährwerte pro 100g Header
          Text(
            'Nährwerte pro 100g',
            style: TextStyle(
              color: Colors.white54,
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
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Kalorien (kcal)'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _proteinController,
                  style: TextStyle(color: Colors.white),
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
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
                  style: TextStyle(color: Colors.white),
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('Kohlenhydrate (g)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _fatController,
                  style: TextStyle(color: Colors.white),
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('Fett (g)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _sugarController,
            style: TextStyle(color: Colors.white),
            keyboardType:
                TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration('Zucker (g)'),
          ),
          const SizedBox(height: 16),

          // Vorschau
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Vorschau: ${previewCalories.toStringAsFixed(0)} kcal bei ${_quantityController.text} g',
              style: TextStyle(
                color: Colors.white54,
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
                color: Colors.white38,
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
              icon: Icon(Icons.check, size: 20),
              label: Text(
                'Zur Mahlzeit hinzufügen',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.black,
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
                style: TextStyle(color: Colors.white54),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: color?.withOpacity(0.4) ?? Colors.white24),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color ?? Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color ?? Colors.white70,
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
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white54, fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _accentColor, width: 1),
      ),
      isDense: true,
    );
  }
}
