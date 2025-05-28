# linux-standby-off
## Desativar Suspensão e Hibernação em Servidores Debian e Ubuntu

Este script foi desenvolvido para configurar servidores Debian e Ubuntu, garantindo que não entrem em suspensão ou hibernação. Além disso, ele ajusta diversas configurações do `systemd` para evitar eventos inesperados de desligamento ou standby.

### 🔧 Funcionalidades:
- **Mascaramento de serviços** (`systemd-hibernate.service`, `systemd-suspend.service`, `sleep.target` e `hybrid-sleep.target`) para impedir hibernação e suspensão.
- **Modificação do `logind.conf`** para ignorar ações relacionadas à tampa do notebook e botões de energia (`HandleLidSwitch`, `HandleSuspendKey`, `HandlePowerKey`, `HandleLidSwitchDocked`).
- **Criação e ajuste do arquivo `/etc/systemd/sleep.conf`** garantindo que `AllowSuspend`, `AllowHibernation`, `AllowSuspendThenHibernate`, `AllowHybridSleep` e `AllowSleep` estejam desativados.
- **Backup automático** dos arquivos de configuração antes de modificações.
- **Recarga do `systemd`** e reinício do serviço `systemd-logind` para aplicação imediata das alterações.

### 🚀 Como usar:
1. Copie o código do script e salve em um arquivo chamado `linux-standby-off.sh`.
2. Dê permissão de execução ao script:
   ```bash
   chmod +x linux-standby-off.sh
   ```
3. Execute o script com privilégios de superusuário:
   ```bash
   sudo ./linux-standby-off.sh
   ```

### ⚠️ Observação:
Caso precise restaurar os arquivos de configuração originais, os backups são gerados automaticamente com um timestamp (`backup_DDMMAAAAHHMMSS`). Basta restaurá-los manualmente conforme necessário.

---

