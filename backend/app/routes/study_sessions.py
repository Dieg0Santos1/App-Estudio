from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status

from app.core.auth import get_current_user_id
from app.schemas.study_sessions import StudySessionCreate, StudySessionDetail, StudySessionResult
from app.services.study_session_service import (
    InvalidSessionTransitionError,
    MaterialSelectionError,
    StudySessionNotFoundError,
    StudySessionService,
)

router = APIRouter()


def get_study_session_service() -> StudySessionService:
    return StudySessionService()


@router.get("", response_model=list[StudySessionDetail])
async def list_sessions(
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[StudySessionService, Depends(get_study_session_service)],
) -> list[StudySessionDetail]:
    return service.list_sessions(user_id)


@router.post("", response_model=StudySessionResult, status_code=status.HTTP_201_CREATED)
async def create_session(
    payload: StudySessionCreate,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[StudySessionService, Depends(get_study_session_service)],
) -> StudySessionResult:
    try:
        session = service.create_session(user_id, payload)
    except MaterialSelectionError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc
    return StudySessionResult(session=session)


@router.get("/{session_id}", response_model=StudySessionDetail)
async def get_session(
    session_id: UUID,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[StudySessionService, Depends(get_study_session_service)],
) -> StudySessionDetail:
    try:
        return service.get_session(user_id, session_id)
    except StudySessionNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Study session not found.",
        ) from exc


@router.post("/{session_id}/start", response_model=StudySessionResult)
async def start_session(
    session_id: UUID,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[StudySessionService, Depends(get_study_session_service)],
) -> StudySessionResult:
    try:
        session = service.start_session(user_id, session_id)
    except StudySessionNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Study session not found.",
        ) from exc
    except InvalidSessionTransitionError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc)) from exc
    return StudySessionResult(session=session)


@router.post("/{session_id}/complete", response_model=StudySessionResult)
async def complete_session(
    session_id: UUID,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[StudySessionService, Depends(get_study_session_service)],
) -> StudySessionResult:
    try:
        session = service.complete_session(user_id, session_id)
    except StudySessionNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Study session not found.",
        ) from exc
    except InvalidSessionTransitionError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc)) from exc
    return StudySessionResult(session=session)


@router.post("/{session_id}/cancel", response_model=StudySessionResult)
async def cancel_session(
    session_id: UUID,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[StudySessionService, Depends(get_study_session_service)],
) -> StudySessionResult:
    try:
        session = service.cancel_session(user_id, session_id)
    except StudySessionNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Study session not found.",
        ) from exc
    except InvalidSessionTransitionError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc)) from exc
    return StudySessionResult(session=session)
