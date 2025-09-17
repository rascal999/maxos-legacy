#!/bin/bash

# Script to fix all module namespaces from modules.tools to maxos.tools
# This script updates all .nix files in the entire modules directory

set -e

echo "Fixing all module namespaces in modules/..."

# Find all .nix files in modules directory
find modules -name "*.nix" -type f | while read -r file; do
    echo "Processing: $file"
    
    # Create backup
    cp "$file" "$file.backup"
    
    # Replace modules.tools with maxos.tools (but not modules.toolBundles)
    sed -i 's/modules\.tools\([^B]\)/maxos.tools\1/g' "$file"
    
    # Check if changes were made
    if ! diff -q "$file" "$file.backup" > /dev/null 2>&1; then
        echo "  ✓ Updated namespaces in $file"
    else
        echo "  - No changes needed in $file"
        # Remove backup if no changes were made
        rm "$file.backup"
    fi
done

echo "All namespace fixes completed!"
echo ""
echo "Backup files (.backup) have been created for modified files."
echo "Review the changes and remove backup files when satisfied."