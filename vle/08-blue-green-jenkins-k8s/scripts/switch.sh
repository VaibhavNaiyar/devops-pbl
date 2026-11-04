#!/usr/bin/env bash
# Manual switch / rollback: bash switch.sh blue|green
set -euo pipefail
TO=${1:?blue or green}; OTHER=$([ "$TO" = blue ] && echo green || echo blue)
kubectl -n bluegreen patch svc shop-live    -p "{\"spec\":{\"selector\":{\"app\":\"shop\",\"color\":\"$TO\"}}}"
kubectl -n bluegreen patch svc shop-preview -p "{\"spec\":{\"selector\":{\"app\":\"shop\",\"color\":\"$OTHER\"}}}"
kubectl -n bluegreen get svc -o custom-columns=NAME:.metadata.name,COLOR:.spec.selector.color
