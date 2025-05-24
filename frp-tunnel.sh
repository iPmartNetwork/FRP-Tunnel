#!/bin/bash

set -e

CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
  ____________________________________________________________________________
      ____                             _     _
 ,   /    )                           /|   /                                 
-----/____/---_--_----__---)__--_/_---/-| -/-----__--_/_-----------__---)__--
 /   /        / /  ) /   ) /   ) /    /  | /    /___) /   | /| /  /   ) /   ) 
_/___/________/_/__/_(___(_/_____(_ __/___|/____(___ _(_ __|/_|/__(___/_/____
                                                    
          FRP Minimal Tunnel Installer
EOF
echo -e "${NC}"

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH_DL="amd64" ;;
    aarch64) ARCH_DL="arm64" ;;
    armv7l) ARCH_DL="arm" ;;
    *) echo -e "${RED}Unsupported architecture: $ARCH${NC}"; exit 1 ;;
esac

# Select role
echo -e "${YELLOW}Select node role:${NC}"
echo "1) Server (frps) [Outside node]"
echo "2) Client (frpc) [Inside/Iran node]"
read -rp "Enter your choice [1/2]: " ROLE

sudo apt update -y
sudo apt install -y wget curl tar > /dev/null

echo -e "${YELLOW}Downloading latest FRP...${NC}"
FRP_VER=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep tag_name | cut -d '"' -f 4 | tr -d 'v')
FRP_FILE="frp_${FRP_VER}_linux_${ARCH_DL}.tar.gz"
FRP_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VER}/${FRP_FILE}"

cd /tmp
wget -q --show-progress $FRP_URL
tar -xzf $FRP_FILE
sudo mkdir -p /usr/local/frp
sudo cp frp_${FRP_VER}_linux_${ARCH_DL}/* /usr/local/frp/
sudo chmod +x /usr/local/frp/frp*

if [[ "$ROLE" == "1" ]]; then
    echo -e "${CYAN}FRPS (Server/Outside) configuration:${NC}"
    read -rp "FRPS listen port [7000]: " FRPS_PORT; FRPS_PORT=${FRPS_PORT:-7000}
    read -rp "FRP authentication token: " FRP_TOKEN

    sudo tee /usr/local/frp/frps.ini > /dev/null <<EOF
[common]
bind_port = $FRPS_PORT
token = $FRP_TOKEN
EOF

    sudo tee /etc/systemd/system/frps.service > /dev/null <<EOF
[Unit]
Description=frps (FRP server)
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/frp/frps -c /usr/local/frp/frps.ini
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable frps
    sudo systemctl restart frps

    echo -e "${GREEN}FRPS is installed and running!${NC}"
    echo -e "${YELLOW}Server public IP: $(curl -s ifconfig.me)"
    echo -e "Tunnel port: $FRPS_PORT"
    echo -e "Token: $FRP_TOKEN${NC}"
    SERVICE="frps"

else
    echo -e "${CYAN}FRPC (Client/Inside) configuration:${NC}"
    read -rp "FRPS server public IP or domain: " FRPS_IP
    read -rp "FRPS port [7000]: " FRPS_PORT; FRPS_PORT=${FRPS_PORT:-7000}
    read -rp "FRP authentication token: " FRP_TOKEN
    read -rp "Local service port (e.g. 22 for SSH): " LOCAL_PORT
    read -rp "Remote bind port (on server, e.g. 2222): " REMOTE_PORT
    read -rp "Tunnel name: " PROXY_NAME
    read -rp "Protocol [tcp/udp] (default tcp): " PROTO; PROTO=${PROTO:-tcp}

    sudo tee /usr/local/frp/frpc.ini > /dev/null <<EOF
[common]
server_addr = $FRPS_IP
server_port = $FRPS_PORT
token = $FRP_TOKEN

[$PROXY_NAME]
type = $PROTO
local_ip = 127.0.0.1
local_port = $LOCAL_PORT
remote_port = $REMOTE_PORT
EOF

    sudo tee /etc/systemd/system/frpc.service > /dev/null <<EOF
[Unit]
Description=frpc (FRP client)
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/frp/frpc -c /usr/local/frp/frpc.ini
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable frpc
    sudo systemctl restart frpc

    echo -e "${GREEN}FRPC is installed and running!${NC}"
    echo -e "${YELLOW}Your local port $LOCAL_PORT is tunneled to $FRPS_IP:$REMOTE_PORT ($PROTO)${NC}"
    SERVICE="frpc"
fi

echo -e "${CYAN}Checking $SERVICE service status...${NC}"
sudo systemctl status $SERVICE --no-pager

echo -e "${CYAN}---- Live $SERVICE logs (Ctrl+C to exit) ----${NC}"
sudo journalctl -u $SERVICE -f
