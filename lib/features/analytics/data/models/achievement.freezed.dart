// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Achievement _$AchievementFromJson(Map<String, dynamic> json) {
  return _Achievement.fromJson(json);
}

/// @nodoc
mixin _$Achievement {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  AchievementType get type => throw _privateConstructorUsedError;
  AchievementCategory get category => throw _privateConstructorUsedError;
  int get targetValue => throw _privateConstructorUsedError;
  int get currentProgress => throw _privateConstructorUsedError;
  bool get isUnlocked => throw _privateConstructorUsedError;
  bool get isNotified => throw _privateConstructorUsedError;
  DateTime? get unlockedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  int get tier =>
      throw _privateConstructorUsedError; // 1-5 difficulty/importance
  @JsonKey(ignore: true)
  IconData? get customIcon => throw _privateConstructorUsedError;
  int get iconCodePoint => throw _privateConstructorUsedError;
  String get iconFontFamily => throw _privateConstructorUsedError;
  String? get reward => throw _privateConstructorUsedError;

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementCopyWith<Achievement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementCopyWith<$Res> {
  factory $AchievementCopyWith(
    Achievement value,
    $Res Function(Achievement) then,
  ) = _$AchievementCopyWithImpl<$Res, Achievement>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    AchievementType type,
    AchievementCategory category,
    int targetValue,
    int currentProgress,
    bool isUnlocked,
    bool isNotified,
    DateTime? unlockedAt,
    DateTime? createdAt,
    int tier,
    @JsonKey(ignore: true) IconData? customIcon,
    int iconCodePoint,
    String iconFontFamily,
    String? reward,
  });
}

/// @nodoc
class _$AchievementCopyWithImpl<$Res, $Val extends Achievement>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? category = null,
    Object? targetValue = null,
    Object? currentProgress = null,
    Object? isUnlocked = null,
    Object? isNotified = null,
    Object? unlockedAt = freezed,
    Object? createdAt = freezed,
    Object? tier = null,
    Object? customIcon = freezed,
    Object? iconCodePoint = null,
    Object? iconFontFamily = null,
    Object? reward = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as AchievementType,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as AchievementCategory,
            targetValue: null == targetValue
                ? _value.targetValue
                : targetValue // ignore: cast_nullable_to_non_nullable
                      as int,
            currentProgress: null == currentProgress
                ? _value.currentProgress
                : currentProgress // ignore: cast_nullable_to_non_nullable
                      as int,
            isUnlocked: null == isUnlocked
                ? _value.isUnlocked
                : isUnlocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            isNotified: null == isNotified
                ? _value.isNotified
                : isNotified // ignore: cast_nullable_to_non_nullable
                      as bool,
            unlockedAt: freezed == unlockedAt
                ? _value.unlockedAt
                : unlockedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            tier: null == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as int,
            customIcon: freezed == customIcon
                ? _value.customIcon
                : customIcon // ignore: cast_nullable_to_non_nullable
                      as IconData?,
            iconCodePoint: null == iconCodePoint
                ? _value.iconCodePoint
                : iconCodePoint // ignore: cast_nullable_to_non_nullable
                      as int,
            iconFontFamily: null == iconFontFamily
                ? _value.iconFontFamily
                : iconFontFamily // ignore: cast_nullable_to_non_nullable
                      as String,
            reward: freezed == reward
                ? _value.reward
                : reward // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AchievementImplCopyWith<$Res>
    implements $AchievementCopyWith<$Res> {
  factory _$$AchievementImplCopyWith(
    _$AchievementImpl value,
    $Res Function(_$AchievementImpl) then,
  ) = __$$AchievementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    AchievementType type,
    AchievementCategory category,
    int targetValue,
    int currentProgress,
    bool isUnlocked,
    bool isNotified,
    DateTime? unlockedAt,
    DateTime? createdAt,
    int tier,
    @JsonKey(ignore: true) IconData? customIcon,
    int iconCodePoint,
    String iconFontFamily,
    String? reward,
  });
}

/// @nodoc
class __$$AchievementImplCopyWithImpl<$Res>
    extends _$AchievementCopyWithImpl<$Res, _$AchievementImpl>
    implements _$$AchievementImplCopyWith<$Res> {
  __$$AchievementImplCopyWithImpl(
    _$AchievementImpl _value,
    $Res Function(_$AchievementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? category = null,
    Object? targetValue = null,
    Object? currentProgress = null,
    Object? isUnlocked = null,
    Object? isNotified = null,
    Object? unlockedAt = freezed,
    Object? createdAt = freezed,
    Object? tier = null,
    Object? customIcon = freezed,
    Object? iconCodePoint = null,
    Object? iconFontFamily = null,
    Object? reward = freezed,
  }) {
    return _then(
      _$AchievementImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as AchievementType,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as AchievementCategory,
        targetValue: null == targetValue
            ? _value.targetValue
            : targetValue // ignore: cast_nullable_to_non_nullable
                  as int,
        currentProgress: null == currentProgress
            ? _value.currentProgress
            : currentProgress // ignore: cast_nullable_to_non_nullable
                  as int,
        isUnlocked: null == isUnlocked
            ? _value.isUnlocked
            : isUnlocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        isNotified: null == isNotified
            ? _value.isNotified
            : isNotified // ignore: cast_nullable_to_non_nullable
                  as bool,
        unlockedAt: freezed == unlockedAt
            ? _value.unlockedAt
            : unlockedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        tier: null == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as int,
        customIcon: freezed == customIcon
            ? _value.customIcon
            : customIcon // ignore: cast_nullable_to_non_nullable
                  as IconData?,
        iconCodePoint: null == iconCodePoint
            ? _value.iconCodePoint
            : iconCodePoint // ignore: cast_nullable_to_non_nullable
                  as int,
        iconFontFamily: null == iconFontFamily
            ? _value.iconFontFamily
            : iconFontFamily // ignore: cast_nullable_to_non_nullable
                  as String,
        reward: freezed == reward
            ? _value.reward
            : reward // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementImpl implements _Achievement {
  const _$AchievementImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.targetValue,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.isNotified = false,
    this.unlockedAt,
    this.createdAt,
    this.tier = 1,
    @JsonKey(ignore: true) this.customIcon,
    this.iconCodePoint = 0,
    this.iconFontFamily = 'MaterialIcons',
    this.reward,
  });

  factory _$AchievementImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final AchievementType type;
  @override
  final AchievementCategory category;
  @override
  final int targetValue;
  @override
  @JsonKey()
  final int currentProgress;
  @override
  @JsonKey()
  final bool isUnlocked;
  @override
  @JsonKey()
  final bool isNotified;
  @override
  final DateTime? unlockedAt;
  @override
  final DateTime? createdAt;
  @override
  @JsonKey()
  final int tier;
  // 1-5 difficulty/importance
  @override
  @JsonKey(ignore: true)
  final IconData? customIcon;
  @override
  @JsonKey()
  final int iconCodePoint;
  @override
  @JsonKey()
  final String iconFontFamily;
  @override
  final String? reward;

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, description: $description, type: $type, category: $category, targetValue: $targetValue, currentProgress: $currentProgress, isUnlocked: $isUnlocked, isNotified: $isNotified, unlockedAt: $unlockedAt, createdAt: $createdAt, tier: $tier, customIcon: $customIcon, iconCodePoint: $iconCodePoint, iconFontFamily: $iconFontFamily, reward: $reward)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.targetValue, targetValue) ||
                other.targetValue == targetValue) &&
            (identical(other.currentProgress, currentProgress) ||
                other.currentProgress == currentProgress) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.isNotified, isNotified) ||
                other.isNotified == isNotified) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.customIcon, customIcon) ||
                other.customIcon == customIcon) &&
            (identical(other.iconCodePoint, iconCodePoint) ||
                other.iconCodePoint == iconCodePoint) &&
            (identical(other.iconFontFamily, iconFontFamily) ||
                other.iconFontFamily == iconFontFamily) &&
            (identical(other.reward, reward) || other.reward == reward));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    type,
    category,
    targetValue,
    currentProgress,
    isUnlocked,
    isNotified,
    unlockedAt,
    createdAt,
    tier,
    customIcon,
    iconCodePoint,
    iconFontFamily,
    reward,
  );

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      __$$AchievementImplCopyWithImpl<_$AchievementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementImplToJson(this);
  }
}

abstract class _Achievement implements Achievement {
  const factory _Achievement({
    required final String id,
    required final String title,
    required final String description,
    required final AchievementType type,
    required final AchievementCategory category,
    required final int targetValue,
    final int currentProgress,
    final bool isUnlocked,
    final bool isNotified,
    final DateTime? unlockedAt,
    final DateTime? createdAt,
    final int tier,
    @JsonKey(ignore: true) final IconData? customIcon,
    final int iconCodePoint,
    final String iconFontFamily,
    final String? reward,
  }) = _$AchievementImpl;

  factory _Achievement.fromJson(Map<String, dynamic> json) =
      _$AchievementImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  AchievementType get type;
  @override
  AchievementCategory get category;
  @override
  int get targetValue;
  @override
  int get currentProgress;
  @override
  bool get isUnlocked;
  @override
  bool get isNotified;
  @override
  DateTime? get unlockedAt;
  @override
  DateTime? get createdAt;
  @override
  int get tier; // 1-5 difficulty/importance
  @override
  @JsonKey(ignore: true)
  IconData? get customIcon;
  @override
  int get iconCodePoint;
  @override
  String get iconFontFamily;
  @override
  String? get reward;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) {
  return _UserProgress.fromJson(json);
}

/// @nodoc
mixin _$UserProgress {
  String get userId => throw _privateConstructorUsedError;
  List<Achievement> get unlockedAchievements =>
      throw _privateConstructorUsedError;
  List<Achievement> get inProgressAchievements =>
      throw _privateConstructorUsedError;
  int get totalPoints => throw _privateConstructorUsedError;
  int get currentLevel => throw _privateConstructorUsedError;
  int get currentLevelProgress => throw _privateConstructorUsedError;
  int get nextLevelRequirement => throw _privateConstructorUsedError;
  Map<AchievementCategory, int> get categoryProgress =>
      throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this UserProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProgressCopyWith<UserProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProgressCopyWith<$Res> {
  factory $UserProgressCopyWith(
    UserProgress value,
    $Res Function(UserProgress) then,
  ) = _$UserProgressCopyWithImpl<$Res, UserProgress>;
  @useResult
  $Res call({
    String userId,
    List<Achievement> unlockedAchievements,
    List<Achievement> inProgressAchievements,
    int totalPoints,
    int currentLevel,
    int currentLevelProgress,
    int nextLevelRequirement,
    Map<AchievementCategory, int> categoryProgress,
    DateTime? lastUpdated,
  });
}

/// @nodoc
class _$UserProgressCopyWithImpl<$Res, $Val extends UserProgress>
    implements $UserProgressCopyWith<$Res> {
  _$UserProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? unlockedAchievements = null,
    Object? inProgressAchievements = null,
    Object? totalPoints = null,
    Object? currentLevel = null,
    Object? currentLevelProgress = null,
    Object? nextLevelRequirement = null,
    Object? categoryProgress = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            unlockedAchievements: null == unlockedAchievements
                ? _value.unlockedAchievements
                : unlockedAchievements // ignore: cast_nullable_to_non_nullable
                      as List<Achievement>,
            inProgressAchievements: null == inProgressAchievements
                ? _value.inProgressAchievements
                : inProgressAchievements // ignore: cast_nullable_to_non_nullable
                      as List<Achievement>,
            totalPoints: null == totalPoints
                ? _value.totalPoints
                : totalPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            currentLevel: null == currentLevel
                ? _value.currentLevel
                : currentLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            currentLevelProgress: null == currentLevelProgress
                ? _value.currentLevelProgress
                : currentLevelProgress // ignore: cast_nullable_to_non_nullable
                      as int,
            nextLevelRequirement: null == nextLevelRequirement
                ? _value.nextLevelRequirement
                : nextLevelRequirement // ignore: cast_nullable_to_non_nullable
                      as int,
            categoryProgress: null == categoryProgress
                ? _value.categoryProgress
                : categoryProgress // ignore: cast_nullable_to_non_nullable
                      as Map<AchievementCategory, int>,
            lastUpdated: freezed == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProgressImplCopyWith<$Res>
    implements $UserProgressCopyWith<$Res> {
  factory _$$UserProgressImplCopyWith(
    _$UserProgressImpl value,
    $Res Function(_$UserProgressImpl) then,
  ) = __$$UserProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    List<Achievement> unlockedAchievements,
    List<Achievement> inProgressAchievements,
    int totalPoints,
    int currentLevel,
    int currentLevelProgress,
    int nextLevelRequirement,
    Map<AchievementCategory, int> categoryProgress,
    DateTime? lastUpdated,
  });
}

/// @nodoc
class __$$UserProgressImplCopyWithImpl<$Res>
    extends _$UserProgressCopyWithImpl<$Res, _$UserProgressImpl>
    implements _$$UserProgressImplCopyWith<$Res> {
  __$$UserProgressImplCopyWithImpl(
    _$UserProgressImpl _value,
    $Res Function(_$UserProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? unlockedAchievements = null,
    Object? inProgressAchievements = null,
    Object? totalPoints = null,
    Object? currentLevel = null,
    Object? currentLevelProgress = null,
    Object? nextLevelRequirement = null,
    Object? categoryProgress = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _$UserProgressImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        unlockedAchievements: null == unlockedAchievements
            ? _value._unlockedAchievements
            : unlockedAchievements // ignore: cast_nullable_to_non_nullable
                  as List<Achievement>,
        inProgressAchievements: null == inProgressAchievements
            ? _value._inProgressAchievements
            : inProgressAchievements // ignore: cast_nullable_to_non_nullable
                  as List<Achievement>,
        totalPoints: null == totalPoints
            ? _value.totalPoints
            : totalPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        currentLevel: null == currentLevel
            ? _value.currentLevel
            : currentLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        currentLevelProgress: null == currentLevelProgress
            ? _value.currentLevelProgress
            : currentLevelProgress // ignore: cast_nullable_to_non_nullable
                  as int,
        nextLevelRequirement: null == nextLevelRequirement
            ? _value.nextLevelRequirement
            : nextLevelRequirement // ignore: cast_nullable_to_non_nullable
                  as int,
        categoryProgress: null == categoryProgress
            ? _value._categoryProgress
            : categoryProgress // ignore: cast_nullable_to_non_nullable
                  as Map<AchievementCategory, int>,
        lastUpdated: freezed == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProgressImpl implements _UserProgress {
  const _$UserProgressImpl({
    required this.userId,
    final List<Achievement> unlockedAchievements = const [],
    final List<Achievement> inProgressAchievements = const [],
    this.totalPoints = 0,
    this.currentLevel = 1,
    this.currentLevelProgress = 0,
    this.nextLevelRequirement = 100,
    final Map<AchievementCategory, int> categoryProgress = const {},
    this.lastUpdated,
  }) : _unlockedAchievements = unlockedAchievements,
       _inProgressAchievements = inProgressAchievements,
       _categoryProgress = categoryProgress;

  factory _$UserProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProgressImplFromJson(json);

  @override
  final String userId;
  final List<Achievement> _unlockedAchievements;
  @override
  @JsonKey()
  List<Achievement> get unlockedAchievements {
    if (_unlockedAchievements is EqualUnmodifiableListView)
      return _unlockedAchievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unlockedAchievements);
  }

  final List<Achievement> _inProgressAchievements;
  @override
  @JsonKey()
  List<Achievement> get inProgressAchievements {
    if (_inProgressAchievements is EqualUnmodifiableListView)
      return _inProgressAchievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_inProgressAchievements);
  }

  @override
  @JsonKey()
  final int totalPoints;
  @override
  @JsonKey()
  final int currentLevel;
  @override
  @JsonKey()
  final int currentLevelProgress;
  @override
  @JsonKey()
  final int nextLevelRequirement;
  final Map<AchievementCategory, int> _categoryProgress;
  @override
  @JsonKey()
  Map<AchievementCategory, int> get categoryProgress {
    if (_categoryProgress is EqualUnmodifiableMapView) return _categoryProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryProgress);
  }

  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'UserProgress(userId: $userId, unlockedAchievements: $unlockedAchievements, inProgressAchievements: $inProgressAchievements, totalPoints: $totalPoints, currentLevel: $currentLevel, currentLevelProgress: $currentLevelProgress, nextLevelRequirement: $nextLevelRequirement, categoryProgress: $categoryProgress, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProgressImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(
              other._unlockedAchievements,
              _unlockedAchievements,
            ) &&
            const DeepCollectionEquality().equals(
              other._inProgressAchievements,
              _inProgressAchievements,
            ) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.currentLevelProgress, currentLevelProgress) ||
                other.currentLevelProgress == currentLevelProgress) &&
            (identical(other.nextLevelRequirement, nextLevelRequirement) ||
                other.nextLevelRequirement == nextLevelRequirement) &&
            const DeepCollectionEquality().equals(
              other._categoryProgress,
              _categoryProgress,
            ) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    const DeepCollectionEquality().hash(_unlockedAchievements),
    const DeepCollectionEquality().hash(_inProgressAchievements),
    totalPoints,
    currentLevel,
    currentLevelProgress,
    nextLevelRequirement,
    const DeepCollectionEquality().hash(_categoryProgress),
    lastUpdated,
  );

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      __$$UserProgressImplCopyWithImpl<_$UserProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProgressImplToJson(this);
  }
}

abstract class _UserProgress implements UserProgress {
  const factory _UserProgress({
    required final String userId,
    final List<Achievement> unlockedAchievements,
    final List<Achievement> inProgressAchievements,
    final int totalPoints,
    final int currentLevel,
    final int currentLevelProgress,
    final int nextLevelRequirement,
    final Map<AchievementCategory, int> categoryProgress,
    final DateTime? lastUpdated,
  }) = _$UserProgressImpl;

  factory _UserProgress.fromJson(Map<String, dynamic> json) =
      _$UserProgressImpl.fromJson;

  @override
  String get userId;
  @override
  List<Achievement> get unlockedAchievements;
  @override
  List<Achievement> get inProgressAchievements;
  @override
  int get totalPoints;
  @override
  int get currentLevel;
  @override
  int get currentLevelProgress;
  @override
  int get nextLevelRequirement;
  @override
  Map<AchievementCategory, int> get categoryProgress;
  @override
  DateTime? get lastUpdated;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
