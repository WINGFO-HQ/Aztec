# Aztec Sequencer Node Automatic Installer

This script automates the installation process of an Aztec Sequencer Node on Ubuntu servers. It handles all the necessary steps from system updates to node configuration and startup.

## Features

- Automatic system updates and prerequisite installation
- Docker installation if not already present
- Aztec Sandbox installation and configuration
- Automatic server IP detection
- Custom port configuration
- One-click node deployment

## Requirements

- Ubuntu server
- Minimum hardware specifications:
  - 8 Core CPU
  - 16 GB RAM
  - 1 TB NVMe SSD
  - 25 Mbps up/down bandwidth

## Installation

1. Download the installation script:

```bash
wget https://raw.githubusercontent.com/WINGFO-HQ/Aztec/refs/heads/main/aztec.sh && chmod +x aztec.sh && ./aztec.sh
```

2. Follow the on-screen prompts to configure your node:
   - Confirm or enter your server IP
   - Enter your Ethereum private key
   - Configure custom ports (optional)

## Usage

After installation, your Aztec Sequencer Node will start automatically. Here are some useful commands for managing your node:

- Check node logs:

```bash
cd $HOME/aztec-sequencer && docker-compose logs -f
```

- Stop the node:

```bash
cd $HOME/aztec-sequencer && docker compose down -v
```

- Restart the node:

```bash
cd $HOME/aztec-sequencer && docker restart aztec-sequencer
```

## Customization

During installation, you can customize:

- Network endpoints (Ethereum RPC and Beacon API)
- TCP/UDP ports (default: 40400)
- HTTP port (default: 8080)

All configuration is stored in the `~/aztec-sequencer/.env` and `~/aztec-sequencer/docker-compose.yml` files.

## Troubleshooting

If you encounter any issues:

1. Check the node logs for error messages
2. Ensure your server meets the minimum hardware requirements
3. Verify your Ethereum private key is valid
4. Check if the specified ports are open in your firewall

## Support

For help and support, please refer to the [official Aztec Network documentation](https://docs.aztec.network/next/the_aztec_network/guides/run_nodes/how_to_run_sequencer).

## License

This script is provided under the MIT License. Feel free to modify and distribute it.
