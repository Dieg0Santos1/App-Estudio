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
- `study_methods`
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
- `services`: reglas de aplicacion para materiales, sesiones y futuros flujos de quiz.
- `core`: configuracion e infraestructura.

## OpenAI

La app movil consume endpoints propios. El backend usa `OPENAI_API_KEY` y la Responses API para:

- generar preguntas;
- evaluar respuestas;
- dar feedback;
- detectar conceptos debiles.

Modelo inicial: `gpt-5.4-mini`, elegido por equilibrio entre velocidad, costo y calidad para respuestas breves y evaluaciones educativas.

## Nuevo Enfoque

Cada sesion debe registrar un metodo de estudio:

- `visual`: resumenes, tarjetas, esquemas y flashcards.
- `audio`: guiones o explicaciones narradas.
- `writing`: preguntas abiertas, explicaciones y practica escrita.
- `mixed`: ruta combinada de lectura, escucha, practica y evaluacion.

El modo concentracion no sera solo temporizador: mostrara contenido activo segun el metodo elegido.

Flujo base de producto:

1. El usuario crea o sube materiales.
2. Crea una sesion con tema, duracion, modo y metodo de estudio.
3. El backend genera contenido activo para el metodo elegido.
4. Inicia la sesion; Android aplica el bloqueo y la app muestra contenido activo.
5. Al completar el tiempo, la sesion pasa a quiz pendiente.
6. El quiz decide si el telefono se desbloquea o si hay repaso adicional.

El quiz de desbloqueo oculta respuestas correctas en el cliente. Cada respuesta se evalua con IA
contra la respuesta esperada y la explicacion generada; el backend calcula el promedio final y cambia
`unlock_status` a `unlocked` cuando supera el umbral inicial de 0.7.

Los assets de estudio viven en `study_assets` como JSON estructurado. Eso permite que mobile renderice
resumenes, flashcards, guiones de audio, prompts de escritura o rutas mixtas sin pedir IA en cada vista.

## Supabase

Supabase cubre:

- auth;
- PostgreSQL;
- storage;
- pgvector;
- Row Level Security.

La primera migracion define las tablas centrales de producto y politicas RLS por usuario.

Cuando Supabase Auth crea un usuario, un trigger crea automaticamente su fila en `profiles`.

Mobile inicia sesion con `supabase_flutter` y adjunta el access token al backend. FastAPI valida ese
token contra Supabase Auth y deriva el `user_id`; `X-User-Id` queda solo como fallback local temporal.
