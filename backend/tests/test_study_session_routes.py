from datetime import UTC, datetime
from uuid import UUID

from fastapi.testclient import TestClient

from app.main import app
from app.routes.study_sessions import get_study_session_service
from app.schemas.study_sessions import (
    SessionStatus,
    StudyMethod,
    StudyMode,
    StudySessionCreate,
    StudySessionDetail,
    UnlockStatus,
)

USER_ID = UUID("00000000-0000-0000-0000-000000000001")
SESSION_ID = UUID("00000000-0000-0000-0000-000000000010")
MATERIAL_ID = UUID("00000000-0000-0000-0000-000000000020")


class FakeStudySessionService:
    def list_sessions(self, user_id: UUID) -> list[StudySessionDetail]:
        assert user_id == USER_ID
        return [_session()]

    def get_session(self, user_id: UUID, session_id: UUID) -> StudySessionDetail:
        assert user_id == USER_ID
        assert session_id == SESSION_ID
        return _session()

    def create_session(self, user_id: UUID, payload: StudySessionCreate) -> StudySessionDetail:
        assert user_id == USER_ID
        assert payload.topic == "POO"
        assert payload.study_method == StudyMethod.VISUAL
        assert payload.material_ids == [MATERIAL_ID]
        return _session(topic=payload.topic, material_ids=payload.material_ids)

    def start_session(self, user_id: UUID, session_id: UUID) -> StudySessionDetail:
        assert user_id == USER_ID
        assert session_id == SESSION_ID
        return _session(status=SessionStatus.ACTIVE)

    def complete_session(self, user_id: UUID, session_id: UUID) -> StudySessionDetail:
        assert user_id == USER_ID
        assert session_id == SESSION_ID
        return _session(status=SessionStatus.COMPLETED, unlock_status=UnlockStatus.PENDING_QUIZ)

    def cancel_session(self, user_id: UUID, session_id: UUID) -> StudySessionDetail:
        assert user_id == USER_ID
        assert session_id == SESSION_ID
        return _session(status=SessionStatus.CANCELLED)


def _session(
    topic: str = "Resumen POO",
    status: SessionStatus = SessionStatus.DRAFT,
    unlock_status: UnlockStatus = UnlockStatus.LOCKED,
    material_ids: list[UUID] | None = None,
) -> StudySessionDetail:
    return StudySessionDetail(
        id=SESSION_ID,
        user_id=USER_ID,
        topic=topic,
        duration_minutes=45,
        mode=StudyMode.NORMAL,
        study_method=StudyMethod.VISUAL,
        started_at=None,
        ended_at=None,
        status=status,
        score=None,
        unlock_status=unlock_status,
        created_at=datetime(2026, 6, 6, tzinfo=UTC),
        material_ids=material_ids or [MATERIAL_ID],
    )


def _client() -> TestClient:
    app.dependency_overrides[get_study_session_service] = lambda: FakeStudySessionService()
    return TestClient(app)


def teardown_function() -> None:
    app.dependency_overrides.clear()


def test_create_study_session() -> None:
    response = _client().post(
        "/study-sessions",
        headers={"X-User-Id": str(USER_ID)},
        json={
            "topic": "POO",
            "duration_minutes": 45,
            "mode": "normal",
            "study_method": "visual",
            "material_ids": [str(MATERIAL_ID)],
        },
    )

    assert response.status_code == 201
    assert response.json()["session"]["topic"] == "POO"
    assert response.json()["session"]["material_ids"] == [str(MATERIAL_ID)]


def test_list_study_sessions() -> None:
    response = _client().get("/study-sessions", headers={"X-User-Id": str(USER_ID)})

    assert response.status_code == 200
    assert response.json()[0]["study_method"] == "visual"


def test_start_study_session() -> None:
    response = _client().post(
        f"/study-sessions/{SESSION_ID}/start",
        headers={"X-User-Id": str(USER_ID)},
    )

    assert response.status_code == 200
    assert response.json()["session"]["status"] == "active"


def test_complete_study_session_sets_pending_quiz() -> None:
    response = _client().post(
        f"/study-sessions/{SESSION_ID}/complete",
        headers={"X-User-Id": str(USER_ID)},
    )

    assert response.status_code == 200
    assert response.json()["session"]["status"] == "completed"
    assert response.json()["session"]["unlock_status"] == "pending_quiz"
