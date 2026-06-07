from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from fastapi.responses import Response

from app.core.auth import get_current_user_id
from app.documents.extractor import UnsupportedDocumentError
from app.schemas.materials import MaterialDetail, MaterialUploadResult, TextMaterialCreate
from app.services.material_service import EmptyMaterialError, MaterialNotFoundError, MaterialService

router = APIRouter()


def get_material_service() -> MaterialService:
    return MaterialService()


@router.get("", response_model=list[MaterialDetail])
async def list_materials(
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[MaterialService, Depends(get_material_service)],
) -> list[MaterialDetail]:
    return service.list_materials(user_id)


@router.get("/{material_id}", response_model=MaterialDetail)
async def get_material(
    material_id: UUID,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[MaterialService, Depends(get_material_service)],
) -> MaterialDetail:
    try:
        return service.get_material(user_id, material_id)
    except MaterialNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Material not found.",
        ) from exc


@router.post("/text", response_model=MaterialUploadResult, status_code=status.HTTP_201_CREATED)
async def create_text_material(
    payload: TextMaterialCreate,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[MaterialService, Depends(get_material_service)],
) -> MaterialUploadResult:
    material = await service.create_text_material(user_id, payload)
    return MaterialUploadResult(material=material)


@router.post("/upload", response_model=MaterialUploadResult, status_code=status.HTTP_201_CREATED)
async def upload_material(
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[MaterialService, Depends(get_material_service)],
    file: Annotated[UploadFile, File()],
    title: Annotated[str | None, Form()] = None,
) -> MaterialUploadResult:
    try:
        material = await service.upload_material(user_id, file, title)
    except EmptyMaterialError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc
    except UnsupportedDocumentError as exc:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail=str(exc),
        ) from exc

    return MaterialUploadResult(material=material)


@router.delete("/{material_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_material(
    material_id: UUID,
    user_id: Annotated[UUID, Depends(get_current_user_id)],
    service: Annotated[MaterialService, Depends(get_material_service)],
) -> Response:
    try:
        service.delete_material(user_id, material_id)
    except MaterialNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Material not found.",
        ) from exc

    return Response(status_code=status.HTTP_204_NO_CONTENT)
