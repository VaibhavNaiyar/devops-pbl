#!/usr/bin/env bash
# Run during a release - prints version every second, counts failed requests (should be 0)
URL=$(cd "$(dirname "$0")/terraform" && terraform output -raw url)
fail=0
while true; do
  out=$(curl -s -m 2 "$URL/health") || { fail=$((fail+1)); out="FAILED"; }
  echo "$(date +%T)  $out   failures=$fail"; sleep 1
done
