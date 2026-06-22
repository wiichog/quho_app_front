// Genera los íconos PNG de QUHO desde un SVG del búho de la marca.
// Uso: node scripts/gen-icons.mjs   (requiere `sharp`)
import sharp from 'sharp';
import { mkdirSync } from 'node:fs';
import { join } from 'node:path';

const OUT = join(process.cwd(), 'assets', 'images');
mkdirSync(OUT, { recursive: true });

// Búho de la marca (coordenadas sobre lienzo 512). Blanco para destacar en cualquier fondo.
const owl = `
  <path d="M150 150 L122 74 L198 120 Z" fill="#FFFFFF"/>
  <path d="M362 150 L390 74 L314 120 Z" fill="#FFFFFF"/>
  <circle cx="190" cy="236" r="82" fill="#FFFFFF"/>
  <circle cx="322" cy="236" r="82" fill="#FFFFFF"/>
  <circle cx="190" cy="236" r="34" fill="#1E293B"/>
  <circle cx="322" cy="236" r="34" fill="#1E293B"/>
  <circle cx="202" cy="224" r="11" fill="#FFFFFF"/>
  <circle cx="334" cy="224" r="11" fill="#FFFFFF"/>
  <path d="M256 280 L232 312 L280 312 Z" fill="#F59E0B"/>
`;

const owlMono = `
  <path d="M150 150 L122 74 L198 120 Z" fill="#FFFFFF"/>
  <path d="M362 150 L390 74 L314 120 Z" fill="#FFFFFF"/>
  <circle cx="190" cy="236" r="82" fill="#FFFFFF"/>
  <circle cx="322" cy="236" r="82" fill="#FFFFFF"/>
  <path d="M256 280 L232 312 L280 312 Z" fill="#FFFFFF"/>
`;

const gradient = `
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#14B8A6"/>
      <stop offset="1" stop-color="#0D9488"/>
    </linearGradient>
  </defs>`;

const scaled = (inner, s) =>
  `<g transform="translate(256,256) scale(${s}) translate(-256,-256)">${inner}</g>`;

const svg = (size, body) =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="${size}" height="${size}">${body}</svg>`;

// Ícono completo (fondo gradiente full-bleed; el SO recorta esquinas)
const fullIcon = (size) => svg(size, `${gradient}<rect width="512" height="512" fill="url(#bg)"/>${owl}`);
// Fondo gradiente sólido (capa de fondo del adaptive icon)
const bgLayer = (size) => svg(size, `${gradient}<rect width="512" height="512" fill="url(#bg)"/>`);
// Primer plano del adaptive icon (búho dentro de la zona segura, fondo transparente)
const foreground = (size) => svg(size, scaled(owl, 0.62));
// Monocromo (themed icons Android)
const monochrome = (size) => svg(size, scaled(owlMono, 0.62));
// Splash (búho a color sobre transparente)
const splash = (size) => svg(size, scaled(owl, 0.85));

const png = (markup, size, file) =>
  sharp(Buffer.from(markup)).resize(size, size).png().toFile(join(OUT, file));

await Promise.all([
  png(fullIcon(1024), 1024, 'icon.png'),
  png(bgLayer(1024), 1024, 'android-icon-background.png'),
  png(foreground(1024), 1024, 'android-icon-foreground.png'),
  png(monochrome(1024), 1024, 'android-icon-monochrome.png'),
  png(splash(1024), 1024, 'splash-icon.png'),
  png(fullIcon(48), 48, 'favicon.png'),
]);

console.log('✅ Íconos QUHO generados en assets/images/');
