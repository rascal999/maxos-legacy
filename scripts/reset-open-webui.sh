#!/usr/bin/env bash

echo "Stopping Open WebUI service..."
systemctl stop open-webui

echo "Removing Open WebUI container if it exists..."
docker rm -f open-webui || true

echo "Removing Open WebUI volume..."
docker volume rm open-webui || true

echo "Creating fresh Open WebUI volume..."
docker volume create open-webui

echo "Starting Open WebUI service..."
systemctl start open-webui

echo "Open WebUI has been reset"
