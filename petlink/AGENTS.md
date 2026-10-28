# AGENTS.md — PetLink

## Propósito

PetLink es una aplicación Flutter para reportar mascotas perdidas o encontradas, explorar reportes cercanos, registrar avistamientos y detectar posibles coincidencias.

El proyecto incluye:

- Aplicación Flutter en `petlink/`.
- Backend NestJS en `backend/`.
- PostgreSQL gestionado por Supabase mediante Prisma.
- Almacenamiento de fotos en Supabase Storage.
- Autenticación JWT.

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

Desde `backend/`:

```powershell
npm install
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
npm run build
npm run start:dev
```

El backend se sirve con el prefijo `/api/v1` y Swagger está disponible en `/docs`.

## Variables de entorno

El backend usa `backend/.env`. Nunca versionar este archivo ni pegar sus secretos en el chat.

Variables principales:

```env
DATABASE_URL=...
DIRECT_URL=...
JWT_ACCESS_SECRET=...
SUPABASE_URL=...
SUPABASE_SERVICE_ROLE_KEY=...
SUPABASE_STORAGE_BUCKET=pet-photos
OPENROUTER_API_KEY=...
OPENROUTER_MODEL=...
```

`OPENROUTER_API_KEY` es opcional y actualmente solo se usa por el endpoint experimental de análisis de imágenes. No colocar claves en Flutter, Git, `README.md` ni archivos `.example`.

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

## Backend y API

El backend NestJS usa Prisma y JWT.

Endpoints principales:

- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/me`
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

## Fotos y Supabase Storage

El bucket esperado es `pet-photos`. El backend recibe la foto en multipart con el campo `file`, la sube a Supabase Storage y persiste la URL en Prisma.

El bucket debe existir. La clave `SUPABASE_SERVICE_ROLE_KEY` solo puede vivir en el backend.

## Coincidencias

El backend calcula coincidencias reales entre reportes activos de tipos opuestos, usando especie, raza, color y distancia. Flutter usa `RemoteMatchRepository` cuando `API_BASE_URL` está configurada y usa mock únicamente sin backend configurado.

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

Los textos visibles deben agregarse a `lib/l10n/app_es.arb` y `app_en.arb`; actualizar los archivos generados cuando corresponda.

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

## Estado actual

Funcionando:

- Autenticación real con JWT y Supabase/PostgreSQL.
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

Pendiente:

- Push en segundo plano con FCM/APNs.
- Integrar automáticamente el análisis de IA al subir fotos.
- Mejorar el algoritmo de coincidencias con atributos visuales.
- Pruebas automatizadas más completas.
- Configuración de producción y despliegue del backend.
