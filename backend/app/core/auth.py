from uuid import UUID

from fastapi import Header, HTTPException, status


async def get_current_user_id(x_user_id: str = Header(alias="X-User-Id")) -> UUID:
    try:
        return UUID(x_user_id)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="X-User-Id must be a valid UUID.",
        ) from exc
