import 'package:intl/intl.dart';
import 'package:mental_math_marathon/domain/entities/session.dart';

class SessionModel extends Session {
  const SessionModel({
    required String id,
    required DateTime startTime,
    required DateTime endTime,
    required String mode,
    required String difficulty,
    required List<String> operators,
    required int totalQuestions,
    required int correctAnswers,
    required int wrongAnswers,
    required int cph,
    required double accuracy,
    required int bestStreak,
    required int xpEarned,
  }) : super(
          id: id,
          startTime: startTime,
          endTime: endTime,
          mode: mode,
          difficulty: difficulty,
          operators: operators,
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
          wrongAnswers: wrongAnswers,
          cph: cph,
          accuracy: accuracy,
          bestStreak: bestStreak,
          xpEarned: xpEarned,
        );

  static const _dateFormat = 'yyyy-MM-ddTHH:mm:ss';

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(String s) => DateFormat(_dateFormat).parseUTC(s);

    return SessionModel(
      id: json['id'] as String,
      startTime: parseDate(json['startTime'] as String),
      endTime: parseDate(json['endTime'] as String),
      mode: json['mode'] as String,
      difficulty: json['difficulty'] as String,
      operators: (json['operators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      wrongAnswers: json['wrongAnswers'] as int,
      cph: json['cph'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      bestStreak: json['bestStreak'] as int,
      xpEarned: json['xpEarned'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    String formatDate(DateTime dt) =>
        DateFormat(_dateFormat).format(dt.toUtc());

    return {
      'id': id,
      'startTime': formatDate(startTime),
      'endTime': formatDate(endTime),
      'mode': mode,
      'difficulty': difficulty,
      'operators': operators,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'cph': cph,
      'accuracy': accuracy,
      'bestStreak': bestStreak,
      'xpEarned': xpEarned,
    };
  }

  factory SessionModel.fromEntity(Session entity) {
    return SessionModel(
      id: entity.id,
      startTime: entity.startTime,
      endTime: entity.endTime,
      mode: entity.mode,
      difficulty: entity.difficulty,
      operators: entity.operators,
      totalQuestions: entity.totalQuestions,
      correctAnswers: entity.correctAnswers,
      wrongAnswers: entity.wrongAnswers,
      cph: entity.cph,
      accuracy: entity.accuracy,
      bestStreak: entity.bestStreak,
      xpEarned: entity.xpEarned,
    );
  }
}
