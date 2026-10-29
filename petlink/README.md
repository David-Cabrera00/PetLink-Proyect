# 🐾 PetLink

> **Conectando comunidades para reunir mascotas perdidas con sus familias.**

PetLink es un ecosistema móvil integral y colaborativo diseñado para reportar animales de compañía extraviados o encontrados, explorar reportes geoespaciales en tiempo real, recibir alertas tempranas de avistamientos y cruzar coincidencias inteligentes mediante algoritmos de proximidad y similitud física.

---

## 📑 Tabla de Contenidos

- [Visión General](#-visión-general)
- [Características Principales](#-características-principales)
- [Arquitectura de la Solución](#-arquitectura-de-la-solución)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Sistema de Diseño y UI/UX](#-sistema-de-diseño-y-uiux)
- [Soporte Multi-idioma y Accesibilidad](#-soporte-multi-idioma-y-accesibilidad)
- [Pila Tecnológica](#-pila-tecnológica)
- [Requisitos Previos](#-requisitos-previos)
- [Puesta en Marcha](#-puesta-en-marcha)
  - [1. Configuración del Backend (NestJS + Prisma)](#1-configuración-del-backend-nestjs--prisma)
  - [2. Configuración de la App Móvil (Flutter)](#2-configuración-de-la-app-móvil-flutter)
- [Variables de Entorno](#-variables-de-entorno)
- [API Endpoints Principales](#-api-endpoints-principales)
- [Calidad de Código y Pruebas](#-calidad-de-código-y-pruebas)
- [Licencia](#-licencia)

---

## 🌟 Visión General

La pérdida de una mascota es una experiencia angustiante donde los primeros minutos y horas resultan críticos. PetLink aborda esta problemática mediante:

1. **Inmediatez Geográfica**: Alertas basadas en la ubicación del dispositivo en un radio configurable de 5 km.
2. **Identificación Efectiva**: Fichas visuales estructuradas con rasgos distintivos, fotos en alta resolución, señas particulares y fecha/hora exacta.
3. **Cruce Inteligente (Matching)**: Detección automática entre reportes de mascotas perdidas y encontradas que comparten rasgos y cercanía espacial.
4. **Comunidad Activa**: Facilitación de avistamientos con un solo toque y contacto seguro con quien reportó.

---

## 🚀 Características Principales

### 📡 Radar Inteligente
- **Onda Expansiva Animada**: Visualización dinámica de monitoreo en tiempo real.
- **Resumen Comunitario**: Conteo automático de reportes activos en las últimas 24 horas dentro de un radio de 5 km.
- **Coincidencias Sugeridas**: Acceso inmediato a posibles mascotas encontradas que encajan con los reportes propios.

### 🗺️ Exploración en Mapa y Lista
- **Mapa Interactivo**: Basado en `flutter_map` con tiles vectoriales/raster rápidos (CartoDB / OpenStreetMap) y pines de estado codificados por color.
- **Lista de Tarjetas**: Visualización rápida con distancia calculada en kilómetros (`< 5 km`), dirección y badges de estado.
- **Filtros Dinámicos**: Filtrado instantáneo por *Todos*, *Perdidas*, *Encontradas* o *Cerca de ti*.
- **Búsqueda en Tiempo Real**: Filtrado reactivo por nombre, especie, raza o dirección.

### 📝 Creación de Reportes en 6 Pasos
Un flujo guiado con animaciones y stepper visual interactivo:
1. **Tipo de Reporte**: Selección ilustrada entre *Perdí a mi mascota* y *Encontré una mascota*.
2. **Datos de la Mascota**: Especie, raza, sexo, edad aproximada, tamaño y color, con previsualización en vivo estilo credencial reactiva.
3. **Fotografías**: Galería de hasta 3 fotos con marco tipo *Polaroid* y selector de cámara o galería.
4. **Ubicación Geográfica**: Selección precisa sobre el mapa con GPS automático y círculo de cobertura de alerta de 5 km.
5. **Detalles y Circunstancias**: Línea de tiempo interactiva con selector de fecha/hora y caja de señas particulares.
6. **Revisión y Publicación**: Vista previa en formato de póster editorial antes de su emisión y pantalla de celebración con ondas de emisión radial.

### 🔔 Notificaciones y Actividad
- **Línea de Tiempo Conectada**: Historial agrupado cronológicamente (*Hoy*, *Ayer*, *Hace X días*) con nodos iconográficos temáticos para avistamientos, coincidencias y actualizaciones de estado.
- **Lectura en Lote**: Opción de marcar todas las novedades como leídas con un solo clic.

### 🌗 Tema Adaptativo (Dark / Light Mode)
- **Sincronización Total**: Inversión contextual de contrastes (`PetTokens.bgOf`, `surfaceOf`, `inkOf`, `borderOf`).
- **Selector en Perfil**: Soporte para *Modo del Sistema*, *Claro* y *Oscuro* persistente mediante `SharedPreferences`.

### 🌐 Internacionalización Completa (i18n)
- Soporte nativo para **Español** e **Inglés**, con conmutación en caliente desde los ajustes de perfil.

---

## 🏛 Arquitectura de la Solución

El proyecto está estructurado como un monorepositorio modular desacoplado:

```mermaid
graph TD
    subgraph Cliente Móvil [Flutter Client]
        UI[UI / Screens / Widgets]
        State[Riverpod Providers]
        Router[GoRouter Navigation]
        Repo[Remote Repositories]
        Theme[PetTokens / PetTheme]
        i18n[AppLocalizations - es/en]
    end

    subgraph Backend [NestJS Server]
        API[REST API /api/v1]
        Auth[JWT & Guards]
        Prisma[Prisma ORM]
        Matching[Match Engine]
    end

    subgraph Servicios en la Nube [Cloud Infrastructure]
        Postgres[(PostgreSQL Database)]
        Storage[(Supabase Storage: pet-photos)]
    end

    UI --> State
    UI --> Theme
    UI --> i18n
    State --> Repo
    Repo --> API
    API --> Auth
    API --> Matching
    API --> Prisma
    Prisma --> Postgres
    API --> Storage
```

---

## 📁 Estructura del Proyecto

### Directorio `petlink/` (Frontend Flutter)

```text
petlink/
├── lib/
│   ├── app/                      # Raíz de la app, MaterialApp.router y GoRouter
│   │   ├── app.dart
│   │   ├── router.dart
│   │   └── widgets/
│   ├── core/                     # Red, constantes y motor de tokens visuales
│   │   ├── network/api_client.dart
│   │   └── theme/
│   │       ├── pet_tokens.dart   # Design tokens, tipografías y helpers temáticos
│   │       ├── pet_theme.dart    # Temas ThemeData.light y dark de Material 3
│   │       ├── pet_colors.dart
│   │       └── pet_typography.dart
│   ├── design_system/            # Componentes reutilizables de bajo nivel
│   │   ├── badges/
│   │   └── buttons/
│   ├── features/                 # Módulos funcionales organizados por dominio
│   │   ├── activity/             # Notificaciones y línea de tiempo
│   │   ├── auth/                 # Bienvenida, intro animada, login y registro
│   │   ├── explore/              # Mapa interactivo y listado de reportes
│   │   ├── matches/              # Detalle y comparación de coincidencias
│   │   ├── profile/              # Configuración de tema, idioma y cuenta
│   │   ├── radar/                # Radar de pulso geolocalizado de 5 km
│   │   └── reports/              # Hub de reportes y flujo de creación en 6 pasos
│   ├── l10n/                     # Recursos de localización (app_es.arb, app_en.arb)
│   └── shared/                   # Modelos de datos, repositorios remotos y widgets
│       ├── models/
│       ├── repositories/
│       └── widgets/
├── assets/                       # Ilustraciones y decoraciones vectoriales
├── test/                         # Pruebas unitarias y de widgets
└── pubspec.yaml                  # Dependencias y configuración de assets
```

### Directorio `../backend/` (Backend NestJS)

```text
backend/
├── prisma/
│   ├── schema.prisma             # Modelos de base de datos
│   └── seed.ts                   # Datos de prueba para desarrollo local
├── src/
│   ├── auth/                     # Autenticación JWT, guards y hashing Argon2/Bcrypt
│   ├── reports/                  # CRUD de reportes y carga de fotos multipart
│   ├── matches/                  # Algoritmo de emparejamiento geoespacial
│   ├── activity/                 # Historial de notificaciones
│   ├── favorites/                # Marcado de reportes favoritos
│   └── main.ts                   # Punto de entrada de la aplicación y CORS
└── package.json
```

---

## 🎨 Sistema de Diseño y UI/UX

PetLink cuenta con una identidad visual inspirada en tonos orgánicos y cálidos, combinando modernidad con calidez:

| Token | Hex Claro | Hex Oscuro | Uso Principal |
|---|---|---|---|
| **Ciruela (`plum`)** | `#4A2D4A` | `#8C638C` | Color primario de marca, botones principales, acento principal. |
| **Arcilla (`clay`)** | `#C86D51` | `#E07A5F` | Reportes de pérdida, pines de alerta, acciones de emergencia. |
| **Menta (`mint`)** | `#4B8B73` | `#589E84` | Mascotas encontradas, estados activos, éxito. |
| **Arena (`sand` / `bg`)** | `#F6EFE8` | `#141117` | Fondo principal de pantallas y contenedores raíz. |
| **Superficie (`surface`)** | `#FFFFFF` | `#1E1924` | Tarjetas elevadas, modales y hojas inferiores. |
| **Tinta (`ink`)** | `#2A1A29` | `#F8F2F6` | Títulos y texto de alto contraste. |
| **Muted (`muted`)** | `#8B7D8A` | `#B8AAB7` | Subtítulos, fechas secundarias y etiquetas auxiliares. |

### Tipografía
- **Fraunces (Weight 500, Italic opcional)**: Para encabezados editoriales, títulos destacados y nombres de mascotas.
- **Manrope (Weight 400, 600, 700)**: Para interfaz de usuario, formularios, etiquetas y lectura de cuerpo de texto.
- **Phosphor Icons**: Iconografía técnica y consistente en todo el sistema.

---

## 🛠 Pila Tecnológica

- **Framework**: [Flutter 3.x](https://flutter.dev/) (Dart 3.x)
- **Gestión de Estado**: [Riverpod 2.6](https://riverpod.dev/) (`StateNotifierProvider`, `AsyncValue`, `FutureProvider`)
- **Enrutamiento**: [GoRouter 14.x](https://pub.dev/packages/go_router) (Declarativo con soporte para `ShellRoute`)
- **Mapas**: [Flutter Map 8.x](https://pub.dev/packages/flutter_map) + [LatLong2](https://pub.dev/packages/latlong2)
- **Geolocalización**: [Geolocator 14.x](https://pub.dev/packages/geolocator)
- **Tipografías**: [Google Fonts](https://pub.dev/packages/google_fonts)
- **Almacenamiento Local**: [Shared Preferences](https://pub.dev/packages/shared_preferences) & [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- **Backend**: [NestJS](https://nestjs.com/) + [TypeScript](https://www.typescriptlang.org/)
- **ORM & BD**: [Prisma](https://www.prisma.io/) + [PostgreSQL](https://www.postgresql.org/) (Supabase)
- **Storage**: [Supabase Storage](https://supabase.com/storage) (bucket: `pet-photos`)

---

## 📋 Requisitos Previos

Asegúrate de contar con las siguientes herramientas instaladas:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versión 3.13.5 o superior).
- [Node.js](https://nodejs.org/) (versión 18.x o superior) y npm.
- Un emulador de Android/iOS o un dispositivo físico con depuración USB activa.
- Cuenta o proyecto en [Supabase](https://supabase.com/) con PostgreSQL y Storage configurados.

---

## ⚡ Puesta en Marcha

### 1. Configuración del Backend (NestJS + Prisma)

1. Ingresa a la carpeta del backend:
   ```bash
   cd backend
   ```
2. Instala las dependencias:
   ```bash
   npm install
   ```
3. Crea y configura tu archivo de entorno `.env` en la raíz de `backend/`:
   ```env
   DATABASE_URL="postgresql://usuario:password@host:5432/postgres?schema=public"
   DIRECT_URL="postgresql://usuario:password@host:5432/postgres?schema=public"
   JWT_ACCESS_SECRET="clave-secreta-jwt-super-segura"
   SUPABASE_URL="https://tu-proyecto.supabase.co"
   SUPABASE_SERVICE_ROLE_KEY="tu-supabase-service-role-key"
   SUPABASE_STORAGE_BUCKET="pet-photos"
   PORT=3000
   ```
4. Genera el cliente de Prisma y ejecuta las migraciones:
   ```bash
   npm run prisma:generate
   npm run prisma:migrate
   ```
5. *(Opcional)* Carga datos iniciales de prueba:
   ```bash
   npm run prisma:seed
   ```
6. Inicia el servidor de desarrollo:
   ```bash
   npm run start:dev
   ```
   > El servidor estará disponible en `http://localhost:3000/api/v1` y la documentación interactiva Swagger en `http://localhost:3000/docs`.

---

### 2. Configuración de la App Móvil (Flutter)

1. Ingresa a la carpeta de Flutter:
   ```bash
   cd petlink
   ```
2. Descarga las dependencias del proyecto:
   ```bash
   flutter pub get
   ```
3. Genera los archivos de localización:
   ```bash
   flutter gen-l10n
   ```
4. Ejecuta la aplicación:
   - **Con Backend conectado** (reemplaza por tu IP local para dispositivos físicos o emuladores):
     ```bash
     flutter run --dart-define=API_BASE_URL=http://192.168.1.35:3000/api/v1
     ```
   - **En Modo Mock (sin backend)**:
     ```bash
     flutter run
     ```
     > Si se omite la variable `API_BASE_URL`, PetLink arranca automáticamente en modo de prueba visual con datos mockeados.

---

## 🔒 Variables de Entorno

| Variable | Entorno | Descripción |
|---|---|---|
| `API_BASE_URL` | Flutter (`--dart-define`) | URL base del backend NestJS (ej. `http://192.168.1.35:3000/api/v1`). |
| `DATABASE_URL` | Backend (`.env`) | Cadena de conexión para Prisma (con connection pooling). |
| `DIRECT_URL` | Backend (`.env`) | Conexión directa a PostgreSQL para migraciones. |
| `JWT_ACCESS_SECRET` | Backend (`.env`) | Secreto para firmar tokens de sesión JWT. |
| `SUPABASE_URL` | Backend (`.env`) | Endpoint de la API de Supabase. |
| `SUPABASE_SERVICE_ROLE_KEY` | Backend (`.env`) | Clave con permisos para subir imágenes al bucket `pet-photos`. |
| `SUPABASE_STORAGE_BUCKET` | Backend (`.env`) | Nombre del bucket de almacenamiento (por defecto: `pet-photos`). |

---

## 🔌 API Endpoints Principales

Todos los endpoints tienen como prefijo `/api/v1`:

| Método | Endpoint | Descripción | Requiere Auth |
|---|---|---|:---:|
| `POST` | `/auth/register` | Registro de nuevos usuarios | No |
| `POST` | `/auth/login` | Autenticación y obtención de JWT | No |
| `GET` | `/auth/me` | Datos del usuario autenticado | Sí |
| `GET` | `/reports` | Listado público de reportes para el Radar y Explorar | No |
| `GET` | `/reports/mine` | Listado exclusivo de reportes creados por el usuario actual | Sí |
| `POST` | `/reports` | Creación de un nuevo reporte de mascota | Sí |
| `GET` | `/reports/:id` | Detalle exhaustivo de un reporte | No |
| `POST` | `/reports/:id/photos` | Carga de foto multipart a Supabase Storage | Sí |
| `GET` | `/reports/:id/sightings` | Listado de avistamientos recibidos | No |
| `POST` | `/reports/:id/sightings` | Registro de un nuevo avistamiento comunitario | Sí |
| `GET` | `/matches` | Coincidencias detectadas para los reportes del usuario | Sí |
| `GET` | `/activity` | Línea de tiempo de notificaciones y eventos | Sí |

---

## 🧪 Calidad de Código y Pruebas

El proyecto cuenta con un conjunto de análisis estático y pruebas automatizadas:

```bash
# Analizar código con las reglas de linter activas
flutter analyze

# Ejecutar la suite de tests unitarios y de widgets
flutter test

# Formatear el código según las convenciones de Dart
dart format lib test
```

---

## 📄 Licencia

Este proyecto está licenciado bajo la **Licencia MIT**. Consulta el archivo `LICENSE` para más información.
