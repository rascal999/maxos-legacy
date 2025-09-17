#!/bin/bash

# Script to fix module namespaces from modules.tools.* to maxos.tools.*
# This script updates all .nix files in modules/04-applications

set -e

echo "Fixing module namespaces in modules/04-applications..."

# Find all .nix files in modules/04-applications
find modules/04-applications -name "*.nix" -type f | while read -r file; do
    echo "Processing: $file"
    
    # Create backup
    cp "$file" "$file.backup"
    
    # Replace config.modules.tools. with config.maxos.tools.
    sed -i 's/config\.modules\.tools\./config.maxos.tools./g' "$file"
    
    # Replace options.modules.tools. with options.maxos.tools.
    sed -i 's/options\.modules\.tools\./options.maxos.tools./g' "$file"
    
    # Check if changes were made
    if ! diff -q "$file" "$file.backup" > /dev/null 2>&1; then
        echo "  ✓ Updated namespaces in $file"
    else
        echo "  - No changes needed in $file"
    fi
    
    # Remove backup if no changes were made
    if diff -q "$file" "$file.backup" > /dev/null 2>&1; then
        rm "$file.backup"
    fi
done

echo "Namespace fixes completed!"
echo ""
echo "Backup files (.backup) have been created for modified files."
echo "Review the changes and remove backup files when satisfied."