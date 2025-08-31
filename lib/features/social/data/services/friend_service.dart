import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/shared/models/social_models.dart';

class FriendService {
  static const String _connectionsCollection = 'friend_connections';
  static const String _profilesCollection = 'user_profiles';
  static const String _requestsCollection = 'friend_requests';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Send friend request
  Future<void> sendFriendRequest({
    required String friendId,
    String? message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    if (user.uid == friendId) {
      throw Exception('Cannot send friend request to yourself');
    }

    // Check if request already exists
    final existingRequest = await _firestore
        .collection(_requestsCollection)
        .where('senderId', isEqualTo: user.uid)
        .where('receiverId', isEqualTo: friendId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existingRequest.docs.isNotEmpty) {
      throw Exception('Friend request already sent');
    }

    // Check if already friends
    final existingConnection = await _firestore
        .collection(_connectionsCollection)
        .where('userId', isEqualTo: user.uid)
        .where('friendId', isEqualTo: friendId)
        .where('status', isEqualTo: 'accepted')
        .get();

    if (existingConnection.docs.isNotEmpty) {
      throw Exception('Already friends with this user');
    }

    // Check privacy settings of target user
    final targetProfileDoc = await _firestore
        .collection(_profilesCollection)
        .doc(friendId)
        .get();

    if (targetProfileDoc.exists) {
      final targetProfile = UserProfile.fromJson(targetProfileDoc.data()!);
      if (!targetProfile.privacySettings.allowFriendRequests) {
        throw Exception('This user is not accepting friend requests');
      }
    }

    // Create friend request
    await _firestore.collection(_requestsCollection).add({
      'id': '',
      'senderId': user.uid,
      'receiverId': friendId,
      'message': message,
      'sentAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  /// Accept friend request
  Future<void> acceptFriendRequest(String requestId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final requestDoc = await _firestore
        .collection(_requestsCollection)
        .doc(requestId)
        .get();

    if (!requestDoc.exists) throw Exception('Friend request not found');

    final requestData = requestDoc.data()!;
    if (requestData['receiverId'] != user.uid) {
      throw Exception('Unauthorized to accept this request');
    }

    if (requestData['status'] != 'pending') {
      throw Exception('Request is no longer pending');
    }

    final senderId = requestData['senderId'];
    final receiverId = requestData['receiverId'];

    // Create bidirectional friend connections
    final batch = _firestore.batch();

    // Connection from user to friend
    final connection1Ref = _firestore.collection(_connectionsCollection).doc();
    batch.set(connection1Ref, {
      'id': connection1Ref.id,
      'userId': receiverId,
      'friendId': senderId,
      'status': 'accepted',
      'connectedAt': FieldValue.serverTimestamp(),
      'requestedAt': requestData['sentAt'],
    });

    // Connection from friend to user
    final connection2Ref = _firestore.collection(_connectionsCollection).doc();
    batch.set(connection2Ref, {
      'id': connection2Ref.id,
      'userId': senderId,
      'friendId': receiverId,
      'status': 'accepted',
      'connectedAt': FieldValue.serverTimestamp(),
      'requestedAt': requestData['sentAt'],
    });

    // Update request status
    batch.update(requestDoc.reference, {'status': 'accepted'});

    await batch.commit();
  }

  /// Decline friend request
  Future<void> declineFriendRequest(String requestId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final requestDoc = await _firestore
        .collection(_requestsCollection)
        .doc(requestId)
        .get();

    if (!requestDoc.exists) throw Exception('Friend request not found');

    final requestData = requestDoc.data()!;
    if (requestData['receiverId'] != user.uid) {
      throw Exception('Unauthorized to decline this request');
    }

    await requestDoc.reference.update({'status': 'declined'});
  }

  /// Cancel sent friend request
  Future<void> cancelFriendRequest(String requestId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final requestDoc = await _firestore
        .collection(_requestsCollection)
        .doc(requestId)
        .get();

    if (!requestDoc.exists) throw Exception('Friend request not found');

    final requestData = requestDoc.data()!;
    if (requestData['senderId'] != user.uid) {
      throw Exception('Unauthorized to cancel this request');
    }

    await requestDoc.reference.delete();
  }

  /// Remove friend connection
  Future<void> removeFriend(String friendId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Find and delete both connections
    final myConnectionQuery = await _firestore
        .collection(_connectionsCollection)
        .where('userId', isEqualTo: user.uid)
        .where('friendId', isEqualTo: friendId)
        .get();

    final friendConnectionQuery = await _firestore
        .collection(_connectionsCollection)
        .where('userId', isEqualTo: friendId)
        .where('friendId', isEqualTo: user.uid)
        .get();

    final batch = _firestore.batch();

    for (final doc in myConnectionQuery.docs) {
      batch.delete(doc.reference);
    }

    for (final doc in friendConnectionQuery.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Block user
  Future<void> blockUser(String userId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Remove existing friend connection if exists
    await removeFriend(userId);

    // Add to blocked users list in user profile
    await _firestore.collection(_profilesCollection).doc(user.uid).update({
      'blockedUsers': FieldValue.arrayUnion([userId]),
    });

    // Create blocking relationship record
    await _firestore.collection('user_blocks').add({
      'blockerId': user.uid,
      'blockedUserId': userId,
      'blockedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Unblock user
  Future<void> unblockUser(String userId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Remove from blocked users list
    await _firestore.collection(_profilesCollection).doc(user.uid).update({
      'blockedUsers': FieldValue.arrayRemove([userId]),
    });

    // Remove blocking relationship record
    final blockQuery = await _firestore
        .collection('user_blocks')
        .where('blockerId', isEqualTo: user.uid)
        .where('blockedUserId', isEqualTo: userId)
        .get();

    for (final doc in blockQuery.docs) {
      await doc.reference.delete();
    }
  }

  /// Get user's friends list
  Stream<List<UserProfile>> getFriends() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(_connectionsCollection)
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((snapshot) async {
      final friendIds = snapshot.docs.map((doc) => doc.data()['friendId'] as String).toList();
      
      if (friendIds.isEmpty) return <UserProfile>[];

      final friends = <UserProfile>[];
      for (final friendId in friendIds) {
        final profileDoc = await _firestore
            .collection(_profilesCollection)
            .doc(friendId)
            .get();
        
        if (profileDoc.exists) {
          friends.add(UserProfile.fromJson(profileDoc.data()!));
        }
      }

      return friends;
    });
  }

  /// Get pending friend requests (received)
  Stream<List<Map<String, dynamic>>> getPendingFriendRequests() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(_requestsCollection)
        .where('receiverId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final requests = <Map<String, dynamic>>[];
      
      for (final doc in snapshot.docs) {
        final requestData = doc.data();
        requestData['id'] = doc.id;

        // Get sender profile info
        final senderDoc = await _firestore
            .collection(_profilesCollection)
            .doc(requestData['senderId'])
            .get();

        if (senderDoc.exists) {
          requestData['senderProfile'] = senderDoc.data();
        }

        requests.add(requestData);
      }

      return requests;
    });
  }

  /// Get sent friend requests
  Stream<List<Map<String, dynamic>>> getSentFriendRequests() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(_requestsCollection)
        .where('senderId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final requests = <Map<String, dynamic>>[];
      
      for (final doc in snapshot.docs) {
        final requestData = doc.data();
        requestData['id'] = doc.id;

        // Get receiver profile info
        final receiverDoc = await _firestore
            .collection(_profilesCollection)
            .doc(requestData['receiverId'])
            .get();

        if (receiverDoc.exists) {
          requestData['receiverProfile'] = receiverDoc.data();
        }

        requests.add(requestData);
      }

      return requests;
    });
  }

  /// Search for users to add as friends
  Future<List<UserProfile>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    // Get current user's blocked users
    final profileDoc = await _firestore
        .collection(_profilesCollection)
        .doc(user.uid)
        .get();

    final blockedUsers = <String>[];
    if (profileDoc.exists) {
      final profile = UserProfile.fromJson(profileDoc.data()!);
      blockedUsers.addAll(profile.blockedUsers);
    }

    // Search by display name
    final nameResults = await _firestore
        .collection(_profilesCollection)
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(limit)
        .get();

    final users = <UserProfile>[];
    final seenIds = <String>{};

    for (final doc in nameResults.docs) {
      final profile = UserProfile.fromJson(doc.data());
      
      // Filter out current user, blocked users, and inactive users
      if (profile.userId != user.uid &&
          !blockedUsers.contains(profile.userId) &&
          !seenIds.contains(profile.userId) &&
          profile.isActive &&
          profile.privacySettings.profileVisibility != ProfileVisibility.private) {
        seenIds.add(profile.userId);
        users.add(profile);
      }
    }

    return users;
  }

  /// Check friendship status between current user and another user
  Future<FriendshipStatus?> getFriendshipStatus(String userId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Check for existing connection
    final connectionQuery = await _firestore
        .collection(_connectionsCollection)
        .where('userId', isEqualTo: user.uid)
        .where('friendId', isEqualTo: userId)
        .limit(1)
        .get();

    if (connectionQuery.docs.isNotEmpty) {
      final connection = FriendConnection.fromJson(connectionQuery.docs.first.data());
      return connection.status;
    }

    // Check for pending request (sent by current user)
    final sentRequestQuery = await _firestore
        .collection(_requestsCollection)
        .where('senderId', isEqualTo: user.uid)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (sentRequestQuery.docs.isNotEmpty) {
      return FriendshipStatus.pending;
    }

    // Check for pending request (received by current user)
    final receivedRequestQuery = await _firestore
        .collection(_requestsCollection)
        .where('senderId', isEqualTo: userId)
        .where('receiverId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (receivedRequestQuery.docs.isNotEmpty) {
      return FriendshipStatus.pending;
    }

    return null; // No relationship
  }

  /// Get mutual friends between current user and another user
  Future<List<UserProfile>> getMutualFriends(String userId) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    // Get current user's friends
    final myFriendsQuery = await _firestore
        .collection(_connectionsCollection)
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'accepted')
        .get();

    final myFriendIds = myFriendsQuery.docs
        .map((doc) => doc.data()['friendId'] as String)
        .toSet();

    // Get other user's friends
    final theirFriendsQuery = await _firestore
        .collection(_connectionsCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .get();

    final theirFriendIds = theirFriendsQuery.docs
        .map((doc) => doc.data()['friendId'] as String)
        .toSet();

    // Find mutual friends
    final mutualFriendIds = myFriendIds.intersection(theirFriendIds);

    if (mutualFriendIds.isEmpty) return [];

    // Get profiles of mutual friends
    final mutualFriends = <UserProfile>[];
    for (final friendId in mutualFriendIds) {
      final profileDoc = await _firestore
          .collection(_profilesCollection)
          .doc(friendId)
          .get();
      
      if (profileDoc.exists) {
        mutualFriends.add(UserProfile.fromJson(profileDoc.data()!));
      }
    }

    return mutualFriends;
  }

  /// Get friend suggestions based on mutual connections
  Future<List<UserProfile>> getFriendSuggestions({int limit = 10}) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    // Get user's current friends
    final friendsQuery = await _firestore
        .collection(_connectionsCollection)
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'accepted')
        .get();

    final currentFriendIds = friendsQuery.docs
        .map((doc) => doc.data()['friendId'] as String)
        .toSet();

    if (currentFriendIds.isEmpty) return [];

    // Find friends of friends
    final suggestions = <String, int>{}; // userId -> mutual connections count

    for (final friendId in currentFriendIds) {
      final friendsOfFriendQuery = await _firestore
          .collection(_connectionsCollection)
          .where('userId', isEqualTo: friendId)
          .where('status', isEqualTo: 'accepted')
          .get();

      for (final doc in friendsOfFriendQuery.docs) {
        final potentialFriendId = doc.data()['friendId'] as String;
        
        // Skip if it's the current user or already a friend
        if (potentialFriendId != user.uid && 
            !currentFriendIds.contains(potentialFriendId)) {
          suggestions[potentialFriendId] = (suggestions[potentialFriendId] ?? 0) + 1;
        }
      }
    }

    // Sort by number of mutual connections and get profiles
    final sortedSuggestions = suggestions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final suggestionProfiles = <UserProfile>[];
    for (final entry in sortedSuggestions.take(limit)) {
      final profileDoc = await _firestore
          .collection(_profilesCollection)
          .doc(entry.key)
          .get();
      
      if (profileDoc.exists) {
        final profile = UserProfile.fromJson(profileDoc.data()!);
        if (profile.isActive && 
            profile.privacySettings.profileVisibility != ProfileVisibility.private) {
          suggestionProfiles.add(profile);
        }
      }
    }

    return suggestionProfiles;
  }

  /// Get friendship statistics
  Future<FriendshipStats> getFriendshipStats() async {
    final user = _auth.currentUser;
    if (user == null) {
      return const FriendshipStats(
        totalFriends: 0,
        pendingRequests: 0,
        sentRequests: 0,
        mutualConnections: 0,
      );
    }

    final friendsCount = await _firestore
        .collection(_connectionsCollection)
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'accepted')
        .count()
        .get();

    final pendingRequestsCount = await _firestore
        .collection(_requestsCollection)
        .where('receiverId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .count()
        .get();

    final sentRequestsCount = await _firestore
        .collection(_requestsCollection)
        .where('senderId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .count()
        .get();

    return FriendshipStats(
      totalFriends: friendsCount.count ?? 0,
      pendingRequests: pendingRequestsCount.count ?? 0,
      sentRequests: sentRequestsCount.count ?? 0,
      mutualConnections: 0, // Would require additional calculation
    );
  }
}

// Friendship statistics model
class FriendshipStats {
  final int totalFriends;
  final int pendingRequests;
  final int sentRequests;
  final int mutualConnections;

  const FriendshipStats({
    required this.totalFriends,
    required this.pendingRequests,
    required this.sentRequests,
    required this.mutualConnections,
  });
}