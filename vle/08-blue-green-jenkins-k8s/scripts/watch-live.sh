#!/usr/bin/env bash
# Shows which color/version is live every second during a switch (no failed requests expected)
f=0; while true; do o=$(curl -s -m 2 localhost:30081/health) || { f=$((f+1)); o=FAILED; }; echo "$(date +%T) $o fails=$f"; sleep 1; done
