import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../config/app_config.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

class CacheService {
  static const String _boxName = 'app_cache';
  static const String _responseBoxName = 'api_responses';
  late Box<String> _cacheBox;
  late Box<String> _responseBox;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox<String>(_boxName);
    _responseBox = await Hive.openBox<String>(_responseBoxName);
    _initialized = true;
  }

  Future<void> cacheResponse(String key, String data, {int? maxAgeMinutes}) async {
    final expiry = DateTime.now().add(
      Duration(minutes: maxAgeMinutes ?? AppConfig.cacheMaxAgeMinutes),
    );
    final cacheEntry = jsonEncode({
      'data': data,
      'expiry': expiry.toIso8601String(),
    });
    await _responseBox.put(key, cacheEntry);
  }

  String? getCachedResponse(String key) {
    final entry = _responseBox.get(key);
    if (entry == null) return null;
    try {
      final decoded = jsonDecode(entry) as Map<String, dynamic>;
      final expiry = DateTime.parse(decoded['expiry'] as String);
      if (DateTime.now().isAfter(expiry)) {
        _responseBox.delete(key);
        return null;
      }
      return decoded['data'] as String;
    } catch (_) {
      _responseBox.delete(key);
      return null;
    }
  }

  Future<void> clearCache() async {
    await _responseBox.clear();
  }

  Future<void> clearExpired() async {
    final keys = _responseBox.keys.toList();
    for (final key in keys) {
      final entry = _responseBox.get(key);
      if (entry == null) continue;
      try {
        final decoded = jsonDecode(entry) as Map<String, dynamic>;
        final expiry = DateTime.parse(decoded['expiry'] as String);
        if (DateTime.now().isAfter(expiry)) {
          await _responseBox.delete(key);
        }
      } catch (_) {
        await _responseBox.delete(key);
      }
    }
  }

  Future<void> cachePreference(String key, String value) async {
    await _cacheBox.put(key, value);
  }

  String? getPreference(String key) {
    return _cacheBox.get(key);
  }

  Future<void> removePreference(String key) async {
    await _cacheBox.delete(key);
  }

  Future<void> clearAll() async {
    await _cacheBox.clear();
    await _responseBox.clear();
  }

  int get cachedItemsCount => _responseBox.length;
}
