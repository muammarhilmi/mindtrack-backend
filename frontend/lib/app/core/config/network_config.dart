import 'package:flutter_dotenv/flutter_dotenv.dart';

class NetworkConfig {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://swan-compactor-revenge.ngrok-free.dev';

  static String? token;
}