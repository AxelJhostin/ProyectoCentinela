# Sitio web Centinela (Astro)

Landing de promoción + descarga de APK y política de privacidad.

## Rutas

| Ruta | Contenido |
|------|-----------|
| `/` | Landing, CTA descarga APK |
| `/privacidad` | Política LOPDP |

## Desarrollo local

```bash
cd centinela-web
npm install
npm run dev
```

Abre http://localhost:4321

## Actualizar APK en la web

```bash
./scripts/build_apk.sh
./scripts/prepare_web_apk.sh
```

## Deploy gratuito en Vercel

1. Crea cuenta en [vercel.com](https://vercel.com) e importa el repo `ProyectoCentinela`.
2. En **Project Settings → General → Root Directory**, pon: `centinela-web`
3. Framework Preset: **Astro** (detecta build automáticamente).
4. Deploy. URL en producción: **https://proyecto-centinela.vercel.app**
5. El sitemap se genera en build: `/sitemap-index.xml` (referenciado en `robots.txt`).

### CLI (opcional)

```bash
cd centinela-web
npx vercel --yes
```

## Notas

- El APK se sirve desde `/centinela.apk` (carpeta `public/`).
- **Métricas públicas** (visitas, descargas, compartidos) vía Supabase RPC `obtener_metricas_sitio` — visibles en la landing y en el panel admin de la app.
- Plan gratuito de Vercel: suficiente para piloto y tráfico moderado.
- Dominio propio: configurar después en Vercel → Domains.
