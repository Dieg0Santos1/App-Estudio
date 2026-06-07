from pathlib import Path
from uuid import UUID

from app.core.config import settings
from app.core.supabase import get_supabase_client


class MaterialService:
    def __init__(self) -> None:
        self._supabase = get_supabase_client()
        self._bucket = settings.supabase_storage_bucket

    def get_upload_path(self, user_id: UUID, filename: str) -> str:
        safe_name = Path(filename).name
        return f"{user_id}/materials/{safe_name}"

    def list_materials(self, user_id: UUID) -> list[dict]:
        response = (
            self._supabase.table("study_materials")
            .select("*")
            .eq("user_id", str(user_id))
            .order("created_at", desc=True)
            .execute()
        )
        return list(response.data or [])

    def bucket_name(self) -> str:
        return self._bucket
