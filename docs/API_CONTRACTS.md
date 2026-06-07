# Contratos Iniciales

## Health

`GET /health`

```json
{
  "status": "ok"
}
```

## Materiales

Los endpoints de materiales usan temporalmente el header `X-User-Id` hasta conectar Supabase Auth en mobile. El usuario debe existir en `profiles`; en produccion esa fila se crea automaticamente desde Supabase Auth.

### Listar Materiales

`GET /materials`

Headers:

```txt
X-User-Id: 00000000-0000-0000-0000-000000000000
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
