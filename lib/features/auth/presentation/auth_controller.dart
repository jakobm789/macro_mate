import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';

import '../../../core/logging/app_logger.dart';
import '../../../services/remote_database_service.dart';
import '../../settings/presentation/settings_controller.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required SettingsController settingsController,
    RemoteDatabaseService? remoteService,
    AppLogger logger = const AppLogger(),
  })  : _settingsController = settingsController,
        _remoteService = remoteService ?? RemoteDatabaseService(),
        _logger = logger;

  final SettingsController _settingsController;
  final RemoteDatabaseService _remoteService;
  final AppLogger _logger;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _currentUserEmail;
  String? get currentUserEmail => _currentUserEmail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final email = await _settingsController.getSavedEmail();
      final password = await _settingsController.getSavedPassword();

      if (email != null && password != null && email.isNotEmpty && password.isNotEmpty) {
        _currentUserEmail = email;
        _isLoggedIn = true;
      }
    } catch (e) {
      _logger.error('initialize_auth', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _remoteService.getUserByEmail(email.trim());
      if (user != null) {
        final isVerified = user['is_verified'] == true;
        final hash = user['password_hash'] as String?;
        if (isVerified && hash != null && BCrypt.checkpw(password, hash)) {
          await _settingsController.saveCredentials(email.trim(), password);
          _currentUserEmail = email.trim();
          _isLoggedIn = true;
          return true;
        }
      }
      _errorMessage = 'Ungültige Anmeldedaten oder Konto nicht bestätigt.';
      return false;
    } catch (e) {
      _errorMessage = 'Anmeldefehler: $e';
      _logger.error('login', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerUser(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final existing = await _remoteService.getUserByEmail(email.trim());
      if (existing != null) {
        _errorMessage = 'Diese E-Mail ist bereits registriert.';
        return false;
      }

      final salt = BCrypt.gensalt();
      final hash = BCrypt.hashpw(password, salt);
      final code = (100000 + Random().nextInt(900000)).toString();

      await _remoteService.insertUserWithVerification(email.trim(), hash, code);
      return true;
    } catch (e) {
      _errorMessage = 'Registrierungsfehler: $e';
      _logger.error('register', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyAccount(String email, String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _remoteService.getUserByEmail(email.trim());
      if (user == null) {
        _errorMessage = 'Benutzer nicht gefunden.';
        return false;
      }
      if (user['verification_code'] == code.trim()) {
        await _remoteService.verifyUser(email.trim());
        return true;
      }
      _errorMessage = 'Falscher Bestätigungscode.';
      return false;
    } catch (e) {
      _errorMessage = 'Bestätigungsfehler: $e';
      _logger.error('verify_account', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _settingsController.clearCredentials();
      _isLoggedIn = false;
      _currentUserEmail = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount({required Future<void> Function() onLocalReset}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final email = _currentUserEmail ?? await _settingsController.getSavedEmail();
      if (email != null && email.isNotEmpty) {
        try {
          await _remoteService.deleteUserByEmail(email);
        } catch (e) {
          _logger.warning('Remote user delete error: $e');
        }
      }
      await _settingsController.clearCredentials();
      await onLocalReset();
      _isLoggedIn = false;
      _currentUserEmail = null;
      return true;
    } catch (e) {
      _logger.error('delete_account', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
