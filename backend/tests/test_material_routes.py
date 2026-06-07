from datetime import UTC, datetime
from uuid import UUID

from fastapi.testclient import TestClient

from app.main import app
from app.routes.materials import get_material_service
from app.schemas.materials import MaterialAnalysisStatus, MaterialDetail, TextMaterialCreate

USER_ID = UUID("00000000-0000-0000-0000-000000000001")
MATERIAL_ID = UUID("00000000-0000-0000-0000-000000000002")


class FakeMaterialService:
    def list_materials(self, user_id: UUID) -> list[MaterialDetail]:
        assert user_id == USER_ID
        return [_material()]

    def get_material(self, user_id: UUID, material_id: UUID) -> MaterialDetail:
        assert user_id == USER_ID
        assert material_id == MATERIAL_ID
        return _material()

    async def create_text_material(
        self,
        user_id: UUID,
        payload: TextMaterialCreate,
    ) -> MaterialDetail:
        assert user_id == USER_ID
        assert payload.title == "Nota"
        return _material(title=payload.title, extracted_text=payload.content)

    def delete_material(self, user_id: UUID, material_id: UUID) -> None:
        assert user_id == USER_ID
        assert material_id == MATERIAL_ID


def _material(title: str = "Resumen", extracted_text: str = "Contenido") -> MaterialDetail:
    return MaterialDetail(
        id=MATERIAL_ID,
        user_id=USER_ID,
        title=title,
        file_type="text",
        file_url=None,
        extracted_text=extracted_text,
        analysis_status=MaterialAnalysisStatus.READY,
        created_at=datetime(2026, 6, 6, tzinfo=UTC),
    )


def _client() -> TestClient:
    app.dependency_overrides[get_material_service] = lambda: FakeMaterialService()
    return TestClient(app)


def teardown_function() -> None:
    app.dependency_overrides.clear()


def test_list_materials() -> None:
    response = _client().get("/materials", headers={"X-User-Id": str(USER_ID)})

    assert response.status_code == 200
    assert response.json()[0]["title"] == "Resumen"


def test_create_text_material() -> None:
    response = _client().post(
        "/materials/text",
        headers={"X-User-Id": str(USER_ID)},
        json={"title": "Nota", "content": "Texto pegado"},
    )

    assert response.status_code == 201
    assert response.json()["material"]["title"] == "Nota"
    assert response.json()["material"]["extracted_text"] == "Texto pegado"


def test_delete_material() -> None:
    response = _client().delete(f"/materials/{MATERIAL_ID}", headers={"X-User-Id": str(USER_ID)})

    assert response.status_code == 204
