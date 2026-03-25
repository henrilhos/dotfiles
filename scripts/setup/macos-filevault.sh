#!/usr/bin/env bash
# macos-filevault.sh - Configure FileVault full-disk encryption

set -euo pipefail

# Load required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/scripts/lib/colors.sh"
source "$SCRIPT_DIR/scripts/lib/logging.sh"
source "$SCRIPT_DIR/scripts/lib/sudo.sh"

setup_filevault() {
  if [ "${STRAP_ADMIN:-0}" -eq 0 ] || [ "${STRAP_CI:-0}" -gt 0 ]; then
    logskip "Skipping full-disk encryption (not admin or CI mode)."
    return 0
  fi
  
  logn "Checking full-disk encryption status:"
  
  local VAULT_MSG Q
  VAULT_MSG="FileVault is (On|Off, but will be enabled after the next restart)."
  Q=""
  [ "${STRAP_DEBUG:-0}" -eq 0 ] && Q="-q"
  
  # shellcheck disable=SC2086
  if fdesetup status 2>/dev/null | grep $Q -E "$VAULT_MSG"; then
    logk
    log_to_file "INFO: FileVault already enabled"
    return 0
  fi
  
  # FileVault is not enabled, try to enable it
  log "Enabling full-disk encryption (FileVault)..."
  
  local recovery_key_file="$HOME/Desktop/FileVault Recovery Key.txt"
  
  if sudo_askpass fdesetup enable -user "$USER" 2>/dev/null | tee "$recovery_key_file"; then
    echo
    echo -e "${GREEN}✓ FileVault enabled successfully!${NC}"
    echo -e "${YELLOW}=========================================${NC}"
    echo -e "${YELLOW}⚠️  IMPORTANT: Recovery Key Saved${NC}"
    echo -e "${YELLOW}=========================================${NC}"
    echo -e "${YELLOW}Your FileVault recovery key has been saved to:${NC}"
    echo -e "${CYAN}$recovery_key_file${NC}"
    echo
    echo -e "${YELLOW}Please do the following:${NC}"
    echo -e "${YELLOW}1. Copy this file to a secure location (USB drive, password manager)${NC}"
    echo -e "${YELLOW}2. Delete the file from your Desktop after backing it up${NC}"
    echo -e "${YELLOW}3. Keep the recovery key in a safe place - you'll need it if you forget your password${NC}"
    echo -e "${YELLOW}=========================================${NC}"
    echo
    
    if [ "${STRAP_INTERACTIVE:-0}" -gt 0 ]; then
      echo -e "${BLUE}Press Enter to continue...${NC}"
      read -r
    fi
    
    log "Full-disk encryption will be enabled after next reboot."
    logk
    log_to_file "INFO: FileVault enabled, recovery key saved to Desktop"
  else
    echo
    logwarn "FileVault could not be enabled automatically."
    echo -e "${YELLOW}You can enable it manually by running:${NC}"
    echo -e "${CYAN}  sudo fdesetup enable -user \"$USER\"${NC}"
    echo -e "${YELLOW}Or through System Settings > Privacy & Security > FileVault${NC}"
    log_to_file "WARNING: FileVault could not be enabled automatically"
    
    if [ "${STRAP_INTERACTIVE:-0}" -gt 0 ]; then
      echo
      echo -e "${BLUE}Press Enter to continue...${NC}"
      read -r
    fi
  fi
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_filevault
fi