<div align="center">
  <h1 style="color: #00bcd4;">Remnawave Auto-Installer</h1>
  <p>Professional script for automatic installation of Remnawave panel and node connection on Linux</p>
  <img src="https://github.com/AsanFillter/Remnawave-AutoSetup/blob/8ebe16c44b64d2e0e7a81c20613a625fad68805e/remnawave_screenshot.png?raw=true" alt="Remnawave Screenshot" style="width: 80%; max-width: 800px; margin: 20px 0;">
  
  <!-- License, Version, and Platform badges -->
  <div style="display: flex; justify-content: center; gap: 15px; margin-top: 20px;">
    <img src="https://img.shields.io/badge/Platform-Linux-brightgreen" alt="Linux">
    <img src="https://img.shields.io/badge/Version-v0.1%20(Beta)-orange" alt="Version">
    <img src="https://img.shields.io/badge/License-MIT-blue" alt="MIT License">
  </div>

  <br><br>
  <div style="font-size: 14px;">
    <a href="https://github.com/AsanFillter/Remnawave-AutoSetup/blob/main/README.md" style="text-decoration: none; color: #007bff;">English</a> | 
    <a href="https://github.com/AsanFillter/Remnawave-AutoSetup/blob/main/docs/README-fa.md" style="text-decoration: none; color: #007bff;">فارسی</a> | 
    <a href="https://github.com/AsanFillter/Remnawave-AutoSetup/blob/main/docs/README-ru.md" style="text-decoration: none; color: #007bff;">Русский</a> | 
    <a href="https://github.com/AsanFillter/Remnawave-AutoSetup/blob/main/docs/README-zh.md" style="text-decoration: none; color: #007bff;">中文</a>
  </div>
</div>

> **Note**: This project is only for personal learning and communication, please do not use it for illegal purposes, please do not use it in a production environment

## Requirements

- Ubuntu 20.04 or higher
- Minimum 1GB RAM
- 10GB Free Disk Space
- Root access to server
- Valid domain name (for SSL)
- Domain pointed to your server's IP

## Features

- **Security**
  - Advanced Encryption: State-of-the-art encryption protocols for maximum security
  - Anti-Attack System: Built-in protection against DDoS and other cyber attacks
  - IP Hiding: Advanced IP masking and protection features
  - Multi-Layer Security: Multiple security layers to protect your data

- **Performance**
  - High Speed Performance: Optimized for maximum speed and minimal latency
  - Load Balancing: Smart traffic distribution across multiple nodes
  - Unlimited Bandwidth: No restrictions on data transfer
  - Global Network: Access to servers worldwide

- **Management**
  - Easy Panel Management: User-friendly interface for easy administration
  - Real-time Monitoring: Live monitoring of all connections and traffic
  - Auto Configuration: Automatic setup and configuration
  - Multi-User System: Support for multiple user accounts and permissions

- **Technical Features**
  - Docker Integration: Full containerization support with Docker
  - Nginx Integration: Advanced web server configuration with Nginx
  - SSL Certificate: Automatic SSL certificate setup and renewal
  - Node Management: Easy addition and configuration of new nodes
  - Telegram Integration: Built-in Telegram bot for notifications and control

- **Analytics & Reporting**
  - Traffic Analytics: Detailed traffic monitoring and analysis
  - Usage Statistics: Comprehensive usage statistics and reports
  - User Tracking: Monitor user activities and connections
  - System Logs: Detailed system logs for troubleshooting

- **Additional Features**
  - Multi-Language Support: Interface available in multiple languages
  - Regular Updates: Continuous system updates and improvements
  - 24/7 Uptime: Designed for continuous operation
  - Backup System: Automated backup and restore functionality

> **Note**: Requires Ubuntu 20.04 or higher.

---

### Automatic Installation

Run the following command in your terminal to install Remnawave automatically:

```sh
wget -O start.sh https://raw.githubusercontent.com/xGuliyev/Remnawave-AutoSetup/main/start.sh && chmod +x start.sh && ./start.sh
```

<details>
<summary><b>Manual Installation</b></summary>

### Panel Installation Steps

1. Install prerequisites:
```sh
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install -y docker-ce
docker --version
```

2. Create a new file named `jwtgen.py`:
```sh
nano jwtgen.py
```

3. Add the following content to `jwtgen.py`:
```python
import secrets

# Generate JWT_AUTH_SECRET
jwt_auth_secret = secrets.token_hex(32)
print("JWT_AUTH_SECRET:", jwt_auth_secret)

# Generate JWT_API_TOKENS_SECRET
jwt_api_tokens_secret = secrets.token_hex(32)
print("JWT_API_TOKENS_SECRET:", jwt_api_tokens_secret)
```

4. Run the script to generate JWT secrets:
```sh
python3 jwtgen.py
```

5. Save the generated HEX codes for later use.

6. Create a directory for Remnawave and navigate into it:
```sh
mkdir remnawave && cd remnawave
```

7. Download the project configuration file:
```sh
curl -o .env https://raw.githubusercontent.com/remnawave/backend/refs/heads/main/.env.sample
```

8. Edit the configuration file:
```sh
nano .env
```

9. Replace the placeholders with the correct values:
```env
### APP ###
APP_PORT=3000

DATABASE_URL="postgresql://postgres:postgres@remnawave-db:5432/postgres"

### JWT ###
### CHANGE DEFAULT VALUES ###
JWT_AUTH_SECRET=YourFirstHexCode
JWT_API_TOKENS_SECRET=YourSecondHexCode

### TELEGRAM ###
TELEGRAM_BOT_TOKEN=YourTelegramBotToken
TELEGRAM_ADMIN_ID=YourTelegramAdminID
NODES_NOTIFY_CHAT_ID=YourTelegramChatID

### FRONT_END ###
FRONT_END_DOMAIN=*

### SUBSCRIPTION ###
SUB_SUPPORT_URL=https://YourSubdomain
SUB_PROFILE_TITLE=Subscription Profile
SUB_UPDATE_INTERVAL=12
SUB_WEBPAGE_URL=https://YourSubdomain

### SUBSCRIPTION PUBLIC DOMAIN ###
### RAW DOMAIN, WITHOUT HTTP/HTTPS, DO NOT PLACE / to end of domain ###
SUB_PUBLIC_DOMAIN=rw.guilanit.com

EXPIRED_USER_REMARKS=["Subscription expired","Contact support"]
DISABLED_USER_REMARKS=["Subscription disabled","Contact support"]
LIMITED_USER_REMARKS=["Subscription limited","Contact support"]

### SUPERADMIN ###
### CHANGE DEFAULT VALUES ###
SUPERADMIN_USERNAME=YourAdminUsername
SUPERADMIN_PASSWORD=YourAdminPassword

### SWAGGER ###
SWAGGER_PATH=/docs
SCALAR_PATH=/scalar
IS_DOCS_ENABLED=true

### PROMETHEUS ###
METRICS_USER=admin
METRICS_PASS=admin

### WEBHOOK ###
WEBHOOK_ENABLED=true
### Only https:// is allowed
WEBHOOK_URL=https://webhook.site/1234567890
### This secret is used to sign the webhook payload, must be exact 64 characters. Only a-z, 0-9, A-Z are allowed.
WEBHOOK_SECRET_HEADER=vsmu67Kmg6R8FjIOF1WUY8LWBHie4scdEqrfsKmyf4IAf8dY3nFS0wwYHkhh6ZvQ

### CLOUDFLARE ###
# USED ONLY FOR docker-compose-prod-with-cf.yml
# NOT USED BY THE APP ITSELF
CLOUDFLARE_TOKEN=ey...

### Database ###
### For Postgres Docker container ###
# NOT USED BY THE APP ITSELF
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=postgres
```

10. Create the Docker Compose file:
```sh
nano docker-compose.yml
```

11. Add the following content to `docker-compose.yml`:
```yaml
services:
    remnawave-db:
        image: postgres:17
        container_name: 'remnawave-db'
        hostname: remnawave-db
        restart: always
        env_file:
            - .env
        environment:
            - POSTGRES_USER=${POSTGRES_USER}
            - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
            - POSTGRES_DB=${POSTGRES_DB}
            - TZ=UTC
        ports:
            - '127.0.0.1:6767:5432'
        volumes:
            - remnawave-db-data:/var/lib/postgresql/data
        networks:
            - remnawave-network
        healthcheck:
            test: ['CMD-SHELL', 'pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}']
            interval: 3s
            timeout: 10s
            retries: 3

    remnawave:
        image: remnawave/backend:latest
        container_name: 'remnawave'
        hostname: remnawave
        restart: always
        ports:
            - '127.0.0.1:3000:3000'
        env_file:
            - .env
        networks:
            - remnawave-network

networks:
    remnawave-network:
        name: remnawave-network
        driver: bridge
        external: false

volumes:
    remnawave-db-data:
        driver: local
        external: false
        name: remnawave-db-data
```

12. Run the following command to start the containers:
```sh
docker compose up -d
```

13. Check the logs to ensure everything is running correctly:
```sh
docker compose logs -f
```

### Node Setup Instructions

After installing the main panel, create a new virtual server with your desired location.

1. First, install Docker on your server:
```sh
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install -y docker-ce
docker --version
```

2. Update your server:
```sh
sudo apt update && apt upgrade -y
```

3. Create a directory for the Node and create a Docker file:
```sh
mkdir /remnanode && cd /remnanode && nano docker-compose.yml
```

4. Add the following content to `docker-compose.yml`:
```yaml
services:
  remnanode:
    container_name: remnanode
    hostname: remnanode
    image: remnawave/node:latest
    env_file:
      - .env
    network_mode: host
```

5. Create and edit the .env file:
```sh
nano .env
```

6. Go to your panel and add a Node. Click on "Important information" and copy the key. Add it to your .env file:
```env
### APP ###
APP_PORT=2222
```

7. Start the Docker container and check the logs:
```sh
docker compose up -d && docker compose logs -f
```

</details>

## Contributions

Contributions are always welcome! Here's how you can help:

- Report bugs or issues
- Suggest new features
- Improve documentation
- Review code changes

## Support

[![Watch the tutorial video](https://github.com/AsanFillter/Remnawave-AutoSetup/raw/main/img/thumbnail.jpg)](https://www.youtube.com/watch?v=AM2ppG1kTFI)

If you find this project useful, please consider giving it a star on GitHub!

- **Telegram Channel:** [@AsanFillter](https://t.me/AsanFillter)  
- **Telegram Group:** [@AsanFillter_Group](https://t.me/asanfillter_group)

For more information and documentation, please visit the [official Remnawave site](https://remna.st/).
