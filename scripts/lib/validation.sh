#!/usr/bin/env bash
# validation.sh - Validation functions

validate_required_vars() {
  local missing_vars=()
  
  if [[ -z "${GIT_NAME:-}" ]]; then
    missing_vars+=("GIT_NAME")
  fi
  
  if [[ -z "${GIT_EMAIL:-}" ]]; then
    missing_vars+=("GIT_EMAIL")
  fi
  
  if [[ ${#missing_vars[@]} -gt 0 ]]; then
    echo -e "${RED}!!! Missing required environment variables: ${missing_vars[*]}${NC}" >&2
    echo "!!! Set them before running this script:" >&2
    echo "!!!   export GIT_NAME='Your Name'" >&2
    echo "!!!   export GIT_EMAIL='your@email.com'" >&2
    exit 1
  fi
  
  log_to_file "INFO: Required variables validated (GIT_NAME, GIT_EMAIL)"
}

validate_dotfiles_url() {
  if [[ ! "${DOTFILES_URL:-}" =~ ^https?:// ]]; then
    abort "Invalid DOTFILES_URL: ${DOTFILES_URL:-empty} (must start with http:// or https://)"
  fi
  
  log_to_file "INFO: Dotfiles URL validated: $DOTFILES_URL"
}

check_prerequisites() {
  local missing_tools=()
  
  # Check essential commands
  command -v curl >/dev/null 2>&1 || missing_tools+=("curl")
  command -v git >/dev/null 2>&1 || missing_tools+=("git")
  
  if [[ ${#missing_tools[@]} -gt 0 ]]; then
    abort "Missing required tools: ${missing_tools[*]}"
  fi
  
  # Check internet connection
  log_no_sudo "Checking internet connection..."
  if ! curl -s --connect-timeout 5 https://www.google.com > /dev/null 2>&1; then
    abort "No internet connection detected. Please check your network."
  fi
  logk
  
  log_to_file "INFO: Prerequisites check passed"
}

export -f validate_required_vars validate_dotfiles_url check_prerequisites