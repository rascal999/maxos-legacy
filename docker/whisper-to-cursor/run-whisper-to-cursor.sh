#!/usr/bin/env bash

# Script to run the whisper-to-cursor Docker container

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Go to the script directory
cd "$SCRIPT_DIR"

# Function to check if container is running
container_running() {
    docker ps --format '{{.Names}}' | grep -q "^whisper-to-cursor$"
}

# Always stop and remove the container if it exists
echo "Stopping and removing any existing whisper-to-cursor container..."
docker stop whisper-to-cursor 2>/dev/null || true
docker rm whisper-to-cursor 2>/dev/null || true

# Always rebuild and start the container
echo "Building whisper-to-cursor container..."
docker-compose build --no-cache
if [ $? -ne 0 ]; then
    echo "Error: Failed to build the container. Please check the Dockerfile and requirements."
    exit 1
fi

echo "Starting whisper-to-cursor container..."
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "Error: Failed to start the container. Please check the docker-compose.yml file."
    exit 1
fi

# Check if container is running before attaching
if container_running; then
    echo "Attaching to whisper-to-cursor container..."
    echo "If you don't see the application output, press Enter once to activate the terminal."
    echo "Press Ctrl+C at any time to exit."
    echo ""
    
    # Give the container a moment to initialize
    sleep 2
    
    # Attach with interactive mode
    docker attach --sig-proxy=true whisper-to-cursor
else
    echo "Error: Container is not running. Please check the logs for more information:"
    docker-compose logs
    exit 1
fi