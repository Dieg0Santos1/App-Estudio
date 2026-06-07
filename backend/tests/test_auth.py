from uuid import UUID

from fastapi.testclient import TestClient

from app.core import auth
from app.main import app
from app.routes.materials import get_material_service

USER_ID = UUID("00000000-0000-0000-0000-000000000001")


class FakeMaterialService:
    def list_materials(self, user_id: UUID) -> list:
        assert user_id == USER_ID
        return []


def teardown_function() -> None:
    app.dependency_overrides.clear()


def test_auth_accepts_bearer_token(monkeypatch) -> None:
    monkeypatch.setattr(auth, "get_user_id_from_access_token", lambda token: USER_ID)
    app.dependency_overrides[get_material_service] = lambda: FakeMaterialService()

    response = TestClient(app).get("/materials", headers={"Authorization": "Bearer token"})

    assert response.status_code == 200


def test_auth_rejects_missing_credentials() -> None:
    response = TestClient(app).get("/materials")

    assert response.status_code == 401
    assert response.json()["detail"] == "Authorization bearer token is required."


def test_auth_keeps_x_user_id_fallback_for_local_development() -> None:
    app.dependency_overrides[get_material_service] = lambda: FakeMaterialService()

    response = TestClient(app).get("/materials", headers={"X-User-Id": str(USER_ID)})

    assert response.status_code == 200
