#!/usr/bin/env bash
set -euo pipefail

# Directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SECRETS_DIR="${REPO_ROOT}/secrets"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

usage() {
  cat << EOF
Usage: $(basename "$0") COMMAND [OPTIONS]

Commands:
  create NAME     Create a new secret
  edit NAME       Edit an existing secret
  rekey          Re-encrypt all secrets with updated recipient keys
  rotate         Generate new keys for all systems
  test           Test secrets decryption in a VM
  list           List all secrets and their recipients

Options:
  -h, --help     Show this help message
  -f, --force    Force operation without confirmation
EOF
  exit 1
}

check_dependencies() {
  local missing=0
  for cmd in age age-keygen agenix ssh-keygen; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      log_error "Missing dependency: $cmd"
      missing=1
    fi
  done
  [[ $missing -eq 1 ]] && exit 1
}

create_secret() {
  local name="$1"
  local path="${SECRETS_DIR}/${name}.age"
  
  if [[ -f "$path" ]]; then
    log_error "Secret already exists: $name"
    exit 1
  fi
  
  # Create directories if they don't exist
  mkdir -p "$(dirname "$path")"
  
  # Create temporary file for editing
  local tmp_file
  tmp_file="$(mktemp)"
  trap 'rm -f "$tmp_file"' EXIT
  
  # Edit the secret content
  "${EDITOR:-vim}" "$tmp_file"
  
  # Encrypt the secret
  log_info "Encrypting secret: $name"
  agenix -e "$path" < "$tmp_file"
  
  log_info "Secret created: $name"
}

edit_secret() {
  local name="$1"
  local path="${SECRETS_DIR}/${name}.age"
  
  if [[ ! -f "$path" ]]; then
    log_error "Secret does not exist: $name"
    exit 1
  }
  
  # Create temporary file for editing
  local tmp_file
  tmp_file="$(mktemp)"
  trap 'rm -f "$tmp_file"' EXIT
  
  # Decrypt and edit
  log_info "Decrypting secret: $name"
  agenix -d "$path" > "$tmp_file"
  "${EDITOR:-vim}" "$tmp_file"
  
  # Re-encrypt
  log_info "Re-encrypting secret: $name"
  agenix -e "$path" < "$tmp_file"
  
  log_info "Secret updated: $name"
}

rekey_secrets() {
  log_info "Re-encrypting all secrets with updated keys"
  
  # Find all .age files
  find "${SECRETS_DIR}" -type f -name "*.age" | while read -r secret; do
    local name
    name="$(basename "$secret" .age)"
    log_info "Re-encrypting: $name"
    
    # Create temporary file
    local tmp_file
    tmp_file="$(mktemp)"
    trap 'rm -f "$tmp_file"' EXIT
    
    # Decrypt and re-encrypt
    agenix -d "$secret" > "$tmp_file"
    agenix -e "$secret" < "$tmp_file"
  done
  
  log_info "All secrets have been re-encrypted"
}

rotate_keys() {
  log_warn "This will generate new SSH keys for all systems"
  read -rp "Are you sure you want to continue? [y/N] " confirm
  [[ "${confirm,,}" != "y" ]] && exit 0
  
  # Backup existing keys
  local backup_dir="${SECRETS_DIR}/backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$backup_dir"
  cp -r "${SECRETS_DIR}/keys" "$backup_dir/" || true
  
  # Generate new keys
  mkdir -p "${SECRETS_DIR}/keys"
  for system in desktop vm-test; do
    log_info "Generating new key for: $system"
    ssh-keygen -t ed25519 -N "" -f "${SECRETS_DIR}/keys/${system}"
  done
  
  # Update secrets.nix with new public keys
  log_info "Updating secrets.nix with new public keys"
  sed -i.bak -e '/ssh-ed25519/d' "${SECRETS_DIR}/secrets.nix"
  for system in desktop vm-test; do
    public_key="$(cat "${SECRETS_DIR}/keys/${system}.pub")"
    sed -i "/${system} =/a\\  \"$public_key\";" "${SECRETS_DIR}/secrets.nix"
  done
  
  # Re-encrypt all secrets with new keys
  rekey_secrets
  
  log_info "Key rotation complete. Old keys backed up in: $backup_dir"
}

test_secrets() {
  log_info "Testing secrets decryption in VM"
  
  # Build VM configuration
  nix build .#nixosConfigurations.vm-test.config.system.build.vm
  
  # Start VM with secrets
  QEMU_NET_OPTS="hostfwd=tcp::2222-:22" ./result/bin/run-nixos-vm \
    -drive file="${SECRETS_DIR}/keys/vm-test",format=raw,if=virtio
  
  # Test decryption
  ssh -p 2222 -i "${SECRETS_DIR}/keys/vm-test" root@localhost \
    "agenix -d /run/agenix/* && echo 'All secrets decrypted successfully'"
}

list_secrets() {
  log_info "Listing all secrets and their recipients"
  
  # Parse secrets.nix to show all secrets and their recipients
  nix eval --expr "
    let
      secrets = import ${SECRETS_DIR}/secrets.nix;
    in
      builtins.mapAttrs (name: value: value.publicKeys) secrets
  " | sed 's/\[ /\n  /g' | sed 's/ \]/\n/g'
}

# Main script
[[ $# -eq 0 ]] && usage

check_dependencies

case "$1" in
  create) [[ $# -eq 2 ]] && create_secret "$2" || usage ;;
  edit) [[ $# -eq 2 ]] && edit_secret "$2" || usage ;;
  rekey) rekey_secrets ;;
  rotate) rotate_keys ;;
  test) test_secrets ;;
  list) list_secrets ;;
  -h|--help) usage ;;
  *) usage ;;
esac
