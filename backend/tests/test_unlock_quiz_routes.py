from datetime import UTC, datetime
from uuid import UUID

from fastapi.testclient import TestClient

from app.main import app
from app.routes.unlock_quiz import get_unlock_quiz_service
from app.schemas.ai import AnswerEvaluationResult, Difficulty, QuestionOption, QuestionType
from app.schemas.study_sessions import UnlockStatus
from app.schemas.unlock_quiz import (
    UnlockQuiz,
    UnlockQuizAnswerCreate,
    UnlockQuizAnswerResult,
    UnlockQuizGenerateRequest,
    UnlockQuizProgress,
    UnlockQuizQuestion,
)

USER_ID = UUID("00000000-0000-0000-0000-000000000001")
SESSION_ID = UUID("00000000-0000-0000-0000-000000000010")
QUESTION_ID = UUID("00000000-0000-0000-0000-000000000030")


class FakeUnlockQuizService:
    async def generate_quiz(
        self,
        user_id: UUID,
        session_id: UUID,
        payload: UnlockQuizGenerateRequest,
    ) -> UnlockQuiz:
        assert user_id == USER_ID
        assert session_id == SESSION_ID
        assert payload.question_count == 3
        return _quiz()

    def get_quiz(self, user_id: UUID, session_id: UUID) -> UnlockQuiz:
        assert user_id == USER_ID
        assert session_id == SESSION_ID
        return _quiz()

    async def submit_answer(
        self,
        user_id: UUID,
        session_id: UUID,
        payload: UnlockQuizAnswerCreate,
    ) -> UnlockQuizAnswerResult:
        assert user_id == USER_ID
        assert session_id == SESSION_ID
        assert payload.question_id == QUESTION_ID
        return UnlockQuizAnswerResult(
            question_id=QUESTION_ID,
            answer_text=payload.answer_text,
            evaluation=AnswerEvaluationResult(
                is_correct=True,
                score=0.85,
                feedback="Buen manejo del concepto.",
                missing_concepts=[],
                reinforced_concepts=["Polimorfismo"],
            ),
            progress=UnlockQuizProgress(
                total_questions=1,
                answered_questions=1,
                average_score=0.85,
                passing_score=0.7,
                unlock_status=UnlockStatus.UNLOCKED,
                passed=True,
            ),
        )


def _quiz() -> UnlockQuiz:
    return UnlockQuiz(
        session_id=SESSION_ID,
        questions=[
            UnlockQuizQuestion(
                id=QUESTION_ID,
                session_id=SESSION_ID,
                question_text="Que es el polimorfismo?",
                question_type=QuestionType.MULTIPLE_CHOICE,
                options=[
                    QuestionOption(id="A", text="Herencia directa"),
                    QuestionOption(id="B", text="Mismo mensaje, respuestas diferentes"),
                ],
                difficulty=Difficulty.MEDIUM,
                related_concepts=["Polimorfismo"],
                source_hint="Material 1",
                created_at=datetime(2026, 6, 6, tzinfo=UTC),
                answered=False,
            )
        ],
        progress=UnlockQuizProgress(
            total_questions=1,
            answered_questions=0,
            average_score=None,
            passing_score=0.7,
            unlock_status=UnlockStatus.PENDING_QUIZ,
            passed=False,
        ),
    )


def _client() -> TestClient:
    app.dependency_overrides[get_unlock_quiz_service] = lambda: FakeUnlockQuizService()
    return TestClient(app)


def teardown_function() -> None:
    app.dependency_overrides.clear()


def test_generate_unlock_quiz_hides_correct_answer() -> None:
    response = _client().post(
        f"/study-sessions/{SESSION_ID}/quiz",
        headers={"X-User-Id": str(USER_ID)},
        json={"question_count": 3, "difficulty": "medium", "question_type": "mixed"},
    )

    assert response.status_code == 201
    question = response.json()["questions"][0]
    assert question["question_text"] == "Que es el polimorfismo?"
    assert "correct_answer" not in question
    assert "explanation" not in question


def test_get_unlock_quiz_progress() -> None:
    response = _client().get(
        f"/study-sessions/{SESSION_ID}/quiz",
        headers={"X-User-Id": str(USER_ID)},
    )

    assert response.status_code == 200
    assert response.json()["progress"]["unlock_status"] == "pending_quiz"


def test_submit_answer_returns_evaluation_and_unlock_progress() -> None:
    response = _client().post(
        f"/study-sessions/{SESSION_ID}/quiz/answers",
        headers={"X-User-Id": str(USER_ID)},
        json={
            "question_id": str(QUESTION_ID),
            "answer_text": "Es responder distinto ante el mismo metodo.",
        },
    )

    assert response.status_code == 200
    body = response.json()
    assert body["evaluation"]["is_correct"] is True
    assert body["progress"]["passed"] is True
    assert body["progress"]["unlock_status"] == "unlocked"
