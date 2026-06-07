import '../../../core/models/study_enums.dart';
import '../../../core/network/json_helpers.dart';

class QuestionOption {
  const QuestionOption({
    required this.id,
    required this.text,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }

  final String id;
  final String text;
}

class UnlockQuizQuestion {
  const UnlockQuizQuestion({
    required this.id,
    required this.sessionId,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.difficulty,
    required this.relatedConcepts,
    required this.createdAt,
    required this.answered,
    this.sourceHint,
  });

  factory UnlockQuizQuestion.fromJson(Map<String, dynamic> json) {
    final options = json['options'] as List<dynamic>? ?? const [];

    return UnlockQuizQuestion(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      questionText: json['question_text'] as String,
      questionType: QuestionType.fromJson(json['question_type'] as String),
      options: options
          .cast<Map<String, dynamic>>()
          .map(QuestionOption.fromJson)
          .toList(growable: false),
      difficulty: QuestionDifficulty.fromJson(json['difficulty'] as String),
      relatedConcepts: parseStringList(json['related_concepts']),
      sourceHint: json['source_hint'] as String?,
      createdAt: parseDateTime(json['created_at']),
      answered: json['answered'] as bool,
    );
  }

  final String id;
  final String sessionId;
  final String questionText;
  final QuestionType questionType;
  final List<QuestionOption> options;
  final QuestionDifficulty difficulty;
  final List<String> relatedConcepts;
  final String? sourceHint;
  final DateTime createdAt;
  final bool answered;
}

class UnlockQuizProgress {
  const UnlockQuizProgress({
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.passingScore,
    required this.unlockStatus,
    required this.passed,
    this.averageScore,
  });

  factory UnlockQuizProgress.fromJson(Map<String, dynamic> json) {
    return UnlockQuizProgress(
      totalQuestions: json['total_questions'] as int,
      answeredQuestions: json['answered_questions'] as int,
      averageScore: (json['average_score'] as num?)?.toDouble(),
      passingScore: (json['passing_score'] as num).toDouble(),
      unlockStatus: UnlockStatus.fromJson(json['unlock_status'] as String),
      passed: json['passed'] as bool,
    );
  }

  final int totalQuestions;
  final int answeredQuestions;
  final double? averageScore;
  final double passingScore;
  final UnlockStatus unlockStatus;
  final bool passed;
}

class UnlockQuiz {
  const UnlockQuiz({
    required this.sessionId,
    required this.questions,
    required this.progress,
  });

  factory UnlockQuiz.fromJson(Map<String, dynamic> json) {
    final questions = json['questions'] as List<dynamic>? ?? const [];

    return UnlockQuiz(
      sessionId: json['session_id'] as String,
      questions: questions
          .cast<Map<String, dynamic>>()
          .map(UnlockQuizQuestion.fromJson)
          .toList(growable: false),
      progress: UnlockQuizProgress.fromJson(json['progress'] as Map<String, dynamic>),
    );
  }

  final String sessionId;
  final List<UnlockQuizQuestion> questions;
  final UnlockQuizProgress progress;
}

class AnswerEvaluation {
  const AnswerEvaluation({
    required this.isCorrect,
    required this.score,
    required this.feedback,
    required this.missingConcepts,
    required this.reinforcedConcepts,
  });

  factory AnswerEvaluation.fromJson(Map<String, dynamic> json) {
    return AnswerEvaluation(
      isCorrect: json['is_correct'] as bool,
      score: (json['score'] as num).toDouble(),
      feedback: json['feedback'] as String,
      missingConcepts: parseStringList(json['missing_concepts']),
      reinforcedConcepts: parseStringList(json['reinforced_concepts']),
    );
  }

  final bool isCorrect;
  final double score;
  final String feedback;
  final List<String> missingConcepts;
  final List<String> reinforcedConcepts;
}

class UnlockQuizAnswerResult {
  const UnlockQuizAnswerResult({
    required this.questionId,
    required this.answerText,
    required this.evaluation,
    required this.progress,
  });

  factory UnlockQuizAnswerResult.fromJson(Map<String, dynamic> json) {
    return UnlockQuizAnswerResult(
      questionId: json['question_id'] as String,
      answerText: json['answer_text'] as String,
      evaluation: AnswerEvaluation.fromJson(json['evaluation'] as Map<String, dynamic>),
      progress: UnlockQuizProgress.fromJson(json['progress'] as Map<String, dynamic>),
    );
  }

  final String questionId;
  final String answerText;
  final AnswerEvaluation evaluation;
  final UnlockQuizProgress progress;
}
