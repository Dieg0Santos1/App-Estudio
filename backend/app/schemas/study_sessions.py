from datetime import datetime
from enum import StrEnum
from uuid import UUID

from pydantic import BaseModel, Field


class StudyMode(StrEnum):
    LIGHT = "light"
    NORMAL = "normal"
    STRICT = "strict"


class StudyMethod(StrEnum):
    VISUAL = "visual"
    AUDIO = "audio"
    WRITING = "writing"
    MIXED = "mixed"


class SessionStatus(StrEnum):
    DRAFT = "draft"
    ACTIVE = "active"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class UnlockStatus(StrEnum):
    LOCKED = "locked"
    PENDING_QUIZ = "pending_quiz"
    UNLOCKED = "unlocked"
    FAILED = "failed"


class StudySessionCreate(BaseModel):
    topic: str = Field(min_length=1, max_length=160)
    duration_minutes: int = Field(gt=0, le=240)
    mode: StudyMode = StudyMode.NORMAL
    study_method: StudyMethod = StudyMethod.VISUAL
    material_ids: list[UUID] = Field(min_length=1, max_length=20)


class StudySessionSummary(BaseModel):
    id: UUID
    user_id: UUID
    topic: str
    duration_minutes: int
    mode: StudyMode
    study_method: StudyMethod
    started_at: datetime | None = None
    ended_at: datetime | None = None
    status: SessionStatus
    score: float | None = None
    unlock_status: UnlockStatus
    created_at: datetime
    material_ids: list[UUID] = Field(default_factory=list)


class StudySessionDetail(StudySessionSummary):
    pass


class StudySessionResult(BaseModel):
    session: StudySessionDetail
