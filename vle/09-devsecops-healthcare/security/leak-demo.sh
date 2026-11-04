#!/usr/bin/env bash
# VLE 9 demo: plant a FAKE AWS key in app.js so the Gitleaks gate blocks the build.
#   bash security/leak-demo.sh add      -> commit + push -> build FAILS at stage 1 (nothing deployed)
#   bash security/leak-demo.sh remove   -> commit + push -> build passes again
# The key is assembled at runtime so this script itself never contains a full key.
# (AWS's documented example key AKIAIOSFODNN7EXAMPLE is allow-listed by Gitleaks, so it would NOT block.)
set -euo pipefail
F="$(dirname "$0")/../app/src/app.js"
case "${1:-}" in
  add)    K="AKIA4QWERTY7"; K="${K}PBL2LEAK"
          echo "const AWS_SECRET_KEY = \"$K\"; // leaked by mistake (demo)" >> "$F"; tail -1 "$F" ;;
  remove) sed -i '/leaked by mistake (demo)/d' "$F"; echo "removed demo key from $F" ;;
  *)      echo "usage: $0 add|remove"; exit 1 ;;
esac
