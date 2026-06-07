import json

from openai import AsyncOpenAI

from app.ai.base import AIProvider
from app.core.config import settings
from app.schemas.ai import (
    AnswerEvaluationRequest,
    AnswerEvaluationResult,
    QuestionGenerationRequest,
    QuestionGenerationResult,
)


class OpenAIProvider(AIProvider):
    def __init__(self) -> None:
        if not settings.openai_api_key:
            raise RuntimeError("OPENAI_API_KEY is required to use OpenAIProvider.")

        self._client = AsyncOpenAI(api_key=settings.openai_api_key)
        self._model = settings.openai_model

    async def generate_questions(
        self,
        request: QuestionGenerationRequest,
    ) -> QuestionGenerationResult:
        response = await self._client.responses.create(
            model=self._model,
            instructions=(
                "Eres un tutor academico. Genera preguntas utiles para validar "
                "comprension real, no memorizacion superficial. Usa solo el material dado."
            ),
            input=self._question_prompt(request),
            text={
                "format": {
                    "type": "json_schema",
                    "name": "question_generation_result",
                    "schema": QuestionGenerationResult.model_json_schema(),
                    "strict": True,
                }
            },
        )
        return QuestionGenerationResult.model_validate(json.loads(response.output_text))

    async def evaluate_answer(
        self,
        request: AnswerEvaluationRequest,
    ) -> AnswerEvaluationResult:
        response = await self._client.responses.create(
            model=self._model,
            instructions=(
                "Eres un evaluador academico justo. Evalua significado, claridad y "
                "uso de conceptos. Devuelve feedback breve y accionable."
            ),
            input=self._evaluation_prompt(request),
            text={
                "format": {
                    "type": "json_schema",
                    "name": "answer_evaluation_result",
                    "schema": AnswerEvaluationResult.model_json_schema(),
                    "strict": True,
                }
            },
        )
        return AnswerEvaluationResult.model_validate(json.loads(response.output_text))

    def _question_prompt(self, request: QuestionGenerationRequest) -> str:
        return f"""
Tema: {request.topic}
Metodo de estudio elegido: {request.study_method}
Dificultad: {request.difficulty}
Tipo de evaluacion: {request.question_type}
Cantidad de preguntas: {request.question_count}

Material de estudio:
{request.material_text}
""".strip()

    def _evaluation_prompt(self, request: AnswerEvaluationRequest) -> str:
        return f"""
Pregunta:
{request.question_text}

Respuesta esperada:
{request.expected_answer}

Respuesta del estudiante:
{request.user_answer}

Material o explicacion de referencia:
{request.reference_text or "No hay referencia adicional."}
""".strip()
