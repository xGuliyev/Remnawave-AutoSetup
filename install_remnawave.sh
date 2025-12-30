#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root (sudo)"
    exit 1
fi

clear

BOLD_PINK=$(tput setaf 5)
BOLD_GREEN=$(tput setaf 2)
LIGHT_GREEN=$(tput setaf 10)
BOLD_BLUE_MENU=$(tput setaf 6)
ORANGE=$(tput setaf 3)
BOLD_RED=$(tput setaf 1)
PURPLE=$(tput setaf 5)
BLUE=$(tput setaf 6)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)

VIRTUAL_SERVER_IP=$(hostname -I | awk '{print $1}')
if [ -z "$VIRTUAL_SERVER_IP" ]; then
    VIRTUAL_SERVER_IP="No IP address found"
fi

CPU_INFO=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d ':' -f 2 | sed 's/^[ \t]*//')
MEMORY_INFO=$(free -h | grep "Mem:" | awk '{print $2}')
DISK_INFO=$(df -h / | awk 'NR==2 {print $2}')

check_internet() {
    echo -ne "${BOLD_BLUE_MENU}Checking internet connection... ${NC}"
    if ping -c 1 google.com &>/dev/null; then
        echo -e "${BOLD_GREEN}Connected${NC}"
        return 0
    else
        echo -e "${BOLD_RED}Not connected${NC}"
        return 1
    fi
}

print_banner() {
    echo -e "${BOLD_PINK}"
    echo "█████╗ ███████╗ █████╗ ███╗   ██╗    ███████╗██╗██╗     ██╗  ████████╗███████╗██████╗ "
    echo "██╔══██╗██╔════╝██╔══██╗████╗  ██║    ██╔════╝██║██║     ██║  ╚══██╔══╝██╔════╝██╔══██╗"
    echo "███████║███████╗███████║██╔██╗ ██║    █████╗  ██║██║     ██║     ██║   █████╗  ██████╔╝"
    echo "██╔══██║╚════██║██╔══██║██║╚██╗██║    ██╔══╝  ██║██║     ██║     ██║   ██╔══╝  ██╔══██╗"
    echo "██║  ██║███████║██║  ██║██║ ╚████║    ██║     ██║███████╗███████╗██║   ███████╗██║  ██║"
    echo "╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝    ╚═╝     ╚═╝╚══════╝╚══════╝╚═╝   ╚══════╝╚═╝  ╚═╝"
    echo -e "${NC}"
}

draw_info_box() {
    local width=68
    local title="$1"
    local subtitle="$2"
    
    echo -e "${BOLD_GREEN}"
    printf "┌%s┐\n" "$(printf '─%.0s' $(seq 1 $width))"
    printf "│%-${width}s│\n" "$(printf '%*s' $(( (width + ${#title}) / 2)) "$title")"
    printf "│%-${width}s│\n" "$(printf '%*s' $(( (width + ${#subtitle}) / 2)) "$subtitle")"
    printf "│%-${width}s│\n" ""
    printf "│  • Server IP: ${ORANGE}%s${NC}${BOLD_GREEN}%-$(( width - 25 - ${#VIRTUAL_SERVER_IP} ))s│\n" "$VIRTUAL_SERVER_IP" ""
    printf "│  • Telegram: ${ORANGE}@AsanFillter${NC}${BOLD_GREEN}%-$(( width - 26 ))s│\n" ""
    printf "│  • Version: ${ORANGE}V0.2 (Beta)${NC}${BOLD_GREEN}%-$(( width - 24 ))s│\n" ""
    printf "│%-${width}s│\n" ""
    printf "└%s┘\n" "$(printf '─%.0s' $(seq 1 $width))"
    echo -e "${NC}"
}

animate_text() {
    local text="$1"
    local speed="${2:-0.01}"
    for (( i=0; i<${#text}; i++ )); do
        echo -ne "${text:$i:1}"
        sleep $speed
    done
    echo ""
}

exiting_animation() {
    local text="Exiting"
    for (( i=1; i<=3; i++ )); do
        echo -ne "$text$(printf '.%.0s' $(seq 1 $i))\r"
        sleep 0.5
    done
    echo -e "$text... Done."
}

show_installing_animation() {
    local pid=$!
    local messages=(
        "${ORANGE}The required packages are being installed.${NC}"
        "${ORANGE}The required packages are being installed..${NC}"
        "${ORANGE}The required packages are being installed...${NC}"
    )
    local i=0
    while kill -0 $pid 2>/dev/null; do
        echo -ne "\r${messages[$i]}"
        i=$(( (i+1) % 3 ))
        sleep 0.5
    done
    echo -ne "\r\033[K"
}

show_setup_animation() {
    local pid=$!
    local messages=(
        "${BLUE}The script is performing the required tasks.${NC}"
        "${BLUE}The script is performing the required tasks..${NC}"
        "${BLUE}The script is performing the required tasks...${NC}"
    )
    local i=0
    while kill -0 $pid 2>/dev/null; do
        echo -ne "\r${messages[$i]}"
        i=$(( (i+1) % 3 ))
        sleep 0.5
    done
    echo -ne "\r\033[K"
}

validate_numeric_port() {
    local port="$1"
    if [[ "$port" =~ ^[0-9]+$ && "$port" -ge 1 && "$port" -le 65535 ]]; then
        return 0
    else
        return 1
    fi
}

install_panel() {
    clear
    
    check_internet || {
        echo -e "${BOLD_RED}Error: Internet connection required for installation.${NC}"
        echo -e "\n${ORANGE}Press Enter to return to the main menu...${NC}"
        read
        return 1
    }
    
    (
        sudo apt update -y > /dev/null 2>&1
        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common > /dev/null 2>&1
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - > /dev/null 2>&1
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" > /dev/null 2>&1
        sudo apt update -y > /dev/null 2>&1
        sudo apt install -y docker-ce > /dev/null 2>&1
        docker --version > /dev/null 2>&1
    ) & show_installing_animation
    
    wait $!
    
    clear
    echo -e "${GREEN}Packages installed successfully${NC}"
    sleep 2
    
    echo "import secrets
jwt_auth_secret = secrets.token_hex(32)
print(\"JWT_AUTH_SECRET:\", jwt_auth_secret)
jwt_api_tokens_secret = secrets.token_hex(32)
print(\"JWT_API_TOKENS_SECRET:\", jwt_api_tokens_secret)" > generate_jwt_secrets.py
    
    JWT_OUTPUT=$(python3 generate_jwt_secrets.py)
    JWT_AUTH_SECRET=$(echo "$JWT_OUTPUT" | grep "JWT_AUTH_SECRET" | cut -d' ' -f2)
    JWT_API_TOKENS_SECRET=$(echo "$JWT_OUTPUT" | grep "JWT_API_TOKENS_SECRET" | cut -d' ' -f2)
    rm generate_jwt_secrets.py
    
    mkdir -p remnawave && cd remnawave
    (
        curl -o .env https://raw.githubusercontent.com/remnawave/backend/refs/heads/main/.env.sample
    ) & show_setup_animation
    
    while true; do
        echo -ne "${ORANGE}Enter your Telegram bot token: ${NC}"
        read TELEGRAM_BOT_TOKEN
        echo
        if validate_telegram_token "$TELEGRAM_BOT_TOKEN"; then
            break
        else
            echo -e "${BOLD_RED}Error: Invalid Telegram bot token format. It should look like '123456789:ABCdef...'.${NC}"
        fi
    done
    
    while true; do
        echo -ne "${ORANGE}Enter your Telegram admin ID: ${NC}"
        read TELEGRAM_ADMIN_ID
        echo
        if validate_numeric_id "$TELEGRAM_ADMIN_ID"; then
            break
        else
            echo -e "${BOLD_RED}Error: Admin ID must be a numeric value.${NC}"
        fi
    done
    
    while true; do
        echo -ne "${ORANGE}Enter the chat ID for notifications: ${NC}"
        read NODES_NOTIFY_CHAT_ID
        echo
        if validate_numeric_id "$NODES_NOTIFY_CHAT_ID"; then
            break
        else
            echo -e "${BOLD_RED}Error: Chat ID must be a numeric value.${NC}"
        fi
    done
    
    echo -ne "${PURPLE}Enter the public domain for subscription (e.g., rw.domain.com): ${NC}"
    read SUB_PUBLIC_DOMAIN
    echo
    
    clear
    (
        sed -i "s|JWT_AUTH_SECRET=change_me|JWT_AUTH_SECRET=$JWT_AUTH_SECRET|" .env
        sed -i "s|JWT_API_TOKENS_SECRET=change_me|JWT_API_TOKENS_SECRET=$JWT_API_TOKENS_SECRET|" .env
        sed -i "s|TELEGRAM_BOT_TOKEN=change_me|TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN|" .env
        sed -i "s|TELEGRAM_ADMIN_ID=change_me|TELEGRAM_ADMIN_ID=$TELEGRAM_ADMIN_ID|" .env
        sed -i "s|NODES_NOTIFY_CHAT_ID=change_me|NODES_NOTIFY_CHAT_ID=$NODES_NOTIFY_CHAT_ID|" .env
        sed -i "s|SUB_PUBLIC_DOMAIN=example.com|SUB_PUBLIC_DOMAIN=$SUB_PUBLIC_DOMAIN|" .env
        sed -i '/SUB_SUPPORT_URL/d' .env
        sed -i '/SUB_PROFILE_TITLE/d' .env
        sed -i '/SUB_UPDATE_INTERVAL/d' .env
        sed -i '/SUB_WEBPAGE_URL/d' .env
        sed -i '/EXPIRED_USER_REMARKS/d' .env
        sed -i '/DISABLED_USER_REMARKS/d' .env
        sed -i '/LIMITED_USER_REMARKS/d' .env
        sed -i '/SUPERADMIN_PASSWORD/d' .env
        sed -i '/SUPERADMIN_USERNAME/d' .env
        echo -e "\n### REDIS ###\nREDIS_HOST=remnawave-redis\nREDIS_PORT=6379" >> .env
    ) & show_setup_animation
    
    echo -e "${GREEN}The .env file has been successfully set up.${NC}"
    sleep 3
    clear
    
    cat > docker-compose.yml << 'EOF'
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
            - '127.0.0.1:5432:5432'
        volumes:
            - remnawave-db-data:/var/lib/postgresql/data
        networks:
            - remnawave-network
        healthcheck:
            test: ['CMD-SHELL', 'pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}']
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
        depends_on:
            remnawave-db:
                condition: service_healthy
            remnawave-redis:
                condition: service_healthy

    remnawave-redis:
        image: valkey/valkey:8.0.2-alpine
        container_name: remnawave-redis
        hostname: remnawave-redis
        restart: always
        networks:
            - remnawave-network
        volumes:
            - remnawave-redis-data:/data
        healthcheck:
            test: ['CMD', 'valkey-cli', 'ping']
            interval: 3s
            timeout: 10s
            retries: 3

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
    remnawave-redis-data:
        driver: local
        external: false
        name: remnawave-redis-data
EOF
    
    docker compose pull && docker compose down && docker compose up -d && docker compose logs -f -t > /tmp/docker_logs 2>&1 & LOGS_PID=$!
    sleep 1
    clear
    tail -f /tmp/docker_logs & TAIL_PID=$!
    echo -e "${BOLD_RED}Press enter to continue ...${NC}"
    read
    kill $LOGS_PID $TAIL_PID 2>/dev/null
    wait $LOGS_PID $TAIL_PID 2>/dev/null
    rm -f /tmp/docker_logs
    clear
    
    sudo apt-get install -y cron socat
    
    echo -e "${ORANGE}Installing acme.sh for certificate management...${NC}"
    curl https://get.acme.sh | sh -s email="$EMAIL" > /dev/null 2>&1
    source ~/.bashrc
    export PATH=$PATH:/root/.acme.sh
    
    clear
    echo -ne "${ORANGE}Enter your email address for certificate: ${NC}"
    read EMAIL
    
    if ! command -v acme.sh &>/dev/null; then
        echo -e "${ORANGE}acme.sh not found. Re-installing acme.sh...${NC}"
        curl https://get.acme.sh | sh -s email="$EMAIL" > /dev/null 2>&1
        source ~/.bashrc
        export PATH=$PATH:/root/.acme.sh
    fi
    
    mkdir -p ~/remnawave/nginx && cd ~/remnawave/nginx
    
    echo -e "${YELLOW}Do not use domain zones: .ru, .su, .рф. Currently ZeroSSL does not support these zones.${NC}"
    echo -ne "${ORANGE}Enter your domain for getting certificate: ${NC}"
    read CERT_DOMAIN
    
    if ! echo "$CERT_DOMAIN" | grep -P '^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$' > /dev/null; then
        echo -e "${BOLD_RED}Error: Domain '$CERT_DOMAIN' is not properly formatted. Use a valid domain like 'example.com' or 'sub.domain.com'.${NC}"
        echo -e "\n${ORANGE}Press Enter to try again or return to the main menu...${NC}"
        read
        return 1
    fi
    
    if ! ping -c 1 "$CERT_DOMAIN" &>/dev/null; then
        echo -e "${BOLD_RED}Error: Domain '$CERT_DOMAIN' does not resolve. Please enter a valid public domain.${NC}"
        echo -e "\n${ORANGE}Press Enter to try again or return to the main menu...${NC}"
        read
        return 1
    fi
    
    fuser -k 8880/tcp 2>/dev/null || true
    
    if ! command -v acme.sh &>/dev/null; then
        echo -e "${BOLD_RED}Error: acme.sh is still not available. Aborting certificate issuance.${NC}"
        echo -e "\n${ORANGE}Press Enter to return to the main menu...${NC}"
        read
        return 1
    fi
    
    acme.sh --issue --standalone -d "$CERT_DOMAIN" --key-file ~/remnawave/nginx/privkey.key --fullchain-file ~/remnawave/nginx/fullchain.pem --alpn --tlsport 8880
    
    curl https://ssl-config.mozilla.org/ffdhe2048.txt > ~/remnawave/nginx/dhparam.pem
    
    cat > nginx.conf << EOF
upstream remnawave {
    server 127.0.0.1:3000;
}

map \$http_upgrade \$connection_upgrade {
    default upgrade;
    "" close;
}

server {
    server_name $CERT_DOMAIN;

    listen 8080 ssl reuseport;
    listen [::]:8080 ssl reuseport;
    http2 on;

    location / {
        proxy_http_version 1.1;
        proxy_pass http://remnawave;
        proxy_set_header Host \$host;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Port \$server_port;

        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ecdh_curve X25519:prime256v1:secp384r1;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305;
    ssl_prefer_server_ciphers off;

    ssl_session_timeout 1d;
    ssl_session_cache shared:MozSSL:10m;
    ssl_dhparam "/etc/nginx/ssl/dhparam.pem";
    ssl_certificate "/etc/nginx/ssl/fullchain.pem";
    ssl_certificate_key "/etc/nginx/ssl/privkey.key";

    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate "/etc/nginx/ssl/fullchain.pem";
    resolver 1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4 208.67.222.222 208.67.220.220;

    proxy_hide_header Strict-Transport-Security;
    add_header Strict-Transport-Security "max-age=15552000" always;

    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_min_length 256;
    gzip_types
    application/atom+xml
    application/geo+json
    application/javascript
    application/x-javascript
    application/json
    application/ld+json
    application/manifest+json
    application/rdf+xml
    application/rss+xml
    application/xhtml+xml
    application/xml
    font/eot
    font/otf
    font/ttf
    image/svg+xml
    text/css
    text/javascript
    text/plain
    text/xml;
}

server {
    listen 8080 ssl default_server;
    listen [::]:8080 ssl default_server;
    server_name _;

    ssl_reject_handshake on;
}
EOF
    
    cat > docker-compose.yml << 'EOF'
services:
    remnawave-nginx:
        image: nginx:1.26
        container_name: remnawave-nginx
        hostname: remnawave-nginx
        volumes:
            - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
            - ./dhparam.pem:/etc/nginx/ssl/dhparam.pem:ro
            - ./fullchain.pem:/etc/nginx/ssl/fullchain.pem:ro
            - ./privkey.key:/etc/nginx/ssl/privkey.key:ro
        restart: always
        network_mode: host
EOF
    
    docker compose up -d
    docker compose logs -f -t > /tmp/docker_logs 2>&1 & LOGS_PID=$!
    sleep 1
    clear
    tail -f /tmp/docker_logs & TAIL_PID=$!
    echo -e "${BOLD_RED}Press enter to continue ...${NC}"
    read
    kill $LOGS_PID $TAIL_PID 2>/dev/null
    wait $LOGS_PID $TAIL_PID 2>/dev/null
    rm -f /tmp/docker_logs
    clear
    
    clear
    echo -e "${GREEN}Remnawave panel has been successfully installed and configured${NC}"
    echo
    echo -e "\033[1m┌────────────────────────────────────────────┐\033[0m"
    echo -e "\033[1m│ You can access your panel at:              │\033[0m"
    echo -e "\033[1m│ https://$CERT_DOMAIN                       │\033[0m"
    echo -e "\033[1m└────────────────────────────────────────────┘\033[0m"
    echo
    echo -e "Press enter to exit"
    read
    
    cd ~
    clear
    print_banner
    draw_info_box "Remnawave Panel" "Enhanced Setup v0.2"
}

update_panel() {
    clear
    echo -e "${BOLD_PINK}Updating Remnawave Panel...${NC}"
    sleep 1
    cd ~/remnawave
    cat > docker-compose.yml << 'EOF'
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
            - '127.0.0.1:5432:5432'
        volumes:
            - remnawave-db-data:/var/lib/postgresql/data
        networks:
            - remnawave-network
        healthcheck:
            test: ['CMD-SHELL', 'pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}']
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
        depends_on:
            remnawave-db:
                condition: service_healthy
            remnawave-redis:
                condition: service_healthy

    remnawave-redis:
        image: valkey/valkey:8.0.2-alpine
        container_name: remnawave-redis
        hostname: remnawave-redis
        restart: always
        networks:
            - remnawave-network
        volumes:
            - remnawave-redis-data:/data
        healthcheck:
            test: ['CMD', 'valkey-cli', 'ping']
            interval: 3s
            timeout: 10s
            retries: 3

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
    remnawave-redis-data:
        driver: local
        external: false
        name: remnawave-redis-data
EOF
    (
        sed -i '/SUB_SUPPORT_URL/d' .env
        sed -i '/SUB_PROFILE_TITLE/d' .env
        sed -i '/SUB_UPDATE_INTERVAL/d' .env
        sed -i '/SUB_WEBPAGE_URL/d' .env
        sed -i '/EXPIRED_USER_REMARKS/d' .env
        sed -i '/DISABLED_USER_REMARKS/d' .env
        sed -i '/LIMITED_USER_REMARKS/d' .env
        sed -i '/SUPERADMIN_PASSWORD/d' .env
        sed -i '/SUPERADMIN_USERNAME/d' .env
        echo -e "\n### REDIS ###\nREDIS_HOST=remnawave-redis\nREDIS_PORT=6379" >> .env
    ) & show_setup_animation
    
    local message="Don't worry about the removed variables, they are moved to dashboard settings. Check out \"Subscription Settings\" section in dashboard.\nSuperadmin credentials now is stored in database and you will be prompted to create a superadmin account after updating."
    for (( i=1; i<=5; i++ )); do
        echo -ne "${BOLD_RED}${message}$(printf '.%.0s' $(seq 1 $i))\r"
        sleep 0.5
    done
    echo -e "\n"
    sleep 2
    
    docker compose pull && docker compose down && docker compose up -d && docker compose logs -f -t > /tmp/docker_logs 2>&1 & LOGS_PID=$!
    sleep 1
    clear
    tail -f /tmp/docker_logs & TAIL_PID=$!
    echo -e "${BOLD_RED}Press enter to continue ...${NC}"
    read
    kill $LOGS_PID $TAIL_PID 2>/dev/null
    wait $LOGS_PID $TAIL_PID 2>/dev/null
    rm -f /tmp/docker_logs
    clear
    print_banner
    draw_info_box "Remnawave Panel" "Enhanced Setup v0.2"
}

update_node() {
    clear
    echo -e "${BOLD_PINK}Updating Remnawave Node...${NC}"
    sleep 1
    cd ~/remnanode && docker compose pull && docker compose down && docker compose up -d && docker compose logs -f -t > /tmp/docker_logs 2>&1 & LOGS_PID=$!
    sleep 1
    clear
    tail -f /tmp/docker_logs & TAIL_PID=$!
    echo -e "${BOLD_RED}Press enter to continue ...${NC}"
    read
    kill $LOGS_PID $TAIL_PID 2>/dev/null
    wait $LOGS_PID $TAIL_PID 2>/dev/null
    rm -f /tmp/docker_logs
    clear
    print_banner
    draw_info_box "Remnawave Panel" "Enhanced Setup v0.2"
}

setup_node() {
    clear
    
    check_internet || {
        echo -e "${BOLD_RED}Error: Internet connection required for node setup.${NC}"
        echo -e "\n${ORANGE}Press Enter to return to the main menu...${NC}"
        read
        return 1
    }
    
    (
        sudo dpkg --configure -a > /dev/null 2>&1
        sudo apt update > /dev/null 2>&1
        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common > /dev/null 2>&1
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - > /dev/null 2>&1
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" > /dev/null 2>&1
        sudo apt update > /dev/null 2>&1
        sudo apt install -y docker-ce > /dev/null 2>&1
    ) & show_installing_animation
    
    wait $!
    
    clear
    echo -e "${GREEN}The required packages have been successfully installed.${NC}"
    sleep 2
    
    mkdir -p /remnanode && cd /remnanode
    curl -s https://raw.githubusercontent.com/remnawave/node/refs/heads/main/docker-compose-prod.yml > docker-compose.yml
    
    while true; do
        echo -ne "${ORANGE}Enter your desired port to establish the node connection: ${NC}"
        read NODE_PORT
        echo
        if [ -z "$NODE_PORT" ]; then
            echo -e "${BOLD_RED}Error: Port cannot be empty. Please enter a valid number.${NC}"
        elif validate_numeric_port "$NODE_PORT"; then
            break
        else
            echo -e "${BOLD_RED}Error: Please enter a valid port number between 1 and 65535.${NC}"
        fi
    done
    
    echo -e "${ORANGE}Enter the server certificate (after pasting the contents, press Enter twice to confirm): ${NC}"
    CERTIFICATE=""
    enter_count=0
    while true; do
        read -r line
        if [ -z "$line" ]; then
            enter_count=$((enter_count + 1))
            if [ $enter_count -eq 2 ]; then
                if [ -n "$CERTIFICATE" ]; then
                    break
                else
                    echo -e "${BOLD_RED}Error: Certificate cannot be empty. Please enter the certificate content.${NC}"
                    enter_count=0
                    CERTIFICATE=""
                fi
            fi
        else
            CERTIFICATE="$CERTIFICATE$line\n"
            enter_count=0
        fi
    done
    
    while true; do
        echo -ne "${BOLD_RED}Are you sure the certificate is correct? (y/n): ${NC}"
        read confirm
        echo
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            break
        elif [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
            echo -e "${ORANGE}Enter the server certificate (after pasting the contents, press Enter twice to confirm): ${NC}"
            CERTIFICATE=""
            enter_count=0
            while true; do
                read -r line
                if [ -z "$line" ]; then
                    enter_count=$((enter_count + 1))
                    if [ $enter_count -eq 2 ]; then
                        if [ -n "$CERTIFICATE" ]; then
                            break
                        else
                            echo -e "${BOLD_RED}Error: Certificate cannot be empty. Please enter the certificate content.${NC}"
                            enter_count=0
                            CERTIFICATE=""
                        fi
                    fi
                else
                    CERTIFICATE="$CERTIFICATE$line\n"
                    enter_count=0
                fi
            done
        else
            echo -e "${BOLD_RED}Please enter 'y' or 'n'.${NC}"
        fi
    done
    
    (
        echo -e "### APP ###\nAPP_PORT=$NODE_PORT\n$CERTIFICATE" > .env
    ) & show_setup_animation
    
    docker compose up -d && docker compose logs -f > /tmp/node_logs 2>&1 & LOGS_PID=$!
    sleep 1
    if [ ! -f /tmp/node_logs ]; then
        touch /tmp/node_logs
    fi
    clear
    tail -f /tmp/node_logs & TAIL_PID=$!
    echo -e "${BOLD_RED}Press Enter to continue...${NC}"
    read
    kill $LOGS_PID $TAIL_PID 2>/dev/null
    wait $LOGS_PID $TAIL_PID 2>/dev/null
    rm -f /tmp/node_logs
    
    unset NODE_PORT
    unset CERTIFICATE
    
    clear
    print_banner
    draw_info_box "Remnawave Panel" "Enhanced Setup v0.2"
}

show_system_info() {
    echo -e "\n${BOLD_BLUE_MENU}System Information:${NC}\n"
    
    echo -e "${BOLD_GREEN}Hardware Information:${NC}"
    echo -e "  ${ORANGE}CPU:${NC} $CPU_INFO"
    echo -e "  ${ORANGE}Memory:${NC} $MEMORY_INFO"
    echo -e "  ${ORANGE}Disk:${NC} $DISK_INFO"
    
    echo -e "\n${BOLD_GREEN}Network Information:${NC}"
    echo -e "  ${ORANGE}IP Address:${NC} $VIRTUAL_SERVER_IP"
    echo -e "  ${ORANGE}Hostname:${NC} $(hostname)"
    
    echo -e "\n${BOLD_GREEN}System Status:${NC}"
    echo -e "  ${ORANGE}Uptime:${NC} $(uptime -p)"
    echo -e "  ${ORANGE}Load Average:${NC} $(uptime | awk -F'load average:' '{print $2}')"
    
    echo -e "\n${BOLD_BLUE_MENU}Press Enter to return to the main menu...${NC}"
    read dummy_var
    clear
    print_banner
    draw_info_box "Remnawave Panel" "Enhanced Setup v0.2"
}

update_menu() {
    clear
    print_banner
    draw_info_box "Update Menu" "Select what to update"
    echo -e "${BOLD_PINK}1) Update Panel${NC}"
    echo -e "${BOLD_PINK}2) Update Node${NC}"
    echo -e "${BOLD_PINK}3) Back to Main Menu${NC}"
    echo -en "${BOLD_RED}Please enter your choice [1-3]: ${NC}"
    read choice
    case $choice in
        1)
            update_panel
            ;;
        2)
            update_node
            ;;
        3)
            main
            ;;
        *)
            echo -e "${BOLD_RED}Invalid choice, please try again.${NC}"
            sleep 1
            update_menu
            ;;
    esac
}

main() {
    print_banner
    draw_info_box "Remnawave Panel" "Enhanced Setup v0.2"
    
    while true; do
        echo ""
        animate_text " ${BOLD_GREEN}1) Install & Set Up Remnawave Panel${NC}" 0.02
        echo ""
        animate_text " ${LIGHT_GREEN}2) Set Up Node Automatically${NC}" 0.02
        echo ""
        animate_text " ${BOLD_BLUE_MENU}3) Display System Information${NC}" 0.02
        echo ""
        animate_text " ${BOLD_PINK}4) Update${NC}" 0.02
        echo ""
        animate_text " ${BOLD_RED}5) Exit${NC}" 0.02
        
        echo -e "\n${BOLD_BLUE}───────────────────────────────────────────────${NC}"
        echo -en "${BOLD_RED}Please enter your choice [1-5]: ${NC}"
        read choice
        
        case $choice in
            1)
                install_panel
                ;;
            2)
                setup_node
                ;;
            3)
                show_system_info
                ;;
            4)
                update_menu
                ;;
            5)
                exiting_animation
                break
                ;;
            *)
                clear
                print_banner
                draw_info_box "Remnawave Panel" "Enhanced Setup v0.2"
                echo -e "${BOLD_RED}Invalid choice, please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

validate_telegram_token() {
    local token="$1"
    if [[ "$token" =~ ^[0-9]{8,10}:[A-Za-z0-9_-]{35}$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_numeric_id() {
    local id="$1"
    if [[ "$id" =~ ^[0-9]+$ || "$id" =~ ^-[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

main
