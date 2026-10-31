# AGENTS.md — PetLink

## Propósito

PetLink es una aplicación Flutter para reportar mascotas perdidas o encontradas, explorar reportes cercanos, registrar avistamientos y detectar posibles coincidencias.

El proyecto incluye:

- Aplicación Flutter en `petlink/`.
- Backend NestJS en `backend/`.
- PostgreSQL gestionado por Supabase mediante Prisma.
- Almacenamiento de fotos en Supabase Storage.
- Autenticación JWT con access token corto y refresh token.

El repositorio Git se trabaja normalmente desde `petlink/`, aunque `backend/` es un directorio hermano incluido en el mismo repositorio padre.

## Comandos principales

Desde `petlink/`:

```powershell
flutter pub get
flutter run -d RF8R32JL3GE --dart-define=API_BASE_URL=http://192.168.1.35:3000/api/v1
flutter analyze
flutter test
dart format lib test
```

Formatear solo los archivos tocados (`dart format lib/features/...`) evita mezclar cambios de formato con trabajo pendiente de otras personas.

Desde `backend/`:

```powershell
npm install
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
npm run build
npm run start:dev
```

`npm run build` genera `dist/main.js` (gracias a `rootDir` e `include` en `tsconfig.json`) y `npm start` lo ejecuta. Si el build vuelve a generar `dist/src/main.js`, `npm start` fallará en producción.

El backend se sirve con el prefijo `/api/v1` y Swagger está disponible en `/docs`.

## Variables de entorno

El backend usa `backend/.env`. Nunca versionar este archivo ni pegar sus secretos en el chat.

Variables principales:

```env
NODE_ENV=development
PORT=3000
DATABASE_URL=...
DIRECT_URL=...
JWT_ACCESS_SECRET=...
JWT_ACCESS_TTL=15m
JWT_REFRESH_SECRET=...
JWT_REFRESH_TTL=60d
CORS_ORIGINS=http://localhost:3000,http://localhost:8080
RATE_LIMIT_TTL_MS=60000
RATE_LIMIT_MAX=30
SUPABASE_URL=...
SUPABASE_SERVICE_ROLE_KEY=...
SUPABASE_STORAGE_BUCKET=pet-photos
OPENROUTER_API_KEY=...
OPENROUTER_MODEL=...
```

`RATE_LIMIT_TTL_MS` y `RATE_LIMIT_MAX` controlan el throttling del backend; el cliente traduce un `429` a “Demasiados intentos. Espera un momento”.

`OPENROUTER_API_KEY` es opcional y actualmente solo se usa por el endpoint experimental de análisis de imágenes. No colocar claves en Flutter, Git, `README.md` ni archivos `.example`.

`JWT_REFRESH_SECRET` es opcional en desarrollo (si falta se usa `JWT_ACCESS_SECRET`), pero en producción debe ser distinto. `JWT_ACCESS_TTL` y `JWT_REFRESH_TTL` aceptan el formato de `jsonwebtoken` (`15m`, `60d`).

## Arquitectura Flutter

La aplicación usa Flutter, Material 3, Riverpod y GoRouter.

```text
lib/
├── app/                 # Aplicación y navegación
├── core/                # Red, permisos, constantes y tema
├── design_system/       # Botones, inputs, badges y componentes base
├── features/
│   ├── auth/            # Login, registro e intro
│   ├── activity/        # Actividad/notificaciones en la app
│   ├── explore/         # Lista, mapa y filtros públicos
│   ├── matches/         # Detalle de coincidencias
│   ├── profile/         # Perfil y preferencias
│   ├── radar/           # Reportes cercanos y coincidencias
│   └── reports/         # Flujo de creación, detalle y avistamientos
└── shared/
    ├── models/
    ├── repositories/
    └── widgets/
```

Las pantallas no deben acceder directamente a HTTP. Usar `ApiClient`, interfaces de repositorio y providers de Riverpod.

## Navegación actual

| Ruta | Pantalla |
|---|---|
| `/intro` | Intro |
| `/welcome` | Bienvenida |
| `/login` | Inicio de sesión |
| `/register` | Registro |
| `/radar` | Radar |
| `/explore` | Explorar reportes en mapa/lista |
| `/reports` | Reportes |
| `/reports/mine` | Reportes propios |
| `/reports/:id` | Detalle de reporte |
| `/reports/:id/sighting` | Formulario de avistamiento |
| `/matches/:id` | Detalle de coincidencia |
| `/activity` | Actividad |
| `/profile` | Perfil |

Flujo de creación:

```text
/report/new
→ /report/new/pet-info
→ /report/new/photos
→ /report/new/location
→ /report/new/details
→ /report/new/review
→ /report/new/published
```

Dentro de rutas del `ShellRoute`, preferir `context.go('/radar')` o una ruta explícita al volver. Evitar `Navigator.pop()` cuando pueda dejar una pantalla sin ruta válida.

Rutas públicas: `/intro`, `/welcome`, `/login`, `/register` y `/forgot-password`. Cualquier otra exige sesión; los deep links a reportes o coincidencias redirigen a `/welcome`.

## Sesión y red

La autenticación usa dos tokens:

- `accessToken`: 15 min por defecto (`JWT_ACCESS_TTL`). Va en `Authorization: Bearer`.
- `refreshToken`: 60 días por defecto (`JWT_REFRESH_TTL`). Se guarda en `flutter_secure_storage`.
- `POST /auth/refresh` recibe `{ refreshToken }` y devuelve `{ user, accessToken, refreshToken }`.
- Los JWT incluyen el claim `typ` (`access`/`refresh`); el guard rechaza un refresh usado como access.

`ApiClient` (`lib/core/network/api_client.dart`) centraliza la red:

- Ante un `401` intenta refrescar y reintenta la petición original una vez.
- Varias peticiones simultáneas comparten un único refresh (`_refreshInFlight`).
- Si el refresh es inválido (400/401/403), borra la sesión y llama a `onSessionExpired`.
- Si el refresh falla por red o timeout, **no** borra la sesión: se reintenta en la siguiente petición.
- Los `GET` reintentan una vez ante timeout (mitiga el arranque en frío de Render, que puede superar los 30 s).
- `ApiException` expone `kind` (`http`, `network`, `timeout`), `isUnauthorized`, `isNetworkError` e `isTimeout`. Las pantallas deben mostrar `apiErrorMessage(l10n, error)` en lugar de interpolar `$error`.

`AuthNotifier` (`lib/features/auth/providers/auth_provider.dart`):

- Guarda access/refresh y cachea el usuario en `petlink_user` para restaurar la sesión sin red.
- Al arrancar muestra el perfil cacheado y luego valida con `GET /auth/me`.
- Solo cierra la sesión cuando el backend confirma que el token ya no sirve.
- Login y registro propagan el error para que la pantalla muestre un SnackBar.
- En release, sin `API_BASE_URL` lanzan un error visible; en debug simulan sesión.

Datos por usuario:

- `currentUserEmailProvider` expone el email autenticado.
- Todo provider que consulte datos personales (radar, explore, reports, activity) debe observarlo y devolver vacío si es `null`. Esto invalida cachés al cambiar de cuenta y evita llamadas sin sesión después de cerrar sesión.
- En tests hay que sobrescribir `currentUserEmailProvider` (ver `test/activity_providers_test.dart` y `test/explore_providers_test.dart`); de lo contrario los providers devuelven vacío.

Mocks:

- Solo se usan en debug (`kDebugMode`) y sin `API_BASE_URL`.
- En release, sin `API_BASE_URL` la app falla de forma visible en lugar de mostrar datos falsos. Compilar siempre con `--dart-define=API_BASE_URL=...`.

Flujos deshabilitados a propósito:

- Google Sign-In: el botón muestra “Google Sign-In aún no está disponible”.
- Recuperar contraseña: el enlace se ocultó porque el backend no envía correos. La pantalla sigue en el repo, pero no debe prometer un envío real.

## Backend y API

El backend NestJS usa Prisma y JWT.

Endpoints principales:

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `GET /auth/me`
- `PATCH /auth/me`
- `POST /auth/me/avatar`
- `PATCH /auth/password`
- `GET /reports`
- `GET /reports/mine`
- `GET /reports/:id`
- `POST /reports`
- `PATCH /reports/:id`
- `DELETE /reports/:id`
- `POST /reports/:id/photos`
- `GET /reports/:reportId/sightings`
- `POST /reports/:reportId/sightings`
- `DELETE /reports/:reportId/sightings/:id`
- `GET /matches`
- `GET /favorites`
- `POST /favorites/:reportId`
- `DELETE /favorites/:reportId`
- `GET /activity`
- `POST /ai/analyze-image` experimental

Los reportes propios se consultan mediante `/reports/mine`. Radar y Explorar muestran reportes públicos de la comunidad.

La eliminación está protegida en dos niveles:

1. La interfaz solo muestra “Eliminar” si `isOwner` es verdadero.
2. El backend verifica `ownerId` antes de eliminar.

### Compilación y despliegue

- `backend/tsconfig.json` usa `rootDir: ./src` e `include: ["src/**/*.ts"]`; el build genera `dist/main.js` y `npm start` funciona.
- Si aparece `dist/src/main.js`, se rompió `rootDir`/`include` o hay archivos TS fuera de `src`.
- Build en Render: `npm ci && npx prisma generate && npm run build`; después `npx prisma migrate deploy`.
- Variables nuevas en Render: `JWT_REFRESH_SECRET` (distinto de access) y, opcionalmente, `JWT_ACCESS_TTL` / `JWT_REFRESH_TTL`.
- El free tier de Render duerme por inactividad; el arranque en frío puede superar el timeout del cliente. Evaluar instancia paga o keep-alive.

## Fotos y Supabase Storage

El bucket esperado es `pet-photos`. El backend recibe la foto en multipart con el campo `file`, la sube a Supabase Storage y persiste la URL en Prisma.

El bucket debe existir. La clave `SUPABASE_SERVICE_ROLE_KEY` solo puede vivir en el backend.

## Coincidencias

El backend calcula coincidencias reales entre reportes activos de tipos opuestos, usando especie, raza, color y distancia. Flutter usa `RemoteMatchRepository` cuando `API_BASE_URL` está configurada y usa mock solo en debug sin backend configurado.

Las distancias visibles deben limitarse a dos decimales. No mostrar rasgos inventados: el detalle usa el color y `traits` registrados en el reporte; si no existen, mostrar “No especificado”.

## Ubicación y permisos

La aplicación usa ubicación en primer plano para Radar y Explorar. Si el usuario no concede permiso, no inventar una ciudad: mostrar “Ubicación no disponible”.

Permisos actuales:

- Ubicación mientras se usa la aplicación.
- Cámara.
- Galería/fotos mediante `image_picker`.
- Notificaciones mediante `permission_handler`.

No pedir Wi-Fi, contactos, micrófono, Bluetooth ni ubicación en segundo plano salvo que una funcionalidad futura lo requiera.

El permiso de notificaciones está preparado, pero Firebase/FCM todavía no está integrado. Para push con la aplicación cerrada se necesitarán las configuraciones de Android/iOS y un proveedor push.

## IA

Está preparado un endpoint experimental `POST /api/v1/ai/analyze-image` compatible con OpenRouter para analizar una URL pública de imagen y devolver atributos JSON.

La integración automática al publicar fotos todavía no debe considerarse terminada. La clave no debe exponerse. Si se requiere una solución sin API externa, evaluar un modelo local como Ollama/Qwen2.5-VL o un modelo on-device; ambos tienen compromisos de rendimiento y despliegue.

## Formularios

- Validar antes de avanzar entre pasos.
- Hacer `trim()` en datos textuales antes de enviarlos.
- No permitir espacios en contraseñas.
- No aceptar campos obligatorios vacíos.
- Mantener límites razonables de longitud.
- Los datos no deben aparecer en la interfaz si no fueron introducidos por el usuario.

## Diseño

Usar los tokens de `core/theme/` y los componentes de `design_system/`. Mantener compatibilidad con tema claro/oscuro, Material 3, áreas táctiles amplias y textos localizados.

Los textos visibles deben agregarse a `lib/l10n/app_es.arb` y `app_en.arb`; actualizar los archivos generados cuando corresponda. Ejecutar `flutter gen-l10n` después de editar los ARB.

Claves incorporadas para sesión y red: `errorGeneric`, `errorNoConnection`, `errorTimeout`, `errorServer`, `errorTooManyRequests`, `authInvalidCredentials`, `authEmailInUse`, `authSessionExpired`, `authGoogleUnavailable`.

## Git

No incluir:

- `backend/.env`.
- `.idea/` y caches del IDE.
- `build/` y `.dart_tool/`.
- Reportes generados de Gradle.
- Registrantes generados de Flutter, salvo que un cambio de plugin requiera versionarlos.

Separar commits por responsabilidad, por ejemplo:

```text
feat(backend): ...
feat(auth): ...
feat(reports): ...
feat(radar): ...
feat(notifications): ...
```

Antes de cada commit revisar:

```powershell
git diff --check
git status --short
git diff --cached --stat
```

El agente no ejecuta `git add`, `git commit` ni `git push`: propone archivos, orden y mensajes, y el usuario aplica los commits. No descartar cambios del working tree sin confirmarlo.

## Estado actual

Funcionando:

- Autenticación real con JWT, refresh token y sesión persistente.
- Creación de reportes.
- Subida y visualización de fotos.
- Reportes propios separados por usuario.
- Eliminación protegida por propietario.
- Compartir reportes.
- Contacto por correo.
- Avistamientos.
- Radar y Explorar.
- Coincidencias conectadas al backend.
- Ubicación y permisos principales.
- Permiso de notificaciones.

Cambios recientes ya implementados:

- Actividad conectada al backend con reportes y notificaciones persistentes de avistamientos.
- Las notificaciones de avistamiento muestran la descripción escrita por la persona.
- El detalle del reporte muestra avistamientos con descripción, fecha, ubicación y foto.
- Perfil con cambio de nombre y foto persistida en Supabase Storage.
- Saludo del Radar dinámico según la hora local y el idioma.
- Reportes propios identificados mediante `isOwner`; Radar excluye los propios y Explorar ofrece `Mis reportes`.
- Los marcadores propios usan un color diferente y los propietarios no pueden enviarse avistamientos a sí mismos.
- Las fotos principales del detalle se muestran completas con `BoxFit.contain`, sin recorte.
- Marcar notificaciones como leídas y abrirlas desde Actividad hacia el reporte correspondiente, con indicador de no leídos en la barra de navegación y sincronización en backend.
- Refresh tokens con renovación automática y cierre de sesión solo si el refresh es inválido.
- Restauración de sesión offline con perfil cacheado; los errores de red ya no cierran la sesión.
- Errores de login/registro visibles (credenciales, correo en uso, red, timeout, 429, 5xx).
- Todas las rutas privadas protegidas, incluidos deep links a reportes y coincidencias.
- Cachés por usuario en Radar, Explorar, Reportes y Actividad mediante `currentUserEmailProvider`.
- Sin mocks en release: los repositorios fallan de forma visible si falta `API_BASE_URL`.
- Build del backend corregido (`dist/main.js`) y `*.tsbuildinfo` ignorado.
- Google Sign-In y recuperación de contraseña ya no simulan funcionar.
- **Prevención de reportes duplicados por fallo de fotos (Fase 1):** `RemotePetReportRepository.createReport` captura fallos al subir fotos individuales; si alguna falla lanza `PartialReportUploadException` con el `PetReport` ya creado en base de datos. `ReportReviewScreen` limpia el borrador, invalida cachés, redirige a `/reports/:id` y notifica al usuario con el mensaje localizado `reportPublishedMissingPhotos`. Cubierto con pruebas unitarias en `test/report_repository_test.dart`.

Pendiente (priorizado):

1. **Localización completa (Fase 2):** Mover a los ARB todos los textos hardcodeados en español (radar, reportes, perfil y ajustes).
2. **Pruebas de sesión y red (Fase 3):** Inyectar `http.Client` en `ApiClient` y testear 401 → refresh → reintento, refresh inválido → logout, error de red → conservar sesión, timeout/retry.
3. **Firma y publicación del APK + Render (Fase 4):** `applicationId` definitivo, keystore, `key.properties`, `signingConfigs` de release, variables en Render y migración.
4. **Features externas (Fase 5):** Recuperación de contraseña real (email provider), Google Sign-In real (OAuth), push con FCM/APNs, IA automática al subir fotos y algoritmo de matching visual.

## Plan de trabajo acordado y estado de fases

- [x] **Fase 0 — Base limpia:** Working tree commiteado y ordenado en ramas lógicas.
- [x] **Fase 1 — Reportes sin duplicados:** `PartialReportUploadException`, navegación directa al reporte, borrador limpio y test de desconexión en 2da foto.
- [ ] **Fase 2 — Localización completa:** Inventario y extracción de strings a ARB es/en.
- [ ] **Fase 3 — Pruebas de sesión y red:** Blindaje HTTP/Auth con inyección de cliente HTTP y almacenamiento fake.
- [ ] **Fase 4 — APK release + Render:** Keystore, build de release y configuración de despliegue.
- [ ] **Fase 5 — Features externas:** Recuperación de contraseña, OAuth Google, FCM push, IA.

## Estado del working tree (2026-10-31)

Hay cambios sin commitear ni push. Mezclan dos trabajos:

1. Migración de tema oscuro a `PetTokens`, iniciada antes de esta sesión (los 18 archivos que ya estaban modificados).
2. Correcciones de sesión, red y flujos descritas en este documento (backend + Flutter).

No se hizo `git add` ni commit. `dart format` normalizó indentación en varios archivos ya modificados, así que el diff de tema incluye ajustes de formato; se revirtieron los archivos que no tenían cambios previos.

Verificación de esta sesión: `flutter analyze` limpio, `flutter test` 6/6, backend `npm run build` y arranque OK. Probados en local: `POST /auth/refresh` con token inválido → 401, login con credenciales malas → 401 y `GET /auth/me` sin token → 401.

Próximo paso acordado: decidir entre (a) preparar el plan de commits o (b) corregir primero los reportes duplicados por fallo de fotos y los textos sin traducir.
