import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/study_enums.dart';
import '../../../core/network/api_client_provider.dart';
import '../../../core/network/api_exception.dart';
import 'unlock_quiz.dart';

final unlockQuizRepositoryProvider = Provider<UnlockQuizRepository>((ref) {
  return UnlockQuizRepository(ref.watch(apiClientProvider));
});

final unlockQuizProvider =
    FutureProvider.autoDispose.family<UnlockQuiz, String>((ref, sessionId) {
  return ref.watch(unlockQuizRepositoryProvider).getQuiz(sessionId);
});

class UnlockQuizRepository {
  const UnlockQuizRepository(this._client);

  final Dio _client;

  Future<UnlockQuiz> generateQuiz({
    required String sessionId,
    int questionCount = 5,
    QuestionDifficulty difficulty = QuestionDifficulty.medium,
    QuestionType questionType = QuestionType.mixed,
  }) async {
    return _guard(() async {
      final response = await _client.post<Map<String, dynamic>>(
        '/study-sessions/$sessionId/quiz',
        data: {
          'question_count': questionCount,
          'difficulty': difficulty.value,
          'question_type': questionType.value,
        },
      );
      return UnlockQuiz.fromJson(response.data ?? const {});
    });
  }

  Future<UnlockQuiz> getQuiz(String sessionId) async {
    return _guard(() async {
      final response = await _client.get<Map<String, dynamic>>(
        '/study-sessions/$sessionId/quiz',
      );
      return UnlockQuiz.fromJson(response.data ?? const {});
    });
  }

  Future<UnlockQuizAnswerResult> submitAnswer({
    required String sessionId,
    required String questionId,
    required String answerText,
  }) async {
    return _guard(() async {
      final response = await _client.post<Map<String, dynamic>>(
        '/study-sessions/$sessionId/quiz/answers',
        data: {
          'question_id': questionId,
          'answer_text': answerText,
        },
      );
      return UnlockQuizAnswerResult.fromJson(response.data ?? const {});
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
