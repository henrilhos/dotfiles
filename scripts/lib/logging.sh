#!/usr/bin/env bash
# logging.sh - Logging functions

# Ensure LOG_FILE is set
LOG_FILE="${LOG_FILE:-/tmp/bootstrap_$(date +%Y%m%d_%H%M%S).log}"

log_to_file() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log_section() {
  echo
  echo -e "${CYAN}=========================================${NC}"
  echo -e "${CYAN}$*${NC}"
  echo -e "${CYAN}=========================================${NC}"
  log_to_file "SECTION: $*"
}

log_no_sudo() {
  STRAP_STEP="$*"
  echo -e "${BLUE}-->${NC} $*"
  log_to_file "INFO: $*"
}

log() {
  STRAP_STEP="$*"
  sudo_refresh 2>/dev/null || true
  echo -e "${BLUE}-->${NC} $*"
  log_to_file "INFO: $*"
}

logn_no_sudo() {
  STRAP_STEP="$*"
  printf -- "${BLUE}-->${NC} %s " "$*"
  log_to_file "INFO: $*"
}

logn() {
  STRAP_STEP="$*"
  sudo_refresh 2>/dev/null || true
  printf -- "${BLUE}-->${NC} %s " "$*"
  log_to_file "INFO: $*"
}

logk() {
  STRAP_STEP=""
  echo -e "${GREEN}✓ OK${NC}"
  log_to_file "SUCCESS: Previous step completed"
}

logskip() {
  STRAP_STEP=""
  echo -e "${YELLOW}⊘ SKIPPED${NC}"
  [[ -n "$*" ]] && echo "$*"
  log_to_file "SKIPPED: $*"
}

logwarn() {
  echo -e "${YELLOW}⚠ WARNING: $*${NC}"
  log_to_file "WARNING: $*"
}

abort() {
  STRAP_STEP=""
  echo -e "${RED}!!! $*${NC}" >&2
  log_to_file "ERROR: $*"
  exit 1
}

error_handler() {
  local exit_code=$?
  local line_number=$1
  
  if [ -z "${STRAP_SUCCESS:-}" ]; then
    echo -e "${RED}!!! Script failed at line $line_number with exit code $exit_code${NC}" >&2
    if [ -n "${STRAP_STEP:-}" ]; then
      echo -e "${RED}!!! Failed step: $STRAP_STEP${NC}" >&2
    fi
    if [ "${STRAP_DEBUG:-0}" -eq 0 ]; then
      echo -e "${YELLOW}!!! Run with --debug for debugging output.${NC}" >&2
      echo -e "${YELLOW}!!! Check the log file at: ${LOG_FILE}${NC}" >&2
    fi
    log_to_file "FAILED: Script execution failed at line $line_number with exit code $exit_code"
  fi
}

cleanup() {
  set +e
  
  # Clean up temporary files
  if [ -n "${SUDO_ASKPASS:-}" ]; then
    sudo --askpass rm -rf "${CLT_PLACEHOLDER:-}" "$SUDO_ASKPASS" "${SUDO_ASKPASS_DIR:-}" 2>/dev/null
    sudo --reset-timestamp 2>/dev/null
  fi
  
  # Clean up sensitive variables
  unset SUDO_PASSWORD STRAP_GITHUB_TOKEN
  
  # Show final status
  if [ -z "${STRAP_SUCCESS:-}" ]; then
    if [ -n "${STRAP_STEP:-}" ]; then
      echo -e "${RED}!!! $STRAP_STEP FAILED${NC}" >&2
    else
      echo -e "${RED}!!! FAILED${NC}" >&2
    fi
    log_to_file "FAILED: Script execution failed"
  else
    log_to_file "SUCCESS: Script completed successfully"
  fi
}

export -f log_to_file log_section log_no_sudo log logn_no_sudo logn
export -f logk logskip logwarn abort error_handler cleanup