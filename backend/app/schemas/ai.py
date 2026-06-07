from enum import StrEnum

from pydantic import BaseModel, Field


class Difficulty(StrEnum):
    EASY = "easy"
    MEDIUM = "medium"
    HARD = "hard"


class QuestionType(StrEnum):
    MULTIPLE_CHOICE = "multiple_choice"
    TRUE_FALSE = "true_false"
    SHORT_ANSWER = "short_answer"
    ARGUMENTATIVE = "argumentative"
    MIXED = "mixed"


class StudyMethod(StrEnum):
    VISUAL = "visual"
    AUDIO = "audio"
    WRITING = "writing"
    MIXED = "mixed"


class QuestionOption(BaseModel):
    id: str = Field(description="Stable option identifier, for example A, B, C or D.")
    text: str


class GeneratedQuestion(BaseModel):
    question_text: str
    question_type: QuestionType
    options: list[QuestionOption] = Field(default_factory=list)
    correct_answer: str
    explanation: str
    related_concepts: list[str] = Field(default_factory=list)
    source_hint: str | None = None


class QuestionGenerationRequest(BaseModel):
    topic: str
    material_text: str
    study_method: StudyMethod = StudyMethod.VISUAL
    difficulty: Difficulty = Difficulty.MEDIUM
    question_type: QuestionType = QuestionType.MIXED
    question_count: int = Field(default=5, ge=1, le=10)


class QuestionGenerationResult(BaseModel):
    topic: str
    questions: list[GeneratedQuestion]


class AnswerEvaluationRequest(BaseModel):
    question_text: str
    expected_answer: str
    user_answer: str
    reference_text: str | None = None


class AnswerEvaluationResult(BaseModel):
    is_correct: bool
    score: float = Field(ge=0, le=1)
    feedback: str
    missing_concepts: list[str] = Field(default_factory=list)
    reinforced_concepts: list[str] = Field(default_factory=list)
