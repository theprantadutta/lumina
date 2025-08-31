import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumina/shared/models/journal_entry.dart';

class JournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'journal_entries';

  // Create a new journal entry
  Future<void> createJournalEntry(JournalEntry journalEntry) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(journalEntry.id)
          .set(journalEntry.toJson());
    } catch (e) {
      throw Exception('Failed to create journal entry: $e');
    }
  }

  // Get journal entries for a specific user
  Future<List<JournalEntry>> getJournalEntries({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    JournalTemplate? template,
    List<String>? tags,
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

      if (template != null) {
        query = query.where('template', isEqualTo: template.name);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final QuerySnapshot querySnapshot = await query.get();

      List<JournalEntry> entries = querySnapshot.docs
          .map(
            (doc) => JournalEntry.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Filter by tags if specified (client-side filtering)
      if (tags != null && tags.isNotEmpty) {
        entries = entries.where((entry) {
          return tags.any((tag) => entry.tags.contains(tag));
        }).toList();
      }

      return entries;
    } catch (e) {
      throw Exception('Failed to get journal entries: $e');
    }
  }

  // Get journal entries for a specific date
  Future<List<JournalEntry>> getJournalEntriesForDate({
    required String userId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return getJournalEntries(
      userId: userId,
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  // Get journal entry by ID
  Future<JournalEntry?> getJournalEntryById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();

      if (doc.exists) {
        return JournalEntry.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get journal entry: $e');
    }
  }

  // Update journal entry
  Future<void> updateJournalEntry(JournalEntry journalEntry) async {
    try {
      final updatedEntry = JournalEntry(
        id: journalEntry.id,
        userId: journalEntry.userId,
        title: journalEntry.title,
        content: journalEntry.content,
        tags: journalEntry.tags,
        imageUrls: journalEntry.imageUrls,
        audioUrl: journalEntry.audioUrl,
        gratitudeList: journalEntry.gratitudeList,
        timestamp: journalEntry.timestamp,
        createdAt: journalEntry.createdAt,
        updatedAt: DateTime.now(),
        isFavorite: journalEntry.isFavorite,
        mood: journalEntry.mood,
        weather: journalEntry.weather,
        location: journalEntry.location,
        template: journalEntry.template,
      );

      await _firestore
          .collection(_collection)
          .doc(journalEntry.id)
          .update(updatedEntry.toJson());
    } catch (e) {
      throw Exception('Failed to update journal entry: $e');
    }
  }

  // Delete journal entry
  Future<void> deleteJournalEntry(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete journal entry: $e');
    }
  }

  // Get journal entries stream for real-time updates
  Stream<List<JournalEntry>> getJournalEntriesStream({
    required String userId,
    int? limit,
    JournalTemplate? template,
  }) {
    Query query = _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true);

    if (template != null) {
      query = query.where('template', isEqualTo: template.name);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((querySnapshot) {
      return querySnapshot.docs
          .map(
            (doc) => JournalEntry.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  // Search journal entries by content or title
  Future<List<JournalEntry>> searchJournalEntries({
    required String userId,
    required String searchQuery,
    int? limit,
  }) async {
    try {
      // Note: Firestore doesn't have built-in full-text search
      // This is a basic implementation that searches in title and content
      final entries = await getJournalEntries(
        userId: userId,
        limit: limit ?? 50,
      );

      final searchWords = searchQuery.toLowerCase().split(' ');

      return entries.where((entry) {
        final titleLower = entry.title.toLowerCase();
        final contentLower = entry.content.toLowerCase();

        return searchWords.any(
          (word) => titleLower.contains(word) || contentLower.contains(word),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to search journal entries: $e');
    }
  }

  // Get favorite journal entries
  Future<List<JournalEntry>> getFavoriteJournalEntries({
    required String userId,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isFavorite', isEqualTo: true)
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs
          .map(
            (doc) => JournalEntry.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get favorite journal entries: $e');
    }
  }

  // Get journal statistics for a user
  Future<JournalStatistics> getJournalStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final entries = await getJournalEntries(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (entries.isEmpty) {
        return JournalStatistics(
          totalEntries: 0,
          totalWords: 0,
          averageWordsPerEntry: 0.0,
          mostUsedTemplate: null,
          mostCommonMood: null,
          favoriteCount: 0,
          entriesWithImages: 0,
          gratitudeCount: 0,
          longestStreak: 0,
          currentStreak: 0,
        );
      }

      // Calculate total words
      final totalWords = entries.fold<int>(
        0,
        (total, entry) => total + entry.content.split(' ').length,
      );

      // Calculate average words per entry
      final averageWordsPerEntry = totalWords / entries.length;

      // Find most used template
      final templateCounts = <JournalTemplate, int>{};
      for (final entry in entries) {
        templateCounts[entry.template] =
            (templateCounts[entry.template] ?? 0) + 1;
      }

      final mostUsedTemplate = templateCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      // Find most common mood
      final moodCounts = <JournalMood, int>{};
      for (final entry in entries) {
        moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
      }

      final mostCommonMood = moodCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      // Count favorites
      final favoriteCount = entries.where((entry) => entry.isFavorite).length;

      // Count entries with images
      final entriesWithImages = entries
          .where((entry) => entry.imageUrls.isNotEmpty)
          .length;

      // Count total gratitude items
      final gratitudeCount = entries.fold<int>(
        0,
        (total, entry) => total + entry.gratitudeList.length,
      );

      // Calculate streaks (simplified version)
      final currentStreak = _calculateCurrentStreak(entries);
      final longestStreak = _calculateLongestStreak(entries);

      return JournalStatistics(
        totalEntries: entries.length,
        totalWords: totalWords,
        averageWordsPerEntry: averageWordsPerEntry,
        mostUsedTemplate: mostUsedTemplate,
        mostCommonMood: mostCommonMood,
        favoriteCount: favoriteCount,
        entriesWithImages: entriesWithImages,
        gratitudeCount: gratitudeCount,
        longestStreak: longestStreak,
        currentStreak: currentStreak,
      );
    } catch (e) {
      throw Exception('Failed to get journal statistics: $e');
    }
  }

  // Get all unique tags used by a user
  Future<List<String>> getUserTags({required String userId, int? limit}) async {
    try {
      final entries = await getJournalEntries(
        userId: userId,
        limit: limit ?? 100,
      );

      final Set<String> allTags = {};
      for (final entry in entries) {
        allTags.addAll(entry.tags);
      }

      final tagsList = allTags.toList()..sort();
      return tagsList;
    } catch (e) {
      throw Exception('Failed to get user tags: $e');
    }
  }

  // Helper methods for streak calculation
  int _calculateCurrentStreak(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0;

    // Sort entries by date (most recent first)
    final sortedEntries = List<JournalEntry>.from(entries)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int streak = 0;
    DateTime? lastDate;

    for (final entry in sortedEntries) {
      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      if (lastDate == null) {
        // First entry
        lastDate = entryDate;
        streak = 1;
      } else {
        final daysDifference = lastDate.difference(entryDate).inDays;

        if (daysDifference == 1) {
          // Consecutive day
          streak++;
          lastDate = entryDate;
        } else if (daysDifference > 1) {
          // Gap found, break the streak
          break;
        }
        // daysDifference == 0 means same day, continue without incrementing
      }
    }

    return streak;
  }

  int _calculateLongestStreak(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0;

    // Group entries by date
    final Map<DateTime, List<JournalEntry>> entriesByDate = {};
    for (final entry in entries) {
      final date = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      entriesByDate.putIfAbsent(date, () => []).add(entry);
    }

    // Get unique dates and sort them
    final uniqueDates = entriesByDate.keys.toList()..sort();

    if (uniqueDates.isEmpty) return 0;

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < uniqueDates.length; i++) {
      final previousDate = uniqueDates[i - 1];
      final currentDate = uniqueDates[i];

      if (currentDate.difference(previousDate).inDays == 1) {
        currentStreak++;
        longestStreak = longestStreak > currentStreak
            ? longestStreak
            : currentStreak;
      } else {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }
}

class JournalStatistics {
  final int totalEntries;
  final int totalWords;
  final double averageWordsPerEntry;
  final JournalTemplate? mostUsedTemplate;
  final JournalMood? mostCommonMood;
  final int favoriteCount;
  final int entriesWithImages;
  final int gratitudeCount;
  final int longestStreak;
  final int currentStreak;

  const JournalStatistics({
    required this.totalEntries,
    required this.totalWords,
    required this.averageWordsPerEntry,
    required this.mostUsedTemplate,
    required this.mostCommonMood,
    required this.favoriteCount,
    required this.entriesWithImages,
    required this.gratitudeCount,
    required this.longestStreak,
    required this.currentStreak,
  });
}
