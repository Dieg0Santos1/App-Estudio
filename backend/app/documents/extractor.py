from pathlib import Path
from typing import Protocol


class TextExtractor(Protocol):
    def supports(self, path: Path) -> bool:
        """Return true when the extractor can process this file."""

    async def extract_text(self, path: Path) -> str:
        """Extract readable study text from a file."""


class UnsupportedDocumentError(ValueError):
    pass
