// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JournalEntry _$JournalEntryFromJson(Map<String, dynamic> json) => JournalEntry(
  id: json['id'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  audioUrl: json['audioUrl'] as String?,
  gratitudeList:
      (json['gratitudeList'] as List<dynamic>?)
          ?.map((e) => Gratitude.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  timestamp: DateTime.parse(json['timestamp'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isFavorite: json['isFavorite'] as bool? ?? false,
  mood:
      $enumDecodeNullable(_$JournalMoodEnumMap, json['mood']) ??
      JournalMood.neutral,
  weather: json['weather'] as String?,
  location: json['location'] as String?,
  template:
      $enumDecodeNullable(_$JournalTemplateEnumMap, json['template']) ??
      JournalTemplate.freeform,
);

Map<String, dynamic> _$JournalEntryToJson(JournalEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'content': instance.content,
      'tags': instance.tags,
      'imageUrls': instance.imageUrls,
      'audioUrl': instance.audioUrl,
      'gratitudeList': instance.gratitudeList,
      'timestamp': instance.timestamp.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isFavorite': instance.isFavorite,
      'mood': _$JournalMoodEnumMap[instance.mood]!,
      'weather': instance.weather,
      'location': instance.location,
      'template': _$JournalTemplateEnumMap[instance.template]!,
    };

const _$JournalMoodEnumMap = {
  JournalMood.ecstatic: 'ecstatic',
  JournalMood.happy: 'happy',
  JournalMood.content: 'content',
  JournalMood.neutral: 'neutral',
  JournalMood.sad: 'sad',
  JournalMood.anxious: 'anxious',
  JournalMood.angry: 'angry',
  JournalMood.reflective: 'reflective',
};

const _$JournalTemplateEnumMap = {
  JournalTemplate.freeform: 'freeform',
  JournalTemplate.gratitude: 'gratitude',
  JournalTemplate.dailyReflection: 'dailyReflection',
  JournalTemplate.goalTracking: 'goalTracking',
  JournalTemplate.mindfulness: 'mindfulness',
  JournalTemplate.dreamJournal: 'dreamJournal',
  JournalTemplate.travelLog: 'travelLog',
  JournalTemplate.moodExploration: 'moodExploration',
};

Gratitude _$GratitudeFromJson(Map<String, dynamic> json) => Gratitude(
  id: json['id'] as String,
  text: json['text'] as String,
  category: $enumDecode(_$GratitudeCategoryEnumMap, json['category']),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$GratitudeToJson(Gratitude instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'category': _$GratitudeCategoryEnumMap[instance.category]!,
  'createdAt': instance.createdAt?.toIso8601String(),
};

const _$GratitudeCategoryEnumMap = {
  GratitudeCategory.people: 'people',
  GratitudeCategory.experiences: 'experiences',
  GratitudeCategory.nature: 'nature',
  GratitudeCategory.achievements: 'achievements',
  GratitudeCategory.health: 'health',
  GratitudeCategory.opportunities: 'opportunities',
  GratitudeCategory.simpleJoys: 'simpleJoys',
  GratitudeCategory.learning: 'learning',
};
