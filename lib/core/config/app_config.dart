import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig._();

  static const _defaultBaseUrl = 'http://10.0.2.2:3000/api/v1';

  static String get apiBaseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.trim().isNotEmpty) {
      return envUrl.trim();
    }

    const defineUrl = String.fromEnvironment('API_BASE_URL');
    if (defineUrl.isNotEmpty) {
      return defineUrl;
    }

    return _defaultBaseUrl;
  }

  static const playbackTokenTtlMinutes = 10;
  static const discoveryCacheMinutes = 5;
}
