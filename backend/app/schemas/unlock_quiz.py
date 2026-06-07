from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

from app.schemas.ai import AnswerEvaluationResult, Difficulty, QuestionOption, QuestionType
from app.schemas.study_sessions import UnlockStatus


class UnlockQuizGenerateRequest(BaseModel):
    question_count: int = Field(default=5, ge=1, le=10)
    difficulty: Difficulty = Difficulty.MEDIUM
    question_type: QuestionType = QuestionType.MIXED


class UnlockQuizQuestion(BaseModel):
    id: UUID
    session_id: UUID
    question_text: str
    question_type: QuestionType
    options: list[QuestionOption] = Field(default_factory=list)
    difficulty: Difficulty
    related_concepts: list[str] = Field(default_factory=list)
    source_hint: str | None = None
    created_at: datetime
    answered: bool = False


class UnlockQuizProgress(BaseModel):
    total_questions: int
    answered_questions: int
    average_score: float | None = Field(default=None, ge=0, le=1)
    passing_score: float = Field(ge=0, le=1)
    unlock_status: UnlockStatus
    passed: bool = False


class UnlockQuiz(BaseModel):
    session_id: UUID
    questions: list[UnlockQuizQuestion]
    progress: UnlockQuizProgress


class UnlockQuizAnswerCreate(BaseModel):
    question_id: UUID
    answer_text: str = Field(min_length=1, max_length=3000)


class UnlockQuizAnswerResult(BaseModel):
    question_id: UUID
    answer_text: str
    evaluation: AnswerEvaluationResult
    progress: UnlockQuizProgress
