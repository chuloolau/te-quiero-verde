# Video de presentación "Identidad visual Te Quiero Verde" (1080x1920, 30 fps).
# 1) Renderiza las 10 escenas de escenas.html con Edge. 2) Cada escena con zoom lento. 3) Une con fundidos.
$ErrorActionPreference = 'Continue'
$p = $PSScriptRoot
$ff = (Get-Command ffmpeg).Source
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$url = 'file:///' + ($p -replace '\\', '/') + '/escenas.html'

# duración de cada escena en segundos
$dur = @(3.5, 4, 3.5, 3.5, 4.5, 4, 4, 4, 4, 5)
$fade = 0.6

for ($i = 1; $i -le $dur.Count; $i++) {
  & $edge --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 --allow-file-access-from-files `
    --window-size=1080,1920 --virtual-time-budget=15000 "--screenshot=$p\escena-$i.png" "$url#e$i" 2>$null | Out-Null
  $n = [int]($dur[$i - 1] * 30)
  & $ff -y -loglevel error -loop 1 -framerate 30 -i "$p\escena-$i.png" -filter_complex (
    "[0:v]scale=2160:3840:flags=lanczos,zoompan=z='1+0.035*on/$n':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=1080x1920:fps=30,format=yuv420p[v]") `
    -map "[v]" -frames:v $n -c:v libx264 -crf 18 -preset medium "$p\tmp-$i.mp4"
}

# cadena de xfade
$inputs = @(); for ($i = 1; $i -le $dur.Count; $i++) { $inputs += '-i'; $inputs += "$p\tmp-$i.mp4" }
$fc = ''; $prev = '[0:v]'; $off = 0
for ($i = 1; $i -lt $dur.Count; $i++) {
  $off += $dur[$i - 1] - $fade
  $out = if ($i -eq $dur.Count - 1) { '[v]' } else { "[x$i]" }
  $fc += "$prev[$($i):v]xfade=transition=fade:duration=$($fade):offset=$([math]::Round($off,2))$out;"
  $prev = "[x$i]"
}
$fc = $fc.TrimEnd(';') + ';[v]fade=in:st=0:d=0.5,format=yuv420p[vf]'
& $ff -y -loglevel error @inputs -f lavfi -i anullsrc=r=44100:cl=stereo -filter_complex $fc `
  -map '[vf]' -map "$($dur.Count):a" -shortest -c:v libx264 -crf 18 -preset medium -movflags +faststart -c:a aac -b:a 128k `
  "$p\identidad-visual-te-quiero-verde.mp4"

Remove-Item "$p\tmp-*.mp4"
Get-Item "$p\identidad-visual-te-quiero-verde.mp4" | Select-Object Name, @{n='MB';e={[math]::Round($_.Length/1MB,1)}}
