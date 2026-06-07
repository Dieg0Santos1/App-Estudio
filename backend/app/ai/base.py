from typing import Protocol

from app.schemas.ai import (
    AnswerEvaluationRequest,
    AnswerEvaluationResult,
    QuestionGenerationRequest,
    QuestionGenerationResult,
)
from app.schemas.study_assets import StudyAssetGenerationRequest, StudyAssetGenerationResult


class AIProvider(Protocol):
    async def generate_questions(
        self,
        request: QuestionGenerationRequest,
    ) -> QuestionGenerationResult:
        """Generate study questions from extracted material."""

    async def evaluate_answer(
        self,
        request: AnswerEvaluationRequest,
    ) -> AnswerEvaluationResult:
        """Evaluate the meaning and quality of a student's answer."""

    async def generate_study_assets(
        self,
        request: StudyAssetGenerationRequest,
    ) -> StudyAssetGenerationResult:
        """Generate active study content for a focus session."""
