import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:lumina/shared/models/social_models.dart';

class NotificationService {
  static const String _notificationsCollection = 'notifications';
  static const String _tokenCollection = 'fcm_tokens';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static NotificationService? _instance;
  
  factory NotificationService() {
    return _instance ??= NotificationService._internal();
  }
  
  NotificationService._internal();

  /// Initialize FCM and set up listeners
  Future<void> initialize() async {
    if (kDebugMode) {
      print('Initializing NotificationService...');
    }

    // Request permission for notifications
    await _requestPermissions();

    // Get and store FCM token
    await _updateFCMToken();

    // Listen to token refresh
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    // Set up foreground message handling
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Set up background message handling
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification taps when app is opened from terminated state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle notification tap when app is opened from terminated state
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
      criticalAlert: false,
      carPlay: false,
      announcement: false,
    );

    if (kDebugMode) {
      print('Notification permission status: ${settings.authorizationStatus}');
    }
  }

  /// Update FCM token in Firestore
  Future<void> _updateFCMToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore
            .collection(_tokenCollection)
            .doc(user.uid)
            .set({
          'token': token,
          'updatedAt': FieldValue.serverTimestamp(),
          'platform': defaultTargetPlatform.name,
        }, SetOptions(merge: true));

        if (kDebugMode) {
          print('FCM token updated: ${token.substring(0, 20)}...');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating FCM token: $e');
      }
    }
  }

  /// Handle token refresh
  Future<void> _onTokenRefresh(String token) async {
    await _updateFCMToken();
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message received: ${message.notification?.title}');
    }

    // Store notification in local database
    _storeNotification(message);

    // Show in-app notification or update UI
    // This would typically trigger a UI update through state management
  }

  /// Handle message opened app
  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('Message opened app: ${message.data}');
    }

    // Navigate to appropriate screen based on message data
    _navigateFromNotification(message.data);
  }

  /// Store notification in Firestore
  Future<void> _storeNotification(RemoteMessage message) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final notification = AppNotification(
      id: '',
      userId: user.uid,
      title: message.notification?.title ?? 'New notification',
      body: message.notification?.body ?? '',
      type: _getNotificationTypeFromData(message.data),
      createdAt: DateTime.now(),
      isRead: false,
      targetId: message.data['targetId'],
      data: message.data,
      imageUrl: message.notification?.android?.imageUrl ?? 
                message.notification?.apple?.imageUrl,
    );

    final docRef = await _firestore
        .collection(_notificationsCollection)
        .add(notification.toJson());

    await docRef.update({'id': docRef.id});
  }

  /// Send notification to user
  Future<void> sendNotification({
    required String targetUserId,
    required String title,
    required String body,
    required NotificationType type,
    String? targetId,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if target user allows this type of notification
    final canSend = await _canSendNotification(targetUserId, type);
    if (!canSend) return;

    // Store notification in database
    final notification = AppNotification(
      id: '',
      userId: targetUserId,
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
      isRead: false,
      targetId: targetId,
      data: data ?? {},
      imageUrl: imageUrl,
    );

    final docRef = await _firestore
        .collection(_notificationsCollection)
        .add(notification.toJson());

    await docRef.update({'id': docRef.id});

    // Send FCM push notification
    await _sendPushNotification(
      targetUserId: targetUserId,
      title: title,
      body: body,
      data: {
        'notificationId': docRef.id,
        'type': type.name,
        'targetId': targetId ?? '',
        ...?data,
      },
      imageUrl: imageUrl,
    );
  }

  /// Send push notification via FCM
  Future<void> _sendPushNotification({
    required String targetUserId,
    required String title,
    required String body,
    Map<String, String>? data,
    String? imageUrl,
  }) async {
    try {
      // Get user's FCM token
      final tokenDoc = await _firestore
          .collection(_tokenCollection)
          .doc(targetUserId)
          .get();

      if (!tokenDoc.exists) return;

      final token = tokenDoc.data()?['token'] as String?;
      if (token == null) return;

      // Prepare the message payload
      final messageData = <String, String>{
        'title': title,
        'body': body,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        if (imageUrl != null) 'image': imageUrl,
        ...?data,
      };

      // Send via Firebase Functions (Cloud Functions would handle the actual sending)
      await _firestore.collection('notification_queue').add({
        'token': token,
        'title': title,
        'body': body,
        'data': messageData,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });

    } catch (e) {
      if (kDebugMode) {
        print('Error sending push notification: $e');
      }
    }
  }

  /// Get user's notifications
  Stream<List<AppNotification>> getUserNotifications({int limit = 50}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppNotification.fromJson(doc.data());
      }).toList();
    });
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection(_notificationsCollection)
        .doc(notificationId)
        .update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final unreadNotifications = await _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();

    for (final doc in unreadNotifications.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore
        .collection(_notificationsCollection)
        .doc(notificationId)
        .delete();
  }

  /// Delete all read notifications
  Future<void> deleteAllReadNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final readNotifications = await _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: true)
        .get();

    final batch = _firestore.batch();

    for (final doc in readNotifications.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Get unread notification count
  Stream<int> getUnreadNotificationCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Send friend request notification
  Future<void> sendFriendRequestNotification({
    required String targetUserId,
    required String senderName,
    required String requestId,
  }) async {
    await sendNotification(
      targetUserId: targetUserId,
      title: 'New Friend Request',
      body: '$senderName wants to connect with you',
      type: NotificationType.friendRequest,
      targetId: requestId,
      data: {
        'senderId': _auth.currentUser?.uid ?? '',
        'senderName': senderName,
      },
    );
  }

  /// Send achievement reaction notification
  Future<void> sendAchievementReactionNotification({
    required String targetUserId,
    required String achievementId,
    required String reactorName,
    required ReactionType reactionType,
  }) async {
    final reactionEmoji = _getReactionEmoji(reactionType);
    
    await sendNotification(
      targetUserId: targetUserId,
      title: 'Achievement Reaction',
      body: '$reactorName reacted $reactionEmoji to your achievement',
      type: NotificationType.messageReaction,
      targetId: achievementId,
      data: {
        'reactorId': _auth.currentUser?.uid ?? '',
        'reactionType': reactionType.name,
      },
    );
  }

  /// Send support group message notification
  Future<void> sendGroupMessageNotification({
    required String groupId,
    required String groupName,
    required String senderName,
    required String messagePreview,
    required List<String> memberIds,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Send to all members except sender
    for (final memberId in memberIds) {
      if (memberId != currentUser.uid) {
        await sendNotification(
          targetUserId: memberId,
          title: groupName,
          body: '$senderName: $messagePreview',
          type: NotificationType.supportMessage,
          targetId: groupId,
          data: {
            'senderId': currentUser.uid,
            'groupId': groupId,
          },
        );
      }
    }
  }

  /// Send challenge invitation notification
  Future<void> sendChallengeInvitationNotification({
    required String targetUserId,
    required String challengeTitle,
    required String challengeId,
    required String inviterName,
  }) async {
    await sendNotification(
      targetUserId: targetUserId,
      title: 'Challenge Invitation',
      body: '$inviterName invited you to join "$challengeTitle"',
      type: NotificationType.challengeInvitation,
      targetId: challengeId,
      data: {
        'inviterId': _auth.currentUser?.uid ?? '',
        'challengeTitle': challengeTitle,
      },
    );
  }

  /// Send daily quote notification
  Future<void> sendDailyQuoteNotification({
    required String quoteText,
    required String author,
    required String quoteId,
    String? imageUrl,
  }) async {
    // Send to all users who have daily quote notifications enabled
    // This would typically be handled by a cloud function
    
    final usersQuery = await _firestore
        .collection('user_profiles')
        .where('privacySettings.enableNotifications', isEqualTo: true)
        .get();

    for (final doc in usersQuery.docs) {
      final userId = doc.id;
      
      await sendNotification(
        targetUserId: userId,
        title: 'Daily Inspiration',
        body: '"${quoteText.length > 60 ? '${quoteText.substring(0, 60)}...' : quoteText}" - $author',
        type: NotificationType.dailyQuote,
        targetId: quoteId,
        imageUrl: imageUrl,
      );
    }
  }

  /// Send milestone achievement notification
  Future<void> sendMilestoneNotification({
    required String targetUserId,
    required String milestoneTitle,
    required String milestoneDescription,
    String? achievementId,
  }) async {
    await sendNotification(
      targetUserId: targetUserId,
      title: 'Milestone Reached! 🎉',
      body: milestoneTitle,
      type: NotificationType.milestoneReached,
      targetId: achievementId,
      data: {
        'milestone': milestoneTitle,
        'description': milestoneDescription,
      },
    );
  }

  // Helper methods

  Future<bool> _canSendNotification(String userId, NotificationType type) async {
    try {
      final profileDoc = await _firestore
          .collection('user_profiles')
          .doc(userId)
          .get();

      if (!profileDoc.exists) return false;

      final profileData = profileDoc.data()!;
      final privacySettings = profileData['privacySettings'] as Map<String, dynamic>? ?? {};

      // Check general notification setting
      if (privacySettings['enableNotifications'] == false) return false;

      // Check specific notification types
      switch (type) {
        case NotificationType.friendRequest:
          return privacySettings['allowFriendRequests'] ?? true;
        case NotificationType.groupInvitation:
          return privacySettings['allowSupportGroupInvites'] ?? true;
        case NotificationType.challengeInvitation:
          return privacySettings['allowChallengeInvites'] ?? true;
        default:
          return true;
      }
    } catch (e) {
      return false;
    }
  }

  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final typeString = data['type'] as String?;
    
    switch (typeString) {
      case 'friendRequest':
        return NotificationType.friendRequest;
      case 'achievementShared':
        return NotificationType.achievementShared;
      case 'groupInvitation':
        return NotificationType.groupInvitation;
      case 'challengeInvitation':
        return NotificationType.challengeInvitation;
      case 'messageReaction':
        return NotificationType.messageReaction;
      case 'dailyQuote':
        return NotificationType.dailyQuote;
      case 'milestoneReached':
        return NotificationType.milestoneReached;
      case 'supportMessage':
        return NotificationType.supportMessage;
      default:
        return NotificationType.supportMessage;
    }
  }

  void _navigateFromNotification(Map<String, dynamic> data) {
    // This would typically use a navigation service to navigate to appropriate screens
    final type = _getNotificationTypeFromData(data);
    final targetId = data['targetId'] as String?;

    if (kDebugMode) {
      print('Navigate from notification: $type, targetId: $targetId');
    }

    // Implementation would depend on your navigation setup (GoRouter, Navigator, etc.)
    // Example:
    // switch (type) {
    //   case NotificationType.friendRequest:
    //     NavigationService.navigateToFriendRequests();
    //     break;
    //   case NotificationType.supportMessage:
    //     if (targetId != null) {
    //       NavigationService.navigateToSupportGroup(targetId);
    //     }
    //     break;
    //   // ... other cases
    // }
  }

  String _getReactionEmoji(ReactionType type) {
    switch (type) {
      case ReactionType.heart:
        return '❤️';
      case ReactionType.supportive:
        return '🤗';
      case ReactionType.inspiring:
        return '✨';
      case ReactionType.celebrate:
        return '🎉';
      case ReactionType.empathy:
        return '🫂';
      case ReactionType.strength:
        return '💪';
    }
  }

  /// Clean up when user logs out
  Future<void> cleanup() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Remove FCM token
      await _firestore
          .collection(_tokenCollection)
          .doc(user.uid)
          .delete();
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message received: ${message.notification?.title}');
  }
  
  // Handle background message processing here
  // This could include updating local storage, scheduling local notifications, etc.
}