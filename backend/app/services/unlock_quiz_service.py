from uuid import UUID

from app.ai.base import AIProvider
from app.core.supabase import get_supabase_client
from app.schemas.ai import AnswerEvaluationRequest, QuestionGenerationRequest
from app.schemas.study_sessions import SessionStatus, UnlockStatus
from app.schemas.unlock_quiz import (
    UnlockQuiz,
    UnlockQuizAnswerCreate,
    UnlockQuizAnswerResult,
    UnlockQuizGenerateRequest,
    UnlockQuizProgress,
    UnlockQuizQuestion,
)

PASSING_SCORE = 0.7
MATERIAL_TEXT_LIMIT = 18_000


class UnlockQuizNotFoundError(LookupError):
    pass


class UnlockQuizUnavailableError(ValueError):
    pass


class UnlockQuizQuestionNotFoundError(LookupError):
    pass


class UnlockQuizService:
    def __init__(self, ai_provider: AIProvider) -> None:
        self._supabase = get_supabase_client()
        self._ai_provider = ai_provider

    async def generate_quiz(
        self,
        user_id: UUID,
        session_id: UUID,
        payload: UnlockQuizGenerateRequest,
    ) -> UnlockQuiz:
        session = self._get_completed_session(user_id, session_id)
        existing_questions = self._list_question_rows(session_id)
        if existing_questions:
            return self._to_quiz(session, existing_questions, user_id)

        material_text = self._get_session_material_text(session_id)
        result = await self._ai_provider.generate_questions(
            QuestionGenerationRequest(
                topic=session["topic"],
                material_text=material_text[:MATERIAL_TEXT_LIMIT],
                study_method=session["study_method"],
                difficulty=payload.difficulty,
                question_type=payload.question_type,
                question_count=payload.question_count,
            )
        )

        rows = [
            {
                "session_id": str(session_id),
                "question_text": question.question_text,
                "question_type": question.question_type.value,
                "options": [option.model_dump() for option in question.options],
                "correct_answer": question.correct_answer,
                "explanation": question.explanation,
                "difficulty": payload.difficulty.value,
                "related_concepts": question.related_concepts,
                "source_hint": question.source_hint,
            }
            for question in result.questions
        ]
        response = self._supabase.table("questions").insert(rows).execute()
        question_rows = response.data or []
        if not question_rows:
            raise RuntimeError("Supabase did not return generated quiz questions.")

        return self._to_quiz(session, question_rows, user_id)

    def get_quiz(self, user_id: UUID, session_id: UUID) -> UnlockQuiz:
        session = self._get_completed_session(user_id, session_id)
        question_rows = self._list_question_rows(session_id)
        if not question_rows:
            raise UnlockQuizNotFoundError("Unlock quiz has not been generated yet.")
        return self._to_quiz(session, question_rows, user_id)

    async def submit_answer(
        self,
        user_id: UUID,
        session_id: UUID,
        payload: UnlockQuizAnswerCreate,
    ) -> UnlockQuizAnswerResult:
        session = self._get_completed_session(user_id, session_id)
        question = self._get_question_row(session_id, payload.question_id)
        evaluation = await self._ai_provider.evaluate_answer(
            AnswerEvaluationRequest(
                question_text=question["question_text"],
                expected_answer=question["correct_answer"],
                user_answer=payload.answer_text,
                reference_text=question["explanation"],
            )
        )

        self._supabase.table("user_answers").insert(
            {
                "question_id": str(payload.question_id),
                "user_id": str(user_id),
                "answer_text": payload.answer_text,
                "is_correct": evaluation.is_correct,
                "score": evaluation.score,
                "feedback": evaluation.feedback,
            }
        ).execute()

        question_rows = self._list_question_rows(session_id)
        progress = self._build_progress(session, question_rows, user_id)
        self._sync_session_unlock_status(user_id, session_id, progress)
        synced_session = self._get_completed_session(user_id, session_id)
        synced_progress = self._build_progress(synced_session, question_rows, user_id)

        return UnlockQuizAnswerResult(
            question_id=payload.question_id,
            answer_text=payload.answer_text,
            evaluation=evaluation,
            progress=synced_progress,
        )

    def _get_completed_session(self, user_id: UUID, session_id: UUID) -> dict:
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
            raise UnlockQuizNotFoundError("Study session not found.")

        session = rows[0]
        if session.get("status") != SessionStatus.COMPLETED.value:
            raise UnlockQuizUnavailableError("Only completed sessions can generate unlock quizzes.")

        if session.get("unlock_status") == UnlockStatus.LOCKED.value:
            raise UnlockQuizUnavailableError("Session is not ready for unlock quiz yet.")

        return session

    def _get_session_material_text(self, session_id: UUID) -> str:
        material_response = (
            self._supabase.table("session_materials")
            .select("material_id")
            .eq("session_id", str(session_id))
            .execute()
        )
        material_ids = [row["material_id"] for row in material_response.data or []]
        if not material_ids:
            raise UnlockQuizUnavailableError("Session has no study materials.")

        response = (
            self._supabase.table("study_materials")
            .select("title, extracted_text")
            .in_("id", material_ids)
            .execute()
        )
        chunks = [
            f"{row['title']}\n{row['extracted_text']}"
            for row in response.data or []
            if row.get("extracted_text")
        ]
        if not chunks:
            raise UnlockQuizUnavailableError("Session materials do not have extracted text.")

        return "\n\n---\n\n".join(chunks)

    def _list_question_rows(self, session_id: UUID) -> list[dict]:
        response = (
            self._supabase.table("questions")
            .select("*")
            .eq("session_id", str(session_id))
            .order("created_at")
            .execute()
        )
        return response.data or []

    def _get_question_row(self, session_id: UUID, question_id: UUID) -> dict:
        response = (
            self._supabase.table("questions")
            .select("*")
            .eq("session_id", str(session_id))
            .eq("id", str(question_id))
            .limit(1)
            .execute()
        )
        rows = response.data or []
        if not rows:
            raise UnlockQuizQuestionNotFoundError("Question not found in this unlock quiz.")
        return rows[0]

    def _to_quiz(self, session: dict, question_rows: list[dict], user_id: UUID) -> UnlockQuiz:
        answered_ids = set(self._latest_answers_by_question(user_id, question_rows))
        questions = [
            UnlockQuizQuestion.model_validate(
                {
                    **row,
                    "answered": UUID(row["id"]) in answered_ids,
                }
            )
            for row in question_rows
        ]
        return UnlockQuiz(
            session_id=UUID(session["id"]),
            questions=questions,
            progress=self._build_progress(session, question_rows, user_id),
        )

    def _build_progress(
        self,
        session: dict,
        question_rows: list[dict],
        user_id: UUID,
    ) -> UnlockQuizProgress:
        answers = self._latest_answers_by_question(user_id, question_rows)
        total_questions = len(question_rows)
        answered_questions = len(answers)
        average_score = None
        passed = False

        if answers:
            average_score = sum(answer["score"] for answer in answers.values()) / len(answers)

        if (
            total_questions > 0
            and answered_questions == total_questions
            and average_score is not None
        ):
            passed = average_score >= PASSING_SCORE

        return UnlockQuizProgress(
            total_questions=total_questions,
            answered_questions=answered_questions,
            average_score=average_score,
            passing_score=PASSING_SCORE,
            unlock_status=session["unlock_status"],
            passed=passed,
        )

    def _latest_answers_by_question(
        self,
        user_id: UUID,
        question_rows: list[dict],
    ) -> dict[UUID, dict]:
        if not question_rows:
            return {}

        question_ids = [row["id"] for row in question_rows]
        response = (
            self._supabase.table("user_answers")
            .select("*")
            .eq("user_id", str(user_id))
            .in_("question_id", question_ids)
            .order("created_at", desc=True)
            .execute()
        )
        answers: dict[UUID, dict] = {}
        for row in response.data or []:
            question_id = UUID(row["question_id"])
            if question_id not in answers:
                answers[question_id] = row
        return answers

    def _sync_session_unlock_status(
        self,
        user_id: UUID,
        session_id: UUID,
        progress: UnlockQuizProgress,
    ) -> None:
        if (
            progress.answered_questions != progress.total_questions
            or progress.average_score is None
        ):
            return

        unlock_status = UnlockStatus.UNLOCKED if progress.passed else UnlockStatus.FAILED
        (
            self._supabase.table("study_sessions")
            .update(
                {
                    "unlock_status": unlock_status.value,
                    "score": round(progress.average_score * 100, 2),
                }
            )
            .eq("user_id", str(user_id))
            .eq("id", str(session_id))
            .execute()
        )
