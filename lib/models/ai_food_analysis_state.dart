// lib/models/ai_food_analysis_state.dart
import 'food_analysis_result.dart';

/// Explizite UI-Zustände der AI-Lebensmittelanalyse.
enum AiFoodAnalysisStatus {
  /// Eingabefelder sichtbar, keine Aktion läuft.
  idle,

  /// Mikrofon-Aufnahme aktiv, Timer läuft.
  recording,

  /// Sprache wird lokal transkribiert.
  transcribing,

  /// Bild/Text wird lokal analysiert.
  analyzing,

  /// Analyse erfolgreich (Confidence ≥ 0.7).
  success,

  /// Fehler aufgetreten.
  error,

  /// Unsichere Schätzung (Confidence < 0.7).
  fallback,
}

/// Immutable State-Objekt für die AI-Analyse-UI.
class AiFoodAnalysisState {
  final AiFoodAnalysisStatus status;
  final FoodAnalysisResult? result;
  final String? errorMessage;
  final Duration recordingDuration;
  final String? transcribedText;

  const AiFoodAnalysisState._({
    required this.status,
    this.result,
    this.errorMessage,
    this.recordingDuration = Duration.zero,
    this.transcribedText,
  });

  /// Initialzustand: Eingabefelder sichtbar.
  factory AiFoodAnalysisState.idle({String? transcribedText}) =>
      AiFoodAnalysisState._(
        status: AiFoodAnalysisStatus.idle,
        transcribedText: transcribedText,
      );

  /// Mikrofon-Aufnahme läuft.
  factory AiFoodAnalysisState.recording(Duration duration) =>
      AiFoodAnalysisState._(
        status: AiFoodAnalysisStatus.recording,
        recordingDuration: duration,
      );

  /// Lokale Spracherkennung verarbeitet Audio.
  factory AiFoodAnalysisState.transcribing() =>
      const AiFoodAnalysisState._(status: AiFoodAnalysisStatus.transcribing);

  /// Lokales Modell analysiert Bild/Text.
  factory AiFoodAnalysisState.analyzing() =>
      const AiFoodAnalysisState._(status: AiFoodAnalysisStatus.analyzing);

  /// Analyse erfolgreich mit hoher Konfidenz.
  factory AiFoodAnalysisState.success(FoodAnalysisResult result) =>
      AiFoodAnalysisState._(
        status: AiFoodAnalysisStatus.success,
        result: result,
      );

  /// Fehler aufgetreten.
  factory AiFoodAnalysisState.error(String message) => AiFoodAnalysisState._(
        status: AiFoodAnalysisStatus.error,
        errorMessage: message,
      );

  /// Unsichere Schätzung — Werte manuell überprüfen.
  factory AiFoodAnalysisState.fallback(FoodAnalysisResult result) =>
      AiFoodAnalysisState._(
        status: AiFoodAnalysisStatus.fallback,
        result: result,
      );

  /// Prüft ob ein Ergebnis vorliegt (success oder fallback).
  bool get hasResult =>
      status == AiFoodAnalysisStatus.success ||
      status == AiFoodAnalysisStatus.fallback;

  /// Prüft ob eine Aktion läuft (recording, transcribing, analyzing).
  bool get isProcessing =>
      status == AiFoodAnalysisStatus.recording ||
      status == AiFoodAnalysisStatus.transcribing ||
      status == AiFoodAnalysisStatus.analyzing;
}
