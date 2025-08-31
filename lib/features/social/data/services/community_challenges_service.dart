import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/shared/models/social_models.dart';

class CommunityChallengesService {
  static const String _challengesCollection = 'community_challenges';
  static const String _participationCollection = 'challenge_participation';
  static const String _leaderboardCollection = 'challenge_leaderboards';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create a new community challenge
  Future<String> createChallenge({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required ChallengeType type,
    required Map<String, dynamic> requirements,
    required ChallengePrivacy privacy,
    String? imageUrl,
    int maxParticipants = 100,
    List<String> tags = const [],
    Map<String, dynamic>? rewards,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    if (startDate.isAfter(endDate)) {
      throw Exception('Start date cannot be after end date');
    }

    final challenge = CommunityChallenge(
      id: '',
      title: title,
      description: description,
      imageUrl: imageUrl,
      startDate: startDate,
      endDate: endDate,
      createdBy: user.uid,
      type: type,
      requirements: requirements,
      participantIds: [],
      maxParticipants: maxParticipants,
      privacy: privacy,
      tags: tags,
      rewards: rewards,
    );

    final docRef = await _firestore
        .collection(_challengesCollection)
        .add(challenge.toJson());

    await docRef.update({'id': docRef.id});

    return docRef.id;
  }

  /// Get available challenges
  Stream<List<CommunityChallenge>> getAvailableChallenges({
    ChallengeType? type,
    ChallengePrivacy? privacy,
    List<String>? tags,
    bool activeOnly = true,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(_challengesCollection)
        .orderBy('startDate', descending: true)
        .limit(limit);

    if (activeOnly) {
      final now = DateTime.now();
      query = query
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThanOrEqualTo: now);
    }

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    if (privacy != null) {
      query = query.where('privacy', isEqualTo: privacy.name);
    }

    return query.snapshots().map((snapshot) {
      List<CommunityChallenge> challenges = snapshot.docs.map((doc) {
        final data = doc.data();
        return CommunityChallenge.fromJson(data as Map<String, dynamic>);
      }).toList();

      // Filter by tags if specified
      if (tags != null && tags.isNotEmpty) {
        challenges = challenges.where((challenge) {
          return tags.any((tag) => challenge.tags.contains(tag));
        }).toList();
      }

      return challenges;
    });
  }

  /// Join a challenge
  Future<void> joinChallenge(String challengeId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get challenge details
    final challengeDoc = await _firestore
        .collection(_challengesCollection)
        .doc(challengeId)
        .get();

    if (!challengeDoc.exists) throw Exception('Challenge not found');

    final challenge = CommunityChallenge.fromJson(challengeDoc.data()!);

    // Check if challenge is still accepting participants
    if (DateTime.now().isAfter(challenge.endDate)) {
      throw Exception('Challenge has already ended');
    }

    if (challenge.participantIds.length >= challenge.maxParticipants) {
      throw Exception('Challenge is at maximum capacity');
    }

    // Check if already participating
    if (challenge.participantIds.contains(user.uid)) {
      throw Exception('Already participating in this challenge');
    }

    // Create participation record
    final participation = ChallengeParticipation(
      id: '',
      challengeId: challengeId,
      userId: user.uid,
      joinedAt: DateTime.now(),
      progress: 0,
      progressData: {},
      completed: false,
      milestones: [],
    );

    final participationRef = await _firestore
        .collection(_participationCollection)
        .add(participation.toJson());

    await participationRef.update({'id': participationRef.id});

    // Add user to challenge participants
    await _firestore.collection(_challengesCollection).doc(challengeId).update({
      'participantIds': FieldValue.arrayUnion([user.uid]),
    });
  }

  /// Leave a challenge
  Future<void> leaveChallenge(String challengeId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Remove participation record
    final participationQuery = await _firestore
        .collection(_participationCollection)
        .where('challengeId', isEqualTo: challengeId)
        .where('userId', isEqualTo: user.uid)
        .get();

    for (final doc in participationQuery.docs) {
      await doc.reference.delete();
    }

    // Remove from challenge participants
    await _firestore.collection(_challengesCollection).doc(challengeId).update({
      'participantIds': FieldValue.arrayRemove([user.uid]),
    });
  }

  /// Update challenge progress
  Future<void> updateProgress({
    required String challengeId,
    required int progress,
    Map<String, dynamic>? additionalData,
    List<String>? newMilestones,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final participationQuery = await _firestore
        .collection(_participationCollection)
        .where('challengeId', isEqualTo: challengeId)
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (participationQuery.docs.isEmpty) {
      throw Exception('Not participating in this challenge');
    }

    final participationDoc = participationQuery.docs.first;
    final participation = ChallengeParticipation.fromJson(
      participationDoc.data(),
    );

    final updates = <String, dynamic>{'progress': progress};

    if (additionalData != null) {
      final updatedProgressData = Map<String, dynamic>.from(
        participation.progressData,
      );
      updatedProgressData.addAll(additionalData);
      updates['progressData'] = updatedProgressData;
    }

    if (newMilestones != null) {
      final updatedMilestones = List<String>.from(participation.milestones);
      for (final milestone in newMilestones) {
        if (!updatedMilestones.contains(milestone)) {
          updatedMilestones.add(milestone);
        }
      }
      updates['milestones'] = updatedMilestones;
    }

    // Check if challenge is completed (100% progress)
    if (progress >= 100 && !participation.completed) {
      updates['completed'] = true;
      updates['completedAt'] = FieldValue.serverTimestamp();
    }

    await participationDoc.reference.update(updates);

    // Update leaderboard
    await _updateLeaderboard(challengeId, user.uid, progress);
  }

  /// Get user's challenge participation
  Stream<List<ChallengeParticipation>> getUserChallenges() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(_participationCollection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChallengeParticipation.fromJson(doc.data());
          }).toList();
        });
  }

  /// Get challenge participants with their progress
  Future<List<ChallengeParticipantInfo>> getChallengeParticipants(
    String challengeId, {
    int limit = 50,
    bool sortByProgress = true,
  }) async {
    Query query = _firestore
        .collection(_participationCollection)
        .where('challengeId', isEqualTo: challengeId)
        .limit(limit);

    if (sortByProgress) {
      query = query.orderBy('progress', descending: true);
    }

    final participationSnapshot = await query.get();

    final participants = <ChallengeParticipantInfo>[];
    for (final doc in participationSnapshot.docs) {
      final data = doc.data();
      final participation = ChallengeParticipation.fromJson(
        data as Map<String, dynamic>,
      );

      // Get user profile
      final profileDoc = await _firestore
          .collection('user_profiles')
          .doc(participation.userId)
          .get();

      String displayName = 'Anonymous User';
      String? avatarUrl;

      if (profileDoc.exists) {
        final profileData = profileDoc.data()!;
        displayName = profileData['displayName'] ?? 'Anonymous User';
        avatarUrl = profileData['avatarUrl'];
      }

      participants.add(
        ChallengeParticipantInfo(
          participation: participation,
          displayName: displayName,
          avatarUrl: avatarUrl,
        ),
      );
    }

    return participants;
  }

  /// Get challenge leaderboard
  Future<List<LeaderboardEntry>> getChallengeLeaderboard(
    String challengeId, {
    int limit = 20,
  }) async {
    final leaderboardSnapshot = await _firestore
        .collection(_leaderboardCollection)
        .doc(challengeId)
        .collection('entries')
        .orderBy('progress', descending: true)
        .orderBy(
          'lastUpdated',
          descending: false,
        ) // Earlier completion wins ties
        .limit(limit)
        .get();

    final entries = <LeaderboardEntry>[];
    int rank = 1;

    for (final doc in leaderboardSnapshot.docs) {
      final data = doc.data();

      // Get user profile for display info
      final profileDoc = await _firestore
          .collection('user_profiles')
          .doc(data['userId'])
          .get();

      String displayName = 'Anonymous User';
      String? avatarUrl;

      if (profileDoc.exists) {
        final profileData = profileDoc.data()!;
        displayName = profileData['displayName'] ?? 'Anonymous User';
        avatarUrl = profileData['avatarUrl'];
      }

      entries.add(
        LeaderboardEntry(
          rank: rank,
          userId: data['userId'],
          displayName: displayName,
          avatarUrl: avatarUrl,
          progress: data['progress'],
          completedAt: data['completedAt']?.toDate(),
          lastUpdated: data['lastUpdated'].toDate(),
        ),
      );

      rank++;
    }

    return entries;
  }

  /// Get trending challenges (most active)
  Future<List<CommunityChallenge>> getTrendingChallenges({
    Duration period = const Duration(days: 7),
    int limit = 10,
  }) async {
    final querySnapshot = await _firestore
        .collection(_challengesCollection)
        .where('startDate', isLessThanOrEqualTo: DateTime.now())
        .where('endDate', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('startDate', descending: false)
        .get();

    // Sort by participant count (trending = more participants)
    final challenges = querySnapshot.docs.map((doc) {
      return CommunityChallenge.fromJson(doc.data());
    }).toList();

    challenges.sort(
      (a, b) => b.participantIds.length.compareTo(a.participantIds.length),
    );

    return challenges.take(limit).toList();
  }

  /// Complete a challenge milestone
  Future<void> completeMilestone({
    required String challengeId,
    required String milestone,
    Map<String, dynamic>? milestoneData,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final participationQuery = await _firestore
        .collection(_participationCollection)
        .where('challengeId', isEqualTo: challengeId)
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (participationQuery.docs.isEmpty) {
      throw Exception('Not participating in this challenge');
    }

    final participationDoc = participationQuery.docs.first;

    await participationDoc.reference.update({
      'milestones': FieldValue.arrayUnion([milestone]),
    });

    // Record milestone completion with timestamp
    if (milestoneData != null) {
      await _firestore
          .collection(_participationCollection)
          .doc(participationDoc.id)
          .collection('milestone_history')
          .add({
            'milestone': milestone,
            'completedAt': FieldValue.serverTimestamp(),
            'data': milestoneData,
          });
    }
  }

  /// Get user's challenge statistics
  Future<ChallengeStats> getUserChallengeStats() async {
    final user = _auth.currentUser;
    if (user == null) {
      return const ChallengeStats(
        totalChallenges: 0,
        completedChallenges: 0,
        activeChallenges: 0,
        totalProgress: 0,
      );
    }

    final participationSnapshot = await _firestore
        .collection(_participationCollection)
        .where('userId', isEqualTo: user.uid)
        .get();

    int totalChallenges = participationSnapshot.docs.length;
    int completedChallenges = 0;
    int activeChallenges = 0;
    int totalProgress = 0;

    for (final doc in participationSnapshot.docs) {
      final participation = ChallengeParticipation.fromJson(doc.data());

      totalProgress += participation.progress;

      if (participation.completed) {
        completedChallenges++;
      } else {
        // Check if challenge is still active
        final challengeDoc = await _firestore
            .collection(_challengesCollection)
            .doc(participation.challengeId)
            .get();

        if (challengeDoc.exists) {
          final challenge = CommunityChallenge.fromJson(challengeDoc.data()!);
          if (DateTime.now().isBefore(challenge.endDate)) {
            activeChallenges++;
          }
        }
      }
    }

    return ChallengeStats(
      totalChallenges: totalChallenges,
      completedChallenges: completedChallenges,
      activeChallenges: activeChallenges,
      totalProgress: totalProgress,
    );
  }

  /// Report inappropriate challenge
  Future<void> reportChallenge({
    required String challengeId,
    required String reason,
    String? additionalInfo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('content_reports').add({
      'reporterId': user.uid,
      'contentId': challengeId,
      'contentType': 'challenge',
      'reason': reason,
      'additionalInfo': additionalInfo,
      'reportedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  // Private helper methods

  Future<void> _updateLeaderboard(
    String challengeId,
    String userId,
    int progress,
  ) async {
    await _firestore
        .collection(_leaderboardCollection)
        .doc(challengeId)
        .collection('entries')
        .doc(userId)
        .set({
          'userId': userId,
          'progress': progress,
          'lastUpdated': FieldValue.serverTimestamp(),
          if (progress >= 100) 'completedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Delete challenge (creator only)
  Future<void> deleteChallenge(String challengeId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final challengeDoc = await _firestore
        .collection(_challengesCollection)
        .doc(challengeId)
        .get();

    if (!challengeDoc.exists) throw Exception('Challenge not found');

    final challenge = CommunityChallenge.fromJson(challengeDoc.data()!);

    if (challenge.createdBy != user.uid) {
      throw Exception('Only the creator can delete this challenge');
    }

    // Delete all participation records
    final participationSnapshot = await _firestore
        .collection(_participationCollection)
        .where('challengeId', isEqualTo: challengeId)
        .get();

    final batch = _firestore.batch();

    for (final doc in participationSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete leaderboard entries
    final leaderboardSnapshot = await _firestore
        .collection(_leaderboardCollection)
        .doc(challengeId)
        .collection('entries')
        .get();

    for (final doc in leaderboardSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete the challenge itself
    batch.delete(challengeDoc.reference);

    await batch.commit();
  }
}

// Helper classes for challenge data

class ChallengeParticipantInfo {
  final ChallengeParticipation participation;
  final String displayName;
  final String? avatarUrl;

  const ChallengeParticipantInfo({
    required this.participation,
    required this.displayName,
    this.avatarUrl,
  });
}

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int progress;
  final DateTime? completedAt;
  final DateTime lastUpdated;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.progress,
    this.completedAt,
    required this.lastUpdated,
  });
}

class ChallengeStats {
  final int totalChallenges;
  final int completedChallenges;
  final int activeChallenges;
  final int totalProgress;

  const ChallengeStats({
    required this.totalChallenges,
    required this.completedChallenges,
    required this.activeChallenges,
    required this.totalProgress,
  });
}
