# 🐧 Linux Standby Off (Debian/Ubuntu)

Script robusto para desativar permanentemente a suspensão, hibernação e o desligamento de tela em servidores e estações de trabalho (PDV) que rodam Debian ou Ubuntu.

## 🎯 Por que usar este script?
Em ambientes de servidor ou terminais de venda (PDV), o modo de espera pode causar desconexão de banco de dados, interrupção de serviços Java/Node e perda de acesso remoto via SSH. Este script blinda o sistema contra esses eventos em múltiplos níveis.

## 🔧 O que o script faz:

### 1. Nível de Sistema (systemd)
- **Mascaramento Total:** Bloqueia as unidades `suspend`, `hibernate`, `hybrid-sleep` e `suspend-then-hibernate`.
- **Configuração de Sleep:** Ajusta o `/etc/systemd/sleep.conf` para garantir que `AllowSuspend=no` e outros parâmetros de repouso sejam aplicados.

### 2. Nível de Hardware (logind)
- **Interação Física:** Configura o sistema para ignorar o fechamento da tampa do notebook (`HandleLidSwitch`) e botões físicos de Power/Sleep no gabinete.

### 3. Nível de Kernel (GRUB)
- **Console Persistente:** Adiciona `consoleblank=0` aos parâmetros do GRUB, impedindo que o monitor apague no terminal (tty) após inatividade.

### 4. Nível Gráfico (X11/LXQt)
- **Prevenção de DPMS:** Desativa o protetor de tela e a economia de energia do monitor caso o sistema possua interface gráfica instalada.

## 🚀 Como usar:

1. **Baixe ou crie o arquivo:**
   ```bash
   nano linux-standby-off.sh
   ```
   *(Cole o código do script e salve com Ctrl+O / Ctrl+X)*

2. **Dê permissão de execução:**
   ```bash
   chmod +x linux-standby-off.sh
   ```

3. **Execute como root:**
   ```bash
   sudo ./linux-standby-off.sh
   ```

4. **Reinicie o sistema:**
   Para que as alterações do GRUB e do Kernel entrem em vigor, é recomendado um reboot:
   ```bash
   sudo reboot
   ```

## ⚠️ Requisitos
- Sistemas baseados em Debian (Debian 10+, Ubuntu 20.04+, etc).
- Privilégios de `sudo` ou `root`.
___
## ✅ Compatibilidade
O script foi projetado para ser agnóstico à distribuição, desde que utilize **systemd** e **GRUB**:
- **Sistemas Base Debian:** Ubuntu, Debian, Mint, Kali, Raspberry Pi OS.
- **Sistemas Base RHEL:** Fedora, CentOS, AlmaLinux (via grub-mkconfig).
- **Ambientes Gráficos:** LXQt, XFCE, GNOME, KDE (via xset/DPMS).
---
*Desenvolvido para garantir a alta disponibilidade de serviços críticos e PDVs.*


