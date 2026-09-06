# Driver e Firmware Wi-Fi 7 + Bluetooth (MediaTek MT7927 / MT6639)
### Placa-mãe ASUS ProArt X870E-CREATOR WIFI (Ubuntu / Debian)

Este repositório contém os pacotes compilados, firmwares originais extraídos e scripts automatizados para instalar e habilitar com facilidade o **Wi-Fi 7** e o **Bluetooth 5.4** do chipset **MediaTek MT7927 (Filogic 380)** no Linux (Ubuntu 24.04, 26.04 e distribuições baseadas em Debian).

---

## 📋 Dispositivos Suportados

| Componente | Chipset | ID do Dispositivo | Driver Utilizado |
|---|---|---|---|
| **Wi-Fi 7 (PCIe)** | MediaTek MT7927 (Filogic 380) | `14c3:7927` | `mt7925e` (DKMS patched) |
| **Bluetooth (USB)** | MediaTek MT6639 (Foxconn) | `0489:e13a` | `btusb` / `btmtk` (DKMS patched) |

---

## 📦 Conteúdo do Repositório

- `packages/mediatek-mt7927-dkms_2.14-6_all.deb`: Pacote DKMS pronto para compilar automaticamente os módulos `mt7925e`, `mt76`, `btusb` e `btmtk` de acordo com o kernel instalado.
- `firmware/`:
  - `BT_RAM_CODE_MT6639_2_1_hdr.bin` (Firmware Bluetooth)
  - `WIFI_MT6639_PATCH_MCU_2_1_hdr.bin` (Patch MCU Wi-Fi)
  - `WIFI_RAM_CODE_MT6639_2_1.bin` (RAM Code Wi-Fi)
- `install.sh`: Script de instalação automatizada com checagem de dependências, cópia de firmwares, compilação DKMS e atualização do initramfs.
- `uninstall.sh`: Script para remoção limpa caso necessário.

---

## 🚀 Instalação Rápida (Passo a Passo)

### 1. Clonar o repositório ou baixar os arquivos
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
1. Verificação e instalação de dependências (`dkms`, `build-essential`, `linux-headers`).
2. Cópia dos firmwares para `/lib/firmware/mediatek/mt7927/`.
3. Instalação e compilação do módulo DKMS para o seu kernel atual.
4. Regeneração da imagem `/boot/initrd.img` com `update-initramfs -u`.

---

## 🔐 Atenção ao Secure Boot (MokManager)

Se o **Secure Boot** estiver ativado na sua placa-mãe, os novos módulos de kernel foram assinados com a chave MOK local do sistema. Para que o Linux autorize o carregamento:

1. Reinicie o computador:
   ```bash
   sudo reboot
   ```
2. Ao ligar a máquina, aparecerá uma tela azul com o título:
   **"Perform MOK management"** (Pressione qualquer tecla antes de terminar a contagem de 10 segundos).
3. No menu exibido:
   - Escolha **Enroll MOK**
   - Escolha **Continue**
   - Escolha **Yes**
   - Digite sua senha de administrador (`sudo`)
   - Selecione **Reboot**

Após reiniciar, os drivers serão autorizados e carregarão normalmente.

---

## ⚙️ Dica Essencial na BIOS ASUS (Estabilidade Bluetooth)

Em placas-mãe ASUS com chip MT6639, após suspensão ou desligamento normal, a alimentação de standby das portas USB pode deixar o firmware do Bluetooth bloqueado.

**Solução recomendada na BIOS:**
1. Reinicie e aperte a tecla `DEL` ou `F2` para entrar na BIOS ASUS.
2. Vá em **Advanced Mode** (F7) -> **Advanced** -> **APM Configuration**.
3. Encontre a opção **ErP Ready** e altere para **Enable (S4+S5)**.
4. Pressione `F10` para salvar e reiniciar.

Isso desliga completamente a energia residual de standby ao desligar o PC, garantindo que o chip Bluetooth sempre inicialize a frio de forma limpa.

---

## 🔍 Comandos de Verificação

Para confirmar se o hardware está funcionando corretamente:

- **Verificar driver de rede Wi-Fi:**
  ```bash
  lspci -nnk -d 14c3:7927
  ```
  *(Deve exibir: `Kernel driver in use: mt7925e`)*

- **Listar interfaces de rede sem fio:**
  ```bash
  ip link
  ```
  *(Deve listar a interface sem fio, ex: `wlan0` ou `wlp10s0`)*

- **Verificar Bluetooth:**
  ```bash
  bluetoothctl show
  ```

- **Logs do kernel:**
  ```bash
  dmesg | grep -iE 'mt7925|mt7927|btmtk|mt6639'
  ```
