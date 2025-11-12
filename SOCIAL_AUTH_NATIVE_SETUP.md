# Configuración Nativa de Social Auth para QUHO

Esta guía explica cómo configurar Google Sign-In, Apple Sign In y Facebook Login en Android e iOS.

## 📋 Prerequisitos

Antes de comenzar, asegúrate de tener:

1. **Google OAuth Client ID** (para Android e iOS)
2. **Apple Developer Account** y **Service ID**
3. **Facebook App ID** y **Client Token**

---

## 🤖 Configuración Android

### 1. Google Sign-In (Android)

#### Paso 1: Obtener SHA-1 y SHA-256

```bash
cd android
./gradlew signingReport
```

Copia los valores SHA-1 y SHA-256 del variant `debug` y `release`.

#### Paso 2: Configurar en Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto
3. Ve a **APIs & Services** → **Credentials**
4. Crear credenciales → **OAuth 2.0 Client ID**
5. Tipo: **Android**
6. Package name: `com.quho.app` (o el tuyo)
7. SHA-1: Pegar el obtenido anteriormente
8. Crear y guardar el **Client ID**

#### Paso 3: Actualizar android/app/build.gradle.kts

```kotlin
android {
    defaultConfig {
        // ... existing config
        
        // Google Sign-In - Agregar al final
        resValue("string", "default_web_client_id", "TU_GOOGLE_CLIENT_ID.apps.googleusercontent.com")
    }
}
```

### 2. Facebook Login (Android)

#### Paso 1: Configurar en Facebook Developer Console

1. Ve a [Facebook Developers](https://developers.facebook.com/)
2. Selecciona tu app
3. Settings → Basic
4. Agrega **Android Platform**
5. Package Name: `com.quho.app`
6. Class Name: `com.quho.app.MainActivity`
7. Key Hashes: Genera con:

```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
# Password: android
```

#### Paso 2: Actualizar android/app/src/main/AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <!-- Existing config -->
        
        <!-- Facebook Configuration -->
        <meta-data 
            android:name="com.facebook.sdk.ApplicationId" 
            android:value="@string/facebook_app_id"/>
            
        <meta-data 
            android:name="com.facebook.sdk.ClientToken" 
            android:value="@string/facebook_client_token"/>
        
        <activity 
            android:name="com.facebook.FacebookActivity"
            android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
            android:label="@string/app_name" />
            
        <activity
            android:name="com.facebook.CustomTabActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="@string/fb_login_protocol_scheme" />
            </intent-filter>
        </activity>
    </application>
    
    <!-- Internet Permission (if not already added) -->
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

#### Paso 3: Crear android/app/src/main/res/values/strings.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">QUHO</string>
    <string name="facebook_app_id">TU_FACEBOOK_APP_ID</string>
    <string name="facebook_client_token">TU_FACEBOOK_CLIENT_TOKEN</string>
    <string name="fb_login_protocol_scheme">fbTU_FACEBOOK_APP_ID</string>
</resources>
```

---

## 🍎 Configuración iOS

### 1. Google Sign-In (iOS)

#### Paso 1: Configurar en Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. APIs & Services → Credentials
3. Crear credenciales → OAuth 2.0 Client ID
4. Tipo: **iOS**
5. Bundle ID: `com.quho.app` (o el tuyo)
6. Guardar el **Client ID**

#### Paso 2: Actualizar ios/Runner/Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Existing keys -->
    
    <!-- Google Sign-In Configuration -->
    <key>GIDClientID</key>
    <string>TU_GOOGLE_CLIENT_ID.apps.googleusercontent.com</string>
    
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <!-- Reversed Client ID from Google Console -->
                <string>com.googleusercontent.apps.TU_CLIENT_ID_INVERTIDO</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

### 2. Apple Sign In (iOS)

#### Paso 1: Habilitar en Apple Developer

1. Ve a [Apple Developer](https://developer.apple.com/)
2. Certificates, IDs & Profiles
3. Identifiers → Selecciona tu App ID
4. Habilita **Sign In with Apple**
5. Save

#### Paso 2: Actualizar ios/Runner/Runner.entitlements

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Existing entitlements -->
    
    <!-- Apple Sign In -->
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>
```

### 3. Facebook Login (iOS)

#### Paso 1: Configurar en Facebook Developer Console

1. Ve a [Facebook Developers](https://developers.facebook.com/)
2. Selecciona tu app
3. Settings → Basic
4. Agrega **iOS Platform**
5. Bundle ID: `com.quho.app`
6. Habilita **Single Sign On**

#### Paso 2: Actualizar ios/Runner/Info.plist

```xml
<dict>
    <!-- Existing keys -->
    
    <!-- Facebook Configuration -->
    <key>FacebookAppID</key>
    <string>TU_FACEBOOK_APP_ID</string>
    
    <key>FacebookClientToken</key>
    <string>TU_FACEBOOK_CLIENT_TOKEN</string>
    
    <key>FacebookDisplayName</key>
    <string>QUHO</string>
    
    <!-- URL Schemes for Facebook -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>fbTU_FACEBOOK_APP_ID</string>
            </array>
        </dict>
    </array>
    
    <!-- LSApplicationQueriesSchemes -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>fbapi</string>
        <string>fb-messenger-share-api</string>
        <string>fbauth2</string>
        <string>fbshareextension</string>
    </array>
</dict>
```

---

## 🔧 Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto (NO COMMITEAR):

```env
# Google OAuth
GOOGLE_CLIENT_ID_ANDROID=tu-client-id-android.apps.googleusercontent.com
GOOGLE_CLIENT_ID_IOS=tu-client-id-ios.apps.googleusercontent.com

# Facebook
FACEBOOK_APP_ID=tu-facebook-app-id
FACEBOOK_CLIENT_TOKEN=tu-facebook-client-token

# Apple (Backend)
APPLE_SERVICE_ID=com.quho.app.signin
APPLE_TEAM_ID=tu-team-id
APPLE_KEY_ID=tu-key-id
```

---

## ✅ Verificación

### Probar Google Sign-In

```bash
# Android
flutter run --debug
# Toca el botón de Google y verifica el flujo

# iOS
flutter run --debug
# Toca el botón de Google y verifica el flujo
```

### Probar Apple Sign In

```bash
# Solo iOS - requiere dispositivo físico
flutter run --release
# Apple Sign In no funciona en simulador
```

### Probar Facebook Login

```bash
# Android e iOS
flutter run --debug
# Toca el botón de Facebook y verifica el flujo
```

---

## 🐛 Solución de Problemas

### Google Sign-In

**Error: "DEVELOPER_ERROR"**
- Verifica que el SHA-1 sea correcto
- Verifica que el package name coincida
- Asegúrate de haber agregado el Client ID correcto

**Error: "SIGN_IN_FAILED"**
- Verifica la configuración en Google Cloud Console
- Revisa que los permisos estén habilitados

### Apple Sign In

**Error: "1000" o "1001"**
- Verifica que Sign In with Apple esté habilitado en el App ID
- Verifica que el Service ID esté correctamente configurado
- Usa un dispositivo físico (no funciona en simulador)

### Facebook Login

**Error: "Invalid key hash"**
- Regenera el key hash con el comando correcto
- Verifica que esté agregado en Facebook Developer Console

**Error: "App not setup"**
- Verifica que el App ID sea correcto en strings.xml/Info.plist
- Verifica que la app esté en modo "Live" o agregada como tester

---

## 📱 URLs de Callback

Configura estas URLs en cada consola:

### Google Cloud Console
- **Android**: No requiere URL de callback específica
- **iOS**: No requiere URL de callback específica

### Facebook Developer Console
- **OAuth Redirect URIs**: `https://api.quhoapp.com/auth/complete/facebook/`

### Apple Developer Console
- **Return URLs**: `https://api.quhoapp.com/auth/complete/apple-id/`

---

## 📚 Referencias

- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [Sign In with Apple Flutter](https://pub.dev/packages/sign_in_with_apple)
- [Facebook Login Flutter](https://pub.dev/packages/flutter_facebook_auth)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Facebook Developers](https://developers.facebook.com/)
- [Apple Developer](https://developer.apple.com/)

---

## ⚠️ Seguridad

1. **NUNCA** commitees archivos con credenciales:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
   - `.env`
   - `strings.xml` con IDs reales

2. Agrega al `.gitignore`:
```gitignore
# Credentials
.env
google-services.json
ios/Runner/GoogleService-Info.plist
android/app/src/main/res/values/strings.xml

# Keys
*.p8
*.pem
*.key
```

3. Usa AWS Secrets Manager o similar para producción

---

## 🎯 Checklist

- [ ] Google Client IDs obtenidos (Android e iOS)
- [ ] Facebook App ID y Client Token obtenidos
- [ ] Apple Service ID configurado
- [ ] SHA-1/SHA-256 generados y agregados a Google Console
- [ ] Key Hash generado y agregado a Facebook Console
- [ ] `strings.xml` creado con Facebook IDs (Android)
- [ ] `Info.plist` actualizado con todos los IDs (iOS)
- [ ] `AndroidManifest.xml` actualizado (Android)
- [ ] `Runner.entitlements` actualizado (iOS)
- [ ] Probado en dispositivo Android
- [ ] Probado en dispositivo iOS
- [ ] URLs de callback configuradas en todas las consolas
- [ ] Variables de entorno configuradas en backend (AWS Secrets Manager)

---

¡Listo! Con esta configuración, el social auth debería funcionar correctamente en ambas plataformas. 🚀

