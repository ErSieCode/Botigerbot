# Komplette Anleitung zum Kryptowährungs-Trading-Bot

## Inhaltsverzeichnis
1. [Überblick](#überblick)
2. [Systemvoraussetzungen](#systemvoraussetzungen)
3. [Installation](#installation)
   - [Windows](#installation-auf-windows)
   - [macOS](#installation-auf-macos)
   - [Linux](#installation-auf-linux)
4. [Projektstruktur](#projektstruktur)
5. [Quellcode und Konfigurationsdateien](#quellcode-und-konfigurationsdateien)
   - [Docker-Compose](#docker-compose)
   - [Backend Dockerfile](#backend-dockerfile)
   - [Frontend Dockerfile](#frontend-dockerfile)
   - [NGINX-Konfiguration](#nginx-konfiguration)
   - [Setup-Skript](#setup-skript)
   - [.env-Datei](#env-datei)
6. [Konfiguration](#konfiguration)
7. [Starten und Betrieb](#starten-und-betrieb)
8. [Nutzung der Anwendung](#nutzung-der-anwendung)
9. [Fehlerbehebung](#fehlerbehebung)
10. [Sicherheitshinweise](#sicherheitshinweise)

## Überblick

Der Kryptowährungs-Trading-Bot ist eine automatisierte Handelsplattform, die aus einem Elixir-Backend und einer Svelte-Frontend-Anwendung besteht. Das System ermöglicht die automatisierte Ausführung von Handelsstrategien auf verschiedenen Kryptowährungsbörsen basierend auf technischen Indikatoren wie RSI, SMA, Bollinger-Bändern und Momentum.

Diese Anleitung führt Sie durch alle notwendigen Schritte zur Installation, Konfiguration und Nutzung des Trading-Bots auf Windows, macOS und Linux.

## Systemvoraussetzungen

### Für alle Betriebssysteme
- Docker und Docker Compose
- Mindestens 4 GB RAM
- Mindestens 10 GB freier Festplattenspeicher
- Internetverbindung
- API-Schlüssel für eine Kryptowährungsbörse (Bitget, Binance, etc.)

### Spezifisch für Windows
- Windows 10/11 (64-bit)
- WSL 2 (Windows Subsystem für Linux)

### Spezifisch für macOS
- macOS Catalina (10.15) oder neuer
- Intel oder Apple Silicon Prozessor

### Spezifisch für Linux
- Eine moderne Linux-Distribution (Ubuntu 20.04+, Debian 11+, CentOS 8+, etc.)
- Systemd oder ein anderer init-Dienst

## Installation

### Installation auf Windows

1. **Docker Desktop installieren**
   - Besuchen Sie die [Docker Desktop-Website](https://www.docker.com/products/docker-desktop)
   - Laden Sie den Installer für Windows herunter
   - Führen Sie den Installer aus und folgen Sie den Anweisungen
   - Starten Sie Ihren Computer neu, wenn Sie dazu aufgefordert werden

2. **WSL 2 aktivieren (falls noch nicht geschehen)**
   - Öffnen Sie PowerShell als Administrator und führen Sie folgende Befehle aus:
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```
   - Starten Sie Ihren Computer neu
   - Laden Sie das [WSL 2 Linux-Kernel-Update](https://aka.ms/wsl2kernel) herunter und installieren Sie es
   - Setzen Sie WSL 2 als Standardversion:
   ```powershell
   wsl --set-default-version 2
   ```

3. **Git installieren**
   - Laden Sie Git von [git-scm.com](https://git-scm.com/download/win) herunter und installieren Sie es

4. **Projektdateien erstellen**
   - Erstellen Sie einen neuen Ordner für das Projekt:
   ```powershell
   mkdir crypto-trading-bot
   cd crypto-trading-bot
   ```
   - Erstellen Sie die im Abschnitt [Quellcode und Konfigurationsdateien](#quellcode-und-konfigurationsdateien) aufgeführten Dateien

### Installation auf macOS

1. **Docker Desktop installieren**
   - Besuchen Sie die [Docker Desktop-Website](https://www.docker.com/products/docker-desktop)
   - Laden Sie den macOS-Installer herunter (Intel oder Apple Silicon Version je nach Mac)
   - Installieren Sie Docker Desktop durch Ziehen in den Applications-Ordner
   - Starten Sie Docker Desktop

2. **Homebrew installieren (optional, aber empfohlen)**
   - Öffnen Sie das Terminal und führen Sie aus:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. **Git installieren (falls noch nicht vorhanden)**
   - Mit Homebrew:
   ```bash
   brew install git
   ```
   - Alternativ mit Command Line Tools:
   ```bash
   xcode-select --install
   ```

4. **Projektdateien erstellen**
   - Erstellen Sie einen neuen Ordner für das Projekt:
   ```bash
   mkdir crypto-trading-bot
   cd crypto-trading-bot
   ```
   - Erstellen Sie die im Abschnitt [Quellcode und Konfigurationsdateien](#quellcode-und-konfigurationsdateien) aufgeführten Dateien

### Installation auf Linux

1. **Docker und Docker Compose installieren**
   
   Für Ubuntu/Debian:
   ```bash
   # Docker installieren
   sudo apt-get update
   sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   sudo apt-get update
   sudo apt-get install docker-ce docker-ce-cli containerd.io
   
   # Docker Compose installieren
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   
   # Docker-Service starten und für Autostart konfigurieren
   sudo systemctl start docker
   sudo systemctl enable docker
   
   # Nicht-Root-Benutzer zur Docker-Gruppe hinzufügen
   sudo usermod -aG docker $USER
   ```
   
   Für Fedora/CentOS:
   ```bash
   # Docker installieren
   sudo dnf -y install dnf-plugins-core
   sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
   sudo dnf install docker-ce docker-ce-cli containerd.io
   
   # Docker Compose installieren
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   
   # Docker-Service starten und für Autostart konfigurieren
   sudo systemctl start docker
   sudo systemctl enable docker
   
   # Nicht-Root-Benutzer zur Docker-Gruppe hinzufügen
   sudo usermod -aG docker $USER
   ```

2. **Git installieren (falls noch nicht vorhanden)**
   
   Für Ubuntu/Debian:
   ```bash
   sudo apt-get install git
   ```
   
   Für Fedora/CentOS:
   ```bash
   sudo dnf install git
   ```

3. **Projektdateien erstellen**
   - Erstellen Sie einen neuen Ordner für das Projekt:
   ```bash
   mkdir crypto-trading-bot
   cd crypto-trading-bot
   ```
   - Erstellen Sie die im Abschnitt [Quellcode und Konfigurationsdateien](#quellcode-und-konfigurationsdateien) aufgeführten Dateien

## Projektstruktur

Nachdem Sie alle Dateien erstellt haben, sollte Ihre Projektstruktur wie folgt aussehen:

```
crypto-trading-bot/
├── backend/                      # Elixir Backend
│   ├── Dockerfile                # Docker-Konfiguration für das Backend
│   ├── lib/                      # Hier werden die Elixir-Quelldateien erstellt
│   │   ├── crypto_bot/           # Kernfunktionalität
│   │   │   ├── exchanges/        # Börsen-API-Integration
│   │   │   ├── indicators/       # Technische Indikatoren
│   │   │   ├── strategies/       # Handelsstrategien
│   │   │   ├── traders/          # Trading-Ausführung
│   │   │   └── schemas/          # Datenbankschemas
│   │   └── crypto_bot_web/       # Web-API
│   ├── config/                   # Konfigurationsdateien
│   └── priv/                     # Assets und Migrationen
│
├── frontend/                     # Svelte Frontend
│   ├── Dockerfile                # Docker-Konfiguration für das Frontend
│   ├── nginx.conf                # NGINX-Konfiguration
│   └── src/                      # Frontend-Quellcode
│
├── docker-compose.yml            # Docker Compose Konfiguration
├── setup.sh                      # Setup-Skript
└── .env                          # Umgebungsvariablen
```

## Quellcode und Konfigurationsdateien

In diesem Abschnitt finden Sie alle notwendigen Dateien mit vollständigem Code, die Sie für die Einrichtung des Trading-Bots benötigen. Erstellen Sie diese Dateien in der oben beschriebenen Struktur.

### Docker-Compose

Erstellen Sie eine Datei `docker-compose.yml` im Stammverzeichnis:

```yaml
# docker-compose.yml
version: '3.8'

services:
  # Database
  db:
    image: postgres:14-alpine
    container_name: cryptobot-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-crypto_user}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-secretpassword}
      POSTGRES_DB: ${POSTGRES_DB:-crypto_bot}
      PGDATA: /var/lib/postgresql/data/pgdata
    volumes:
      - postgres_data:/var/lib/postgresql/data/pgdata
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-crypto_user} -d ${POSTGRES_DB:-crypto_bot}"]
      interval: 10s
      timeout: 5s
      retries: 5
    ports:
      - "5432:5432"
    networks:
      - cryptobot-network

  # Elixir Backend
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: cryptobot-backend
    restart: unless-stopped
    depends_on:
      db:
        condition: service_healthy
    environment:
      DATABASE_URL: postgres://${POSTGRES_USER:-crypto_user}:${POSTGRES_PASSWORD:-secretpassword}@db:5432/${POSTGRES_DB:-crypto_bot}
      SECRET_KEY_BASE: ${SECRET_KEY_BASE:-generatesecurekeyinproduction}
      GUARDIAN_SECRET_KEY: ${GUARDIAN_SECRET_KEY:-generatesecurekeyinproduction}
      API_KEY_ENCRYPTION_KEY: ${API_KEY_ENCRYPTION_KEY:-generatesecurekeyinproduction}
      PHX_HOST: localhost
      PORT: 4000
    ports:
      - "4000:4000"
    volumes:
      - ./backend:/app
      - backend_build:/app/_build
      - backend_deps:/app/deps
    networks:
      - cryptobot-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:4000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Svelte Frontend
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      args:
        VITE_API_URL: ${VITE_API_URL:-http://localhost:4000}
    container_name: cryptobot-frontend
    restart: unless-stopped
    depends_on:
      - backend
    ports:
      - "3000:80"
    networks:
      - cryptobot-network

networks:
  cryptobot-network:
    driver: bridge

volumes:
  postgres_data:
  backend_build:
  backend_deps:
```

### Backend Dockerfile

Erstellen Sie den Ordner `backend` und darin eine Datei `Dockerfile`:

```dockerfile
# backend/Dockerfile
FROM elixir:1.14-alpine AS build

# Install build dependencies
RUN apk add --no-cache build-base git nodejs npm

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build environment
ENV MIX_ENV=prod

# Copy configuration files
COPY config/ ./config/
COPY mix.exs mix.lock ./

# Fetch dependencies and compile them
RUN mix deps.get --only prod && \
    mix deps.compile

# Copy the rest of the application code
COPY lib/ ./lib/
COPY priv/ ./priv/

# Compile the application
RUN mix compile

# Build release
RUN mix release

# Create runtime container
FROM alpine:3.16

# Install runtime dependencies
RUN apk add --no-cache openssl ncurses-libs libstdc++ libgcc tzdata curl

# Set working directory
WORKDIR /app

# Copy release from build stage
COPY --from=build /app/_build/prod/rel/crypto_bot ./

# Set environment
ENV PHX_SERVER=true

# Set entry point
CMD ["bin/crypto_bot", "start"]

# Expose port
EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:4000/api/health || exit 1
```

### Frontend Dockerfile

Erstellen Sie den Ordner `frontend` und darin eine Datei `Dockerfile`:

```dockerfile
# frontend/Dockerfile
# Build stage
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy rest of the application code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy build files from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Command to run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
```

### NGINX-Konfiguration

Erstellen Sie eine Datei `nginx.conf` im Verzeichnis `frontend`:

```nginx
# frontend/nginx.conf
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/javascript application/json image/svg+xml;
    gzip_min_length 1000;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
    add_header Referrer-Policy "strict-origin-when-cross-origin";

    # SPA configuration - redirect all requests to index.html
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 30d;
        add_header Cache-Control "public, max-age=2592000";
    }

    # Prevent access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
```

### Setup-Skript

Erstellen Sie eine Datei `setup.sh` im Stammverzeichnis:

```bash
#!/bin/bash
# =========================================================================
# Crypto-Trading-Bot Setup Script
# =========================================================================
# This script initializes and starts all components of the
# automated crypto trading bot.
# =========================================================================

# Colors for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display banner
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════╗"
echo "║           AUTOMATED CRYPTO-TRADING-BOT           ║"
echo "║                                                  ║"
echo "║        Elixir Backend • Svelte Frontend          ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check for Docker and Docker Compose
echo -e "${BLUE}Checking dependencies...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed.${NC}"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker daemon is not running or you don't have permissions.${NC}"
    echo "Please start the Docker daemon or add your user to the docker group."
    exit 1
fi

# Check Docker Compose (v1 and v2)
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not installed.${NC}"
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

# Docker Compose command based on version
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    COMPOSE_CMD="docker compose"
fi

echo -e "${GREEN}✓ All dependencies are installed${NC}"

# Create environment file if it doesn't exist
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Creating default .env file...${NC}"
    cat > .env << EOL
# Database settings
POSTGRES_USER=crypto_user
POSTGRES_PASSWORD=secretpassword
POSTGRES_DB=crypto_bot

# Backend settings
SECRET_KEY_BASE=W0veQnY5tZ+ZxrOZTWNpgPsJzvPZ1lQZ+AbiVA+E3RRsXBwkzBsUwbxy1wQo5I/D
GUARDIAN_SECRET_KEY=z0HZA2bZeY/kOvHg6aD9CubDAajXwBPJw+4dWMnl+7QmrFsRQWj/G9MrJpvK8xrC
API_KEY_ENCRYPTION_KEY=Y2gQd1s87aAlPArnk79YbB3mU6taPYlRoTf0EwXuHD8=

# Frontend settings
VITE_API_URL=http://localhost:4000
EOL
    echo -e "${GREEN}✓ Created .env file with default values${NC}"
fi

# Create project directories if they don't exist
echo -e "${BLUE}Creating project structure...${NC}"

# Create backend directory and files
if [ ! -d "backend" ]; then
    echo -e "${YELLOW}Creating backend directory...${NC}"
    mkdir -p backend/{lib/{crypto_bot/{exchanges,indicators,strategies,traders,schemas},crypto_bot_web/{controllers,views}},config,priv/repo/migrations}
    
    # Create README file
    cat > backend/README.md << EOL
# Crypto Trading Bot - Elixir Backend

This is the Elixir backend for the automated cryptocurrency trading bot.

## Structure

- lib/crypto_bot/ - Core trading functionality
  - exchanges/ - Exchange API integrations
  - indicators/ - Technical indicators
  - strategies/ - Trading strategies
  - traders/ - Trading execution
  - schemas/ - Database schemas
- lib/crypto_bot_web/ - Web API
  - controllers/ - API endpoints
  - views/ - JSON views

## Starting the server

The server can be started with Docker Compose or directly with mix:

\`\`\`
# With Docker
docker-compose up backend

# Without Docker
cd backend
mix deps.get
mix ecto.create
mix ecto.migrate
mix phx.server
\`\`\`
EOL
    
    echo -e "${GREEN}✓ Backend directory created${NC}"
fi

# Create frontend directory and files
if [ ! -d "frontend" ]; then
    echo -e "${YELLOW}Creating frontend directory...${NC}"
    mkdir -p frontend/{public,src/{components,routes,stores,utils}}
    
    # Create README file
    cat > frontend/README.md << EOL
# Crypto Trading Bot - Svelte Frontend

This is the Svelte frontend for the automated cryptocurrency trading bot.

## Structure

- src/
  - components/ - Reusable UI components
  - routes/ - Page components
  - stores/ - State management
  - utils/ - Helper functions

## Development

\`\`\`
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
\`\`\`
EOL
    
    echo -e "${GREEN}✓ Frontend directory created${NC}"
fi

# Check if Docker files exist
echo -e "${BLUE}Setting up Docker files...${NC}"

if [ -f "docker-compose.yml" ]; then
    echo -e "${GREEN}✓ docker-compose.yml exists${NC}"
else
    echo -e "${RED}Error: docker-compose.yml not found${NC}"
    exit 1
fi

if [ -f "backend/Dockerfile" ]; then
    echo -e "${GREEN}✓ backend/Dockerfile exists${NC}"
else
    echo -e "${RED}Error: backend/Dockerfile not found${NC}"
    exit 1
fi

if [ -f "frontend/Dockerfile" ]; then
    echo -e "${GREEN}✓ frontend/Dockerfile exists${NC}"
else
    echo -e "${RED}Error: frontend/Dockerfile not found${NC}"
    exit 1
fi

if [ -f "frontend/nginx.conf" ]; then
    echo -e "${GREEN}✓ frontend/nginx.conf exists${NC}"
else
    echo -e "${RED}Error: frontend/nginx.conf not found${NC}"
    exit 1
fi

# Ask if user wants to start the services
echo -e "${YELLOW}"
read -p "Do you want to start the Crypto Trading Bot now? (y/N): " START_NOW
echo -e "${NC}"

if [[ "$START_NOW" =~ ^[yY]$ ]]; then
    echo -e "${BLUE}Starting services...${NC}"
    
    # Start with Docker Compose
    $COMPOSE_CMD up -d
    
    # Check if services started successfully
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}  Crypto Trading Bot successfully started!${NC}"
        echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
        echo -e "Frontend: ${BLUE}http://localhost:3000${NC}"
        echo -e "API:      ${BLUE}http://localhost:4000/api${NC}"
        echo -e "Logs:     ${BLUE}$COMPOSE_CMD logs -f${NC}"
        echo
        echo -e "${YELLOW}Note: For login, use username 'admin' and password 'admin123'${NC}"
        echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
    else
        echo -e "${RED}Error starting services. Please check the logs:${NC}"
        echo -e "${BLUE}$COMPOSE_CMD logs${NC}"
    fi
else
    echo -e "${BLUE}You can start the services later with:${NC}"
    echo -e "${GREEN}docker-compose up -d${NC}"
fi

echo -e "${GREEN}Setup completed!${NC}"
exit 0
```

Machen Sie das Setup-Skript ausführbar:
```bash
# Für macOS/Linux:
chmod +x setup.sh

# Für Windows (im Git Bash oder WSL):
chmod +x setup.sh
```

### .env-Datei

Erstellen Sie eine Datei `.env` im Stammverzeichnis:

```
# Database settings
POSTGRES_USER=crypto_user
POSTGRES_PASSWORD=secretpassword
POSTGRES_DB=crypto_bot

# Backend settings
SECRET_KEY_BASE=W0veQnY5tZ+ZxrOZTWNpgPsJzvPZ1lQZ+AbiVA+E3RRsXBwkzBsUwbxy1wQo5I/D
GUARDIAN_SECRET_KEY=z0HZA2bZeY/kOvHg6aD9CubDAajXwBPJw+4dWMnl+7QmrFsRQWj/G9MrJpvK8xrC
API_KEY_ENCRYPTION_KEY=Y2gQd1s87aAlPArnk79YbB3mU6taPYlRoTf0EwXuHD8=

# Frontend settings
VITE_API_URL=http://localhost:4000
```

## Konfiguration

### Umgebungsvariablen

Die `.env`-Datei enthält alle wichtigen Umgebungsvariablen für den Bot. Für Produktionsumgebungen sollten Sie die Sicherheitsschlüssel ändern:

- `POSTGRES_USER`, `POSTGRES_PASSWORD`: Zugangsdaten für die PostgreSQL-Datenbank
- `SECRET_KEY_BASE`, `GUARDIAN_SECRET_KEY`: Sicherheitsschlüssel für das Backend
- `API_KEY_ENCRYPTION_KEY`: Schlüssel zur Verschlüsselung der Börsen-API-Schlüssel
- `VITE_API_URL`: URL des Backend-API für das Frontend

### Börsen-API-Schlüssel generieren

Um den Bot mit einer Kryptobörse zu verbinden, benötigen Sie API-Schlüssel. So erhalten Sie diese:

1. **Bei der gewünschten Börse anmelden** (z.B. Bitget, Binance, Coinbase Pro, etc.)
2. **Zum API-Bereich navigieren** (meist unter Einstellungen oder im Konto-Bereich)
3. **Neue API-Schlüssel erstellen**
   - API-Berechtigungen auf "Lesen" und "Handeln" setzen
   - IP-Einschränkungen konfigurieren (empfohlen)
   - Manche Börsen erfordern zusätzlich ein API-Passwort
4. **Schlüssel sichern**
   - Speichern Sie den API-Schlüssel, das Secret und ggf. das Passwort sicher
   - Diese werden später in der Anwendung eingegeben, nicht in die .env-Datei

**Wichtig:** Verwenden Sie niemals API-Schlüssel mit Auszahlungsberechtigungen für automatisierte Bots.

## Starten und Betrieb

### Erstmaliges Starten

Nach der Einrichtung aller Dateien starten Sie den Bot mit folgenden Schritten:

1. **Öffnen Sie ein Terminal/Eingabeaufforderung**:
   - In Windows: PowerShell oder CMD im Projektverzeichnis öffnen
   - In macOS/Linux: Terminal im Projektverzeichnis öffnen

2. **Führen Sie das Setup-Skript aus**:
   ```bash
   ./setup.sh
   ```
   
   Alternativ können Sie Docker Compose direkt nutzen:
   ```bash
   docker-compose up -d
   ```

3. **Überprüfen Sie den Status**:
   ```bash
   docker-compose ps
   ```
   
   Alle Dienste sollten den Status "Up" haben.

4. **Zugriff auf das Frontend**:
   - Öffnen Sie einen Browser und navigieren Sie zu `http://localhost:3000`
   - Melden Sie sich mit den Standardanmeldedaten an:
     - Benutzername: `admin`
     - Passwort: `admin123`

### Dienste verwalten

- **Alle Dienste stoppen**:
  ```bash
  docker-compose down
  ```

- **Nur bestimmte Dienste neustarten**:
  ```bash
  docker-compose restart backend
  ```

- **Logs anzeigen**:
  ```bash
  docker-compose logs -f
  ```
  
  Oder für einen bestimmten Dienst:
  ```bash
  docker-compose logs -f backend
  ```

- **Auf Datenbank zugreifen**:
  ```bash
  docker-compose exec db psql -U crypto_user -d crypto_bot
  ```

### Sichern und Wiederherstellen

- **Datenbank sichern**:
  ```bash
  docker-compose exec db pg_dump -U crypto_user crypto_bot > backup.sql
  ```

- **Datenbank wiederherstellen**:
  ```bash
  docker-compose exec -T db psql -U crypto_user -d crypto_bot < backup.sql
  ```

## Nutzung der Anwendung

### Dashboard

Nach der Anmeldung sehen Sie das Dashboard, das einen Überblick über Ihre Handelsaktivitäten bietet:
- Aktuelle Handelsaktivitäten und offene Positionen
- Gewinn- und Verluststatistiken
- Markttrends

### Handelseinstellungen konfigurieren

1. **Navigieren Sie zum Bereich "Trading"**
2. **Geben Sie Ihre API-Schlüssel ein**:
   - API Key
   - API Secret
   - API Passphrase (falls erforderlich)
3. **Wählen Sie die Kryptowährungen aus**, die Sie handeln möchten
4. **Konfigurieren Sie die Strategie-Parameter**:
   - RSI-Einstellungen (Periode, Überkauft/Überverkauft-Schwellen)
   - SMA-Einstellungen (Kurz- und Langzeit-Perioden)
   - Stop-Loss und Take-Profit-Prozentsätze
   - Hebelwirkung (falls verwendet)
5. **Wählen Sie den Zeitrahmen** für die Analyse (15m, 1h, 4h, 1d, etc.)

### Handel starten

1. **Konfiguration überprüfen**
2. **Auf "Trading starten" klicken**
3. **Bot-Aktivität überwachen**:
   - Positionsübersicht
   - Gewinn/Verlust-Tracking
   - Marktanalyse

### Positionen verwalten

Im Bereich "Positionen" können Sie:
- Offene Positionen einsehen
- Geschlossene Positionen und deren Performance analysieren
- Historische Handelsstatistiken abrufen

### Marktdaten visualisieren

Im Bereich "Symbols" können Sie:
- Echtzeit-Marktdaten mit verschiedenen Zeitrahmen anzeigen
- Technische Indikatoren wie RSI, SMA und Bollinger-Bänder visualisieren
- Verschiedene Kryptowährungen analysieren

## Fehlerbehebung

### Häufige Probleme und Lösungen

#### Docker-bezogene Probleme

1. **Container starten nicht**:
   ```bash
   # Docker-Status prüfen
   docker info
   
   # Container neu starten
   docker-compose down
   docker-compose up -d
   
   # Logs prüfen
   docker-compose logs
   ```

2. **Port-Konflikte**:
   ```bash
   # Prüfen, ob Ports bereits verwendet werden
   # Windows:
   netstat -ano | findstr :3000
   netstat -ano | findstr :4000
   
   # macOS/Linux:
   lsof -i :3000
   lsof -i :4000
   
   # Ports in docker-compose.yml ändern
   # z.B. "3001:80" statt "3000:80"
   ```

3. **Speicherprobleme**:
   - Docker Desktop Ressourcenbeschränkungen erhöhen (in den Docker-Einstellungen)

#### Anwendungsbezogene Probleme

1. **Anmeldung funktioniert nicht**:
   - Überprüfen Sie die Standardanmeldedaten (admin/admin123)
   - Datenbankdienst neustarten:
     ```bash
     docker-compose restart db
     ```

2. **Backend-API nicht erreichbar**:
   ```bash
   # Backend-Logs prüfen
   docker-compose logs backend
   
   # Backend neustarten
   docker-compose restart backend
   ```

3. **Börsen-API-Fehler**:
   - Überprüfen Sie Ihre API-Schlüssel und Berechtigungen
   - Stellen Sie sicher, dass die Börse verfügbar ist
   - IP-Beschränkungen der API prüfen

4. **Container stürzt regelmäßig ab**:
   ```bash
   # Container-Logs ansehen
   docker-compose logs --tail=100 backend
   
   # Speichernutzung prüfen
   docker stats
   ```

### Debugging-Tipps

- **Detaillierte Logs aktivieren**:
  - Bearbeiten Sie die Docker-Compose-Datei, um detaillierte Logs zu aktivieren
  
- **Direkte Verbindung zur Datenbank**:
  ```bash
  docker-compose exec db psql -U crypto_user -d crypto_bot
  ```
  
- **Backend-Prozesse prüfen**:
  ```bash
  docker-compose exec backend ps aux
  ```

## Sicherheitshinweise

### Wichtige Vorsichtsmaßnahmen

1. **API-Schlüssel-Sicherheit**:
   - Verwenden Sie niemals API-Schlüssel mit Auszahlungsberechtigungen
   - Beschränken Sie die Zugriffsrechte auf bestimmte IPs
   - Verwenden Sie separate API-Schlüssel für den Bot
   
2. **Passwörter und Secrets**:
   - Ändern Sie die Standard-Sicherheitsschlüssel in der .env-Datei
   - Ändern Sie das Standard-Admin-Passwort nach der ersten Anmeldung
   
3. **Server-Sicherheit**:
   - Halten Sie Docker und alle Abhängigkeiten aktuell
   - Verwenden Sie eine Firewall, um den Zugriff zu beschränken
   - Deaktivieren Sie den externen Zugriff (beschränken Sie auf localhost)

### Risikomanagement

1. **Handelsrisiken**:
   - Beginnen Sie mit kleinen Beträgen für Tests
   - Setzen Sie immer Stop-Loss-Grenzen
   - Verwenden Sie nicht Ihr gesamtes Kapital für automatisierten Handel
   
2. **Bot-Überwachung**:
   - Überwachen Sie den Bot regelmäßig
   - Implementieren Sie Benachrichtigungen für wichtige Ereignisse
   - Setzen Sie Grenzen für tägliche/wöchentliche Verluste

### Haftungsausschluss

Der Handel mit Kryptowährungen birgt erhebliche Risiken, insbesondere bei Verwendung von Hebeln. Die Nutzung dieses automatisierten Trading-Bots erfolgt auf eigenes Risiko. Es wird keine Garantie für Gewinne gegeben, und Verluste können eintreten. Benutzer sollten sich gründlich mit den Konzepten des algorithmischen Handels, technischen Indikatoren und Risikomanagement vertraut machen, bevor sie Echtgeld einsetzen.
