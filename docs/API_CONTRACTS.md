# Contratos Iniciales

## Health

`GET /health`

```json
{
  "status": "ok"
}
```

## Generar Preguntas

`POST /ai/questions`

```json
{
  "topic": "Programacion Orientada a Objetos",
  "material_text": "Texto extraido del material...",
  "difficulty": "medium",
  "question_type": "mixed",
  "question_count": 5
}
```

Respuesta:

```json
{
  "topic": "Programacion Orientada a Objetos",
  "questions": [
    {
      "question_text": "Que es el polimorfismo?",
      "question_type": "multiple_choice",
      "options": [{ "id": "A", "text": "..." }],
      "correct_answer": "B",
      "explanation": "...",
      "related_concepts": ["Polimorfismo"],
      "source_hint": "Diapositiva 8"
    }
  ]
}
```

## Evaluar Respuesta

`POST /ai/answers/evaluate`

```json
{
  "question_text": "Que es el polimorfismo?",
  "expected_answer": "Capacidad de distintas clases de responder al mismo metodo de distintas formas.",
  "user_answer": "Es cuando varias clases usan el mismo metodo de forma diferente.",
  "reference_text": "Texto de referencia opcional."
}
```

Respuesta:

```json
{
  "is_correct": true,
  "score": 0.9,
  "feedback": "Respuesta correcta y clara.",
  "missing_concepts": [],
  "reinforced_concepts": ["Polimorfismo"]
}
```
