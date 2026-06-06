from functools import lru_cache

from app.ai.base import AIProvider
from app.ai.openai_provider import OpenAIProvider


@lru_cache
def get_ai_provider() -> AIProvider:
    return OpenAIProvider()
