#!/bin/bash

function menu {
    echo "Escolha uma opção:"
    echo "1. Ativar WireGuard"
    echo "2. Desativar WireGuard"
    echo "3. Sair"
}

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
