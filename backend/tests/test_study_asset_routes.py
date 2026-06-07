from datetime import UTC, datetime
from uuid import UUID

from fastapi.testclient import TestClient

from app.main import app
from app.routes.study_assets import get_study_asset_service
from app.schemas.study_assets import (
    StudyAsset,
    StudyAssetGenerateRequest,
    StudyAssetResult,
    StudyAssetType,
)

USER_ID = UUID("00000000-0000-0000-0000-000000000001")
SESSION_ID = UUID("00000000-0000-0000-0000-000000000010")
ASSET_ID = UUID("00000000-0000-0000-0000-000000000040")


class FakeStudyAssetService:
    def list_assets(self, user_id: UUID, session_id: UUID) -> StudyAssetResult:
        assert user_id == USER_ID
        assert session_id == SESSION_ID
        return _result()

    async def generate_assets(
        self,
        user_id: UUID,
        session_id: UUID,
        payload: StudyAssetGenerateRequest,
    ) -> StudyAssetResult:
        assert user_id == USER_ID
        assert session_id == SESSION_ID
        assert payload.force_regenerate is True
        return _result()


def _asset() -> StudyAsset:
    return StudyAsset(
        id=ASSET_ID,
        session_id=SESSION_ID,
        material_id=None,
        asset_type=StudyAssetType.SUMMARY,
        title="Resumen guiado",
        content={
            "sections": [
                {
                    "heading": "Idea central",
                    "bullets": ["El polimorfismo permite respuestas distintas."],
                }
            ]
        },
        order_index=0,
        created_at=datetime(2026, 6, 6, tzinfo=UTC),
    )


def _result() -> StudyAssetResult:
    return StudyAssetResult(session_id=SESSION_ID, assets=[_asset()])


def _client() -> TestClient:
    app.dependency_overrides[get_study_asset_service] = lambda: FakeStudyAssetService()
    return TestClient(app)


def teardown_function() -> None:
    app.dependency_overrides.clear()


def test_generate_study_assets() -> None:
    response = _client().post(
        f"/study-sessions/{SESSION_ID}/assets",
        headers={"X-User-Id": str(USER_ID)},
        json={"force_regenerate": True},
    )

    assert response.status_code == 201
    assert response.json()["assets"][0]["asset_type"] == "summary"
    assert response.json()["assets"][0]["content"]["sections"][0]["heading"] == "Idea central"


def test_list_study_assets() -> None:
    response = _client().get(
        f"/study-sessions/{SESSION_ID}/assets",
        headers={"X-User-Id": str(USER_ID)},
    )

    assert response.status_code == 200
    assert response.json()["session_id"] == str(SESSION_ID)
