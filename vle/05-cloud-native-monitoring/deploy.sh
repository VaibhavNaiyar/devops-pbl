#!/usr/bin/env bash
# One-command automated deployment: test -> build -> deploy stack -> health check
set -euo pipefail
cd "$(dirname "$0")"
(cd app && npm ci && npm test)
docker compose up -d --build
echo "Waiting for app health..."
for i in $(seq 1 30); do curl -fs localhost:3000/health && break; sleep 2; done
echo
echo "App:          http://localhost:3000"
echo "Prometheus:   http://localhost:9090  (Status -> Targets, Alerts)"
echo "Grafana:      http://localhost:3001  (admin/admin) -> Dashboards -> PBL -> PBL Shop"
echo "Alertmanager: http://localhost:9094"
echo "Generate traffic: bash load-test.sh"
