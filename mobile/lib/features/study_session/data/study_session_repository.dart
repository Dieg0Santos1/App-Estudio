import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/study_enums.dart';
import '../../../core/network/api_client_provider.dart';
import '../../../core/network/api_exception.dart';
import 'study_session.dart';

final studySessionRepositoryProvider = Provider<StudySessionRepository>((ref) {
  return StudySessionRepository(ref.watch(apiClientProvider));
});

final studySessionsProvider = FutureProvider.autoDispose<List<StudySession>>((ref) {
  return ref.watch(studySessionRepositoryProvider).listSessions();
});

class StudySessionRepository {
  const StudySessionRepository(this._client);

  final Dio _client;

  Future<List<StudySession>> listSessions() async {
    return _guard(() async {
      final response = await _client.get<List<dynamic>>('/study-sessions');
      return (response.data ?? const [])
          .cast<Map<String, dynamic>>()
          .map(StudySession.fromJson)
          .toList(growable: false);
    });
  }

  Future<StudySession> getSession(String sessionId) async {
    return _guard(() async {
      final response = await _client.get<Map<String, dynamic>>('/study-sessions/$sessionId');
      return StudySession.fromJson(response.data ?? const {});
    });
  }

  Future<StudySession> createSession({
    required String topic,
    required int durationMinutes,
    required StudyMode mode,
    required StudyMethod studyMethod,
    required List<String> materialIds,
  }) async {
    return _guard(() async {
      final response = await _client.post<Map<String, dynamic>>(
        '/study-sessions',
        data: {
          'topic': topic,
          'duration_minutes': durationMinutes,
          'mode': mode.value,
          'study_method': studyMethod.value,
          'material_ids': materialIds,
        },
      );
      return StudySession.fromJson(response.data?['session'] as Map<String, dynamic>);
    });
  }

  Future<StudySession> startSession(String sessionId) {
    return _updateLifecycle('/study-sessions/$sessionId/start');
  }

  Future<StudySession> completeSession(String sessionId) {
    return _updateLifecycle('/study-sessions/$sessionId/complete');
  }

  Future<StudySession> cancelSession(String sessionId) {
    return _updateLifecycle('/study-sessions/$sessionId/cancel');
  }

  Future<StudySession> _updateLifecycle(String path) async {
    return _guard(() async {
      final response = await _client.post<Map<String, dynamic>>(path);
      return StudySession.fromJson(response.data?['session'] as Map<String, dynamic>);
    });
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
