#!/usr/bin/env bash
# ==============================================================================
# Script de Desinstalacao: Wi-Fi 7 e Bluetooth MediaTek MT7927
# ==============================================================================

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Execute como root: sudo ./uninstall.sh"
  exit 1
fi

echo "Removendo pacote DKMS mediatek-mt7927..."
dpkg -r mediatek-mt7927-dkms 2>/dev/null || dkms remove mediatek-mt7927/2.14 --all || true

echo "Removendo firmwares de /lib/firmware/mediatek/mt7927..."
rm -rf /lib/firmware/mediatek/mt7927

echo "Atualizando initramfs..."
update-initramfs -u

echo "Desinstalacao concluida."
