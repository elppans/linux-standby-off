#!/bin/bash

# Debian Server, configurar Power Settings

LOGIND_CONF="/etc/systemd/logind.conf"
HANDLE_LID_SWITCH="HandleLidSwitch=ignore"

# Desativar hibernação
sudo systemctl mask systemd-hibernate.service

# Desativar suspensão
sudo systemctl mask systemd-suspend.service

# Para um bloqueio total
sudo systemctl mask hybrid-sleep.target suspend-then-hibernate.target

# Verificar se HandleLidSwitch existe e ajustar
if [ -f "$LOGIND_CONF" ]; then
    if grep -q "^$HANDLE_LID_SWITCH" "$LOGIND_CONF"; then
        echo "HandleLidSwitch already set to ignore."
    else
        sudo sed -i "/^#*\s*HandleLidSwitch/c$HANDLE_LID_SWITCH" "$LOGIND_CONF"
        echo "HandleLidSwitch set to ignore."
    fi
else
    echo "$LOGIND_CONF not found."
fi

# Outras opções de hardware no logind.conf
add_to_logind() {
    local key=$1
    sudo sed -i "/^#*\s*$key/c$key=ignore" "$LOGIND_CONF"
}

add_to_logind "HandlePowerKey"
add_to_logind "HandleSuspendKey"
add_to_logind "HandleHibernateKey"
add_to_logind "HandleLidSwitchExternalPower"
add_to_logind "HandleLidSwitchDocked"

# Recarregar as configurações do systemd
sudo systemctl daemon-reload

# Ubuntu Server, desativar Standby

CONFIG_FILE="/etc/systemd/sleep.conf"

# Verifica se o arquivo de configuração existe
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Arquivo $CONFIG_FILE não encontrado. Criando o arquivo..."
    sudo touch "$CONFIG_FILE"
fi

if ! grep -q "^\[Sleep\]" "$CONFIG_FILE"; then
    echo "[Sleep]" | sudo tee "$CONFIG_FILE" > /dev/null
fi

# Função para adicionar ou ajustar configuração
add_or_update_config() {
    local key=$1
    local value=$2
    if grep -q "^#$key" "$CONFIG_FILE"; then
        # Descomenta a linha e ajusta o valor
        sudo sed -i "s/^#$key=.*/$key=$value/" "$CONFIG_FILE"
    elif grep -q "^$key" "$CONFIG_FILE"; then
        # Ajusta o valor se já existir
        sudo sed -i "s/^$key=.*/$key=$value/" "$CONFIG_FILE"
    else
        # Adiciona a linha se não existir
        echo "$key=$value" | sudo tee -a "$CONFIG_FILE" > /dev/null
    fi
}

# Adiciona ou ajusta as configurações
add_or_update_config "AllowSuspend" "no"
add_or_update_config "AllowHibernation" "no"
add_or_update_config "AllowSuspendThenHibernate" "no"
add_or_update_config "AllowHybridSleep" "no"

# Reinicia o serviço systemd-logind para aplicar as alterações
sudo systemctl restart systemd-logind


# Desativar o desligamento da tela no terminal (tty)
# Desativar o "blanking" da tela no terminal físico (tty)
# Redirecionamos para /dev/tty1 para afetar o monitor local, mesmo via SSH
if [ -e /dev/tty1 ]; then
    sudo setterm -blank 0 -powersave off -powerdown 0 < /dev/tty1
    echo "Screen blanking desativado para /dev/tty1."
fi

# Garantir persistência no kernel (opcional, mas recomendado)
# Isso desativa o console blanking da tela no terminal a nível de kernel até o próximo reboot
if [ -f /sys/module/kernel/parameters/consoleblank ]; then
    echo 0 | sudo tee /sys/module/kernel/parameters/consoleblank > /dev/null
fi
# Nota: Para que isso seja persistente após o reboot, geralmente é necessário adicionar consoleblank=0 aos parâmetros do GRUB

# --- Configuração de Persistência no GRUB (consoleblank=0) ---

GRUB_FILE="/etc/default/grub"
PARAM="consoleblank=0"

# Função para atualizar o GRUB de forma inteligente (Multi-Distro)
update_grub_smart() {
    echo "Atualizando configurações do carregador de inicialização (GRUB)..."
    
    if command -v update-grub > /dev/null; then
        # Padrão Debian/Ubuntu
        sudo update-grub
    elif command -v grub-mkconfig > /dev/null; then
        # Padrão Fedora/Arch/CentOS
        local grub_path
        # Tenta encontrar o arquivo de config do grub em caminhos comuns
        for path in /boot/grub/grub.cfg /boot/grub2/grub.cfg /boot/efi/EFI/fedora/grub.cfg; do
            if [ -f "$path" ]; then
                grub_path=$path
                break
            fi
        done
        
        if [ -n "$grub_path" ]; then
            sudo grub-mkconfig -o "$grub_path"
        else
            echo "Caminho do grub.cfg não encontrado. Atualize manualmente."
        fi
    else
        echo "Comando de atualização do GRUB não encontrado."
    fi
}

if [ -f "$GRUB_FILE" ]; then
    # Verifica se o parâmetro já está presente na linha de comando do Linux
    if grep -q "$PARAM" "$GRUB_FILE"; then
        echo "O parâmetro $PARAM já existe no GRUB. Nenhuma alteração necessária."
    else
        echo "Adicionando $PARAM aos parâmetros do GRUB..."
        
        # Usa sed para inserir o parâmetro dentro das aspas de GRUB_CMDLINE_LINUX_DEFAULT
        # O comando procura a linha, e antes do fechamento das aspas, insere um espaço e o parâmetro
        sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\"\$/ $PARAM\"/" "$GRUB_FILE"
        
        # Atualiza o arquivo de configuração real do GRUB
	update_grub_smart
    fi
else
    echo "Erro: Arquivo $GRUB_FILE não encontrado."
fi

# Função para desativar economia de energia no ambiente gráfico (X11/LXQt)
disable_graphic_energy_savings() {
    echo "Verificando ambiente gráfico (X11)..."

    # Define o display padrão caso não esteja definido
    export DISPLAY=${DISPLAY:-:0}

    # Verifica se o xset está instalado (pacote x11-xserver-utils)
    if command -v xset > /dev/null; then
        # Tenta aplicar as configurações para o usuário logado no momento
        # s off: Desativa protetor de tela
        # -dpms: Desativa o desligamento físico do monitor
        # s noblank: Impede a tela de ficar preta
        if xset s off -dpms s noblank 2>/dev/null; then
            sudo touch /etc/profile.d/xset_noblank.sh
            sudo chmod +x /etc/profile.d/xset_noblank.sh
            echo -e '#!/bin/bash
            export DISPLAY=${DISPLAY:-:0}
            xset s off -dpms s noblank 2>/dev/null
            ' | sudo tee /etc/profile.d/xset_noblank.sh &>>/dev/null
            echo "Configurações de DPMS/X11 aplicadas com sucesso."
        else
            echo "Não foi possível comunicar com o X11 (o servidor gráfico pode estar desligado)."
        fi
    else
        echo "xset não encontrado. Ignorando configurações de interface gráfica."
    fi
}

# Para rodar a função: 
# Ps.: OPCIONAL, deixe descomentado APENAS se seu sistema tiver GUI e se realmente quer que o monitor fique 100% ativo
disable_graphic_energy_savings

# echo "Configurações de suspensão desativadas com sucesso!"

echo "Configurações de hibernação e suspensão desativadas e HandleLidSwitch configurado."
