# Genera versiones SVG editables de los flyers (para arrastrar a Figma)
$d = $PSScriptRoot
function B64($f) { [Convert]::ToBase64String([IO.File]::ReadAllBytes("$d\$f")) }
$logo = B64 'logo.jpg'

$flyers = @(
  @{ file='flyer-1-arrancamos'; foto='foto-tractor.jpg'; fx=389.5; dy=0;
     h1=@(@('Arrancamos','#333333'),@('con la','#333333'),@('Siembra','#5BA80A'));
     p=@('Ya estamos en el lote, listos para','que tu cultivo arranque bien','desde el primer día.') },
  @{ file='flyer-2-servicio'; foto='foto-sembradora.jpg'; fx=362; dy=31;
     h1=@(@('Servicio de','#333333'),@('Siembra','#5BA80A'));
     p=@('Siembra directa con equipos de','última generación, regulados para','cada lote y cada cultivo.') }
)

foreach ($f in $flyers) {
  $foto = B64 $f.foto
  $y = 422 + $f.dy   # top del bloque de contenido
  $sb = New-Object Text.StringBuilder
  [void]$sb.Append(@"
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1080" height="1350" viewBox="0 0 1080 1350">
  <defs><clipPath id="clipFoto"><rect x="458" y="0" width="622" height="1350"/></clipPath></defs>
  <rect id="Fondo" width="1080" height="1350" fill="#FFFFFF"/>
  <g id="Foto" clip-path="url(#clipFoto)"><image x="$($f.fx)" y="0" width="759.4" height="1350" preserveAspectRatio="none" xlink:href="data:image/jpeg;base64,$foto"/></g>
  <g id="Franja"><rect x="450" y="0" width="8" height="945" fill="#5BA80A"/><rect x="450" y="945" width="8" height="405" fill="#F5B014"/></g>
  <image id="Logo" x="50" y="64" width="280" height="186" preserveAspectRatio="xMidYMid meet" xlink:href="data:image/jpeg;base64,$logo"/>
  <g id="Eyebrow"><rect x="60" y="$($y+29)" width="40" height="4" rx="2" fill="#F5B014"/>
    <text x="114" y="$($y+38)" font-family="Nunito Sans" font-weight="700" font-size="20" letter-spacing="3" fill="#3F7C05">CAMPAÑA 2026</text></g>
"@)
  $by = $y + 118
  [void]$sb.Append("  <g id=""Titulo"">")
  foreach ($l in $f.h1) { [void]$sb.Append("<text x=""60"" y=""$by"" font-family=""Nunito"" font-weight=""900"" font-size=""60"" letter-spacing=""-0.5"" fill=""$($l[1])"">$($l[0])</text>"); $by += 62.5 }
  [void]$sb.Append("</g>`n")
  $by += 2
  [void]$sb.Append("  <g id=""Bajada"">")
  foreach ($l in $f.p) { [void]$sb.Append("<text x=""60"" y=""$by"" font-family=""Nunito Sans"" font-size=""23"" fill=""#4A4A4A"">$l</text>"); $by += 35.7 }
  [void]$sb.Append("</g>`n")
  $ly = $by + 6
  [void]$sb.Append(@"
  <g id="Lema"><rect x="60" y="$($ly)" width="5" height="65" fill="#F5B014"/>
    <text x="83" y="$($ly+24)" font-family="Nunito" font-weight="800" font-size="25" fill="#3F7C05">Maquinaria moderna y</text>
    <text x="83" y="$($ly+57)" font-family="Nunito" font-weight="800" font-size="25" fill="#3F7C05">equipo comprometido.</text></g>
  <g id="Boton CTA"><rect x="61.5" y="$($ly+106.5)" width="280" height="65" fill="none" stroke="#5BA80A" stroke-width="3"/>
    <text x="97" y="$($ly+147)" font-family="Nunito" font-weight="800" font-size="22" fill="#3F7C05">Pedí tu presupuesto</text></g>
  <g id="Pie Galaro"><rect x="60" y="1208" width="350" height="2" fill="#ECECEC"/>
    <text x="60" y="1253" font-family="Nunito Sans" font-weight="600" font-size="19" fill="#333333"><tspan font-weight="700">Galaro S.A.</tspan> | Servicios agrícolas</text>
    <path transform="translate(60 1268) scale(0.75)" fill="#5BA80A" d="M12 2C8.1 2 5 5.1 5 9c0 5.2 7 13 7 13s7-7.8 7-13c0-3.9-3.1-7-7-7zm0 9.5A2.5 2.5 0 1 1 12 6.5a2.5 2.5 0 0 1 0 5z"/>
    <text x="86" y="1283" font-family="Nunito Sans" font-weight="600" font-size="17" fill="#7A7A7A">Bell Ville, Córdoba</text></g>
</svg>
"@)
  [IO.File]::WriteAllText("$d\$($f.file).svg", $sb.ToString(), (New-Object Text.UTF8Encoding $false))
}
