#!/usr/bin/env bash
# sudo.sh - Sudo management functions

sudo_askpass() {
  if [ -n "${SUDO_ASKPASS:-}" ]; then
    sudo --askpass "$@"
  else
    sudo "$@"
  fi
}

sudo_init() {
  if [ "${STRAP_INTERACTIVE:-0}" -eq 0 ]; then
    sudo -n -l mkdir &>/dev/null && export STRAP_SUDO=1
    return
  fi
  
  local SUDO_PASSWORD SUDO_PASSWORD_SCRIPT
  if ! sudo --validate --non-interactive &>/dev/null; then
    while true; do
      read -rsp "--> Enter your password (for sudo access): " SUDO_PASSWORD
      echo
      if sudo --validate --stdin 2>/dev/null <<<"$SUDO_PASSWORD"; then
        break
      fi
      unset SUDO_PASSWORD
      echo -e "${RED}!!! Wrong password!${NC}" >&2
    done

    SUDO_PASSWORD_SCRIPT="$(
      cat <<-BASH
				#!/usr/bin/env bash
				echo "$SUDO_PASSWORD"
				BASH
    )"
    unset SUDO_PASSWORD
    SUDO_ASKPASS_DIR="$(mktemp -d)"
    SUDO_ASKPASS="$(mktemp "$SUDO_ASKPASS_DIR"/strap-askpass-XXXXXXXX)"
    chmod 700 "$SUDO_ASKPASS_DIR" "$SUDO_ASKPASS"
    bash -c "cat > '$SUDO_ASKPASS'" <<<"$SUDO_PASSWORD_SCRIPT"
    unset SUDO_PASSWORD_SCRIPT
    STRAP_SUDO=1

    export STRAP_SUDO SUDO_ASKPASS SUDO_ASKPASS_DIR
  else
    # Sudo already available (cached credentials)
    export STRAP_SUDO=1
  fi

  log_to_file "INFO: Sudo access initialized"
}

sudo_refresh() {
  if [ -n "${SUDO_ASKPASS:-}" ]; then
    sudo --askpass --validate 2>/dev/null || true
  elif [ "${STRAP_SUDO:-0}" -gt 0 ]; then
    sudo --validate 2>/dev/null || true
  fi
}

export -f sudo_askpass sudo_init sudo_refresh