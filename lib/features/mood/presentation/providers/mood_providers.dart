import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/features/auth/presentation/providers/auth_provider.dart';
import 'package:lumina/features/mood/data/services/mood_service.dart';
import 'package:lumina/shared/models/mood_entry.dart';

// Mood service provider
final moodServiceProvider = Provider<MoodService>((ref) {
  return MoodService();
});

// Current mood entry state provider (for the entry form)
final currentMoodEntryProvider =
    StateNotifierProvider<CurrentMoodEntryNotifier, MoodEntryState>((ref) {
      return CurrentMoodEntryNotifier();
    });

// Mood entries provider
final moodEntriesProvider = StreamProvider<List<MoodEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final moodService = ref.watch(moodServiceProvider);

  if (user == null) {
    return Stream.value([]);
  }

  return moodService.getMoodEntriesStream(userId: user.uid, limit: 100);
});

// Recent mood entries provider (last 7 days)
final recentMoodEntriesProvider = FutureProvider<List<MoodEntry>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final moodService = ref.watch(moodServiceProvider);

  if (user == null) {
    return [];
  }

  final now = DateTime.now();
  final sevenDaysAgo = now.subtract(const Duration(days: 7));

  return moodService.getMoodEntries(
    userId: user.uid,
    startDate: sevenDaysAgo,
    endDate: now,
  );
});

// Mood entries for specific date provider
final moodEntriesForDateProvider =
    FutureProvider.family<List<MoodEntry>, DateTime>((ref, date) async {
      final user = ref.watch(currentUserProvider);
      final moodService = ref.watch(moodServiceProvider);

      if (user == null) {
        return [];
      }

      return moodService.getMoodEntriesForDate(userId: user.uid, date: date);
    });

// Mood statistics provider
final moodStatisticsProvider = FutureProvider<MoodStatistics>((ref) async {
  final user = ref.watch(currentUserProvider);
  final moodService = ref.watch(moodServiceProvider);

  if (user == null) {
    return const MoodStatistics(
      totalEntries: 0,
      averageMood: 0.0,
      mostCommonMood: null,
      averageIntensity: 0.0,
    );
  }

  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));

  return moodService.getMoodStatistics(
    userId: user.uid,
    startDate: thirtyDaysAgo,
    endDate: now,
  );
});

// Mood trends provider
final moodTrendsProvider =
    FutureProvider.family<List<MoodTrendPoint>, MoodTrendsParams>((
      ref,
      params,
    ) async {
      final user = ref.watch(currentUserProvider);
      final moodService = ref.watch(moodServiceProvider);

      if (user == null) {
        return [];
      }

      return moodService.getMoodTrends(
        userId: user.uid,
        startDate: params.startDate,
        endDate: params.endDate,
        period: params.period,
      );
    });

// Mood entry actions provider
final moodEntryActionsProvider = Provider<MoodEntryActions>((ref) {
  final moodService = ref.watch(moodServiceProvider);
  return MoodEntryActions(moodService);
});

// State notifier for current mood entry
class CurrentMoodEntryNotifier extends StateNotifier<MoodEntryState> {
  CurrentMoodEntryNotifier() : super(const MoodEntryState());

  void updateMood(MoodType mood) {
    state = state.copyWith(selectedMood: mood, intensity: mood.baseIntensity);
  }

  void updateIntensity(int intensity) {
    state = state.copyWith(intensity: intensity);
  }

  void updateNote(String note) {
    state = state.copyWith(note: note);
  }

  void updateFactors(List<String> factors) {
    state = state.copyWith(factors: factors);
  }

  void addFactor(String factorId) {
    final currentFactors = List<String>.from(state.factors);
    if (!currentFactors.contains(factorId)) {
      currentFactors.add(factorId);
      state = state.copyWith(factors: currentFactors);
    }
  }

  void removeFactor(String factorId) {
    final currentFactors = List<String>.from(state.factors);
    currentFactors.remove(factorId);
    state = state.copyWith(factors: currentFactors);
  }

  void reset() {
    state = const MoodEntryState();
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }
}

// Mood entry state
class MoodEntryState {
  final MoodType? selectedMood;
  final int intensity;
  final String note;
  final List<String> factors;
  final bool isLoading;
  final String? error;

  const MoodEntryState({
    this.selectedMood,
    this.intensity = 5,
    this.note = '',
    this.factors = const [],
    this.isLoading = false,
    this.error,
  });

  MoodEntryState copyWith({
    MoodType? selectedMood,
    int? intensity,
    String? note,
    List<String>? factors,
    bool? isLoading,
    String? error,
  }) {
    return MoodEntryState(
      selectedMood: selectedMood ?? this.selectedMood,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
      factors: factors ?? this.factors,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get canSave => selectedMood != null && !isLoading;
}

// Mood entry actions
class MoodEntryActions {
  final MoodService _moodService;

  MoodEntryActions(this._moodService);

  Future<void> saveMoodEntry({
    required String userId,
    required MoodType mood,
    required int intensity,
    String? note,
    List<String>? factors,
  }) async {
    final moodEntry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      mood: mood,
      intensity: intensity,
      note: note?.isNotEmpty == true ? note : null,
      factors: factors ?? [],
      timestamp: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _moodService.createMoodEntry(moodEntry);
  }

  Future<void> updateMoodEntry(MoodEntry moodEntry) async {
    await _moodService.updateMoodEntry(moodEntry);
  }

  Future<void> deleteMoodEntry(String id) async {
    await _moodService.deleteMoodEntry(id);
  }
}

// Parameters for mood trends provider
class MoodTrendsParams {
  final DateTime startDate;
  final DateTime endDate;
  final TrendPeriod period;

  const MoodTrendsParams({
    required this.startDate,
    required this.endDate,
    required this.period,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodTrendsParams &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.period == period;
  }

  @override
  int get hashCode => Object.hash(startDate, endDate, period);
}
