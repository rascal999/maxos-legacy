#!/bin/bash

# Restic Backup Manager for Backblaze B2
# This script provides easy management of restic backups

set -e

SECRETS_DIR="/home/user/git/github/monorepo/secrets/environments/personal"
B2_ACCESS_KEY_FILE="$SECRETS_DIR/.b2-access-key"
B2_SECRET_KEY_FILE="$SECRETS_DIR/.b2-secret-key"
RESTIC_PASSWORD_FILE="$SECRETS_DIR/.restic-password"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Check if credentials exist
check_credentials() {
    local missing=0
    
    if [ ! -f "$B2_ACCESS_KEY_FILE" ]; then
        print_error "Backblaze B2 access key file not found: $B2_ACCESS_KEY_FILE"
        missing=1
    fi
    
    if [ ! -f "$B2_SECRET_KEY_FILE" ]; then
        print_error "Backblaze B2 secret key file not found: $B2_SECRET_KEY_FILE"
        missing=1
    fi
    
    if [ ! -f "$RESTIC_PASSWORD_FILE" ]; then
        print_error "Restic password file not found: $RESTIC_PASSWORD_FILE"
        missing=1
    fi
    
    if [ $missing -eq 1 ]; then
        print_error "Missing credentials. Run: ./scripts/setup-backblaze-b2-backup.sh"
        exit 1
    fi
    
    print_status "All credential files found"
}

# Load environment variables
load_env() {
    export AWS_ACCESS_KEY_ID=$(cat "$B2_ACCESS_KEY_FILE")
    export AWS_SECRET_ACCESS_KEY=$(cat "$B2_SECRET_KEY_FILE")
    export RESTIC_PASSWORD_FILE="$RESTIC_PASSWORD_FILE"
    
    # Default repository (can be overridden)
    if [ -z "$RESTIC_REPOSITORY" ]; then
        export RESTIC_REPOSITORY="s3:s3.us-west-004.backblazeb2.com/your-bucket-name/$(hostname)"
        print_warning "Using default repository: $RESTIC_REPOSITORY"
        print_warning "Set RESTIC_REPOSITORY environment variable to override"
    fi
}

# Show usage
show_usage() {
    echo "Restic Backup Manager for Backblaze B2"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  init                    Initialize a new repository"
    echo "  backup [path]           Create a backup (default: /home/user)"
    echo "  list                    List all snapshots"
    echo "  restore <snapshot> <target>  Restore a snapshot to target directory"
    echo "  mount <mountpoint>      Mount repository as filesystem"
    echo "  umount <mountpoint>     Unmount repository"
    echo "  prune                   Remove old snapshots according to policy"
    echo "  check                   Check repository integrity"
    echo "  stats                   Show repository statistics"
    echo "  status                  Show systemd service status"
    echo "  logs                    Show backup service logs"
    echo "  test                    Test backup configuration"
    echo ""
    echo "Environment variables:"
    echo "  RESTIC_REPOSITORY       Repository URL (default: auto-detected)"
    echo "  BACKUP_EXCLUDES         Additional exclude patterns"
    echo ""
    echo "Examples:"
    echo "  $0 init"
    echo "  $0 backup"
    echo "  $0 backup /home/user/Documents"
    echo "  $0 list"
    echo "  $0 restore latest /tmp/restore"
    echo "  $0 mount /mnt/backup"
    echo "  $0 stats"
}

# Initialize repository
init_repo() {
    print_header "Initializing Repository"
    print_status "Repository: $RESTIC_REPOSITORY"
    
    if restic snapshots &>/dev/null; then
        print_warning "Repository already exists"
        return 0
    fi
    
    print_status "Creating new repository..."
    restic init
    print_status "Repository initialized successfully"
}

# Create backup
create_backup() {
    local backup_path="${1:-/home/user}"
    
    print_header "Creating Backup"
    print_status "Backing up: $backup_path"
    print_status "Repository: $RESTIC_REPOSITORY"
    
    # Default excludes
    local excludes=(
        "*.tmp"
        "*.temp"
        "*/node_modules"
        "*/target"
        "*/.cache"
        "*/.local/share/Trash"
        "*/.thumbnails"
        "*/Downloads"
        "*/.docker"
        "*/.npm"
        "*/.cargo/registry"
        "*/.cargo/git"
        "*/go/pkg"
        "*/.rustup"
        "*/.gradle"
        "*/.m2"
        "*/.ivy2"
        "*/.sbt"
        "*/venv"
        "*/__pycache__"
        "*.pyc"
        "*.pyo"
        "*/.git"
        "*/.svn"
        "*/.hg"
        "*/lost+found"
        "/home/user/.local/share/Steam"
        "/home/user/.steam"
        "/home/user/.wine"
        "/home/user/.PlayOnLinux"
        "/home/user/VirtualBox VMs"
        "/home/user/.VirtualBox"
        "/home/user/.vagrant.d"
        "/home/user/.minikube"
        "/home/user/.kube/cache"
    )
    
    # Add custom excludes
    if [ -n "$BACKUP_EXCLUDES" ]; then
        IFS=',' read -ra ADDR <<< "$BACKUP_EXCLUDES"
        for exclude in "${ADDR[@]}"; do
            excludes+=("$exclude")
        done
    fi
    
    # Build exclude arguments
    local exclude_args=()
    for exclude in "${excludes[@]}"; do
        exclude_args+=(--exclude="$exclude")
    done
    
    print_status "Starting backup..."
    restic backup "$backup_path" "${exclude_args[@]}" --verbose
    print_status "Backup completed successfully"
}

# List snapshots
list_snapshots() {
    print_header "Repository Snapshots"
    restic snapshots
}

# Restore snapshot
restore_snapshot() {
    local snapshot="$1"
    local target="$2"
    
    if [ -z "$snapshot" ] || [ -z "$target" ]; then
        print_error "Usage: $0 restore <snapshot> <target>"
        exit 1
    fi
    
    print_header "Restoring Snapshot"
    print_status "Snapshot: $snapshot"
    print_status "Target: $target"
    
    mkdir -p "$target"
    restic restore "$snapshot" --target "$target" --verbose
    print_status "Restore completed successfully"
}

# Mount repository
mount_repo() {
    local mountpoint="$1"
    
    if [ -z "$mountpoint" ]; then
        print_error "Usage: $0 mount <mountpoint>"
        exit 1
    fi
    
    print_header "Mounting Repository"
    print_status "Mountpoint: $mountpoint"
    
    mkdir -p "$mountpoint"
    restic mount "$mountpoint" &
    print_status "Repository mounted at $mountpoint"
    print_status "Use '$0 umount $mountpoint' to unmount"
}

# Unmount repository
umount_repo() {
    local mountpoint="$1"
    
    if [ -z "$mountpoint" ]; then
        print_error "Usage: $0 umount <mountpoint>"
        exit 1
    fi
    
    print_header "Unmounting Repository"
    fusermount -u "$mountpoint"
    print_status "Repository unmounted from $mountpoint"
}

# Prune old snapshots
prune_repo() {
    print_header "Pruning Repository"
    print_status "Removing old snapshots..."
    
    restic forget --prune \
        --keep-daily 7 \
        --keep-weekly 4 \
        --keep-monthly 6 \
        --keep-yearly 2 \
        --verbose
    
    print_status "Pruning completed successfully"
}

# Check repository
check_repo() {
    print_header "Checking Repository"
    restic check --verbose
    print_status "Repository check completed"
}

# Show statistics
show_stats() {
    print_header "Repository Statistics"
    restic stats
}

# Show systemd status
show_status() {
    print_header "Backup Service Status"
    systemctl status restic-backup.service || true
    echo ""
    systemctl status restic-backup.timer || true
}

# Show logs
show_logs() {
    print_header "Backup Service Logs"
    journalctl -u restic-backup.service -n 50 --no-pager
}

# Test configuration
test_config() {
    print_header "Testing Backup Configuration"
    
    check_credentials
    load_env
    
    print_status "Testing repository access..."
    if restic snapshots &>/dev/null; then
        print_status "✓ Repository access successful"
        restic snapshots --compact
    else
        print_warning "Repository not accessible or not initialized"
        print_status "Run '$0 init' to initialize the repository"
    fi
}

# Main script logic
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        "init")
            check_credentials
            load_env
            init_repo
            ;;
        "backup")
            check_credentials
            load_env
            create_backup "$@"
            ;;
        "list")
            check_credentials
            load_env
            list_snapshots
            ;;
        "restore")
            check_credentials
            load_env
            restore_snapshot "$@"
            ;;
        "mount")
            check_credentials
            load_env
            mount_repo "$@"
            ;;
        "umount")
            umount_repo "$@"
            ;;
        "prune")
            check_credentials
            load_env
            prune_repo
            ;;
        "check")
            check_credentials
            load_env
            check_repo
            ;;
        "stats")
            check_credentials
            load_env
            show_stats
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs
            ;;
        "test")
            test_config
            ;;
        *)
            print_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"