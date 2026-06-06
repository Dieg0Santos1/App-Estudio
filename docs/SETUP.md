# Setup Local

## Requisitos ya instalados

- Flutter y Dart
- Android Studio, SDK y AVD `FocusStudy_API36`
- Python 3.12 con `uv`
- Firebase CLI
- Supabase CLI
- Docker Desktop
- Google Cloud SDK

## Pendiente del entorno Windows

Docker Desktop esta instalado, pero el motor Linux requiere WSL y `Virtual Machine Platform` activos con permisos de administrador. Cuando este listo:

```powershell
supabase start
```

## Servicios opcionales

Firebase y Google Cloud quedan fuera por ahora.

- Firebase serviria mas adelante para notificaciones push, Crashlytics y analytics.
- Google Cloud serviria para desplegar el backend en Cloud Run u OCR avanzado.

La siguiente etapa puede funcionar con Supabase + OpenAI + desarrollo local.

## Backend

```powershell
cd backend
Copy-Item .env.example .env
uv sync
uv run uvicorn app.main:app --reload
```

## Mobile

```powershell
cd mobile
flutter pub get
flutter analyze
```

Para apuntar la app al backend:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```
