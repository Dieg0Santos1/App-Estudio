from pathlib import Path
from tempfile import NamedTemporaryFile
from uuid import UUID, uuid4

from fastapi import UploadFile

from app.core.config import settings
from app.core.supabase import get_supabase_client
from app.documents.extractor import DocumentTextExtractor, UnsupportedDocumentError
from app.schemas.materials import (
    MaterialAnalysisStatus,
    MaterialDetail,
    TextMaterialCreate,
)


class MaterialNotFoundError(LookupError):
    pass


class EmptyMaterialError(ValueError):
    pass


class MaterialService:
    def __init__(self, extractor: DocumentTextExtractor | None = None) -> None:
        self._supabase = get_supabase_client()
        self._bucket = settings.supabase_storage_bucket
        self._extractor = extractor or DocumentTextExtractor()

    def bucket_name(self) -> str:
        return self._bucket

    def get_upload_path(self, user_id: UUID, material_id: UUID, filename: str) -> str:
        safe_name = Path(filename).name
        return f"{user_id}/materials/{material_id}/{safe_name}"

    def list_materials(self, user_id: UUID) -> list[MaterialDetail]:
        response = (
            self._supabase.table("study_materials")
            .select("*")
            .eq("user_id", str(user_id))
            .order("created_at", desc=True)
            .execute()
        )
        return [MaterialDetail.model_validate(item) for item in response.data or []]

    def get_material(self, user_id: UUID, material_id: UUID) -> MaterialDetail:
        response = (
            self._supabase.table("study_materials")
            .select("*")
            .eq("user_id", str(user_id))
            .eq("id", str(material_id))
            .limit(1)
            .execute()
        )
        rows = response.data or []
        if not rows:
            raise MaterialNotFoundError(f"Material {material_id} was not found.")
        return MaterialDetail.model_validate(rows[0])

    async def create_text_material(
        self,
        user_id: UUID,
        payload: TextMaterialCreate,
    ) -> MaterialDetail:
        material_id = uuid4()
        row = {
            "id": str(material_id),
            "user_id": str(user_id),
            "title": payload.title,
            "file_type": "text",
            "file_url": None,
            "extracted_text": payload.content.strip(),
            "analysis_status": MaterialAnalysisStatus.READY,
        }
        return self._insert_material(row)

    async def upload_material(
        self,
        user_id: UUID,
        file: UploadFile,
        title: str | None = None,
    ) -> MaterialDetail:
        filename = file.filename or "material"
        file_bytes = await file.read()
        if not file_bytes:
            raise EmptyMaterialError("Uploaded material is empty.")

        material_id = uuid4()
        upload_path = self.get_upload_path(user_id, material_id, filename)
        file_type = Path(filename).suffix.lower().lstrip(".") or "file"
        if not self._extractor.supports(Path(filename)):
            supported = ".txt, .md, .pdf, .docx, .pptx"
            suffix = Path(filename).suffix
            raise UnsupportedDocumentError(
                f"Unsupported document type '{suffix}'. Supported types: {supported}."
            )

        self._supabase.storage.from_(self._bucket).upload(
            path=upload_path,
            file=file_bytes,
            file_options={
                "content-type": file.content_type or "application/octet-stream",
                "upsert": "false",
            },
        )

        extracted_text, status = await self._extract_uploaded_text(filename, file_bytes)
        row = {
            "id": str(material_id),
            "user_id": str(user_id),
            "title": title or Path(filename).stem or filename,
            "file_type": file_type,
            "file_url": upload_path,
            "extracted_text": extracted_text,
            "analysis_status": status,
        }
        return self._insert_material(row)

    def delete_material(self, user_id: UUID, material_id: UUID) -> None:
        material = self.get_material(user_id, material_id)

        if material.file_url:
            self._supabase.storage.from_(self._bucket).remove([material.file_url])

        (
            self._supabase.table("study_materials")
            .delete()
            .eq("user_id", str(user_id))
            .eq("id", str(material_id))
            .execute()
        )

    async def _extract_uploaded_text(
        self,
        filename: str,
        file_bytes: bytes,
    ) -> tuple[str | None, MaterialAnalysisStatus]:
        suffix = Path(filename).suffix

        with NamedTemporaryFile(delete=False, suffix=suffix) as temp_file:
            temp_file.write(file_bytes)
            temp_path = Path(temp_file.name)

        try:
            extracted_text = await self._extractor.extract_text(temp_path)
            if not extracted_text:
                return None, MaterialAnalysisStatus.FAILED
            return extracted_text, MaterialAnalysisStatus.READY
        finally:
            temp_path.unlink(missing_ok=True)

    def _insert_material(self, row: dict) -> MaterialDetail:
        response = self._supabase.table("study_materials").insert(row).execute()
        rows = response.data or []
        if not rows:
            raise RuntimeError("Supabase did not return the inserted material.")
        return MaterialDetail.model_validate(rows[0])
