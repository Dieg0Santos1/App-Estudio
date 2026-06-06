# Proyecto de App de Estudio con IA y Bloqueo Inteligente

## 1. Idea general de la aplicación

La aplicación busca ayudar a los estudiantes a concentrarse mientras estudian, evitando distracciones del celular y validando que realmente hayan aprendido el tema.

La idea principal es:

> Una app que bloquea el celular durante una sesión de estudio y, al finalizar, genera preguntas con IA a partir de los apuntes, diapositivas o archivos subidos por el usuario. Para desbloquear el celular, el usuario debe responder correctamente.

No debe verse solo como una app que bloquea aplicaciones, sino como:

> **Una plataforma de estudio con enfoque, control y validación del aprendizaje mediante IA.**

---

## 2. Flujo principal del usuario

El flujo base de la aplicación sería:

1. El usuario abre la app.
2. Ve una introducción u onboarding.
3. Inicia sesión o se registra.
4. Otorga los permisos necesarios.
5. Entra a la pantalla principal.
6. Toca el botón para iniciar una nueva sesión de estudio.
7. Escribe o selecciona el tema principal.
8. Sube sus archivos, imágenes, diapositivas o apuntes.
9. Selecciona el tiempo de estudio.
10. Inicia el modo concentración.
11. El celular bloquea apps distractoras.
12. Termina el tiempo de estudio.
13. Se activa el botón para desbloquear.
14. El usuario responde preguntas generadas por IA.
15. La app valida sus respuestas.
16. Si responde bien, desbloquea el celular.
17. Si responde mal, debe repasar o responder nuevas preguntas.
18. Finalmente, ve sus resultados y progreso.

---

## 3. Interfaces principales de la app

## 3.1. Onboarding / Bienvenida

Antes del login, la app debería mostrar una pequeña introducción de 2 o 3 pantallas.

### Objetivo

Explicar rápidamente qué hace la app y por qué es útil.

### Pantallas sugeridas

#### Pantalla 1

**Título:** Convierte tu celular en una herramienta de estudio

**Mensaje:**  
Estudia sin distracciones y mantén el foco durante el tiempo que tú elijas.

#### Pantalla 2

**Título:** Sube tus apuntes, PDFs o diapositivas

**Mensaje:**  
La IA analiza tu material y prepara preguntas personalizadas para ti.

#### Pantalla 3

**Título:** Desbloquea aprendiendo

**Mensaje:**  
Al terminar la sesión, responde preguntas sobre el tema para recuperar el acceso completo a tu celular.

---

## 3.2. Login / Registro

El login no debería ser el típico formulario aburrido. Debe sentirse moderno, interactivo y conectado con la idea de concentración.

### Elementos recomendados

- Logo o nombre de la app.
- Ilustración suave relacionada con estudio, concentración o IA.
- Frase motivadora.
- Botón para iniciar sesión con Google.
- Campo para correo.
- Campo para contraseña.
- Botón de iniciar sesión.
- Enlace para crear cuenta.
- Enlace para recuperar contraseña.

### Frases posibles

- “Bienvenido a tu zona de enfoque.”
- “Hoy no estudias por obligación, estudias por progreso.”
- “Menos distracción, más aprendizaje.”
- “Tu celular se desbloquea cuando tu mente avanza.”

### Registro inicial

Al crear cuenta, la app podría pedir:

- Nombre.
- Correo.
- Contraseña.
- Meta diaria de estudio.
- Modo preferido:
  - Ligero.
  - Normal.
  - Estricto.

---

## 3.3. Pantalla de permisos iniciales

Esta pantalla es muy importante porque la app necesitará permisos especiales para funcionar bien, especialmente en Android.

### Permisos necesarios

- Acceso a archivos.
- Acceso a imágenes.
- Notificaciones.
- Acceso de uso de aplicaciones.
- Permiso de accesibilidad.
- Permiso de superposición de pantalla.
- Permiso para bloquear o restringir aplicaciones.

### Cómo debe presentarse

No se deben pedir permisos de manera fría. La app debe explicar por qué necesita cada uno.

### Ejemplos

**Acceso a archivos:**  
Necesitamos este permiso para analizar tus PDFs, diapositivas, imágenes o apuntes.

**Acceso de uso de aplicaciones:**  
Nos permite detectar cuándo intentas abrir una app distractora durante tu sesión.

**Accesibilidad:**  
Ayuda a bloquear apps seleccionadas mientras estudias.

**Notificaciones:**  
Te avisaremos cuando tu sesión termine o cuando debas responder tus preguntas.

---

## 3.4. Pantalla principal / Home

Esta es la vista que el usuario ve ni bien entra a la app. Debe ser limpia, motivadora y directa.

La pantalla principal debe responder estas tres preguntas:

1. ¿Cómo voy?
2. ¿Qué estudié?
3. ¿Qué hago ahora?

### Elementos recomendados

#### Encabezado

- Saludo personalizado.
- Avatar o foto.
- Racha de estudio.
- Tiempo estudiado hoy.

Ejemplo:

> Hola, Alexander  
> ¿Listo para una sesión de enfoque?

#### Tarjeta principal

Debe tener un botón grande y claro:

> **Iniciar sesión de estudio**

#### Bloques secundarios

- Última sesión.
- Material reciente.
- Progreso semanal.
- Recomendación de IA.
- Temas más estudiados.
- Sesiones completadas.

### Ejemplo de contenido

#### Última sesión

- Tema: Programación Orientada a Objetos.
- Duración: 45 minutos.
- Resultado: 80% correcto.

#### Progreso semanal

- 5 sesiones completadas.
- 4 horas estudiadas.
- 85% de precisión en preguntas.

#### Recomendación IA

> Te recomiendo repasar “Herencia y Polimorfismo”, ya que fallaste 2 preguntas relacionadas.

---

## 3.5. Nueva sesión de estudio

Esta es la pantalla donde el usuario configura su sesión.

La estructura recomendada sería:

1. Tema principal.
2. Selección de archivos, imágenes o notas.
3. Lista de material cargado.
4. Selección de duración.
5. Opciones de evaluación.
6. Apps a bloquear.
7. Botón de iniciar.

---

### 3.5.1. Tema principal

Debe ir arriba de todo.

Ejemplo:

**Tema principal**  
Programación Orientada a Objetos

Puede ser un campo de texto o un selector si ya existen temas guardados.

---

### 3.5.2. Selección de material

Después del tema, debe venir el botón para cargar material.

### Tipos de material permitidos

- PDF.
- PPT o diapositivas.
- Imágenes.
- Fotos de cuaderno.
- Notas del celular.
- Texto pegado manualmente.
- Documentos Word.
- Archivos Markdown.

### Botón sugerido

> **Seleccionar archivos de estudio**

También puede haber botones separados:

- Subir PDF.
- Subir imagen.
- Escribir nota.
- Usar material reciente.

---

### 3.5.3. Lista de archivos cargados

Después de seleccionar los archivos, se debe mostrar una lista.

Cada archivo puede tener:

- Icono del tipo de archivo.
- Nombre.
- Tamaño.
- Estado de carga.
- Botón para eliminar.
- Indicador de análisis IA.

Ejemplo:

- POO_Resumen.pdf — 2.4 MB — Analizado.
- Diapositivas_POO.pptx — 5.1 MB — Analizando.
- Apuntes_Clases.jpg — 1.2 MB — Listo.

---

### 3.5.4. Selector de tiempo

Debe permitir seleccionar una duración.

### Opciones sugeridas

- 15 min.
- 30 min.
- 45 min.
- 60 min.
- 90 min.
- Personalizado.

Para empezar, se puede usar:

- 30 min.
- 60 min.
- 90 min.

---

### 3.5.5. Opciones de evaluación

La app debería permitir elegir cómo será el desbloqueo.

### Tipos de preguntas

- Selección múltiple.
- Verdadero o falso.
- Respuesta corta.
- Respuesta argumentativa.
- Evaluación mixta.

### Dificultad

- Fácil.
- Media.
- Difícil.

### Número de preguntas

- 3 preguntas.
- 5 preguntas.
- 10 preguntas.

---

### 3.5.6. Apps a bloquear

Esta opción es importante porque no todos quieren bloquear lo mismo.

### Opciones

- TikTok.
- Instagram.
- Facebook.
- YouTube.
- Juegos.
- Navegadores.
- Apps seleccionadas manualmente.

También se puede tener una opción rápida:

> Bloquear apps distractoras automáticamente

---

### 3.5.7. Botón de inicio

El botón principal debe ser claro:

> **Iniciar sesión**

Antes de iniciar, se puede mostrar una confirmación:

> Durante esta sesión no podrás acceder a las apps bloqueadas hasta completar el tiempo y responder las preguntas.

---

## 3.6. Modo concentración activado

Esta es una de las pantallas más importantes de la app.

### Objetivo

Mostrar que la sesión está activa y que el celular está en modo de enfoque.

### Elementos principales

- Tema actual.
- Temporizador grande.
- Progreso circular.
- Mensaje motivacional.
- Apps bloqueadas.
- Estado de la sesión.
- Botón de pausa.
- Botón de emergencia.
- Botón para finalizar antes, si se permite.

### Ejemplo de contenido

**Modo concentración activado**  
Tema: Programación Orientada a Objetos

**Tiempo restante:**  
42:18

**Mensaje:**  
Enfocado y avanzando.

**Apps distractoras bloqueadas:**  
No podrás acceder a estas apps hasta completar la sesión.

---

### Botones posibles

#### Pausar

Permite pausar temporalmente, según el modo elegido.

#### Emergencia

Permite salir en caso de necesidad real.

#### Finalizar antes

Puede estar bloqueado, tener penalización o pedir confirmación.

---

### Modos de concentración

#### Modo ligero

Permite pausar y salir con advertencia.

#### Modo normal

Permite salir, pero se pierde la sesión.

#### Modo estricto

No permite salir hasta terminar el tiempo o usar emergencia.

---

## 3.7. Pantalla de sesión completada

Antes de pasar al cuestionario, conviene mostrar una pantalla intermedia.

### Objetivo

Hacer que el usuario sienta que completó una etapa.

### Elementos

- Mensaje de logro.
- Tiempo estudiado.
- Tema estudiado.
- Material analizado.
- Botón para desbloquear.

### Ejemplo

**¡Sesión completada!**

Estudiaste 45 minutos sobre:

> Programación Orientada a Objetos

Tu material fue analizado por IA. Ahora responde algunas preguntas para desbloquear tu celular.

Botón:

> **Desbloquear ahora**

---

## 3.8. Desbloqueo por aprendizaje

Esta pantalla valida que el usuario realmente estudió.

### Elementos principales

- Título: Desbloqueo por aprendizaje.
- Barra de progreso.
- Número de pregunta.
- Pregunta generada por IA.
- Opciones o campo de respuesta.
- Botón para verificar.
- Feedback después de responder.

---

### Tipos de pregunta

#### Selección múltiple

Ejemplo:

**Pregunta 2 de 5**  
¿Qué es el polimorfismo?

A. La capacidad de una clase para heredar de varias clases a la vez.  
B. La capacidad de diferentes clases de responder al mismo método de distintas formas.  
C. El proceso de ocultar los detalles internos de un objeto.  
D. La creación de múltiples objetos a partir de una misma clase.

Botón:

> Verificar respuesta

---

#### Respuesta argumentativa

Ejemplo:

**Explica con tus propias palabras qué es la herencia en programación orientada a objetos.**

Campo de respuesta:

> Escribe tu respuesta aquí...

Botón:

> Evaluar respuesta

---

### Evaluación con IA

La IA no debe evaluar solo si el texto coincide exactamente. Debe evaluar el significado.

### Criterios

- Comprensión del concepto.
- Uso correcto de términos.
- Claridad de la explicación.
- Relación con el material subido.
- Nivel de detalle.

---

### Feedback recomendado

No debe limitarse a decir “correcto” o “incorrecto”.

Debe explicar brevemente.

Ejemplo:

**Correcto.**  
El polimorfismo permite que distintas clases respondan al mismo método de diferentes maneras.

Ejemplo de respuesta casi correcta:

**Casi correcto.**  
Tu respuesta menciona la reutilización, pero faltó explicar que diferentes clases pueden implementar el mismo método con comportamientos distintos.

---

### Reglas de desbloqueo

La app puede tener distintos niveles.

#### Fácil

Debe responder 3 de 5 preguntas.

#### Normal

Debe responder 4 de 5 preguntas.

#### Estricto

Debe responder correctamente el 80% o más.

---

### Si falla

Si el usuario no logra desbloquear:

- Puede estudiar 5 o 10 minutos más.
- Puede responder nuevas preguntas.
- Puede revisar un resumen del tema.
- Puede ver los conceptos que debe reforzar.

---

## 3.9. Pantalla de resultados

Después del cuestionario, debe aparecer una pantalla final.

### Elementos

- Puntaje.
- Porcentaje correcto.
- Tiempo estudiado.
- Tema.
- Preguntas correctas.
- Preguntas incorrectas.
- Conceptos a repasar.
- Botón para revisar respuestas.
- Botón para volver al inicio.
- Botón para iniciar otra sesión.

### Ejemplo

**Resultado de sesión**

Tema: Programación Orientada a Objetos  
Duración: 45 minutos  
Preguntas correctas: 4 de 5  
Precisión: 80%

**Conceptos a reforzar:**

- Herencia.
- Encapsulamiento.

Botones:

- Revisar respuestas.
- Nueva sesión.
- Volver al inicio.

---

## 3.10. Biblioteca / Materiales

Esta interfaz permite al usuario revisar todo el material que ha subido.

### Elementos

- Lista de archivos.
- Filtros por tema.
- Filtros por fecha.
- Buscador.
- Carpetas o categorías.
- Estado de análisis IA.
- Botón para eliminar.
- Botón para reutilizar en nueva sesión.

### Categorías posibles

- PDFs.
- Diapositivas.
- Imágenes.
- Apuntes.
- Notas.
- Temas guardados.

---

## 3.11. Historial de sesiones

Esta pantalla ayuda al usuario a ver lo que ya estudió.

### Elementos

- Fecha.
- Tema.
- Duración.
- Material usado.
- Porcentaje de aciertos.
- Estado de desbloqueo.
- Botón para ver detalle.

### Ejemplo

**12 de junio**  
Tema: Base de Datos  
Duración: 60 min  
Resultado: 90%  
Estado: Desbloqueado al primer intento

---

## 3.12. Estadísticas / Progreso

Esta pantalla le da valor a largo plazo a la aplicación.

### Métricas recomendadas

- Horas estudiadas por día.
- Horas estudiadas por semana.
- Horas estudiadas por mes.
- Sesiones completadas.
- Racha de estudio.
- Precisión promedio.
- Temas más estudiados.
- Preguntas falladas por tema.
- Tasa de desbloqueo al primer intento.

### Visualizaciones

- Gráfico semanal.
- Calendario de racha.
- Barras por tema.
- Porcentaje de avance.
- Ranking de temas dominados.

---

## 3.13. Revisión de respuestas

Esta interfaz es muy importante para que la app no sea solo una herramienta de bloqueo, sino una herramienta real de aprendizaje.

### Elementos

- Pregunta.
- Respuesta del usuario.
- Respuesta correcta o esperada.
- Explicación.
- Archivo de origen.
- Concepto relacionado.
- Botón para volver a estudiar ese tema.

### Ejemplo

**Pregunta:**  
¿Qué es el polimorfismo?

**Tu respuesta:**  
Es cuando varias clases usan métodos.

**Respuesta esperada:**  
Es la capacidad de diferentes clases para responder al mismo método de distintas formas.

**Explicación:**  
El polimorfismo permite que un mismo método tenga diferentes comportamientos dependiendo de la clase que lo implemente.

---

## 3.14. Perfil / Configuración

Esta pantalla permite personalizar la experiencia.

### Elementos

- Nombre.
- Foto o avatar.
- Meta diaria.
- Apps bloqueadas por defecto.
- Modo de estudio preferido.
- Dificultad por defecto.
- Número de preguntas por defecto.
- Idioma.
- Tema visual.
- Notificaciones.
- Privacidad.
- Cerrar sesión.

### Opciones importantes

#### Modo de bloqueo

- Ligero.
- Normal.
- Estricto.

#### Tipo de evaluación

- Selección múltiple.
- Respuesta corta.
- Respuesta argumentativa.
- Mixto.

#### Apariencia

- Modo claro.
- Modo oscuro.
- Sistema.

---

## 4. Navegación recomendada

La app podría tener una navegación inferior con cuatro secciones principales:

1. Inicio.
2. Biblioteca.
3. Progreso.
4. Perfil.

La opción de nueva sesión puede estar como botón principal flotante o como botón destacado en el Home.

### Navegación sugerida

- **Inicio:** resumen, progreso rápido y botón de nueva sesión.
- **Biblioteca:** materiales subidos.
- **Progreso:** estadísticas e historial.
- **Perfil:** configuración y preferencias.

---

## 5. Colores y estilo visual

La app debe transmitir concentración, calma, tecnología y aprendizaje.

### Paleta recomendada

#### Color principal

- Azul navy oscuro.
- Representa concentración, seguridad y profesionalismo.

#### Color secundario

- Verde teal.
- Representa progreso, tecnología y tranquilidad.

#### Color de apoyo

- Blanco.
- Para tarjetas limpias y legibles.

#### Colores de alerta

- Amarillo suave.
- Naranja suave.
- Rojo moderado solo para errores o advertencias.

### Estilo visual

- Interfaz moderna.
- Bordes redondeados.
- Tarjetas limpias.
- Iconos minimalistas.
- Buen espaciado.
- Tipografía clara.
- Modo oscuro como opción principal.
- Animaciones suaves.

---

## 6. Aspectos importantes del proyecto

## 6.1. Empezar por Android

Para un MVP, lo más recomendable es empezar con Android.

### Motivo

Android permite mayor control del sistema en comparación con iOS.

En Android se puede trabajar mejor con:

- Accessibility Services.
- Usage Access.
- Device Admin.
- Kiosk Mode.
- Bloqueo de aplicaciones.
- Superposición de pantalla.
- Control de apps abiertas.

iOS es mucho más restrictivo para este tipo de funcionalidad.

---

## 6.2. Definir bien el MVP

No conviene construir todo desde el inicio. Primero debe hacerse una versión mínima funcional.

### MVP recomendado

1. Login.
2. Home.
3. Crear sesión.
4. Subir material.
5. Temporizador de concentración.
6. Bloqueo básico de apps distractoras.
7. Generación de preguntas con IA.
8. Evaluación de respuestas.
9. Desbloqueo según resultado.
10. Historial básico.

Con esto ya se tendría un producto funcional y atractivo.

---

## 6.3. Funciones principales de IA

La IA debe cumplir funciones específicas.

### 1. Leer el material

Debe poder procesar:

- PDFs.
- PPT.
- Imágenes.
- Fotos de cuaderno.
- Notas escritas.
- Texto pegado.

### 2. Extraer información

Debe identificar:

- Conceptos principales.
- Definiciones.
- Ejemplos.
- Títulos.
- Subtemas.
- Palabras clave.

### 3. Generar preguntas

Debe crear:

- Preguntas de selección múltiple.
- Preguntas abiertas.
- Verdadero o falso.
- Completar espacios.
- Preguntas argumentativas.

### 4. Evaluar respuestas

Debe evaluar:

- Si la respuesta es correcta.
- Si es parcialmente correcta.
- Si falta información.
- Si hay conceptos confundidos.
- Si la explicación tiene sentido.

### 5. Dar retroalimentación

Debe entregar:

- Explicación breve.
- Corrección.
- Conceptos a repasar.
- Sugerencias para mejorar.

---

## 6.4. Casos límite que se deben considerar

Para que el proyecto sea serio, hay que pensar en situaciones reales.

### Casos importantes

- ¿Qué pasa si el usuario cierra la app?
- ¿Qué pasa si apaga el celular?
- ¿Qué pasa si intenta abrir una app bloqueada?
- ¿Qué pasa si entra una llamada?
- ¿Qué pasa si necesita WhatsApp por emergencia?
- ¿Qué pasa si no tiene internet?
- ¿Qué pasa si el archivo subido no se puede leer?
- ¿Qué pasa si la IA no logra generar preguntas?
- ¿Qué pasa si el usuario responde mal muchas veces?
- ¿Qué pasa si el usuario reinicia el celular?
- ¿Qué pasa si intenta desinstalar la app durante una sesión?

---

## 6.5. No debe sentirse como castigo

Aunque la app bloquee distracciones, no debe sentirse como una prisión.

Debe sentirse como:

- Acompañamiento.
- Progreso.
- Reto.
- Disciplina inteligente.
- Apoyo académico.

### Para lograrlo

- Usar colores tranquilos.
- Mostrar mensajes motivadores.
- Dar recompensas.
- Mostrar progreso.
- Evitar mensajes agresivos.
- Dar feedback útil.
- Permitir modo emergencia.

---

## 6.6. Privacidad y seguridad

La app manejará información sensible del usuario, como apuntes, PDFs, imágenes y notas.

### Se debe considerar

- Almacenamiento seguro.
- Cifrado de archivos.
- Política de privacidad.
- Consentimiento del usuario.
- Eliminación de archivos.
- Explicar si los archivos se procesan con IA en la nube.
- No usar el material del usuario sin permiso.

---

## 6.7. Gamificación

La gamificación puede hacer que la app sea más atractiva.

### Ideas

- Rachas de estudio.
- Niveles.
- Medallas.
- Puntos de enfoque.
- Logros semanales.
- Ranking personal.
- Avatares desbloqueables.
- Sesiones perfectas.
- Retos diarios.
- Recompensas por estudiar varios días seguidos.

### Ejemplos de logros

- Primera sesión completada.
- 7 días de racha.
- 10 horas estudiadas.
- 5 desbloqueos al primer intento.
- 100 preguntas respondidas.
- 90% de precisión semanal.

---

## 6.8. Modelo de negocio

La app podría funcionar con un modelo freemium.

### Plan gratuito

- 2 sesiones al día.
- Archivos limitados.
- Preguntas básicas.
- Estadísticas simples.
- Bloqueo básico de apps.

### Plan premium

- Sesiones ilimitadas.
- Archivos ilimitados.
- IA avanzada.
- Preguntas argumentativas.
- Evaluación más profunda.
- Estadísticas completas.
- Resúmenes automáticos.
- Recomendaciones personalizadas.
- Modos estrictos avanzados.

---

## 7. Tecnologías sugeridas

## 7.1. Aplicación móvil

### Opción recomendada

- Flutter.

### Alternativas

- React Native.
- Kotlin nativo para Android.

Si el bloqueo de apps es muy profundo, Kotlin nativo puede ser más conveniente para la parte Android.

---

## 7.2. Backend

Opciones:

- Python con FastAPI.
- Node.js con Express o NestJS.

Para IA y procesamiento de documentos, Python puede ser más cómodo.

---

## 7.3. Base de datos

Opciones:

- Supabase.
- PostgreSQL.
- Firebase.

Supabase es una buena opción para MVP porque permite:

- Autenticación.
- Base de datos PostgreSQL.
- Storage para archivos.
- APIs rápidas.
- Escalabilidad inicial.

---

## 7.4. IA

Opciones:

- OpenAI API.
- Gemini API.
- Modelos locales en el futuro.

Funciones de IA:

- Resumir material.
- Generar preguntas.
- Evaluar respuestas.
- Generar retroalimentación.
- Detectar conceptos débiles.

---

## 7.5. Procesamiento de archivos

Para PDFs:

- PyMuPDF.
- pdfplumber.

Para PPT:

- python-pptx.

Para imágenes:

- OCR.
- Google Vision.
- Tesseract.
- Modelos multimodales.

Para documentos:

- docx.
- markdown.
- texto plano.

---

## 8. Base de datos sugerida

Tablas iniciales:

### users

- id.
- name.
- email.
- created_at.
- daily_goal_minutes.
- preferred_mode.

### study_materials

- id.
- user_id.
- title.
- file_type.
- file_url.
- extracted_text.
- created_at.

### study_sessions

- id.
- user_id.
- topic.
- duration_minutes.
- started_at.
- ended_at.
- status.
- score.
- unlock_status.

### session_materials

- id.
- session_id.
- material_id.

### questions

- id.
- session_id.
- question_text.
- question_type.
- options.
- correct_answer.
- explanation.
- difficulty.

### user_answers

- id.
- question_id.
- user_id.
- answer_text.
- is_correct.
- score.
- feedback.

### blocked_apps

- id.
- user_id.
- app_name.
- package_name.
- default_blocked.

### achievements

- id.
- user_id.
- achievement_name.
- description.
- unlocked_at.

---

## 9. Pantallas mínimas para el MVP

Para empezar, las pantallas mínimas deberían ser:

1. Onboarding.
2. Login / registro.
3. Permisos.
4. Home.
5. Nueva sesión.
6. Modo concentración.
7. Sesión completada.
8. Desbloqueo por aprendizaje.
9. Resultados.
10. Historial básico.
11. Biblioteca básica.
12. Perfil / configuración básica.

---

## 10. Prompt base para diseñar interfaces en Stitch

```text
Diseña una aplicación móvil moderna llamada FocusStudy AI. Es una app de estudio con inteligencia artificial que bloquea distracciones del celular durante una sesión de estudio y, al finalizar, genera preguntas basadas en los apuntes, PDFs, diapositivas o imágenes subidas por el usuario para desbloquear el celular.

Usa una paleta de colores calmada y tecnológica: azul navy oscuro, verde teal, blanco, gris claro y pequeños acentos en amarillo suave para alertas. El diseño debe verse premium, estudiantil, moderno y confiable.

Crea una interfaz limpia, con tarjetas redondeadas, iconos minimalistas, buen espaciado, modo oscuro elegante y microinteracciones visuales. La app debe sentirse como una herramienta de enfoque y aprendizaje, no como una app de castigo.

Incluye las siguientes pantallas:
1. Onboarding.
2. Login interactivo.
3. Pantalla de permisos.
4. Home principal.
5. Nueva sesión de estudio.
6. Modo concentración activado.
7. Sesión completada.
8. Desbloqueo por aprendizaje.
9. Resultados de sesión.
10. Biblioteca de materiales.
11. Historial y progreso.
12. Perfil y configuración.
