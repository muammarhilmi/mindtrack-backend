import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage =
      FlutterSecureStorage();

  static const _tokenKey =
      'access_token';

  static const _onboardingKey =
      'onboarding_done';

  static Future<void> saveToken(
    String token,
  ) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  static Future<String?>
      getToken() async {
    return await _storage.read(
      key: _tokenKey,
    );
  }

  static Future<void>
      deleteToken() async {
    await _storage.delete(
      key: _tokenKey,
    );
  }

  static Future<void>
      setOnboardingDone() async {
    await _storage.write(
      key: _onboardingKey,
      value: 'true',
    );
  }

  static Future<bool>
      isOnboardingDone() async {
    final value =
        await _storage.read(
      key: _onboardingKey,
    );

    return value == 'true';
  }
}