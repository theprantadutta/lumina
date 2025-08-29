import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:lumina/core/theme/app_colors.dart';

part 'mood_entry.freezed.dart';
part 'mood_entry.g.dart';

@freezed
class MoodEntry with _$MoodEntry {
  const factory MoodEntry({
    required String id,
    required String userId,
    required MoodType mood,
    required int intensity, // 1-10 scale
    String? note,
    @Default([]) List<String> factors,
    required DateTime timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MoodEntry;

  factory MoodEntry.fromJson(Map<String, dynamic> json) => _$MoodEntryFromJson(json);
}

enum MoodType {
  ecstatic,
  happy,
  content,
  neutral,
  sad,
  anxious,
  angry,
  depressed;

  String get displayName {
    switch (this) {
      case MoodType.ecstatic:
        return 'Ecstatic';
      case MoodType.happy:
        return 'Happy';
      case MoodType.content:
        return 'Content';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.sad:
        return 'Sad';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.angry:
        return 'Angry';
      case MoodType.depressed:
        return 'Depressed';
    }
  }

  String get emoji {
    switch (this) {
      case MoodType.ecstatic:
        return '🤩';
      case MoodType.happy:
        return '😊';
      case MoodType.content:
        return '😌';
      case MoodType.neutral:
        return '😐';
      case MoodType.sad:
        return '😢';
      case MoodType.anxious:
        return '😰';
      case MoodType.angry:
        return '😠';
      case MoodType.depressed:
        return '😔';
    }
  }

  Color get color {
    switch (this) {
      case MoodType.ecstatic:
        return AppColors.moodEcstatic;
      case MoodType.happy:
        return AppColors.moodHappy;
      case MoodType.content:
        return AppColors.moodContent;
      case MoodType.neutral:
        return AppColors.moodNeutral;
      case MoodType.sad:
        return AppColors.moodSad;
      case MoodType.anxious:
        return AppColors.moodAnxious;
      case MoodType.angry:
        return AppColors.moodAngry;
      case MoodType.depressed:
        return AppColors.moodDepressed;
    }
  }

  int get baseIntensity {
    switch (this) {
      case MoodType.ecstatic:
        return 10;
      case MoodType.happy:
        return 8;
      case MoodType.content:
        return 7;
      case MoodType.neutral:
        return 5;
      case MoodType.sad:
        return 3;
      case MoodType.anxious:
        return 3;
      case MoodType.angry:
        return 4;
      case MoodType.depressed:
        return 2;
    }
  }
}

@freezed
class MoodFactor with _$MoodFactor {
  const MoodFactor._();
  
  const factory MoodFactor({
    required String id,
    required String name,
    required String category,
    required int iconCodePoint,
    @Default(true) bool isPositive,
  }) = _MoodFactor;

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  factory MoodFactor.fromJson(Map<String, dynamic> json) => _$MoodFactorFromJson(json);
}

class MoodFactors {
  static const List<MoodFactor> defaultFactors = [
    // Health & Wellness
    MoodFactor(
      id: 'exercise',
      name: 'Exercise',
      category: 'Health',
      iconCodePoint: 0xe0ac, // fitness_center
      isPositive: true,
    ),
    MoodFactor(
      id: 'sleep',
      name: 'Good Sleep',
      category: 'Health',
      iconCodePoint: 0xe98d, // bedtime
      isPositive: true,
    ),
    MoodFactor(
      id: 'poor_sleep',
      name: 'Poor Sleep',
      category: 'Health',
      iconCodePoint: 0xe98e, // bedtime_off
      isPositive: false,
    ),
    MoodFactor(
      id: 'healthy_food',
      name: 'Healthy Food',
      category: 'Health',
      iconCodePoint: 0xe561, // local_dining
      isPositive: true,
    ),
    
    // Social
    MoodFactor(
      id: 'friends',
      name: 'Time with Friends',
      category: 'Social',
      iconCodePoint: 0xe7fb, // people
      isPositive: true,
    ),
    MoodFactor(
      id: 'family',
      name: 'Family Time',
      category: 'Social',
      iconCodePoint: 0xe53f, // family_restroom
      isPositive: true,
    ),
    MoodFactor(
      id: 'social_media',
      name: 'Social Media',
      category: 'Social',
      iconCodePoint: 0xe32c, // phone_android
      isPositive: false,
    ),
    
    // Work & Productivity
    MoodFactor(
      id: 'work_stress',
      name: 'Work Stress',
      category: 'Work',
      iconCodePoint: 0xe97a, // work_off
      isPositive: false,
    ),
    MoodFactor(
      id: 'productivity',
      name: 'Productive Day',
      category: 'Work',
      iconCodePoint: 0xe2e0, // check_circle
      isPositive: true,
    ),
    
    // Personal
    MoodFactor(
      id: 'meditation',
      name: 'Meditation',
      category: 'Personal',
      iconCodePoint: 0xe4c4, // self_improvement
      isPositive: true,
    ),
    MoodFactor(
      id: 'music',
      name: 'Music',
      category: 'Personal',
      iconCodePoint: 0xe405, // music_note
      isPositive: true,
    ),
    MoodFactor(
      id: 'nature',
      name: 'Time in Nature',
      category: 'Personal',
      iconCodePoint: 0xe41f, // nature
      isPositive: true,
    ),
    
    // Weather & Environment
    MoodFactor(
      id: 'sunny_weather',
      name: 'Sunny Weather',
      category: 'Environment',
      iconCodePoint: 0xe82a, // wb_sunny
      isPositive: true,
    ),
    MoodFactor(
      id: 'rainy_weather',
      name: 'Rainy Weather',
      category: 'Environment',
      iconCodePoint: 0xe810, // cloudy_snowing
      isPositive: false,
    ),
  ];
}