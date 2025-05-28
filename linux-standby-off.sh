#!/bin/bash

# Debian Server, configurar Power Settings

LOGIND_CONF="/etc/systemd/logind.conf"
HANDLE_LID_SWITCH="HandleLidSwitch=ignore"
DATA="$(date +%d%m%Y%H%M%S)"
BKP="backup_$DATA"

# Desativar/Mascarar hibernação
sudo systemctl mask systemd-hibernate.service

# Desativar/mascarar suspensão
sudo systemctl mask systemd-suspend.service

# O sleep.target representa o estado de suspensão do sistema. Quando ativado,
# ele coloca o sistema em um estado de baixo consumo de energia, podendo ser acionado
# manualmente ou por eventos como inatividade prolongada.
sudo systemctl mask sleep.target

# O hybrid-sleep.target combina suspensão e hibernação. Ele salva o estado da memória
# no disco (como na hibernação), mas também mantém o sistema em suspensão temporária.
# Se houver perda de energia, o sistema pode ser restaurado a partir do disco.
sudo systemctl mask hybrid-sleep.target


# Verificar se HandleLidSwitch existe e ajustar
if [ -f "$LOGIND_CONF" ]; then
    sudo cp -a "$LOGIND_CONF" "$LOGIND_CONF.$BKP"
    if grep -q "^$HANDLE_LID_SWITCH" "$LOGIND_CONF"; then
        echo "HandleLidSwitch already set to ignore."
    else
        sudo sed -i "/^#*\s*HandleLidSwitch/c$HANDLE_LID_SWITCH" "$LOGIND_CONF"
        echo "HandleLidSwitch set to ignore."
    fi
    sudo sed -i 's/^#\s*HandleSuspendKey=.*/HandleSuspendKey=ignore/' "$LOGIND_CONF"
    sudo sed -i 's/^#\s*HandlePowerKey=.*/HandlePowerKey=ignore/' "$LOGIND_CONF"
    sudo sed -i 's/^#\s*HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/' "$LOGIND_CONF"
else
    echo "$LOGIND_CONF not found."
fi

# Recarregar as configurações do systemd
sudo systemctl daemon-reload

# Ubuntu Server, desativar Standby

CONFIG_FILE="/etc/systemd/sleep.conf"

# Verifica se o arquivo de configuração existe
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Arquivo $CONFIG_FILE não encontrado. Criando o arquivo..."
    sudo touch "$CONFIG_FILE"
else
    sudo cp -a "$CONFIG_FILE" "$CONFIG_FILE.$BKP"
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
add_or_update_config "AllowSleep" "no"

# Reinicia o serviço systemd-logind para aplicar as alterações
sudo systemctl restart systemd-logind

# echo "Configurações de suspensão desativadas com sucesso!"

echo "Configurações de hibernação e suspensão desativadas e HandleLidSwitch configurado."
