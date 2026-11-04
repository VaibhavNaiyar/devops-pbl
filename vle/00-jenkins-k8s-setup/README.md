# Shared Jenkins + Kubernetes setup (VLE 7, 8, 9)

Jenkins runs in Docker on the same Docker network as a **kind** Kubernetes cluster, so pipelines can `docker build/push` and `kubectl apply` directly.

```bash
bash setup.sh
```
Teardown: `docker compose --profile devsecops down -v && kind delete cluster --name pbl`

> Uses Docker Hub as the registry. Create a Docker Hub access token (Account settings → Personal access tokens) and store it as the `dockerhub-creds` Jenkins credential — never inside the Jenkinsfile.
