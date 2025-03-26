#!/bin/bash

# CryptoBot Setup Script
# This script helps set up and run the CryptoBot trading application

# Color definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════╗"
echo "║           CRYPTO TRADING BOT SETUP               ║"
echo "║                                                  ║"
echo "║        Elixir Backend • Svelte Frontend          ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if Docker and Docker Compose are installed
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

echo -e "${GREEN}✓ All dependencies installed${NC}"

# Configure API keys
echo -e "${BLUE}Please enter your API credentials for Bitget exchange:${NC}"

read -p "API Key: " API_KEY
read -p "API Secret: " API_SECRET
read -p "API Passphrase: " API_PASSPHRASE

# Update environment variables in docker-compose file
sed -i "s/BITGET_API_KEY: your_api_key/BITGET_API_KEY: $API_KEY/" docker-compose.yml
sed -i "s/BITGET_API_SECRET: your_api_secret/BITGET_API_SECRET: $API_SECRET/" docker-compose.yml
sed -i "s/BITGET_PASSPHRASE: your_passphrase/BITGET_PASSPHRASE: $API_PASSPHRASE/" docker-compose.yml

echo -e "${GREEN}✓ API credentials updated${NC}"

# Start application with Docker Compose
echo -e "${BLUE}Starting the Crypto Trading Bot...${NC}"
echo "This may take a few minutes, especially on first startup."

$COMPOSE_CMD up -d --build

# Wait for containers
echo -e "${BLUE}Waiting for containers...${NC}"
attempt=0
max_attempts=30

until $COMPOSE_CMD ps | grep -q "backend.*running" || [ $attempt -eq $max_attempts ]; do
    echo -n "."
    sleep 2
    attempt=$((attempt+1))
done

if [ $attempt -eq $max_attempts ]; then
    echo -e "\n${RED}Timeout waiting for containers.${NC}"
    echo "Please check logs with: $COMPOSE_CMD logs"
    exit 1
fi

echo -e "\n${GREEN}All containers started!${NC}"

# Show access information
echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Crypto Trading Bot successfully started!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
echo -e "Frontend UI: ${BLUE}http://localhost:3000${NC}"
echo -e "Backend API: ${BLUE}http://localhost:4000/api${NC}"
echo -e "Logs:       ${BLUE}$COMPOSE_CMD logs -f${NC}"
echo
echo -e "${YELLOW}Login credentials:${NC}"
echo -e "Username: ${BLUE}admin${NC}"
echo -e "Password: ${BLUE}admin123${NC}"
echo
echo -e "${YELLOW}Note: This is a demo application. Do not use it with real funds.${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
