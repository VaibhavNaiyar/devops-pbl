# VLE 7 – CI/CD Pipeline to Deploy a Dockerized Application on Kubernetes using Jenkins

**Pipeline:** Checkout → `npm ci` + unit tests → Docker build (tag `1.0.<build#>`) → push to Docker Hub → `kubectl apply` (RollingUpdate, maxUnavailable 0) → rollout status → in-cluster smoke test → auto `rollout undo` on failure.

1. Run `vle/00-jenkins-k8s-setup/setup.sh` and finish the Jenkins steps it prints.
2. Push this whole `devops-pbl` folder to a GitHub repo.
3. Jenkins → New Item `shop-cicd` → Pipeline from SCM → Script Path `vle/07-cicd-jenkins-k8s/Jenkinsfile` → **Build Now**.
4. Open http://localhost:30080 – shows version `1.0.<build#>`.
5. Optional trigger: Build Triggers → *Poll SCM* `H/2 * * * *` (or a GitHub webhook via ngrok). Change the app, push → new version deploys automatically.

**Demo rollback:** break a test (e.g. change expected total) → push → pipeline stops at test stage, nothing deployed. `kubectl -n shop rollout history deployment/shop` shows revisions.
