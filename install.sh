#!/usr/bin/env bash
# alpha-sub-templates installer
# Usage: bash <(curl -Ls https://raw.githubusercontent.com/alphaclubdev/alpha-sub-templates/main/install.sh) [template-name]

set -euo pipefail

REPO="alphaclubdev/alpha-sub-templates"
BRANCH="main"
NAME="${1:-glass-dark}"
BASE_DIR="/etc/3x-ui/sub_templates"
DIR="${BASE_DIR}/${NAME}"
URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/templates/${NAME}/index.html"

if [[ ! "$NAME" =~ ^[a-z0-9-]+$ ]]; then
  echo "Error: invalid template name." >&2
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "Error: run as root." >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is not installed." >&2
  exit 1
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

echo "Downloading template: ${NAME}"
if ! curl -fsSL "$URL" -o "$TMP"; then
  echo "Error: download failed. Check the template name and your server's access to GitHub." >&2
  exit 1
fi

if [[ ! -s "$TMP" ]] || ! grep -qi "<html" "$TMP"; then
  echo "Error: downloaded file is not a valid template." >&2
  exit 1
fi

mkdir -p "$DIR"

if [[ -f "${DIR}/index.html" ]]; then
  cp "${DIR}/index.html" "${DIR}/index.html.bak"
  echo "Existing template backed up to ${DIR}/index.html.bak"
fi

install -m 644 "$TMP" "${DIR}/index.html"

echo
echo "Done. Template installed at: ${DIR}/"
echo
echo "Last step, in the 3x-ui panel:"
echo "  Panel Settings -> Subscription -> Profile tab"
echo "  Sub Theme Directory: ${DIR}/"
echo "Then save and open a subscription link."
