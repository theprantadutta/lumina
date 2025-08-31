import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumina/shared/models/app_user.dart';

part 'social_models.g.dart';
part 'social_models.freezed.dart';

// User Profile with Privacy Settings
@freezed
sealed class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String userId,
    required String displayName,
    String? avatarUrl,
    String? bio,
    required DateTime joinDate,
    required PrivacySettings privacySettings,
    required List<String> achievements,
    required UserStats stats,
    @Default([]) List<String> blockedUsers,
    @Default([]) List<String> friendIds,
    @Default(true) bool isActive,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

// Privacy Settings
@freezed
sealed class PrivacySettings with _$PrivacySettings {
  const factory PrivacySettings({
    @Default(true) bool allowFriendRequests,
    @Default(true) bool showAchievements,
    @Default(false) bool showMoodTrends,
    @Default(true) bool allowSupportGroupInvites,
    @Default(false) bool showRealName,
    @Default(true) bool allowChallengeInvites,
    @Default(true) bool enableNotifications,
    @Default(ProfileVisibility.friends) ProfileVisibility profileVisibility,
  }) = _PrivacySettings;

  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsFromJson(json);
}

enum ProfileVisibility { public, friends, private }

// Achievement Sharing
@freezed
sealed class SharedAchievement with _$SharedAchievement {
  const factory SharedAchievement({
    required String id,
    required String userId,
    required String achievementId,
    required String title,
    required String description,
    String? imageUrl,
    required DateTime sharedAt,
    @Default([]) List<Reaction> reactions,
    @Default([]) List<String> comments,
    required int likesCount,
    required AchievementType type,
  }) = _SharedAchievement;

  factory SharedAchievement.fromJson(Map<String, dynamic> json) =>
      _$SharedAchievementFromJson(json);
}

enum AchievementType { 
  streak, 
  milestone, 
  mood, 
  journal, 
  community, 
  challenge 
}

// Support Groups
@freezed
sealed class SupportGroup with _$SupportGroup {
  const factory SupportGroup({
    required String id,
    required String name,
    required String description,
    String? imageUrl,
    required String createdBy,
    required DateTime createdAt,
    @Default([]) List<String> memberIds,
    @Default([]) List<String> moderatorIds,
    @Default(10) int maxMembers,
    @Default(true) bool isAnonymous,
    @Default(true) bool requiresApproval,
    required GroupCategory category,
    @Default([]) List<String> tags,
    required GroupPrivacy privacy,
  }) = _SupportGroup;

  factory SupportGroup.fromJson(Map<String, dynamic> json) =>
      _$SupportGroupFromJson(json);
}

enum GroupCategory { 
  anxiety, 
  depression, 
  general, 
  motivation, 
  mindfulness, 
  recovery 
}

enum GroupPrivacy { public, private, inviteOnly }

// Group Messages
@freezed
sealed class GroupMessage with _$GroupMessage {
  const factory GroupMessage({
    required String id,
    required String groupId,
    required String senderId,
    String? senderDisplayName,
    required String content,
    required DateTime sentAt,
    @Default([]) List<Reaction> reactions,
    @Default(false) bool isAnonymous,
    @Default(false) bool isEdited,
    DateTime? editedAt,
    String? replyToMessageId,
    @Default(MessageType.text) MessageType type,
  }) = _GroupMessage;

  factory GroupMessage.fromJson(Map<String, dynamic> json) =>
      _$GroupMessageFromJson(json);
}

enum MessageType { text, image, achievement, quote }

// Friend Connection
@freezed
sealed class FriendConnection with _$FriendConnection {
  const factory FriendConnection({
    required String id,
    required String userId,
    required String friendId,
    required DateTime connectedAt,
    required FriendshipStatus status,
    DateTime? requestedAt,
    String? requestMessage,
  }) = _FriendConnection;

  factory FriendConnection.fromJson(Map<String, dynamic> json) =>
      _$FriendConnectionFromJson(json);
}

enum FriendshipStatus { pending, accepted, blocked, declined }

// Daily Quote
@freezed
sealed class DailyQuote with _$DailyQuote {
  const factory DailyQuote({
    required String id,
    required String text,
    required String author,
    String? category,
    String? imageUrl,
    required DateTime date,
    @Default([]) List<String> tags,
    @Default(0) int likesCount,
    @Default(0) int sharesCount,
  }) = _DailyQuote;

  factory DailyQuote.fromJson(Map<String, dynamic> json) =>
      _$DailyQuoteFromJson(json);
}

// Community Challenge
@freezed
sealed class CommunityChallenge with _$CommunityChallenge {
  const factory CommunityChallenge({
    required String id,
    required String title,
    required String description,
    String? imageUrl,
    required DateTime startDate,
    required DateTime endDate,
    required String createdBy,
    required ChallengeType type,
    required Map<String, dynamic> requirements,
    @Default([]) List<String> participantIds,
    @Default(0) int maxParticipants,
    required ChallengePrivacy privacy,
    @Default([]) List<String> tags,
    Map<String, dynamic>? rewards,
  }) = _CommunityChallenge;

  factory CommunityChallenge.fromJson(Map<String, dynamic> json) =>
      _$CommunityChallengeFromJson(json);
}

enum ChallengeType { 
  moodTracking, 
  journaling, 
  mindfulness, 
  gratitude, 
  custom 
}

enum ChallengePrivacy { public, friends, group }

// Challenge Participation
@freezed
sealed class ChallengeParticipation with _$ChallengeParticipation {
  const factory ChallengeParticipation({
    required String id,
    required String challengeId,
    required String userId,
    required DateTime joinedAt,
    @Default(0) int progress,
    @Default({}) Map<String, dynamic> progressData,
    @Default(false) bool completed,
    DateTime? completedAt,
    @Default([]) List<String> milestones,
  }) = _ChallengeParticipation;

  factory ChallengeParticipation.fromJson(Map<String, dynamic> json) =>
      _$ChallengeParticipationFromJson(json);
}

// Reaction System
@freezed
sealed class Reaction with _$Reaction {
  const factory Reaction({
    required String id,
    required String userId,
    required String targetId, // achievement, message, etc.
    required ReactionType type,
    required DateTime createdAt,
    String? animationAsset, // Lottie animation file
  }) = _Reaction;

  factory Reaction.fromJson(Map<String, dynamic> json) =>
      _$ReactionFromJson(json);
}

enum ReactionType { 
  heart, 
  supportive, 
  inspiring, 
  celebrate, 
  empathy, 
  strength 
}

// Notification
@freezed
sealed class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    required DateTime createdAt,
    @Default(false) bool isRead,
    DateTime? readAt,
    String? targetId, // ID of related object
    Map<String, dynamic>? data,
    String? imageUrl,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}

enum NotificationType { 
  friendRequest,
  achievementShared,
  groupInvitation,
  challengeInvitation,
  messageReaction,
  dailyQuote,
  milestoneReached,
  supportMessage
}