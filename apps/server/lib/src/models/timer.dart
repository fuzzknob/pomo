import '../repositories/timer_repository.dart';

import 'model.dart';

class Timer implements Model {
  Timer({
    this.id,
    required this.startTime,
    required this.timerStartedAt,
    required this.status,
    required this.successionCount,
    required this.elapsedPrePause,
    required this.workTillStatusChange,
    required this.breakTillStatusChange,
    required this.userId,
  });

  @override
  int? id;
  DateTime startTime;
  DateTime timerStartedAt;
  TimerStatus status;
  int successionCount;
  int elapsedPrePause;
  int workTillStatusChange;
  int breakTillStatusChange;
  int userId;

  static TimerRepository get db => TimerRepository();

  Future<void> delete() => db.delete(id!);

  Future<Timer> save() => db.save(this);

  Timer copyWith({
    int? id,
    DateTime? startTime,
    DateTime? timerStartedAt,
    TimerStatus? status,
    int? successionCount,
    int? elapsedPrePause,
    int? workTillStatusChange,
    int? breakTillStatusChange,
    int? userId,
  }) => Timer(
    id: id ?? this.id,
    startTime: startTime ?? this.startTime,
    timerStartedAt: timerStartedAt ?? this.timerStartedAt,
    status: status ?? this.status,
    successionCount: successionCount ?? this.successionCount,
    elapsedPrePause: elapsedPrePause ?? this.elapsedPrePause,
    workTillStatusChange: workTillStatusChange ?? this.workTillStatusChange,
    breakTillStatusChange: breakTillStatusChange ?? this.breakTillStatusChange,
    userId: userId ?? this.userId,
  );

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'startTime': startTime.toUtc().toIso8601String(),
      'timerStartedAt': timerStartedAt.toUtc().toIso8601String(),
      'status': status.value,
      'successionCount': successionCount,
      'elapsedPrePause': elapsedPrePause,
      'totalBreakTime': breakTillStatusChange,
      'totalWorkTime': workTillStatusChange,
      'userId': userId,
    };
  }

  factory Timer.fromJson(Map<String, Object?> json) {
    return Timer(
      id: json['id'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      timerStartedAt: DateTime.parse(json['startTime'] as String),
      status: TimerStatus.fromString(json['status'] as String),
      successionCount: json['successionCount'] as int,
      elapsedPrePause: json['elapsedPrePause'] as int,
      breakTillStatusChange: json['totalBreakTime'] as int,
      workTillStatusChange: json['totalWorkTime'] as int,
      userId: json['userId'] as int,
    );
  }
}

enum TimerStatus {
  idle,
  working,
  shortBreak,
  longBreak,
  paused,
  stopped;

  String get value {
    return switch (this) {
      (TimerStatus.idle) => 'IDLE',
      (TimerStatus.working) => 'WORKING',
      (TimerStatus.shortBreak) => 'SHORT_BREAK',
      (TimerStatus.longBreak) => 'LONG_BREAK',
      (TimerStatus.paused) => 'PAUSED',
      (TimerStatus.stopped) => 'STOPPED',
    };
  }

  @override
  String toString() => value;

  static TimerStatus fromString(String status) {
    return switch (status) {
      ('IDLE') => TimerStatus.idle,
      ('WORKING') => TimerStatus.working,
      ('SHORT_BREAK') => TimerStatus.shortBreak,
      ('LONG_BREAK') => TimerStatus.longBreak,
      ('PAUSED') => TimerStatus.paused,
      ('STOPPED') => TimerStatus.stopped,
      _ => throw Exception('$status is not a valid timer status'),
    };
  }
}
