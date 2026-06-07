import 'package:flutter_test/flutter_test.dart';
import 'package:focusstudy_ai/core/models/study_enums.dart';
import 'package:focusstudy_ai/features/focus_mode/data/study_asset.dart';
import 'package:focusstudy_ai/features/library/data/study_material.dart';
import 'package:focusstudy_ai/features/study_session/data/study_session.dart';
import 'package:focusstudy_ai/features/unlock_quiz/data/unlock_quiz.dart';

void main() {
  test('parses study material contract', () {
    final material = StudyMaterial.fromJson({
      'id': 'material-id',
      'user_id': 'user-id',
      'title': 'Resumen POO',
      'file_type': 'pdf',
      'file_url': null,
      'extracted_text': 'Contenido',
      'analysis_status': 'ready',
      'created_at': '2026-06-06T22:20:00Z',
    });

    expect(material.analysisStatus, MaterialAnalysisStatus.ready);
    expect(material.title, 'Resumen POO');
  });

  test('parses study session with selected study method', () {
    final session = StudySession.fromJson({
      'id': 'session-id',
      'user_id': 'user-id',
      'topic': 'POO',
      'duration_minutes': 45,
      'mode': 'normal',
      'study_method': 'writing',
      'started_at': null,
      'ended_at': null,
      'status': 'draft',
      'score': null,
      'unlock_status': 'locked',
      'created_at': '2026-06-06T22:20:00Z',
      'material_ids': ['material-id'],
    });

    expect(session.studyMethod, StudyMethod.writing);
    expect(session.materialIds, ['material-id']);
  });

  test('parses active study assets for focus mode', () {
    final asset = StudyAsset.fromJson({
      'id': 'asset-id',
      'session_id': 'session-id',
      'material_id': null,
      'asset_type': 'audio_script',
      'title': 'Guion narrado',
      'content': {
        'script': [
          {'text': 'Escucha esta explicacion breve.'},
        ],
      },
      'order_index': 0,
      'created_at': '2026-06-06T22:20:00Z',
    });

    expect(asset.assetType, StudyAssetType.audioScript);
    expect(asset.content['script'], isA<List<dynamic>>());
  });

  test('parses unlock quiz without exposing correct answer', () {
    final quiz = UnlockQuiz.fromJson({
      'session_id': 'session-id',
      'questions': [
        {
          'id': 'question-id',
          'session_id': 'session-id',
          'question_text': 'Que es el polimorfismo?',
          'question_type': 'multiple_choice',
          'options': [
            {'id': 'A', 'text': 'Mismo mensaje, respuestas distintas'},
          ],
          'difficulty': 'medium',
          'related_concepts': ['Polimorfismo'],
          'source_hint': 'Material 1',
          'created_at': '2026-06-06T22:20:00Z',
          'answered': false,
        },
      ],
      'progress': {
        'total_questions': 1,
        'answered_questions': 0,
        'average_score': null,
        'passing_score': 0.7,
        'unlock_status': 'pending_quiz',
        'passed': false,
      },
    });

    expect(quiz.questions.single.questionType, QuestionType.multipleChoice);
    expect(quiz.progress.unlockStatus, UnlockStatus.pendingQuiz);
  });
}
