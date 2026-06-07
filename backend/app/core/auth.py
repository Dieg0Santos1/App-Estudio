from uuid import UUID

from fastapi import Header, HTTPException, status

from app.core.supabase import get_supabase_client


class AuthTokenError(ValueError):
    pass


def get_user_id_from_access_token(access_token: str) -> UUID:
    try:
        response = get_supabase_client().auth.get_user(access_token)
        user = response.user
    except Exception as exc:
        raise AuthTokenError("Invalid or expired access token.") from exc

    if not user or not user.id:
        raise AuthTokenError("Invalid or expired access token.")

    return UUID(user.id)


async def get_current_user_id(
    authorization: str | None = Header(default=None),
    x_user_id: str | None = Header(default=None, alias="X-User-Id"),
) -> UUID:
    if authorization:
        return _get_user_id_from_authorization_header(authorization)

    if x_user_id:
        return _get_user_id_from_dev_header(x_user_id)

    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Authorization bearer token is required.",
    )


def _get_user_id_from_authorization_header(authorization: str) -> UUID:
    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization must use Bearer token.",
        )

    try:
        return get_user_id_from_access_token(token)
    except (AuthTokenError, ValueError) as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
        ) from exc


def _get_user_id_from_dev_header(x_user_id: str) -> UUID:
    try:
        return UUID(x_user_id)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="X-User-Id must be a valid UUID.",
        ) from exc
