from uuid import UUID

from app.ai.base import AIProvider
from app.core.supabase import get_supabase_client
from app.schemas.study_assets import (
    StudyAsset,
    StudyAssetGenerateRequest,
    StudyAssetGenerationRequest,
    StudyAssetResult,
)
from app.schemas.study_sessions import SessionStatus

MATERIAL_TEXT_LIMIT = 18_000


class StudyAssetSessionNotFoundError(LookupError):
    pass


class StudyAssetUnavailableError(ValueError):
    pass


class StudyAssetService:
    def __init__(self, ai_provider: AIProvider) -> None:
        self._supabase = get_supabase_client()
        self._ai_provider = ai_provider

    def list_assets(self, user_id: UUID, session_id: UUID) -> StudyAssetResult:
        self._get_owned_session(user_id, session_id)
        return StudyAssetResult(session_id=session_id, assets=self._list_assets(session_id))

    async def generate_assets(
        self,
        user_id: UUID,
        session_id: UUID,
        payload: StudyAssetGenerateRequest,
    ) -> StudyAssetResult:
        session = self._get_owned_session(user_id, session_id)
        self._ensure_can_generate(session)
        existing_assets = self._list_assets(session_id)
        if existing_assets and not payload.force_regenerate:
            return StudyAssetResult(session_id=session_id, assets=existing_assets)

        material_text = self._get_session_material_text(session_id)
        generated = await self._ai_provider.generate_study_assets(
            StudyAssetGenerationRequest(
                topic=session["topic"],
                study_method=session["study_method"],
                duration_minutes=session["duration_minutes"],
                material_text=material_text[:MATERIAL_TEXT_LIMIT],
            )
        )

        if payload.force_regenerate:
            self._supabase.table("study_assets").delete().eq(
                "session_id", str(session_id)
            ).execute()

        rows = [
            {
                "session_id": str(session_id),
                "material_id": None,
                "asset_type": asset.asset_type.value,
                "title": asset.title,
                "content": asset.content,
                "order_index": asset.order_index,
            }
            for asset in generated.assets
        ]
        response = self._supabase.table("study_assets").insert(rows).execute()
        assets = [StudyAsset.model_validate(row) for row in response.data or []]
        if not assets:
            raise RuntimeError("Supabase did not return generated study assets.")

        return StudyAssetResult(session_id=session_id, assets=assets)

    def _get_owned_session(self, user_id: UUID, session_id: UUID) -> dict:
        response = (
            self._supabase.table("study_sessions")
            .select("*")
            .eq("user_id", str(user_id))
            .eq("id", str(session_id))
            .limit(1)
            .execute()
        )
        rows = response.data or []
        if not rows:
            raise StudyAssetSessionNotFoundError("Study session not found.")

        return rows[0]

    def _ensure_can_generate(self, session: dict) -> None:
        if session.get("status") in {
            SessionStatus.COMPLETED.value,
            SessionStatus.CANCELLED.value,
            SessionStatus.FAILED.value,
        }:
            raise StudyAssetUnavailableError(
                "Study assets can only be generated before or during a session."
            )

    def _list_assets(self, session_id: UUID) -> list[StudyAsset]:
        response = (
            self._supabase.table("study_assets")
            .select("*")
            .eq("session_id", str(session_id))
            .order("order_index")
            .execute()
        )
        return [StudyAsset.model_validate(row) for row in response.data or []]

    def _get_session_material_text(self, session_id: UUID) -> str:
        material_response = (
            self._supabase.table("session_materials")
            .select("material_id")
            .eq("session_id", str(session_id))
            .execute()
        )
        material_ids = [row["material_id"] for row in material_response.data or []]
        if not material_ids:
            raise StudyAssetUnavailableError("Session has no study materials.")

        response = (
            self._supabase.table("study_materials")
            .select("title, extracted_text")
            .in_("id", material_ids)
            .execute()
        )
        chunks = [
            f"{row['title']}\n{row['extracted_text']}"
            for row in response.data or []
            if row.get("extracted_text")
        ]
        if not chunks:
            raise StudyAssetUnavailableError("Session materials do not have extracted text.")

        return "\n\n---\n\n".join(chunks)
