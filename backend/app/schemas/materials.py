from datetime import datetime
from enum import StrEnum
from uuid import UUID

from pydantic import BaseModel, Field


class MaterialAnalysisStatus(StrEnum):
    PENDING = "pending"
    PROCESSING = "processing"
    READY = "ready"
    FAILED = "failed"


class MaterialBase(BaseModel):
    title: str
    file_type: str


class TextMaterialCreate(BaseModel):
    title: str = Field(min_length=1, max_length=160)
    content: str = Field(min_length=1)


class MaterialSummary(MaterialBase):
    id: UUID
    user_id: UUID
    file_url: str | None = None
    analysis_status: MaterialAnalysisStatus
    created_at: datetime


class MaterialDetail(MaterialSummary):
    extracted_text: str | None = None


class MaterialUploadResult(BaseModel):
    material: MaterialDetail
