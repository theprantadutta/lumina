import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/shared/models/social_models.dart';

class SupportGroupsService {
  static const String _groupsCollection = 'support_groups';
  static const String _messagesCollection = 'group_messages';
  static const String _joinRequestsCollection = 'join_requests';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create a new support group
  Future<String> createSupportGroup({
    required String name,
    required String description,
    required GroupCategory category,
    required GroupPrivacy privacy,
    String? imageUrl,
    int maxMembers = 10,
    bool isAnonymous = true,
    bool requiresApproval = true,
    List<String> tags = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final supportGroup = SupportGroup(
      id: '',
      name: name,
      description: description,
      imageUrl: imageUrl,
      createdBy: user.uid,
      createdAt: DateTime.now(),
      memberIds: [user.uid], // Creator is first member
      moderatorIds: [user.uid], // Creator is first moderator
      maxMembers: maxMembers,
      isAnonymous: isAnonymous,
      requiresApproval: requiresApproval,
      category: category,
      tags: tags,
      privacy: privacy,
    );

    final docRef = await _firestore
        .collection(_groupsCollection)
        .add(supportGroup.toJson());

    // Update with document ID
    await docRef.update({'id': docRef.id});

    return docRef.id;
  }

  /// Get available support groups based on privacy settings
  Stream<List<SupportGroup>> getAvailableGroups({
    GroupCategory? category,
    List<String>? tags,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(_groupsCollection)
        .where('privacy', whereIn: [GroupPrivacy.public.name])
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    return query.snapshots().map((snapshot) {
      List<SupportGroup> groups = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SupportGroup.fromJson(data);
      }).toList();

      // Filter by tags if specified
      if (tags != null && tags.isNotEmpty) {
        groups = groups.where((group) {
          return tags.any((tag) => group.tags.contains(tag));
        }).toList();
      }

      return groups;
    });
  }

  /// Get groups the user is a member of
  Stream<List<SupportGroup>> getUserGroups() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(_groupsCollection)
        .where('memberIds', arrayContains: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SupportGroup.fromJson(data);
      }).toList();
    });
  }

  /// Request to join a group
  Future<void> requestToJoinGroup(String groupId, {String? message}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if group exists and get group data
    final groupDoc = await _firestore.collection(_groupsCollection).doc(groupId).get();
    if (!groupDoc.exists) throw Exception('Group not found');

    final group = SupportGroup.fromJson(groupDoc.data()!);

    // Check if already a member
    if (group.memberIds.contains(user.uid)) {
      throw Exception('Already a member of this group');
    }

    // Check if group is at capacity
    if (group.memberIds.length >= group.maxMembers) {
      throw Exception('Group is at maximum capacity');
    }

    if (group.requiresApproval) {
      // Create join request
      await _firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection(_joinRequestsCollection)
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'requestedAt': FieldValue.serverTimestamp(),
        'message': message,
        'status': 'pending',
      });
    } else {
      // Directly add to group
      await _addMemberToGroup(groupId, user.uid);
    }
  }

  /// Approve join request (moderators only)
  Future<void> approveJoinRequest(String groupId, String userId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Verify moderator permissions
    await _verifyModeratorPermissions(groupId, user.uid);

    // Add user to group
    await _addMemberToGroup(groupId, userId);

    // Update join request status
    await _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .collection(_joinRequestsCollection)
        .doc(userId)
        .update({'status': 'approved'});
  }

  /// Reject join request (moderators only)
  Future<void> rejectJoinRequest(String groupId, String userId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _verifyModeratorPermissions(groupId, user.uid);

    await _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .collection(_joinRequestsCollection)
        .doc(userId)
        .update({'status': 'rejected'});
  }

  /// Leave a group
  Future<void> leaveGroup(String groupId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection(_groupsCollection).doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([user.uid]),
      'moderatorIds': FieldValue.arrayRemove([user.uid]),
    });
  }

  /// Send message to group
  Future<String> sendGroupMessage({
    required String groupId,
    required String content,
    bool isAnonymous = false,
    String? replyToMessageId,
    MessageType type = MessageType.text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Verify user is member of the group
    await _verifyGroupMembership(groupId, user.uid);

    final message = GroupMessage(
      id: '',
      groupId: groupId,
      senderId: user.uid,
      senderDisplayName: isAnonymous ? null : user.displayName,
      content: content,
      sentAt: DateTime.now(),
      reactions: [],
      isAnonymous: isAnonymous,
      isEdited: false,
      replyToMessageId: replyToMessageId,
      type: type,
    );

    final docRef = await _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .collection(_messagesCollection)
        .add(message.toJson());

    await docRef.update({'id': docRef.id});

    return docRef.id;
  }

  /// Get group messages (real-time)
  Stream<List<GroupMessage>> getGroupMessages(
    String groupId, {
    int limit = 50,
    DocumentSnapshot? lastDocument,
  }) {
    Query query = _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .collection(_messagesCollection)
        .orderBy('sentAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots().map((snapshot) {
      final messages = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return GroupMessage.fromJson(data);
      }).toList();
      return messages.reversed.toList(); // Reverse to show oldest first
    });
  }

  /// Add reaction to group message
  Future<void> addMessageReaction({
    required String groupId,
    required String messageId,
    required ReactionType reactionType,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _verifyGroupMembership(groupId, user.uid);

    final reaction = Reaction(
      id: '',
      userId: user.uid,
      targetId: messageId,
      type: reactionType,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .collection(_messagesCollection)
        .doc(messageId)
        .collection('reactions')
        .doc(user.uid) // One reaction per user per message
        .set(reaction.toJson());
  }

  /// Remove reaction from group message
  Future<void> removeMessageReaction({
    required String groupId,
    required String messageId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .collection(_messagesCollection)
        .doc(messageId)
        .collection('reactions')
        .doc(user.uid)
        .delete();
  }

  /// Get message reactions
  Stream<List<Reaction>> getMessageReactions(String groupId, String messageId) {
    return _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .collection(_messagesCollection)
        .doc(messageId)
        .collection('reactions')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Reaction.fromJson(data);
      }).toList();
    });
  }

  /// Delete message (sender or moderator only)
  Future<void> deleteMessage(String groupId, String messageId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final messageDoc = await _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .collection(_messagesCollection)
        .doc(messageId)
        .get();

    if (!messageDoc.exists) throw Exception('Message not found');

    final message = GroupMessage.fromJson(messageDoc.data()!);

    // Check if user owns message or is moderator
    if (message.senderId != user.uid) {
      await _verifyModeratorPermissions(groupId, user.uid);
    }

    await messageDoc.reference.delete();
  }

  /// Get pending join requests (moderators only)
  Stream<List<Map<String, dynamic>>> getPendingJoinRequests(String groupId) {
    return _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .collection(_joinRequestsCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Add moderator (existing moderator only)
  Future<void> addModerator(String groupId, String userId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _verifyModeratorPermissions(groupId, user.uid);

    await _firestore.collection(_groupsCollection).doc(groupId).update({
      'moderatorIds': FieldValue.arrayUnion([userId]),
    });
  }

  /// Remove moderator (existing moderator only, cannot remove self if only moderator)
  Future<void> removeModerator(String groupId, String userId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _verifyModeratorPermissions(groupId, user.uid);

    // Get current moderators
    final groupDoc = await _firestore.collection(_groupsCollection).doc(groupId).get();
    final group = SupportGroup.fromJson(groupDoc.data()!);

    if (group.moderatorIds.length == 1 && group.moderatorIds.contains(userId)) {
      throw Exception('Cannot remove the only moderator');
    }

    await _firestore.collection(_groupsCollection).doc(groupId).update({
      'moderatorIds': FieldValue.arrayRemove([userId]),
    });
  }

  /// Report inappropriate content
  Future<void> reportMessage({
    required String groupId,
    required String messageId,
    required String reason,
    String? additionalInfo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('content_reports').add({
      'reporterId': user.uid,
      'contentId': messageId,
      'contentType': 'group_message',
      'groupId': groupId,
      'reason': reason,
      'additionalInfo': additionalInfo,
      'reportedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  // Helper methods

  Future<void> _addMemberToGroup(String groupId, String userId) async {
    await _firestore.collection(_groupsCollection).doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> _verifyModeratorPermissions(String groupId, String userId) async {
    final groupDoc = await _firestore.collection(_groupsCollection).doc(groupId).get();
    if (!groupDoc.exists) throw Exception('Group not found');

    final group = SupportGroup.fromJson(groupDoc.data()!);
    if (!group.moderatorIds.contains(userId)) {
      throw Exception('Insufficient permissions');
    }
  }

  Future<void> _verifyGroupMembership(String groupId, String userId) async {
    final groupDoc = await _firestore.collection(_groupsCollection).doc(groupId).get();
    if (!groupDoc.exists) throw Exception('Group not found');

    final group = SupportGroup.fromJson(groupDoc.data()!);
    if (!group.memberIds.contains(userId)) {
      throw Exception('Not a member of this group');
    }
  }

  /// Get group statistics
  Future<GroupStats> getGroupStats(String groupId) async {
    final groupDoc = await _firestore.collection(_groupsCollection).doc(groupId).get();
    if (!groupDoc.exists) throw Exception('Group not found');

    final group = SupportGroup.fromJson(groupDoc.data()!);

    final messagesSnapshot = await _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .collection(_messagesCollection)
        .get();

    final today = DateTime.now();
    final thisWeek = today.subtract(const Duration(days: 7));

    int todayMessages = 0;
    int weekMessages = 0;

    for (final doc in messagesSnapshot.docs) {
      final messageData = doc.data();
      final sentAt = DateTime.fromMillisecondsSinceEpoch(
        messageData['sentAt']?.millisecondsSinceEpoch ?? 0,
      );

      if (sentAt.day == today.day && 
          sentAt.month == today.month && 
          sentAt.year == today.year) {
        todayMessages++;
      }

      if (sentAt.isAfter(thisWeek)) {
        weekMessages++;
      }
    }

    return GroupStats(
      memberCount: group.memberIds.length,
      totalMessages: messagesSnapshot.docs.length,
      todayMessages: todayMessages,
      weekMessages: weekMessages,
      createdAt: group.createdAt,
    );
  }
}

// Group statistics model
class GroupStats {
  final int memberCount;
  final int totalMessages;
  final int todayMessages;
  final int weekMessages;
  final DateTime createdAt;

  const GroupStats({
    required this.memberCount,
    required this.totalMessages,
    required this.todayMessages,
    required this.weekMessages,
    required this.createdAt,
  });
}