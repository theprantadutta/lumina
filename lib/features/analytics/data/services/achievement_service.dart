import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumina/features/analytics/data/models/achievement.dart';
import 'package:lumina/shared/models/mood_entry.dart';
import 'package:lumina/shared/models/journal_entry.dart';

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserProgress> getUserProgress(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_progress')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserProgress.fromJson(doc.data()!);
      } else {
        // Create new progress for user
        final newProgress = UserProgress(
          userId: userId,
          inProgressAchievements: AchievementDefinitions.defaultAchievements,
          lastUpdated: DateTime.now(),
        );
        
        await _saveUserProgress(newProgress);
        return newProgress;
      }
    } catch (e) {
      throw Exception('Failed to get user progress: $e');
    }
  }

  Future<void> _saveUserProgress(UserProgress progress) async {
    try {
      await _firestore
          .collection('user_progress')
          .doc(progress.userId)
          .set(progress.toJson());
    } catch (e) {
      throw Exception('Failed to save user progress: $e');
    }
  }

  Future<List<Achievement>> checkForNewAchievements({
    required String userId,
    List<MoodEntry>? recentMoodEntries,
    List<JournalEntry>? recentJournalEntries,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final progress = await getUserProgress(userId);
      final newlyUnlocked = <Achievement>[];

      // Check each in-progress achievement
      for (final achievement in progress.inProgressAchievements) {
        if (achievement.isUnlocked) continue;

        final currentProgress = await _calculateAchievementProgress(
          achievement,
          userId,
          recentMoodEntries,
          recentJournalEntries,
          additionalData,
        );

        if (currentProgress >= achievement.targetValue) {
          final unlockedAchievement = achievement.copyWith(
            isUnlocked: true,
            currentProgress: currentProgress,
            unlockedAt: DateTime.now(),
          );
          
          newlyUnlocked.add(unlockedAchievement);
        }
      }

      // Update progress if any achievements were unlocked
      if (newlyUnlocked.isNotEmpty) {
        await _updateProgressWithNewAchievements(progress, newlyUnlocked);
      }

      return newlyUnlocked;
    } catch (e) {
      throw Exception('Failed to check achievements: $e');
    }
  }

  Future<int> _calculateAchievementProgress(
    Achievement achievement,
    String userId,
    List<MoodEntry>? moodEntries,
    List<JournalEntry>? journalEntries,
    Map<String, dynamic>? additionalData,
  ) async {
    switch (achievement.id) {
      case 'first_mood':
        return (moodEntries?.isNotEmpty ?? false) ? 1 : 0;

      case 'first_journal':
        return (journalEntries?.isNotEmpty ?? false) ? 1 : 0;

      case 'mood_week_streak':
      case 'mood_month_streak':
        return await _calculateMoodStreak(userId);

      case 'journal_week_streak':
        return await _calculateJournalStreak(userId);

      case 'mood_100':
        return await _getTotalMoodEntries(userId);

      case 'long_entry':
        return await _getLongestJournalEntry(userId);

      case 'gratitude_master':
        return await _getTotalGratitudeItems(userId);

      case 'daily_double':
        return await _getDailyDoubleCount(userId);

      case 'consistency_king':
        return await _getConsistencyStreak(userId);

      case 'mood_improver':
        return await _getMoodImprovement(userId);

      case 'happy_week':
        return await _getHappyDayStreak(userId);

      case 'template_explorer':
        return await _getUniqueTemplatesUsed(userId);

      case 'mood_spectrum':
        return await _getUniqueMoodTypes(userId);

      case 'insight_seeker':
        return await _getTotalInsights(userId);

      case 'pattern_master':
        return await _getUniqueInsightTypes(userId);

      default:
        return achievement.currentProgress;
    }
  }

  Future<int> _calculateMoodStreak(String userId) async {
    try {
      final entries = await _firestore
          .collection('mood_entries')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      if (entries.docs.isEmpty) return 0;

      int streak = 0;
      DateTime? lastDate;

      for (final doc in entries.docs) {
        final entry = MoodEntry.fromJson(doc.data());
        final entryDate = DateTime(
          entry.timestamp.year,
          entry.timestamp.month,
          entry.timestamp.day,
        );

        if (lastDate == null) {
          lastDate = entryDate;
          streak = 1;
        } else {
          final daysDifference = lastDate.difference(entryDate).inDays;
          if (daysDifference == 1) {
            streak++;
            lastDate = entryDate;
          } else if (daysDifference > 1) {
            break;
          }
        }
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _calculateJournalStreak(String userId) async {
    try {
      final entries = await _firestore
          .collection('journal_entries')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      if (entries.docs.isEmpty) return 0;

      int streak = 0;
      DateTime? lastDate;

      for (final doc in entries.docs) {
        final entry = JournalEntry.fromJson(doc.data());
        final entryDate = DateTime(
          entry.timestamp.year,
          entry.timestamp.month,
          entry.timestamp.day,
        );

        if (lastDate == null) {
          lastDate = entryDate;
          streak = 1;
        } else {
          final daysDifference = lastDate.difference(entryDate).inDays;
          if (daysDifference == 1) {
            streak++;
            lastDate = entryDate;
          } else if (daysDifference > 1) {
            break;
          }
        }
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getTotalMoodEntries(String userId) async {
    try {
      final query = await _firestore
          .collection('mood_entries')
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      return query.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getLongestJournalEntry(String userId) async {
    try {
      final entries = await _firestore
          .collection('journal_entries')
          .where('userId', isEqualTo: userId)
          .get();

      int maxWords = 0;
      for (final doc in entries.docs) {
        final entry = JournalEntry.fromJson(doc.data());
        final wordCount = entry.content.split(' ').length;
        if (wordCount > maxWords) {
          maxWords = wordCount;
        }
      }
      return maxWords;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getTotalGratitudeItems(String userId) async {
    try {
      final entries = await _firestore
          .collection('journal_entries')
          .where('userId', isEqualTo: userId)
          .get();

      int totalGratitude = 0;
      for (final doc in entries.docs) {
        final entry = JournalEntry.fromJson(doc.data());
        totalGratitude += entry.gratitudeList.length;
      }
      return totalGratitude;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getDailyDoubleCount(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final moodQuery = _firestore
          .collection('mood_entries')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay);

      final journalQuery = _firestore
          .collection('journal_entries')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay);

      final results = await Future.wait([
        moodQuery.get(),
        journalQuery.get(),
      ]);

      return (results[0].docs.isNotEmpty && results[1].docs.isNotEmpty) ? 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getConsistencyStreak(String userId) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      
      int streak = 0;
      for (int i = 0; i < 30; i++) {
        final checkDate = endDate.subtract(Duration(days: i));
        final startOfDay = DateTime(checkDate.year, checkDate.month, checkDate.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final moodQuery = await _firestore
            .collection('mood_entries')
            .where('userId', isEqualTo: userId)
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .where('timestamp', isLessThan: endOfDay)
            .limit(1)
            .get();

        final journalQuery = await _firestore
            .collection('journal_entries')
            .where('userId', isEqualTo: userId)
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .where('timestamp', isLessThan: endOfDay)
            .limit(1)
            .get();

        if (moodQuery.docs.isNotEmpty && journalQuery.docs.isNotEmpty) {
          streak++;
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getMoodImprovement(String userId) async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final twoWeeksAgo = now.subtract(const Duration(days: 14));

      final thisWeekEntries = await _firestore
          .collection('mood_entries')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: weekAgo)
          .get();

      final lastWeekEntries = await _firestore
          .collection('mood_entries')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: twoWeeksAgo)
          .where('timestamp', isLessThan: weekAgo)
          .get();

      if (thisWeekEntries.docs.isEmpty || lastWeekEntries.docs.isEmpty) {
        return 0;
      }

      final thisWeekAvg = thisWeekEntries.docs
          .map((doc) => MoodEntry.fromJson(doc.data()).mood.baseIntensity)
          .reduce((a, b) => a + b) / thisWeekEntries.docs.length;

      final lastWeekAvg = lastWeekEntries.docs
          .map((doc) => MoodEntry.fromJson(doc.data()).mood.baseIntensity)
          .reduce((a, b) => a + b) / lastWeekEntries.docs.length;

      final improvement = thisWeekAvg - lastWeekAvg;
      return improvement >= 2.0 ? improvement.round() : 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getHappyDayStreak(String userId) async {
    try {
      final entries = await _firestore
          .collection('mood_entries')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      if (entries.docs.isEmpty) return 0;

      final dailyAverages = <DateTime, List<int>>{};
      
      for (final doc in entries.docs) {
        final entry = MoodEntry.fromJson(doc.data());
        final date = DateTime(
          entry.timestamp.year,
          entry.timestamp.month,
          entry.timestamp.day,
        );
        dailyAverages.putIfAbsent(date, () => [])
            .add(entry.mood.baseIntensity);
      }

      int streak = 0;
      final sortedDates = dailyAverages.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      for (final date in sortedDates) {
        final avgMood = dailyAverages[date]!.reduce((a, b) => a + b) / 
                       dailyAverages[date]!.length;
        
        if (avgMood >= 7.0) {
          streak++;
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getUniqueTemplatesUsed(String userId) async {
    try {
      final entries = await _firestore
          .collection('journal_entries')
          .where('userId', isEqualTo: userId)
          .get();

      final uniqueTemplates = <JournalTemplate>{};
      for (final doc in entries.docs) {
        final entry = JournalEntry.fromJson(doc.data());
        uniqueTemplates.add(entry.template);
      }

      return uniqueTemplates.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getUniqueMoodTypes(String userId) async {
    try {
      final entries = await _firestore
          .collection('mood_entries')
          .where('userId', isEqualTo: userId)
          .get();

      final uniqueMoods = <MoodType>{};
      for (final doc in entries.docs) {
        final entry = MoodEntry.fromJson(doc.data());
        uniqueMoods.add(entry.mood);
      }

      return uniqueMoods.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getTotalInsights(String userId) async {
    try {
      final query = await _firestore
          .collection('insights')
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      return query.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getUniqueInsightTypes(String userId) async {
    try {
      final insights = await _firestore
          .collection('insights')
          .where('userId', isEqualTo: userId)
          .get();

      final uniqueTypes = <String>{};
      for (final doc in insights.docs) {
        final data = doc.data();
        final type = data['type'] as String? ?? '';
        if (type.isNotEmpty) {
          uniqueTypes.add(type);
        }
      }

      return uniqueTypes.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _updateProgressWithNewAchievements(
    UserProgress currentProgress,
    List<Achievement> newAchievements,
  ) async {
    try {
      final updatedUnlocked = List<Achievement>.from(currentProgress.unlockedAchievements)
        ..addAll(newAchievements);

      final updatedInProgress = currentProgress.inProgressAchievements
          .map((achievement) {
            final newVersion = newAchievements
                .firstWhere((a) => a.id == achievement.id, orElse: () => achievement);
            return newVersion.isUnlocked ? newVersion : achievement;
          })
          .toList();

      final addedPoints = newAchievements
          .map((a) => AchievementDefinitions.getPointsForTier(a.tier))
          .fold<int>(0, (sum, points) => sum + points);

      final newTotalPoints = currentProgress.totalPoints + addedPoints;
      final newLevel = _calculateLevel(newTotalPoints);
      final newLevelProgress = _calculateLevelProgress(newTotalPoints, newLevel);
      final nextLevelReq = AchievementDefinitions.getLevelRequirement(newLevel + 1);

      final updatedProgress = currentProgress.copyWith(
        unlockedAchievements: updatedUnlocked,
        inProgressAchievements: updatedInProgress,
        totalPoints: newTotalPoints,
        currentLevel: newLevel,
        currentLevelProgress: newLevelProgress,
        nextLevelRequirement: nextLevelReq,
        lastUpdated: DateTime.now(),
      );

      await _saveUserProgress(updatedProgress);
    } catch (e) {
      throw Exception('Failed to update progress: $e');
    }
  }

  int _calculateLevel(int totalPoints) {
    int level = 1;
    int pointsNeeded = 0;

    while (pointsNeeded <= totalPoints) {
      pointsNeeded += AchievementDefinitions.getLevelRequirement(level);
      if (pointsNeeded <= totalPoints) {
        level++;
      }
    }

    return level;
  }

  int _calculateLevelProgress(int totalPoints, int currentLevel) {
    int pointsUsed = 0;
    for (int i = 1; i < currentLevel; i++) {
      pointsUsed += AchievementDefinitions.getLevelRequirement(i);
    }
    return totalPoints - pointsUsed;
  }

  Future<void> markAchievementAsNotified(String userId, String achievementId) async {
    try {
      final progress = await getUserProgress(userId);
      final updatedUnlocked = progress.unlockedAchievements.map((achievement) {
        if (achievement.id == achievementId) {
          return achievement.copyWith(isNotified: true);
        }
        return achievement;
      }).toList();

      final updatedProgress = progress.copyWith(
        unlockedAchievements: updatedUnlocked,
        lastUpdated: DateTime.now(),
      );

      await _saveUserProgress(updatedProgress);
    } catch (e) {
      throw Exception('Failed to mark achievement as notified: $e');
    }
  }
}