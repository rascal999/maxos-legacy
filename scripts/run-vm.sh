#!/usr/bin/env bash

# Exit on error
set -e

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MAXOS_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Cleaning up old files...${NC}"
rm -f nixos.qcow2
rm -f "$MAXOS_DIR/result"

echo -e "${GREEN}Building VM...${NC}"
cd "$MAXOS_DIR"
nix --extra-experimental-features "nix-command flakes" build .#nixosConfigurations.desktop-test-vm.config.system.build.vm

echo -e "${GREEN}Running VM...${NC}"
./result/bin/run-nixos-vm
