// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodEntry _$MoodEntryFromJson(Map<String, dynamic> json) => MoodEntry(
  id: json['id'] as String,
  userId: json['userId'] as String,
  mood: $enumDecode(_$MoodTypeEnumMap, json['mood']),
  intensity: (json['intensity'] as num).toInt(),
  note: json['note'] as String?,
  factors:
      (json['factors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  timestamp: DateTime.parse(json['timestamp'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MoodEntryToJson(MoodEntry instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'mood': _$MoodTypeEnumMap[instance.mood]!,
  'intensity': instance.intensity,
  'note': instance.note,
  'factors': instance.factors,
  'timestamp': instance.timestamp.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$MoodTypeEnumMap = {
  MoodType.ecstatic: 'ecstatic',
  MoodType.happy: 'happy',
  MoodType.content: 'content',
  MoodType.neutral: 'neutral',
  MoodType.sad: 'sad',
  MoodType.anxious: 'anxious',
  MoodType.angry: 'angry',
  MoodType.depressed: 'depressed',
};

MoodFactor _$MoodFactorFromJson(Map<String, dynamic> json) => MoodFactor(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  iconCodePoint: (json['iconCodePoint'] as num).toInt(),
  isPositive: json['isPositive'] as bool? ?? true,
);

Map<String, dynamic> _$MoodFactorToJson(MoodFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'iconCodePoint': instance.iconCodePoint,
      'isPositive': instance.isPositive,
    };
