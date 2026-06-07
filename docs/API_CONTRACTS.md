# Contratos Iniciales

## Health

`GET /health`

```json
{
  "status": "ok"
}
```

## Autenticacion

Los endpoints privados usan Supabase Auth:

```txt
Authorization: Bearer <access_token>
```

Durante desarrollo local, el backend mantiene temporalmente `X-User-Id` como fallback para pruebas
manuales y tests. Mobile debe usar el token real de Supabase.

## Materiales

El usuario debe existir en `profiles`; en produccion esa fila se crea automaticamente desde Supabase Auth.

### Listar Materiales

`GET /materials`

Headers:

```txt
Authorization: Bearer <access_token>
```

Respuesta:

```json
[
  {
    "id": "00000000-0000-0000-0000-000000000000",
    "user_id": "00000000-0000-0000-0000-000000000000",
    "title": "Resumen POO",
    "file_type": "pdf",
    "file_url": "user/materials/material/file.pdf",
    "analysis_status": "ready",
    "created_at": "2026-06-06T22:20:00Z",
    "extracted_text": "Texto extraido..."
  }
]
```

### Subir Archivo

`POST /materials/upload`

`multipart/form-data`:

```txt
file: archivo .txt, .md, .pdf, .docx o .pptx
title: titulo opcional
```

### Crear Material de Texto

`POST /materials/text`

```json
{
  "title": "Nota sobre polimorfismo",
  "content": "Texto pegado por el usuario..."
}
```

### Obtener Detalle

`GET /materials/{material_id}`

### Eliminar

`DELETE /materials/{material_id}`

## Sesiones de Estudio

Una sesion nace como `draft`, pasa a `active` cuando inicia el modo foco y queda en `pending_quiz`
al completarse.

### Crear Sesion

`POST /study-sessions`

```json
{
  "topic": "Programacion Orientada a Objetos",
  "duration_minutes": 45,
  "mode": "normal",
  "study_method": "visual",
  "material_ids": ["00000000-0000-0000-0000-000000000000"]
}
```

Respuesta:

```json
{
  "session": {
    "id": "00000000-0000-0000-0000-000000000000",
    "user_id": "00000000-0000-0000-0000-000000000000",
    "topic": "Programacion Orientada a Objetos",
    "duration_minutes": 45,
    "mode": "normal",
    "study_method": "visual",
    "started_at": null,
    "ended_at": null,
    "status": "draft",
    "score": null,
    "unlock_status": "locked",
    "created_at": "2026-06-06T22:20:00Z",
    "material_ids": ["00000000-0000-0000-0000-000000000000"]
  }
}
```

### Listar y Ver Detalle

`GET /study-sessions`

`GET /study-sessions/{session_id}`

### Ciclo de Vida

`POST /study-sessions/{session_id}/start`

Marca la sesion como `active`, registra `started_at` y mantiene el desbloqueo en `locked`.

`POST /study-sessions/{session_id}/complete`

Marca la sesion como `completed`, registra `ended_at` y cambia `unlock_status` a `pending_quiz`.

`POST /study-sessions/{session_id}/cancel`

Cancela sesiones `draft` o `active`.

## Contenido Activo de Estudio

Estos assets son el contenido que aparece durante el modo foco. Se generan antes o durante una
sesion `draft`/`active`, segun el metodo elegido en la sesion.

### Generar Assets

`POST /study-sessions/{session_id}/assets`

```json
{
  "force_regenerate": false
}
```

Respuesta:

```json
{
  "session_id": "00000000-0000-0000-0000-000000000000",
  "assets": [
    {
      "id": "00000000-0000-0000-0000-000000000000",
      "session_id": "00000000-0000-0000-0000-000000000000",
      "material_id": null,
      "asset_type": "summary",
      "title": "Resumen guiado",
      "content": {
        "sections": [
          {
            "heading": "Idea central",
            "bullets": ["El polimorfismo permite respuestas distintas al mismo mensaje."]
          }
        ]
      },
      "order_index": 0,
      "created_at": "2026-06-06T22:20:00Z"
    }
  ]
}
```

Tipos esperados segun metodo:

- `visual`: `summary`, `flashcards`, `comparison_table`, `mind_map`.
- `audio`: `audio_script`.
- `writing`: `writing_prompt`.
- `mixed`: `mixed_path`.

### Listar Assets

`GET /study-sessions/{session_id}/assets`

## Quiz de Desbloqueo

El quiz se genera solo cuando la sesion ya esta `completed` y su `unlock_status` esta en
`pending_quiz`. El backend guarda la respuesta correcta, pero no la entrega al cliente antes de que
el usuario conteste.

### Generar Quiz

`POST /study-sessions/{session_id}/quiz`

```json
{
  "question_count": 5,
  "difficulty": "medium",
  "question_type": "mixed"
}
```

Respuesta:

```json
{
  "session_id": "00000000-0000-0000-0000-000000000000",
  "questions": [
    {
      "id": "00000000-0000-0000-0000-000000000000",
      "session_id": "00000000-0000-0000-0000-000000000000",
      "question_text": "Que es el polimorfismo?",
      "question_type": "multiple_choice",
      "options": [{ "id": "A", "text": "..." }],
      "difficulty": "medium",
      "related_concepts": ["Polimorfismo"],
      "source_hint": "Material 1",
      "created_at": "2026-06-06T22:20:00Z",
      "answered": false
    }
  ],
  "progress": {
    "total_questions": 5,
    "answered_questions": 0,
    "average_score": null,
    "passing_score": 0.7,
    "unlock_status": "pending_quiz",
    "passed": false
  }
}
```

### Ver Quiz

`GET /study-sessions/{session_id}/quiz`

### Responder

`POST /study-sessions/{session_id}/quiz/answers`

```json
{
  "question_id": "00000000-0000-0000-0000-000000000000",
  "answer_text": "El polimorfismo permite que distintas clases respondan distinto al mismo metodo."
}
```

Respuesta:

```json
{
  "question_id": "00000000-0000-0000-0000-000000000000",
  "answer_text": "El polimorfismo permite que distintas clases respondan distinto al mismo metodo.",
  "evaluation": {
    "is_correct": true,
    "score": 0.85,
    "feedback": "Correcto; explica la idea central.",
    "missing_concepts": [],
    "reinforced_concepts": ["Polimorfismo"]
  },
  "progress": {
    "total_questions": 5,
    "answered_questions": 5,
    "average_score": 0.82,
    "passing_score": 0.7,
    "unlock_status": "unlocked",
    "passed": true
  }
}
```

## Generar Preguntas

`POST /ai/questions`

```json
{
  "topic": "Programacion Orientada a Objetos",
  "material_text": "Texto extraido del material...",
  "study_method": "visual",
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
