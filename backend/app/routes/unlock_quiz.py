from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status

from app.ai.base import AIProvider
from app.ai.provider_factory import get_ai_provider
from app.core.auth import get_current_user_id
from app.schemas.unlock_quiz import (
    UnlockQuiz,
    UnlockQuizAnswerCreate,
    UnlockQuizAnswerResult,
    UnlockQuizGenerateRequest,
)
from app.services.unlock_quiz_service import (
    UnlockQuizNotFoundError,
    UnlockQuizQuestionNotFoundError,
    UnlockQuizService,
    UnlockQuizUnavailableError,
)

router = APIRouter()


def get_unlock_quiz_service(
    provider: Annotated[AIProvider, Depends(get_ai_provider)],
) -> UnlockQuizService:
    return UnlockQuizService(provider)


@router.post("/{session_id}/quiz", response_model=UnlockQuiz, status_code=status.HTTP_201_CREATED)
async def generate_quiz(
    session_id: UUID,
    payload: UnlockQuizGenerateRequest,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[UnlockQuizService, Depends(get_unlock_quiz_service)],
) -> UnlockQuiz:
    try:
        return await service.generate_quiz(user_id, session_id, payload)
    except UnlockQuizUnavailableError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc)) from exc
    except UnlockQuizNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc)) from exc


@router.get("/{session_id}/quiz", response_model=UnlockQuiz)
async def get_quiz(
    session_id: UUID,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[UnlockQuizService, Depends(get_unlock_quiz_service)],
) -> UnlockQuiz:
    try:
        return service.get_quiz(user_id, session_id)
    except UnlockQuizUnavailableError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc)) from exc
    except UnlockQuizNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc)) from exc


@router.post("/{session_id}/quiz/answers", response_model=UnlockQuizAnswerResult)
async def submit_answer(
    session_id: UUID,
    payload: UnlockQuizAnswerCreate,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[UnlockQuizService, Depends(get_unlock_quiz_service)],
) -> UnlockQuizAnswerResult:
    try:
        return await service.submit_answer(user_id, session_id, payload)
    except UnlockQuizUnavailableError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc)) from exc
    except (UnlockQuizNotFoundError, UnlockQuizQuestionNotFoundError) as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc)) from exc
