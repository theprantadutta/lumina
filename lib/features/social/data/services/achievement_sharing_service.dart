import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/shared/models/social_models.dart';

class AchievementSharingService {
  static const String _collection = 'shared_achievements';
  static const String _reactionsCollection = 'reactions';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Share an achievement with the community
  Future<String> shareAchievement({
    required String achievementId,
    required String title,
    required String description,
    required AchievementType type,
    String? customMessage,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final sharedAchievement = SharedAchievement(
      id: '',
      userId: user.uid,
      achievementId: achievementId,
      title: title,
      description: customMessage ?? description,
      imageUrl: imageUrl,
      sharedAt: DateTime.now(),
      reactions: [],
      comments: [],
      likesCount: 0,
      type: type,
    );

    final docRef = await _firestore
        .collection(_collection)
        .add(sharedAchievement.toJson());

    // Update the document with its ID
    await docRef.update({'id': docRef.id});

    return docRef.id;
  }

  /// Get shared achievements feed (paginated)
  Stream<List<SharedAchievement>> getSharedAchievementsFeed({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) {
    Query query = _firestore
        .collection(_collection)
        .orderBy('sharedAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SharedAchievement.fromJson(data);
      }).toList();
    });
  }

  /// Get achievements shared by a specific user
  Stream<List<SharedAchievement>> getUserSharedAchievements(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('sharedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return SharedAchievement.fromJson(data);
          }).toList();
        });
  }

  /// Get achievements shared by friends
  Stream<List<SharedAchievement>> getFriendsSharedAchievements(
    List<String> friendIds,
  ) {
    if (friendIds.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('userId', whereIn: friendIds)
        .orderBy('sharedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return SharedAchievement.fromJson(data);
          }).toList();
        });
  }

  /// Add reaction to a shared achievement
  Future<void> addReaction({
    required String achievementId,
    required ReactionType type,
    String? animationAsset,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final reaction = Reaction(
      id: '',
      userId: user.uid,
      targetId: achievementId,
      type: type,
      createdAt: DateTime.now(),
      animationAsset: animationAsset,
    );

    // Add reaction to reactions subcollection
    final reactionDocRef = await _firestore
        .collection(_collection)
        .doc(achievementId)
        .collection(_reactionsCollection)
        .add(reaction.toJson());

    // Update reaction with its ID
    await reactionDocRef.update({'id': reactionDocRef.id});

    // Update likes count on the achievement
    await _updateLikesCount(achievementId);
  }

  /// Remove reaction from a shared achievement
  Future<void> removeReaction({
    required String achievementId,
    required String reactionId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Remove reaction from subcollection
    await _firestore
        .collection(_collection)
        .doc(achievementId)
        .collection(_reactionsCollection)
        .doc(reactionId)
        .delete();

    // Update likes count
    await _updateLikesCount(achievementId);
  }

  /// Get reactions for a shared achievement
  Stream<List<Reaction>> getReactions(String achievementId) {
    return _firestore
        .collection(_collection)
        .doc(achievementId)
        .collection(_reactionsCollection)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Reaction.fromJson(data);
          }).toList();
        });
  }

  /// Get user's reaction for a specific achievement
  Future<Reaction?> getUserReaction(String achievementId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection(_collection)
        .doc(achievementId)
        .collection(_reactionsCollection)
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return Reaction.fromJson(snapshot.docs.first.data());
  }

  /// Delete a shared achievement
  Future<void> deleteSharedAchievement(String achievementId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Verify ownership
    final doc = await _firestore
        .collection(_collection)
        .doc(achievementId)
        .get();
    final data = doc.data();

    if (data == null || data['userId'] != user.uid) {
      throw Exception('Unauthorized to delete this achievement');
    }

    // Delete reactions subcollection
    final reactionsSnapshot = await _firestore
        .collection(_collection)
        .doc(achievementId)
        .collection(_reactionsCollection)
        .get();

    for (final doc in reactionsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete the achievement
    await _firestore.collection(_collection).doc(achievementId).delete();
  }

  /// Get achievement statistics
  Future<AchievementStats> getAchievementStats(String achievementId) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(achievementId)
        .get();

    if (!doc.exists) {
      throw Exception('Achievement not found');
    }

    final reactionsSnapshot = await _firestore
        .collection(_collection)
        .doc(achievementId)
        .collection(_reactionsCollection)
        .get();

    final reactions = reactionsSnapshot.docs.map((doc) {
      return Reaction.fromJson(doc.data());
    }).toList();

    // Count reactions by type
    final reactionCounts = <ReactionType, int>{};
    for (final reaction in reactions) {
      reactionCounts[reaction.type] = (reactionCounts[reaction.type] ?? 0) + 1;
    }

    return AchievementStats(
      totalReactions: reactions.length,
      reactionBreakdown: reactionCounts,
      sharedAt: DateTime.fromMillisecondsSinceEpoch(
        doc.data()?['sharedAt']?.millisecondsSinceEpoch ?? 0,
      ),
    );
  }

  /// Private helper to update likes count
  Future<void> _updateLikesCount(String achievementId) async {
    final reactionsSnapshot = await _firestore
        .collection(_collection)
        .doc(achievementId)
        .collection(_reactionsCollection)
        .get();

    await _firestore.collection(_collection).doc(achievementId).update({
      'likesCount': reactionsSnapshot.docs.length,
    });
  }

  /// Get trending shared achievements
  Stream<List<SharedAchievement>> getTrendingAchievements({
    Duration period = const Duration(days: 7),
    int limit = 20,
  }) {
    final cutoffDate = DateTime.now().subtract(period);

    return _firestore
        .collection(_collection)
        .where('sharedAt', isGreaterThan: cutoffDate)
        .orderBy('sharedAt', descending: false)
        .orderBy('likesCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return SharedAchievement.fromJson(data);
          }).toList();
        });
  }

  /// Report inappropriate content
  Future<void> reportAchievement({
    required String achievementId,
    required String reason,
    String? additionalInfo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('content_reports').add({
      'reporterId': user.uid,
      'contentId': achievementId,
      'contentType': 'shared_achievement',
      'reason': reason,
      'additionalInfo': additionalInfo,
      'reportedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }
}

// Achievement statistics model
class AchievementStats {
  final int totalReactions;
  final Map<ReactionType, int> reactionBreakdown;
  final DateTime sharedAt;

  const AchievementStats({
    required this.totalReactions,
    required this.reactionBreakdown,
    required this.sharedAt,
  });
}
