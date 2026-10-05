# Te Quiero Verde — Material para redes

Material gráfico de **Te Quiero Verde** (Galaro S.A. | Servicios agrícolas, Bell Ville, Córdoba).

## Carpetas

- `flyers-siembra/`: flyers para Instagram.
  - `v2-*.png`: posts de feed (1080×1350).
  - `v3-venta-rollos.png`: post de venta de rollos.
  - `historia-*.png`: historias (1080×1920).
  - Los `.html` + `.css` son las fuentes editables de cada pieza.
- `destacados/`: tapas de historias destacadas.
- `perfil-instagram/`: foto de perfil (1080×1080).
- `logo-te-quiero-verde-sin-fondo.png` / `logo-te-quiero-verde-blanco.png`: logo sin fondo en alta.

## Regenerar un PNG

Abrir el `.html` en el navegador, o exportarlo con Edge:

```
msedge --headless=new --hide-scrollbars --window-size=1080,1350 --screenshot=salida.png archivo.html
```

(1080,1920 para historias.)