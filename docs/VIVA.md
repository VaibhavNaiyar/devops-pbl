# Viva quick-prep

**Terraform** – declarative IaC by HashiCorp. `init` downloads providers, `plan` diffs desired vs state, `apply` creates, `destroy` removes. State file (`terraform.tfstate`) maps code → real resources; store remotely in S3 + DynamoDB lock for teams. Data source = read existing resource; output = print values; variable = input.

**Ansible** – agentless (SSH), push-based config management, YAML playbooks, idempotent modules. Inventory = hosts; handler = runs only when notified; template = Jinja2; facts = gathered host info. Terraform *provisions* infra, Ansible *configures* it.

**Docker** – client → dockerd → containerd → runc. Image = layered read-only template; container = running instance + writable layer. Dockerfile instructions: FROM, RUN, COPY, CMD vs ENTRYPOINT. Multi-stage builds shrink images. Swarm = native orchestration (manager/worker, services, replicas, overlay network).

**Kubernetes** – control plane (API server, etcd, scheduler, controller-manager) + nodes (kubelet, kube-proxy, runtime). Pod = smallest unit; Deployment = replicas + rolling updates; Service = stable IP/DNS (ClusterIP, NodePort, LoadBalancer); probes: liveness restarts, readiness controls traffic; HPA scales on CPU.

**CI/CD** – CI: build + test on every commit. CD: automatic deploy. Jenkinsfile = pipeline as code (stages, steps, post, credentials). Rollback via `kubectl rollout undo`.

**Deployment strategies** – Recreate (downtime), Rolling (gradual, `maxUnavailable: 0` = no downtime), Blue-Green (two full envs, instant switch/rollback, 2× cost), Canary (small % first).

**Monitoring** – Prometheus pulls metrics (`/metrics`), PromQL, alert rules → Alertmanager; Grafana visualises. CloudWatch = AWS-native metrics, logs, alarms. Golden signals: latency, traffic, errors, saturation.

**DevSecOps** – shift-left security. Secret scan (Gitleaks), SCA (npm audit, OWASP Dependency-Check), SAST (SonarQube), container scan (Trivy), IaC scan, DAST (OWASP ZAP). Least privilege, non-root containers, NetworkPolicy, Secrets. Healthcare → HIPAA: access control, audit, integrity, authentication, transmission security.

**AWS** – EC2 (VM), S3 (object storage, 11 nines durability), IAM (users/roles/policies – never use root), VPC/SG (stateful firewall), ALB (L7 LB), ASG (auto scaling + self-healing), CloudWatch (monitoring).
