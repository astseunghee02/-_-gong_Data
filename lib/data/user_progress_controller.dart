import 'package:flutter/foundation.dart';

class UserProgressState {
  final int missionPoints;
  final List<DateTime> completionHistory;

  const UserProgressState({
    this.missionPoints = 0,
    this.completionHistory = const [],
  });

  UserProgressState copyWith({
    int? missionPoints,
    List<DateTime>? completionHistory,
  }) {
    return UserProgressState(
      missionPoints: missionPoints ?? this.missionPoints,
      completionHistory: completionHistory != null
          ? List.unmodifiable(completionHistory)
          : this.completionHistory,
    );
  }
}

class UserProgressController {
  UserProgressController._internal();

  static final UserProgressController instance =
      UserProgressController._internal();

  final ValueNotifier<UserProgressState> notifier =
      ValueNotifier(const UserProgressState());

  int get missionPoints => notifier.value.missionPoints;

  List<DateTime> get completionHistory => notifier.value.completionHistory;

  void addMissionCompletion({required int points, DateTime? completionDate}) {
    if (points <= 0) return;
    final now = completionDate ?? DateTime.now();
    final updatedHistory = List<DateTime>.from(completionHistory)..add(now);

    notifier.value = notifier.value.copyWith(
      missionPoints: missionPoints + points,
      completionHistory: List.unmodifiable(updatedHistory),
    );
  }

  void reset() {
    notifier.value = const UserProgressState();
  }
}
