# linux-standby-off
## Desativar Suspensão e Hibernação em Servidores Debian e Ubuntu

Este script é destinado a configurar servidores Debian e Ubuntu para desativar a suspensão e hibernação, além de ajustar a configuração `HandleLidSwitch` para ignorar a tampa do notebook. Ele verifica se os arquivos de configuração necessários existem e ajusta os parâmetros conforme necessário.

#### Funcionalidades:
- Desativa os serviços de hibernação e suspensão.
- Configura `HandleLidSwitch` para ignorar o fechamento da tampa.
- Verifica e cria o arquivo de configuração `/etc/systemd/sleep.conf` se necessário.
- Ajusta ou adiciona as configurações `AllowSuspend`, `AllowHibernation`, `AllowSuspendThenHibernate` e `AllowHybridSleep` para `no`.
- Recarrega as configurações do systemd e reinicia o serviço `systemd-logind`.

#### Como usar:
1. Copie o código do script e salve em um arquivo chamado `configure_power_settings.sh`.
2. Dê permissão de execução ao script:
   ```bash
   chmod +x linux-standby-off.sh
   ```
3. Execute o script com privilégios de superusuário:
   ```bash
   sudo ./linux-standby-off.sh
   ```
