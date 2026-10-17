# PetLink API

Backend NestJS + Prisma para PetLink. La API se publica bajo `/api/v1` y la documentación OpenAPI está disponible en `/docs`.

## Desarrollo local

1. Copia `.env.example` a `.env` y define `DATABASE_URL` y un `JWT_ACCESS_SECRET` de al menos 16 caracteres.
2. Instala dependencias: `npm install`.
3. Genera Prisma: `npm run prisma:generate`.
4. Ejecuta la migración en una base de desarrollo: `npm run prisma:migrate -- --name init`.
5. Opcionalmente carga datos demo: `npm run prisma:seed`.
6. Inicia la API: `npm run start:dev`.

Endpoints principales: `POST /api/v1/auth/register`, `POST /api/v1/auth/login`, `GET /api/v1/auth/me`, `GET /api/v1/reports`, `GET /api/v1/reports/mine`, `GET /api/v1/reports/:id`, `POST /api/v1/reports`, `PATCH /api/v1/reports/:id` y `GET /api/v1/matches`.

Las imágenes y avistamientos están modelados en Prisma. La subida a Supabase Storage requiere configurar las credenciales del proveedor y se mantiene deliberadamente pendiente hasta disponer de ellas; no se exponen claves de servicio en Flutter.

## Configuración Flutter

Ejecuta desde `petlink/` con `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1` para Android Emulator, o usa `http://localhost:3000/api/v1` en Web/desktop. Sin `API_BASE_URL`, la aplicación conserva los repositorios mock.

Google Sign-In y recuperación de contraseña no se presentan como funcionales: requieren credenciales OAuth y un proveedor de correo transaccional.
