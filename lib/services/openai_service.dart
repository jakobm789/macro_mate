// lib/services/openai_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/food_analysis_result.dart';

/// Custom Exception-Typen für differenziertes Error-Handling.
class OpenAIAuthenticationError implements Exception {
  final String message;
  OpenAIAuthenticationError(this.message);
  @override
  String toString() => 'Authentifizierungsfehler: $message';
}

class OpenAIRateLimitError implements Exception {
  final String message;
  OpenAIRateLimitError(this.message);
  @override
  String toString() => 'Rate-Limit erreicht: $message';
}

class OpenAIServerError implements Exception {
  final String message;
  final int statusCode;
  OpenAIServerError(this.message, this.statusCode);
  @override
  String toString() => 'Server-Fehler ($statusCode): $message';
}

class OpenAIJsonParseError implements Exception {
  final String message;
  OpenAIJsonParseError(this.message);
  @override
  String toString() => 'JSON-Parsing-Fehler: $message';
}

class OpenAIInputValidationError implements Exception {
  final String message;
  OpenAIInputValidationError(this.message);
  @override
  String toString() => message;
}

/// Zentraler Service für OpenAI API-Aufrufe (Whisper + GPT-5.4-nano).
///
/// Unterstützt:
/// - Audio-Transkription via Whisper
/// - Lebensmittelanalyse via GPT-5.4-nano (multimodal: Bild + Text)
///
/// Features:
/// - Retry-Logik mit exponential backoff (max 2 Retries)
/// - Request-Timeout: 30s
/// - Input-Validierung (Dateigröße, Format)
/// - Anonymisiertes Logging (nur Metriken, keine Inhalte)
class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _visionModel = 'gpt-5.4-nano';
  static const String _whisperModel = 'whisper-1';
  static const int _maxRetries = 2;
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxAudioSizeBytes = 25 * 1024 * 1024; // 25 MB
  static const int _maxImageSizeBytes = 20 * 1024 * 1024; // 20 MB
  static const int _maxTextLength = 1000;

  final String _apiKey;
  final http.Client _client;

  OpenAIService({http.Client? client})
      : _apiKey = const String.fromEnvironment('OPENAI_API_KEY'),
        _client = client ?? http.Client() {
    if (_apiKey.isEmpty) {
      throw OpenAIAuthenticationError(
        'OPENAI_API_KEY ist nicht gesetzt. '
        'Bitte als --dart-define übergeben.',
      );
    }
  }

  /// Transkribiert eine Audio-Datei via OpenAI Whisper API.
  ///
  /// Unterstützte Formate: m4a, mp3, wav, webm, mp4, mpeg, mpga, oga, ogg.
  /// Max. Dateigröße: 25 MB.
  ///
  /// Gibt den transkribierten Text zurück.
  Future<String> transcribeAudio(String filePath) async {
    final file = File(filePath);

    // Validierung
    if (!await file.exists()) {
      throw OpenAIInputValidationError('Audio-Datei nicht gefunden.');
    }

    final fileSize = await file.length();
    if (fileSize > _maxAudioSizeBytes) {
      throw OpenAIInputValidationError(
        'Audio-Datei ist zu groß (${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB). '
        'Maximum: 25 MB.',
      );
    }

    final allowedExtensions = [
      'm4a', 'mp3', 'wav', 'webm', 'mp4', 'mpeg', 'mpga', 'oga', 'ogg',
    ];
    final ext = filePath.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(ext)) {
      throw OpenAIInputValidationError(
        'Audio-Format ".$ext" wird nicht unterstützt. '
        'Erlaubt: ${allowedExtensions.join(", ")}.',
      );
    }

    final stopwatch = Stopwatch()..start();

    final response = await _retryRequest(() async {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/audio/transcriptions'),
      );
      request.headers['Authorization'] = 'Bearer $_apiKey';
      request.fields['model'] = _whisperModel;
      request.fields['language'] = 'de';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await _client.send(request).timeout(_timeout);
      return await http.Response.fromStream(streamedResponse);
    });

    stopwatch.stop();
    _logMetrics('transcribe', _whisperModel, stopwatch.elapsed, null);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final text = body['text'] as String? ?? '';

    if (text.trim().isEmpty) {
      throw OpenAIJsonParseError(
        'Whisper hat keinen Text erkannt. Bitte versuche es erneut.',
      );
    }

    return text.trim();
  }

  /// Analysiert ein Lebensmittel anhand von Bild und/oder Text.
  ///
  /// Mindestens eins von [imagePath] oder [textDescription] muss angegeben werden.
  /// Gibt ein [FoodAnalysisResult] mit Nährwerten pro 100g zurück.
  Future<FoodAnalysisResult> analyzeFood({
    String? imagePath,
    String? textDescription,
  }) async {
    // Validierung: mindestens eine Eingabe
    if ((imagePath == null || imagePath.isEmpty) &&
        (textDescription == null || textDescription.trim().isEmpty)) {
      throw OpenAIInputValidationError(
        'Bitte gib mindestens ein Foto oder eine Beschreibung ein.',
      );
    }

    // Text-Länge begrenzen
    if (textDescription != null && textDescription.length > _maxTextLength) {
      textDescription = textDescription.substring(0, _maxTextLength);
    }

    // Bild validieren und base64-encodieren
    String? imageBase64;
    if (imagePath != null && imagePath.isNotEmpty) {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw OpenAIInputValidationError('Bild-Datei nicht gefunden.');
      }

      final imageSize = await imageFile.length();
      if (imageSize > _maxImageSizeBytes) {
        throw OpenAIInputValidationError(
          'Bild ist zu groß (${(imageSize / 1024 / 1024).toStringAsFixed(1)} MB). '
          'Maximum: 20 MB.',
        );
      }

      final bytes = await imageFile.readAsBytes();
      imageBase64 = base64Encode(bytes);
    }

    // Messages für GPT aufbauen
    final messages = _buildFoodAnalysisMessages(
      imageBase64: imageBase64,
      textDescription: textDescription?.trim(),
      imagePath: imagePath,
    );

    final stopwatch = Stopwatch()..start();

    final response = await _retryRequest(() async {
      return await _client
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _visionModel,
              'messages': messages,
              'response_format': {'type': 'json_object'},
              'max_tokens': 500,
              'temperature': 0.3,
            }),
          )
          .timeout(_timeout);
    });

    stopwatch.stop();

    // JSON-Antwort parsen
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = body['choices'] as List<dynamic>?;

    if (choices == null || choices.isEmpty) {
      throw OpenAIJsonParseError('Keine Antwort vom Modell erhalten.');
    }

    final content =
        choices[0]['message']?['content'] as String? ?? '';

    if (content.isEmpty) {
      throw OpenAIJsonParseError('Leere Antwort vom Modell erhalten.');
    }

    try {
      final foodJson = jsonDecode(content) as Map<String, dynamic>;
      final result = FoodAnalysisResult.fromJson(foodJson);

      _logMetrics(
        'analyze',
        _visionModel,
        stopwatch.elapsed,
        result.confidence,
      );

      return result;
    } on FormatException catch (e) {
      throw OpenAIJsonParseError(
        'Die Antwort konnte nicht verarbeitet werden: ${e.message}',
      );
    }
  }

  /// Baut die Messages-Liste für die Lebensmittelanalyse.
  List<Map<String, dynamic>> _buildFoodAnalysisMessages({
    String? imageBase64,
    String? textDescription,
    String? imagePath,
  }) {
    const systemPrompt = '''Du bist ein Ernährungsexperte und Lebensmittel-Analyst. 
Analysiere das bereitgestellte Bild und/oder die Textbeschreibung und schätze die Nährwerte.

WICHTIG: Gib alle Nährwerte PRO 100g an, nicht für die gesamte Portion.
Schätze außerdem das Gesamtgewicht der sichtbaren Portion in Gramm.

Antworte AUSSCHLIESSLICH mit einem JSON-Objekt in folgendem Format:
{
  "name": "Name des Lebensmittels/Gerichts",
  "brand": "Marke falls erkennbar, sonst 'Unbekannt'",
  "estimated_weight_grams": 350,
  "calories_per_100g": 150,
  "protein_per_100g": 12.0,
  "carbs_per_100g": 18.5,
  "fat_per_100g": 3.2,
  "sugar_per_100g": 2.1,
  "confidence": 0.85,
  "notes": "Kurze Erklärung zur Schätzung"
}

Regeln:
- "confidence" ist ein Wert zwischen 0.0 und 1.0, der deine Sicherheit ausdrückt.
- Bei unklaren Bildern oder vagen Beschreibungen: confidence < 0.7 setzen.
- Alle Nährwerte als Zahlen, keine Strings.
- Gewicht in Gramm als ganze Zahl.
- Kalorien als ganze Zahl pro 100g.
- Makros als Dezimalzahlen mit einer Nachkommastelle pro 100g.
- Bei reiner Textbeschreibung ohne Mengenangabe: Standardportion schätzen.
- Sprache: Deutsch für name und notes.''';

    // User-Content zusammenbauen (Text + optional Bild)
    final userContent = <Map<String, dynamic>>[];

    if (textDescription != null && textDescription.isNotEmpty) {
      userContent.add({
        'type': 'text',
        'text': textDescription,
      });
    }

    if (imageBase64 != null) {
      // MIME-Type aus Dateiendung ableiten
      final ext = (imagePath ?? '').split('.').last.toLowerCase();
      final mimeType = _imageMimeType(ext);

      userContent.add({
        'type': 'image_url',
        'image_url': {
          'url': 'data:$mimeType;base64,$imageBase64',
          'detail': 'high',
        },
      });
    }

    // Falls nur ein Bild ohne Text → Standardanweisung hinzufügen
    if ((textDescription == null || textDescription.isEmpty) &&
        imageBase64 != null) {
      userContent.insert(0, {
        'type': 'text',
        'text': 'Analysiere dieses Lebensmittel/Gericht und schätze die Nährwerte pro 100g.',
      });
    }

    return [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userContent},
    ];
  }

  /// MIME-Type für Bild-Dateien.
  String _imageMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Führt einen HTTP-Request mit Retry-Logik aus.
  ///
  /// Max [_maxRetries] Wiederholungen mit exponential backoff.
  /// Wirft spezifische Exceptions je nach HTTP-Statuscode.
  Future<http.Response> _retryRequest(
    Future<http.Response> Function() requestFn,
  ) async {
    int attempt = 0;

    while (true) {
      try {
        final response = await requestFn();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }

        // Spezifische Fehler behandeln
        if (response.statusCode == 401) {
          throw OpenAIAuthenticationError(
            'Ungültiger API-Key. Bitte überprüfe deine Konfiguration.',
          );
        }

        if (response.statusCode == 429) {
          if (attempt < _maxRetries) {
            attempt++;
            final delay = Duration(seconds: pow(2, attempt).toInt());
            await Future.delayed(delay);
            continue;
          }
          throw OpenAIRateLimitError(
            'Zu viele Anfragen. Bitte versuche es in einer Minute erneut.',
          );
        }

        if (response.statusCode >= 500) {
          if (attempt < _maxRetries) {
            attempt++;
            final delay = Duration(seconds: pow(2, attempt).toInt());
            await Future.delayed(delay);
            continue;
          }
          throw OpenAIServerError(
            'OpenAI-Server ist nicht erreichbar. Bitte versuche es später.',
            response.statusCode,
          );
        }

        // Sonstige Client-Fehler
        String errorMsg = 'Unbekannter Fehler (${response.statusCode})';
        try {
          final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
          errorMsg = errorBody['error']?['message'] as String? ?? errorMsg;
        } catch (_) {}

        throw OpenAIServerError(errorMsg, response.statusCode);
      } on TimeoutException {
        if (attempt < _maxRetries) {
          attempt++;
          final delay = Duration(seconds: pow(2, attempt).toInt());
          await Future.delayed(delay);
          continue;
        }
        throw OpenAIServerError(
          'Zeitüberschreitung. Bitte überprüfe deine Internetverbindung.',
          0,
        );
      } on SocketException {
        if (attempt < _maxRetries) {
          attempt++;
          final delay = Duration(seconds: pow(2, attempt).toInt());
          await Future.delayed(delay);
          continue;
        }
        throw OpenAIServerError(
          'Keine Internetverbindung. Bitte überprüfe dein Netzwerk.',
          0,
        );
      }
    }
  }

  /// Anonymisiertes Logging — nur Metriken, keine Inhalte.
  void _logMetrics(
    String operation,
    String model,
    Duration duration,
    double? confidence,
  ) {
    final metrics = {
      'op': operation,
      'model': model,
      'duration_ms': duration.inMilliseconds,
      if (confidence != null) 'confidence': confidence,
      'timestamp': DateTime.now().toIso8601String(),
    };
    // ignore: avoid_print
    print('[OpenAI Metrics] $metrics');
  }

  /// Gibt Ressourcen frei.
  void dispose() {
    _client.close();
  }
}
