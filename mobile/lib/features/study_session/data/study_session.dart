import '../../../core/models/study_enums.dart';
import '../../../core/network/json_helpers.dart';

class StudySession {
  const StudySession({
    required this.id,
    required this.userId,
    required this.topic,
    required this.durationMinutes,
    required this.mode,
    required this.studyMethod,
    required this.status,
    required this.unlockStatus,
    required this.createdAt,
    required this.materialIds,
    this.startedAt,
    this.endedAt,
    this.score,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      topic: json['topic'] as String,
      durationMinutes: json['duration_minutes'] as int,
      mode: StudyMode.fromJson(json['mode'] as String),
      studyMethod: StudyMethod.fromJson(json['study_method'] as String),
      startedAt: parseOptionalDateTime(json['started_at']),
      endedAt: parseOptionalDateTime(json['ended_at']),
      status: SessionStatus.fromJson(json['status'] as String),
      score: (json['score'] as num?)?.toDouble(),
      unlockStatus: UnlockStatus.fromJson(json['unlock_status'] as String),
      createdAt: parseDateTime(json['created_at']),
      materialIds: parseStringList(json['material_ids']),
    );
  }

  final String id;
  final String userId;
  final String topic;
  final int durationMinutes;
  final StudyMode mode;
  final StudyMethod studyMethod;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final SessionStatus status;
  final double? score;
  final UnlockStatus unlockStatus;
  final DateTime createdAt;
  final List<String> materialIds;
}
