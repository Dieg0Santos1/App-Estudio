from pathlib import Path

import pytest

from app.documents.extractor import DocumentTextExtractor, UnsupportedDocumentError


@pytest.mark.anyio
async def test_extracts_plain_text(tmp_path: Path) -> None:
    path = tmp_path / "notes.txt"
    path.write_text("Polimorfismo y herencia", encoding="utf-8")

    result = await DocumentTextExtractor().extract_text(path)

    assert result == "Polimorfismo y herencia"


@pytest.mark.anyio
async def test_rejects_unsupported_document_type(tmp_path: Path) -> None:
    path = tmp_path / "image.png"
    path.write_bytes(b"not used")

    with pytest.raises(UnsupportedDocumentError):
        await DocumentTextExtractor().extract_text(path)
