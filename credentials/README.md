# Credenciales de EAS Submit (NO se commitean)

Esta carpeta guarda las credenciales que usa `eas submit` (referenciadas en `eas.json`).
Todo lo que está aquí está **gitignored** salvo este README.

**iOS primero.** Orden recomendado:

```bash
eas login
eas init                 # crea/enlaza el projectId de Expo (una sola vez)
eas build  -p ios   --profile production
eas submit -p ios   --profile production     # -> TestFlight
# luego Android:
eas build  -p android --profile production
eas submit -p android --profile production   # -> Play internal
```

## Archivos esperados aquí (rellénalos tú)

- `asc-api-key.p8` — App Store Connect API Key (.p8). Descárgala de App Store Connect.
- `play-service-account.json` — Service Account JSON de Google Play Console.

## Placeholders a reemplazar en `eas.json` (`submit.production`)

| Placeholder | Dónde sale |
|-------------|-----------|
| `{{APPLE_ID_EMAIL}}` | Tu Apple ID (email) |
| `{{ASC_APP_ID}}` | App Store Connect → tu app → App Information → Apple ID (numérico) |
| `{{APPLE_TEAM_ID}}` | Apple Developer → Membership (10 chars) |
| `{{ASC_API_KEY_ID}}` | App Store Connect → Users and Access → Keys |
| `{{ASC_API_KEY_ISSUER_ID}}` | Misma pantalla de Keys (Issuer ID) |

> No pegues credenciales reales en el chat ni en el repo: van solo en esta carpeta.
