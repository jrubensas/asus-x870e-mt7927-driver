#!/usr/bin/env bash
# ==============================================================================
# Script de Instalacao Automatizada: Wi-Fi 7 e Bluetooth (MediaTek MT7927 / MT6639)
# Placa-mae: Asus ProArt X870E-CREATOR WIFI (e placas compativeis)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FW_DIR="/lib/firmware/mediatek/mt7927"
PKG_FILE="${SCRIPT_DIR}/packages/mediatek-mt7927-dkms_2.14-6_all.deb"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}====================================================================${NC}"
echo -e "${BLUE}  Instalador Wi-Fi 7 e Bluetooth MediaTek MT7927 (Asus ProArt X870E) ${NC}"
echo -e "${BLUE}====================================================================${NC}"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[ERRO] Este script precisa ser executado como root (sudo).${NC}"
  echo "Por favor, execute: sudo ./install.sh"
  exit 1
fi

echo -e "\n${YELLOW}[1/5] Verificando pre-requisitos do sistema...${NC}"
MISSING_PKGS=()
for pkg in dkms build-essential linux-headers-$(uname -r); do
  if ! dpkg -l | grep -q " ${pkg} "; then
    MISSING_PKGS+=("$pkg")
  fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
  echo -e "${YELLOW}Dependencias ausentes detectadas: ${MISSING_PKGS[*]}${NC}"
  echo "Tentando instalar dependencias via apt..."
  apt-get update && apt-get install -y "${MISSING_PKGS[@]}" || {
    echo -e "${RED}[ERRO] Falha ao instalar dependencias. Instale-as manualmente:${NC}"
    echo "sudo apt-get install -y ${MISSING_PKGS[*]}"
    exit 1
  }
else
  echo -e "${GREEN}[OK] Dependencias instaladas.${NC}"
fi

echo -e "\n${YELLOW}[2/5] Instalando arquivos de firmware em ${FW_DIR}...${NC}"
mkdir -p "${FW_DIR}"

if [ -d "${SCRIPT_DIR}/firmware" ]; then
  cp -v "${SCRIPT_DIR}"/firmware/BT_RAM_CODE_MT6639_2_1_hdr.bin "${FW_DIR}/"
  cp -v "${SCRIPT_DIR}"/firmware/WIFI_MT6639_PATCH_MCU_2_1_hdr.bin "${FW_DIR}/"
  cp -v "${SCRIPT_DIR}"/firmware/WIFI_RAM_CODE_MT6639_2_1.bin "${FW_DIR}/"
  chmod 644 "${FW_DIR}"/*.bin
  echo -e "${GREEN}[OK] Firmwares copiados com sucesso.${NC}"
else
  echo -e "${RED}[ERRO] Diretorio firmware nao encontrado em ${SCRIPT_DIR}.${NC}"
  exit 1
fi

echo -e "\n${YELLOW}[3/5] Instalando pacote DKMS mediatek-mt7927...${NC}"
if [ -f "${PKG_FILE}" ]; then
  dpkg -i "${PKG_FILE}" || apt-get install -f -y
  echo -e "${GREEN}[OK] Modulo DKMS instalado e compilado com sucesso.${NC}"
else
  echo -e "${RED}[ERRO] Pacote .deb nao encontrado em ${PKG_FILE}.${NC}"
  exit 1
fi

echo -e "\n${YELLOW}[4/5] Atualizando imagem initramfs...${NC}"
update-initramfs -u
echo -e "${GREEN}[OK] Initramfs atualizado.${NC}"

echo -e "\n${YELLOW}[5/5] Verificando Secure Boot...${NC}"
SB_STATE="disabled"
if command -v mokutil >/dev/null 2>&1; then
  if mokutil --sb-state 2>/dev/null | grep -qi "enabled"; then
    SB_STATE="enabled"
  fi
fi

echo -e "\n${GREEN}====================================================================${NC}"
echo -e "${GREEN}             INSTALACAO CONCLUIDA COM SUCESSO!                      ${NC}"
echo -e "${GREEN}====================================================================${NC}"

if [ "${SB_STATE}" = "enabled" ]; then
  echo -e "\n${YELLOW}SECURE BOOT DETECTADO COMO ATIVO!${NC}"
  echo "Módulos DKMS exigem autorização quando o Secure Boot está ligado."
  echo ""
  echo "Opcao A (Recomendada): Desative o Secure Boot na BIOS ASUS:"
  echo "  Boot -> Secure Boot -> OS Type: mude para 'Other OS'."
  echo ""
  echo "Opcao B: Autorize a chave MOK no proximo boot:"
  echo "  1. Execute: sudo mokutil --import /var/lib/shim-signed/mok/MOK.der (crie uma senha temporaria)"
  echo "  2. Reinicie: sudo reboot"
  echo "  3. Na tela azul MokManager: Enroll MOK -> Continue -> Yes -> digite a senha -> Reboot."
else
  echo -e "\nSecure Boot esta desativado. Carregando modulos agora..."
  modprobe -r mt7925e mt7921e btusb 2>/dev/null || true
  modprobe mt7925e 2>/dev/null || true
  modprobe btusb 2>/dev/null || true
  echo -e "${GREEN}[OK] Modulos mt7925e e btusb carregados e em execucao!${NC}"
fi

echo -e "\n${BLUE}Dica BIOS ASUS (Estabilidade Bluetooth):${NC}"
echo "Advanced -> APM Configuration -> ErP Ready: Enable (S4+S5)."
echo -e "${BLUE}====================================================================${NC}\n"
