from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.routes import ai, health, materials, study_assets, study_sessions, unlock_quiz


def create_app() -> FastAPI:
    app = FastAPI(
        title="FocusStudy AI API",
        version="0.1.0",
        description="Backend for study sessions, AI questions, answers and progress.",
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(health.router)
    app.include_router(ai.router, prefix="/ai", tags=["ai"])
    app.include_router(materials.router, prefix="/materials", tags=["materials"])
    app.include_router(study_sessions.router, prefix="/study-sessions", tags=["study-sessions"])
    app.include_router(study_assets.router, prefix="/study-sessions", tags=["study-assets"])
    app.include_router(unlock_quiz.router, prefix="/study-sessions", tags=["unlock-quiz"])

    return app


app = create_app()
