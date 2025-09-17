#!/usr/bin/env bash

# Migration script for MaxOS layered architecture
# This script helps transition from the old structure to the new layered structure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
MODULES_DIR="$REPO_ROOT/modules"

echo "MaxOS Layered Architecture Migration"
echo "===================================="
echo

# Backup current structure
echo "1. Creating backup of current modules..."
if [ ! -d "$MODULES_DIR.backup" ]; then
    cp -r "$MODULES_DIR" "$MODULES_DIR.backup"
    echo "   ✓ Backup created at modules.backup/"
else
    echo "   ⚠ Backup already exists at modules.backup/"
fi

# Test the new layered structure
echo
echo "2. Testing new layered structure..."

# Test system modules
echo "   Testing system modules..."
if nix-instantiate --eval --expr "
  let
    pkgs = import <nixpkgs> {};
    lib = pkgs.lib;
    config = {};
  in
  (import $MODULES_DIR/system-layered.nix { inherit config lib pkgs; })
" >/dev/null 2>&1; then
    echo "   ✓ System modules syntax check passed"
else
    echo "   ✗ System modules syntax check failed"
    exit 1
fi

# Test home modules
echo "   Testing home modules..."
if nix-instantiate --eval --expr "
  let
    pkgs = import <nixpkgs> {};
    lib = pkgs.lib;
    config = {};
  in
  (import $MODULES_DIR/home-layered.nix { inherit config lib pkgs; })
" >/dev/null 2>&1; then
    echo "   ✓ Home modules syntax check passed"
else
    echo "   ✗ Home modules syntax check failed"
    exit 1
fi

echo
echo "3. Migration steps completed:"
echo "   ✓ Backup created"
echo "   ✓ New layered structure tested"
echo
echo "Next steps:"
echo "1. Update your flake.nix to use modules/default-layered.nix"
echo "2. Test your host configurations"
echo "3. If everything works, you can remove the old structure"
echo
echo "To rollback: rm -rf modules && mv modules.backup modules"