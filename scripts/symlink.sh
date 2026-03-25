#!/usr/bin/env bash
# symlink.sh - Create symbolic links for dotfiles

set -euo pipefail

# Load required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/scripts/lib/colors.sh"
source "$SCRIPT_DIR/scripts/lib/logging.sh"

# Dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_CONFIG_DIR="$DOTFILES_DIR/dotfiles"

create_symlink() {
  local source="$1"
  local target="$2"
  
  # Create parent directory if it doesn't exist
  local target_dir
  target_dir=$(dirname "$target")
  if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
    log_to_file "INFO: Created directory: $target_dir"
  fi
  
  # If target exists and is not a symlink, back it up
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    local backup="$target.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$target" "$backup"
    logwarn "Backed up existing file: $target → $backup"
    log_to_file "INFO: Backed up: $target → $backup"
  fi
  
  # Remove existing symlink if it exists
  if [ -L "$target" ]; then
    rm "$target"
  fi
  
  # Create symlink
  ln -sf "$source" "$target"
  log_to_file "INFO: Created symlink: $target → $source"
}

symlink_dotfiles() {
  if [ ! -d "$DOTFILES_DIR" ]; then
    logwarn "Dotfiles directory not found: $DOTFILES_DIR"
    return 1
  fi
  
  if [ ! -d "$DOTFILES_CONFIG_DIR" ]; then
    logwarn "Dotfiles config directory not found: $DOTFILES_CONFIG_DIR"
    log_no_sudo "Creating example dotfiles directory structure..."
    mkdir -p "$DOTFILES_CONFIG_DIR"
    logk
    return 0
  fi
  
  log_no_sudo "Creating symbolic links for dotfiles..."
  
  # Counter for created symlinks
  local count=0
  
  # Symlink all files in dotfiles directory
  while IFS= read -r -d '' file; do
    local filename
    filename=$(basename "$file")
    
    # Skip certain files
    case "$filename" in
      .DS_Store|.git|.gitignore|README.md)
        continue
        ;;
    esac
    
    # Determine target location
    local target="$HOME/$filename"
    
    # Create symlink
    create_symlink "$file" "$target"
    ((count++))
  done < <(find "$DOTFILES_CONFIG_DIR" -maxdepth 1 -type f -print0)
  
  # Symlink subdirectories for each top-level directory in dotfiles
  while IFS= read -r -d '' dir; do
    local dirname
    dirname=$(basename "$dir")

    mkdir -p "$HOME/$dirname"

    while IFS= read -r -d '' child; do
      local childname
      childname=$(basename "$child")
      local target="$HOME/$dirname/$childname"

      create_symlink "$child" "$target"
      ((count++))
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0)
  done < <(find "$DOTFILES_CONFIG_DIR" -mindepth 1 -maxdepth 1 -type d -print0)
  
  if [ $count -eq 0 ]; then
    logwarn "No dotfiles found to symlink in $DOTFILES_CONFIG_DIR"
  else
    log_no_sudo "Created $count symbolic link(s)."
    logk
  fi
  
  log_to_file "INFO: Symlinked $count dotfile(s)"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  symlink_dotfiles
fi