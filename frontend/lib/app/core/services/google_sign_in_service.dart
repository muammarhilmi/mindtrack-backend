import 'package:google_sign_in/google_sign_in.dart';

import '../constants/api_constants.dart';

class GoogleSignInService {
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (!_isInitialized) {
      await GoogleSignIn.instance.initialize(
        clientId: ApiConstants.googleWebClientId,
      );
      _isInitialized = true;
    }
  }

  static Future<String?> signInAndGetIdToken() async {
    await init();
    try {
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      return null;
    }
  }
}

