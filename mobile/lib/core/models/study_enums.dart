enum MaterialAnalysisStatus {
  pending('pending'),
  processing('processing'),
  ready('ready'),
  failed('failed');

  const MaterialAnalysisStatus(this.value);

  final String value;

  static MaterialAnalysisStatus fromJson(String value) {
    return MaterialAnalysisStatus.values.firstWhere((status) => status.value == value);
  }
}

enum StudyMode {
  light('light'),
  normal('normal'),
  strict('strict');

  const StudyMode(this.value);

  final String value;

  static StudyMode fromJson(String value) {
    return StudyMode.values.firstWhere((mode) => mode.value == value);
  }
}

enum StudyMethod {
  visual('visual'),
  audio('audio'),
  writing('writing'),
  mixed('mixed');

  const StudyMethod(this.value);

  final String value;

  static StudyMethod fromJson(String value) {
    return StudyMethod.values.firstWhere((method) => method.value == value);
  }
}

enum SessionStatus {
  draft('draft'),
  active('active'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const SessionStatus(this.value);

  final String value;

  static SessionStatus fromJson(String value) {
    return SessionStatus.values.firstWhere((status) => status.value == value);
  }
}

enum UnlockStatus {
  locked('locked'),
  pendingQuiz('pending_quiz'),
  unlocked('unlocked'),
  failed('failed');

  const UnlockStatus(this.value);

  final String value;

  static UnlockStatus fromJson(String value) {
    return UnlockStatus.values.firstWhere((status) => status.value == value);
  }
}

enum StudyAssetType {
  summary('summary'),
  flashcards('flashcards'),
  comparisonTable('comparison_table'),
  mindMap('mind_map'),
  audioScript('audio_script'),
  writingPrompt('writing_prompt'),
  mixedPath('mixed_path');

  const StudyAssetType(this.value);

  final String value;

  static StudyAssetType fromJson(String value) {
    return StudyAssetType.values.firstWhere((type) => type.value == value);
  }
}

enum QuestionType {
  multipleChoice('multiple_choice'),
  trueFalse('true_false'),
  shortAnswer('short_answer'),
  argumentative('argumentative'),
  mixed('mixed');

  const QuestionType(this.value);

  final String value;

  static QuestionType fromJson(String value) {
    return QuestionType.values.firstWhere((type) => type.value == value);
  }
}

enum QuestionDifficulty {
  easy('easy'),
  medium('medium'),
  hard('hard');

  const QuestionDifficulty(this.value);

  final String value;

  static QuestionDifficulty fromJson(String value) {
    return QuestionDifficulty.values.firstWhere((difficulty) => difficulty.value == value);
  }
}
