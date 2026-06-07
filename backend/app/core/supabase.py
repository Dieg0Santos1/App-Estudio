from functools import lru_cache

from supabase import Client, create_client

from app.core.config import settings


@lru_cache
def get_supabase_client() -> Client:
    if not settings.supabase_url:
        raise RuntimeError("SUPABASE_URL is required to use Supabase.")
    if not settings.supabase_service_role_key:
        raise RuntimeError("SUPABASE_SERVICE_ROLE_KEY is required to use Supabase.")

    return create_client(settings.supabase_url, settings.supabase_service_role_key)
