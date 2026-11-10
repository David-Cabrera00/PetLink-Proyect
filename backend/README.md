# PetLink API

Backend NestJS + Prisma para PetLink. La API se publica bajo `/api/v1` y la documentación OpenAPI está disponible en `/docs`.

## Desarrollo local

1. Copia `.env.example` a `.env` y define `DATABASE_URL` y un `JWT_ACCESS_SECRET` de al menos 16 caracteres.
2. Instala dependencias: `npm install`.
3. Genera Prisma: `npm run prisma:generate`.
4. Ejecuta la migración en una base de desarrollo: `npm run prisma:migrate -- --name init`.
5. Opcionalmente carga datos demo: `npm run prisma:seed`.
6. Inicia la API: `npm run start:dev`.

Health check público: `GET /health`. Para UptimeRobot usa `https://TU-SERVICIO.onrender.com/health`; debe responder HTTP 200 con un JSON que contiene `status: "ok"`.

Endpoints principales: `POST /api/v1/auth/register`, `POST /api/v1/auth/login`, `GET /api/v1/auth/me`, `GET /api/v1/reports`, `GET /api/v1/reports/mine`, `GET /api/v1/reports/:id`, `POST /api/v1/reports`, `PATCH /api/v1/reports/:id` y `GET /api/v1/matches`.

Las imágenes se suben desde el backend a Supabase Storage; la clave `SUPABASE_SERVICE_ROLE_KEY` nunca se expone en Flutter.

## IA de visión

La API incluye `POST /api/v1/ai/analyze-image`, protegido con JWT. Acepta una imagen multipart en el campo `file`, o alternativamente `imageUrl`/`imageBase64`, y devuelve especie, raza, color, tamaño, sexo, rasgos visibles y confianza.

El flujo de Flutter usa esta respuesta para sugerir datos del reporte. La IA no identifica todavía que dos fotografías sean de la misma mascota: el endpoint `/matches` sigue usando coincidencias de campos de texto y distancia geográfica.

Para evitar resultados intermitentes:

- Usa una foto nítida, frontal o de perfil, con la mascota ocupando buena parte del encuadre.
- Evita fotos oscuras, borrosas, con varias mascotas o con el animal parcialmente tapado.
- Configura al menos un proveedor (`OPENROUTER_API_KEY` + `OPENROUTER_MODEL`, o Gemini/Groq) y prueba el endpoint con una imagen real.
- Trata la respuesta como sugerencia: la persona debe revisar raza, sexo y tamaño antes de publicar.
- No envíes varias fotos simultáneamente sin controlar el orden de respuesta; el último resultado recibido puede sobrescribir campos del formulario.

### Configurar Amazon Bedrock como respaldo

El backend también puede usar Amazon Nova Lite como proveedor de respaldo. En AWS crea un usuario o rol IAM con permiso mínimo para `bedrock:Converse` sobre el modelo elegido. En Render agrega:

```env
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_BEDROCK_MODEL_ID=amazon.nova-lite-v1:0
```

No pongas estas credenciales en Flutter ni en el repositorio. El backend intenta Bedrock después de los proveedores configurados previamente. La cuenta y la región deben tener disponible el modelo de Bedrock seleccionado.

## Configuración Flutter

Ejecuta desde `petlink/` con `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1` para Android Emulator, o usa `http://localhost:3000/api/v1` en Web/desktop. Sin `API_BASE_URL`, la aplicación conserva los repositorios mock.

Google Sign-In y recuperación de contraseña requieren credenciales OAuth y un proveedor de correo transaccional. En producción también conviene añadir límites de tamaño/tipo para las imágenes y validar estrictamente las URLs externas antes de descargarlas.
