#!/usr/bin/env bash
# colors.sh - Color definitions for terminal output

if [[ -t 1 ]]; then
  readonly RED='\033[0;31m'
  readonly GREEN='\033[0;32m'
  readonly YELLOW='\033[1;33m'
  readonly BLUE='\033[0;34m'
  readonly MAGENTA='\033[0;35m'
  readonly CYAN='\033[0;36m'
  readonly NC='\033[0m'  # No Color
else
  readonly RED=''
  readonly GREEN=''
  readonly YELLOW=''
  readonly BLUE=''
  readonly MAGENTA=''
  readonly CYAN=''
  readonly NC=''
fi

export RED GREEN YELLOW BLUE MAGENTA CYAN NC