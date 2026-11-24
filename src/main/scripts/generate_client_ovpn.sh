#!/usr/bin/env bash
set -euo pipefail

# generate_ovpn.sh
# Create an inline OpenVPN client profile (.ovpn) from existing credentials.

# Defaults
CLIENT_NAME="${CLIENT_NAME:-client}"
CREDS_DIR="${CREDS_DIR:-/client_credentials}"
SERVER_HOST="${SERVER_HOST:-}"
SERVER_PORT="${SERVER_PORT:-1194}"
PROTO="${PROTO:-udp}"
OUTPUT_PATH="${OUTPUT_PATH:-}"
CIPHER="${CIPHER:-AES-256-GCM}"
AUTH_DIGEST="${AUTH_DIGEST:-SHA384}"
KEY_DIRECTION="${KEY_DIRECTION:-1}"
VERBOSITY="${VERBOSITY:-3}"
REDIRECT_GATEWAY="${REDIRECT_GATEWAY:-true}"   # set to "false" to avoid redirecting all traffic
AUTH_NOCACHE="${AUTH_NOCACHE:-true}"           # set to "false" to skip auth-nocache
REMOTE_CERT_TLS="${REMOTE_CERT_TLS:-server}"   # typically "server"
VERIFY_X509_NAME="${VERIFY_X509_NAME:-}"       # e.g. "myservername" to pin CN/SAN
DEV_NAME="${DEV_NAME:-tun}"                    # typically "tun"
RESOLVE_RETRY="${RESOLVE_RETRY:-infinite}"     # or a number of seconds
EXPLICIT_EXIT_NOTIFY="${EXPLICIT_EXIT_NOTIFY:-3}" # only applies to UDP, set empty to disable

print_usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --clientname NAME           Client certificate/key base name (default: ${CLIENT_NAME})
  --credsdir PATH             Directory containing ca.crt, ta.key, and client cert/key (default: ${CREDS_DIR})
  --server-host HOST          Server hostname or IP (required unless provided via SERVER_HOST env)
  --server-port PORT          Server port (default: ${SERVER_PORT})
  --proto udp|tcp             Transport protocol (default: ${PROTO})
  --output PATH               Output .ovpn file path (default: print to stdout)
  --cipher NAME               Cipher (default: ${CIPHER})
  --auth-digest NAME          Auth digest (default: ${AUTH_DIGEST})
  --key-direction N           tls-auth/crypt key-direction (default: ${KEY_DIRECTION})
  --verbosity N               OpenVPN verb level (default: ${VERBOSITY})
  --no-redirect-gateway       Do not route all client traffic via VPN
  --no-auth-nocache           Do not add auth-nocache
  --remote-cert-tls TYPE      remote-cert-tls TYPE (default: ${REMOTE_CERT_TLS})
  --verify-x509-name NAME     Verify server cert name (optional)
  --dev NAME                  TUN/TAP device name (default: ${DEV_NAME})
  --resolve-retry VALUE       resolve-retry value (default: ${RESOLVE_RETRY})
  --explicit-exit-notify N    Set explicit-exit-notify (UDP only). Use 0 or empty to disable. (default: ${EXPLICIT_EXIT_NOTIFY})
  -h, --help                  Show this help

Environment variables with the same names can also be used to override defaults.
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --clientname) CLIENT_NAME="$2"; shift 2;;
    --credsdir) CREDS_DIR="$2"; shift 2;;
    --server-host) SERVER_HOST="$2"; shift 2;;
    --server-port) SERVER_PORT="$2"; shift 2;;
    --proto) PROTO="$2"; shift 2;;
    --output) OUTPUT_PATH="$2"; shift 2;;
    --cipher) CIPHER="$2"; shift 2;;
    --auth-digest) AUTH_DIGEST="$2"; shift 2;;
    --key-direction) KEY_DIRECTION="$2"; shift 2;;
    --verbosity) VERBOSITY="$2"; shift 2;;
    --no-redirect-gateway) REDIRECT_GATEWAY="false"; shift 1;;
    --no-auth-nocache) AUTH_NOCACHE="false"; shift 1;;
    --remote-cert-tls) REMOTE_CERT_TLS="$2"; shift 2;;
    --verify-x509-name) VERIFY_X509_NAME="$2"; shift 2;;
    --dev) DEV_NAME="$2"; shift 2;;
    --resolve-retry) RESOLVE_RETRY="$2"; shift 2;;
    --explicit-exit-notify) EXPLICIT_EXIT_NOTIFY="${2:-}"; shift 2;;
    -h|--help) print_usage; exit 0;;
    *) echo "Unknown option: $1" >&2; print_usage; exit 2;;
  esac
done

# Validate inputs
if [[ -z "${SERVER_HOST}" ]]; then
  echo "Error: --server-host is required (or set SERVER_HOST env var)" >&2
  exit 1
fi
if [[ "${PROTO}" != "udp" && "${PROTO}" != "tcp" ]]; then
  echo "Error: --proto must be 'udp' or 'tcp'" >&2
  exit 1
fi

# Resolve credential file paths
CA_CRT="${CREDS_DIR}/ca.crt"
TA_KEY="${CREDS_DIR}/ta.key"
CLIENT_CRT="${CREDS_DIR}/${CLIENT_NAME}.crt"
CLIENT_KEY="${CREDS_DIR}/${CLIENT_NAME}.key"

for f in "$CA_CRT" "$TA_KEY" "$CLIENT_CRT" "$CLIENT_KEY"; do
  if [[ ! -s "$f" ]]; then
    echo "Error: missing credential file: $f" >&2
    exit 1
  fi
done

# Assemble the profile
tmpfile="$(mktemp)"
cleanup() { rm -f "$tmpfile"; }
trap cleanup EXIT

{
  echo "client"
  echo "dev ${DEV_NAME}"
  echo "proto ${PROTO}"
  echo "remote ${SERVER_HOST} ${SERVER_PORT}"
  echo "resolv-retry ${RESOLVE_RETRY}"
  echo "nobind"
  echo "persist-key"
  echo "persist-tun"
  echo "remote-cert-tls ${REMOTE_CERT_TLS}"
  if [[ -n "${VERIFY_X509_NAME}" ]]; then
    # Mode 'name' is broadly compatible. Adjust if you need exact semantics for your setup.
    echo "verify-x509-name ${VERIFY_X509_NAME} name"
  fi
  echo "cipher ${CIPHER}"
  # Rely on TLS negotiation to select the most secure and compatible auth algorithm, preventing connection failures.
  # echo "auth ${AUTH_DIGEST}"
  echo "verb ${VERBOSITY}"
  if [[ "${AUTH_NOCACHE}" == "true" ]]; then
    echo "auth-nocache"
  fi
  if [[ "${REDIRECT_GATEWAY}" == "true" ]]; then
    echo "redirect-gateway def1"
  fi
  if [[ "${PROTO}" == "udp" && -n "${EXPLICIT_EXIT_NOTIFY}" ]]; then
    echo "explicit-exit-notify ${EXPLICIT_EXIT_NOTIFY}"
  fi
  echo "key-direction ${KEY_DIRECTION}"
  echo
  echo "<ca>"
  cat "$CA_CRT"
  echo "</ca>"
  echo
  echo "<cert>"
  # Some client certs include the chain; include as-is
  cat "$CLIENT_CRT"
  echo "</cert>"
  echo
  echo "<key>"
  cat "$CLIENT_KEY"
  echo "</key>"
  echo
  echo "<tls-auth>"
  cat "$TA_KEY"
  echo "</tls-auth>"
} > "$tmpfile"

# Output
if [[ -n "$OUTPUT_PATH" ]]; then
  mkdir -p "$(dirname "$OUTPUT_PATH")"
  mv "$tmpfile" "$OUTPUT_PATH"
  trap - EXIT
  echo "Wrote ${OUTPUT_PATH}"
else
  cat "$tmpfile"
fi