import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive caching service for performance optimization
class CacheService {
  static const String _cacheBoxName = 'lumina_cache';
  static const String _userDataBoxName = 'user_data';
  static const String _analyticsBoxName = 'analytics_cache';
  
  static late Box _cacheBox;
  static late Box _userDataBox;
  static late Box _analyticsBox;
  static SharedPreferences? _prefs;

  /// Initialize cache service
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    _cacheBox = await Hive.openBox(_cacheBoxName);
    _userDataBox = await Hive.openBox(_userDataBoxName);
    _analyticsBox = await Hive.openBox(_analyticsBoxName);
    _prefs = await SharedPreferences.getInstance();
    
    debugPrint('✅ Cache service initialized');
  }

  /// Generic cache operations
  static Future<void> set(String key, dynamic value, {Duration? expiry}) async {
    final cacheItem = CacheItem(
      value: value,
      timestamp: DateTime.now(),
      expiry: expiry,
    );
    
    await _cacheBox.put(key, cacheItem.toJson());
  }

  static T? get<T>(String key) {
    final data = _cacheBox.get(key);
    if (data == null) return null;
    
    final cacheItem = CacheItem.fromJson(data);
    
    // Check if expired
    if (cacheItem.isExpired) {
      _cacheBox.delete(key);
      return null;
    }
    
    return cacheItem.value as T?;
  }

  /// User-specific data caching (persists longer)
  static Future<void> setUserData(String key, dynamic value) async {
    await _userDataBox.put(key, value);
  }

  static T? getUserData<T>(String key) {
    return _userDataBox.get(key) as T?;
  }

  /// Analytics data caching (optimized for frequent reads)
  static Future<void> setAnalyticsData(String key, dynamic value, {Duration? expiry}) async {
    final cacheItem = CacheItem(
      value: value,
      timestamp: DateTime.now(),
      expiry: expiry ?? const Duration(minutes: 30),
    );
    
    await _analyticsBox.put(key, cacheItem.toJson());
  }

  static T? getAnalyticsData<T>(String key) {
    final data = _analyticsBox.get(key);
    if (data == null) return null;
    
    final cacheItem = CacheItem.fromJson(data);
    
    if (cacheItem.isExpired) {
      _analyticsBox.delete(key);
      return null;
    }
    
    return cacheItem.value as T?;
  }

  /// Image caching utilities
  static Future<void> cacheImage(String url, Uint8List data) async {
    final key = 'image_${url.hashCode}';
    await set(key, data, expiry: const Duration(days: 7));
  }

  static Uint8List? getCachedImage(String url) {
    final key = 'image_${url.hashCode}';
    return get<Uint8List>(key);
  }

  /// Mood entry caching
  static Future<void> cacheMoodEntries(List<Map<String, dynamic>> entries) async {
    await setUserData('mood_entries', entries);
    await _prefs?.setString('mood_entries_timestamp', DateTime.now().toIso8601String());
  }

  static List<Map<String, dynamic>>? getCachedMoodEntries() {
    final timestampStr = _prefs?.getString('mood_entries_timestamp');
    if (timestampStr == null) return null;
    
    final timestamp = DateTime.parse(timestampStr);
    final isStale = DateTime.now().difference(timestamp) > const Duration(hours: 1);
    
    if (isStale) {
      _userDataBox.delete('mood_entries');
      _prefs?.remove('mood_entries_timestamp');
      return null;
    }
    
    final entries = getUserData<List<dynamic>>('mood_entries');
    return entries?.cast<Map<String, dynamic>>();
  }

  /// Analytics caching with smart invalidation
  static Future<void> cacheAnalytics(String period, Map<String, dynamic> data) async {
    final key = 'analytics_$period';
    await setAnalyticsData(key, data, expiry: const Duration(minutes: 15));
  }

  static Map<String, dynamic>? getCachedAnalytics(String period) {
    final key = 'analytics_$period';
    return getAnalyticsData<Map<String, dynamic>>(key);
  }

  /// Settings caching
  static Future<void> cacheSettings(Map<String, dynamic> settings) async {
    await setUserData('app_settings', settings);
  }

  static Map<String, dynamic>? getCachedSettings() {
    return getUserData<Map<String, dynamic>>('app_settings');
  }

  /// Clear expired cache entries
  static Future<void> clearExpired() async {
    final keysToDelete = <String>[];
    
    for (final key in _cacheBox.keys) {
      final data = _cacheBox.get(key);
      if (data != null) {
        final cacheItem = CacheItem.fromJson(data);
        if (cacheItem.isExpired) {
          keysToDelete.add(key);
        }
      }
    }
    
    for (final key in keysToDelete) {
      await _cacheBox.delete(key);
    }
    
    debugPrint('🧹 Cleared ${keysToDelete.length} expired cache entries');
  }

  /// Clear all cache
  static Future<void> clearAll() async {
    await _cacheBox.clear();
    await _analyticsBox.clear();
    debugPrint('🗑️ Cache cleared');
  }

  /// Clear user data (for logout)
  static Future<void> clearUserData() async {
    await _userDataBox.clear();
    await _prefs?.clear();
    debugPrint('👤 User data cleared');
  }

  /// Get cache statistics
  static CacheStats getStats() {
    return CacheStats(
      totalEntries: _cacheBox.length + _userDataBox.length + _analyticsBox.length,
      cacheEntries: _cacheBox.length,
      userDataEntries: _userDataBox.length,
      analyticsEntries: _analyticsBox.length,
    );
  }

  /// Pre-warm cache with essential data
  static Future<void> preWarmCache() async {
    // This would be called during app startup to cache frequently used data
    debugPrint('🔥 Pre-warming cache...');
    
    // Example: Pre-cache recent mood entries
    // Example: Pre-cache user preferences
    // Example: Pre-cache frequently accessed analytics
  }

  /// Batch operations for performance
  static Future<void> batchSet(Map<String, dynamic> keyValues) async {
    final futures = keyValues.entries.map((entry) =>
        set(entry.key, entry.value),
    );
    
    await Future.wait(futures);
  }

  /// Memory optimization - compress large data
  static Future<void> setCompressed(String key, dynamic value, {Duration? expiry}) async {
    final jsonString = jsonEncode(value);
    final compressed = gzip.encode(utf8.encode(jsonString));
    
    final cacheItem = CacheItem(
      value: compressed,
      timestamp: DateTime.now(),
      expiry: expiry,
      isCompressed: true,
    );
    
    await _cacheBox.put(key, cacheItem.toJson());
  }

  static T? getCompressed<T>(String key) {
    final data = _cacheBox.get(key);
    if (data == null) return null;
    
    final cacheItem = CacheItem.fromJson(data);
    
    if (cacheItem.isExpired) {
      _cacheBox.delete(key);
      return null;
    }
    
    if (cacheItem.isCompressed) {
      final compressed = cacheItem.value as List<int>;
      final decompressed = gzip.decode(compressed);
      final jsonString = utf8.decode(decompressed);
      return jsonDecode(jsonString) as T;
    }
    
    return cacheItem.value as T?;
  }
}

/// Cache item wrapper
class CacheItem {
  final dynamic value;
  final DateTime timestamp;
  final Duration? expiry;
  final bool isCompressed;

  const CacheItem({
    required this.value,
    required this.timestamp,
    this.expiry,
    this.isCompressed = false,
  });

  bool get isExpired {
    if (expiry == null) return false;
    return DateTime.now().difference(timestamp) > expiry!;
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
      'isCompressed': isCompressed,
    };
  }

  factory CacheItem.fromJson(Map<String, dynamic> json) {
    return CacheItem(
      value: json['value'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      expiry: json['expiry'] != null ? Duration(milliseconds: json['expiry']) : null,
      isCompressed: json['isCompressed'] ?? false,
    );
  }
}

/// Cache statistics
class CacheStats {
  final int totalEntries;
  final int cacheEntries;
  final int userDataEntries;
  final int analyticsEntries;

  const CacheStats({
    required this.totalEntries,
    required this.cacheEntries,
    required this.userDataEntries,
    required this.analyticsEntries,
  });

  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, cache: $cacheEntries, userData: $userDataEntries, analytics: $analyticsEntries)';
  }
}

/// Memory optimization utilities
class MemoryOptimizer {
  /// Optimize images for display
  static Future<Uint8List?> optimizeImage(Uint8List imageData, {
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) async {
    // This would use image processing to reduce size
    // For now, returning original data
    return imageData;
  }

  /// Monitor memory usage
  static void logMemoryUsage() {
    // This would track memory metrics
    debugPrint('📊 Memory usage logging...');
  }
}

