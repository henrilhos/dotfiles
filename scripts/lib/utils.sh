#!/usr/bin/env bash
# utils.sh - Utility functions

escape() {
  printf '%s' "${1//\'/\'}"
}

check_os_and_arch() {
  local os arch
  os=$(uname -s)
  arch=$(uname -m)
  
  if [[ $os != "Darwin" ]]; then
    abort "Unsupported operating system: $os. This script only supports macOS on Apple Silicon."
  fi
  
  if [[ $arch != "arm64" ]]; then
    abort "Unsupported architecture: $arch. This script only supports Apple Silicon (arm64)."
  fi
  
  log_to_file "INFO: OS and architecture validated: $os $arch"
}

run_script() {
  local script_path="$1"
  local script_name
  script_name=$(basename "$script_path")
  
  if [ ! -f "$script_path" ]; then
    logwarn "Script not found: $script_path"
    return 1
  fi
  
  if [ ! -x "$script_path" ]; then
    chmod +x "$script_path"
  fi
  
  log_no_sudo "Running $script_name..."
  log_to_file "INFO: Executing script: $script_path"
  
  if bash "$script_path"; then
    log_to_file "INFO: Script completed successfully: $script_name"
    return 0
  else
    log_to_file "ERROR: Script failed: $script_name"
    return 1
  fi
}

run_dotfile_scripts() {
  if [ -d "$HOME/.dotfiles" ]; then
    (
      cd "$HOME/.dotfiles"
      for script in "$@"; do
        if [ -f "$script" ] && [ -x "$script" ]; then
          log_no_sudo "Running dotfiles script: $script"
          if [ "${STRAP_DEBUG:-0}" -eq 0 ]; then
            "$script" 2>/dev/null
          else
            "$script"
          fi
          log_to_file "INFO: Executed dotfiles script: $script"
          break
        fi
      done
    )
  fi
}

export -f escape check_os_and_arch run_script run_dotfile_scripts