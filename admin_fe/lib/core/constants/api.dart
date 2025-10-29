// lib/core/constants/api.dart
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConstants {
  static String androidHost = '192.168.88.123'; // IP máy dev Android
  static String iosHost = 'localhost'; // iOS simulator
  static String webHost = 'localhost'; // Web
  static int port = 5000; // port backend

  static String get baseUrl {
    if (kIsWeb) return 'http://$webHost:$port';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://$androidHost:$port';
    } else {
      return 'http://$iosHost:$port';
    }
  }

  /// URL để load assets (ảnh)
  static String get assetUrl => '$baseUrl/assets';

  /// User API
  static String get users => '$baseUrl/api/users';
}
