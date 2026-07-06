# Detecta la IP real de este equipo en la red local (LAN), evitando adaptadores
# virtuales (Docker, WSL, VirtualBox, VPN) que no son alcanzables desde otros equipos.
# Usada por iniciar_servidor.bat antes de levantar los contenedores.

$ip = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.PrefixOrigin -eq 'Dhcp' -and $_.IPAddress -notlike '169.254.*'
} | Select-Object -First 1 -ExpandProperty IPAddress

if (-not $ip) {
    $ip = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
        $_.IPAddress -notlike '169.254.*' -and
        $_.IPAddress -ne '127.0.0.1' -and
        $_.InterfaceAlias -notmatch 'Loopback|vEthernet|Docker|VirtualBox|VMware|Tailscale'
    } | Select-Object -First 1 -ExpandProperty IPAddress
}

if (-not $ip) { $ip = '127.0.0.1' }

Write-Output $ip
