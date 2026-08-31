import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/services/encrypted_backup_service.dart';

void main() {
  test('encrypts and decrypts a versioned backup envelope', () async {
    final service = EncryptedBackupService();
    final encrypted = await service.encrypt(
      {
        'health_records': [],
        'cycle_profiles': [
          {'id': 1}
        ]
      },
      password: 'correct horse battery staple',
    );
    final envelope = jsonDecode(encrypted) as Map<String, dynamic>;
    expect(envelope['format'], EncryptedBackupService.format);
    expect(envelope['algorithm'], 'AES-256-GCM');
    expect(envelope['ciphertext'], isNot(contains('health_records')));
    final payload = await service.decrypt(
      encrypted,
      password: 'correct horse battery staple',
    );
    expect(payload['health_records'], isEmpty);
    expect((payload['cycle_profiles'] as List).single['id'], 1);
  });

  test('rejects a wrong password and weak passwords', () async {
    final service = EncryptedBackupService();
    final encrypted = await service.encrypt({'ok': true}, password: '12345678');
    expect(
      () => service.decrypt(encrypted, password: '87654321'),
      throwsA(isA<SecretBoxAuthenticationError>()),
    );
    expect(
      () => service.encrypt({}, password: 'short'),
      throwsArgumentError,
    );
  });
}
