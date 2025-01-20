#!/usr/bin/env bash

# Debug script for i3/NVIDIA issues
# Usage: ./debug-i3-nvidia.sh

echo "=== Collecting debug information for i3/NVIDIA issues ==="

# Create debug directory with timestamp
DEBUG_DIR="/tmp/i3-nvidia-debug-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DEBUG_DIR"

# Function to run command and save output
debug_command() {
    echo "Running: $1"
    echo "=== $1 ===" > "$DEBUG_DIR/$2"
    eval "$1" >> "$DEBUG_DIR/$2" 2>&1
    echo "" >> "$DEBUG_DIR/$2"
}

# System Information
echo "Collecting system information..."
debug_command "uname -a" "system_info.log"
debug_command "nixos-version" "system_info.log"

# NVIDIA Information
echo "Collecting NVIDIA information..."
debug_command "lspci -nnk | grep -A3 'VGA\|3D\|Display'" "gpu_info.log"
debug_command "nvidia-smi" "nvidia_info.log"
debug_command "lsmod | grep -i 'nvidia\|i915'" "gpu_modules.log"
debug_command "dmesg | grep -i 'nvidia\|i915\|gpu'" "gpu_dmesg.log"

# X Server Information
echo "Collecting X server information..."
debug_command "cat /var/log/Xorg.0.log" "xorg.log"
debug_command "xrandr --verbose" "xrandr.log"
debug_command "env | grep -i 'display\|xauth\|nvidia'" "x_environment.log"

# i3 Information
echo "Collecting i3 information..."
debug_command "cat ~/.i3/config 2>/dev/null || cat /etc/i3/config" "i3_config.log"
debug_command "cat ~/.i3/log 2>/dev/null" "i3_log.log"
debug_command "i3-msg -t get_version" "i3_version.log"

# Systemd Status
echo "Collecting service status..."
debug_command "systemctl status display-manager" "display_manager_status.log"
debug_command "journalctl -b 0 -u display-manager" "display_manager_journal.log"
debug_command "systemctl --user status i3" "i3_status.log"

# GLX Information
echo "Collecting GLX information..."
debug_command "glxinfo | grep -i 'vendor\|rendering'" "glx_info.log"

# Package Information
echo "Collecting package information..."
debug_command "nix-store -q --references /run/current-system/sw | grep -i 'nvidia\|i3\|xorg'" "package_info.log"

# Create summary
echo "Creating summary..."
{
    echo "=== Debug Summary ==="
    echo "Date: $(date)"
    echo "System: $(uname -a)"
    echo "NixOS Version: $(nixos-version)"
    echo ""
    echo "=== GPU Information ==="
    grep -h "" "$DEBUG_DIR/gpu_info.log"
    echo ""
    echo "=== Loaded GPU Modules ==="
    grep -h "" "$DEBUG_DIR/gpu_modules.log"
    echo ""
    echo "=== X Server Status ==="
    grep -i "error\|warning\|fail" "$DEBUG_DIR/xorg.log" | tail -n 20
    echo ""
    echo "=== Recent i3 Logs ==="
    tail -n 20 "$DEBUG_DIR/i3_log.log" 2>/dev/null
} > "$DEBUG_DIR/summary.log"

# Compress debug information
tar czf "$DEBUG_DIR.tar.gz" -C "$(dirname "$DEBUG_DIR")" "$(basename "$DEBUG_DIR")"

echo "Debug information collected and saved to $DEBUG_DIR.tar.gz"
echo "Run 'tar xzf $DEBUG_DIR.tar.gz' to extract"
echo ""
echo "Quick summary of potential issues:"
grep -i "error\|warning\|fail" "$DEBUG_DIR/summary.log"
