import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumina/shared/models/mood_entry.dart';

class MoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'mood_entries';

  // Create a new mood entry
  Future<void> createMoodEntry(MoodEntry moodEntry) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(moodEntry.id)
          .set(moodEntry.toJson());
    } catch (e) {
      throw Exception('Failed to create mood entry: $e');
    }
  }

  // Get mood entries for a specific user
  Future<List<MoodEntry>> getMoodEntries({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true);

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => MoodEntry.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get mood entries: $e');
    }
  }

  // Get mood entries for a specific date
  Future<List<MoodEntry>> getMoodEntriesForDate({
    required String userId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return getMoodEntries(
      userId: userId,
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  // Get mood entry by ID
  Future<MoodEntry?> getMoodEntryById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();

      if (doc.exists) {
        return MoodEntry.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get mood entry: $e');
    }
  }

  // Update mood entry
  Future<void> updateMoodEntry(MoodEntry moodEntry) async {
    try {
      final updatedEntry = MoodEntry(
        id: moodEntry.id,
        userId: moodEntry.userId,
        mood: moodEntry.mood,
        intensity: moodEntry.intensity,
        note: moodEntry.note,
        factors: moodEntry.factors,
        timestamp: moodEntry.timestamp,
        createdAt: moodEntry.createdAt,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(moodEntry.id)
          .update(updatedEntry.toJson());
    } catch (e) {
      throw Exception('Failed to update mood entry: $e');
    }
  }

  // Delete mood entry
  Future<void> deleteMoodEntry(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete mood entry: $e');
    }
  }

  // Get mood entries stream for real-time updates
  Stream<List<MoodEntry>> getMoodEntriesStream({
    required String userId,
    int? limit,
  }) {
    Query query = _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => MoodEntry.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get mood statistics for a user
  Future<MoodStatistics> getMoodStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final entries = await getMoodEntries(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (entries.isEmpty) {
        return MoodStatistics(
          totalEntries: 0,
          averageMood: 0.0,
          mostCommonMood: null,
          averageIntensity: 0.0,
        );
      }

      // Calculate average intensity
      final totalIntensity = entries.fold<double>(
        0.0,
        (total, entry) => total + entry.intensity,
      );
      final averageIntensity = totalIntensity / entries.length;

      // Calculate average mood (using baseIntensity as numeric value)
      final totalMoodValue = entries.fold<double>(
        0.0,
        (total, entry) => total + entry.mood.baseIntensity,
      );
      final averageMood = totalMoodValue / entries.length;

      // Find most common mood
      final moodCounts = <MoodType, int>{};
      for (final entry in entries) {
        moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
      }

      final mostCommonMood = moodCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      return MoodStatistics(
        totalEntries: entries.length,
        averageMood: averageMood,
        mostCommonMood: mostCommonMood,
        averageIntensity: averageIntensity,
      );
    } catch (e) {
      throw Exception('Failed to get mood statistics: $e');
    }
  }

  // Get mood trends over time
  Future<List<MoodTrendPoint>> getMoodTrends({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    TrendPeriod period = TrendPeriod.daily,
  }) async {
    try {
      final entries = await getMoodEntries(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final Map<DateTime, List<MoodEntry>> groupedEntries = {};

      for (final entry in entries) {
        DateTime key;
        switch (period) {
          case TrendPeriod.daily:
            key = DateTime(
              entry.timestamp.year,
              entry.timestamp.month,
              entry.timestamp.day,
            );
            break;
          case TrendPeriod.weekly:
            final daysSinceMonday = entry.timestamp.weekday - 1;
            key = entry.timestamp.subtract(Duration(days: daysSinceMonday));
            key = DateTime(key.year, key.month, key.day);
            break;
          case TrendPeriod.monthly:
            key = DateTime(entry.timestamp.year, entry.timestamp.month, 1);
            break;
        }

        groupedEntries.putIfAbsent(key, () => []).add(entry);
      }

      return groupedEntries.entries.map((entry) {
        final date = entry.key;
        final entries = entry.value;

        final averageIntensity =
            entries.fold<double>(0.0, (total, e) => total + e.intensity) /
            entries.length;

        final averageMood =
            entries.fold<double>(
              0.0,
              (total, e) => total + e.mood.baseIntensity,
            ) /
            entries.length;

        return MoodTrendPoint(
          date: date,
          averageIntensity: averageIntensity,
          averageMood: averageMood,
          entryCount: entries.length,
        );
      }).toList()..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      throw Exception('Failed to get mood trends: $e');
    }
  }
}

class MoodStatistics {
  final int totalEntries;
  final double averageMood;
  final MoodType? mostCommonMood;
  final double averageIntensity;

  const MoodStatistics({
    required this.totalEntries,
    required this.averageMood,
    required this.mostCommonMood,
    required this.averageIntensity,
  });
}

class MoodTrendPoint {
  final DateTime date;
  final double averageIntensity;
  final double averageMood;
  final int entryCount;

  const MoodTrendPoint({
    required this.date,
    required this.averageIntensity,
    required this.averageMood,
    required this.entryCount,
  });
}

enum TrendPeriod { daily, weekly, monthly }
