# Historia "Estamos fertilizando nuestras alfalfas" (1080x1920) a partir del video horizontal de WhatsApp.
# Fondo: el mismo video agrandado y desenfocado. Centro: video mejorado (escalado lanczos, menos ruido,
# más nitidez y color) con bordes fundidos. Encima: textos de la marca que aparecen con fundido.
$ErrorActionPreference = 'Stop'
$r = $PSScriptRoot
$f = Split-Path $r -Parent
$ff = (Get-Command ffmpeg).Source

& $ff -y -loglevel error -i "$r\fertilizacion-original.mp4" -loop 1 -i "$r\mascara.png" -loop 1 -i "$r\capa-fert.png" `
  -f lavfi -i anullsrc=r=44100:cl=stereo -filter_complex (
  "[0:v]fps=30,split[a][b];" +
  "[a]scale=-2:1920:flags=bicubic,crop=1080:1920,boxblur=30:3,eq=brightness=-0.12:saturation=1.25[bg];" +
  "[b]hqdn3d=3:2:6:4,scale=1350:760:flags=lanczos,crop=1080:760,unsharp=5:5:0.9:5:5:0," +
  "eq=contrast=1.07:saturation=1.22:gamma=0.97,format=rgba[v];" +
  "[1:v]format=gray,scale=1080:760[m];[v][m]alphamerge[vm];" +
  "[bg][vm]overlay=0:700:shortest=1[base];" +
  "[2:v]format=rgba,fade=in:st=0.3:d=0.8:alpha=1[tx];" +
  "[base][tx]overlay=0:0:shortest=1,fade=in:st=0:d=0.4,fade=out:st=18.3:d=0.5,format=yuv420p[out]") `
  -map "[out]" -map 3:a -shortest -c:v libx264 -crf 18 -preset slow -movflags +faststart -c:a aac -b:a 128k `
  "$f\historia-fertilizacion.mp4"

Get-Item "$f\historia-fertilizacion.mp4" | Select-Object Name, @{n='MB';e={[math]::Round($_.Length/1MB,1)}}
