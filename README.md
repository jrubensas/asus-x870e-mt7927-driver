# Driver e Firmware Wi-Fi 7 + Bluetooth (MediaTek MT7927 / MT6639)
### Placa-mãe ASUS ProArt X870E-CREATOR WIFI (Ubuntu / Debian)

> **Status:** ✅ **Testado e 100% Funcional** no Ubuntu 26.04 LTS (Kernel 7.0.0-31-generic) e kernels 6.17+.

Este repositório contém os pacotes DKMS compilados, firmwares originais extraídos e scripts automatizados para instalar e habilitar com facilidade o **Wi-Fi 7** e o **Bluetooth 5.4** do chipset **MediaTek MT7927 (Filogic 380)** no Linux (Ubuntu 24.04, 26.04 e distribuições baseadas em Debian).

---

## 📋 Dispositivos Suportados e Confirmados

| Componente | Chipset | ID do Dispositivo | Driver em Uso | Status |
|---|---|---|---|---|
| **Wi-Fi 7 (PCIe)** | MediaTek MT7927 (Filogic 380) | `14c3:7927` | `mt7925e` (DKMS) | ✅ Operacional (2.4/5/6 GHz, 320MHz EHT) |
| **Bluetooth (USB)** | MediaTek MT6639 (Foxconn) | `0489:e13a` | `btusb` / `btmtk` (DKMS) | ✅ Operacional (`hci0`) |

---

## 📦 Conteúdo do Repositório

- `packages/mediatek-mt7927-dkms_2.14-6_all.deb`: Pacote DKMS pronto para compilar automaticamente os módulos `mt7925e`, `mt76`, `btusb` e `btmtk` de acordo com o kernel instalado.
- `firmware/`:
  - `BT_RAM_CODE_MT6639_2_1_hdr.bin` (Firmware Bluetooth MT6639)
  - `WIFI_MT6639_PATCH_MCU_2_1_hdr.bin` (Patch MCU Wi-Fi 7)
  - `WIFI_RAM_CODE_MT6639_2_1.bin` (RAM Code Wi-Fi 7)
- `install.sh`: Script de instalação automatizada em 1 clique (verifica dependências, copia firmwares, compila módulos DKMS e atualiza o initramfs).
- `uninstall.sh`: Script para remoção limpa se necessário.

---

## 🚀 Instalação Rápida (Passo a Passo)

### 1. Clonar o repositório
```bash
git clone https://github.com/jrubensas/asus-x870e-mt7927-driver.git
cd asus-x870e-mt7927-driver
```

### 2. Executar o instalador
Execute o script de instalação com privilégios de superusuário:
```bash
sudo ./install.sh
```

O script realizará automaticamente:
1. Verificação e instalação de dependências (`dkms`, `build-essential`, `linux-headers-$(uname -r)`).
2. Cópia dos firmwares originais para `/lib/firmware/mediatek/mt7927/`.
3. Instalação e compilação do módulo DKMS para o kernel ativo.
4. Regeneração da imagem de boot `/boot/initrd.img` com `update-initramfs -u`.

---

## 🔐 Configuração Importante de Secure Boot

Módulos de terceiros compilados via DKMS são bloqueados pelo Linux se o Secure Boot estiver ativado sem autorização da chave de assinatura (erro: `Key was rejected by service`).

Você tem **duas formas** de resolver isso:

### Opção A (Recomendada e mais simples — Desativar o Secure Boot na BIOS)
1. Reinicie o computador e pressione `DEL` ou `F2` para entrar na BIOS ASUS.
2. Vá em **Boot** ➔ **Secure Boot**.
3. Altere a opção **OS Type** de *"Windows UEFI mode"* para **"Other OS"** (ou desative o Secure Boot).
4. Pressione `F10` para salvar e reiniciar.
> *Ao desativar o Secure Boot, o kernel Linux carrega os módulos `mt7925e` e `btusb` imediatamente sem nenhum bloqueio.*

### Opção B (Manter o Secure Boot ativado — MokManager)
Se você precisa manter o Secure Boot ligado:
1. Importe a chave MOK local do sistema antes de reiniciar:
   ```bash
   sudo mokutil --import /var/lib/shim-signed/mok/MOK.der
   ```
   *(Defina uma senha temporária quando solicitado).*
2. Reinicie o computador: `sudo reboot`.
3. Na inicialização do PC, aparecerá uma tela azul com o título **"Perform MOK management"** (pressione qualquer tecla em até 10 segundos).
4. Selecione: **Enroll MOK** ➔ **Continue** ➔ **Yes** ➔ Digite a senha definida ➔ **Reboot**.

---

## ⚙️ Ajuste Essencial na BIOS ASUS (Estabilidade do Bluetooth)

Em placas-mãe ASUS com chip MT6639, a alimentação em standby das portas USB internas pode deixar o firmware do Bluetooth travado após suspensão ou reinicialização morna (*warm reboot*).

**Configuração recomendada na BIOS ASUS:**
1. Reinicie e aperte `DEL` ou `F2` para entrar na BIOS ASUS.
2. Vá em **Advanced Mode** (F7) ➔ **Advanced** ➔ **APM Configuration**.
3. Encontre a opção **ErP Ready** e altere para **Enable (S4+S5)**.
4. Pressione `F10` para salvar e reiniciar.

Isso desliga completamente a alimentação de standby das portas USB ao desligar o computador, garantindo que o módulo Bluetooth sempre faça uma inicialização a frio limpa.

---

## 🔍 Comandos de Validação

Para confirmar o funcionamento no terminal:

- **Verificar driver de rede Wi-Fi ativo:**
  ```bash
  lspci -nnk -d 14c3:7927
  ```
  *(Confirmação esperada: `Kernel driver in use: mt7925e`)*

- **Verificar status das interfaces de rádio:**
  ```bash
  rfkill list
  ```
  *(Confirmação esperada: `hci0: Bluetooth` e `Wireless LAN` com `Soft blocked: no` e `Hard blocked: no`)*

- **Verificar módulos carregados:**
  ```bash
  lsmod | grep -E 'mt7925|btusb'
  ```

- **Verificar Bluetooth:**
  ```bash
  bluetoothctl show
  ```
