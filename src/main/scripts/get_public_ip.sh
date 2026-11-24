#!/usr/bin/env bash
# /scripts/get_public_ip.sh
# Provides get_public_ip function; when executed directly, prints the IP or exits non-zero with an error.

get_public_ip() {
  # Fail fast inside the function but don't exit the caller script on internal errors.
  set -euo pipefail

  require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
      echo "Error: required command not found: $1" >&2
      return 1
    }
  }

  require_cmd curl
  require_cmd tr

  try_fetch() {
    local url="$1"
    curl -fsS --max-time 5 "$url" | tr -d '\r\n'
  }

  is_valid_ipv4() {
    local ip="$1"
    [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
    IFS='.' read -r a b c d <<<"$ip"
    for n in "$a" "$b" "$c" "$d"; do
      (( n >= 0 && n <= 255 )) || return 1
    done
    return 0
  }

  local ip
  local candidates=(
    "https://checkip.amazonaws.com"
    "https://api.ipify.org"
    "https://ifconfig.me/ip"
    "https://icanhazip.com"
  )

  for url in "${candidates[@]}"; do
    ip="$(try_fetch "$url" 2>/dev/null || true)"
    if [[ -n "${ip:-}" ]] && is_valid_ipv4 "$ip"; then
      printf '%s\n' "$ip"
      return 0
    fi
  done

  echo "Error: could not determine public IP after trying multiple services." >&2
  return 1
}

# If executed directly, run the function and propagate its exit code.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  get_public_ip
fi