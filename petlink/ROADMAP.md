# Roadmap de PetLink

## Objetivo del producto

Construir una aplicación móvil clara, confiable y rápida que ayude a:

- propietarios y cuidadores a reportar una mascota perdida;
- personas que encuentran un animal a publicar un reporte;
- ambas partes a descubrir coincidencias cercanas y contactar de forma segura.

## Público objetivo

Personas de 18 a 60 años, usuarias de smartphone, con distintos niveles de experiencia digital. La aplicación debe funcionar especialmente bien en momentos de estrés, con poca atención disponible y posiblemente con conectividad limitada.

## Principios de priorización

1. Encontrar o ayudar a encontrar una mascota.
2. Reducir el tiempo para publicar un reporte completo.
3. Hacer evidente qué acción debe tomar la persona.
4. Generar confianza y proteger la privacidad.
5. Mantener una experiencia accesible, legible y usable en pantallas pequeñas.

## Estado actual resumido

Ya existe una base visual y funcional de prototipo:

- Flutter con Material 3.
- Navegación con GoRouter.
- Estado con Riverpod.
- Temas claro y oscuro.
- Design system inicial.
- Pantallas de Radar, Explorar, Reportes, Actividad, Perfil y coincidencias.
- Flujo de creación de reportes de siete pasos.
- Repositorios mock con datos de Pasto.

Las mayores limitaciones actuales son la ausencia de backend real, persistencia, autenticación, geolocalización, subida de fotos y acciones de contacto. La interfaz también necesita una revisión completa de jerarquía, consistencia y accesibilidad.

## Roadmap por fases

### Fase 0 — Preparación y definición

Objetivo: eliminar ambigüedades antes de rediseñar.

- [x] Corregir la codificación de todos los textos visibles.
- [x] Definir el tono de voz: cercano, claro, urgente sin alarmismo.
- [x] Definir las acciones principales por tipo de usuario.
- [x] Confirmar la estructura de navegación móvil.
- [x] Crear inventario de pantallas, estados y acciones.
- [ ] Definir métricas iniciales: reportes publicados, reportes completos, coincidencias abiertas y contactos iniciados.
- [ ] Establecer reglas de privacidad para dirección, teléfono, fotos y ubicación.

Resultado esperado: alcance funcional y criterios de éxito documentados.

### Fase 1 — Fundamentos de diseño

Objetivo: convertir el sistema visual inicial en un sistema consistente.

- [ ] Revisar la paleta para contraste en claro y oscuro.
- [x] Consolidar tokens de color, tipografía, espaciado, radios y elevación.
- [x] Definir jerarquía tipográfica para móvil.
- [x] Unificar `PetButton`, `PetInput`, `PetCard`, `PetChip` y `StatusBadge`.
- [ ] Definir estados de componentes: normal, presionado, foco, deshabilitado, carga y error.
- [x] Crear placeholders y reglas para imágenes.
- [ ] Definir iconografía para perdido, encontrado, coincidencia, ubicación y contacto.
- [ ] Revisar tamaños táctiles y accesibilidad.
- [ ] Eliminar estilos repetidos directamente escritos en las pantallas.

Resultado esperado: cualquier pantalla nueva puede construirse con componentes y tokens existentes.

### Fase 2 — Rediseño de experiencia móvil

Objetivo: que una persona pueda entender y actuar sin entrenamiento.

- [ ] Rediseñar Radar priorizando coincidencias y reportes urgentes.
- [x] Rediseñar Explorar con lista y mapa claramente diferenciados.
- [x] Simplificar la navegación inferior y destacar Reportar como acción principal.
- [x] Mejorar el detalle de reporte: foto, estado, ubicación aproximada, fecha, descripción y acción.
- [ ] Rediseñar el flujo de reporte con progreso visible y guardado automático del borrador.
- [x] Definir qué campos son obligatorios y cuáles pueden completarse después.
- [ ] Diseñar estados loading, vacío, error, sin permisos, sin conexión y éxito.
- [ ] Diseñar mensajes de confirmación y prevención de dobles envíos.
- [ ] Validar las pantallas en tamaños de smartphone pequeños y grandes.

Resultado esperado: prototipo navegable y visualmente coherente para los principales casos de uso.

### Fase 3 — Calidad del prototipo actual

Objetivo: corregir los problemas que afectan la percepción y la demostración.

- [x] Corregir todos los textos con caracteres dañados.
- [ ] Reemplazar botones vacíos o esconder temporalmente acciones no disponibles.
- [x] Añadir fallback para imágenes fallidas.
- [x] Corregir el flujo posterior a publicar para que el nuevo reporte aparezca en las listas.
- [x] Hacer deterministas los datos mock.
- [x] Evitar `ProviderScope` duplicado.
- [ ] Añadir pruebas de rutas, filtros, validación y publicación.
- [ ] Confirmar que `flutter analyze` y `flutter test` terminen correctamente.

Resultado esperado: demo estable, reproducible y sin interacciones falsas visibles.

### Fase 4 — Datos, persistencia y configuración

Objetivo: separar el prototipo de la infraestructura real.

- [ ] Añadir serialización JSON para modelos.
- [ ] Implementar cliente HTTP con timeout, headers y manejo de errores.
- [ ] Separar configuración de desarrollo, staging y producción.
- [ ] Reemplazar repositorios mock por repositorios remotos detrás de las mismas interfaces.
- [ ] Añadir persistencia local del borrador.
- [ ] Añadir cache de reportes recientes.
- [ ] Invalidar/refrescar providers después de crear, editar o cerrar un reporte.
- [ ] Definir estados de sesión y expiración de autenticación.

Resultado esperado: la aplicación conserva información y consume datos reales sin acoplar las pantallas al backend.

### Fase 5 — Funcionalidad principal del producto

Objetivo: completar el ciclo de ayuda entre quien pierde y quien encuentra.

- [x] Registro e inicio de sesión (mock; backend pendiente).
- [ ] Crear, editar, cerrar y marcar como recuperado un reporte.
- [ ] Subir, eliminar y ordenar fotografías.
- [ ] Integrar cámara y galería.
- [x] Integrar ubicación actual, permisos y selección manual en mapa.
- [x] Aplicar radio de búsqueda real.
- [ ] Implementar coincidencias con criterios explicables.
- [ ] Implementar compartir un reporte.
- [ ] Implementar guardar/favoritos si se confirma como necesidad.
- [ ] Implementar contacto seguro entre usuarios.
- [ ] Implementar notificaciones de coincidencias y actividad.

Resultado esperado: una persona puede publicar, descubrir, verificar y contactar sin salir de PetLink.

### Fase 6 — Confianza, seguridad y moderación

Objetivo: proteger a las personas y evitar abusos.

- [ ] Mostrar ubicación aproximada públicamente, no necesariamente la dirección exacta.
- [ ] Evitar exponer teléfono o datos personales sin consentimiento.
- [ ] Añadir reporte de contenido y bloqueo de usuarios.
- [ ] Definir moderación de fotos y textos.
- [ ] Validar formatos y tamaños de imágenes.
- [ ] Proteger endpoints y tokens.
- [ ] Registrar acciones sensibles y errores sin almacenar datos innecesarios.
- [ ] Añadir textos de consentimiento y política de privacidad.

Resultado esperado: la aplicación puede manejar información sensible con controles básicos de seguridad y confianza.

### Fase 7 — Accesibilidad, rendimiento y lanzamiento

Objetivo: preparar la aplicación para uso real.

- [ ] Probar contraste y escalado de texto.
- [ ] Probar lector de pantalla y navegación por teclado en web/escritorio.
- [ ] Medir tiempos de carga y consumo de datos.
- [ ] Optimizar imágenes y listas.
- [ ] Probar conectividad lenta y pérdida de red.
- [ ] Añadir logging y seguimiento de errores.
- [ ] Crear pruebas de integración de los flujos críticos.
- [ ] Configurar builds firmadas y variables seguras.
- [ ] Preparar icono, splash, capturas y textos de tienda.
- [ ] Hacer una prueba piloto con propietarios y cuidadores reales.

Resultado esperado: versión candidata a lanzamiento con feedback real y problemas críticos resueltos.

## Orden inmediato de trabajo

La siguiente secuencia evita invertir tiempo en pulir pantallas que todavía cambiarán por falta de funcionalidad:

1. Corregir codificación y textos visibles.
2. Completar el inventario de pantallas y estados.
3. Definir la jerarquía visual de Radar, Explorar y Reportar.
4. Consolidar el design system.
5. Corregir publicación, refresco de listas y estados mock.
6. Rediseñar el flujo móvil de reporte.
7. Añadir pruebas de los flujos principales.
8. Conectar persistencia y backend.
9. Integrar ubicación, fotos, coincidencias y contacto.
10. Validar con usuarios reales.

## Definición de terminado para cada pantalla

Una pantalla no se considera terminada hasta tener:

- estado de carga;
- estado vacío;
- estado de error con recuperación;
- estado exitoso;
- navegación de ida y vuelta;
- contenido legible con texto ampliado;
- tema claro y oscuro revisados;
- acciones sin callbacks vacíos;
- componentes del design system;
- prueba manual en smartphone.

## Primer objetivo del ciclo actual

Completar una primera versión sólida de la experiencia móvil del flujo principal:

`Radar → detalle de reporte → iniciar reporte → completar → revisar → publicar`.

La primera entrega debe sentirse coherente, confiable y comprensible aunque todavía utilice datos mock. Después se sustituirán los mocks por infraestructura real.
