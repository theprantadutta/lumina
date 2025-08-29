import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

@freezed
class JournalEntry with _$JournalEntry {
  const factory JournalEntry({
    required String id,
    required String userId,
    required String title,
    required String content,
    @Default([]) List<String> tags,
    @Default([]) List<String> imageUrls,
    String? audioUrl,
    @Default([]) List<Gratitude> gratitudeList,
    required DateTime timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isFavorite,
    @Default(JournalMood.neutral) JournalMood mood,
    String? weather,
    String? location,
    @Default(JournalTemplate.freeform) JournalTemplate template,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) => _$JournalEntryFromJson(json);
}

@freezed
class Gratitude with _$Gratitude {
  const factory Gratitude({
    required String id,
    required String text,
    required GratitudeCategory category,
    DateTime? createdAt,
  }) = _Gratitude;

  factory Gratitude.fromJson(Map<String, dynamic> json) => _$GratitudeFromJson(json);
}

enum JournalMood {
  ecstatic,
  happy,
  content,
  neutral,
  sad,
  anxious,
  angry,
  reflective;

  String get displayName {
    switch (this) {
      case JournalMood.ecstatic:
        return 'Ecstatic';
      case JournalMood.happy:
        return 'Happy';
      case JournalMood.content:
        return 'Content';
      case JournalMood.neutral:
        return 'Neutral';
      case JournalMood.sad:
        return 'Sad';
      case JournalMood.anxious:
        return 'Anxious';
      case JournalMood.angry:
        return 'Angry';
      case JournalMood.reflective:
        return 'Reflective';
    }
  }

  String get emoji {
    switch (this) {
      case JournalMood.ecstatic:
        return '🤩';
      case JournalMood.happy:
        return '😊';
      case JournalMood.content:
        return '😌';
      case JournalMood.neutral:
        return '😐';
      case JournalMood.sad:
        return '😢';
      case JournalMood.anxious:
        return '😰';
      case JournalMood.angry:
        return '😠';
      case JournalMood.reflective:
        return '🤔';
    }
  }

  Color get color {
    switch (this) {
      case JournalMood.ecstatic:
        return const Color(0xFFFF6B9D);
      case JournalMood.happy:
        return const Color(0xFF10B981);
      case JournalMood.content:
        return const Color(0xFF3B82F6);
      case JournalMood.neutral:
        return const Color(0xFF6B7280);
      case JournalMood.sad:
        return const Color(0xFF8B5CF6);
      case JournalMood.anxious:
        return const Color(0xFFF59E0B);
      case JournalMood.angry:
        return const Color(0xFFEF4444);
      case JournalMood.reflective:
        return const Color(0xFF8B5CF6);
    }
  }
}

enum JournalTemplate {
  freeform,
  gratitude,
  dailyReflection,
  goalTracking,
  mindfulness,
  dreamJournal,
  travelLog,
  moodExploration;

  String get displayName {
    switch (this) {
      case JournalTemplate.freeform:
        return 'Free Form';
      case JournalTemplate.gratitude:
        return 'Gratitude';
      case JournalTemplate.dailyReflection:
        return 'Daily Reflection';
      case JournalTemplate.goalTracking:
        return 'Goal Tracking';
      case JournalTemplate.mindfulness:
        return 'Mindfulness';
      case JournalTemplate.dreamJournal:
        return 'Dream Journal';
      case JournalTemplate.travelLog:
        return 'Travel Log';
      case JournalTemplate.moodExploration:
        return 'Mood Exploration';
    }
  }

  String get description {
    switch (this) {
      case JournalTemplate.freeform:
        return 'Write freely about anything on your mind';
      case JournalTemplate.gratitude:
        return 'Focus on what you\'re grateful for today';
      case JournalTemplate.dailyReflection:
        return 'Reflect on your day, highs and lows';
      case JournalTemplate.goalTracking:
        return 'Track progress toward your goals';
      case JournalTemplate.mindfulness:
        return 'Mindful observations and present moment awareness';
      case JournalTemplate.dreamJournal:
        return 'Record and explore your dreams';
      case JournalTemplate.travelLog:
        return 'Document your travel experiences';
      case JournalTemplate.moodExploration:
        return 'Explore and understand your emotions';
    }
  }

  IconData get icon {
    switch (this) {
      case JournalTemplate.freeform:
        return Icons.edit_outlined;
      case JournalTemplate.gratitude:
        return Icons.favorite_outline;
      case JournalTemplate.dailyReflection:
        return Icons.today_outlined;
      case JournalTemplate.goalTracking:
        return Icons.flag_outlined;
      case JournalTemplate.mindfulness:
        return Icons.self_improvement_outlined;
      case JournalTemplate.dreamJournal:
        return Icons.bedtime_outlined;
      case JournalTemplate.travelLog:
        return Icons.flight_takeoff_outlined;
      case JournalTemplate.moodExploration:
        return Icons.psychology_outlined;
    }
  }

  List<String> get prompts {
    switch (this) {
      case JournalTemplate.freeform:
        return [
          'What\'s on your mind today?',
          'How are you feeling right now?',
          'What would you like to remember about today?',
        ];
      case JournalTemplate.gratitude:
        return [
          'What are three things you\'re grateful for today?',
          'Who made a positive impact on your day?',
          'What simple pleasure did you enjoy today?',
          'What opportunity are you thankful for?',
        ];
      case JournalTemplate.dailyReflection:
        return [
          'What was the highlight of your day?',
          'What challenged you today and how did you handle it?',
          'What did you learn about yourself today?',
          'What would you do differently?',
        ];
      case JournalTemplate.goalTracking:
        return [
          'What progress did you make toward your goals today?',
          'What obstacles did you encounter?',
          'What will you focus on tomorrow?',
          'How can you celebrate today\'s wins?',
        ];
      case JournalTemplate.mindfulness:
        return [
          'What do you notice in this present moment?',
          'How is your body feeling right now?',
          'What thoughts are passing through your mind?',
          'What can you let go of today?',
        ];
      case JournalTemplate.dreamJournal:
        return [
          'What do you remember from your dreams?',
          'How did the dream make you feel?',
          'What symbols or themes appeared?',
          'What might this dream mean to you?',
        ];
      case JournalTemplate.travelLog:
        return [
          'What new place did you discover today?',
          'What surprised you about this location?',
          'Who did you meet and what did you learn?',
          'What will you remember most about today?',
        ];
      case JournalTemplate.moodExploration:
        return [
          'How are you feeling emotionally right now?',
          'What triggered this feeling?',
          'What does your body tell you about this emotion?',
          'What do you need right now to feel better?',
        ];
    }
  }
}

enum GratitudeCategory {
  people,
  experiences,
  nature,
  achievements,
  health,
  opportunities,
  simpleJoys,
  learning;

  String get displayName {
    switch (this) {
      case GratitudeCategory.people:
        return 'People';
      case GratitudeCategory.experiences:
        return 'Experiences';
      case GratitudeCategory.nature:
        return 'Nature';
      case GratitudeCategory.achievements:
        return 'Achievements';
      case GratitudeCategory.health:
        return 'Health';
      case GratitudeCategory.opportunities:
        return 'Opportunities';
      case GratitudeCategory.simpleJoys:
        return 'Simple Joys';
      case GratitudeCategory.learning:
        return 'Learning';
    }
  }

  IconData get icon {
    switch (this) {
      case GratitudeCategory.people:
        return Icons.people_outline;
      case GratitudeCategory.experiences:
        return Icons.explore_outlined;
      case GratitudeCategory.nature:
        return Icons.nature_outlined;
      case GratitudeCategory.achievements:
        return Icons.emoji_events_outlined;
      case GratitudeCategory.health:
        return Icons.favorite_outline;
      case GratitudeCategory.opportunities:
        return Icons.door_front_door_outlined;
      case GratitudeCategory.simpleJoys:
        return Icons.sentiment_satisfied_alt_outlined;
      case GratitudeCategory.learning:
        return Icons.school_outlined;
    }
  }

  Color get color {
    switch (this) {
      case GratitudeCategory.people:
        return const Color(0xFF10B981);
      case GratitudeCategory.experiences:
        return const Color(0xFF3B82F6);
      case GratitudeCategory.nature:
        return const Color(0xFF059669);
      case GratitudeCategory.achievements:
        return const Color(0xFFF59E0B);
      case GratitudeCategory.health:
        return const Color(0xFFEF4444);
      case GratitudeCategory.opportunities:
        return const Color(0xFF8B5CF6);
      case GratitudeCategory.simpleJoys:
        return const Color(0xFFFF6B9D);
      case GratitudeCategory.learning:
        return const Color(0xFF6B7280);
    }
  }
}

class JournalPrompts {
  static const List<String> dailyPrompts = [
    'What made you smile today?',
    'Describe a moment when you felt truly present.',
    'What lesson did you learn today?',
    'How did you show kindness to yourself or others?',
    'What are you looking forward to tomorrow?',
    'What would you tell your past self about today?',
    'What sound, smell, or sight brought you joy today?',
    'How did you grow as a person today?',
    'What unexpected thing happened today?',
    'What are you most proud of right now?',
  ];

  static const List<String> reflectionPrompts = [
    'What patterns do you notice in your thoughts lately?',
    'How have you changed in the past month?',
    'What belief about yourself would you like to challenge?',
    'What does happiness mean to you right now?',
    'How do you want to be remembered?',
    'What would you do if you knew you couldn\'t fail?',
    'What advice would you give to someone in your situation?',
    'What are you most curious about right now?',
    'How do you define success for yourself?',
    'What would love do in this situation?',
  ];

  static const List<String> gratitudePrompts = [
    'What ordinary moment felt extraordinary today?',
    'Who in your life deserves more appreciation?',
    'What challenge are you grateful for in hindsight?',
    'What about your body are you thankful for?',
    'What opportunity came your way recently?',
    'What skill or talent are you grateful to have?',
    'What piece of technology makes your life better?',
    'What about your living space brings you comfort?',
    'What memory always makes you smile?',
    'What act of kindness did you witness or receive?',
  ];

  static String getRandomPrompt(JournalTemplate template) {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    switch (template) {
      case JournalTemplate.gratitude:
        return gratitudePrompts[random % gratitudePrompts.length];
      case JournalTemplate.dailyReflection:
        return reflectionPrompts[random % reflectionPrompts.length];
      default:
        return dailyPrompts[random % dailyPrompts.length];
    }
  }
}