# Arma el reel "Venta de rollos" (1080x1920, 30 fps) con ffmpeg.
# 3 escenas con zoom lento + texto que aparece, y placa final de contacto.
$ErrorActionPreference = 'Stop'
$r = $PSScriptRoot
$f = Split-Path $r -Parent
$ff = (Get-Command ffmpeg).Source

# escena: foto, recorte 9:16 (x dentro de 960x1280), duración, capa de texto
$esc = @(
  @{ foto = "$f\foto-rollos-fila.jpg";  x = 120; dur = 4.0; capa = "$r\capa1.png" },
  @{ foto = "$f\foto-rollos-pala.jpg";  x = 60;  dur = 3.5; capa = "$r\capa2.png" },
  @{ foto = "$f\foto-rollos-carga.jpg"; x = 40;  dur = 3.5; capa = "$r\capa3.png" }
)
$i = 0
foreach ($e in $esc) {
  $n = [int]($e.dur * 30)
  & $ff -y -loglevel error -loop 1 -framerate 30 -i $e.foto -loop 1 -framerate 30 -i $e.capa -filter_complex (
    "[0:v]crop=720:1280:$($e.x):0,scale=2160:3840:flags=lanczos," +
    "zoompan=z='1+0.10*on/$n':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=1080x1920:fps=30[bg];" +
    "[1:v]format=rgba,fade=in:st=0.35:d=0.6:alpha=1[tx];" +
    "[bg][tx]overlay=0:0,format=yuv420p[v]") -map "[v]" -frames:v $n -c:v libx264 -crf 18 -preset medium "$r\esc$i.mp4"
  $i++
}
# placa final: historia de contacto con un zoom muy leve
& $ff -y -loglevel error -loop 1 -framerate 30 -i "$f\historia-contacto.png" -filter_complex (
  "[0:v]scale=2160:3840:flags=lanczos,zoompan=z='1+0.03*on/120':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=1080x1920:fps=30,format=yuv420p[v]") `
  -map "[v]" -frames:v 120 -c:v libx264 -crf 18 -preset medium "$r\esc3.mp4"

# unir con fundidos de 0.5 s y pista de audio silenciosa (la música se agrega en Instagram)
& $ff -y -loglevel error -i "$r\esc0.mp4" -i "$r\esc1.mp4" -i "$r\esc2.mp4" -i "$r\esc3.mp4" -f lavfi -i anullsrc=r=44100:cl=stereo -filter_complex (
  "[0:v][1:v]xfade=transition=fade:duration=0.5:offset=3.5[a];" +
  "[a][2:v]xfade=transition=slideleft:duration=0.5:offset=6.5[b];" +
  "[b][3:v]xfade=transition=fade:duration=0.5:offset=9.5,format=yuv420p[v]") `
  -map "[v]" -map 4:a -shortest -c:v libx264 -crf 18 -preset medium -movflags +faststart -c:a aac -b:a 128k "$f\reel-venta-rollos.mp4"

Remove-Item "$r\esc*.mp4"
Get-Item "$f\reel-venta-rollos.mp4" | Select-Object Name, @{n='MB';e={[math]::Round($_.Length/1MB,1)}}
