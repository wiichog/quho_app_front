# Configuración de Google Sign-In para Web

Este documento explica cómo configurar Google Sign-In para Flutter Web.

## 📋 Prerequisitos

1. **Google OAuth Client ID** para Web application
2. Acceso a [Google Cloud Console](https://console.cloud.google.com/)

---

## 🔧 Configuración

### Paso 1: Obtener Google OAuth Client ID

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto o crea uno nuevo
3. Ve a **APIs & Services** → **Credentials**
4. Haz clic en **Create Credentials** → **OAuth 2.0 Client ID**
5. Si es la primera vez, configura el **OAuth consent screen**:
   - Tipo de aplicación: **External** (o Internal si tienes Google Workspace)
   - Completa la información requerida
6. En **Application type**, selecciona **Web application**
7. Configura las **Authorized JavaScript origins**:
   - `http://localhost` (para desarrollo)
   - `http://localhost:8080` (si usas otro puerto)
   - `https://tu-dominio.com` (para producción)
8. Configura las **Authorized redirect URIs**:
   - `http://localhost/auth/callback` (para desarrollo)
   - `https://tu-dominio.com/auth/callback` (para producción)
9. Haz clic en **Create**
10. **Copia el Client ID** (formato: `xxxxx.apps.googleusercontent.com`)

### Paso 2: Configurar en la aplicación

1. Abre el archivo `web/index.html`
2. Busca el meta tag:
   ```html
   <meta name="google-signin-client_id" content="TU_GOOGLE_CLIENT_ID_WEB.apps.googleusercontent.com">
   ```
3. Reemplaza `TU_GOOGLE_CLIENT_ID_WEB.apps.googleusercontent.com` con tu Client ID real
4. Guarda el archivo

**Ejemplo:**
```html
<meta name="google-signin-client_id" content="123456789-abcdefghijklmnop.apps.googleusercontent.com">
```

### Paso 3: Verificar la configuración

1. Reinicia la aplicación Flutter Web
2. Intenta iniciar sesión con Google
3. Deberías ver el diálogo de Google Sign-In

---

## 🐛 Solución de Problemas

### Error: "ClientID not set"

**Problema:** El meta tag no está configurado o tiene un valor incorrecto.

**Solución:**
1. Verifica que el meta tag esté presente en `web/index.html`
2. Verifica que el Client ID sea correcto (formato: `xxxxx.apps.googleusercontent.com`)
3. Asegúrate de que no haya espacios extra en el contenido del meta tag
4. Reinicia la aplicación después de hacer cambios

### Error: "redirect_uri_mismatch"

**Problema:** La URI de redirección no está autorizada en Google Cloud Console.

**Solución:**
1. Ve a Google Cloud Console → Credentials → Tu Client ID
2. Agrega la URI exacta que estás usando (incluyendo el puerto si es desarrollo)
3. Guarda los cambios
4. Espera unos minutos para que los cambios se propaguen

### Error: "access_denied"

**Problema:** El usuario canceló el proceso de autenticación o hay un problema con los permisos.

**Solución:**
1. Verifica que el OAuth consent screen esté configurado correctamente
2. Asegúrate de que los scopes solicitados (`email`, `profile`) estén habilitados
3. Si estás en desarrollo, verifica que el tipo de aplicación sea "External" y esté en modo "Testing"

---

## 📝 Notas Importantes

- **No commitees el Client ID real** si es un proyecto público. Considera usar variables de entorno o un archivo de configuración que no se suba al repositorio.
- El Client ID de Web es **diferente** al Client ID de Android e iOS. Necesitas crear credenciales separadas para cada plataforma.
- Para producción, asegúrate de agregar tu dominio real en las **Authorized JavaScript origins** y **Authorized redirect URIs**.

---

## 🔗 Enlaces Útiles

- [Google Cloud Console](https://console.cloud.google.com/)
- [Google Sign-In Flutter Package](https://pub.dev/packages/google_sign_in)
- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)

---

## ✅ Checklist

- [ ] Client ID creado en Google Cloud Console
- [ ] OAuth consent screen configurado
- [ ] Authorized JavaScript origins configuradas
- [ ] Authorized redirect URIs configuradas
- [ ] Meta tag agregado en `web/index.html` con el Client ID correcto
- [ ] Aplicación probada y funcionando


