#!/bin/bash

echo "============================================"
echo " WINGFO Aztec Sequencer Node Auto Installer "
echo "============================================"
echo

SERVER_IP=$(curl -s https://ipinfo.io/ip)
echo "Detected server IP: $SERVER_IP"
read -p "Use this IP? (y/n): " use_detected_ip
if [[ "$use_detected_ip" != "y" && "$use_detected_ip" != "Y" ]]; then
    read -p "Enter your VPS/Server IP: " SERVER_IP
fi

read -p "Enter your ETH private key: " ETH_PRIVATE_KEY

echo "Default ports are: 40400 (TCP/UDP) and 8080 (HTTP)"
read -p "Do you want to use custom ports? (y/n): " use_custom_ports

if [[ "$use_custom_ports" == "y" || "$use_custom_ports" == "Y" ]]; then
    read -p "Enter TCP/UDP port (default: 40400): " TCP_UDP_PORT
    read -p "Enter HTTP port (default: 8080): " HTTP_PORT
    
    TCP_UDP_PORT=${TCP_UDP_PORT:-40400}
    HTTP_PORT=${HTTP_PORT:-8080}
else
    TCP_UDP_PORT=40400
    HTTP_PORT=8080
fi

echo "Updating system and installing prerequisites..."
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y

if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y && sudo apt upgrade -y
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    echo "Docker installed successfully!"
else
    echo "Docker is already installed, skipping installation."
fi

echo "Installing Aztec Sandbox..."
curl -s https://install.aztec.network > aztec_install.sh
echo "y" | bash aztec_install.sh
source ~/.bashrc

echo "Updating Aztec Tool..."
if [ -f "/root/.aztec/bin/aztec-up" ]; then
    /root/.aztec/bin/aztec-up alpha-testnet
else
    aztec-up alpha-testnet
fi

echo "Setting up Aztec Sequencer configuration..."
mkdir -p ~/aztec-sequencer
cd ~/aztec-sequencer

echo "Creating .env file..."
echo -e "VALIDATOR_PRIVATE_KEY=${ETH_PRIVATE_KEY}\nP2P_IP=${SERVER_IP}" > .env

echo "Creating docker-compose.yml file with port configuration..."
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  node:
    image: aztecprotocol/aztec:0.85.0-alpha-testnet.5
    container_name: aztec-sequencer
    environment:
      ETHEREUM_HOSTS: "https://ethereum-sepolia-rpc.publicnode.com"
      L1_CONSENSUS_HOST_URLS: "https://ethereum-sepolia-beacon-api.publicnode.com"
      DATA_DIRECTORY: /data
      VALIDATOR_PRIVATE_KEY: \${VALIDATOR_PRIVATE_KEY}
      P2P_IP: \${P2P_IP}
      LOG_LEVEL: debug
    entrypoint: >
      sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --node --archiver --sequencer'
    ports:
      - ${TCP_UDP_PORT}:40400/tcp
      - ${TCP_UDP_PORT}:40400/udp
      - ${HTTP_PORT}:8080
    volumes:
      - /home/my-node/node:/data
    restart: unless-stopped
EOF

echo "Starting Aztec Sequencer Node..."
cd $HOME/aztec-sequencer && docker compose up -d

echo
echo "============================================"
echo "   Aztec Sequencer Node has been installed  "
echo "============================================"
echo
echo "Node details:"
echo "- IP: $SERVER_IP"
echo "- TCP/UDP Port: $TCP_UDP_PORT"
echo "- HTTP Port: $HTTP_PORT"
echo
echo "Useful commands:"
echo "- Check logs: cd $HOME/aztec-sequencer && docker-compose logs -f"
echo "- Stop node: cd $HOME/aztec-sequencer && docker compose down -v"
echo "- Restart node: cd $HOME/aztec-sequencer && docker restart aztec-sequencer"
echo
echo "Your node should now be running. Check logs to ensure everything is working properly."