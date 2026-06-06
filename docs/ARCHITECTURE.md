# Arquitectura

## Capas

```txt
Flutter UI
  -> Riverpod state
  -> GoRouter navigation
  -> Dio API client
  -> FastAPI backend
  -> OpenAI / Supabase / document services

Flutter UI
  -> Platform Channels
  -> Kotlin Android services
  -> UsageStats, Accessibility, ForegroundService, Overlay
```

## Mobile

`mobile/lib/features` separa los dominios principales:

- `onboarding`
- `auth`
- `permissions`
- `home`
- `study_session`
- `focus_mode`
- `unlock_quiz`
- `results`
- `library`
- `progress`
- `profile`

Las pantallas actuales son placeholders tecnicos. Las vistas de Stitch/Figma entran despues, cuando los contratos de datos esten claros.

## Backend

`backend/app` separa:

- `routes`: endpoints HTTP.
- `schemas`: contratos Pydantic.
- `ai`: proveedores de IA y abstracciones.
- `documents`: extraccion de texto desde material academico.
- `core`: configuracion e infraestructura.

## OpenAI

La app movil consume endpoints propios. El backend usa `OPENAI_API_KEY` y la Responses API para:

- generar preguntas;
- evaluar respuestas;
- dar feedback;
- detectar conceptos debiles.

## Supabase

Supabase cubre:

- auth;
- PostgreSQL;
- storage;
- pgvector;
- Row Level Security.

La primera migracion define las tablas centrales de producto y politicas RLS por usuario.
