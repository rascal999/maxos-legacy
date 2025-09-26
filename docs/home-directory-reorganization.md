# Home Directory Reorganization Plan

## Current State Analysis

The current `/home/user` directory is cluttered with:
- Mixed configuration files and user data
- Multiple backup directories (`backup`, `backups`)
- Development projects scattered across different locations
- Symlinks pointing to various locations
- Cache and temporary files mixed with important data

## Proposed Directory Structure

```
/home/user/
├── Documents/           # Personal documents, notes, PDFs
├── Projects/           # All development projects
│   ├── personal/       # Personal projects
│   ├── work/          # Work-related projects  
│   └── contrib/       # Open source contributions
├── Media/             # All media files
│   ├── Pictures/      # Photos, screenshots, images
│   ├── Videos/        # Video files
│   ├── Music/         # Audio files
│   └── Downloads/     # Downloaded files (temporary)
├── Tools/             # Standalone tools and utilities
├── Workspace/         # Current working directory/scratch space
├── Archive/           # Old files to keep but not actively used
└── .config/           # Application configurations (XDG standard)
```

## Reorganization Steps

### 1. Create New Directory Structure

```bash
# Create main directories
mkdir -p ~/Projects/{personal,work,contrib}
mkdir -p ~/Media/{Pictures,Videos,Music,Downloads}
mkdir -p ~/Backups
mkdir -p ~/Tools
mkdir -p ~/Workspace
mkdir -p ~/Archive
```

### 2. Move Existing Content

#### Development Projects
```bash
# Move git repositories to Projects
mv ~/git ~/Projects/personal/
mv ~/go ~/Projects/personal/
mv ~/mgp-monorepo ~/Projects/work/
mv ~/work ~/Projects/work/
```

#### Media Files
```bash
# Consolidate media
mv ~/Pictures ~/Media/
mv ~/Videos ~/Media/
mv ~/Music ~/Media/
mv ~/Downloads ~/Media/
mv ~/screenshots ~/Media/Pictures/
```

#### Backups and Archives
```bash
# Consolidate backups
mv ~/backup ~/Backups/
mv ~/backups ~/Backups/
mv ~/share ~/Sync/  # Keep as sync directory
```

#### Tools and Utilities
```bash
# Move standalone tools
mv ~/logseq ~/Tools/
```

#### Workspace
```bash
# Move temporary/working files
mv ~/tmp ~/Workspace/
mv ~/mount ~/Workspace/
```

### 3. Update Symlinks

```bash
# Update symlinks to point to new locations
rm ~/monorepo
ln -s ~/Projects/personal/git/github/monorepo ~/monorepo

rm ~/workspace
ln -s ~/Workspace ~/workspace
```

### 4. Clean Up Root Directory

#### Files to Archive
- `private.key`, `public.key` → `~/Archive/keys/`
- `wg.conf` → `~/Archive/configs/`
- Old backup files

#### Files to Remove (if safe)
- `.zcompdump*` files (will be regenerated)
- `.bash_history` (if not needed)
- Cache directories that can be regenerated

## Benefits of New Structure

1. **Clear Separation**: Projects, media, and system files are clearly separated
2. **Scalable**: Easy to add new projects or categories
3. **Backup-Friendly**: Important directories are clearly defined for backup inclusion/exclusion
4. **XDG Compliant**: Follows Linux desktop standards
5. **Intuitive**: Directory names clearly indicate their purpose

## Backup Strategy with New Structure

### Include in Backups
- `~/Documents/` - Important personal documents
- `~/Projects/` - All development work
- `~/Media/Pictures/` - Photos and important images
- `~/Media/Videos/` - Important videos
- `~/Sync/` - Syncthing data
- `~/Tools/` - Standalone applications and tools
- `~/.config/` - Application configurations
- `~/.ssh/` - SSH keys and config
- `~/.gnupg/` - GPG keys

### Exclude from Backups
- `~/Media/Downloads/` - Temporary downloads
- `~/Workspace/` - Temporary working files
- `~/Archive/` - Already archived content
- `~/.cache/` - Application caches
- `~/.local/share/Trash/` - Trash
- `~/.docker/` - Docker cache
- `~/.npm/` - NPM cache
- Build artifacts and dependencies

## Implementation Script

Create a script to safely reorganize the directory:

```bash
#!/bin/bash
# home-reorganize.sh - Safely reorganize home directory

set -e

BACKUP_DIR="$HOME/Archive/pre-reorganization-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

echo "Creating backup of current structure in $BACKUP_DIR"
# Create backup of important symlinks and small files
cp -r ~/.ssh "$BACKUP_DIR/" 2>/dev/null || true
cp ~/.zshrc "$BACKUP_DIR/" 2>/dev/null || true
# ... other important files

echo "Creating new directory structure..."
mkdir -p ~/Projects/{personal,work,contrib}
mkdir -p ~/Media/{Pictures,Videos,Music,Downloads}
mkdir -p ~/Backups
mkdir -p ~/Tools
mkdir -p ~/Workspace
mkdir -p ~/Archive

echo "Moving directories..."
# Move with confirmation and error handling
# ... implementation details
```

## Migration Checklist

- [ ] Create backup of current state
- [ ] Create new directory structure
- [ ] Move git repositories to Projects/personal/
- [ ] Move work projects to Projects/work/
- [ ] Consolidate media files in Media/
- [ ] Move backup directories to Backups/
- [ ] Update symlinks
- [ ] Update application configurations that reference old paths
- [ ] Test that all applications still work
- [ ] Update backup configuration to use new structure
- [ ] Clean up empty directories
- [ ] Update shell aliases and environment variables

## Post-Migration Tasks

1. **Update Backup Configuration**: Modify restic backup paths to use new structure
2. **Update Development Tools**: Ensure IDEs and tools can find projects in new locations
3. **Update Scripts**: Any scripts that reference old paths need updating
4. **Update Documentation**: Update any documentation that references the old structure

## Maintenance

- Keep `~/Workspace/` clean - it's for temporary files only
- Regularly clean `~/Media/Downloads/`
- Archive old projects to `~/Archive/` when no longer active
- Use consistent naming conventions within each directory