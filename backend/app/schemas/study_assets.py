from datetime import datetime
from enum import StrEnum
from typing import Any
from uuid import UUID

from pydantic import BaseModel, Field


class StudyAssetType(StrEnum):
    SUMMARY = "summary"
    FLASHCARDS = "flashcards"
    COMPARISON_TABLE = "comparison_table"
    MIND_MAP = "mind_map"
    AUDIO_SCRIPT = "audio_script"
    WRITING_PROMPT = "writing_prompt"
    MIXED_PATH = "mixed_path"


class StudyAssetDraft(BaseModel):
    asset_type: StudyAssetType
    title: str = Field(min_length=1, max_length=160)
    content: dict[str, Any]
    order_index: int = Field(ge=0)


class StudyAssetGenerateRequest(BaseModel):
    force_regenerate: bool = False


class StudyAssetGenerationRequest(BaseModel):
    topic: str
    study_method: str
    duration_minutes: int
    material_text: str


class StudyAssetGenerationResult(BaseModel):
    assets: list[StudyAssetDraft] = Field(min_length=1, max_length=8)


class StudyAsset(BaseModel):
    id: UUID
    session_id: UUID
    material_id: UUID | None = None
    asset_type: StudyAssetType
    title: str
    content: dict[str, Any]
    order_index: int
    created_at: datetime


class StudyAssetResult(BaseModel):
    session_id: UUID
    assets: list[StudyAsset]
