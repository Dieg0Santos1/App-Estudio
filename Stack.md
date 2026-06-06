# Stack de Herramientas y Tecnologías para la App de Estudio con IA

## 1. Visión general del stack

La aplicación será una plataforma móvil de estudio con inteligencia artificial que permitirá al usuario bloquear distracciones del celular durante una sesión de estudio y, al finalizar, responder preguntas generadas por IA a partir de sus apuntes, PDFs, diapositivas o imágenes para poder desbloquear el dispositivo.

El objetivo no es crear una app básica, sino una aplicación totalmente funcional, con buena experiencia de usuario, diseño profesional, animaciones, sistema de bloqueo real, análisis de material académico, evaluación inteligente y seguimiento del progreso del estudiante.

---

# 2. Stack general recomendado

```txt
UX/UI:
- Figma
- Figma Make
- Google Stitch
- Rive
- LottieFiles
- Maze

Aplicación móvil:
- Flutter
- Dart
- Kotlin Android Native
- Platform Channels

Estado y navegación:
- Riverpod
- GoRouter

Animaciones:
- Rive
- Lottie
- Flutter Animate

Backend:
- Python
- FastAPI
- Docker

Base de datos:
- Supabase
- PostgreSQL
- pgvector

Storage:
- Supabase Storage

Autenticación:
- Supabase Auth

Inteligencia Artificial:
- OpenAI API
- Gemini API

OCR y procesamiento de documentos:
- PyMuPDF
- pdfplumber
- python-pptx
- python-docx
- Google Vision API
- Tesseract OCR
- Modelos multimodales con visión

Notificaciones:
- Firebase Cloud Messaging
- flutter_local_notifications

Analytics:
- Firebase Analytics
- PostHog

Errores y monitoreo:
- Sentry
- Firebase Crashlytics

Pagos y suscripciones:
- RevenueCat
- Google Play Billing
- Stripe

Deploy:
- Google Cloud Run
- Railway
- Render
- Supabase
- GitHub Actions

Testing y distribución:
- Firebase App Distribution
- Google Play Console Internal Testing
```

---

# 3. Diseño UX/UI

## 3.1. Figma

Figma será la herramienta principal para diseñar la interfaz profesional de la aplicación.

Se usará para:

* Crear el sistema de diseño.
* Diseñar las pantallas principales.
* Definir colores, tipografías, botones y componentes.
* Crear prototipos navegables.
* Diseñar estados de error, carga y éxito.
* Preparar el handoff para desarrollo.
* Organizar componentes reutilizables.
* Probar flujos antes de programar.

Figma será el centro visual del producto.

---

## 3.2. Figma Make

Figma Make puede ayudar a acelerar la creación de primeras versiones de interfaces o componentes mediante IA.

Se puede usar para:

* Generar ideas visuales.
* Explorar variantes de pantallas.
* Crear prototipos rápidos.
* Convertir ideas en interfaces iniciales.

No reemplaza el diseño final, pero ayuda a acelerar el proceso creativo.

---

## 3.3. Google Stitch

Google Stitch servirá para generar interfaces rápidamente a partir de prompts.

Se usará principalmente para:

* Crear ideas iniciales de pantallas.
* Explorar distintos estilos visuales.
* Generar diseños de login, home, concentración, desbloqueo y progreso.
* Obtener inspiración visual para luego refinar en Figma.

Flujo recomendado:

```txt
Stitch → Idea visual rápida → Figma → Diseño profesional final → Flutter
```

---

## 3.4. Rive

Rive será una herramienta clave para que la app tenga una experiencia premium.

Se usará para animaciones interactivas como:

* Animación del login.
* Esfera de concentración.
* Temporizador animado.
* Candado bloqueado/desbloqueado.
* Avatar de estudio.
* Medallas.
* Progreso de racha.
* Estados de IA analizando.
* Transiciones entre modo normal y modo concentración.

Ejemplo de estados animados:

```txt
Idle → Preparando sesión → Concentración activa → Tiempo completado → Evaluación IA → Desbloqueado
```

Rive permitirá que la app se sienta viva, moderna e interactiva.

---

## 3.5. LottieFiles

LottieFiles servirá para animaciones ligeras y rápidas de integrar.

Se usará para:

* Carga de archivos.
* IA analizando material.
* Check de archivo procesado.
* Sesión completada.
* Respuesta correcta.
* Respuesta incorrecta.
* Desbloqueo exitoso.
* Errores suaves.
* Estados vacíos.

Diferencia entre Rive y Lottie:

```txt
Rive = animaciones interactivas y avanzadas.
Lottie = animaciones ligeras, rápidas y decorativas.
```

---

## 3.6. Maze

Maze se puede usar para probar la experiencia de usuario antes de desarrollar toda la app.

Se usará para validar:

* Si el usuario entiende cómo iniciar una sesión.
* Si sabe subir archivos.
* Si comprende por qué debe otorgar permisos.
* Si la pantalla de bloqueo se siente útil o molesta.
* Si las preguntas generadas por IA se entienden.
* Si el flujo de desbloqueo es claro.

Esto ayudará a evitar crear una app visualmente bonita pero difícil de usar.

---

# 4. Aplicación móvil

## 4.1. Flutter

Flutter será el framework principal para desarrollar la aplicación móvil.

Se usará para:

* Crear interfaces modernas.
* Desarrollar pantallas responsive.
* Implementar animaciones.
* Conectar con el backend.
* Conectar con Supabase.
* Manejar navegación.
* Mostrar estadísticas.
* Integrar Rive y Lottie.
* Crear una experiencia visual premium.

Flutter permite avanzar rápido en la parte visual y construir una app con muy buena apariencia.

---

## 4.2. Dart

Dart será el lenguaje principal usado dentro de Flutter.

Se usará para:

* Lógica de interfaz.
* Manejo de estados.
* Consumo de APIs.
* Validaciones.
* Modelos de datos.
* Conexión con servicios.
* Manejo de formularios.
* Control de navegación.

---

## 4.3. Kotlin Android Native

Kotlin se usará para las funciones profundas de Android que Flutter no puede controlar completamente por sí solo.

Se usará para:

* Detectar apps abiertas.
* Bloquear apps distractoras.
* Manejar permisos del sistema.
* Crear servicios en segundo plano.
* Mantener activo el modo concentración.
* Mostrar pantallas de bloqueo.
* Usar APIs nativas de Android.
* Evitar que el usuario cierre fácilmente el modo concentración.

Esta parte es fundamental porque la app necesita controlar el uso del celular.

---

## 4.4. Platform Channels

Los Platform Channels permitirán conectar Flutter con Kotlin.

La arquitectura sería:

```txt
Flutter UI
   ↓
Platform Channels
   ↓
Kotlin Android Services
   ↓
Bloqueo de apps, permisos, servicios y control del sistema
```

Flutter se encargará de la interfaz y Kotlin de las funciones nativas.

---

# 5. Librerías principales para Flutter

## 5.1. Estado y navegación

```txt
flutter_riverpod
go_router
```

### Riverpod

Se usará para manejar el estado global de la app.

Ejemplos:

* Usuario autenticado.
* Sesión activa.
* Archivos subidos.
* Preguntas generadas.
* Progreso.
* Configuración del usuario.

### GoRouter

Se usará para manejar la navegación entre pantallas.

Ejemplos:

* Login.
* Home.
* Nueva sesión.
* Modo concentración.
* Desbloqueo por aprendizaje.
* Resultados.
* Biblioteca.
* Perfil.

---

## 5.2. Consumo de APIs

```txt
dio
```

Dio se usará para conectar la app móvil con el backend.

Permitirá:

* Enviar archivos.
* Obtener preguntas.
* Enviar respuestas.
* Recibir resultados.
* Consultar historial.
* Obtener estadísticas.

---

## 5.3. Supabase en Flutter

```txt
supabase_flutter
```

Se usará para:

* Login.
* Registro.
* Sesiones de usuario.
* Conexión con la base de datos.
* Subida de archivos.
* Lectura de datos.
* Gestión de perfil.

---

## 5.4. Archivos y permisos

```txt
file_picker
permission_handler
```

### file_picker

Permitirá seleccionar archivos del celular:

* PDFs.
* Imágenes.
* Documentos.
* Diapositivas.
* Notas.

### permission_handler

Permitirá solicitar permisos como:

* Acceso a archivos.
* Notificaciones.
* Uso de aplicaciones.
* Accesibilidad.
* Superposición de pantalla.

---

## 5.5. Notificaciones

```txt
flutter_local_notifications
firebase_messaging
```

Se usarán para:

* Avisar que la sesión empezó.
* Avisar que la sesión terminó.
* Recordar estudiar.
* Notificar desbloqueo pendiente.
* Enviar recordatorios de racha.

---

## 5.6. Animaciones

```txt
rive
lottie
flutter_animate
```

Se usarán para:

* Login animado.
* Carga de archivos.
* IA analizando.
* Temporizador visual.
* Modo concentración.
* Desbloqueo.
* Resultados.
* Medallas y logros.

---

## 5.7. Gráficos y estadísticas

```txt
fl_chart
syncfusion_flutter_charts
```

Se usarán para mostrar:

* Horas estudiadas.
* Progreso semanal.
* Precisión en preguntas.
* Rachas.
* Temas más estudiados.
* Rendimiento por curso.
* Sesiones completadas.

---

# 6. Funciones nativas de Android

Para el bloqueo real del celular, se necesitará usar APIs y servicios nativos.

## 6.1. UsageStatsManager

Permitirá detectar qué aplicación está usando el usuario.

Se usará para:

* Saber si el usuario abrió una app bloqueada.
* Detectar intentos de distracción.
* Registrar apps más intentadas durante una sesión.
* Activar la pantalla de bloqueo si corresponde.

---

## 6.2. AccessibilityService

Permitirá tener mayor control sobre la interacción del usuario con otras apps.

Se usará para:

* Detectar cambios de ventana.
* Interceptar apertura de apps bloqueadas.
* Redirigir al usuario a la pantalla de concentración.
* Mostrar advertencias cuando intenta romper el enfoque.

Esta función debe usarse con mucho cuidado y transparencia, explicando bien al usuario por qué se necesita.

---

## 6.3. ForegroundService

Permitirá mantener activa la sesión de concentración aunque la app esté en segundo plano.

Se usará para:

* Mantener el temporizador activo.
* Evitar que el bloqueo se detenga.
* Mostrar una notificación persistente.
* Mantener el modo concentración funcionando.

---

## 6.4. Overlay Permission

Permitirá mostrar una pantalla encima cuando el usuario intente abrir una app bloqueada.

Ejemplo:

```txt
Estás en modo concentración.
Te quedan 24:12.
Vuelve a tu sesión y sigue avanzando.
```

---

## 6.5. DevicePolicyManager

Se puede usar para modos más estrictos, aunque requiere mayor cuidado.

Podría servir para:

* Bloqueo avanzado.
* Modo tipo kiosk.
* Mayor control sobre el dispositivo.

Para una primera versión completa, se puede evaluar si realmente es necesario.

---

## 6.6. WorkManager y AlarmManager

Se usarán para tareas programadas y control del tiempo.

Ejemplos:

* Mantener sesiones aunque la app esté en segundo plano.
* Programar recordatorios.
* Restaurar el estado después de reiniciar.
* Sincronizar datos pendientes.

---

# 7. Backend

## 7.1. Python

Python será el lenguaje principal del backend.

Es ideal para:

* Procesamiento de archivos.
* IA.
* Extracción de texto.
* OCR.
* Generación de preguntas.
* Evaluación de respuestas.
* Análisis de progreso.

---

## 7.2. FastAPI

FastAPI será el framework del backend.

Se usará para crear endpoints como:

```txt
/auth
/materials
/sessions
/questions
/answers
/progress
/achievements
/billing
/ai
```

Ventajas:

* Rápido.
* Ordenado.
* Documentación automática.
* Fácil integración con Python.
* Ideal para APIs modernas.
* Compatible con Docker.

---

## 7.3. Docker

Docker se usará para empaquetar el backend y desplegarlo de forma más controlada.

Permitirá:

* Crear entornos consistentes.
* Facilitar despliegues.
* Evitar problemas de dependencias.
* Preparar la app para producción.

---

# 8. Servicios internos del backend

La arquitectura del backend puede dividirse en servicios.

```txt
MaterialService
QuestionGeneratorService
AnswerEvaluatorService
ProgressService
LockSessionService
RecommendationService
AchievementService
BillingService
```

## 8.1. MaterialService

Se encargará de:

* Recibir archivos.
* Extraer texto.
* Guardar material.
* Dividir contenido por temas.
* Limpiar información.
* Preparar texto para IA.

---

## 8.2. QuestionGeneratorService

Se encargará de:

* Generar preguntas.
* Crear opciones.
* Crear respuestas correctas.
* Definir dificultad.
* Relacionar preguntas con el material original.

---

## 8.3. AnswerEvaluatorService

Se encargará de:

* Evaluar respuestas.
* Comparar significado.
* Detectar respuestas parcialmente correctas.
* Generar feedback.
* Calcular puntaje.

---

## 8.4. ProgressService

Se encargará de:

* Calcular horas estudiadas.
* Guardar estadísticas.
* Medir precisión.
* Detectar temas débiles.
* Generar recomendaciones.

---

## 8.5. RecommendationService

Se encargará de sugerir:

* Qué tema estudiar.
* Qué archivo repasar.
* Qué conceptos reforzar.
* Qué tipo de preguntas practicar.

---

## 8.6. AchievementService

Se encargará de:

* Rachas.
* Logros.
* Medallas.
* Niveles.
* Recompensas.

---

## 8.7. BillingService

Se encargará de:

* Plan gratuito.
* Plan premium.
* Límites de uso.
* Suscripciones.
* Validación de pagos.

---

# 9. Base de datos y almacenamiento

## 9.1. Supabase

Supabase será una opción ideal porque permite manejar varias partes del proyecto en una sola plataforma.

Se usará para:

* Autenticación.
* Base de datos PostgreSQL.
* Storage de archivos.
* Seguridad con RLS.
* APIs rápidas.
* Gestión de usuarios.
* Datos de progreso.

---

## 9.2. PostgreSQL

PostgreSQL será la base de datos principal.

Se usará para guardar:

* Usuarios.
* Sesiones.
* Materiales.
* Preguntas.
* Respuestas.
* Historial.
* Estadísticas.
* Logros.
* Configuración.
* Apps bloqueadas.

---

## 9.3. Supabase Storage

Se usará para almacenar:

* PDFs.
* Imágenes.
* Diapositivas.
* Documentos.
* Archivos del usuario.

---

## 9.4. pgvector

pgvector permitirá guardar embeddings del contenido estudiado.

Esto servirá para:

* Buscar información dentro del material.
* Generar preguntas más precisas.
* Relacionar conceptos.
* Encontrar fragmentos relevantes.
* Mejorar la calidad de la IA.

---

# 10. Inteligencia Artificial

## 10.1. OpenAI API

OpenAI se puede usar para:

* Generar preguntas.
* Evaluar respuestas.
* Dar feedback.
* Crear resúmenes.
* Detectar conceptos débiles.
* Generar explicaciones.
* Crear simulacros.

---

## 10.2. Gemini API

Gemini se puede usar para:

* Analizar contenido multimodal.
* Leer imágenes.
* Interpretar diapositivas.
* Procesar apuntes visuales.
* Apoyar en OCR inteligente.
* Generar preguntas desde contenido visual.

---

## 10.3. Arquitectura recomendada para IA

No se debe conectar la IA directamente desde Flutter. Lo ideal es que Flutter se comunique con el backend y el backend con la IA.

Flujo recomendado:

```txt
Flutter
   ↓
FastAPI
   ↓
OpenAI / Gemini
   ↓
FastAPI procesa la respuesta
   ↓
Flutter muestra el resultado
```

Esto permite:

* Proteger API keys.
* Controlar costos.
* Validar respuestas.
* Guardar historial.
* Cambiar de proveedor IA fácilmente.
* Evitar que el usuario manipule llamadas directas.

---

## 10.4. Capa de proveedores IA

Se recomienda crear una capa independiente para no depender de un solo proveedor.

```txt
AIProvider
- OpenAIProvider
- GeminiProvider
```

Funciones esperadas:

```txt
generateQuestions()
evaluateAnswer()
summarizeMaterial()
extractConcepts()
explainMistake()
recommendNextTopic()
```

---

# 11. Procesamiento de documentos y OCR

## 11.1. PDFs

Herramientas recomendadas:

```txt
PyMuPDF
pdfplumber
```

Se usarán para:

* Extraer texto.
* Leer páginas.
* Separar secciones.
* Procesar documentos académicos.

---

## 11.2. PowerPoint

Herramienta recomendada:

```txt
python-pptx
```

Se usará para:

* Leer diapositivas.
* Extraer títulos.
* Extraer contenido.
* Procesar presentaciones de clase.

---

## 11.3. Word

Herramienta recomendada:

```txt
python-docx
```

Se usará para:

* Leer documentos `.docx`.
* Extraer apuntes.
* Procesar informes o guías.

---

## 11.4. Imágenes y fotos de apuntes

Herramientas recomendadas:

```txt
Google Vision API
Tesseract OCR
OpenAI Vision
Gemini Vision
```

Para apuntes escritos a mano, es mejor usar modelos multimodales o Google Vision, ya que Tesseract puede fallar con letra manuscrita.

---

# 12. Notificaciones

## 12.1. Firebase Cloud Messaging

Se usará para notificaciones push.

Ejemplos:

* Recordatorios de estudio.
* Avisos de racha.
* Alertas de meta diaria.
* Mensajes de progreso.

---

## 12.2. Notificaciones locales

Se usarán para eventos dentro del dispositivo.

Ejemplos:

* Sesión iniciada.
* Sesión terminada.
* Desbloqueo disponible.
* Tiempo restante.
* Modo concentración activo.

---

# 13. Analytics y monitoreo

## 13.1. Firebase Analytics

Se usará para medir eventos importantes.

Ejemplos:

* Sesiones iniciadas.
* Sesiones completadas.
* Archivos subidos.
* Preguntas respondidas.
* Desbloqueos exitosos.
* Permisos aceptados o rechazados.

---

## 13.2. PostHog

PostHog se puede usar para análisis más avanzado del comportamiento del usuario.

Ejemplos:

* Funnels.
* Retención.
* Eventos personalizados.
* Análisis de uso.
* Grabaciones o mapas de comportamiento, si se habilitan.

---

## 13.3. Sentry

Sentry se usará para detectar errores en producción.

Ayuda a:

* Ver crashes.
* Detectar errores del backend.
* Identificar problemas por dispositivo.
* Mejorar estabilidad.

---

## 13.4. Firebase Crashlytics

Crashlytics se usará para detectar fallos en la app móvil.

Permitirá saber:

* Qué error ocurrió.
* En qué versión.
* En qué dispositivo.
* Cuántos usuarios fueron afectados.

---

# 14. Pagos y suscripciones

## 14.1. RevenueCat

RevenueCat puede facilitar el manejo de suscripciones móviles.

Se usará para:

* Plan premium.
* Validación de compras.
* Gestión de suscripciones.
* Integración con Google Play Billing.
* Control de acceso a funciones premium.

---

## 14.2. Google Play Billing

Se usará para compras dentro de Android.

Puede manejar:

* Suscripciones.
* Pagos únicos.
* Planes premium.

---

## 14.3. Stripe

Stripe se puede usar si más adelante se crea una versión web o panel externo.

Se usaría para:

* Pagos desde web.
* Planes institucionales.
* Suscripciones fuera de la app móvil.

---

# 15. Herramientas de desarrollo

## 15.1. VS Code

VS Code será el editor principal de desarrollo.

Se usará para:

* Flutter.
* Dart.
* Python.
* FastAPI.
* Kotlin.
* Supabase CLI.
* Docker.
* Git.
* Integración con IA de desarrollo.

Extensiones recomendadas:

```txt
Flutter
Dart
Kotlin
Python
Pylance
Docker
GitLens
Error Lens
REST Client
Thunder Client
Supabase
```

---

## 15.2. Android Studio

Aunque se use VS Code, Android Studio será necesario para:

* Android SDK.
* Emuladores.
* Herramientas de compilación.
* Configuración nativa Android.
* Pruebas en dispositivos.
* Revisión de permisos.

---

## 15.3. GitHub

GitHub se usará para:

* Control de versiones.
* Repositorio del proyecto.
* Issues.
* Pull requests.
* Documentación.
* GitHub Projects.
* Automatizaciones.

---

## 15.4. GitHub Actions

GitHub Actions se usará para CI/CD.

Ejemplos:

* Ejecutar tests.
* Revisar código.
* Construir backend.
* Desplegar a Cloud Run.
* Generar builds internas.

---

## 15.5. Fastlane

Fastlane se puede usar para automatizar tareas móviles.

Ejemplos:

* Generar builds.
* Subir versiones de prueba.
* Publicar en Google Play.
* Gestionar screenshots.
* Automatizar releases.

---

# 16. Deploy y distribución

## 16.1. Google Cloud Run

Google Cloud Run es una opción sólida para desplegar el backend en producción.

Se usará para:

* API FastAPI.
* Procesamiento IA.
* Servicios backend.
* Escalabilidad.

---

## 16.2. Railway o Render

Railway o Render pueden usarse para etapas iniciales o entornos de prueba.

Son más simples para empezar.

---

## 16.3. Firebase App Distribution

Se usará para distribuir versiones beta de la app a testers.

Ideal para:

* Pruebas internas.
* Feedback de estudiantes.
* Validar funciones antes de publicar.
* Revisar errores en dispositivos reales.

---

## 16.4. Google Play Console

Se usará para publicar la app en Google Play.

También permitirá:

* Testing interno.
* Testing cerrado.
* Testing abierto.
* Revisión de políticas.
* Publicación final.
* Gestión de fichas de la app.

---

# 17. Testing

## 17.1. Testing funcional

Se deben probar:

* Login.
* Registro.
* Subida de archivos.
* Análisis de material.
* Generación de preguntas.
* Evaluación de respuestas.
* Bloqueo de apps.
* Desbloqueo.
* Historial.
* Estadísticas.

---

## 17.2. Testing UX

Se debe probar con estudiantes reales.

Preguntas a validar:

* ¿Entienden el objetivo de la app?
* ¿Saben iniciar una sesión?
* ¿Saben subir material?
* ¿Entienden los permisos?
* ¿El bloqueo se siente útil o molesto?
* ¿Las preguntas son claras?
* ¿La retroalimentación ayuda?
* ¿Usarían la app de forma constante?

---

## 17.3. Testing de seguridad

Se debe probar:

* Protección de archivos.
* Acceso a datos.
* Reglas de Supabase.
* API keys.
* Autenticación.
* Control de sesiones.
* Intentos de manipulación del desbloqueo.
* Cierre forzado de la app.
* Reinicio del celular.
* Desinstalación durante una sesión.

---

# 18. Estructura sugerida del proyecto

## 18.1. Repositorios

Se puede trabajar con dos repositorios separados:

```txt
focusstudy-mobile
focusstudy-backend
```

También se puede usar un monorepo:

```txt
focusstudy-ai/
│
├── mobile/
│   └── Flutter app
│
├── backend/
│   └── FastAPI app
│
├── docs/
│   └── Documentación del proyecto
│
└── design/
    └── Referencias de diseño
```

---

## 18.2. Estructura móvil

```txt
mobile/
│
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   ├── features/
│   │   ├── auth/
│   │   ├── onboarding/
│   │   ├── home/
│   │   ├── study_session/
│   │   ├── focus_mode/
│   │   ├── unlock_quiz/
│   │   ├── progress/
│   │   ├── library/
│   │   └── profile/
│   ├── shared/
│   └── theme/
│
├── assets/
│   ├── images/
│   ├── animations/
│   └── icons/
│
└── android/
    └── app/src/main/kotlin/
```

---

## 18.3. Estructura backend

```txt
backend/
│
├── app/
│   ├── main.py
│   ├── routes/
│   ├── services/
│   ├── models/
│   ├── schemas/
│   ├── ai/
│   ├── documents/
│   ├── core/
│   └── utils/
│
├── requirements.txt
├── Dockerfile
├── .env.example
└── README.md
```

---

# 19. Flujo de trabajo recomendado

El flujo ideal sería:

```txt
1. Stitch
   Generar ideas visuales rápidas.

2. Figma
   Refinar diseño profesional y crear sistema visual.

3. Rive / Lottie
   Crear animaciones premium.

4. VS Code
   Desarrollar Flutter, backend, IA y lógica general.

5. Android Studio
   Configurar SDK, emuladores y partes nativas Android.

6. Supabase
   Crear base de datos, auth, storage y políticas.

7. Firebase / PostHog / Sentry
   Medir comportamiento, detectar errores y mejorar estabilidad.

8. Google Play Console
   Publicar la app.
```

---

# 20. Recomendación final del stack

Para una app totalmente funcional, seria y con buena experiencia, el stack recomendado sería:

```txt
Flutter + Dart para la app móvil.
Kotlin nativo para bloqueo real en Android.
FastAPI + Python para el backend.
Supabase para auth, base de datos y storage.
pgvector para búsqueda semántica del material.
OpenAI y Gemini para IA educativa.
Google Vision / OCR para imágenes y apuntes.
Rive y Lottie para animaciones premium.
Figma y Stitch para diseño UX/UI.
Firebase, PostHog, Sentry y Crashlytics para monitoreo.
RevenueCat y Google Play Billing para suscripciones.
Google Cloud Run para backend en producción.
GitHub Actions y Fastlane para automatización.
```

La idea no debe desarrollarse como una app simple, sino como una plataforma completa de estudio con enfoque, IA y validación del aprendizaje.

La propuesta de valor principal sería:

> **Demuestra que estudiaste para recuperar tu celular.**
