import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Comprehensive offline support service
class OfflineService {
  static const String _offlineQueueBox = 'offline_queue';
  static const String _syncStatusBox = 'sync_status';
  
  static late Box _offlineQueue;
  static late Box _syncStatus;
  static bool _isInitialized = false;
  
  static final StreamController<bool> _connectivityController = 
      StreamController<bool>.broadcast();
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  static bool _isOnline = true;
  static DateTime? _lastSyncTime;

  /// Initialize offline service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _offlineQueue = await Hive.openBox(_offlineQueueBox);
      _syncStatus = await Hive.openBox(_syncStatusBox);
      
      // Setup connectivity monitoring
      await _setupConnectivityMonitoring();
      
      // Load last sync time
      final syncTimestamp = _syncStatus.get('last_sync');
      if (syncTimestamp != null) {
        _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(syncTimestamp);
      }
      
      _isInitialized = true;
      debugPrint('📶 Offline service initialized');
      
      // Sync pending items if online
      if (_isOnline) {
        unawaited(_processPendingItems());
      }
    } catch (e) {
      debugPrint('❌ Failed to initialize offline service: $e');
    }
  }

  /// Setup connectivity monitoring
  static Future<void> _setupConnectivityMonitoring() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOnline = _isOnline;
        _isOnline = !results.contains(ConnectivityResult.none);
        
        _connectivityController.add(_isOnline);
        
        // Process pending items when coming back online
        if (!wasOnline && _isOnline) {
          debugPrint('📶 Connection restored - syncing pending items');
          unawaited(_processPendingItems());
        } else if (wasOnline && !_isOnline) {
          debugPrint('📶 Connection lost - entering offline mode');
        }
      },
    );
  }

  /// Connectivity status stream
  static Stream<bool> get connectivityStream => _connectivityController.stream;
  
  /// Current online status
  static bool get isOnline => _isOnline;
  
  /// Last sync time
  static DateTime? get lastSyncTime => _lastSyncTime;
  
  /// Time since last sync
  static Duration? get timeSinceLastSync {
    if (_lastSyncTime == null) return null;
    return DateTime.now().difference(_lastSyncTime!);
  }

  /// Add item to offline queue
  static Future<void> addToQueue(OfflineItem item) async {
    await _offlineQueue.add(item.toJson());
    debugPrint('📝 Added to offline queue: ${item.type} - ${item.id}');
  }

  /// Remove item from offline queue
  static Future<void> removeFromQueue(String id) async {
    final keysToRemove = <dynamic>[];
    
    for (final key in _offlineQueue.keys) {
      final data = _offlineQueue.get(key);
      if (data != null && data['id'] == id) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      await _offlineQueue.delete(key);
    }
  }

  /// Get pending items count
  static int get pendingItemsCount => _offlineQueue.length;

  /// Get pending items by type
  static List<OfflineItem> getPendingItems({OfflineItemType? type}) {
    final items = <OfflineItem>[];
    
    for (final data in _offlineQueue.values) {
      final item = OfflineItem.fromJson(data);
      if (type == null || item.type == type) {
        items.add(item);
      }
    }
    
    return items..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Process all pending items
  static Future<void> _processPendingItems() async {
    if (!_isOnline || _offlineQueue.isEmpty) return;
    
    final pendingItems = getPendingItems();
    final failedItems = <OfflineItem>[];
    
    debugPrint('🔄 Processing ${pendingItems.length} pending items');
    
    for (final item in pendingItems) {
      try {
        await _processOfflineItem(item);
        await removeFromQueue(item.id);
        debugPrint('✅ Synced: ${item.type} - ${item.id}');
      } catch (e) {
        debugPrint('❌ Failed to sync: ${item.type} - ${item.id}: $e');
        failedItems.add(item);
        
        // Increment retry count
        item.retryCount++;
        if (item.retryCount >= 3) {
          debugPrint('🚫 Max retries reached for: ${item.id}');
          await removeFromQueue(item.id);
        }
      }
    }
    
    // Update sync status
    await _updateSyncStatus(
      totalProcessed: pendingItems.length,
      failed: failedItems.length,
    );
  }

  /// Process individual offline item
  static Future<void> _processOfflineItem(OfflineItem item) async {
    switch (item.type) {
      case OfflineItemType.moodEntry:
        await _syncMoodEntry(item);
        break;
      case OfflineItemType.journalEntry:
        await _syncJournalEntry(item);
        break;
      case OfflineItemType.userProfile:
        await _syncUserProfile(item);
        break;
      case OfflineItemType.settings:
        await _syncSettings(item);
        break;
      case OfflineItemType.achievement:
        await _syncAchievement(item);
        break;
    }
  }

  /// Sync mood entry
  static Future<void> _syncMoodEntry(OfflineItem item) async {
    final firestore = FirebaseFirestore.instance;
    
    if (item.operation == OfflineOperation.create) {
      await firestore.collection('mood_entries').doc(item.id).set(item.data);
    } else if (item.operation == OfflineOperation.update) {
      await firestore.collection('mood_entries').doc(item.id).update(item.data);
    } else if (item.operation == OfflineOperation.delete) {
      await firestore.collection('mood_entries').doc(item.id).delete();
    }
  }

  /// Sync journal entry
  static Future<void> _syncJournalEntry(OfflineItem item) async {
    final firestore = FirebaseFirestore.instance;
    
    if (item.operation == OfflineOperation.create) {
      await firestore.collection('journal_entries').doc(item.id).set(item.data);
    } else if (item.operation == OfflineOperation.update) {
      await firestore.collection('journal_entries').doc(item.id).update(item.data);
    } else if (item.operation == OfflineOperation.delete) {
      await firestore.collection('journal_entries').doc(item.id).delete();
    }
  }

  /// Sync user profile
  static Future<void> _syncUserProfile(OfflineItem item) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('user_profiles').doc(item.id).update(item.data);
  }

  /// Sync settings
  static Future<void> _syncSettings(OfflineItem item) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('user_settings').doc(item.id).set(item.data);
  }

  /// Sync achievement
  static Future<void> _syncAchievement(OfflineItem item) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('user_achievements').doc(item.id).set(item.data);
  }

  /// Update sync status
  static Future<void> _updateSyncStatus({
    required int totalProcessed,
    required int failed,
  }) async {
    _lastSyncTime = DateTime.now();
    
    await _syncStatus.put('last_sync', _lastSyncTime!.millisecondsSinceEpoch);
    await _syncStatus.put('last_sync_total', totalProcessed);
    await _syncStatus.put('last_sync_failed', failed);
    
    debugPrint('📊 Sync complete: $totalProcessed processed, $failed failed');
  }

  /// Manual sync trigger
  static Future<bool> forceSyncPendingItems() async {
    if (!_isOnline) {
      debugPrint('❌ Cannot sync - device is offline');
      return false;
    }
    
    try {
      await _processPendingItems();
      return true;
    } catch (e) {
      debugPrint('❌ Force sync failed: $e');
      return false;
    }
  }

  /// Get sync statistics
  static Map<String, dynamic> getSyncStats() {
    return {
      'pendingItems': pendingItemsCount,
      'lastSync': _lastSyncTime?.toIso8601String(),
      'timeSinceLastSync': timeSinceLastSync?.inMinutes,
      'isOnline': _isOnline,
      'lastSyncTotal': _syncStatus.get('last_sync_total', defaultValue: 0),
      'lastSyncFailed': _syncStatus.get('last_sync_failed', defaultValue: 0),
    };
  }

  /// Clear all offline data
  static Future<void> clearOfflineData() async {
    await _offlineQueue.clear();
    await _syncStatus.clear();
    _lastSyncTime = null;
    debugPrint('🗑️ Offline data cleared');
  }

  /// Dispose resources
  static Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _connectivityController.close();
  }
}

/// Offline item types
enum OfflineItemType {
  moodEntry,
  journalEntry,
  userProfile,
  settings,
  achievement,
}

/// Offline operations
enum OfflineOperation {
  create,
  update,
  delete,
}

/// Offline item model
class OfflineItem {
  final String id;
  final OfflineItemType type;
  final OfflineOperation operation;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  int retryCount;

  OfflineItem({
    required this.id,
    required this.type,
    required this.operation,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'operation': operation.name,
      'data': data,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'retryCount': retryCount,
    };
  }

  factory OfflineItem.fromJson(Map<String, dynamic> json) {
    return OfflineItem(
      id: json['id'],
      type: OfflineItemType.values.byName(json['type']),
      operation: OfflineOperation.values.byName(json['operation']),
      data: Map<String, dynamic>.from(json['data']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      retryCount: json['retryCount'] ?? 0,
    );
  }
}

/// Offline-aware widget wrapper
class OfflineAware extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context)? offlineBuilder;
  final bool showOfflineIndicator;

  const OfflineAware({
    super.key,
    required this.child,
    this.offlineBuilder,
    this.showOfflineIndicator = true,
  });

  @override
  State<OfflineAware> createState() => _OfflineAwareState();
}

class _OfflineAwareState extends State<OfflineAware> {
  bool _isOnline = true;
  late StreamSubscription<bool> _subscription;

  @override
  void initState() {
    super.initState();
    _isOnline = OfflineService.isOnline;
    
    _subscription = OfflineService.connectivityStream.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOnline && widget.offlineBuilder != null) {
      return widget.offlineBuilder!(context);
    }

    return Stack(
      children: [
        widget.child,
        if (!_isOnline && widget.showOfflineIndicator)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange[700],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Offline mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (OfflineService.pendingItemsCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${OfflineService.pendingItemsCount} pending',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Utility extension for Future operations
extension UnawaiteExtension<T> on Future<T> {
  void get unawaited {}
}