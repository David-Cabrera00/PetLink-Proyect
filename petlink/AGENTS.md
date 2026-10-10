# AGENTS.md — PetLink

## Propósito

PetLink es una aplicación Flutter para reportar mascotas perdidas o encontradas y ayudar a encontrar coincidencias cercanas. El proyecto está en una fase funcional de prototipo: las pantallas, navegación, estado y datos de demostración están implementados, pero la persistencia y la conexión con el backend todavía no están integradas.

## Alcance de este documento

Estas instrucciones aplican a todo el paquete Flutter ubicado en `petlink/`. El repositorio padre (`C:\proyectos-flutter`) puede contener configuración del IDE, pero el código de la aplicación y sus comandos se ejecutan desde `petlink/`.

## Stack y configuración

- Flutter/Dart.
- SDK de Dart declarado: `^3.13.5`.
- Material 3.
- `flutter_riverpod` `^2.6.1` para estado e inyección de dependencias.
- `go_router` `^14.8.1` para navegación.
- `google_fonts` `^6.2.1`; la tipografía principal es Manrope.
- `cupertino_icons` `^1.0.8`.
- `flutter_lints` `^6.0.0` en desarrollo.
- Nombre del paquete: `petlink`.
- Versión declarada: `1.0.0+1`.
- El paquete no se publica en pub.dev (`publish_to: none`).
- Plataformas generadas presentes: Android, iOS, macOS, Linux, Windows y Web.

## Comandos de desarrollo

Ejecutar desde `petlink/`:

```bash
flutter pub get
flutter run
flutter analyze
flutter test
dart format lib test
```

Antes de entregar cambios:

1. Ejecutar `dart format lib test` sobre los archivos Dart modificados.
2. Ejecutar `flutter analyze`.
3. Ejecutar `flutter test`.
4. Si se cambia navegación o UI, probar al menos el flujo afectado en una plataforma disponible.

El análisis usa `package:flutter_lints/flutter.yaml` y excluye `build/`, `android/`, `ios/`, `web/`, `windows/`, `macos/` y `linux/`. No agregar silenciosamente excepciones de lint; corregir el código o documentar de forma puntual el motivo.

## Arranque de la aplicación

`lib/main.dart` inicia la aplicación con un `ProviderScope` global y monta `PetLinkApp`.

`lib/app/app.dart` configura:

- título `PetLink`;
- tema claro y oscuro de `PetTheme`;
- modo de tema desde `themeModeProvider`;
- `MaterialApp.router` con `AppRouter.router`;
- banner de depuración desactivado.
- locale controlado por `localeProvider`, con español como idioma inicial e inglés disponible.

## Arquitectura y reglas de organización

El código Dart está organizado por responsabilidad:

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── router.dart
├── core/
│   ├── constants/
│   ├── network/
│   └── theme/
├── design_system/
│   ├── badges/
│   ├── buttons/
│   ├── cards/
│   ├── chips/
│   └── inputs/
├── features/
│   ├── activity/
│   ├── explore/
│   ├── matches/
│   ├── profile/
│   ├── radar/
│   └── reports/
└── shared/
    ├── models/
    ├── repositories/
    └── widgets/
```

Reglas para nuevos cambios:

- Mantener cada funcionalidad dentro de `features/<feature>/`.
- Dejar modelos reutilizables en `shared/models/`.
- Usar interfaces de repositorio en `shared/repositories/` y no acceder a datos desde una pantalla directamente.
- Registrar los repositorios y estados con providers de Riverpod.
- Poner componentes reutilizables de UI en `shared/widgets/` o `design_system/` según corresponda.
- Usar tokens de `core/theme/`; evitar colores, radios y espaciados arbitrarios en las pantallas.
- Mantener las pantallas enfocadas en composición y eventos de UI; la lógica de estado debe vivir en providers/notifiers.
- Preferir widgets pequeños, `const` cuando sea posible y nombres en inglés consistentes con el código existente.
- Los textos visibles de la aplicación están principalmente en español.

## Navegación

La navegación está en `lib/app/router.dart` y usa `GoRouter`. La ruta inicial es `/radar`.

### Rutas principales

| Ruta | Pantalla | Propósito |
|---|---|---|
| `/radar` | `RadarScreen` | Resumen de reportes cercanos y coincidencias. |
| `/explore` | `ExploreScreen` | Explorar reportes en el área y filtrarlos. |
| `/reports` | `ReportsScreen` | Listar reportes propios. |
| `/reports/:id` | `ReportDetailScreen` | Ver el detalle de un reporte. |
| `/matches/:id` | `MatchDetailScreen` | Ver el detalle de una coincidencia. |
| `/activity` | `ActivityScreen` | Actividad/notificaciones; actualmente es una pantalla de base. |
| `/profile` | `ProfileScreen` | Perfil y selección del tema. |
| `/welcome` | `WelcomeScreen` | Entrada de usuarios no autenticados. |
| `/login` | `LoginScreen` | Inicio de sesión mock. |
| `/register` | `CreateAccountScreen` | Registro local/mock. |
| `/forgot-password` | `ForgotPasswordScreen` | Recuperación visual/mock. |

### Flujo de creación de reportes

Las rutas no están dentro del `ShellRoute` de la navegación inferior:

`/report/new` → `/report/new/pet-info` → `/report/new/photos` → `/report/new/location` → `/report/new/details` → `/report/new/review` → `/report/new/published`.

El botón central de la navegación inferior abre `/report/new`.

## Estado y datos

Riverpod es la fuente de coordinación del estado:

- `themeModeProvider`: modo claro, oscuro o sistema mediante `ThemeModeNotifier`.
- `localeProvider`: idioma actual (`es` o `en`), español por defecto.
- `authProvider`: estado de autenticación mock, usuario actual y estado de carga.
- `reportDraftProvider`: borrador inmutable del formulario de creación, administrado por `ReportDraftNotifier`.
- `reportsFilterProvider` y `myReportsProvider`: filtro y carga de reportes propios.
- `reportByIdProvider`: carga de un reporte por ID.
- `exploreFilterProvider`, `exploreReportsProvider` y `selectedReportProvider`: estado de Explorar.
- `petReportRepositoryProvider`: implementación actual `MockPetReportRepository`.
- `matchRepositoryProvider`, `matchesProvider` y `matchByIdProvider`: coincidencias.
- `radarSummaryProvider`: resumen derivado de reportes y coincidencias.

El `ReportDraft` ofrece validaciones de alto nivel mediante `isPetInfoComplete`, `isLocationComplete` e `isDetailsComplete`. Las pantallas de formulario deben conservar el borrador entre pasos y validar antes de avanzar.

## Modelos de dominio

En `shared/models/`:

- `Pet`: identidad y características de una mascota.
- `PetReport`: reporte con mascota, tipo, estado, ubicación, fechas, descripción, distancia y avistamientos.
- `ReportType`: `lost` o `found`.
- `ReportStatus`: `active`, `possibleMatch`, `recovered` o `closed`.
- `ReportDraft`: datos temporales del flujo de publicación.
- `PetMatch`: relación entre un reporte perdido y uno encontrado, nivel de coincidencia, distancia, diferencia de tiempo y rasgos coincidentes.
- `MatchLevel`: `low`, `medium` o `high`.
- `Sighting`: avistamiento asociado a un reporte.
- `PetStatus`: estados visuales `lost`, `found`, `match` y `recovered`.

Los modelos actuales son clases inmutables sencillas, sin serialización JSON ni generación de código.

## Repositorios y backend

Las interfaces son:

- `PetReportRepository`: reportes cercanos, propios, por ID y creación.
- `MatchRepository`: coincidencias del usuario y coincidencia por ID.

Las implementaciones activas son `MockPetReportRepository` y `MockMatchRepository`, con demoras artificiales para simular red y datos fijos de Pasto. `createReport` también simula la publicación local.

`core/network/api_client.dart` solo contiene:

- base URL: `https://api.petlink.app/v1`;
- timeout: 30 segundos.

No hay cliente HTTP integrado, autenticación, manejo de tokens, serializadores ni persistencia local. Al conectar el backend, conservar las interfaces para que las pantallas sigan dependiendo de abstracciones y reemplazar la implementación mock mediante providers.

## Sistema visual

La fuente de verdad visual está en `core/theme/` y `design_system/`.

- `PetColors`: colores de fondo, superficie, texto, borde, primario, acento y estados perdido/encontrado/coincidencia en claro y oscuro.
- `PetSpacing`: `xs=4`, `sm=8`, `md=12`, `lg=16`, `xl=24`, `xxl=32`, `xxxl=48`.
- `PetRadius`: radios de 6, 8, 12, 16 y 24.
- `PetTypography`: estilos Manrope para display, heading, title, body, body pequeño, label y botones.
- `PetThemeExtension`: colores semánticos adicionales por tema.
- `PetTheme`: temas Material 3 claro y oscuro.

Componentes existentes del design system:

- `PetButton`: variantes primary, secondary, accent, outline, lightOutline y danger; soporta icono, carga y etiqueta semántica.
- `PetCard`: tarjeta base.
- `PetChip`: chip seleccionable.
- `PetInput`: entrada reutilizable con validación, iconos y modo solo lectura.
- `StatusBadge`: insignias de estado.

Widgets compartidos:

- `StepIndicator`, `SectionHeader`, `PetSearchBar`, `PetCardCompact`, `MatchCard`, `EmptyState` y `ErrorState`.
- `AnimalPatternField`: fondo decorativo animado con huellas de baja intensidad.

## Plataformas y archivos generados

Los directorios `android/`, `ios/`, `macos/`, `linux/`, `windows/` y `web/` son los runners generados por Flutter. Modificarlos solo cuando el cambio realmente sea específico de plataforma, configuración de compilación, permisos, identificadores o recursos nativos.

No editar manualmente archivos generados de Flutter salvo que sea imprescindible y se tenga claro cómo regenerarlos. Los archivos de `build/`, `.dart_tool/`, caches y artefactos locales no deben versionarse.

## Pruebas

Actualmente existe `test/widget_test.dart`. Antes de cambiar un flujo importante, ampliar las pruebas para cubrir:

- navegación y rutas;
- estados loading, error, vacío y éxito de providers;
- validación del `ReportDraft`;
- creación y filtrado de reportes;
- cambio entre tema claro y oscuro.

No depender de tiempos artificiales en tests nuevos; inyectar repositorios fake o controlables cuando se agreguen pruebas de providers.

## Limitaciones conocidas

- El backend real aún no está conectado.
- Los datos de reportes y coincidencias son mocks.
- La autenticación actual es mock y no persiste la sesión.
- No hay integración real con mapas, geolocalización, cámara, galería o subida de imágenes; el flujo de fotos usa datos de demostración.
- No hay persistencia local del borrador o de los reportes.
- `ActivityScreen` es una pantalla inicial.
- La URL de API está declarada, pero no existe todavía una capa HTTP funcional.
- Mantener la codificación UTF-8 y colocar los nuevos textos visibles en las localizaciones correspondientes.

## Dirección actual de diseño

La interfaz usa una identidad PetLink sobria y reconocible, orientada a personas de 18 a 60 años:

- composición editorial y clara, sin depender de tarjetas excesivas;
- degradados y acentos usados con moderación;
- huellas y referencias animales como recurso de marca, no como decoración infantil;
- contraste revisado en claro y oscuro;
- botones principales visibles y con áreas táctiles amplias;
- no usar imágenes decorativas genéricas si un recurso nativo o vectorial resuelve mejor la identidad.

La siguiente pantalla prioritaria es `ExploreScreen`: debe resolver la relación entre mapa, lista, filtros y estados vacío/error sin cambiar primero la lógica de providers.

## Criterios para cambios

- No introducir una dependencia nueva si Flutter o las dependencias actuales resuelven el problema.
- No mezclar lógica de backend, navegación y estilos dentro de un mismo widget si puede separarse.
- Mantener compatibilidad con tema oscuro y Material 3.
- Para nuevos estados asíncronos, representar explícitamente loading, error, vacío y datos.
- Para cambios de contrato, actualizar interfaces, mocks y providers en el mismo cambio.
- Actualizar `DESING.md` si cambia arquitectura visual, tokens, navegación o componentes.
- Mantener este archivo actualizado cuando cambien comandos, dependencias, estructura, rutas o limitaciones.
