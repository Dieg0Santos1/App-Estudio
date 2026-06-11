# Focus - Estado actual y roadmap

## 1. Estado general

Focus ya tiene una base funcional importante. El proyecto no esta en una fase de idea: ya existe estructura de backend, base de datos, app movil, autenticacion, permisos y varias pantallas reales.

El foco actual es avanzar de pantallas base a flujos conectados con datos reales.

## 2. Stack actual

### Mobile

- Flutter.
- Riverpod.
- GoRouter.
- Dio.
- Supabase Flutter.
- Shared Preferences.
- Permission Handler.
- Android nativo con Kotlin para permisos especiales.

### Backend

- Python.
- FastAPI.
- Supabase.
- OpenAI API.
- Procesamiento inicial de documentos.
- Tests con pytest.

### Datos y storage

- Supabase Auth.
- Supabase Postgres.
- Supabase Storage.
- Bucket: `study-materials`.

## 3. Lo que ya existe

### 3.1 Estructura del proyecto

Ya existe una estructura separada:

- `mobile/`: aplicacion Flutter.
- `backend/`: API FastAPI.
- `supabase/`: migraciones y configuracion.
- `docs/`: documentacion.
- `design/`: referencias de diseno.

### 3.2 Backend

Ya existen endpoints y servicios para:

- Health check.
- Materiales de estudio.
- Sesiones de estudio.
- Assets activos de estudio.
- Quiz de desbloqueo.
- Generacion de preguntas con IA.
- Evaluacion de respuestas con IA.

Tambien existe autenticacion con Supabase:

- Valida `Authorization: Bearer <access_token>`.
- Mantiene fallback local por `X-User-Id` para tests/desarrollo.

### 3.3 Base de datos

Ya hay migraciones iniciales para:

- Perfiles de usuario.
- Materiales de estudio.
- Sesiones.
- Relacion sesion-material.
- Preguntas.
- Respuestas.
- Apps bloqueadas.
- Assets de estudio.

Tambien hay trigger de perfil al crear usuario.

### 3.4 IA

Ya existe integracion backend con OpenAI para:

- Generar preguntas.
- Evaluar respuestas.
- Separar proveedor de IA por interfaz.

Modelo configurado:

- `gpt-5.4-mini` como opcion rapida y de buena calidad para respuestas puntuales.

### 3.5 App movil

Pantallas reales implementadas:

- Onboarding.
- Login / Crear cuenta.
- Permisos.
- Home.
- Nueva sesion.

Pantallas aun placeholder o pendientes de evolucion:

- Biblioteca.
- Progreso.
- Perfil.
- Focus Mode.
- Unlock Quiz.
- Resultados.

### 3.6 Onboarding

Implementado con:

- Tres pantallas.
- Branding Focus.
- Animacion tipo libro/foco.
- Persistencia de onboarding visto.
- Paso hacia Auth.

### 3.7 Auth

Implementado con:

- Login por correo y contrasena.
- Crear cuenta.
- Recuperar contrasena.
- Transiciones suaves entre login y registro.
- Conexion real con Supabase Auth.

Verificado:

- Crear cuenta funciona desde emulador.
- Login funciona desde emulador.

Nota:

- La app debe correr con `--dart-define` para recibir las variables de Supabase.

### 3.8 Permisos

Implementado como flujo guiado:

- Notificaciones.
- Acceso de uso.
- Mostrar sobre otras apps.
- Archivos explicado como selector puntual.
- Accesibilidad como opcion avanzada.

Incluye:

- Estado real de permisos.
- Boton contextual segun permiso pendiente.
- Canal nativo Android/Kotlin para Usage Access y Overlay.
- Refresh automatico al volver desde Ajustes.

### 3.9 Home

Implementado como dashboard real:

- Header Focus.
- Saludo del usuario.
- Racha.
- Tiempo de estudio de hoy.
- Boton `Nueva sesion`.
- Progreso semanal.
- Material reciente.
- Aviso si faltan permisos.
- Footer con cinco secciones:
  - Biblioteca.
  - Sesiones.
  - Inicio.
  - Progreso.
  - Perfil.

Estado actual:

- Usa datos mock para progreso y materiales.
- Ya lee el nombre desde Supabase si existe.

### 3.10 Nueva sesion

Implementado como wizard de tres pasos:

1. Que vas a estudiar?
   - Tema principal.
   - Material de estudio.
   - Acceso a agregar material.

2. Como quieres aprender?
   - Tipo de estudio:
     - Visual.
     - Auditivo.
     - Escritura.
     - Mixto.
   - Duracion.
   - Nivel de reto:
     - Suave.
     - Intermedio.
     - Exigente.

3. Que quieres bloquear?
   - Apps a bloquear.
   - Resumen de la sesion.
   - Boton `Iniciar sesion`.

Decision de producto aplicada:

- Se elimino "tipo de pregunta" manual.
- Focus decide las preguntas segun el tipo de estudio elegido.

Estado actual:

- Usa datos mock.
- El boton final navega hacia Focus Mode placeholder.
- Falta conectar con backend para crear sesion real.

## 4. Verificacion actual

El proyecto ha sido verificado con:

- `flutter analyze`.
- `flutter test`.
- `flutter build apk --debug`.
- Pruebas visuales en emulador Android.
- Tests backend con pytest en avances anteriores.

Tests mobile actuales:

- Onboarding inicial.
- Cambio de Auth a Crear cuenta.
- Permisos en estado listo.
- Home con dashboard y cinco tabs.
- Wizard de Nueva sesion.

## 5. Pendientes importantes

### 5.1 Conectar Nueva sesion al backend

Objetivo:

- Reemplazar datos mock por materiales reales.
- Crear sesion real con:
  - topic.
  - duration_minutes.
  - mode.
  - study_method.
  - material_ids.

Al completar:

- Llamar `POST /study-sessions`.
- Luego llamar start session si corresponde.
- Navegar a Focus Mode con el `sessionId`.

### 5.2 Biblioteca real

Objetivo:

- Subir material.
- Listar materiales.
- Mostrar estado de analisis.
- Reutilizar material en Nueva sesion.

Flujo deseado:

1. Usuario toca Biblioteca.
2. Sube PDF, markdown, texto o documento.
3. Backend extrae texto.
4. Se guarda en Supabase Storage y Postgres.
5. Material aparece como listo/procesando.

### 5.3 Focus Mode real

Objetivo:

- Reemplazar placeholder por pantalla activa.

Debe incluir:

- Temporizador.
- Tema.
- Metodo elegido.
- Apps bloqueadas.
- Contenido activo segun metodo.
- Estado de bloqueo.
- Boton de emergencia.

Por metodo:

- Visual: tarjetas/resumen/esquema.
- Auditivo: reproductor/guion/transcripcion.
- Escritura: prompt/campo/feedback.
- Mixto: ruta por pasos.

### 5.4 Bloqueo real de apps

Objetivo:

- Detectar intento de abrir apps bloqueadas.
- Mostrar overlay de Focus.
- Guiar al estudiante de vuelta a la sesion.

Piezas necesarias:

- Usage Access para detectar app foreground.
- Overlay para mostrar pantalla encima.
- Posible servicio Android en segundo plano.
- Estrategia de emergencia.

### 5.5 Assets activos de estudio

Objetivo:

- Generar contenido durante la sesion segun metodo.

Backend ya tiene base para assets.

Falta:

- UI para consumirlos.
- Generacion diferenciada por metodo.
- Estado de carga mientras IA prepara contenido.

### 5.6 Unlock Quiz real

Objetivo:

- Mostrar preguntas.
- Recoger respuestas.
- Evaluar con IA.
- Decidir si desbloquea.

Debe adaptarse al tipo de estudio:

- Visual: relacion, seleccion, conceptos.
- Auditivo: comprension y recuerdo.
- Escritura: respuestas abiertas y explicacion.
- Mixto: combinacion.

### 5.7 Resultados

Objetivo:

- Cerrar la sesion con feedback.

Debe mostrar:

- Puntaje.
- Tiempo estudiado.
- Metodo usado.
- Preguntas correctas.
- Conceptos dominados.
- Conceptos a reforzar.
- Recomendacion de siguiente sesion.

### 5.8 Progreso real

Objetivo:

- Convertir el progreso mock del Home en datos reales.

Debe calcular:

- Minutos por dia.
- Sesiones completadas.
- Racha.
- Precision promedio.
- Tasa de desbloqueo.
- Conceptos debiles.

### 5.9 Perfil real

Objetivo:

- Gestionar preferencias.

Debe incluir:

- Nombre.
- Meta diaria.
- Modo preferido.
- Apps bloqueadas por defecto.
- Privacidad.
- Cerrar sesion.

## 6. Roadmap recomendado

### Fase 1 - Flujo core conectado

Prioridad alta.

1. Biblioteca real minima.
2. Conectar Nueva sesion con materiales reales.
3. Crear sesion real en backend desde mobile.
4. Navegar a Focus Mode con `sessionId`.
5. Mostrar datos reales de sesion en Focus Mode.

Resultado esperado:

> El usuario puede subir material, crear una sesion real y entrar al modo enfoque.

### Fase 2 - Sesion activa por metodo

Prioridad alta.

1. Generar assets de estudio por metodo.
2. UI de Focus Mode para Visual.
3. UI de Focus Mode para Escritura.
4. Base para Auditivo.
5. Timer real y lifecycle de sesion.

Resultado esperado:

> Durante el bloqueo, el usuario ve una experiencia de aprendizaje activa y no solo un temporizador.

### Fase 3 - Desbloqueo por aprendizaje

Prioridad alta.

1. UI de quiz.
2. Envio de respuestas.
3. Evaluacion IA.
4. Feedback inmediato.
5. Reglas de desbloqueo por nivel de reto.
6. Pantalla de resultados.

Resultado esperado:

> El celular se desbloquea cuando el estudiante demuestra aprendizaje.

### Fase 4 - Bloqueo Android real

Prioridad media/alta.

1. Servicio Android para monitorear app foreground.
2. Overlay de bloqueo.
3. Lista real de apps instaladas.
4. Configuracion de apps bloqueadas.
5. Manejo de emergencia.

Resultado esperado:

> Focus empieza a funcionar como bloqueador real en Android.

### Fase 5 - Progreso y retencion

Prioridad media.

1. Progreso real en Home.
2. Pantalla Progreso.
3. Historial de sesiones.
4. Recomendaciones.
5. Rachas y logros.

Resultado esperado:

> El usuario ve avance y motivos para volver.

### Fase 6 - Pulido y preparacion de presentacion

Prioridad media.

1. Branding final.
2. Icono/logo/personaje.
3. Microinteracciones.
4. Pitch universitario.
5. Demo controlada.
6. Politica de privacidad inicial.

Resultado esperado:

> Producto presentable para evento/startup universitaria.

## 7. Orden inmediato recomendado

El siguiente paso recomendado es:

> Biblioteca real minima + conexion de Nueva sesion al backend.

Por que:

- Home ya apunta a Nueva sesion.
- Nueva sesion ya necesita materiales reales.
- El backend ya tiene endpoints para materiales y sesiones.
- Es el puente entre UI bonita y producto funcional.

Secuencia concreta:

1. Implementar Biblioteca real con lista de materiales.
2. Implementar subida/seleccion de material desde mobile.
3. Conectar Nueva sesion a `materialRepository`.
4. Conectar boton final a `studySessionRepository.createSession`.
5. Pasar `sessionId` al Focus Mode.

## 8. Riesgos y decisiones pendientes

### Confirmacion de email

Supabase puede requerir confirmacion de correo.

Pendiente:

- Definir si en desarrollo se desactiva confirmacion.
- Mostrar pantalla "Revisa tu correo" si no hay sesion inmediata.

### Bloqueo Android

El bloqueo real puede requerir decisiones cuidadosas.

Pendiente:

- Definir si se usara solo Usage Access + Overlay inicialmente.
- Evaluar si Accesibilidad entra en una fase posterior.
- Evitar patrones que compliquen publicacion en Play Store.

### Audio

El modo auditivo puede empezar sin audio generado real.

Opcion inicial:

- Mostrar guion narrado en texto.
- Luego agregar TTS o audio generado.

### Modelo premium

No se debe implementar pago todavia.

Pero conviene preparar:

- Limites de sesiones.
- Limites de materiales.
- Flags de funciones premium.

## 9. Comandos utiles

### Mobile

```powershell
cd D:\CODE\App-Estudio\mobile
flutter analyze
flutter test
flutter build apk --debug
```

### Correr app con Supabase

```powershell
cd D:\CODE\App-Estudio\mobile

$envVars = @{}
Get-Content .env | Where-Object { $_ -match "=" } | ForEach-Object {
  $parts = $_ -split "=", 2
  $envVars[$parts[0]] = $parts[1]
}

flutter run -d emulator-5554 `
  --dart-define=API_BASE_URL=$($envVars.API_BASE_URL) `
  --dart-define=SUPABASE_URL=$($envVars.SUPABASE_URL) `
  --dart-define=SUPABASE_ANON_KEY=$($envVars.SUPABASE_ANON_KEY)
```

### Backend

```powershell
cd D:\CODE\App-Estudio\backend
uv run pytest
uv run ruff check app tests
```

## 10. Definicion de avance actual

Focus ya tiene:

- Identidad de producto clara.
- Flujo inicial real.
- Auth funcional.
- Permisos funcionales.
- Home profesional.
- Wizard de Nueva sesion profesional.
- Backend base.
- Supabase base.
- IA backend base.

Lo que falta para que se sienta como app completa:

- Materiales reales en mobile.
- Sesiones reales creadas desde mobile.
- Focus Mode activo.
- Desbloqueo por aprendizaje en UI.
- Bloqueo Android real.
- Progreso con datos reales.

Resumen:

> Ya tenemos el esqueleto y las primeras experiencias reales. Ahora toca conectar datos y convertir el flujo de estudio en una experiencia funcional end-to-end.
