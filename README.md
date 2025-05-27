# FRP-Tunnel

<img src="https://ipmart.network/img/layouts/logo/iPmart.png" alt="iPmartNetwork Logo" width="160" />

A minimal, interactive, and production-ready FRP tunnel installer for easy secure tunneling between servers behind NAT or firewalls.

---

## Features

- 🟢 **One script for both server (frps) and client (frpc)**
- ⚡ **Interactive configuration with real values**
- 🚀 **Automatic download and installation of the latest official FRP release**
- 🔒 **Token-based authentication**
- 🔄 **Systemd service integration for always-on tunnel**
- 📜 **Live status and log output after installation**
- 👨‍💻 **100% compatible with modern Linux servers (Ubuntu, Debian, CentOS, etc.)**
- 🪶 **Minimal, reliable, and super easy to use**

---

## ⚡️ Quick Start

### 1. Download & Run on Both Servers

On **both the outside (server) and inside (client) nodes**, simply run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/iPmartNetwork/FRP-Tunnel/master/frp-tunnel.sh)
```

> Make sure you have `curl` installed.  
> You can also clone the repo and run manually:
> ```bash
> git clone https://github.com/iPmartNetwork/FRP-Tunnel.git
> cd FRP-Tunnel
> chmod +x frp-tunnel.sh
> sudo ./frp-tunnel.sh
> ```

### 2. Follow the Interactive Prompts

- **Select node role:**  
  - `1` for Server (frps) – run on your VPS with public IP (outside)
  - `2` for Client (frpc) – run on your home/inside/NAT server
- **Enter the required ports, IPs, tunnel name, and authentication token as prompted.**
- **Wait for installation to finish and see the live tunnel log/status automatically!**

---

## 🧩 Example Usage

#### Example: Expose SSH (port 22) of your inside server at port 2222 on outside VPS

- **On your outside VPS (public IP):**
  - Role: `1` (Server)
  - Listen port: `7000` (or custom)
  - Token: (choose a strong password/token)
- **On your inside/NAT server:**
  - Role: `2` (Client)
  - Server IP: (VPS public IP)
  - Server port: `7000`
  - Token: (must match server)
  - Local service port: `22`
  - Remote bind port: `2222`
  - Tunnel name: `myssh`
  - Protocol: `tcp`

After setup, connect to your SSH via:
```bash
ssh user@<VPS_IP> -p 2222
```

---

## 🔍 How it Works

- **Server (frps):**  
  Listens for frpc connections on your public VPS and forwards incoming connections to the client.
- **Client (frpc):**  
  Connects to your VPS, registering local services (like SSH, HTTP, etc.) to be tunneled through the server.

All configuration is minimal and production-safe.  
Token authentication keeps your tunnel secure.

---

## 🛠️ System Requirements

- Linux x86_64/amd64, arm64, or armv7l (auto-detected)
- sudo/root access
- curl, wget, tar, systemd

---

## 📃 Script Content (Main Steps)

- Architecture detection
- Downloading & installing latest FRP from GitHub
- Creating minimal frps.ini/frpc.ini config
- Registering systemd service (frps or frpc)
- Enabling & starting the service
- Showing live status and logs for immediate troubleshooting

---

## 🧑‍💻 Manual Management

Check status:
```bash
sudo systemctl status frps   # On server
sudo systemctl status frpc   # On client
```

See live logs:
```bash
sudo journalctl -u frps -f   # On server
sudo journalctl -u frpc -f   # On client
```

Restart service:
```bash
sudo systemctl restart frps  # On server
sudo systemctl restart frpc  # On client
```

---

## ❓ FAQ

- **Q: How do I add more tunnels?**  
  Edit `/usr/local/frp/frpc.ini` on the client, add more `[proxy_name]` sections, and restart `frpc`.

- **Q: Is this secure?**  
  Yes. All tunnels use your custom token for authentication and are production-grade.

- **Q: How do I uninstall?**  
  Stop and disable the service, then delete `/usr/local/frp` and `/etc/systemd/system/frp*.service`.

---

## 📜 License

[MIT](LICENSE)

---

## 🙌 Credits

- [fatedier/frp](https://github.com/fatedier/frp)
- [iPmartNetwork](https://github.com/iPmartNetwork)

---

> Developed and maintained by iPmartNetwork Team  
> Fast issues? Suggestions? [Open an Issue](https://github.com/iPmartNetwork/FRP-Tunnel/issues)
