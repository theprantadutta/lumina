// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journal_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

JournalEntry _$JournalEntryFromJson(Map<String, dynamic> json) {
  return _JournalEntry.fromJson(json);
}

/// @nodoc
mixin _$JournalEntry {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;
  String? get audioUrl => throw _privateConstructorUsedError;
  List<Gratitude> get gratitudeList => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  JournalMood get mood => throw _privateConstructorUsedError;
  String? get weather => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  JournalTemplate get template => throw _privateConstructorUsedError;

  /// Serializes this JournalEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JournalEntryCopyWith<JournalEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JournalEntryCopyWith<$Res> {
  factory $JournalEntryCopyWith(
    JournalEntry value,
    $Res Function(JournalEntry) then,
  ) = _$JournalEntryCopyWithImpl<$Res, JournalEntry>;
  @useResult
  $Res call({
    String id,
    String userId,
    String title,
    String content,
    List<String> tags,
    List<String> imageUrls,
    String? audioUrl,
    List<Gratitude> gratitudeList,
    DateTime timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isFavorite,
    JournalMood mood,
    String? weather,
    String? location,
    JournalTemplate template,
  });
}

/// @nodoc
class _$JournalEntryCopyWithImpl<$Res, $Val extends JournalEntry>
    implements $JournalEntryCopyWith<$Res> {
  _$JournalEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? content = null,
    Object? tags = null,
    Object? imageUrls = null,
    Object? audioUrl = freezed,
    Object? gratitudeList = null,
    Object? timestamp = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isFavorite = null,
    Object? mood = null,
    Object? weather = freezed,
    Object? location = freezed,
    Object? template = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            imageUrls: null == imageUrls
                ? _value.imageUrls
                : imageUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            audioUrl: freezed == audioUrl
                ? _value.audioUrl
                : audioUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            gratitudeList: null == gratitudeList
                ? _value.gratitudeList
                : gratitudeList // ignore: cast_nullable_to_non_nullable
                      as List<Gratitude>,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isFavorite: null == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
                      as bool,
            mood: null == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as JournalMood,
            weather: freezed == weather
                ? _value.weather
                : weather // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            template: null == template
                ? _value.template
                : template // ignore: cast_nullable_to_non_nullable
                      as JournalTemplate,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JournalEntryImplCopyWith<$Res>
    implements $JournalEntryCopyWith<$Res> {
  factory _$$JournalEntryImplCopyWith(
    _$JournalEntryImpl value,
    $Res Function(_$JournalEntryImpl) then,
  ) = __$$JournalEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String title,
    String content,
    List<String> tags,
    List<String> imageUrls,
    String? audioUrl,
    List<Gratitude> gratitudeList,
    DateTime timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isFavorite,
    JournalMood mood,
    String? weather,
    String? location,
    JournalTemplate template,
  });
}

/// @nodoc
class __$$JournalEntryImplCopyWithImpl<$Res>
    extends _$JournalEntryCopyWithImpl<$Res, _$JournalEntryImpl>
    implements _$$JournalEntryImplCopyWith<$Res> {
  __$$JournalEntryImplCopyWithImpl(
    _$JournalEntryImpl _value,
    $Res Function(_$JournalEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? content = null,
    Object? tags = null,
    Object? imageUrls = null,
    Object? audioUrl = freezed,
    Object? gratitudeList = null,
    Object? timestamp = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isFavorite = null,
    Object? mood = null,
    Object? weather = freezed,
    Object? location = freezed,
    Object? template = null,
  }) {
    return _then(
      _$JournalEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        imageUrls: null == imageUrls
            ? _value._imageUrls
            : imageUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        audioUrl: freezed == audioUrl
            ? _value.audioUrl
            : audioUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        gratitudeList: null == gratitudeList
            ? _value._gratitudeList
            : gratitudeList // ignore: cast_nullable_to_non_nullable
                  as List<Gratitude>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isFavorite: null == isFavorite
            ? _value.isFavorite
            : isFavorite // ignore: cast_nullable_to_non_nullable
                  as bool,
        mood: null == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as JournalMood,
        weather: freezed == weather
            ? _value.weather
            : weather // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        template: null == template
            ? _value.template
            : template // ignore: cast_nullable_to_non_nullable
                  as JournalTemplate,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JournalEntryImpl implements _JournalEntry {
  const _$JournalEntryImpl({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    final List<String> tags = const [],
    final List<String> imageUrls = const [],
    this.audioUrl,
    final List<Gratitude> gratitudeList = const [],
    required this.timestamp,
    this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.mood = JournalMood.neutral,
    this.weather,
    this.location,
    this.template = JournalTemplate.freeform,
  }) : _tags = tags,
       _imageUrls = imageUrls,
       _gratitudeList = gratitudeList;

  factory _$JournalEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$JournalEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final String content;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<String> _imageUrls;
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  @override
  final String? audioUrl;
  final List<Gratitude> _gratitudeList;
  @override
  @JsonKey()
  List<Gratitude> get gratitudeList {
    if (_gratitudeList is EqualUnmodifiableListView) return _gratitudeList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gratitudeList);
  }

  @override
  final DateTime timestamp;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  @JsonKey()
  final JournalMood mood;
  @override
  final String? weather;
  @override
  final String? location;
  @override
  @JsonKey()
  final JournalTemplate template;

  @override
  String toString() {
    return 'JournalEntry(id: $id, userId: $userId, title: $title, content: $content, tags: $tags, imageUrls: $imageUrls, audioUrl: $audioUrl, gratitudeList: $gratitudeList, timestamp: $timestamp, createdAt: $createdAt, updatedAt: $updatedAt, isFavorite: $isFavorite, mood: $mood, weather: $weather, location: $location, template: $template)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JournalEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(
              other._imageUrls,
              _imageUrls,
            ) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            const DeepCollectionEquality().equals(
              other._gratitudeList,
              _gratitudeList,
            ) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.weather, weather) || other.weather == weather) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.template, template) ||
                other.template == template));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    title,
    content,
    const DeepCollectionEquality().hash(_tags),
    const DeepCollectionEquality().hash(_imageUrls),
    audioUrl,
    const DeepCollectionEquality().hash(_gratitudeList),
    timestamp,
    createdAt,
    updatedAt,
    isFavorite,
    mood,
    weather,
    location,
    template,
  );

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JournalEntryImplCopyWith<_$JournalEntryImpl> get copyWith =>
      __$$JournalEntryImplCopyWithImpl<_$JournalEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JournalEntryImplToJson(this);
  }
}

abstract class _JournalEntry implements JournalEntry {
  const factory _JournalEntry({
    required final String id,
    required final String userId,
    required final String title,
    required final String content,
    final List<String> tags,
    final List<String> imageUrls,
    final String? audioUrl,
    final List<Gratitude> gratitudeList,
    required final DateTime timestamp,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final bool isFavorite,
    final JournalMood mood,
    final String? weather,
    final String? location,
    final JournalTemplate template,
  }) = _$JournalEntryImpl;

  factory _JournalEntry.fromJson(Map<String, dynamic> json) =
      _$JournalEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  String get content;
  @override
  List<String> get tags;
  @override
  List<String> get imageUrls;
  @override
  String? get audioUrl;
  @override
  List<Gratitude> get gratitudeList;
  @override
  DateTime get timestamp;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  bool get isFavorite;
  @override
  JournalMood get mood;
  @override
  String? get weather;
  @override
  String? get location;
  @override
  JournalTemplate get template;

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JournalEntryImplCopyWith<_$JournalEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Gratitude _$GratitudeFromJson(Map<String, dynamic> json) {
  return _Gratitude.fromJson(json);
}

/// @nodoc
mixin _$Gratitude {
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  GratitudeCategory get category => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Gratitude to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Gratitude
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GratitudeCopyWith<Gratitude> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GratitudeCopyWith<$Res> {
  factory $GratitudeCopyWith(Gratitude value, $Res Function(Gratitude) then) =
      _$GratitudeCopyWithImpl<$Res, Gratitude>;
  @useResult
  $Res call({
    String id,
    String text,
    GratitudeCategory category,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$GratitudeCopyWithImpl<$Res, $Val extends Gratitude>
    implements $GratitudeCopyWith<$Res> {
  _$GratitudeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Gratitude
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? category = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as GratitudeCategory,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GratitudeImplCopyWith<$Res>
    implements $GratitudeCopyWith<$Res> {
  factory _$$GratitudeImplCopyWith(
    _$GratitudeImpl value,
    $Res Function(_$GratitudeImpl) then,
  ) = __$$GratitudeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String text,
    GratitudeCategory category,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$GratitudeImplCopyWithImpl<$Res>
    extends _$GratitudeCopyWithImpl<$Res, _$GratitudeImpl>
    implements _$$GratitudeImplCopyWith<$Res> {
  __$$GratitudeImplCopyWithImpl(
    _$GratitudeImpl _value,
    $Res Function(_$GratitudeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Gratitude
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? category = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$GratitudeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as GratitudeCategory,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GratitudeImpl implements _Gratitude {
  const _$GratitudeImpl({
    required this.id,
    required this.text,
    required this.category,
    this.createdAt,
  });

  factory _$GratitudeImpl.fromJson(Map<String, dynamic> json) =>
      _$$GratitudeImplFromJson(json);

  @override
  final String id;
  @override
  final String text;
  @override
  final GratitudeCategory category;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Gratitude(id: $id, text: $text, category: $category, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GratitudeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, text, category, createdAt);

  /// Create a copy of Gratitude
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GratitudeImplCopyWith<_$GratitudeImpl> get copyWith =>
      __$$GratitudeImplCopyWithImpl<_$GratitudeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GratitudeImplToJson(this);
  }
}

abstract class _Gratitude implements Gratitude {
  const factory _Gratitude({
    required final String id,
    required final String text,
    required final GratitudeCategory category,
    final DateTime? createdAt,
  }) = _$GratitudeImpl;

  factory _Gratitude.fromJson(Map<String, dynamic> json) =
      _$GratitudeImpl.fromJson;

  @override
  String get id;
  @override
  String get text;
  @override
  GratitudeCategory get category;
  @override
  DateTime? get createdAt;

  /// Create a copy of Gratitude
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GratitudeImplCopyWith<_$GratitudeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
