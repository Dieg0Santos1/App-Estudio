from typing import Annotated

from fastapi import APIRouter, Depends

from app.ai.base import AIProvider
from app.ai.provider_factory import get_ai_provider
from app.schemas.ai import (
    AnswerEvaluationRequest,
    AnswerEvaluationResult,
    QuestionGenerationRequest,
    QuestionGenerationResult,
)

router = APIRouter()


@router.post("/questions", response_model=QuestionGenerationResult)
async def generate_questions(
    request: QuestionGenerationRequest,
    provider: Annotated[AIProvider, Depends(get_ai_provider)],
) -> QuestionGenerationResult:
    return await provider.generate_questions(request)


@router.post("/answers/evaluate", response_model=AnswerEvaluationResult)
async def evaluate_answer(
    request: AnswerEvaluationRequest,
    provider: Annotated[AIProvider, Depends(get_ai_provider)],
) -> AnswerEvaluationResult:
    return await provider.evaluate_answer(request)
