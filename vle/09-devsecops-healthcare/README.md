# VLE 9 – Secure DevOps (DevSecOps) Implementation in a Healthcare System

**Scenario:** A hospital's patient-records API handles PHI (Protected Health Information). Regulations (HIPAA / India DPDP Act 2023) require access control, audit logs, integrity and transmission security. DevSecOps embeds automated security checks into every stage of CI/CD.

## Pipeline security gates
| # | Stage | Tool | Fails build when |
|---|---|---|---|
| 1 | Secret scanning | Gitleaks | any credential/key committed |
| 2 | Unit tests (incl. security tests) | node:test | auth, validation, masking, header tests fail |
| 3 | SCA | npm audit + OWASP Dependency-Check | High/Critical CVE in dependencies |
| 4 | SAST | SonarQube + Quality Gate | bugs, vulnerabilities, hotspots, coverage gate |
| 5 | Dockerfile lint | Hadolint | insecure Dockerfile practice |
| 6–7 | Container scan | Trivy image | fixable HIGH/CRITICAL OS/library CVE |
| 8 | IaC scan | Trivy config | insecure K8s manifests (root, privileged…) |
| 10 | Secure deploy | kubectl | — (Secret injected at deploy, PSA `restricted`) |
| 11 | DAST | OWASP ZAP baseline | report published |

## Application controls (src/app.js)
API-key auth with constant-time compare · strict input validation (regex allow-lists) · Helmet security headers · rate limiting · 10 kb body limit · phone number masking (minimum-necessary) · PHI-free audit log with hashed client id · generic error responses (no stack traces).

## Runtime controls (k8s/)
Non-root UID 1000 · read-only root filesystem · all Linux capabilities dropped · no privilege escalation · seccomp RuntimeDefault · Pod Security Admission `restricted` · no service-account token · CPU/memory limits · default-deny NetworkPolicy · least-privilege RBAC Role · API key from Kubernetes Secret.

## HIPAA technical safeguard mapping
| HIPAA §164.312 | Implementation |
|---|---|
| (a) Access control | API key auth, RBAC, NetworkPolicy, non-root containers |
| (b) Audit controls | structured audit log of every PHI read/create (no PHI in logs) |
| (c) Integrity | input validation, immutable versioned images, Trivy-scanned |
| (d) Authentication | constant-time API key verification, K8s Secret |
| (e) Transmission security | HSTS header; TLS at Ingress/ALB in production |

## Run
1. `vle/00-jenkins-k8s-setup/setup.sh` (starts SonarQube too). In SonarQube (http://localhost:9000, admin/admin) create a token.
2. Jenkins credentials: `dockerhub-creds`, `kubeconfig`, `sonar-token` (secret text), `patient-api-key` (secret text, any long random string).
3. New pipeline → Script Path `vle/09-devsecops-healthcare/Jenkinsfile` → Build.
4. Test: `curl -H "x-api-key: <your key>" localhost:30083/api/patients/P1001`

**Demo a blocked build:** `bash vle/09-devsecops-healthcare/security/leak-demo.sh add` → commit + push → Build → stage 1 Gitleaks fails, nothing is deployed. Then `leak-demo.sh remove` → commit + push → build passes.
(Don't use AWS's documented example key `AKIAIOSFODNN7EXAMPLE`: Gitleaks allow-lists it, so it would not block.)

**Notes:** OWASP Dependency-Check is optional (`RUN_DEPENDENCY_CHECK` build parameter), because its first run downloads the NVD database (20+ min). `npm audit` covers SCA by default.
