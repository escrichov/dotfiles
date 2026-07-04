#!/usr/bin/env bash
# Pone los DNS de Cloudflare en el servicio de red ACTIVO (la interfaz de la
# ruta por defecto), en vez de asumir "Wi-Fi" (fallaba por Ethernet/dock).

iface=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')
svc=$(networksetup -listallhardwareports | awk -v i="$iface" '
  /^Hardware Port:/{sub(/^Hardware Port: /,""); port=$0}
  /^Device:/{if ($2==i) print port}')
svc=${svc:-Wi-Fi}

if sudo networksetup -setdnsservers "$svc" 1.1.1.1 1.0.0.1; then
  echo "DNS 1.1.1.1 / 1.0.0.1 aplicados a: $svc"
else
  echo "No se pudo fijar el DNS en el servicio '$svc'"
fi
