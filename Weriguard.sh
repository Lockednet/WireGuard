#!/bin/bash

# Verifica se o wget está instalado, se não, instala.
if ! command -v wget &> /dev/null; then
    echo "wget não encontrado. Instalando..."
    sudo apt install wget -y
fi

# Função para exibir o menu
function menu {
    echo "Escolha uma opção:"
    echo "1. Ativar WireGuard"
    echo "2. Desativar WireGuard"
    echo "3. Sair"
}

# Função para ativar o WireGuard
function ativar_wireguard {
    echo "Configurando limites de arquivos e ajustes adicionais..."
    sudo apt install wireguard resolvconf curl -y

    IP_PUBLICO=$(curl -4 -s ifconfig.me)

    if [ ! -d "/etc/wireguard" ]; then
        mkdir -p /etc/wireguard
    fi

    cat << EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = OJ/ytNFUAEBcKSi8H7+7M/uk0lsLIjWdkj9Vxa6K6ks=
Address = 172.16.0.2/32
DNS = 1.1.1.1, 1.0.0.1
MTU = 1280
PostUp = ip rule add from $IP_PUBLICO lookup main
PostDown = ip rule delete from $IP_PUBLICO lookup main

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = engage.cloudflareclient.com:2408
EOF

    chmod 600 /etc/wireguard/wg0.conf
    sudo wg-quick up wg0
    sudo wg
    sudo systemctl enable wg-quick@wg0

    echo "WireGuard ativado."
}

# Função para desativar o WireGuard
function desativar_wireguard {
    echo "Desativando WireGuard..."
    sudo wg-quick down wg0
    sudo systemctl disable wg-quick@wg0

    if [ -f /etc/wireguard/wg0.conf ]; then
        sudo rm /etc/wireguard/wg0.conf
        echo "Configuração do WireGuard removida."
    else
        echo "Nenhuma configuração do WireGuard encontrada para remover."
    fi

    echo "WireGuard desativado."
}

# Função para criar o comando weriguard
function criar_comando {
    echo "Criando comando 'weriguard'..."
    echo "#!/bin/bash" > /usr/local/bin/weriguard
    echo "bash <(wget -qO- https://raw.githubusercontent.com/Lockednet/WireGuard/main/Weriguard.sh)" >> /usr/local/bin/weriguard
    chmod +x /usr/local/bin/weriguard
    echo "Comando 'weriguard' criado com sucesso."
}

# Chama a função para criar o comando
criar_comando

# Loop para exibir o menu
while true; do
    menu
    read -p "Digite sua opção: " opcao
    case $opcao in
        1)
            ativar_wireguard
            ;;
        2)
            desativar_wireguard
            ;;
        3)
            echo "Saindo..."
            break
            ;;
        *)
            echo "Opção inválida. Tente novamente."
            ;;
    esac
done
