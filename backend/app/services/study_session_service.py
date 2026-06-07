from datetime import UTC, datetime
from uuid import UUID, uuid4

from app.core.supabase import get_supabase_client
from app.schemas.materials import MaterialAnalysisStatus
from app.schemas.study_sessions import (
    SessionStatus,
    StudySessionCreate,
    StudySessionDetail,
    UnlockStatus,
)


class StudySessionNotFoundError(LookupError):
    pass


class MaterialSelectionError(ValueError):
    pass


class InvalidSessionTransitionError(ValueError):
    pass


class StudySessionService:
    def __init__(self) -> None:
        self._supabase = get_supabase_client()

    def list_sessions(self, user_id: UUID) -> list[StudySessionDetail]:
        response = (
            self._supabase.table("study_sessions")
            .select("*")
            .eq("user_id", str(user_id))
            .order("created_at", desc=True)
            .execute()
        )
        rows = response.data or []
        material_map = self._get_material_ids_by_session([UUID(row["id"]) for row in rows])
        return [self._to_detail(row, material_map.get(UUID(row["id"]), [])) for row in rows]

    def get_session(self, user_id: UUID, session_id: UUID) -> StudySessionDetail:
        row = self._get_session_row(user_id, session_id)
        material_ids = self._get_material_ids(session_id)
        return self._to_detail(row, material_ids)

    def create_session(self, user_id: UUID, payload: StudySessionCreate) -> StudySessionDetail:
        material_ids = self._ensure_materials_ready(user_id, payload.material_ids)
        session_id = uuid4()
        row = {
            "id": str(session_id),
            "user_id": str(user_id),
            "topic": payload.topic,
            "duration_minutes": payload.duration_minutes,
            "mode": payload.mode.value,
            "study_method": payload.study_method.value,
            "status": SessionStatus.DRAFT.value,
            "unlock_status": UnlockStatus.LOCKED.value,
        }
        response = self._supabase.table("study_sessions").insert(row).execute()
        rows = response.data or []
        if not rows:
            raise RuntimeError("Supabase did not return the inserted study session.")

        relation_rows = [
            {
                "session_id": str(session_id),
                "material_id": str(material_id),
            }
            for material_id in material_ids
        ]
        self._supabase.table("session_materials").insert(relation_rows).execute()
        return self._to_detail(rows[0], material_ids)

    def start_session(self, user_id: UUID, session_id: UUID) -> StudySessionDetail:
        session = self.get_session(user_id, session_id)
        if session.status == SessionStatus.ACTIVE:
            return session
        if session.status != SessionStatus.DRAFT:
            raise InvalidSessionTransitionError("Only draft sessions can be started.")

        updated = self._update_session(
            user_id,
            session_id,
            {
                "status": SessionStatus.ACTIVE.value,
                "started_at": datetime.now(UTC).isoformat(),
                "unlock_status": UnlockStatus.LOCKED.value,
            },
        )
        return self._to_detail(updated, session.material_ids)

    def complete_session(self, user_id: UUID, session_id: UUID) -> StudySessionDetail:
        session = self.get_session(user_id, session_id)
        if session.status == SessionStatus.COMPLETED:
            return session
        if session.status != SessionStatus.ACTIVE:
            raise InvalidSessionTransitionError("Only active sessions can be completed.")

        updated = self._update_session(
            user_id,
            session_id,
            {
                "status": SessionStatus.COMPLETED.value,
                "ended_at": datetime.now(UTC).isoformat(),
                "unlock_status": UnlockStatus.PENDING_QUIZ.value,
            },
        )
        return self._to_detail(updated, session.material_ids)

    def cancel_session(self, user_id: UUID, session_id: UUID) -> StudySessionDetail:
        session = self.get_session(user_id, session_id)
        if session.status in {SessionStatus.COMPLETED, SessionStatus.CANCELLED}:
            raise InvalidSessionTransitionError(
                "Completed or cancelled sessions cannot be cancelled."
            )

        updated = self._update_session(
            user_id,
            session_id,
            {
                "status": SessionStatus.CANCELLED.value,
                "ended_at": datetime.now(UTC).isoformat(),
            },
        )
        return self._to_detail(updated, session.material_ids)

    def _get_session_row(self, user_id: UUID, session_id: UUID) -> dict:
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
            raise StudySessionNotFoundError(f"Study session {session_id} was not found.")
        return rows[0]

    def _update_session(self, user_id: UUID, session_id: UUID, payload: dict) -> dict:
        response = (
            self._supabase.table("study_sessions")
            .update(payload)
            .eq("user_id", str(user_id))
            .eq("id", str(session_id))
            .execute()
        )
        rows = response.data or []
        if not rows:
            raise StudySessionNotFoundError(f"Study session {session_id} was not found.")
        return rows[0]

    def _ensure_materials_ready(self, user_id: UUID, material_ids: list[UUID]) -> list[UUID]:
        unique_ids = list(dict.fromkeys(material_ids))
        response = (
            self._supabase.table("study_materials")
            .select("id, analysis_status")
            .eq("user_id", str(user_id))
            .in_("id", [str(material_id) for material_id in unique_ids])
            .execute()
        )
        rows = response.data or []
        found_ids = {UUID(row["id"]) for row in rows}
        missing_ids = [material_id for material_id in unique_ids if material_id not in found_ids]
        if missing_ids:
            raise MaterialSelectionError("One or more selected materials do not exist.")

        not_ready_ids = [
            row["id"]
            for row in rows
            if row.get("analysis_status") != MaterialAnalysisStatus.READY.value
        ]
        if not_ready_ids:
            raise MaterialSelectionError(
                "All selected materials must be ready before starting a session."
            )

        return unique_ids

    def _get_material_ids(self, session_id: UUID) -> list[UUID]:
        material_map = self._get_material_ids_by_session([session_id])
        return material_map.get(session_id, [])

    def _get_material_ids_by_session(self, session_ids: list[UUID]) -> dict[UUID, list[UUID]]:
        if not session_ids:
            return {}

        response = (
            self._supabase.table("session_materials")
            .select("session_id, material_id")
            .in_("session_id", [str(session_id) for session_id in session_ids])
            .execute()
        )
        material_map: dict[UUID, list[UUID]] = {session_id: [] for session_id in session_ids}
        for row in response.data or []:
            material_map[UUID(row["session_id"])].append(UUID(row["material_id"]))
        return material_map

    def _to_detail(self, row: dict, material_ids: list[UUID]) -> StudySessionDetail:
        return StudySessionDetail.model_validate({**row, "material_ids": material_ids})
