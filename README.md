# FocusStudy AI

FocusStudy AI convierte el celular en una herramienta de estudio: bloquea distracciones durante una sesion y valida el aprendizaje con preguntas generadas por IA antes de desbloquear.

## Estructura

```txt
focusstudy-ai/
├── mobile/      # Flutter + Dart, UI, estado y Android bridge
├── backend/     # FastAPI + Python, OpenAI, documentos y servicios
├── supabase/    # Configuracion, migraciones y RLS
├── docs/        # Arquitectura y contratos
├── design/      # Referencias exportadas desde Stitch/Figma
├── Concepto.md
└── Stack.md
```

## Principios

- Flutter no llama directamente a OpenAI.
- Las API keys viven solo en backend o servicios seguros.
- Kotlin nativo se usara para permisos, bloqueo y servicios Android profundos.
- Supabase maneja auth, datos, storage y pgvector.
- Las vistas de Stitch/Figma son referencia visual; primero se estabilizan contratos y arquitectura.

## Primeros comandos

```powershell
cd backend
uv sync
uv run uvicorn app.main:app --reload
```

```powershell
cd mobile
flutter pub get
flutter analyze
```

Supabase local requiere Docker Desktop con WSL funcionando:

```powershell
supabase start
```
