import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'UniManager';
  static const String appVersion = '1.0.0';

  // Change cette URL selon ton environnement :
  //   - ngrok (partage externe) : https://dude-flock-excusable.ngrok-free.dev/api
  //   - Téléphone physique (WiFi local) : http://10.82.83.181:8000/api
  //   - Émulateur Android : http://10.0.2.2:8000/api
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  static String get baseUrl {
    if (kReleaseMode) return _baseUrl;
    if (kIsWeb) return 'http://localhost:8000/api';
    return _baseUrl;
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  static const int cacheMaxAgeMinutes = 15;
  static const int paginationPerPage = 20;

  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
}
