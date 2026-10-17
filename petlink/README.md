# PetLink

Aplicación Flutter de PetLink. El backend NestJS está en [`../backend`](../backend/README.md).

## Desarrollo

```bash
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

Si `API_BASE_URL` se omite, se usa el modo mock para desarrollo visual.
