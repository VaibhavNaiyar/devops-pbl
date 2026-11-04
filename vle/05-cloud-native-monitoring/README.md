# VLE 5 – Automated Cloud-Native Application Deployment with Monitoring

**Architecture:** Node.js microservice (12-factor, health/readiness endpoints, `/metrics`) → Docker multi-stage image → deployed with Docker Compose (or Kubernetes with HPA) → Prometheus scrapes metrics → Grafana dashboard (auto-provisioned) → Alert rules → Alertmanager.

```bash
bash deploy.sh          # tests, builds, deploys everything
bash load-test.sh       # generate traffic, watch Grafana
docker compose stop app # wait 30s -> "AppDown" alert fires in Prometheus/Alertmanager
docker compose down
```
**Kubernetes variant:**
```bash
kind create cluster --name pbl
docker build -t pbl-shop:1.0.0 app && kind load docker-image pbl-shop:1.0.0 --name pbl
kubectl apply -f k8s/app.yaml && kubectl get pods,svc,hpa
kubectl port-forward svc/shop 8080:80
```
**Metrics:** `http_requests_total`, `http_request_duration_seconds` (histogram), `shop_orders_total`, Node.js default metrics, node-exporter host metrics.
**Alerts:** AppDown, HighErrorRate (>5%), HighLatencyP95 (>500ms), HighCPU (>80%).
