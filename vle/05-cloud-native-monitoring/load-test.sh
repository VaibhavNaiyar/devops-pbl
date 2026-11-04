#!/usr/bin/env bash
# Generates traffic so the Grafana graphs move
for i in $(seq 1 300); do
  curl -s localhost:3000/api/products >/dev/null
  curl -s -XPOST localhost:3000/api/orders -H 'content-type: application/json' -d '{"productId":1,"qty":1}' >/dev/null
  curl -s -XPOST localhost:3000/api/orders -H 'content-type: application/json' -d '{"productId":9,"qty":1}' >/dev/null
  sleep 0.2
done
