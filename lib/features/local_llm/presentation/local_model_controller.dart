import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/local_llm_model.dart';
import '../../../services/llm_service.dart';

class LocalModelController extends ChangeNotifier {
  LocalModelController() {
    _selectedModel = LocalLlmModel.supported.first;
  }

  static const String _storedModelKey = 'selected_local_llm_model';

  late LocalLlmModel _selectedModel;
  LocalLlmModel get selectedModel => _selectedModel;

  List<LocalLlmModel> get supportedModels => LocalLlmModel.supported;

  bool _isInstalled = false;
  bool get isInstalled => _isInstalled;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  int _downloadProgress = 0;
  int get downloadProgress => _downloadProgress;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  bool get isAndroid => Platform.isAndroid;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_storedModelKey);
      if (stored != null) {
        _selectedModel = LocalLlmModel.byStoredName(stored);
      }
    } catch (_) {}
    await checkModelStatus();
  }

  Future<void> selectModel(LocalLlmModel model) async {
    _selectedModel = model;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storedModelKey, model.id.name);
    } catch (_) {}
    await checkModelStatus();
  }

  Future<void> checkModelStatus() async {
    if (!Platform.isAndroid) {
      _isInstalled = false;
      _statusMessage =
          'Lokale LLM-Inferenz wird auf dieser Plattform nicht unterstützt.';
      notifyListeners();
      return;
    }

    try {
      final service = LlmService(selectedModel: _selectedModel);
      _isInstalled = await service.isSelectedModelInstalled();
      _statusMessage = _isInstalled
          ? 'Modell ist installiert und einsatzbereit.'
          : 'Modell ist noch nicht heruntergeladen.';
    } catch (e) {
      _isInstalled = false;
      _statusMessage = 'Status konnte nicht geprüft werden: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> downloadSelectedModel() async {
    if (!Platform.isAndroid || _isDownloading) return;

    _isDownloading = true;
    _downloadProgress = 0;
    _statusMessage = 'Download startet...';
    notifyListeners();

    try {
      final service = LlmService(selectedModel: _selectedModel);
      await service.ensureSelectedModelAvailable(
        allowDownload: true,
        onDownloadProgress: (progress) {
          _downloadProgress = progress;
          _statusMessage = 'Download: $progress%';
          notifyListeners();
        },
      );
      _isInstalled = true;
      _statusMessage = 'Modell erfolgreich installiert!';
    } catch (e) {
      _statusMessage = 'Download fehlgeschlagen: $e';
    } finally {
      _isDownloading = false;
      notifyListeners();
      await checkModelStatus();
    }
  }
}
