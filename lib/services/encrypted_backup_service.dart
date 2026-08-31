import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/helpers.dart';

class EncryptedBackupService {
  EncryptedBackupService({AesGcm? cipher, Pbkdf2? kdf})
      : _cipher = cipher ?? AesGcm.with256bits(),
        _kdf = kdf ?? Pbkdf2.hmacSha256(iterations: 210000, bits: 256);

  static const format = 'macromate-backup-encrypted';
  static const formatVersion = 3;
  static const maxSchemaVersion = 27;
  static const _aad = <int>[77, 97, 99, 114, 111, 77, 97, 116, 101, 47, 51];

  final AesGcm _cipher;
  final Pbkdf2 _kdf;

  Future<String> encrypt(
    Map<String, dynamic> payload, {
    required String password,
    String appVersion = '1.0.0',
    int schemaVersion = 27,
  }) async {
    _validatePassword(password);
    final salt = randomBytes(16);
    final key =
        await _kdf.deriveKeyFromPassword(password: password, nonce: salt);
    final clearText = utf8.encode(jsonEncode(payload));
    final box = await _cipher.encrypt(clearText, secretKey: key, aad: _aad);
    return jsonEncode({
      'format': format,
      'format_version': formatVersion,
      'algorithm': 'AES-256-GCM',
      'kdf': 'PBKDF2-HMAC-SHA256',
      'kdf_iterations': _kdf.iterations,
      'salt': base64UrlEncode(salt),
      'ciphertext': base64UrlEncode(box.concatenation()),
      'app_version': appVersion,
      'schema_version': schemaVersion,
      'created_at_utc': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> decrypt(
    String encryptedJson, {
    required String password,
  }) async {
    _validatePassword(password);
    final dynamic envelope;
    try {
      envelope = jsonDecode(encryptedJson);
    } catch (_) {
      throw const FormatException('Backup-Envelope ist ungültig.');
    }
    if (envelope is! Map || envelope['format'] != format) {
      throw const FormatException(
          'Unbekanntes oder nicht verschlüsseltes Backup-Format.');
    }
    final envelopeVersion = envelope['format_version'];
    if (envelopeVersion is! int ||
        envelopeVersion < 2 ||
        envelopeVersion > formatVersion ||
        envelope['algorithm'] != 'AES-256-GCM' ||
        envelope['kdf'] != 'PBKDF2-HMAC-SHA256') {
      throw const FormatException(
          'Nicht unterstützte Backup-Version oder Kryptografie.');
    }
    final schemaVersion = envelope['schema_version'];
    if (schemaVersion is! int || schemaVersion > maxSchemaVersion) {
      throw const FormatException(
          'Dieses Backup benötigt eine neuere App-Version.');
    }
    final salt = base64Url.decode(envelope['salt'] as String);
    final bytes = base64Url.decode(envelope['ciphertext'] as String);
    final box = SecretBox.fromConcatenation(
      bytes,
      nonceLength: _cipher.nonceLength,
      macLength: _cipher.macAlgorithm.macLength,
    );
    final key =
        await _kdf.deriveKeyFromPassword(password: password, nonce: salt);
    final clearText = await _cipher.decrypt(
      box,
      secretKey: key,
      aad: envelopeVersion == formatVersion
          ? _aad
          : const [77, 97, 99, 114, 111, 77, 97, 116, 101, 47, 2],
    );
    final payload = jsonDecode(utf8.decode(clearText));
    if (payload is! Map) {
      throw const FormatException('Backup-Payload ist ungültig.');
    }
    return Map<String, dynamic>.from(payload);
  }

  void _validatePassword(String password) {
    if (password.length < 8) {
      throw ArgumentError.value(
        password.length,
        'password',
        'Das Backup-Passwort muss mindestens 8 Zeichen enthalten.',
      );
    }
  }
}
