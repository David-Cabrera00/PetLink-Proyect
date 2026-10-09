# DESING.md — Guía de diseño de PetLink

> Nota: el nombre del archivo conserva `DESING.md` tal como fue solicitado. El contenido documenta el sistema de diseño de PetLink.

## Dirección del producto

PetLink debe sentirse cercano, claro y confiable. La interfaz acompaña a una persona que posiblemente está preocupada por una mascota perdida, por lo que la información importante debe ser fácil de encontrar y las acciones deben tener una jerarquía visual evidente.

Principios:

- Priorizar la acción principal de cada pantalla.
- Comunicar rápidamente si un reporte es de mascota perdida, encontrada o una coincidencia.
- Usar lenguaje directo, humano y principalmente en español.
- Reducir la carga cognitiva en el flujo de creación de reportes.
- Mantener consistencia entre móvil, escritorio y web.
- Diseñar todos los estados: carga, error, vacío, datos y éxito.
- Respetar accesibilidad: contraste suficiente, tamaños táctiles adecuados y etiquetas semánticas.

## Arquitectura de interfaz

La aplicación se divide en una navegación principal y un flujo de publicación:

```text
Navegación principal
├── Radar       → resumen local, reportes cercanos y coincidencias
├── Explorar    → búsqueda/filtrado visual de reportes
├── Reportar    → flujo paso a paso para publicar un reporte
├── Actividad   → notificaciones y eventos del usuario
└── Perfil      → preferencias y tema

Flujo Reportar
Tipo → Información de mascota → Fotos → Ubicación → Detalles → Revisar → Publicado
```

La navegación inferior debe permanecer reservada para las cinco áreas principales. Las pantallas de creación de reportes se presentan como un flujo independiente para evitar competir con la navegación principal.

## Tokens visuales

Los tokens deben consumirse desde `lib/core/theme/` y no duplicarse dentro de las pantallas.

### Color

| Rol | Claro | Oscuro | Uso |
|---|---|---|---|
| Primario | `#0F6B6F` | `#54B8B5` | Acción principal, navegación activa y enlaces importantes. |
| Acento | `#F4A261` | `#F5B375` | Destacar acciones secundarias o información relevante. |
| Perdida | `#C2414B` | `#F1787F` | Reportes de mascotas perdidas y errores. |
| Encontrada | `#2D7A5F` | `#64C49B` | Reportes de mascotas encontradas y estados positivos. |
| Coincidencia | `#6257B8` | `#9C92E8` | Matches y señales de posible coincidencia. |
| Fondo | `#F6F8F7` | `#0E1515` | Fondo general de la aplicación. |
| Superficie | `#FFFFFF` | `#151F1F` | Tarjetas, campos y contenedores. |

Los tonos suaves (`lostSoft`, `foundSoft`, `matchSoft`, `surfaceVariant`) sirven como fondos de apoyo y no deben utilizarse como único indicador de estado: siempre acompañar con texto, icono o etiqueta.

### Espaciado

Usar `PetSpacing`:

| Token | Valor | Uso recomendado |
|---|---:|---|
| `xs` | 4 | Separación mínima entre icono y texto. |
| `sm` | 8 | Gaps compactos y elementos relacionados. |
| `md` | 12 | Separación interna de controles. |
| `lg` | 16 | Padding estándar de tarjetas y secciones. |
| `xl` | 24 | Separación entre bloques. |
| `xxl` | 32 | Márgenes de secciones principales. |
| `xxxl` | 48 | Separación de inicio/fin en pantallas de onboarding o formularios. |

### Radios

Usar `PetRadius`:

- `sm` (6): elementos compactos.
- `md` (8): controles pequeños.
- `lg` (12): inputs y botones.
- `xl` (16): tarjetas y contenedores principales.
- `xxl` (24): superficies destacadas o contenedores de mayor énfasis.

### Tipografía

La familia es Manrope, configurada en `PetTypography`:

- Display: 32 px, peso 700.
- Heading: 24 px, peso 700.
- Title: 18 px, peso 600.
- Body: 16 px, peso 400.
- Body small: 14 px, peso 400.
- Label: 12 px, peso 500.
- Button: 16 px, peso 600.

No usar tamaños nuevos sin una razón de producto o accesibilidad. Los títulos deben describir la tarea o el estado; evitar titulares ambiguos.

## Componentes

### `PetButton`

Variantes disponibles: `primary`, `secondary`, `outline` y `danger`.

- Usar un solo botón primario dominante por sección.
- `primary`: publicar, continuar o confirmar.
- `secondary`: acción complementaria de bajo riesgo.
- `outline`: cancelar, volver o alternativa equivalente.
- `danger`: eliminar, cerrar o acción irreversible.
- Usar `isLoading` durante operaciones asíncronas y bloquear dobles envíos.
- Añadir `semanticLabel` cuando el icono no sea autoexplicativo.

### `PetInput`

Los campos deben tener etiqueta visible, hint útil y validación cercana al error. Usar `readOnly` y `onTap` para selectores o campos que abren una interacción externa, como ubicación o fecha.

No usar el hint como sustituto permanente de la etiqueta. En formularios largos, agrupar campos por tarea y conservar el borrador al pasar de un paso a otro.

### `PetCard`, `PetCardCompact` y `MatchCard`

Las tarjetas deben mostrar primero la identidad de la mascota y el estado del reporte. La acción de abrir el detalle debe ser evidente y toda la tarjeta puede ser táctil cuando tenga un `onTap`.

- Mantener jerarquía: nombre → estado → ubicación/distancia → metadatos.
- No saturar la tarjeta con toda la descripción; reservar el detalle para la pantalla dedicada.
- Las coincidencias deben mostrar nivel, distancia y rasgos coincidentes.

### `PetChip` y `StatusBadge`

Usar chips para filtros o selección. Usar badges para estados que describen un dato ya existente. No intercambiar ambos patrones sin motivo.

El color de estado debe acompañarse con texto y, cuando ayude, icono:

- Perdida: prioridad/alerta.
- Encontrada: confirmación.
- Coincidencia: enlace o comparación.
- Recuperada: resultado positivo.

### Estados de contenido

Usar `EmptyState` cuando una consulta sea válida pero no tenga resultados. Usar `ErrorState` cuando una consulta falle y ofrecer `onRetry` cuando sea posible. Los estados de carga deben conservar la estructura de la pantalla para reducir saltos visuales.

## Pantallas y comportamiento esperado

### Radar

Es la pantalla inicial y debe responder tres preguntas: qué está pasando cerca, cuántos reportes hay y si existe una coincidencia relevante. Las coincidencias de alta prioridad deben tener un tratamiento visual más fuerte, sin ocultar los reportes cercanos.

### Explorar

Debe permitir descubrir reportes mediante búsqueda y filtros (`all`, `lost`, `found`, `nearby`). El mapa/área visual es de demostración actualmente; la implementación real deberá conservar una alternativa de lista accesible.

### Reportes

Debe separar claramente reportes activos, recuperados y todos. El estado de cada reporte debe ser legible sin abrir el detalle.

### Detalle de reporte

Orden recomendado:

1. Identidad de la mascota y estado.
2. Foto o representación visual principal.
3. Ubicación y fecha relevantes.
4. Descripción y características.
5. Avistamientos o coincidencias.
6. Acción disponible.

### Flujo de publicación

El indicador `StepIndicator` debe mostrar progreso y contexto. Cada paso debe tener una sola decisión principal y conservar lo introducido previamente.

- Tipo: seleccionar perdido o encontrado.
- Información: completar atributos de la mascota.
- Fotos: agregar o quitar imágenes; máximo definido por `AppConstants.maxImagesPerReport` (5).
- Ubicación: dirección y coordenadas.
- Detalles: descripción y fecha del último avistamiento.
- Revisar: confirmar datos antes de publicar.
- Publicado: confirmar resultado y ofrecer siguiente acción.

Los errores de validación deben aparecer antes de navegar al siguiente paso. El botón de continuar debe reflejar si el paso está incompleto.

### Perfil y tema

El usuario puede seleccionar el modo de tema. Toda pantalla y componente nuevo debe probarse en los modos claro y oscuro; no asumir que un color claro funcionará sobre una superficie oscura.

## Responsive y accesibilidad

- Diseñar primero para una columna estrecha y ampliar progresivamente en pantallas grandes.
- Evitar anchos fijos que provoquen overflow.
- Respetar `SafeArea` y teclado en formularios.
- Mantener áreas táctiles cómodas para controles interactivos.
- Usar `Semantics` o `semanticLabel` para iconos sin texto.
- No comunicar estados solo con color.
- Verificar contraste, foco, orden de lectura y escalado de texto.
- En web y escritorio, aprovechar el espacio horizontal sin convertir tarjetas pequeñas en bloques difíciles de recorrer.

## Reglas para evolucionar el diseño

- Si un valor se repite, convertirlo en token o componente.
- Si un patrón aparece en más de una feature, moverlo a `shared/widgets/` o `design_system/`.
- Si un componente necesita variantes, modelarlas explícitamente en lugar de duplicar widgets.
- Actualizar este documento al añadir tokens, componentes, rutas o cambios de jerarquía.
- Mantener los estados de error, vacío, carga y éxito como parte del diseño, no como una tarea posterior.
