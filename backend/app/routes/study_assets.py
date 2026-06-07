from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status

from app.ai.base import AIProvider
from app.ai.provider_factory import get_ai_provider
from app.core.auth import get_current_user_id
from app.schemas.study_assets import StudyAssetGenerateRequest, StudyAssetResult
from app.services.study_asset_service import (
    StudyAssetService,
    StudyAssetSessionNotFoundError,
    StudyAssetUnavailableError,
)

router = APIRouter()


def get_study_asset_service(
    provider: Annotated[AIProvider, Depends(get_ai_provider)],
) -> StudyAssetService:
    return StudyAssetService(provider)


@router.get("/{session_id}/assets", response_model=StudyAssetResult)
async def list_assets(
    session_id: UUID,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[StudyAssetService, Depends(get_study_asset_service)],
) -> StudyAssetResult:
    try:
        return service.list_assets(user_id, session_id)
    except StudyAssetSessionNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc)) from exc
    except StudyAssetUnavailableError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc)) from exc


@router.post(
    "/{session_id}/assets",
    response_model=StudyAssetResult,
    status_code=status.HTTP_201_CREATED,
)
async def generate_assets(
    session_id: UUID,
    payload: StudyAssetGenerateRequest,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[StudyAssetService, Depends(get_study_asset_service)],
) -> StudyAssetResult:
    try:
        return await service.generate_assets(user_id, session_id, payload)
    except StudyAssetSessionNotFoundError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc)) from exc
    except StudyAssetUnavailableError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc)) from exc
