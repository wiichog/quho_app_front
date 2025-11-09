# 🚀 QUHO Web App - Deployment Guide

## 📋 Configuración para AWS Amplify

### Variables de Entorno Requeridas

En AWS Amplify Console, configurar las siguientes variables:

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `API_URL` | `https://api.quhoapp.com/api/v1` | URL del API backend |
| `ENV` | `production` | Ambiente de ejecución |

### Build Settings

El archivo `amplify.yml` ya está configurado para:
- ✅ Instalar Flutter stable
- ✅ Compilar con web-renderer canvaskit
- ✅ Inyectar variables de entorno en build time
- ✅ Cachear dependencias para builds más rápidos

### Dominios

**Dominio principal:** `quhoapp.com`

Configurar en Amplify:
1. Domain management → Add domain
2. Ingresar `quhoapp.com`
3. Configurar DNS records (automático con Route 53)
4. Esperar validación SSL (~15-60 min)

### Builds Automáticos

Los builds se disparan automáticamente en:
- Push a rama `main` → Deploy a producción
- Pull requests → Preview builds

### Testing Local

Para probar el build de producción localmente:

```bash
cd web-app

# Build con variables de producción
flutter build web --release \
  --web-renderer canvaskit \
  --dart-define=ENV=production \
  --dart-define=API_URL=https://api.quhoapp.com/api/v1

# Servir localmente
cd build/web
python -m http.server 8080
```

Abrir: `http://localhost:8080`

### Routing (SPA)

El archivo `web/_redirects` configura el routing correcto:
- Todas las rutas redirigen a `/index.html` (código 200)
- Esto permite que Flutter maneje el routing del lado del cliente

### Assets

Asegúrate de tener los siguientes archivos en `web/`:
- ✅ `favicon.png` - Favicon del sitio
- ✅ `icons/Icon-192.png` - Icono PWA 192x192
- ✅ `icons/Icon-512.png` - Icono PWA 512x512
- ✅ `icons/Icon-maskable-192.png` - Icono maskable 192x192
- ✅ `icons/Icon-maskable-512.png` - Icono maskable 512x512

### Performance

Configuraciones de caché recomendadas en Amplify:
```
/assets/*: max-age=31536000, immutable
/icons/*: max-age=31536000, immutable
/index.html: no-cache
/manifest.json: max-age=3600
```

### CORS

Asegúrate que el backend tenga configurado CORS para:
- `https://quhoapp.com`
- `https://www.quhoapp.com`
- `https://*.amplifyapp.com` (para preview builds)

### Monitoreo

En Amplify Console puedes ver:
- ✅ Build logs
- ✅ Access logs
- ✅ Métricas de performance
- ✅ Errores 4xx/5xx

---

## 🔧 Troubleshooting

### API no se conecta
1. Verificar que `API_URL` esté configurada correctamente en Amplify
2. Verificar CORS en el backend
3. Revisar logs del build

### Rutas dan 404
1. Verificar que `_redirects` esté en `build/web/`
2. Verificar configuración de rewrites en Amplify

### Build falla
1. Revisar logs en Amplify Console
2. Verificar que Flutter se instale correctamente
3. Verificar dependencias en `pubspec.yaml`

---

## 📱 PWA (Progressive Web App)

La app está configurada como PWA:
- ✅ Service Worker (generado automáticamente)
- ✅ Web Manifest con iconos
- ✅ Installable en móviles y desktop
- ✅ Funciona offline (caché de assets)

Para instalar:
1. Abrir en Chrome/Safari
2. Menú → "Agregar a pantalla de inicio"

---

## ✅ Checklist Pre-Deploy

- [ ] Variables de entorno configuradas en Amplify
- [ ] API backend funcionando en `api.quhoapp.com`
- [ ] CORS configurado en backend
- [ ] Iconos PWA en `web/icons/`
- [ ] Dominio configurado (si aplica)
- [ ] SSL/HTTPS verificado

---

**Última actualización:** 2025-11-09

